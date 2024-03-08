## KayraCore 

KayraCore is a simple side project of mine to create a linux distro from scratch. It uses busybox as the root filesystem and the linux kernel as the kernel. 


Creates a syslinux bootable image file named `boot.img` in workdir/boot-files. `boot.img` is 128M in size and can be booted with qemu-system-x86_64. It includes KayraCore.kernel as linux kernel and KayraCore.cpio as the root filesystem. Also it has a syslinux config file to automatically boot the OS.

Be sure to change `build.sh` to your needs. It has `OS_NAME` and `PROJECT_DIR` variables that you should change to your needs. Also it uses `qemu-system-x86_64` to boot the generated image. Change the `qemu` command to your needs.
It is configured to use 8 threads for building the kernel and busybox.

### Building
Clone the linux kernel at workdir/linux and busybox at workdir/busybox. Then use the build.sh script for the tasks.

### Tasks
- `build.sh linux_config` - Configure the linux kernel with menuconfig.
- `build.sh busybox_config` - Configure busybox with menuconfig.
- `build.sh build_kernel` - Build the linux kernel.
- `build.sh build_initramfs` - Build the initramfs.
- `build.sh compile` - Store the kernel and initramfs into boot.img.
- `build.sh boot` - Boot the generated image with qemu-system-x86_64.
- `build.sh cleanup` - Clean generated images and kernel also clean the kernel and busybox build directories.