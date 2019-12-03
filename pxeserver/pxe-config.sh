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

SERVER_CONF=$mydir"/server.conf"
HIVE_CONF=$mydir"/hive-config/rig.conf"

TFTP_ROOT=$mydir"/tftp"
BOOT_CONF=$TFTP_ROOT"/bios/menu.cfg"
HTTP_ROOT="$mydir/hiveramfs"
SYS_CONF=$mydir"/configs"


#install package
need_install=
dpkg -s apache2  > /dev/null 2>&1
[[ $? -eq 0 ]] && service apache2 stop > /dev/null 2>&1 && apt remove apache2 > /dev/null 2>&1

dpkg -s dnsmasq  > /dev/null 2>&1
[[ $? -ne 0 ]] && need_install="$need_install dnsmasq"
dpkg -s nginx-extras  > /dev/null 2>&1
[[ $? -ne 0 ]] && need_install="$need_install nginx-extras"
dpkg -s pv  > /dev/null 2>&1
[[ $? -ne 0 ]] && need_install="$need_install pv"
dpkg -s atftpd  > /dev/null 2>&1
[[ $? -ne 0 ]] && need_install="$need_install atftpd"

if [[ ! -z $need_install ]]; then
	apt update
	apt install -y $need_install
fi
######
FARM_HASH=""
source $SERVER_CONF > /dev/null 2>&1
source $HIVE_CONF > /dev/null 2>&1

##Get variable

echo -e "${GREEN}Workers config${NOCOLOR}"

if [[ ! -z $FARM_HASH ]]; then
	echo -e "FARM_HASH: ${YELLOW}$FARM_HASH${NOCOLOR}"
	echo "Press ENTER to continue with this FARM_HASH or type a new one"
else
	echo -n "Type FARM_HASH: "
fi
while true; do
	read hash
	[[ -z $hash && ! -z $FARM_HASH ]] && break
	[[ -z $hash ]] && echo "Invalid FARM_HASH" && continue
	[[ ! $hash =~ \"|\'|[[:blank:]] ]] && FARM_HASH=$hash &&
		echo -e "New FARM_HASH: ${YELLOW}$FARM_HASH${NOCOLOR}" &&
		break
	echo "Invalid FARM_HASH"
done

if [[ ! -z $HIVE_HOST_URL ]]; then
	echo -e "Hive server URL: ${YELLOW}$HIVE_HOST_URL${NOCOLOR}"
	echo "Press ENTER to continue with this URL or type a new one"
else
	echo -n "Type Hive server URL: "
fi
while true; do
	read url
	[[ -z $url && ! -z $HIVE_HOST_URL ]] && break
	[[ $url =~ ^(http|https)://.+$ ]] &&
		HIVE_HOST_URL=$url &&
		echo -e "New Hive server URL: ${YELLOW}$HIVE_HOST_URL${NOCOLOR}" &&
		break
	echo "Invalid URL"
done
echo "++++++++++++++++++"
echo -e "${GREEN}Server config${NOCOLOR}" 
if [[ ! -z $HIVE_REPO_URL ]]; then
	echo -e "Hive repo URL: ${YELLOW}$HIVE_REPO_URL${NOCOLOR}"
	echo "Press ENTER to continue with this URL or type a new one"
else
	echo -n "Type Hive repo URL: "
fi
while true; do
	read repourl
	[[ -z $repourl && ! -z $HIVE_REPO_URL ]] && break
	[[ $repourl =~ ^(http|https):// ]] &&
		HIVE_REPO_URL=$repourl &&
		echo -e "New Hive repo URL: ${YELLOW}$HIVE_REPO_URL${NOCOLOR}" &&
		break
	echo "Invalid URL"
done

IP=$(hostname -I |  awk '{print $1}')
if [[ ! -z $IP ]]; then
	echo -e "Current server IP-address: ${YELLOW}$IP${NOCOLOR}"
	echo "Press ENTER to continue with this IP-address or type a new one"
else
	echo -n "Type this server IP-address: "
fi
while true; do
	read ip
	[[ -z $ip && ! -z $IP ]] && break
	[[ $ip =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]] &&
		IP=$ip &&
		echo -e "New IP: ${YELLOW}$IP${NOCOLOR}" &&
		break
	echo "Invalid IP"
done


[[ -z $FS_SIZE ]] && FS_SIZE=1400
echo -e "TMPFS size: ${YELLOW}$FS_SIZE Mb${NOCOLOR}"
echo "Press ENTER to continue with this TMPFS size or type a new one (in MB)"

while true; do
	read size
	[[ -z $size && ! -z $FS_SIZE ]] && break
	[[ $size =~ ^[0-9]+$ ]] &&
		FS_SIZE=$size &&
		echo -e "New TMPFS size: ${YELLOW}$FS_SIZE Mb${NOCOLOR}" &&
		break
	echo "Invalid TMPFS size"
done

[[ -z $ARCH_NAME ]] && ARCH_NAME=hiveramfs.tar.xz
echo -e "FS archive name: ${YELLOW}$ARCH_NAME${NOCOLOR}"
echo "Press ENTER to continue with this FS archive name or type a new one"

while true; do
	read archname
	[[ -z $archname && ! -z $ARCH_NAME ]] && break
	[[ $archname =~ \"|\'|[[:blank:]] ]] &&
		ARCH_NAME=$archname &&
		echo -e "New FS archive name: ${YELLOW}$ARCH_NAME${NOCOLOR}" &&
		break
	echo "Invalid FS archive name"
done
echo 

echo -e "${GREEN}Config complete${NOCOLOR}" 
echo "++++++++++++++++++"

echo "HIVE_HOST_URL="$HIVE_HOST_URL > $HIVE_CONF
echo "" >> $HIVE_CONF
echo "FARM_HASH="$FARM_HASH >> $HIVE_CONF
echo "" >> $HIVE_CONF
echo "X_DISABLED=1" >> $HIVE_CONF
echo "HIVE_REPO_URL="$HIVE_REPO_URL > $SERVER_CONF
echo "">> $SERVER_CONF
echo "IP="$IP >> $SERVER_CONF
echo "" >> $SERVER_CONF
echo "FS_SIZE="$FS_SIZE >> $SERVER_CONF
echo "" >> $SERVER_CONF
echo "ARCH_NAME="$ARCH_NAME >> $SERVER_CONF
echo "" >> $SERVER_CONF

#Change Boot config
sed -i "/kernel/c kernel http://${IP}/hiveramfs/boot/vmlinuz" $BOOT_CONF
sed -i "/append/c append initrd=http://${IP}/hiveramfs/boot/initrd-ram.img ip=dhcp root=http httproot=http://${IP}/hiveramfs/ ram_fs_size=${FS_SIZE}M hive_fs_arch=${ARCH_NAME} text consoleblank=0 intel_pstate=disable net.ifnames=0 ipv6.disable=1 pci=noaer iommu=soft amdgpu.vm_fragment_size=9 radeon.si_support=0 radeon.cik_support=0 amdgpu.si_support=1 amdgpu.cik_support=1" $BOOT_CONF 

echo "port=0" > $SYS_CONF"/etc/dnsmasq.conf"
echo "" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "log-facility=/var/log/dnsmasq.log" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "log-dhcp" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "#change the IP-address to the real IP-address of the server" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "dhcp-range=$IP,proxy" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "dhcp-no-override" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "" >> $SYS_CONF"/etc/dnsmasq.conf"
#echo "enable-tftp" >> $SYS_CONF"/etc/dnsmasq.conf"
#echo "tftp-root=$TFTP_ROOT" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "dhcp-option-force=208,f1:00:74:7e" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "dhcp-option-force=211,30i" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "#change the IP-address to the real IP-address of the server" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "pxe-service=X86PC, "Boot BIOS PXE",/bios/lpxelinux.0,$IP" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "pxe-service=BC_EFI, "Boot UEFI PXE-BC",/efi/grubnetx64.efi,$IP" >> $SYS_CONF"/etc/dnsmasq.conf"
echo "pxe-service=X86-64_EFI, "Boot UEFI PXE-64",/efi/grubnetx64.efi,$IP" >> $SYS_CONF"/etc/dnsmasq.conf"

cp /etc/dnsmasq.conf $SYS_CONF"/etc/dnsmasq.bak"
cp $SYS_CONF"/etc/dnsmasq.conf" /etc
echo "DNSMASQ_EXCEPT=lo" >> /etc/default/dnsmasq

[[ ! -d /var/www/html ]] && mkdir -p /var/www/html
[[ ! -e /var/www/html/hiveramfs ]] && ln -s $HTTP_ROOT /var/www/html
cp -R /etc/nginx $SYS_CONF/etc/nginx.bak
cp -R $SYS_CONF/etc/nginx /etc

sed -e 's/^USE_INETD=true/USE_INETD=false/g' -i /etc/default/atftpd
sed -i "/OPTIONS=/c OPTIONS=\"--tftpd-timeout 300 --retry-timeout 5 --mcast-port 1758 --mcast-addr 239.239.239.0-255 --mcast-ttl 1 --maxthread 100 --verbose=5 ${TFTP_ROOT}\"" /etc/default/atftpd
systemctl enable atftpd > /dev/null 2>&1

sysctl net.core.somaxconn=65535

res=0
echo -n "> Restart DNSMASQ server. "
service dnsmasq restart
if [[ $? -ne 0 ]]; then
	res=1
	echo -e "${RED}FAILED${NOCOLOR}"
else
	echo -e "${GREEN}OK${NOCOLOR}"
fi
echo -n "> Restart Nginx server. "
service nginx restart
if [[ $? -ne 0 ]]; then
	res=1
	echo -e "${RED}FAILED${NOCOLOR}"
else
	echo -e "${GREEN}OK${NOCOLOR}"
fi

echo -n "> Restart Atftp server. "
systemctl restart atftpd
if [[ $? -ne 0 ]]; then
	res=1
	echo -e "${RED}FAILED${NOCOLOR}"
else
	echo -e "${GREEN}OK${NOCOLOR}"
fi

echo
[[ $res != 0 ]] && echo -e "${RED}Server install failed${NOCOLOR}" && exit 1
echo -e "${GREEN}Server ready to work${NOCOLOR}"
echo 
upgrade="y"
echo -n "Do you want to upgrade HiveOS [Y/n]?"
read upg

[[ ! -z $upg ]] && upgrade=$(echo ${upg,,} | cut -c 1)

[[ $upgrade == "y" ]] && exec $mydir/hive-upgrade.sh

exit 0
