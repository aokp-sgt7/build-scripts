#!/bin/bash
# --------------------------------------- ------ ---- -- -
# original build script by eaut/cdesai of SGT7 TE4M
# kernel compilation / CWM flashable zip creation by teamhacksung
# modified for AOKP SGT7 by stimpz0r
# --------------------------------------- ------ ---- -- -

echo 
echo "            ,,cSS#"
echo "            ######    ,,ccc,,    ,,cSS#   ,c####SScc,"
echo "    ,ccS########## ,cS#######Sc, ######  ,S###S#########SScc,"
echo "   ;#####*'*######;#####*'*#####;######,cS###*'######*'l#####;"
echo "  ;l####l   ######l#####   #####l#########S*'  ######  ;#####l"
echo "  l#####################   ##############Scc,, ######  ;#####l"
echo "  ######    ############   ############'l###Sc,######c,l#####;"
echo "  ######;   ######l#####   #####l###### ;###############SS**'"
echo "  l#####l   ######;#####c,c#####;######  ############"
echo "  ;######;  '*S### '*S#######S*' ######  ############"
echo "   l#####l            ''***''    ##S**'  ######'*S###"
echo "-- ;S**''  ----------------------------- '**S## ------- --- -"
echo ";;[ . . A O K P - S G T 7 ];;; ,c####*',cS##Sc,*#####*,c###c,"
echo ";;[ ;;;;;;;;; by stimpz0r ];;; ##; ;;; ## ;; ##  ## ;;;;;;'##"
echo ";;[ ;;;;;;;;;;;;;;;;;;;;; ];;;,'*###Sc,*#,,,,##  ## ;;;;;; ##"
echo ";;[ B U I L D S C R I P T ];;;''    ;## '''''##  ## ;;;;;; ##"
echo ";;[ ;;;;;;;;;;;;;;;;;;;;; ];;;,'*####*'ccS###*', ## ;;;;;; ##"
echo "- --- ---------------------------------------------------- *#"
echo "(::) buildscript adapted from SGT7 ICS TE4M's CM9 build"
echo "(::) kernel packaging / rebuild from teamhacksung"
echo "---------------------------------------------------- --- -- -"

# default settings ::
DEVICE=p1
VARIANT=userdebug
TOP=${PWD}
THREADS=$(grep processor /proc/cpuinfo | wc -l)

# create logging directory for build logs
mkdir -p logs

# --------------------------------------------

do_build()
{
	echo "(*) device  :: $DEVICE"
	echo "(*) variant :: $VARIANT"
	echo "(*) threads :: $THREADS"
	time {
		START=$(date +%s)
		STARTBUILD=`date +"%H:%M @ %d/%m/%Y"`
		echo
		echo "(::) starting build :: $STARTBUILD"
		echo
		make -j$THREADS bacon $OTHER | tee logs/aokp_sgt7-$DEVICE-`date +"%Y_%m_%d-%H_%M"`.log
		create_kernel_zip
		ENDBUILD=`date +"%H:%M @ %d/%m/%Y"`
		echo
		echo "(::) build completed @ $ENDBUILD"
		END=$(date +%s)
		ELAPSED=$((END - START))
		E_MIN=$((ELAPSED / 60))
		E_SEC=$((ELAPSED - E_MIN * 60))
		printf "(::) time elapsed: "
		[ $E_MIN != 0 ] && printf "%d min(s) " $E_MIN
		printf "%d sec(s)\n" $E_SEC
		echo
	}
}

build_kernel()
{
	START=$(date +%s)
	echo	
	echo -e "(::) KERNEL :: building bootimage for $DEVICE ..."
	echo
        rm -rf out/target/product/${DEVICE}/obj/KERNEL_OBJ
        rm out/target/product/${DEVICE}/kernel
        rm out/target/product/${DEVICE}/boot.img
        rm -rf out/target/product/${DEVICE}/root
        rm -rf out/target/product/${DEVICE}/ramdisk*

        make -j${THREADS} out/target/product/${DEVICE}/boot.img | tee logs/aokp_sgt7-kernel-$DEVICE-`date +"%Y_%m_%d-%H_%M"`.log
        make -j${THREADS} updater
        if [ ! -e out/host/linux-x86/framework/signapk.jar ]; then
		make -j${THREADS} signapk
        fi
        create_kernel_zip
	END=$(date +%s)
	ELAPSED=$((END - START))
	E_MIN=$((ELAPSED / 60))
	E_SEC=$((ELAPSED - E_MIN * 60))
	printf "(::) KERNEL :: succesfully built - time elapsed: "
	[ $E_MIN != 0 ] && printf "%d min(s) " $E_MIN
	printf "%d sec(s)\n" $E_SEC
	echo
}

create_kernel_zip()
{
    if [ -e out/target/product/${DEVICE}/boot.img ]; then
        if [ -e ${TOP}/buildscripts/samsung/${DEVICE}/kernel_updater-script_top ]; then

            echo -e "(::) KERNEL :: creating kernel zip for ${DEVICE}"
            cd out/target/product/${DEVICE}

            rm -rf kernel_zip
            rm -f aokp_sgt7-*_kernel-*.zip

            mkdir -p kernel_zip/system/lib/modules
            mkdir -p kernel_zip/META-INF/com/google/android

            echo "(::) KERNEL :: copying boot.img..."
            cp boot.img kernel_zip/
            echo "(::) KERNEL :: copying kernel flashing tools..."
            cp -R ${TOP}/buildscripts/samsung/common/* kernel_zip/
            echo "(::) KERNEL :: copying kernel modules..."
            cp -R system/lib/modules/* kernel_zip/system/lib/modules
            echo "(::) KERNEL :: copying update-binary..."
            cp obj/EXECUTABLES/updater_intermediates/updater kernel_zip/META-INF/com/google/android/update-binary
            echo "(::) KERNEL :: copying updater-script..."
            cat ${TOP}/buildscripts/samsung/${DEVICE}/kernel_updater-script_top > kernel_zip/META-INF/com/google/android/updater-script
	    echo "ui_print(\"(::) device            :: ${DEVICE}\");" >> kernel_zip/META-INF/com/google/android/updater-script
	    echo "ui_print(\"(::) kernel build date :: $(date +%d/%m/%Y)\");" >> kernel_zip/META-INF/com/google/android/updater-script
            cat ${TOP}/buildscripts/samsung/${DEVICE}/kernel_updater-script_bottom >> kernel_zip/META-INF/com/google/android/updater-script
            echo "(::) KERNEL :: zipping CWM recovery flashable package..."
            cd kernel_zip
            zip -qr ../aokp_sgt7-${DEVICE}_kernel-$(date +%Y%m%d).zip ./
            cd ${TOP}/out/target/product/${DEVICE}

            echo "(::) KERNEL :: signing package..."
            java -jar ${TOP}/out/host/linux-x86/framework/signapk.jar ${TOP}/build/target/product/security/testkey.x509.pem ${TOP}/build/target/product/security/testkey.pk8 aokp_sgt7-${DEVICE}_kernel-$(date +%Y%m%d).zip aokp_sgt7-${DEVICE}_kernel-$(date +%Y%m%d)-signed.zip
            rm aokp_sgt7-${DEVICE}_kernel-$(date +%Y%m%d).zip
	    mv aokp_sgt7-${DEVICE}_kernel-$(date +%Y%m%d)-signed.zip aokp_sgt7-${DEVICE}_kernel-$(date +%Y%m%d).zip
            echo -e "(::) KERNEL :: package complete - out/target/product/${DEVICE}/aokp_sgt7-${DEVICE}_kernel-$(date +%Y%m%d).zip"
            md5sum aokp_sgt7-${DEVICE}_kernel-$(date +%Y%m%d).zip
            cd ${TOP}
        else
            echo -e "(::) KERNEL :: no instructions to create out/target/product/${DEVICE}/aokp_sgt7-${DEVICE}_kernel-$(date +%Y%m%d).zip... skipping."
        fi
    fi
}

case "$1" in
  distclean)
      repo forall -c 'git clean -xdf'
      ;&
  clean)
      make clobber
      ( cd kernel/samsung/p1  ; make mrproper )
      ( cd kernel/samsung/p1c ; make mrproper )
      ;;
  kernel)
	if [ "$2" == "all" ]; then
		for i in p1 p1c p1l p1n; do
			DEVICE="$i"
			TARGET="aokp_$DEVICE-$VARIANT"
			source build/envsetup.sh
			lunch "$TARGET"
			build_kernel
		done
	else
		for i in p1 p1c p1l p1n; do
			[ "$2" == "$i" ] && DEVICE="$i"
		done
		TARGET="aokp_$DEVICE-$VARIANT"
		source build/envsetup.sh
		lunch "$TARGET"
		build_kernel
	fi
	;;
   build)
	if [ "$2" == "all" ]; then
		for i in p1 p1c p1l p1n; do
			DEVICE="$i"
			TARGET="aokp_$DEVICE-$VARIANT"
			source build/envsetup.sh
			lunch "$TARGET"
			do_build
		done
	else
		for i in p1 p1c p1l p1n; do
			[ "$2" == "$i" ] && DEVICE="$i"
		done
		TARGET="aokp_$DEVICE-$VARIANT"
		source build/envsetup.sh
		lunch "$TARGET"
		do_build
	fi
	;;
  *)
      echo
      echo "(!!) usage ::" 
      echo "       ${0##*/} <action> [ device ]"
      echo
      echo "  <action> : clean|distclean|build|kernel"
      echo "  <device> : p1|p1c|p1l|p1n|all"
      ;;
esac


