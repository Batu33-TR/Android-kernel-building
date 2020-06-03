##############################################
#   SebaUbuntu custom kernel build script    #
##############################################

# Set defaults directory's
ROOT_DIR=$(pwd)
OUT_DIR=$ROOT_DIR/out
# ANYKERNEL_DIR=$ROOT_DIR/anykernel3
KERNEL_DIR=$ROOT_DIR
DATE=$(date +"%m-%d-%y")
BUILD_START=$(date +"%s")

# Export ARCH and SUBARCH <arm, arm64, x86, x86_64>
export ARCH=arm64
export SUBARCH=arm64

# Set kernel name and defconfig
export VERSION=MedusaKernel-VersionNumber-VersionName
export DEFCONFIG=j4plus_kali_defconfig

# Keep it as is
export LOCALVERSION=-$VERSION

# Export Username and machine name
export KBUILD_BUILD_USER=Batuu
export KBUILD_BUILD_HOST=Manjaro

# Color definition
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`
reset=`tput sgr0`

# Cross-compiler exporting
if [ $ARCH = arm ]
	then
		# Export ARM from the given directory
		export CROSS_COMPILE=${ROOT_DIR}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
elif [ $ARCH = arm64 ]
	then
		# Export ARM64 and ARM cross-compliers from the given directory
		export CROSS_COMPILE=${ROOT_DIR}/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
		export CROSS_COMPILE_ARM32=${ROOT_DIR}/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
elif [ $ARCH = x86 ]
	then
		# Export x86 cross-compliers from the given directory
		export CROSS_COMPILE=${ROOT_DIR}/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/bin/x86_64-linux-android-
elif [ $ARCH = x86_64 ]
	then
		# Export x86 and x86_64 cross-compliers from the given directory
		export CROSS_COMPILE=${ROOT_DIR}/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/bin/x86_64-linux-android-
		export CROSS_COMPILE_X86=${ROOT_DIR}/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/bin/x86_64-linux-android-
else
	echo "$red Error: Arch not compatible $reset"
	exit
fi

echo -e "*****************************************************"
echo    "            Compiling kernel using GCC               "
echo -e "*****************************************************"
echo -e "-----------------------------------------------------"
echo    " Architecture: $ARCH                                 "
echo    " Output directory: $OUT_DIR                          "
echo    " Kernel version: $VERSION                            "
echo    " Build user: $KBUILD_BUILD_USER                      "
echo    " Build machine: $KBUILD_BUILD_HOST                   "
echo    " Build started on: $BUILD_START                      "
echo    " Toolchain: GCC 4.9                                  "
echo -e "-----------------------------------------------------"

# Set kernel source workspace
cd $KERNEL_DIR

# Clean build
make O=$OUT_DIR clean
CLEAN_SUCCESS=$?
if [ $CLEAN_SUCCESS != 0 ]
	then
		echo "$red Error: make clean failed"
		exit
fi

make O=$OUT_DIR mrproper
MRPROPER_SUCCESS=$?
if [ $MRPROPER_SUCCESS != 0 ]
	then
		echo "$red Error: make mrproper failed"
		exit
fi 

# Make your device device_defconfig
make O=$OUT_DIR ARCH=$ARCH $DEFCONFIG
DEFCONFIG_SUCCESS=$?
if [ $DEFCONFIG_SUCCESS != 0 ]
	then
		echo "$red Error: make $DEFCONFIG failed, specified a defconfig not present? $reset"
		exit
fi

# Build Kernel
make O=$OUT_DIR ARCH=$ARCH -j$(nproc --all)

# Find how much build has been long
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))

BUILD_SUCCESS=$?
if [ $BUILD_SUCCESS != 0 ]
	then
		echo "$red Error: Build failed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds $reset"
		exit
fi

# # Possible kernel filenames
# APPENDED_DTB_KERNEL="zImage-dtb Image.gz-dtb Image.bz2-dtb Image.lzo-dtb Image.lzma-dtb Image.xz-dtb Image.lz4-dtb Image-dtb"
# NOT_APPENDED_DTB_KERNEL="zImage Image.gz Image.bz2 Image.lzo Image.lzma Image.xz Image.lz4 Image.fit Image"
# KERNEL_DTB="dt dt.img dtb dtb.img"
# 
# cd "$ROOT_DIR"
# 
# 

echo -e "$green Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds $reset"
exit

# echo -e "Making flashable zip using anykernel3"
# 
# # remove all zips and old kernels
# rm "$ANYKERNEL_DIR/*.zip"
# for i in "$APPENDED_DTB_KERNEL $NOT_APPENDED_DTB_KERNEL $KERNEL_DTB"
# 	do
# 		if [ -f "$ANYKERNEL_DIR/$i" ]
# 			then
# 				rm -f "$ANYKERNEL_DIR/$i"
# 		fi
# done
# 
# # First of all see if kernel with appended dtb exists and copy it
# for i in "$APPENDED_DTB_KERNEL"
# 	do
# 		if [ -f "$OUT_DIR/arch/$ARCH/boot/$i" ]
# 			then
# 				cp "$OUT_DIR/arch/$ARCH/boot/$i" "$ANYKERNEL_DIR/$i"
# 				KERNEL_HAVE_APPENDED_DTB=true
# 		fi
# 		[ $KERNEL_HAVE_APPENDED_DTB ] && break
# done
# 
# # If kernel with appended dtbs doesn't exists, copy kernel w/o appended dtb and dtb image
# if [ "$KERNEL_HAVE_APPENDED_DTB" != true ]
# 	then
# 		for i in $NOT_APPENDED_DTB_KERNEL
# 			do
# 				if [ -f "$OUT_DIR/arch/$ARCH/boot/$i" ]
# 					then
# 						cp "$OUT_DIR/arch/$ARCH/boot/$i" "$ANYKERNEL_DIR/$i"
# 						KERNEL_HAVE_APPENDED_DTB=false
# 				fi
# 				[ $KERNEL_HAVE_APPENDED_DTB = false ] && break
# 		done
# 		for i in $KERNEL_DTB
# 			do
# 				if [ -f "$OUT_DIR/arch/$ARCH/boot/$i" ]
# 					then
# 						cp "$OUT_DIR/arch/$ARCH/boot/$i" "$ANYKERNEL_DIR/$i"
# 				fi
# 		done
# fi
# 
# # Change the directory to anykernel3 directory
# cd $ANYKERNEL_DIR
# 	
# # Build a flashable zip Device using anykernel2
# zip -r9 $VERSION-$DATE.zip $ANYKERNEL_DIR/* -x $ANYKERNEL_DIR/README $ANYKERNEL_DIR/$VERSION-$DATE.zip
# 
# # Exported variables cleanup
# for i in ARCH SUBARCH LOCALVERSION KBUILD_BUILD_USER KBUILD_BUILD_HOST DEFCONFIG CROSS_COMPILE CROSS_COMPILE_ARM32 CROSS_COMPILE_X86
# 	do
# 		unset $i
# done
# 