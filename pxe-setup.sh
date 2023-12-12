#!/bin/bash

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



dir=$1
[[ $dir == "/" ]] && dir=""
kernel_url="https://download.hiveos.farm/diskless/kernel"
echo
echo -e "Destination directory: ${YELLOW}${dir}/pxeserver${NOCOLOR}"
echo "Press ENTER to continue with this destination or type a new one"
while true; do
		read dest
		[[ -z $dest ]] && break
		if [[ $(echo $dest | head -c 1) == "/" ]]; then
			dir=$dest
			[[ $dir == "/" ]] && dir=""
			echo -e "New destination directory: ${YELLOW}${dir}/pxeserver${NOCOLOR}"
			break
		fi
		echo -e "${RED}> Please specify FULL PATH to destination dir${NOCOLOR}"
done

[[ -d /tmp/pxe-server ]] && rm -R /tmp/pxe-server
mkdir -p /tmp/pxe-server > /dev/null 2>&1
cd /tmp/pxe-server
echo
echo -e "${GREEN}> Download PXE-server package${NOCOLOR}"
wget -t 5 --show-progress https://github.com/minershive/hiveos-pxe-diskless/archive/master.zip
echo
if [[ $? -eq 0 ]]; then
    dpkg -s unzip  > /dev/null 2>&1
    [[ $? -ne 0 ]] && apt-get install -y unzip
	echo -e "${GREEN}> Extract PXE-server package.Please wait${NOCOLOR}"
	unzip master.zip > /dev/null 2>&1
else
	echo -e "${RED}> Error download PXE-server package. Exit${NOCOLOR}"
	exit 1
fi

##No need after 6.5 version.
#cat /tmp/pxe-server/hiveos-pxe-diskless-master/pxeserver/hiveramfs/x* > /tmp/pxe-server/hiveos-pxe-diskless-master/pxeserver/hiveramfs/hiveramfs.tar.xz
#rm /tmp/pxe-server/hiveos-pxe-diskless-master/pxeserver/hiveramfs/x*
##

[[ -f ${dir}/pxeserver/server.conf ]] && cp ${dir}/pxeserver/server.conf /tmp/pxe-server/hiveos-pxe-diskless-master/pxeserver
[[ -d ${dir}/pxeserver/hiveramfs/hive-config ]] && cp -R ${dir}/pxeserver/hiveramfs/hive-config/* /tmp/pxe-server/hiveos-pxe-diskless-master/pxeserver/hiveramfs/hive-config/

[[ ! -d ${dir}/pxeserver ]] && mkdir -p ${dir}/pxeserver

echo
echo -e "${GREEN}> Copy PXE-server package to destination directory.${NOCOLOR}"
cp -R /tmp/pxe-server/hiveos-pxe-diskless-master/pxeserver/* ${dir}/pxeserver/

rm -R /tmp/pxe-server > /dev/null 2>&1

cd ${dir}/pxeserver
[[ -d ${dir}/pxeserver/kernel ]] && rm -R ${dir}/pxeserver/kernel
#mkdir -p ${dir}/pxeserver/kernel
echo
echo -e "${GREEN}> Download PXE-kernel package${NOCOLOR}"
echo
wget -nH --no-parent -r --cut-dir=1 $kernel_url
if [[ $? -ne 0 ]]; then
	echo -e "${RED}> Error download PXE-kernel package. Exit${NOCOLOR}"
	exit 1
fi
[[ -f robots.txt ]] && rm -R robots.txt

config="y"
echo
echo -n "Do you want to config Hiveos PXE server package [Y/n]? "
read val
[[ ! -z $val ]] && config=$(echo ${val,,} | cut -c 1)
if [[ $config == "y" ]]; then
    exec sudo ./pxe-config.sh
else
    echo "> Setup complite. Run pxe-config.sh manualy"
fi
