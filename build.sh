#!/bin/bash
#
# Script to build AOKP for Galaxy Tab (with Kernel)
# 2012 Chirayu Desai
# modified by stimpz0r for use with AOKP

# Common defines
txtrst='\e[0m'    # Color off
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue

echo -e "${txtblu}-------------------------------------- --- -- -"
echo -e "${txtblu}:: AOKP ICS for SGT7 GSM - build by stimpz0r ::"
echo -e "${txtblu}- -- --- --------------------------------------"
echo -e "\r\n ${txtrst}"

DEVICE=$1
BUILDTYPE="$2"
THREADS=`cat /proc/cpuinfo | grep processor | wc -l`

case $DEVICE in
	clean)
		make clobber && make installclean && make clean
		cd kernel/samsung/p1
		./build.sh clean
		exit
		;;
	p1|P1)
		P1_TARGET=p1
		;;
	p1l|P1L)
		P1_TARGET=p1l
		;;
	p1n|P1N)
		P1_TARGET=p1n
		;;
	*)
		echo -e "${txtred}(!!) ERROR: choose a device"
		echo -e "default : p1"
		echo -e "supported buildtypes : p1 p1l p1n${txtrst}"
		;;
esac

case "$BUILDTYPE" in
	clean)
		make clobber && make installclean && make clean
		cd kernel/samsung/p1
		./build.sh clean
		exit
		;;
#
# -- disabling eng and user builds for now, left here incase they get used. - stimpz0r
#  
#	eng)
#		LUNCH=aokp_galaxytab-eng
#		;;
	userdebug)
		LUNCH=aokp_galaxytab-userdebug
		;;
#	user)
#		LUNCH=aokp_galaxytab-user
#		;;
	*)
		echo -e "${txtred}(!!) ERROR: choose a build type"
		echo -e "default : userdebug"
		echo -e "supported buildtypes: userdebug${txtrst}"
		;;
esac

if [ "$1" = "" ] ; then
P1_TARGET=p1
fi

if [ "$2" = "" ] ; then
LUNCH=aokp_galaxytab-userdebug
fi

START=$(date +%s)

# Setup build environment and start the build
echo -e "${txtblu}(::) building AOKP for SGT7 ..."
echo -e "\r\n ${txtrst}"

. build/envsetup.sh
lunch $LUNCH

# Kernel build
cd kernel/samsung/p1
./build.sh
cd ../../..

# Android build
make -j$THREADS bacon

END=$(date +%s)
ELAPSED=$((END - START))
E_MIN=$((ELAPSED / 60))
E_SEC=$((ELAPSED - E_MIN * 60))
printf "(::) elapsed: "
[ $E_MIN != 0 ] && printf "%d min(s) " $E_MIN
printf "%d sec(s)\n" $E_SEC
