#!/bin/sh

tar zxf /srv/coremark-d5fad6bd094899101a4e5fd53af7298160ced6ab.tar.gz
cd coremark-d5fad6bd094899101a4e5fd53af7298160ced6ab
sed -i 's|EXE = .exe|EXE =|' posix/core_portme.mak
make PORT_CFLAGS="-O3 -s" XCFLAGS="-DMULTITHREAD=$(nproc) -DUSE_PTHREAD -pthread" compile
./coremark
