#!/bin/sh

cd /coremark
sed -i 's|EXE = .exe|EXE =|' posix/core_portme.mak
make PORT_CFLAGS="-O3 -s" XCFLAGS="-DMULTITHREAD=$(nproc) -DUSE_PTHREAD -pthread" compile >/dev/null
./coremark
