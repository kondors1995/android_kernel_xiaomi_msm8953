#!/bin/bash

## Pipefail
set -o pipefail

## Parse options

# set defaults
wd=$(pwd)
tc="$HOME/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
mod=""
out=$wd/out
fresh="true"
boot=$out/arch/arm64/boot/
jc="j$(grep -c ^processor /proc/cpuinfo)"
user="THHT"
host="butterbeer"
log=""
ct="aarch64-linux-gnu-"
cc="$HOME/linux-x86/clang-r328903/bin/clang"

# read the options
TEMP=`getopt -o w:t:m:o:f:b:j:u:h:l:t:c --long workdir:,toolchain:,modifier:,out:,fresh:,boot:,jobcount:,user:,host:,log:,clang_triple:,clang_compile: -- "$@"`
eval set -- "$TEMP"

# extract options and their arguments into variables.
while true ; do
    case "$1" in
        -w|--workdir)
            wd=$2 ; shift 2 ;;
        -t|--toolchain)
            tc=$2 ; shift 2 ;;
        -m|modifier)
            mod=$2 ; shift 2 ;;
        -o|--out)
        	out=$2 ; shift 2 ;;
		-f|--fresh)
			fresh=$2 ; shift 2 ;;
		-b|--boot)
			boot=$2 ; shift 2 ;;
		-j|--jobcount)
			jc=$2 ; shift 2 ;;
        -l|--log)
            log=$2 ; shift 2 ;;
        -u|--user)
            user=$2 ; shift 2 ;;
        -h|--host)
            host=$2 ; shift 2 ;;
        -t|--clang_triple)
            ct=$2 ; shift 2 ;;
        -c|clang_compile)
            cc=$2 ; shift 2 ;;
		--) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

# print set options
echo
echo "Configured options
workdir = $wd 
toolchain = $tc 
modifier = $mod 
out = $out 
fresh = $fresh 
boot = $boot 
jobcount = $jc 
user = $user
host = $host
log = $log
clang-triple = $ct
clang_compile = $cc "
echo

## Set user and host
export KBUILD_BUILD_USER=$user
export KBUILD_BUILD_HOST=$host

## Start building

# clean out previous log
rm -rf $log

# clean out directory
if [ $fresh = "true" ]; then
	echo "Cleaning up"
	make clean O=$out
	make mrproper O=$out
    echo
fi

# compile
echo "Preparing kernel config"
make O=out ARCH=arm64 mido_defconfig |& tee -a $log
status=$?
if [ $status != 0 ]; then
	echo "You don't have a valid config for your device, code $status"
    exit $status
fi
echo
echo "Compiling Kernel and making zip"
echo
if [ "$mod" = "clang" ]; then
    make -$jc ARCH=arm64 O=$out CROSS_COMPILE=$tc CC=$cc CLANG_TRIPLE=$ct |& tee -a $log
else
    make -$jc ARCH=arm64 O=$out CROSS_COMPILE=$tc |& tee -a $log
fi
status=$?
if [ $status != 0 ]; then
	echo "Building interrupted, code $status"
	exit $status
else
    # make zip
    echo
    echo "Making Flashable Zip"
    image=$boot/Image.gz-dtb
    suffix=$(date +%Y%m%d-%H%M%S)
    srelease=$wd/spectrum
    nsrelease=$wd/nospectrum
    rm -f $srelease/*.zip $nsrelease/*.zip
    rm -f $nsrelease/zImage $nsrelease/zImage
    cp $image $srelease
    cp $image $nsrelease
#    cd $srelease
#    zip -r9 NinthHorcrux-Spectrum-$suffix.zip *
    cd $nsrelease
    zip -r9 NinthHorcrux-NoSpcectrum-$suffix.zip *
    cd $wd
    echo "Flashable zip made"
    echo
fi
