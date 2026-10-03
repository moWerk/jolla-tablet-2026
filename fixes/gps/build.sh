#!/bin/bash
# SPDX-FileCopyrightText: 2026 moWerk <mo@mowerk.net>
# SPDX-License-Identifier: GPL-2.0-or-later
#
# Builds libgeoclue-boottime.so for the Jolla Tablet on any x86 computer.
# No 32-bit libc is needed: the shim is freestanding.
set -e
cd "$(dirname "$0")"
gcc -m32 -march=i686 -O2 -shared -fPIC -nostdlib -ffreestanding \
    -fno-stack-protector -fno-asynchronous-unwind-tables -fcf-protection=none \
    -Wall -Wextra -Wl,-soname,libgeoclue-boottime.so -Wl,--hash-style=both \
    -Wl,-z,noexecstack \
    -o libgeoclue-boottime.so geoclue-boottime.c
echo "built: $(file -b libgeoclue-boottime.so | cut -c1-70)"
echo "needs from the host process:"; nm -D --undefined-only libgeoclue-boottime.so
echo "exports:"; nm -D --defined-only libgeoclue-boottime.so
echo "DT_NEEDED: $(readelf -d libgeoclue-boottime.so | grep -c NEEDED)"
