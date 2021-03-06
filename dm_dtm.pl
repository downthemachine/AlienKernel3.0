#!/usr/bin/perl -W
use strict;
use Cwd;

my $dir = getcwd;

print "\ncleaning kernel source\n";


print "\nremoving old boot.img\n";
system ("rm boot.img");
system ("rm $dir/zpack/zcwmfiles/boot.img");

print "\nremoving old dm_dtm_tst_krnl.zip\n";
system ("rm $dir/dm_dtm_tst_krnl.zip");

print "\ncreating ramdisk from n860 folder\n";
chdir ("$dir/zpack");

 unless (-d "$dir/zpack/n860/data") {
 system ("mkdir n860 | tar -C /$dir/zpack/n860/ -xvf n860.tar");
 }

chdir ("$dir/zpack/n860");
system ("find . | cpio -o -H newc | gzip > $dir/ramdisk-repack.gz");


print "\nbuilding zImage from source\n";
chdir ("$dir");
system ("cp defconfig2 $dir/.config");
system ("make -j8");

print "\ncreating boot.img\n";
chdir $dir or die "/zpack/n860 $!";;
system ("$dir/zpack/mkbootimg --cmdline 'console=ttyMSM1,115200' --kernel $dir/arch/arm/boot/zImage --ramdisk ramdisk-repack.gz -o boot.img --base 0x00200000 --pagesize 4096");

unlink("ramdisk-repack.gz") or die $!;

print "\ncreating flashable zip file\n";
system ("cp boot.img $dir/zpack/zcwmfiles/");
chdir ("$dir/zpack/zcwmfiles");
system ("zip -9 -r $dir/dm_dtm_tst_krnl.zip *");
print "\nceated dm_dtm_tst_krnl.zip\n";

print "\nremoving old dm_dtm_tst_krnl.zip from sdcard\n";
system ("adb shell rm /sdcard/dm_dtm_tst_krnl.zip");

print "\npushing new dm_dtm_tst_krnl.zip to sdcard\n";
system ("adb push $dir/dm_dtm_tst_krnl.zip /sdcard/dm_dtm_tst_krnl.zip");
print "\ndone\n";

