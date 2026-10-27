#!/bin/bash
# usage: pack_recovery_ramdisk.sh <ramdisk-recovery.img> <known-good recovery_ramdisk dump (mmcblk0p32)> <out.img>
# Builds a kernel-less Android boot image (the layout the bootloader accepts for recovery_ramdisk) with the new ramdisk,
# copying every header field except the sizes from the known-good dump.
set -e
RD=$1; OLD=$2; OUT=$3
MK=${MKBOOTIMG:-out/host/linux-x86/bin/mkbootimg}
: > /tmp/empty_kernel_$$
python3 $MK --kernel /tmp/empty_kernel_$$ --ramdisk "$RD" --cmdline "buildvariant=eng" --base 0x10000000 --pagesize 2048 \
  --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --second_offset 0x00f00000 --tags_offset 0x00000100 \
  --os_version 9.0.0 --os_patch_level 2019-10 --header_version 0 --output "$OUT"
python3 - "$OUT" "$OLD" <<'PY'
import struct,hashlib,sys
F,OLD=sys.argv[1:3]; d=bytearray(open(F,'rb').read())
ks,ka,rs,ra,ss,sa,ta,ps,hv,osv=struct.unpack('<10I',bytes(d[8:48])); pad=lambda n:(n+ps-1)//ps*ps
k=bytes(d[ps:ps+ks]); r=bytes(d[ps+pad(ks):ps+pad(ks)+rs]); s=bytes(d[ps+pad(ks)+pad(rs):ps+pad(ks)+pad(rs)+ss])
d[28:32]=open(OLD,'rb').read(2048)[28:32]
h=hashlib.sha1()
for blob,n in ((k,ks),(r,rs),(s,ss)): h.update(blob); h.update(struct.pack('<I',n))
d[576:596]=h.digest(); open(F,'wb').write(bytes(d))
PY
rm -f /tmp/empty_kernel_$$
