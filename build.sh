#
# Copyright � 2016,  Sultan Qasim Khan <sultanqasim@gmail.com>
# Copyright � 2016,  Zeeshan Hussain <zeeshanhussain12@gmail.com>
# Copyright � 2016,  Varun Chitre  <varun.chitre15@gmail.com>
# Copyright � 2016,  Aman Kumar  <firelord.xda@gmail.com>
# Copyright � 2016,  Kartik Bhalla <kartikbhalla12@gmail.com> 

# Custom build script
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it
#

#!/bin/bash
KERNEL_DIR=~/android/kernel/samsung/smdk5260
KERN_IMG=$KERNEL_DIR/arch/arm/boot/zImage
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=~/android/kernel/toolchain/google-4.8/bin/arm-eabi-
export KBUILD_BUILD_USER="haha"
export KBUILD_BUILD_HOST="FireLord"
rm -f flash_zip/boot.img

compile_kernel ()
{
  echo -e "$cyan***********************************************"
  echo -e "          Initializing defconfig          "
  echo -e "***********************************************$nocol"
  make cyanogenmod-$dev-exynos5260_defconfig
  echo -e "$cyan***********************************************"
  echo -e "             Building kernel          "
  echo -e "***********************************************$nocol"
  make -j12 zImage
  if ! [ -a $KERN_IMG ];
  then
    echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
    exit 1
  fi
}

fire_kernel ()
{
  echo -e "$cyan***********************************************"
  echo "          Compiling FireKernel kernel          "
  echo -e "***********************************************$nocol"
  echo -e " "
  echo -e " SELECT ONE OF THE FOLLOWING TYPES TO BUILD : "
  echo -e " 1.DIRTY"
  echo -e " 2.CLEAN"
  echo -n " YOUR CHOICE : ? "
  read ch
  echo -n " VERSION : ? "
  read ver
  echo -n " OLD VERSION : ? "
  read old
  echo -n " Which device : ? "
  read dev
  echo -n " Which android lp,mm,n : ? "
  read anv

replace $old $ver -- $KERNEL_DIR/arch/arm/configs/cyanogenmod-$dev-exynos5260_defconfig
replace $old $ver -- $KERNEL_DIR/flash_zip/META-INF/com/google/android/updater-script
case $ch in
  1) echo -e "$cyan***********************************************"
     echo -e "          	Dirty          "
     echo -e "***********************************************$nocol"
     compile_kernel ;;
  2) echo -e "$cyan***********************************************"
     echo -e "          	Clean          "
     echo -e "***********************************************$nocol"
     make clean
     make mrproper
     compile_kernel ;;
  *) device ;;
esac
echo -e "$cyan***********************************************"
echo -e " Converting the output into a flashable zip"
echo -e "***********************************************$nocol"
rm -rf firekernel_install
mkdir -p firekernel_install
cp arch/arm/boot/zImage flash_zip/tools/
rm -f ~/android/kernel/upload/$dev/*
cd flash_zip
zip -r ../arch/arm/boot/fire_kernel.zip ./
today=$(date +"-%d%m%Y")
mv ~/android/kernel/samsung/smdk5260/arch/arm/boot/fire_kernel.zip ~/android/kernel/upload/$dev/FireKernel-$anv-$dev-v$ver$today.zip
}

fire_kernel
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
