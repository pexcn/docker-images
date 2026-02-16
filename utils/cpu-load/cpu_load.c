/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * cpu_load.c
 *
 * Copyright (c) 2026 pexcn <pexcn97@gmail.com>
 *
 * This program is free software; you may redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 3 of the License, or (at your
 * option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but it is
 * provided WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
 * Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * This file was originally created with the assistance of ChatGPT (OpenAI),
 * Gemini (Google) and Claude (Anthropic) then reviewed and modified by pexcn.
 */

#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <pthread.h>
#include <errno.h>
#include <stdatomic.h>
#include <sched.h>
#include <signal.h>
#include <getopt.h>

// Length of one control slice in milliseconds (default: 10 ms)
#define SLICE_MILLIS 10

// High frequency control parameters
#define CONTROL_STEP_SEC 0.1
#define STEPS_PER_SEC    10

// Proportional gain for the simple controller (actually an integral gain)
#define KP 0.5

// Global atomic flags / parameters
static atomic_int g_running        = 1;  // global "keep running" flag
static atomic_int g_load_enabled   = 0;  // 1 = workers should generate load, 0 = idle
static atomic_int g_target_percent = 0;  // per-core busy percentage for workers

// Stop flag set by signal handler (mainly for debugging / observability)
static volatile sig_atomic_t g_stop_flag = 0;

// CPU usage measurement from /proc/stat
static unsigned long long g_prev_total_jiffies = 0;
static unsigned long long g_prev_idle_jiffies  = 0;
static int    g_cpu_usage_inited = 0;   // 0 = first sample, no delta yet
static double g_last_cpu_usage   = 0.0; // last measured global CPU usage (0..100)

// Global file pointer for /proc/stat to avoid frequent open/close
static FILE *g_proc_stat_fp = NULL;

// Calibration result: loops per second
static unsigned long g_loops_per_sec = 0;

// Utility: read current time diff in seconds (double)
static double timespec_diff_sec(const struct timespec *start,
                                const struct timespec *end)
{
    time_t sec = end->tv_sec - start->tv_sec;
    long   nsec = end->tv_nsec - start->tv_nsec;
    return (double)sec + (double)nsec / 1000000000.0;
}

// Burn CPU using Integer ALU ops instead of NOP/Float
static void burn_cpu_loops(unsigned long loops)
{
    unsigned long v = 0;
    for (unsigned long i = 0; i < loops; ++i) {
        // Simple integer arithmetic mix (XOR + ADD)
        v = (v ^ 0x5AA5) + i;
        
        // Compiler barrier: tells the compiler that 'v' is modified/read here,
        // preventing the loop from being optimized away (Dead Code Elimination),
        // without generating extra instructions like volatile memory access would.
        __asm__ volatile ("" : "+r" (v));
    }
}

// Calibrate CPU speed at startup
static void calibrate_cpu_speed(void)
{
    fprintf(stdout, "Calibrating CPU speed... ");
    fflush(stdout);

    unsigned long loops = 100000;
    struct timespec start, end;
    double elapsed = 0.0;

    // Warm up
    burn_cpu_loops(loops);

    // Dynamic calibration
    while (1) {
        clock_gettime(CLOCK_MONOTONIC, &start);
        burn_cpu_loops(loops);
        clock_gettime(CLOCK_MONOTONIC, &end);

        elapsed = timespec_diff_sec(&start, &end);
        if (elapsed >= 0.05) { // Ensure at least 50ms for precision
            break;
        }
        loops *= 2;
    }

    g_loops_per_sec = (unsigned long)((double)loops / elapsed);
    fprintf(stdout, "Done. (%lu loops/sec)\n", g_loops_per_sec);
}

// Simple busy-wait for the given number of seconds on the current core.
static void busy_wait(double seconds)
{
    if (seconds <= 0.0) {
        return;
    }

    // Calculate required loops based on calibration
    unsigned long loops = (unsigned long)(seconds * (double)g_loops_per_sec);
    burn_cpu_loops(loops);
}

// Sleep for the given number of seconds using clock_nanosleep on CLOCK_MONOTONIC.
static void sleep_for(double seconds)
{
    if (seconds <= 0.0) {
        return;
    }

    struct timespec req;
    req.tv_sec  = (time_t)seconds;
    req.tv_nsec = (long)((seconds - (double)req.tv_sec) * 1000000000L);
    if (req.tv_nsec < 0) {
        req.tv_nsec = 0;
    } else if (req.tv_nsec >= 1000000000L) {
        req.tv_nsec = 999999999L;
    }

    struct timespec rem;
    for (;;) {
        int ret = clock_nanosleep(CLOCK_MONOTONIC, 0, &req, &rem);
        if (ret == 0) {
            break;
        }
        if (ret != EINTR) {
            // On other errors, give up the sleep but keep going.
            break;
        }
        // Restart sleep with remaining time if interrupted by a signal.
        req = rem;
    }
}

// Sleep in chunks up to max_step seconds, checking the running flag between chunks.
static void bounded_sleep(double seconds, double max_step)
{
    while (seconds > 0.0) {
        if (!atomic_load_explicit(&g_running, memory_order_relaxed)) {
            break;
        }
        double step = (seconds > max_step) ? max_step : seconds;
        sleep_for(step);
        seconds -= step;
    }
}

// Generate CPU load for approximately "interval_sec" seconds with
// the given "percent" usage on this core. The implementation uses
// short slices (e.g., 10 ms) for smoother average CPU usage.
static void generate_load_interval(double interval_sec, int percent)
{
    if (interval_sec <= 0.0) {
        return;
    }

    if (percent <= 0) {
        // 0% -> fully idle
        sleep_for(interval_sec);
        return;
    }

    if (percent >= 100) {
        // 100% -> fully busy
        busy_wait(interval_sec);
        return;
    }

    struct timespec t_start, t_now;
    clock_gettime(CLOCK_MONOTONIC, &t_start);

    for (;;) {
        clock_gettime(CLOCK_MONOTONIC, &t_now);
        double elapsed = timespec_diff_sec(&t_start, &t_now);
        if (elapsed >= interval_sec) {
            break;
        }

        double remaining = interval_sec - elapsed;
        double max_slice = (double)SLICE_MILLIS / 1000.0;
        double slice = (remaining > max_slice) ? max_slice : remaining;

        double busy_sec = slice * (double)percent / 100.0;
        double idle_sec = slice - busy_sec;

        if (busy_sec > 0.0) {
            busy_wait(busy_sec);
        }
        if (idle_sec > 0.0) {
            sleep_for(idle_sec);
        }
    }
}

// Parse percent range "min:max"
static int parse_percent_range(const char *s, int *out_min, int *out_max)
{
    if (!s || !out_min || !out_max) {
        return -1;
    }

    char *colon = strchr(s, ':');
    if (!colon) {
        return -1;
    }

    char   buf[64];
    size_t len1 = (size_t)(colon - s);
    size_t len2 = strlen(colon + 1);

    if (len1 == 0 || len1 >= sizeof(buf) ||
        len2 == 0 || len2 >= sizeof(buf)) {
        return -1;
    }

    memcpy(buf, s, len1);
    buf[len1] = '\0';
    int minp  = atoi(buf);

    memcpy(buf, colon + 1, len2);
    buf[len2] = '\0';
    int maxp  = atoi(buf);

    if (minp < 0 || maxp < 0 || minp > 100 || maxp > 100 || minp > maxp) {
        return -1;
    }

    *out_min = minp;
    *out_max = maxp;
    return 0;
}

// Parse time window "HH:MM-HH:MM" (same day, start < end)
static int parse_time_window(const char *s, int *out_start_sec, int *out_end_sec)
{
    if (!s || !out_start_sec || !out_end_sec) {
        return -1;
    }

    char *dash = strchr(s, '-');
    if (!dash) {
        return -1;
    }

    char   left[16], right[16];
    size_t len_left  = (size_t)(dash - s);
    size_t len_right = strlen(dash + 1);

    if (len_left == 0 || len_left >= sizeof(left) ||
        len_right == 0 || len_right >= sizeof(right)) {
        return -1;
    }

    memcpy(left, s, len_left);
    left[len_left] = '\0';
    memcpy(right, dash + 1, len_right);
    right[len_right] = '\0';

    int sh, sm, eh, em;
    if (sscanf(left,  "%d:%d", &sh, &sm) != 2) {
        return -1;
    }
    if (sscanf(right, "%d:%d", &eh, &em) != 2) {
        return -1;
    }

    if (sh < 0 || sh > 23 || eh < 0 || eh > 23 ||
        sm < 0 || sm > 59 || em < 0 || em > 59) {
        return -1;
    }

    int start = sh * 3600 + sm * 60;
    int end   = eh * 3600 + em * 60;

    // For simplicity: only support start < end within the same day.
    if (start >= end) {
        return -1;
    }

    *out_start_sec = start;
    *out_end_sec   = end;
    return 0;
}

// Read /proc/stat and update global CPU usage
static int read_proc_stat(unsigned long long *total, unsigned long long *idle)
{
    if (!total || !idle) {
        return -1;
    }

    // Check global file pointer
    if (!g_proc_stat_fp) {
        return -1;
    }

    // Rewind instead of reopening
    rewind(g_proc_stat_fp);

    // We only care about the aggregate "cpu" line.
    char line[512];
    if (!fgets(line, sizeof(line), g_proc_stat_fp)) {
        return -1;
    }

    // Format (Linux):
    // cpu user nice system idle iowait irq softirq steal guest guest_nice
    unsigned long long user = 0, nice = 0, system = 0;
    unsigned long long idle_v = 0, iowait = 0;
    int matched = sscanf(line,
                         "cpu  %llu %llu %llu %llu %llu",
                         &user, &nice, &system, &idle_v, &iowait);
    if (matched < 4) {
        return -1;
    }

    *idle  = idle_v + iowait;
    *total = user + nice + system + *idle;
    return 0;
}

// Update the global CPU usage value by sampling /proc/stat and computing a delta.
static void update_cpu_usage(void)
{
    unsigned long long total = 0, idle = 0;
    if (read_proc_stat(&total, &idle) != 0) {
        // If we cannot read, keep previous value.
        return;
    }

    if (!g_cpu_usage_inited) {
        g_prev_total_jiffies = total;
        g_prev_idle_jiffies  = idle;
        g_cpu_usage_inited   = 1;
        // On first sample, we do not know the usage yet; keep 0.
        g_last_cpu_usage     = 0.0;
        return;
    }

    unsigned long long dtotal = total - g_prev_total_jiffies;
    unsigned long long didle  = idle  - g_prev_idle_jiffies;
    g_prev_total_jiffies      = total;
    g_prev_idle_jiffies       = idle;

    if (dtotal == 0) {
        return;
    }

    double usage = 100.0 * (double)(dtotal - didle) / (double)dtotal;
    if (usage < 0.0)   usage = 0.0;
    if (usage > 100.0) usage = 100.0;

    g_last_cpu_usage = usage;
}

// Get current second of day and day-of-year
static void get_day_time(int *sec_of_day, int *yday)
{
    if (!sec_of_day || !yday) {
        return;
    }

    time_t now = time(NULL);
    struct tm tm_now;
    localtime_r(&now, &tm_now);

    *sec_of_day = tm_now.tm_hour * 3600 + tm_now.tm_min * 60 + tm_now.tm_sec;
    *yday       = tm_now.tm_yday;
}

// Signal handler: request a graceful shutdown
static void handle_signal(int signo)
{
    (void)signo;
    g_stop_flag = 1;
    atomic_store_explicit(&g_running,      0, memory_order_relaxed);
    atomic_store_explicit(&g_load_enabled, 0, memory_order_relaxed);
}

// Worker thread: generate CPU load as instructed
static void *worker_thread(void *arg)
{
    int cpu = *(int *)arg;
    free(arg);

    // Pin this thread to the given CPU, best-effort.
    cpu_set_t set;
    CPU_ZERO(&set);
    CPU_SET(cpu, &set);
    if (pthread_setaffinity_np(pthread_self(), sizeof(set), &set) != 0) {
        // If setting affinity fails, just continue without pinning.
    }

    while (atomic_load_explicit(&g_running, memory_order_relaxed)) {
        int enabled = atomic_load_explicit(&g_load_enabled, memory_order_relaxed);
        if (!enabled) {
            // No load requested: stay idle for a short interval
            sleep_for(CONTROL_STEP_SEC);
            continue;
        }

        int percent = atomic_load_explicit(&g_target_percent, memory_order_relaxed);
        generate_load_interval(CONTROL_STEP_SEC, percent);
    }

    return NULL;
}

// Helper to count available CPUs accurately
static int get_available_cpus(void) {
    cpu_set_t set;
    CPU_ZERO(&set);
    if (sched_getaffinity(0, sizeof(set), &set) == 0) {
        return CPU_COUNT(&set);
    }
    return (int)sysconf(_SC_NPROCESSORS_ONLN);
}

// Show help message
static void usage(const char *prog_name, int status)
{
    FILE *stream = (status == EXIT_SUCCESS) ? stdout : stderr;
    fprintf(stream,
            "Usage:\n"
            "  %s -p <percent_range> -t <time_range> -d <active_seconds>\n"
            "\n"
            "Example:\n"
            "  %s -p 40:60 -t 00:30-06:30 -d 7200\n"
            "\n"
            "Meaning:\n"
            "  Every day between 00:30 and 06:30, there will be a total of 7200 seconds with CPU load, randomly distributed in that window.\n"
            "  During those active seconds, overall CPU usage (averaged across cores) will fluctuate randomly between 40%% and 60%%.\n",
            prog_name, prog_name);
    exit(status);
}

int main(int argc, char *argv[])
{
    const char *opt_percent_range = NULL;
    const char *opt_time_range = NULL;
    const char *opt_active_seconds = NULL;

    int opt;
    while ((opt = getopt(argc, argv, "p:t:d:h")) != -1) {
        switch (opt) {
        case 'p':
            opt_percent_range = optarg;
            break;
        case 't':
            opt_time_range = optarg;
            break;
        case 'd':
            opt_active_seconds = optarg;
            break;
        case 'h':
            usage(argv[0], EXIT_SUCCESS);
            break;
        default:
            usage(argv[0], EXIT_FAILURE);
            break;
        }
    }

    if (!opt_percent_range || !opt_time_range || !opt_active_seconds || optind != argc) {
        usage(argv[0], EXIT_FAILURE);
    }

    // Parse percent range
    int min_percent, max_percent;
    if (parse_percent_range(opt_percent_range, &min_percent, &max_percent) != 0) {
        fprintf(stderr,
                "Invalid CPU percent range: %s, expected min:max, e.g. 40:60\n",
                opt_percent_range);
        return EXIT_FAILURE;
    }

    // Parse time window
    int window_start_sec, window_end_sec;
    if (parse_time_window(opt_time_range, &window_start_sec, &window_end_sec) != 0) {
        fprintf(stderr,
                "Invalid time window: %s, expected HH:MM-HH:MM, e.g. 00:30-06:30\n",
                opt_time_range);
        return EXIT_FAILURE;
    }
    int window_length = window_end_sec - window_start_sec;

    // Parse active seconds
    long active_seconds = strtol(opt_active_seconds, NULL, 10);
    if (active_seconds <= 0) {
        fprintf(stderr, "active_seconds must be a positive integer\n");
        return EXIT_FAILURE;
    }

    if (active_seconds > window_length) {
        // We clamp to window_length seconds (at most one load second per real second).
        fprintf(stderr,
                "Warning: active_seconds (%ld) is greater than window length (%d), clamping to window length.\n",
                active_seconds, window_length);
        active_seconds = window_length;
    }

    // Initialize random seed
    srandom((unsigned int)(time(NULL) ^ getpid()));

    // Install signal handlers before creating worker threads
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = handle_signal;
    sigemptyset(&sa.sa_mask);
    if (sigaction(SIGINT, &sa, NULL) != 0) {
        perror("sigaction(SIGINT)");
    }
    if (sigaction(SIGTERM, &sa, NULL) != 0) {
        perror("sigaction(SIGTERM)");
    }

    // Detect number of CPUs and create worker threads
    int n_cpus = get_available_cpus();
    if (n_cpus <= 0) {
        n_cpus = 1;
    }

    // Open /proc/stat once at startup
    g_proc_stat_fp = fopen("/proc/stat", "r");
    if (!g_proc_stat_fp) {
        perror("fopen /proc/stat");
        return EXIT_FAILURE;
    }

    // Calibrate before starting workers/printing info
    calibrate_cpu_speed();

    fprintf(stdout,
            "cpu-load started:\n"
            "  Time range     : %02d:%02d-%02d:%02d\n"
            "  Window length  : %d seconds\n"
            "  Active seconds : %ld seconds per day\n"
            "  CPU range      : %d%%-%d%%\n"
            "  Worker threads : %d (logical CPUs)\n",
            window_start_sec / 3600, (window_start_sec / 60) % 60,
            window_end_sec   / 3600, (window_end_sec   / 60) % 60,
            window_length, active_seconds,
            min_percent, max_percent,
            n_cpus);
    fflush(stdout);

    // create worker threads
    pthread_t *threads = calloc((size_t)n_cpus, sizeof(pthread_t));
    if (!threads) {
        perror("calloc");
        if (g_proc_stat_fp) {
            fclose(g_proc_stat_fp);
        }
        return EXIT_FAILURE;
    }

    for (int i = 0; i < n_cpus; ++i) {
        int *cpu_id = malloc(sizeof(int));
        if (!cpu_id) {
            perror("malloc");
            free(threads);
            if (g_proc_stat_fp) {
                fclose(g_proc_stat_fp);
            }
            return EXIT_FAILURE;
        }
        *cpu_id = i;

        if (pthread_create(&threads[i], NULL, worker_thread, cpu_id) != 0) {
            perror("pthread_create");
            free(cpu_id);
            free(threads);
            if (g_proc_stat_fp) {
                fclose(g_proc_stat_fp);
            }
            return EXIT_FAILURE;
        }
    }

    // Controller state: our own busy percentage contribution.
    double controller_own_percent = 0.0;

    // Scheduler loop (main thread)
    int last_yday = -1;
    long used_active_today = 0;

    while (atomic_load_explicit(&g_running, memory_order_relaxed)) {
        int sec_of_day, yday;
        get_day_time(&sec_of_day, &yday);

        // New day: reset counters
        if (yday != last_yday) {
            used_active_today = 0;
            last_yday = yday;
        }

        if (sec_of_day < window_start_sec) {
            // Before today's window: idle until window start (bounded).
            atomic_store_explicit(&g_load_enabled, 0, memory_order_relaxed);

            int delta = window_start_sec - sec_of_day;
            if (delta > 60) {
                delta = 60; // do not sleep too long, to be responsive to day changes
            }
            bounded_sleep((double)delta, 10.0);
            continue;
        }

        if (sec_of_day >= window_end_sec) {
            // After today's window: idle until next day.
            atomic_store_explicit(&g_load_enabled, 0, memory_order_relaxed);
            bounded_sleep(60.0, 10.0);
            continue;
        }

        // We are inside today's window
        long remaining_active = active_seconds - used_active_today;
        int remaining_window_seconds = window_end_sec - sec_of_day;

        if (remaining_active <= 0 || remaining_window_seconds <= 0) {
            // Already used all active seconds today; stay idle until window ends.
            atomic_store_explicit(&g_load_enabled, 0, memory_order_relaxed);
            bounded_sleep((double)remaining_window_seconds, 10.0);
            continue;
        }

        // Decide whether this second should be a "candidate load second"
        int load_candidate;
        if (remaining_active >= remaining_window_seconds) {
            // We must load in every remaining second to consume quota
            load_candidate = 1;
        } else {
            double p = (double)remaining_active / (double)remaining_window_seconds;
            double r = (double)random() / (double)RAND_MAX;
            load_candidate = (r < p) ? 1 : 0;
        }

        // Use last measured global CPU usage
        double current_usage = g_cpu_usage_inited ? g_last_cpu_usage : 0.0;

        if (!load_candidate) {
            // This second is not selected for active load: keep workers idle.
            atomic_store_explicit(&g_load_enabled, 0, memory_order_relaxed);

            // Sleep for ~1 second and update CPU usage measurement.
            sleep_for(1.0);
            update_cpu_usage();
            continue;
        }

        // Choose a random global target in [min_percent, max_percent] for this second.
        int target_global = min_percent;
        if (max_percent > min_percent) {
            int range = max_percent - min_percent + 1;
            target_global = min_percent + (int)(random() % range);
        }

        // Enable workers, but update control loop frequently (10Hz)
        atomic_store_explicit(&g_load_enabled, 1, memory_order_relaxed);

        for (int step = 0; step < STEPS_PER_SEC; ++step) {
            // Check running flag to exit immediately on signal
            if (!atomic_load(&g_running))
                break;

            // PID Calculation
            double error = (double)target_global - current_usage;
            controller_own_percent += KP * error;

            if (controller_own_percent < 0.0) controller_own_percent = 0.0;
            if (controller_own_percent > 100.0) controller_own_percent = 100.0;

            int own_percent_int = (int)(controller_own_percent + 0.5);

            // Push to workers
            atomic_store_explicit(&g_target_percent, own_percent_int, memory_order_relaxed);
            
            // Wait for 1 tick (0.1s)
            sleep_for(CONTROL_STEP_SEC);

            // Read Feedback
            update_cpu_usage();
            if (g_cpu_usage_inited) {
                current_usage = g_last_cpu_usage;
            }
        }

        // This second counts towards the active_seconds budget
        used_active_today += 1;
    }

    // Graceful shutdown: ensure workers see g_running == 0
    atomic_store_explicit(&g_running, 0, memory_order_relaxed);
    atomic_store_explicit(&g_load_enabled, 0, memory_order_relaxed);

    for (int i = 0; i < n_cpus; ++i) {
        pthread_join(threads[i], NULL);
    }
    free(threads);

    // Close global file pointer
    if (g_proc_stat_fp) {
        fclose(g_proc_stat_fp);
        g_proc_stat_fp = NULL;
    }

    return EXIT_SUCCESS;
}
