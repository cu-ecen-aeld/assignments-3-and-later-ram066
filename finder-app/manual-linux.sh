#!/bin/bash
set -e
set -u

##################################
# Paths and config
##################################
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

OUTDIR=${1:-/tmp/aeld}
ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu-

KERNEL_REPO=https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1

SYSROOT=/usr/aarch64-linux-gnu

mkdir -p "${OUTDIR}"

##################################
# Kernel build
##################################
cd "${OUTDIR}"

if [ ! -d linux-stable ]; then
    git clone --depth 1 --branch ${KERNEL_VERSION} ${KERNEL_REPO} linux-stable
fi

cd linux-stable
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
make -j$(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}

cp arch/arm64/boot/Image "${OUTDIR}/Image"

##################################
# BusyBox build
##################################
cd "${OUTDIR}"

if [ ! -d busybox ]; then
    git clone git://busybox.net/busybox.git
fi

cd busybox
git checkout ${BUSYBOX_VERSION}

make distclean
make defconfig
make -j$(nproc) ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} CONFIG_PREFIX="${OUTDIR}/rootfs" install

##################################
# Root filesystem
##################################
cd "${OUTDIR}/rootfs"

mkdir -p dev proc sys etc home lib lib/aarch64-linux-gnu

sudo mknod -m 666 dev/null c 1 3 || true
sudo mknod -m 600 dev/console c 5 1 || true

##################################
# Copy ARM64 shared libraries
##################################
cp ${SYSROOT}/lib/ld-linux-aarch64.so.1 lib/
cp ${SYSROOT}/lib/libc.so.6 lib/aarch64-linux-gnu/
cp ${SYSROOT}/lib/libm.so.6 lib/aarch64-linux-gnu/
cp ${SYSROOT}/lib/libresolv.so.2 lib/aarch64-linux-gnu/

##################################
# Build writer (STATIC)
##################################
${CROSS_COMPILE}gcc -static \
    -o "${OUTDIR}/rootfs/home/writer" \
    "${SCRIPT_DIR}/writer.c"

##################################
# Copy finder app files
##################################
cp "${SCRIPT_DIR}/finder.sh" home/
cp "${SCRIPT_DIR}/finder-test.sh" home/
cp "${SCRIPT_DIR}/autorun-qemu.sh" home/
cp "${SCRIPT_DIR}/conf/assignment.txt" home/
cp "${SCRIPT_DIR}/conf/username.txt" home/

chmod +x home/*.sh home/writer

##################################
# Create init
##################################
cat << 'EOF' > "${OUTDIR}/rootfs/init"
#!/bin/sh

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

echo "Init started, running autorun..."

exec /home/autorun-qemu.sh
EOF

chmod +x "${OUTDIR}/rootfs/init"

##################################
# Ownership
##################################
sudo chown -R root:root "${OUTDIR}/rootfs"

##################################
# Initramfs
##################################
cd "${OUTDIR}/rootfs"
find . | cpio -H newc -ov --owner root:root > "${OUTDIR}/initramfs.cpio"
gzip -f "${OUTDIR}/initramfs.cpio"

echo "manual-linux.sh completed successfully"

