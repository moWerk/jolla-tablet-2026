// SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
// SPDX-License-Identifier: GPL-2.0-or-later

/*
 * geoclue-boottime.c
 *
 * LD_PRELOAD shim for /usr/libexec/geoclue-hybris on the Jolla Tablet
 * (Sailfish OS 4.6, i486, glibc 2.30, Broadcom BCM4752 with glgps).
 *
 * The bug: HybrisProvider::handleNtpResponse() stamps injected NTP time with
 * CLOCK_MONOTONIC, which stops during suspend. Android's inject_time()
 * contract is elapsedRealtime, which does not, and gpsd ages the stamp
 * against that. After any suspend the GPS engine therefore starts wrong by
 * the total time asleep, and glgps aborts: "Initial time estimate was bad".
 *
 * The cure: answer CLOCK_BOOTTIME where the provider asks for
 * CLOCK_MONOTONIC. Only calls made from the main executable are changed.
 * Qt and every other library keep the real CLOCK_MONOTONIC, because their
 * timed waits are measured by the kernel against that clock.
 *
 * Freestanding on purpose: no libc is linked, so it builds on any x86 host
 * with `gcc -m32` and carries no glibc symbol versions. See build.sh.
 */
#define CLOCK_MONOTONIC   1
#define CLOCK_BOOTTIME    7
#define NR_clock_gettime  265          /* i386 */
#define PT_LOAD           1
#define PF_X              1

typedef struct {
    unsigned p_type, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz, p_flags, p_align;
} Phdr;

struct dl_phdr_info {
    unsigned       dlpi_addr;
    const char    *dlpi_name;
    const Phdr    *dlpi_phdr;
    unsigned short dlpi_phnum;
};

/* Both resolved at load time from the libc the process already has. */
extern int  dl_iterate_phdr(int (*)(struct dl_phdr_info *, unsigned, void *), void *);
extern int *__errno_location(void);

static unsigned exe_lo, exe_hi;

/* The first object reported is always the main program. Take its
 * executable segment and stop. */
static int first_object(struct dl_phdr_info *info, unsigned size, void *data)
{
    unsigned i;
    (void)size; (void)data;
    for (i = 0; i < info->dlpi_phnum; i++) {
        const Phdr *p = &info->dlpi_phdr[i];
        if (p->p_type == PT_LOAD && (p->p_flags & PF_X)) {
            exe_lo = info->dlpi_addr + p->p_vaddr;
            exe_hi = exe_lo + p->p_memsz;
        }
    }
    return 1;
}

static long raw_clock_gettime(int id, void *ts)
{
    long r;
    __asm__ volatile ("int $0x80"
                      : "=a"(r)
                      : "a"(NR_clock_gettime), "b"(id), "c"(ts)
                      : "memory");
    return r;
}

int clock_gettime(int id, void *ts)
{
    long r;

    if (id == CLOCK_MONOTONIC) {
        unsigned caller = (unsigned)__builtin_return_address(0);
        if (!exe_hi)
            dl_iterate_phdr(first_object, 0);
        if (caller >= exe_lo && caller < exe_hi)
            id = CLOCK_BOOTTIME;
    }

    r = raw_clock_gettime(id, ts);
    if (r < 0) {
        *__errno_location() = (int)-r;
        return -1;
    }
    return 0;
}
