#!/usr/bin/env bash

BLACK='\033[0;30m'
DGRAY='\033[1;30m'
RED='\033[0;31m'
BRED='\033[1;31m'
GREEN='\033[0;32m'
BGREEN='\033[1;32m'
YELLOW='\033[0;33m'
BYELLOW='\033[1;33m'
BLUE='\033[0;34m'
BBLUE='\033[1;34m'
PURPLE='\033[0;35m'
BPURPLE='\033[1;35m'
CYAN='\033[0;36m'
BCYAN='\033[1;36m'
LGRAY='\033[0;37m'
WHITE='\033[1;37m'
NOCOLOR='\033[0m'

SCRIPT_PATH=`dirname $0`
cd $SCRIPT_PATH
mydir=`pwd`
HIVE_REPO_URL=
SERVER_CONF=$mydir"/server.conf"
TMP_DIR=$mydir"/tmp"

new_ver=
cur_ver=

[[ -f $mydir"/VER" ]] && cur_ver=`cat $mydir"/VER"`

new_ver=`curl -j -f -s https://raw.githubusercontent.com/minershive/hiveos-pxe-diskless/master/pxeserver/VER`
if [[ $? -ne 0 || -z $new_ver || -z $cur_ver || $new_ver != $cur_ver ]]; then
	echo "You package of Hiveos PXE server is outdate."
	echo "Need upgrade Hiveos PXE server. Otherwise correct work is not guaranteed"
	upgrade="y"
	echo -n "Do you want to upgrade Hiveos PXE server package [Y/n]?"
	read upg
	[[ ! -z $upg ]] && upgrade=$(echo ${upg,,} | cut -c 1)
	if [[ $upgrade == "y" ]]; then
		current_dir=`dirname $mydir`
		sudo curl -j -f -s https://raw.githubusercontent.com/minershive/hiveos-pxe-diskless/master/pxe-setup.sh -o "/tmp/pxe-setup.sh"
		[[ $? -ne 0 ]] && "Download install script failed! Exit" && exit 1
		chmod +x /tmp/pxe-setup.sh
		exec sudo /tmp/pxe-setup.sh $current_dir
		exit 0
	fi
fi


source $SERVER_CONF > /dev/null 2>&1
FS="$mydir/hiveramfs/$ARCH_NAME"

echo "> Upgrading HiveOS FS"

if [[ -z $HIVE_REPO_URL ]];then
	echo -e "${RED}Hive repo URL not set. Run pxe-config.sh first${NOCOLOR}"
	exit 1
fi

if [[ ! -f $FS ]];then
	echo -e "${RED}Hive FS archive not found${NOCOLOR}"
	exit 1
fi


dpkg -s pv > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
	apt update
	apt install -y pv
fi

[[ -d $TMP_DIR ]] && rm -R $TMP_DIR
mkdir -p ${TMP_DIR}/root
cd ${TMP_DIR}/root
echo
arch_size=$(wc -c < $FS )
echo -e "> Extract Hive FS to tmp dir"
pv $FS | tar --lzma -xf -
echo
echo -e "> Chrooting to Hive FS"
echo
mount proc -t proc ${TMP_DIR}/root/proc
mount sys -t sysfs ${TMP_DIR}/root/sys
mount --bind /dev ${TMP_DIR}/root/dev
mount --bind /run ${TMP_DIR}/root/run
#exit


cat << EOF | chroot ${TMP_DIR}/root	
export PATH="./:/hive/bin:/hive/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
echo "deb $HIVE_REPO_URL /" > /etc/apt/sources.list.d/hiverepo.list
apt update
serverupgrade
echo $? > /exitcode
EOF



umount ${TMP_DIR}/root/proc
umount ${TMP_DIR}/root/sys
umount ${TMP_DIR}/root/dev
umount ${TMP_DIR}/root/run

[[ $(cat ${TMP_DIR}/root/exitcode) != 0 ]] && echo -e "${RED}Hive FS upgrade failed${NOCOLOR}" && exit 1
rm ${TMP_DIR}/root/exitcode
touch ${TMP_DIR}/root/hive-config/.DISKLESS_AMD > /dev/null 2>&1
cd ${TMP_DIR}
rm -R ${TMP_DIR}/root/var/lib/apt/lists/*

echo
echo -e "${GREEN}Hive FS upgrade complete${NOCOLOR}"
echo
echo -e "> Create FS archive"
tar -C root --lzma -cpf - . | pv -s $arch_size | cat > $ARCH_NAME
res=$?
#tar -C root --lzma -cpf - . | pv -s $(du -sb root | awk '{print $1}') | cat > $ARCH_NAME
echo
echo -e "> Check FS archive"
pv $ARCH_NAME | tar -v -Jtf - | awk '{size+=$3} END {print size}' > size
size=$(cat size)

if [[ $res -ne 0 || $size < 1000000000 ]];then
	echo -e "${RED}Create Hive FS archive failed or FS size too small${NOCOLOR}"
	cd $mydir
#	rm -R ${TMP_DIR}
	exit 1
fi
size=$(echo $size | awk '{ $1 = $1/1024**2}1')
echo
echo -e "${GREEN}Create FS archive successfull. Size of FS:${YELLOW} "$size" Mb${NOCOLOR}"
echo -e "${GREEN}Recommended size of tmpfs on the rigs: ${YELLOW}Not less than "$(( ${size%.*} + 150 ))" Mb${NOCOLOR}"
echo
back=$mydir"/backup_fs/"$(basename $FS)"."`TZ=UTC date +'%y%m%d'`".bak"
echo -e "> Backup old FS archive to "$back
[[ ! -d $mydir/backup_fs ]] && mkdir -p $mydir/backup_fs
pv $FS > $back
echo
echo -e "> Replacing old FS archive"
pv $ARCH_NAME > $FS
cd $mydir
rm -R ${TMP_DIR}
echo
echo -e "${GREEN}Update Hive FS successfull. To use updated HiveOS, reboot you rigs${NOCOLOR}"

exit 0
