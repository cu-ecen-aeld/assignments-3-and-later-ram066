#!/bin/bash
set -e
set -u

OUTDIR=${1:-/tmp/aeld}
ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu-
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1

mkdir -p "$OUTDIR"

# Kernel
cd "$OUTDIR"
if [ ! -d linux-stable ]; then
    echo "Cloning Linux kernel..."
    git clone --depth 1 --branch $KERNEL_VERSION $KERNEL_REPO
fi

cd linux-stable
make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE defconfig
make -j$(nproc) ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE

# BusyBox
cd "$OUTDIR"
if [ ! -d busybox ]; then
    git clone git://busybox.net/busybox.git
    cd busybox
    git checkout $BUSYBOX_VERSION
else
    cd busybox
fi

make distclean
make defconfig
make -j$(nproc) ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE
make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE CONFIG_PREFIX="$OUTDIR/rootfs" install

# Root filesystem
cd "$OUTDIR/rootfs"
mkdir -p dev proc sys etc home
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1

# Check library dependencies
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

echo "manual-linux.sh completed successfully"

