#!/bin/bash

BASEDIR="/home/diego-ch/Android/i9070"
OUTDIR="$BASEDIR/out"
INITRAMFSDIR="$BASEDIR/ramdisk"
STOCKMODULESDIR="$BASEDIR/stockmodules"
TOOLCHAIN="/home/diego-ch/Android/toolchains/arm-eabi-4.4.3/bin/arm-eabi-"

STARTTIME=$SECONDS

cd kernel
case "$1" in
	clean)
		echo -e "\n\n Cleaning Kernel Sources...\n\n"
		make mrproper ARCH=arm CROSS_COMPILE=$TOOLCHAIN
		rm -rf ${INITRAMFSDIR}/lib
		rm -rf ${OUTDIR}
		ENDTIME=$SECONDS
		echo -e "\n\n Finished in $((ENDTIME-STARTTIME)) Seconds\n\n"
		;;
	*)
		echo -e "\n\n Configuring I9070 Kernel...\n\n"
		make cyanogenmod_janice_defconfig ARCH=arm CROSS_COMPILE=$TOOLCHAIN

		echo -e "\n\n Compiling I9070 Kernel and Modules... \n\n"
		make -j9 ARCH=arm CROSS_COMPILE=$TOOLCHAIN CONFIG_INITRAMFS_SOURCE=$INITRAMFSDIR

		echo -e "\n\n Copying Modules to InitRamFS Folder...\n\n"
		mkdir -p $INITRAMFSDIR/lib/modules/2.6.35.7
		mkdir -p $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/bluetooth/bthid
		mkdir -p $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/net/wireless/bcm4330
		mkdir -p $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/samsung/j4fs
		mkdir -p $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/samsung/param
		mkdir -p $INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/scsi

		cp drivers/bluetooth/bthid/bthid.ko	$INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/bluetooth/bthid/bthid.ko
		cp drivers/net/wireless/bcm4330/dhd.ko	$INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/net/wireless/bcm4330/dhd.ko
		cp drivers/samsung/param/param.ko	$INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/samsung/param/param.ko
		cp drivers/scsi/scsi_wait_scan.ko	$INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/scsi/scsi_wait_scan.ko
#		cp drivers/samsung/j4fs/j4fs.ko		$INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/samsung/j4fs/j4fs.ko

		cp $STOCKMODULESDIR/j4fs.ko		$INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/samsung/j4fs/j4fs.ko
#		cp $STOCKMODULESDIR/bthid.ko		$INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/bluetooth/bthid/bthid.ko
#		cp $STOCKMODULESDIR/dhd.ko		$INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/net/wireless/bcm4330/dhd.ko
#		cp $STOCKMODULESDIR/param.ko		$INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/samsung/param/param.ko
#		cp $STOCKMODULESDIR/scsi_wait_scan.ko	$INITRAMFSDIR/lib/modules/2.6.35.7/kernel/drivers/scsi/scsi_wait_scan.ko

		echo -e "\n\n Creating zImage...\n\n"
		make ARCH=arm CROSS_COMPILE=$TOOLCHAIN CONFIG_INITRAMFS_SOURCE=$INITRAMFSDIR zImage

		mkdir -p ${OUTDIR}
		cp arch/arm/boot/zImage ${OUTDIR}/kernel.bin

		echo -e "\n\n Generating Odin Flasheable Kernel...\n\n"
		pushd ${OUTDIR}
		md5sum -t kernel.bin >> kernel.bin
		mv kernel.bin kernel.bin.md5
		tar cf GT-I9070_Kernel_DroidAdvance+.tar kernel.bin.md5
		md5sum -t GT-I9070_Kernel_DroidAdvance+.tar >> GT-I9070_Kernel_DroidAdvance+.tar
		mv GT-I9070_Kernel_DroidAdvance+.tar GT-I9070_Kernel_DroidAdvance+.tar.md5
		popd

                ENDTIME=$SECONDS
                echo -e "\n\n = Finished in $((ENDTIME-STARTTIME)) Seconds =\n\n"
		;;
esac
