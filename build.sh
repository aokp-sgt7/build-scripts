#!/bin/bash
# --------------------------------------- ------ ---- -- -
# original build script by eaut/cdesai of SGT7 TE4M
# kernel compilation / CWM flashable zip creation by teamhacksung
# modified for AOKP SGT7 by stimpz0r
# --------------------------------------- ------ ---- -- -

CL_RED="\033[31m"
CL_GRN="\033[32m"
CL_YLW="\033[33m"
CL_BLU="\033[34m"
CL_MAG="\033[35m"
CL_CYN="\033[36m"
CL_RST="\033[0m"

# default settings ::
DEVICE=p1
VERSION=jb-mr1
VARIANT=userdebug
TOP=${PWD}
THREADS=$(grep processor /proc/cpuinfo | wc -l)

# create logging directory for build logs
mkdir -p logs

echo 
echo -e "${CL_CYN}            ,,cSS#"
echo -e "${CL_CYN}            ######    ,,ccc,,    ,,cSS#   ,c####SScc,"
echo -e "${CL_CYN}    ,ccS########## ,cS#######Sc, ######  ,S###S#########SScc,"
echo -e "${CL_CYN}   ;#####*'*######;#####*'*#####;######,cS###*'######*'l#####;"
echo -e "${CL_CYN}  ;l####l   ######l#####   #####l#########S*'  ######  ;#####l"
echo -e "${CL_CYN}  l#####################   ##############Scc,, ######  ;#####l"
echo -e "${CL_CYN}  ######    ############   ############'l###Sc,######c,l#####;"
echo -e "${CL_CYN}  ######;   ######l#####   #####l###### ;###############SS**'"
echo -e "${CL_CYN}  l#####l   ######;#####c,c#####;######  ############"
echo -e "${CL_CYN}  ;######;  '*S### '*S#######S*' ######  ############"
echo -e "${CL_CYN}   l#####l            ''***''    ##S**'  ######'*S###"
echo -e "${CL_BLU}--${CL_CYN} ;S**''  ${CL_BLU}-----------------------------${CL_CYN} '**S## ${CL_BLU}------- --- -"
echo -e "${CL_BLU};;[ . .${CL_MAG} A O K P - S G T 7${CL_BLU} ];;; ${CL_CYN},c####*',cS##Sc,*#####*,c###c,"
echo -e "${CL_BLU};;[ ;;;;;;;;;${CL_MAG} by stimpz0r${CL_BLU} ];;; ${CL_CYN}##;${CL_BLU} ;;; ${CL_CYN}##${CL_BLU} ;; ${CL_CYN}##  ##${CL_BLU} ;;;;;;${CL_CYN}'##"
echo -e "${CL_BLU};;[ ;;;;;;;;;;;;;;;;;;;;; ];;;,${CL_CYN}'*###Sc,*#,,,,##  ##${CL_BLU} ;;;;;; ${CL_CYN}##"
echo -e "${CL_BLU};;[${CL_MAG} B U I L D S C R I P T ${CL_BLU}];;;''    ${CL_CYN};## '''''##  ##${CL_BLU} ;;;;;; ${CL_CYN}##"
echo -e "${CL_BLU};;[ ;;;;;;;;;;;;;;;;;;;;; ];;;,${CL_CYN}'*####*'ccS###*', ##${CL_BLU} ;;;;;; ${CL_CYN}##"
echo -e "${CL_BLU}- --- ---------------------------------------------------- ${CL_CYN}*#"
echo -e "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_MAG} buildscript adapted from SGT7 ICS TE4M's CM9 build"
echo -e "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_MAG} kernel packaging / rebuild from teamhacksung"
echo -e "${CL_BLU}---------------------------------------------------- --- -- -"
echo -e "${CL_RST}"

# --------------------------------------------

do_build()
{
	echo -e "${CL_BLU}(${CL_CYN}**${CL_BLU})${CL_CYN} device  ${CL_BLU}::${CL_MAG} $DEVICE"
	echo -e "${CL_BLU}(${CL_CYN}**${CL_BLU})${CL_CYN} version ${CL_BLU}::${CL_MAG} $VERSION"
	echo -e "${CL_BLU}(${CL_CYN}**${CL_BLU})${CL_CYN} variant ${CL_BLU}::${CL_MAG} $VARIANT"
	echo -e "${CL_BLU}(${CL_CYN}**${CL_BLU})${CL_CYN} threads ${CL_BLU}::${CL_MAG} $THREADS"
	time {
		START=$(date +%s)
		STARTBUILD=`date +"%H:%M @ %d/%m/%Y"`
		echo
		echo -e "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_CYN} starting build ${CL_BLU}::${CL_MAG} $STARTBUILD"
        echo -e "${CL_RST}"
		mka bacon | tee -a logs/aokp_sgt7-$DEVICE_$VERSION-`date +"%Y_%m_%d-%H_%M"`.log
		create_kernel_zip
		ENDBUILD=`date +"%H:%M @ %d/%m/%Y"`
		echo
		echo -e "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_CYN} build completed ${CL_BLU}::${CL_MAG} $ENDBUILD"
		END=$(date +%s)
		ELAPSED=$((END - START))
		E_MIN=$((ELAPSED / 60))
		E_SEC=$((ELAPSED - E_MIN * 60))
		printf "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_CYN} time elapsed${CL_BLU}:${CL_CYN} "
		[ $E_MIN != 0 ] && printf "${CL_MAG}%d${CL_CYN} min(s) " $E_MIN
		printf "${CL_MAG}%d${CL_CYN} sec(s)\n" $E_SEC
        echo -e "${CL_RST}"
	}
}

build_kernel()
{
	START=$(date +%s)
	echo	
	echo -e "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_CYN} KERNEL ${CL_BLU}::${CL_CYN} building bootimage for${CL_MAG} $DEVICE ${CL_BLU}..."
	echo
    rm -rf out/target/product/${DEVICE}/obj/KERNEL_OBJ
    rm out/target/product/${DEVICE}/kernel
    rm out/target/product/${DEVICE}/boot.img
    rm -rf out/target/product/${DEVICE}/root
    rm -rf out/target/product/${DEVICE}/ramdisk*
    if [ $DEVICE == "p1" ]; then
        rm -rf out/target/product/${DEVICE}/obj/KERNEL_P1LN_OBJ
        rm out/target/product/${DEVICE}/boot_p1ln.img
        rm out/target/product/${DEVICE}/kernel_p1ln
    fi            

    mka bootimage | tee -a logs/aokp_sgt7-kernel-$DEVICE_$VERSION-`date +"%Y_%m_%d-%H_%M"`.log
    if [ ! -e out/host/linux-x86/framework/signapk.jar ]; then
        make -j${THREADS} signapk
    fi
    create_kernel_zip $DEVICE $DEVICE
    if [ $DEVICE == "p1" ]; then
        create_kernel_zip $DEVICE p1ln
    fi            
	END=$(date +%s)
	ELAPSED=$((END - START))
	E_MIN=$((ELAPSED / 60))
	E_SEC=$((ELAPSED - E_MIN * 60))
	printf "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_CYN} KERNEL ${CL_BLU}::${CL_CYN} succesfully built ${CL_BLU}-${CL_CYN} time elapsed${CL_BLU}:${CL_CYN} "
	[ $E_MIN != 0 ] && printf "${CL_MAG}%d${CL_CYN} min(s) " $E_MIN
	printf "${CL_MAG}%d${CL_CYN} sec(s)\n" $E_SEC
    echo -e "${CL_RST}"
}

create_kernel_zip()
{
    if [ -e out/target/product/${DEVICE}/boot.img ]; then
    if [ -e ${TOP}/buildscripts/samsung/${DEVICE}/kernel_updater-script_top ]; then

        DEVICE_TYPE=$1
        DEVICE_NAME=$2

        echo -e "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_CYN} KERNEL ${CL_BLU}::${CL_CYN} creating kernel zip for${CL_MAG} ${DEVICE_NAME}"
        cd out/target/product/${DEVICE_TYPE}

        rm -rf kernel_zip
        rm -f aokp_sgt7-${DEVICE_NAME}_${VERSION}_kernel-*.zip

        mkdir -p kernel_zip/system/lib/modules
        mkdir -p kernel_zip/META-INF/com/google/android

        echo -e "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_CYN} KERNEL ${CL_BLU}::${CL_CYN} copying boot.img ${CL_BLU}..."
        if [ $DEVICE_NAME == "p1ln" ]; then
            if [ -e boot_p1ln.img ]; then
                cp boot_p1ln.img kernel_zip/boot.img
            fi
        else
            if [ -e boot.img ]; then
                cp boot.img kernel_zip/
            fi
        fi
        echo -e "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_CYN} KERNEL ${CL_BLU}::${CL_CYN} copying kernel flashing tools ${CL_BLU}..."
        cp -R ${TOP}/buildscripts/samsung/common/* kernel_zip/
        echo -e "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_CYN} KERNEL ${CL_BLU}::${CL_CYN} copying kernel modules ${CL_BLU}..."
        cp -R system/lib/modules/* kernel_zip/system/lib/modules
        echo -e "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_CYN} KERNEL ${CL_BLU}::${CL_CYN} copying update-binary ${CL_BLU}..."
        cp obj/EXECUTABLES/updater_intermediates/updater kernel_zip/META-INF/com/google/android/update-binary
        echo -e "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_CYN} KERNEL ${CL_BLU}::${CL_CYN} copying updater-script ${CL_BLU}..."
        cat ${TOP}/buildscripts/samsung/${DEVICE_TYPE}/kernel_updater-script_top > kernel_zip/META-INF/com/google/android/updater-script
        echo "ui_print(\"(::) device            :: ${DEVICE_NAME}\");" >> kernel_zip/META-INF/com/google/android/updater-script
        echo "ui_print(\"(::) android version   :: ${VERSION}\");" >> kernel_zip/META-INF/com/google/android/updater-script
        echo "ui_print(\"(::) kernel build date :: $(date +%d/%m/%Y)\");" >> kernel_zip/META-INF/com/google/android/updater-script
        cat ${TOP}/buildscripts/samsung/${DEVICE_TYPE}/kernel_updater-script_bottom >> kernel_zip/META-INF/com/google/android/updater-script
        echo -e "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_CYN} KERNEL ${CL_BLU}::${CL_CYN} zipping recovery flashable package ${CL_BLU}..."
        cd kernel_zip
        zip -qr ../aokp_sgt7-${DEVICE_NAME}_${VERSION}_kernel-$(date +%Y%m%d).zip ./
        cd ${TOP}/out/target/product/${DEVICE_TYPE}

        echo -e "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_CYN} KERNEL ${CL_BLU}::${CL_CYN} signing package ${CL_BLU}..."
        java -jar ${TOP}/out/host/linux-x86/framework/signapk.jar -w ${TOP}/build/target/product/security/testkey.x509.pem ${TOP}/build/target/product/security/testkey.pk8 aokp_sgt7-${DEVICE_NAME}_${VERSION}_kernel-$(date +%Y%m%d).zip aokp_sgt7-${DEVICE_NAME}_${VERSION}_kernel-$(date +%Y%m%d)-signed.zip
        rm aokp_sgt7-${DEVICE_NAME}_${VERSION}_kernel-$(date +%Y%m%d).zip
        mv aokp_sgt7-${DEVICE_NAME}_${VERSION}_kernel-$(date +%Y%m%d)-signed.zip aokp_sgt7-${DEVICE_NAME}_${VERSION}_kernel-$(date +%Y%m%d).zip
        echo -e "${CL_BLU}(${CL_CYN}::${CL_BLU})${CL_CYN} KERNEL ${CL_BLU}::${CL_CYN} package complete ${CL_BLU}::${CL_MAG} out/target/product/${DEVICE_TYPE}/aokp_sgt7-${DEVICE_NAME}_${VERSION}_kernel-$(date +%Y%m%d).zip"
        echo -e "${CL_RST}"
        md5sum aokp_sgt7-${DEVICE_NAME}_${VERSION}_kernel-$(date +%Y%m%d).zip
        cd ${TOP}

    else
        echo -e "${CL_BLU}(${CL_RED}!!${CL_BLU})${CL_RED} KERNEL ${CL_BLU}::${CL_CYN} no instructions to create${CL_MAG} out/target/product/${DEVICE_TYPE}/aokp_sgt7-${DEVICE_NAME}_${VERSION}_kernel-$(date +%Y%m%d).zip ${CL_BLU}...${CL_CYN} skipping."
        echo -e "${CL_RST}"
    fi
    fi
}

case "$1" in
  distclean)
      repo forall -c 'git clean -xdf'
      ;&
  clean)
      make clobber
      ( cd kernel/samsung/aries  ; make mrproper )
      ;;
  kernel)
	if [ "$2" == "all" ]; then
		for i in p1 p1c; do
			DEVICE="$i"
			TARGET="aokp_$DEVICE-$VARIANT"
			source build/envsetup.sh
			lunch "$TARGET"
			build_kernel
		done
	else
		for i in p1 p1c; do
			[ "$2" == "$i" ] && DEVICE="$i"
		done
		TARGET="aokp_$DEVICE-$VARIANT"
		source build/envsetup.sh
		lunch "$TARGET"
		build_kernel
	fi
	;;
  kernelzip)
	for i in p1 p1c; do
		[ "$2" == "$i" ] && DEVICE="$i"
	done
	TARGET="aokp_$DEVICE-$VARIANT"
	source build/envsetup.sh
	lunch "$TARGET"
    create_kernel_zip $DEVICE $DEVICE
    if [ $DEVICE == "p1" ]; then
        create_kernel_zip $DEVICE p1ln
    fi            
	;;
   build)
	if [ "$2" == "all" ]; then
		for i in p1 p1c; do
			DEVICE="$i"
			TARGET="aokp_$DEVICE-$VARIANT"
			source build/envsetup.sh
			lunch "$TARGET"
			do_build
		done
	else
		for i in p1 p1c; do
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
      echo -e "${CL_BLU}(${CL_RED}!!${CL_BLU})${CL_RED} USAGE ${CL_BLU}::${CL_CYN} " 
      echo -e "       ${0##*/} ${CL_MAG}<action> ${CL_CYN}[ device ]"
      echo
      echo -e "  ${CL_MAG}<action> ${CL_BLU}: ${CL_CYN}clean${CL_BLU}|${CL_CYN}distclean${CL_BLU}|${CL_CYN}build${CL_BLU}|${CL_CYN}kernel"
      echo -e "  ${CL_CYN}[device] ${CL_BLU}: ${CL_CYN}p1${CL_BLU}|${CL_CYN}p1c${CL_BLU}|${CL_CYN}all ${CL_BLU}- ${CL_CYN}if no device selected, then p1 is assumed"
      echo -e "${CL_RST}"
      ;;
esac


