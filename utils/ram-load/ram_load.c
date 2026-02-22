/* SPDX-License-Identifier: GPL-3.0-or-later */
/*
 * ram_load.c
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
#include <unistd.h>
#include <signal.h>
#include <time.h>
#include <math.h>
#include <errno.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sched.h>
#include <fcntl.h>
#include <getopt.h>

// Allocation granularity per chunk
#define CHUNK_SIZE             (16UL * 1024 * 1024)  // 16 MB per chunk
#define MAX_CHUNKS             8192                   // hard cap: 8192 * 16MB = 128 GB
#define FILL_BATCH             (4UL * 1024 * 1024)   // fill 4 MB at a time, then yield

// Control loop timing
#define LOOP_SEC_MIN           5                      // minimum sleep between cycles (sec)
#define LOOP_SEC_MAX           10                     // maximum sleep between cycles (sec)
#define MAX_ADJUST_PER_CYCLE   2                      // max chunks to add or remove per cycle

// Sine wave period range (seconds)
#define SINE_PERIOD_MIN_SEC    2700.0                 // 45 minutes
#define SINE_PERIOD_MAX_SEC    5400.0                 // 90 minutes

// Noise amplitude as a fraction of local cycle range
#define NOISE_RATIO            0.08                   // +-8% * range

// EMA smoothing factor for baseline (alpha = 0.1 ~= 10-sample window ~75 seconds)
#define BASELINE_EMA_ALPHA     0.1

// Hard upper bound to avoid OOM
#define MAX_PCT_SAFETY         95.0

// Memory chunk descriptor
typedef struct {
    void  *ptr;
    size_t size;
} Chunk;

static volatile sig_atomic_t  g_running       = 1;    // set to 0 by signal handler
static Chunk                 *g_chunks        = NULL;  // array of allocated chunks
static int                    g_nchunks       = 0;     // number of currently held chunks
static uint64_t               g_rng_state     = 0;    // xorshift64 state, seeded at startup
static double                 g_baseline_ema  = -1.0; // EMA of others' memory usage (%); -1 = uninitialized

// Signal handler: request graceful shutdown
static void handle_signal(int signo)
{
    (void)signo;
    g_running = 0;
}

// xorshift64: fast non-cryptographic PRNG with a full 2^64-1 period
static inline uint64_t xorshift64(void)
{
    g_rng_state ^= g_rng_state << 13;
    g_rng_state ^= g_rng_state >> 7;
    g_rng_state ^= g_rng_state << 17;
    return g_rng_state;
}

// Return a uniform integer in [lo, hi]
static inline int rand_int_range(int lo, int hi)
{
    return lo + (int)(xorshift64() % (uint64_t)(hi - lo + 1));
}

// Return a uniform double in [0.0, 1.0) with 53-bit precision
static inline double rand_f64_01(void)
{
    return (double)(xorshift64() >> 11) / (double)(1ULL << 53);
}

// Return a uniform double in [-1.0, +1.0)
static inline double rand_f64_sym(void)
{
    return rand_f64_01() * 2.0 - 1.0;
}

// Return a uniform double in [lo, hi)
static inline double rand_f64_range(double lo, double hi)
{
    return lo + rand_f64_01() * (hi - lo);
}

// Fill a memory region with non-repeating pseudo-random bytes to defeat KSM
// page merging and zRAM compression.  Uses a private xorshift64 state seeded
// from the pointer address so that each chunk produces unique content.
static void fill_random(void *ptr, size_t size)
{
    uint64_t s = (uint64_t)(uintptr_t)ptr
               ^ (uint64_t)time(NULL)
               ^ (uint64_t)getpid()
               ^ 0xDEADC0DECAFEULL;

    uint64_t *p = (uint64_t *)ptr;
    size_t    n = size / sizeof(uint64_t);
    for (size_t i = 0; i < n; i++) {
        s ^= s << 13;
        s ^= s >> 7;
        s ^= s << 17;
        p[i] = s;
    }
}

// Memory snapshot from /proc/meminfo
typedef struct {
    long total_kb;
    long available_kb;
} MemInfo;

// Read MemTotal and MemAvailable from /proc/meminfo.
// Returns 0 on success, -1 on failure.
static int read_meminfo(MemInfo *out)
{
    FILE *f = fopen("/proc/meminfo", "r");
    if (!f) {
        return -1;
    }

    char line[256];
    int  found = 0;
    out->total_kb = out->available_kb = 0;

    while (fgets(line, sizeof(line), f) && found < 2) {
        long v;
        if (sscanf(line, "MemTotal: %ld kB", &v) == 1) {
            out->total_kb = v;
            found++;
        } else if (sscanf(line, "MemAvailable: %ld kB", &v) == 1) {
            out->available_kb = v;
            found++;
        }
    }

    fclose(f);
    return (found == 2) ? 0 : -1;
}

// Return the RSS of the current process in kB from /proc/self/status.
// Used to exclude own footprint when computing system-wide usage.
static long get_own_rss_kb(void)
{
    FILE *f = fopen("/proc/self/status", "r");
    if (!f) {
        return 0;
    }

    char line[256];
    long rss = 0;
    while (fgets(line, sizeof(line), f)) {
        if (sscanf(line, "VmRSS: %ld kB", &rss) == 1) {
            break;
        }
    }

    fclose(f);
    return rss;
}

// Allocate one chunk: mmap, fill with random data, then mlock to prevent swap.
// Returns 0 on success, -1 on failure.
static int chunk_add(void)
{
    if (g_nchunks >= MAX_CHUNKS) {
        return -1;
    }

    void *ptr = mmap(NULL, CHUNK_SIZE,
                     PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (ptr == MAP_FAILED) {
        return -1;
    }

    // Fill in FILL_BATCH increments, yielding between batches to reduce
    // CPU monopolization during allocation.
    uint8_t *p   = (uint8_t *)ptr;
    size_t   rem = CHUNK_SIZE;
    while (rem > 0) {
        size_t batch = (rem < FILL_BATCH) ? rem : FILL_BATCH;
        fill_random(p, batch);
        p   += batch;
        rem -= batch;
        sched_yield();
    }

    // mlock prevents the kernel from swapping these pages out, keeping
    // RSS stable and consistent with what the cloud dashboard reports.
    // Silently ignore if unprivileged or RLIMIT_MEMLOCK is exceeded.
    (void)mlock(ptr, CHUNK_SIZE);

    g_chunks[g_nchunks].ptr  = ptr;
    g_chunks[g_nchunks].size = CHUNK_SIZE;
    g_nchunks++;
    return 0;
}

// Release the most recently allocated chunk.
static void chunk_remove(void)
{
    if (g_nchunks <= 0) {
        return;
    }

    g_nchunks--;
    munlock(g_chunks[g_nchunks].ptr, g_chunks[g_nchunks].size);
    munmap(g_chunks[g_nchunks].ptr,  g_chunks[g_nchunks].size);
    g_chunks[g_nchunks].ptr = NULL;
}

// Release all held chunks.
static void chunks_free_all(void)
{
    while (g_nchunks > 0) {
        chunk_remove();
    }
}

// Parse "HH:MM" into minutes-since-midnight.  Returns 0 on success, -1 on error.
static int parse_hhmm(const char *s, int *out_min)
{
    int h, m;
    if (sscanf(s, "%d:%d", &h, &m) != 2) {
        return -1;
    }
    if (h < 0 || h > 23 || m < 0 || m > 59) {
        return -1;
    }
    *out_min = h * 60 + m;
    return 0;
}

// Parse "HH:MM-HH:MM" into start/end minutes.  Returns 0 on success, -1 on error.
static int parse_time_window(const char *input, int *out_start, int *out_end)
{
    if (!input || !out_start || !out_end) {
        return -1;
    }

    // Search for '-' after position 4 to skip the ':' inside "HH:MM"
    const char *dash = strchr(input + 4, '-');
    if (!dash) {
        return -1;
    }

    char left[16];
    size_t len = (size_t)(dash - input);
    if (len == 0 || len >= sizeof(left)) {
        return -1;
    }
    memcpy(left, input, len);
    left[len] = '\0';

    if (parse_hhmm(left, out_start) != 0) {
        return -1;
    }
    if (parse_hhmm(dash + 1, out_end) != 0) {
        return -1;
    }
    return 0;
}

// Return 1 if the current local time is inside [start_min, end_min).
// Supports cross-midnight windows (e.g. 23:00-08:00).
static int in_time_window(int start_min, int end_min)
{
    time_t    now = time(NULL);
    struct tm tm_now;
    localtime_r(&now, &tm_now);

    int cur = tm_now.tm_hour * 60 + tm_now.tm_min;

    if (start_min <= end_min) {
        return cur >= start_min && cur < end_min;
    }
    // Cross-midnight window
    return cur >= start_min || cur < end_min;
}

// Compute the target memory usage percentage.
//
// Every wave therefore has a different height and depth, so the curve never
// locks into a uniform peak-to-trough pattern over a full day.
// Smooths transient memory spikes to avoid anchoring the cycle's baseline at
// an artificially high level.
// The small xorshift64 noise (+-8%) adds short-term jitter on top.
static double compute_target(double min_p, double max_p, double elapsed_sec,
                             double baseline_ema)
{
    static double cycle_start = 0.0; // start time of the current sine cycle
    static double period      = 0.0; // length of the current cycle; 0 = uninitialized
    static double local_lo    = 0.0; // this cycle's randomized trough
    static double local_hi    = 0.0; // this cycle's randomized peak

    // Advance past any completed periods and flag when a new cycle begins.
    int new_cycle = (period <= 0.0); // true on very first call
    while (period <= 0.0 || elapsed_sec >= cycle_start + period) {
        // Anchor the new cycle at the exact end of the previous one to avoid
        // accumulating timing drift from sleep overruns.
        cycle_start = (period > 0.0) ? (cycle_start + period) : 0.0;
        period      = rand_f64_range(SINE_PERIOD_MIN_SEC, SINE_PERIOD_MAX_SEC);
        new_cycle   = 1;
    }

    if (new_cycle) {
        // Effective lower bound: 1pp above the smoothed baseline so we always
        // contribute something visible.  Using the EMA here (not the raw
        // instantaneous value) is what prevents transient spikes from
        // anchoring local_lo high for an entire cycle.
        double eff_min = baseline_ema + 1.0;
        if (eff_min < min_p)  eff_min = min_p;
        if (eff_min >= max_p) eff_min = max_p - 1.0; // keep room to rise

        double eff_range = max_p - eff_min;

        // Trough: anywhere in the lower half of the effective range.
        local_lo = rand_f64_range(eff_min, eff_min + eff_range * 0.5);

        // Peak: at least 20% of the full [min_p, max_p] range above the trough,
        // up to max_p.  Using the full range for the minimum rise keeps waves
        // visually meaningful even when eff_min is high.
        double peak_floor = local_lo + (max_p - min_p) * 0.2;
        if (peak_floor > max_p) peak_floor = max_p;
        local_hi = rand_f64_range(peak_floor, max_p);
    }

    double phase     = (elapsed_sec - cycle_start) / period;
    double loc_range = local_hi - local_lo;

    // Amplitude 0.45 (not 0.5) keeps sine_pos in [0.05, 0.95], leaving
    // headroom so the +-8% noise rarely hits the clamp boundary.
    double sine_pos = 0.5 + 0.45 * sin(2.0 * M_PI * phase);
    double noise    = rand_f64_sym() * NOISE_RATIO;
    double raw      = local_lo + loc_range * (sine_pos + noise);

    if (raw < min_p) raw = min_p;
    if (raw > max_p) raw = max_p;
    return raw;
}

// Get a formatted timestamp string "[HH:MM:SS]"
static void get_time_str(char *buf, size_t size)
{
    time_t    now = time(NULL);
    struct tm tm_now;
    localtime_r(&now, &tm_now);
    strftime(buf, size, "[%H:%M:%S]", &tm_now);
}

// Show usage information and exit
static void usage(const char *prog, int status)
{
    FILE *stream = (status == EXIT_SUCCESS) ? stdout : stderr;
    fprintf(stream,
            "Usage:\n"
            "  %s -p <min>[:<max>] [-t <HH:MM>-<HH:MM>]\n"
            "\n"
            "Options:\n"
            "  -p  Target system memory usage percent, e.g. 20 or 20:50\n"
            "  -t  Active time window (local time), e.g. 23:00-08:00\n"
            "      Inside the window usage follows sine+noise in [min, max].\n"
            "      Outside the window usage is held at min.\n"
            "\n"
            "Example:\n"
            "  %s -p 20:50 -t 23:00-08:00\n",
            prog, prog);
    exit(status);
}

int main(int argc, char *argv[])
{
    const char *opt_percent = NULL;
    const char *opt_window  = NULL;

    int opt;
    while ((opt = getopt(argc, argv, "p:t:h")) != -1) {
        switch (opt) {
        case 'p':
            opt_percent = optarg;
            break;
        case 't':
            opt_window = optarg;
            break;
        case 'h':
            usage(argv[0], EXIT_SUCCESS);
            break;
        default:
            usage(argv[0], EXIT_FAILURE);
            break;
        }
    }

    if (!opt_percent || optind != argc) {
        usage(argv[0], EXIT_FAILURE);
    }

    // Parse percent range
    double min_percent, max_percent;
    {
        char *colon = strchr(opt_percent, ':');
        if (colon) {
            char buf[64];
            size_t len = (size_t)(colon - opt_percent);
            if (len == 0 || len >= sizeof(buf)) {
                fprintf(stderr, "Invalid -p argument: %s\n", opt_percent);
                return EXIT_FAILURE;
            }
            memcpy(buf, opt_percent, len);
            buf[len] = '\0';
            min_percent = atof(buf);
            max_percent = atof(colon + 1);
        } else {
            min_percent = max_percent = atof(opt_percent);
        }
    }

    if (min_percent < 0.0 || max_percent > MAX_PCT_SAFETY || min_percent > max_percent) {
        fprintf(stderr, "Invalid percent range: %.1f:%.1f (must be 0 <= min <= max <= %.0f)\n",
                min_percent, max_percent, MAX_PCT_SAFETY);
        return EXIT_FAILURE;
    }

    // Parse optional time window
    int start_min = 0, end_min = 0, has_window = 0;
    if (opt_window) {
        if (parse_time_window(opt_window, &start_min, &end_min) != 0) {
            fprintf(stderr, "Invalid time window: %s\n", opt_window);
            return EXIT_FAILURE;
        }
        has_window = 1;
    }

    // Install signal handlers
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = handle_signal;
    sigemptyset(&sa.sa_mask);
    sigaction(SIGINT,  &sa, NULL);
    sigaction(SIGTERM, &sa, NULL);

    // Seed PRNG from /dev/urandom; fall back to time^pid if unavailable.
    // /dev/urandom ensures unique curves across rapid systemd restarts where
    // time()+getpid() could collide.
    {
        uint64_t seed = 0;
        int ufd = open("/dev/urandom", O_RDONLY);
        if (ufd >= 0) {
            ssize_t nr = read(ufd, &seed, sizeof(seed));
            close(ufd);
            if (nr != (ssize_t)sizeof(seed)) {
                seed = 0;
            }
        }
        if (seed == 0) {
            // xorshift64 must not start with state 0
            seed = (uint64_t)time(NULL) ^ ((uint64_t)getpid() << 32)
                 ^ 0xFEEDFACEDEADBEEFULL;
        }
        g_rng_state = seed;
    }

    g_chunks = calloc(MAX_CHUNKS, sizeof(Chunk));
    if (!g_chunks) {
        perror("calloc");
        return EXIT_FAILURE;
    }

    // Print startup banner
    fprintf(stdout,
            "RAM Load started\n"
            "  Algorithm      : sine (%.0f-%.0f min/cycle, random trough+peak per cycle) + xorshift64 noise (+-%.0f%%)\n"
            "  Percent range  : %.1f%% - %.1f%%\n"
            "  Active window  : ",
            SINE_PERIOD_MIN_SEC / 60.0, SINE_PERIOD_MAX_SEC / 60.0, NOISE_RATIO * 100.0,
            min_percent, max_percent);
    if (has_window) {
        fprintf(stdout, "%02d:%02d-%02d:%02d (idle: hold min)\n",
                start_min / 60, start_min % 60, end_min / 60, end_min % 60);
    } else {
        fprintf(stdout, "whole day\n");
    }
    fprintf(stdout,
            "  Control cycle  : %d-%d sec (random), chunk %lu MB, max +-%.0f MB/cycle\n",
            LOOP_SEC_MIN, LOOP_SEC_MAX,
            (unsigned long)(CHUNK_SIZE >> 20),
            (double)MAX_ADJUST_PER_CYCLE * (CHUNK_SIZE >> 20));
    fflush(stdout);

    time_t prog_start = time(NULL);
    char   time_buf[32];

    // Main control loop
    while (g_running) {
        // Read current memory state
        MemInfo mi;
        if (read_meminfo(&mi) != 0) {
            fprintf(stderr, "Failed to read /proc/meminfo, retrying in 10s\n");
            sleep(10);
            continue;
        }

        double used_pct = 100.0 * (mi.total_kb - mi.available_kb) / (double)mi.total_kb;

        // Compute baseline: memory used by all processes OTHER than us.
        //
        //   system_used  = MemTotal - MemAvailable (includes our RSS)
        //   others_used  = system_used - own_rss
        //   baseline_pct = others_used / total * 100
        //
        // Subtracting own RSS avoids the feedback where a larger self footprint
        // raises system usage, which in turn lowers the computed target, causing
        // oscillation.
        long own_rss_kb     = get_own_rss_kb();
        long system_used_kb = mi.total_kb - mi.available_kb;
        long others_used_kb = system_used_kb - own_rss_kb;
        if (others_used_kb < 0) {
            others_used_kb = 0;
        }
        double baseline_pct = 100.0 * (double)others_used_kb / (double)mi.total_kb;

        // Update the EMA of baseline_pct every control iteration.
        // Using the EMA (rather than the raw instantaneous value) prevents a
        // transient spike (apt upgrade, logrotate) coinciding with a new cycle
        // boundary from anchoring local_lo high for an entire 45-90 min cycle.
        // alpha=BASELINE_EMA_ALPHA weights the current sample at 10%, smoothing
        // over ~10 samples (~75 seconds at a 7.5-second average cycle).
        // Genuine long-term baseline shifts (new resident service) are still
        // tracked since the EMA converges within a few minutes.
        // On the very first iteration, seed directly so the EMA is valid
        // immediately without a slow warm-up from zero.
        if (g_baseline_ema < 0.0) {
            g_baseline_ema = baseline_pct;
        } else {
            g_baseline_ema = (1.0 - BASELINE_EMA_ALPHA) * g_baseline_ema
                           + BASELINE_EMA_ALPHA * baseline_pct;
        }

        // Safety guard: if the system (including us) already exceeds max_percent,
        // release everything to avoid competing with real workloads for memory.
        if (used_pct >= max_percent) {
            if (g_nchunks > 0) {
                get_time_str(time_buf, sizeof(time_buf));
                fprintf(stdout, "%s [Safety] system %.1f%% >= max %.1f%%, releasing all\n",
                        time_buf, used_pct, max_percent);
                fflush(stdout);
                chunks_free_all();
            }
            for (int s = 0; s < LOOP_SEC_MAX && g_running; s++) {
                sleep(1);
            }
            continue;
        }

        // If even the smoothed baseline exceeds max_percent, other processes are
        // occupying more than the user's ceiling.  Use the EMA (not the raw value)
        // to avoid false warnings from transient spikes.
        if (g_baseline_ema >= max_percent) {
            get_time_str(time_buf, sizeof(time_buf));
            fprintf(stdout, "%s [Warning] baseline(EMA) %.1f%% >= max %.1f%%,"
                    " other processes exceed your -p ceiling; holding\n",
                    time_buf, g_baseline_ema, max_percent);
            fflush(stdout);
            for (int s = 0; s < LOOP_SEC_MAX && g_running; s++) {
                sleep(1);
            }
            continue;
        }

        // Determine target percentage for this cycle
        int    active     = !has_window || in_time_window(start_min, end_min);
        double target_pct;

        if (active && max_percent > min_percent) {
            double elapsed = difftime(time(NULL), prog_start);
            target_pct = compute_target(min_percent, max_percent, elapsed, g_baseline_ema);
        } else {
            // Idle period: hold at the effective floor (max of min_percent and EMA baseline).
            target_pct = (g_baseline_ema + 1.0 > min_percent) ? g_baseline_ema + 1.0 : min_percent;
            if (target_pct > max_percent) target_pct = max_percent;
        }

        // Closed-loop calculation: how many chunks should we hold?
        //
        //   target_own = target_pct% * total - others_used
        long target_kb     = (long)(mi.total_kb * target_pct / 100.0);
        long target_own_kb = target_kb - others_used_kb;
        if (target_own_kb < 0) {
            target_own_kb = 0;
        }

        long chunk_kb      = (long)(CHUNK_SIZE >> 10);
        long target_chunks = (target_own_kb + chunk_kb / 2) / chunk_kb;
        long diff          = target_chunks - (long)g_nchunks;

        // Log and adjust
        get_time_str(time_buf, sizeof(time_buf));
        if (g_baseline_ema > min_percent) {
            fprintf(stdout, "%s system=%.1f%%  target=%.1f%%  self=%lu MB  baseline(EMA)=%.1f%%  %s  ",
                    time_buf, used_pct, target_pct,
                    (unsigned long)g_nchunks * (CHUNK_SIZE >> 20),
                    g_baseline_ema,
                    active ? "active" : "idle");
        } else {
            fprintf(stdout, "%s system=%.1f%%  target=%.1f%%  self=%lu MB  %s  ",
                    time_buf, used_pct, target_pct,
                    (unsigned long)g_nchunks * (CHUNK_SIZE >> 20),
                    active ? "active" : "idle");
        }

        if (diff > 0) {
            int n = (int)((diff < MAX_ADJUST_PER_CYCLE) ? diff : MAX_ADJUST_PER_CYCLE);
            fprintf(stdout, "-> +%d chunk(s) (+%d MB)\n",
                    n, n * (int)(CHUNK_SIZE >> 20));
            fflush(stdout);
            for (int k = 0; k < n && g_running; k++) {
                if (chunk_add() != 0) {
                    fprintf(stderr, "mmap failed: %s\n", strerror(errno));
                    break;
                }
            }
        } else if (diff < 0) {
            int n = (int)((-diff < MAX_ADJUST_PER_CYCLE) ? -diff : MAX_ADJUST_PER_CYCLE);
            fprintf(stdout, "-> -%d chunk(s) (-%d MB)\n",
                    n, n * (int)(CHUNK_SIZE >> 20));
            fflush(stdout);
            for (int k = 0; k < n; k++) {
                chunk_remove();
            }
        } else {
            fprintf(stdout, "-> hold\n");
            fflush(stdout);
        }

        // Sleep a random interval to avoid a predictable heartbeat signature
        int sleep_sec = rand_int_range(LOOP_SEC_MIN, LOOP_SEC_MAX);
        for (int s = 0; s < sleep_sec && g_running; s++) {
            sleep(1);
        }
    }

    // Graceful shutdown
    get_time_str(time_buf, sizeof(time_buf));
    fprintf(stdout, "\n%s Shutting down, releasing %d chunk(s)...\n",
            time_buf, g_nchunks);
    fflush(stdout);

    chunks_free_all();
    free(g_chunks);

    fprintf(stdout, "Done.\n");
    return EXIT_SUCCESS;
}
