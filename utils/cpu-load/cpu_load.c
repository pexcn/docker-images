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
 * then reviewed and modified by pexcn.
 */

#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h>
#include <signal.h>

#define DAY_SECONDS (24 * 3600)

/* Global configuration */
static int g_start_sec = 0;
static int g_end_sec = 0;
static int g_window_len = 0;
static int g_total_active_seconds = 0;
static int g_min_percent = 0;
static int g_max_percent = 0;

/* Global pattern: which seconds in the window are active (CPU load) */
static int *g_active_pattern = NULL;
static int g_pattern_yday = -1;

/* Per-second scheduling: target CPU percent and tick counter */
static int g_current_percent = 0;
static unsigned long long g_tick_counter = 0;

/* Stop flag set by signal handler */
static volatile sig_atomic_t g_stop = 0;

/* Mutex + condition variable for per-second ticks */
static pthread_mutex_t g_tick_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t  g_tick_cond  = PTHREAD_COND_INITIALIZER;

/* Simple fatal error helper */
static void die(const char *msg) {
    perror(msg);
    exit(EXIT_FAILURE);
}

/* Parse time range: format HH:MM-HH:MM, e.g., 00:00-06:00 */
static void parse_time_range(const char *arg, int *start_sec, int *end_sec) {
    int h1, m1, h2, m2;
    if (sscanf(arg, "%d:%d-%d:%d", &h1, &m1, &h2, &m2) != 4) {
        fprintf(stderr, "Invalid time range: %s, expected HH:MM-HH:MM, e.g. 00:00-06:00\n", arg);
        exit(EXIT_FAILURE);
    }
    if (h1 < 0 || h1 > 23 || h2 < 0 || h2 > 23 ||
        m1 < 0 || m1 > 59 || m2 < 0 || m2 > 59) {
        fprintf(stderr, "Invalid time range: %s, hour must be [0,23], minute must be [0,59]\n", arg);
        exit(EXIT_FAILURE);
    }

    int s1 = h1 * 3600 + m1 * 60;
    int s2 = h2 * 3600 + m2 * 60;

    if (s1 >= s2) {
        fprintf(stderr,
                "Invalid time range: %s. This version only supports ranges within a single day\n"
                "with start < end, e.g. 23:00-23:59.\n",
                arg);
        exit(EXIT_FAILURE);
    }

    *start_sec = s1;
    *end_sec   = s2;
}

/* Parse CPU percent range: format min:max, e.g., 30:60 */
static void parse_percent_range(const char *arg, int *min_p, int *max_p) {
    int a, b;
    if (sscanf(arg, "%d:%d", &a, &b) != 2) {
        fprintf(stderr, "Invalid CPU percent range: %s, expected min:max, e.g. 30:60\n", arg);
        exit(EXIT_FAILURE);
    }
    if (a < 0 || b < 0 || a > 100 || b > 100 || a > b) {
        fprintf(stderr, "Invalid CPU percent range: %s, must satisfy 0 <= min <= max <= 100\n", arg);
        exit(EXIT_FAILURE);
    }
    *min_p = a;
    *max_p = b;
}

/* Get local seconds since midnight [0, 86399], also return tm_yday */
static int seconds_since_midnight(int *out_yday) {
    time_t now = time(NULL);
    if (now == (time_t)-1) die("time");

    struct tm lt;
    if (localtime_r(&now, &lt) == NULL) die("localtime_r");

    if (out_yday) {
        *out_yday = lt.tm_yday;
    }
    return lt.tm_hour * 3600 + lt.tm_min * 60 + lt.tm_sec;
}

/* Sleep with EINTR handling and stop flag awareness */
static void sleep_for_seconds(int seconds) {
    if (seconds <= 0) return;

    struct timespec ts;
    ts.tv_sec  = seconds;
    ts.tv_nsec = 0;

    while (!g_stop && nanosleep(&ts, &ts) == -1 && errno == EINTR) {
        /* continue sleeping while interrupted and not stopping */
    }
}

/* Busy-loop for approximately percent% of one second (single thread) */
static void burn_cpu_for_one_second(int percent) {
    const long long ONE_SEC_NS = 1000000000LL;

    if (percent <= 0) {
        sleep_for_seconds(1);
        return;
    }
    if (percent >= 100) {
        struct timespec start, now;
        if (clock_gettime(CLOCK_MONOTONIC, &start) == -1) die("clock_gettime");
        while (!g_stop) {
            if (clock_gettime(CLOCK_MONOTONIC, &now) == -1) die("clock_gettime");
            long long elapsed =
                (now.tv_sec - start.tv_sec) * ONE_SEC_NS +
                (now.tv_nsec - start.tv_nsec);
            if (elapsed >= ONE_SEC_NS) break;
        }
        return;
    }

    long long busy_ns = (ONE_SEC_NS * percent) / 100;
    struct timespec start, now;

    if (clock_gettime(CLOCK_MONOTONIC, &start) == -1) die("clock_gettime");

    /* Busy phase */
    while (!g_stop) {
        if (clock_gettime(CLOCK_MONOTONIC, &now) == -1) die("clock_gettime");
        long long elapsed =
            (now.tv_sec - start.tv_sec) * ONE_SEC_NS +
            (now.tv_nsec - start.tv_nsec);
        if (elapsed >= busy_ns) break;
    }

    /* Idle phase */
    if (clock_gettime(CLOCK_MONOTONIC, &now) == -1) die("clock_gettime");
    long long elapsed =
        (now.tv_sec - start.tv_sec) * ONE_SEC_NS +
        (now.tv_nsec - start.tv_nsec);

    if (!g_stop && elapsed < ONE_SEC_NS) {
        long long remain = ONE_SEC_NS - elapsed;
        struct timespec ts;
        ts.tv_sec  = remain / ONE_SEC_NS;
        ts.tv_nsec = remain % ONE_SEC_NS;
        while (!g_stop && nanosleep(&ts, &ts) == -1 && errno == EINTR) {
            /* continue sleeping while interrupted and not stopping */
        }
    }
}

/* Generate daily active pattern:
 * window_len: number of seconds in the time window
 * active_seconds: total number of seconds that should have load
 * returns array of size window_len, where 1 = active, 0 = idle
 */
static int *generate_active_pattern(int window_len, int active_seconds) {
    if (active_seconds > window_len) {
        fprintf(stderr,
                "Warning: total active seconds (%d) exceeds window length (%d), "
                "clamping to window length.\n",
                active_seconds, window_len);
        active_seconds = window_len;
    }
    int *active = calloc(window_len, sizeof(int));
    if (!active) die("calloc");

    /* Randomly mark active_seconds distinct seconds as active (1) */
    for (int i = 0; i < active_seconds; ++i) {
        while (1) {
            int idx = rand() % window_len;
            if (!active[idx]) {
                active[idx] = 1;
                break;
            }
        }
    }
    return active;
}

/* Signal handler: just set stop flag */
static void handle_signal(int signo) {
    (void)signo;
    g_stop = 1;
}

/* Worker thread: follow scheduler's per-second instruction */
static void *worker_thread(void *arg) {
    (void)arg;
    unsigned long long seen_tick = 0;

    for (;;) {
        if (g_stop) {
            break;
        }

        int percent;

        pthread_mutex_lock(&g_tick_mutex);
        while (!g_stop && seen_tick == g_tick_counter) {
            pthread_cond_wait(&g_tick_cond, &g_tick_mutex);
        }
        if (g_stop) {
            pthread_mutex_unlock(&g_tick_mutex);
            break;
        }
        seen_tick = g_tick_counter;
        percent = g_current_percent;
        pthread_mutex_unlock(&g_tick_mutex);

        if (percent > 0) {
            burn_cpu_for_one_second(percent);
        } else {
            sleep_for_seconds(1);
        }
    }

    return NULL;
}

/* Scheduler: decide each second whether we should load CPU and at what percent */
static void scheduler_loop(void) {
    for (;;) {
        if (g_stop) {
            break;
        }

        int yday;
        int sec_today = seconds_since_midnight(&yday);

        /* New day: regenerate pattern */
        if (g_pattern_yday != yday) {
            if (g_active_pattern) {
                free(g_active_pattern);
                g_active_pattern = NULL;
            }
            g_active_pattern = generate_active_pattern(g_window_len, g_total_active_seconds);
            g_pattern_yday = yday;

            fprintf(stdout, "New day (yday=%d), generated new random active pattern.\n", yday);
            fflush(stdout);
        }

        int percent = 0;

        if (sec_today >= g_start_sec && sec_today < g_end_sec) {
            int idx = sec_today - g_start_sec;  /* [0, g_window_len-1] */
            if (idx >= 0 && idx < g_window_len && g_active_pattern[idx]) {
                if (g_min_percent == g_max_percent) {
                    percent = g_min_percent;
                } else {
                    int range = g_max_percent - g_min_percent;
                    percent = g_min_percent + (rand() % (range + 1));  /* [min, max] */
                }
            }
        } else {
            /* Outside the window: force idle */
            percent = 0;
        }

        /* Publish this second's instruction to all workers */
        pthread_mutex_lock(&g_tick_mutex);
        g_current_percent = percent;
        g_tick_counter++;
        pthread_cond_broadcast(&g_tick_cond);
        pthread_mutex_unlock(&g_tick_mutex);

        /* Keep scheduler on a 1-second cadence */
        sleep_for_seconds(1);
    }

    /* Leaving scheduler: set percent=0, wake everyone so that workers can exit quickly */
    pthread_mutex_lock(&g_tick_mutex);
    g_current_percent = 0;
    g_tick_counter++;
    pthread_cond_broadcast(&g_tick_cond);
    pthread_mutex_unlock(&g_tick_mutex);
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr,
                "Usage: %s <time_range> <total_active_seconds> <cpu_percent_range>\n"
                "Example: %s 00:00-06:00 3600 30:60\n"
                "Meaning:\n"
                "  Every day between 00:00 and 06:00, there will be a total of 3600 seconds\n"
                "  with CPU load, randomly distributed in that window.\n"
                "  During those active seconds, overall CPU usage (averaged across cores)\n"
                "  will fluctuate randomly between 30%% and 60%%.\n",
                argv[0], argv[0]);
        return EXIT_FAILURE;
    }

    parse_time_range(argv[1], &g_start_sec, &g_end_sec);
    g_window_len = g_end_sec - g_start_sec;

    g_total_active_seconds = atoi(argv[2]);
    if (g_total_active_seconds <= 0) {
        fprintf(stderr, "total_active_seconds must be a positive integer\n");
        return EXIT_FAILURE;
    }
    if (g_total_active_seconds > g_window_len) {
        fprintf(stderr,
                "Warning: total_active_seconds (%d) is greater than window length (%d), "
                "clamping to window length.\n",
                g_total_active_seconds, g_window_len);
        g_total_active_seconds = g_window_len;
    }

    parse_percent_range(argv[3], &g_min_percent, &g_max_percent);

    /* Seed RNG; only used in the scheduler (main thread) */
    srand((unsigned int)(time(NULL) ^ getpid()));

    long nprocs = sysconf(_SC_NPROCESSORS_ONLN);
    if (nprocs < 1) nprocs = 1;
    int worker_count = (int)nprocs;

    /* Install signal handlers BEFORE creating threads */
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = handle_signal;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    if (sigaction(SIGINT, &sa, NULL) == -1) {
        die("sigaction(SIGINT)");
    }
    if (sigaction(SIGTERM, &sa, NULL) == -1) {
        die("sigaction(SIGTERM)");
    }

    fprintf(stdout,
            "cpu-load started:\n"
            "  Time range     : %02d:%02d-%02d:%02d\n"
            "  Window length  : %d seconds\n"
            "  Active seconds : %d seconds per day\n"
            "  CPU range      : %d%%-%d%%\n"
            "  Worker threads : %d (logical CPUs)\n",
            g_start_sec / 3600, (g_start_sec / 60) % 60,
            g_end_sec   / 3600, (g_end_sec   / 60) % 60,
            g_window_len, g_total_active_seconds,
            g_min_percent, g_max_percent,
            worker_count);
    fflush(stdout);

    /* Generate today's pattern */
    int yday;
    seconds_since_midnight(&yday);
    g_active_pattern = generate_active_pattern(g_window_len, g_total_active_seconds);
    g_pattern_yday = yday;

    /* Start worker threads */
    pthread_t *threads = calloc(worker_count, sizeof(pthread_t));
    if (!threads) die("calloc threads");

    for (int i = 0; i < worker_count; ++i) {
        if (pthread_create(&threads[i], NULL, worker_thread, NULL) != 0) {
            die("pthread_create");
        }
    }

    /* Main thread acts as scheduler */
    scheduler_loop();

    /* Not reached in normal use */
    for (int i = 0; i < worker_count; ++i) {
        pthread_join(threads[i], NULL);
    }
    free(threads);
    free(g_active_pattern);

    return EXIT_SUCCESS;
}
