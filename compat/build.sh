#!/bin/bash
# Rebuilds recovery/root/system/lib64/libags2_compat.so (see ags2_compat.c). Needs the LineageOS 16 prebuilts (clang 6 + aarch64 binutils).
set -e
P=${LOS16:-/home/tobim6/AGS2_LOS16/lineage-16.0}/prebuilts
C=$(ls -d $P/clang/host/linux-x86/clang-*/bin/clang | tail -1)
B=$P/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android
cd "$(dirname "$0")"
$C --target=aarch64-linux-android -c -fPIC -O2 -fno-stack-protector ags2_compat.c -o /tmp/ags2_compat.o
$B-ld -shared -soname libags2_compat.so -o ../recovery/root/system/lib64/libags2_compat.so /tmp/ags2_compat.o
