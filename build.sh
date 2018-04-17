#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image"
DTBIMAGE="dtb"
export CROSS_COMPILE=~/Android/kernel/tc/linaro/gcc-7.x/bin/aarch64-opt-linux-android-

DEFCONFIG="revolt_defconfig"

# Kernel Details
VER=".R27.TNT"

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR=~/Android/kernel/AnyKernel2"
PATCH_DIR=~/Android/kernel/AnyKernel2/patch"
MODULES_DIR=~/Android/kernel/AnyKernel2/modules"
ZIP_MOVE=~/Android/kernel/AK-releases"
ZIMAGE_DIR=~/Android/kernel/mido/arch/arm64/boot

# Functions
function clean_all {
		cd ~/Android/kernel/AnyKernel2
		git reset --hard && git clean -f -d
		cd $KERNEL_DIR
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD

}

function make_zip {
		cd ~/Android/kernel/AnyKernel2
		cp ~/Android/kernel/EAS/arch/arm64/boot/Image.gz-dtb ~/Android/kernel/AnyKernel2
		zip -r9 `echo $AK_VER`.zip *
		cp `echo $AK_VER`.zip ~/Android/kernel/AK-Releses/
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")


echo -e "${green}"
echo "-----------------"
echo "Making REVOLT Kernel:"
echo "-----------------"
echo -e "${restore}"


# Vars
BASE_AK_VER="REVOLT"
AK_VER="$BASE_AK_VER$VER"
export LOCALVERSION=~`echo $AK_VER`
export LOCALVERSION=~`echo $AK_VER`
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=NATO66613
export KBUILD_BUILD_HOST=PENTAGON

echo

while read -p "Do you want to clean stuffs (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Do you want to build?" dchoice
do
case "$dchoice" in
	y|Y )
		make_kernel
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done


echo -e "${green}"
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
