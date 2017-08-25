# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=lordarcadius @ xda-developers
do.devicecheck=1
do.modules=1
do.cleanup=1
do.cleanuponabort=0
device.name1=mido
device.name2=redmi note 4
device.name3=Rendi Nude 4
device.name4=Redmi Note 4
device.name5=Redmi Note 4x
} # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel permissions
# set permissions for included ramdisk files
chmod -R 755 $ramdisk

## AnyKernel install
dump_boot;
write_boot;

## end install

