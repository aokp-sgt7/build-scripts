#!/bin/bash
# --------------------------------------- ------ ---- -- -
# build script by eaut/cdesai of SGT7 ICS TE4M
# modified for AOKP by stimpz0r
# --------------------------------------- ------ ---- -- -
#
# $VARIANT is hardset to userdebug for now, unless something changes for AOKP this will stay like that. 

echo "-------------------------------------- --- -- -"
echo ":: AOKP ICS for SGT7 GSM - build by stimpz0r ::"
echo "- -- --- --------------------------------------"
echo

# default
DEVICE=p1
# alternatives
for i in p1 p1c p1l p1n; do
  [ "$1" == "$i" ] && DEVICE="$i"
done

# default
VARIANT=userdebug
# alternatives
#for i in user userdebug eng; do
#  [ "$2" == "$i" ] && VARIANT="$i"
#done

# VARIANT 	use
# user 		limited access; suited for production
# userdebug 	like "user" but with root access and debuggability; preferred for debugging
# eng		development configuration with additional debugging tools
#

# --------------------------------------------

# default
TARGET="aokp_$DEVICE-$VARIANT"

# exceptions
case "$DEVICE" in
  p1l|p1n)
      TARGET="aokp_p1-$VARIANT"
      OTHER="TARGET_KERNEL_CONFIG=cyanogenmod_"$DEVICE"_defconfig"
esac

# --------------------------------------------

THREADS=$(grep processor /proc/cpuinfo | wc -l)

case "$1" in

  distclean)
      repo forall -c 'git clean -xdf'
      ;&
  clean)
      make clobber
      ( cd kernel/samsung/p1  ; make mrproper )
      ( cd kernel/samsung/p1c ; make mrproper )
      ;;
  $DEVICE|"")
      echo "(*) device  :: $DEVICE"
      echo "(*) variant :: $VARIANT"
      echo "(*) threads :: $THREADS"
      time {
        source build/envsetup.sh
        lunch "$TARGET"
        make -j$THREADS bacon $OTHER
      }
      ;;
  *)
      echo
      echo "(!) usage ::" 
      echo "       ${0##*/} [ <action> ]"
      echo "       ${0##*/} [ <device> ]"
      echo
      echo "  <action> : clean|distclean|help"
      echo "  <device> : p1|p1c|p1l|p1n       default=$DEVICE"
#     echo "  <variant>: user|userdebug|eng   default=$VARIANT"
      ;;
esac
