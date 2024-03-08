#!/bin/bash

OS_NAME="KayraCore"
PROJECT_DIR=/home/akinozgen/src/quartlinux

init() {
    # Check for required directories. Create if not exists.
    if [ ! -d "$PROJECT_DIR/workdir" ]; then
        mkdir -p $PROJECT_DIR/workdir
    fi

    if [ ! -d "$PROJECT_DIR/workdir/boot-files" ]; then
        mkdir -p $PROJECT_DIR/workdir/boot-files
    fi

    if [ ! -d "$PROJECT_DIR/workdir/chroot" ]; then
        mkdir -p $PROJECT_DIR/workdir/chroot
    fi

    if [ ! -d "$PROJECT_DIR/workdir/initramfs" ]; then
        mkdir -p $PROJECT_DIR/workdir/initramfs
    fi

    if [ ! -d "$PROJECT_DIR/workdir/linux" ]; then
        mkdir -p $PROJECT_DIR/workdir/linux
    fi

    if [ ! -d "$PROJECT_DIR/workdir/busybox" ]; then
        mkdir -p $PROJECT_DIR/workdir/busybox
    fi
    
}

init();

linux_config() {
    echo "Configuring linux kernel for $OS_NAME..."
    cd $PROJECT_DIR/workdir/linux
    make defconfig
    make menuconfig
}

busybox_config() {
    echo "Configuring busybox for $OS_NAME..."
    cd $PROJECT_DIR/workdir/busybox
    make defconfig
    make menuconfig
}

build_kernel() {
    echo "Compiling linux kernel for $OS_NAME..."
    cd $PROJECT_DIR/workdir/linux
    make -j8

    cp $PROJECT_DIR/workdir/linux/arch/x86/boot/bzImage $PROJECT_DIR/workdir/boot-files/$OS_NAME.kernel
}

build_initramfs() {
  cd $PROJECT_DIR/workdir/busybox 
  rm $PROJECT_DIR/workdir/boot-files/$OS_NAME.cpio -f

  rm -rf $PROJECT_DIR/workdir/boot-files/initramfs/bin \
      $PROJECT_DIR/workdir/boot-files/initramfs/sbin \
      $PROJECT_DIR/workdir/boot-files/initramfs/usr
  
  echo "Creating initramfs..."
  
  make -j8
  make CONFIG_PREFIX=$PROJECT_DIR/workdir/boot-files/initramfs install
  rm -f $PROJECT_DIR/workdir/boot-files/initramfs/linuxrc

  echo "Creating initramfs image..."
  cd $PROJECT_DIR/workdir/boot-files/initramfs && find . | cpio -H newc -o > $PROJECT_DIR/workdir/boot-files/$OS_NAME.cpio
}

compile() {
    echo "Creating bootable image..."
    rm $PROJECT_DIR/workdir/boot-files/$OS_NAME.img -f
    dd if=/dev/zero of=$PROJECT_DIR/workdir/boot-files/$OS_NAME.img bs=1M count=128
    mkfs.fat $PROJECT_DIR/workdir/boot-files/$OS_NAME.img
    mkdir -p $PROJECT_DIR/workdir/boot-files/chroot

    syslinux $PROJECT_DIR/workdir/boot-files/$OS_NAME.img

    sudo mount $PROJECT_DIR/workdir/boot-files/$OS_NAME.img $PROJECT_DIR/workdir/boot-files/chroot

    sudo cp -r $PROJECT_DIR/workdir/boot-files/$OS_NAME.cpio $PROJECT_DIR/workdir/boot-files/chroot
    sudo cp $PROJECT_DIR/workdir/boot-files/$OS_NAME.kernel $PROJECT_DIR/workdir/boot-files/chroot
    sudo cp  $PROJECT_DIR/workdir/boot-files/syslinux.cfg $PROJECT_DIR/workdir/boot-files/chroot/syslinux.cfg

    sudo umount $PROJECT_DIR/workdir/boot-files/chroot
    echo "Done."
}

boot() {
    echo "Booting $OS_NAME..."
    qemu-system-x86_64 $PROJECT_DIR/workdir/boot-files/$OS_NAME.img
}

cleanup() {
    echo "Cleaning up..."
    rm $PROJECT_DIR/workdir/boot-files/$OS_NAME.img -f
    rm $PROJECT_DIR/workdir/boot-files/$OS_NAME.cpio -f
    cd $PROJECT_DIR/workdir/linux && make clean
    cd $PROJECT_DIR/workdir/busybox && make clean
    echo "Done."
}

# Parse command line argument
case "$1" in
    linux_config)
        linux_config
        ;;
    
    busybox_config)
        busybox_config
        ;;
    
    build_initramfs)
        build_initramfs
        ;;
    
    build_kernel)
        build_kernel
        ;;
    compile)
        compile
        ;;
    boot)
        boot
        ;;
    cleanup)
        cleanup
        ;;
    *)
        echo "Usage: $0 {build_kernel|compile|boot|cleanup}"
        exit 1
        ;;
esac