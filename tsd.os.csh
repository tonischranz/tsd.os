#!/bin/csh
hash tsd.os || (hash fetch && mkdir -p ~/bin && fetch -o ~/bin/tsd.os https://tsd.ovh/os && chmod +x ~/bin/tsd.os)

set fbsd_root=https://download.freebsd.org/ftp/releases
set fbsd_arch=amd64
set fbsd_fam=amd64
set fbsd_rel=13.0

echo "   _____________________________________________"
echo " /----------------------------------------------"
echo "|-----------------------------------------------"
echo "|\   tsd.os"
echo " \\__________________________________________---"
echo

[ -n "$1" ] || echo "Usage: tsd.os live          - boot live system\
       tsd.os install       - install pkgs\
       tsd.os inject        - install on boot\
       tsd.os <dev>         - create live usb\
       tsd.os uefi [<dev>]  - make bootable"; echo

if ("$1" == install) then
	pkg install -y pkg curl && \
	/usr/local/bin/curl https://tsd.ovh/c | csh

else if ("$1" == uefi) then
	set tsd_dir=`mktemp -d`; cd $tsd_dir
	set tsd_efi=`gpart show -lp | grep efi | awk '{print $3}' | head -n1`
	newfs_msdos -F 32 -c 1 -m 0xf8 /dev/$tsd_efi
	mkdir efi; mount -t msdosfs /dev/$tsd_mde efi/
	mkdir -p efi/EFI/BOOT; cp mnt/boot/loader.efi efi/EFI/BOOT/BOOTX64.efi
	reboot

else if ("$1" == inject) then
	fetch -o /mnt/sbin/tsd.os https://tsd.ovh/os
	chmod +x /mnt/sbin/tsd.os
	echo "tsd.os install" > /mnt/root/.tsd.firstrun
	echo "[ -f ~/.tsd.firstrun ] && . ~/.tsd.firstrun && rm -f ~/.tsd.firstrun" >> /mnt/etc/etc.local	

else if ("$1" == live) then
[ -w / ] && (echo / must be mounted readonly for live-system; exit 1)

echo cleaning up old partitions
gpart show -l | nawk '/=>/{if (match($4,"/")){ignore=1} else {ignore=0;geom=$4}}\
/tsd\.swap/{if (! ignore) { system("gpart delete -i " $3 " " geom) } }\
/tsd\.local/{if (! ignore) { system("gpart delete -i " $3 " " geom) } }\
/tsd\.db/{if (! ignore) { system("gpart delete -i " $3 " " geom) } }\
/tsd\.cache/{if (! ignore) { system("gpart delete -i " $3 " " geom) } }'

mkdir -p /var/cache/pkg\)
exit

echo checking for 20G
	gpart show | nawk 'BEGIN{second=0;first=0}\
/=>/{if (match($4,"/")){ignore=1} else {ignore=0;geom=$4}}\
/- free -/{if (! ignore && $2 > 41943040 && $2 > first)\
{if (first > second) {second_geom=first_geom;second=first};\
first=$2;first_geom=geom}\
else {if (! ignore && $2 > 41943040 && $2 > second) {second=$2;second_geom=geom}}}\
END{\
if (first){\
if (second)\
{system("tsd_db=`gpart add -t freebsd-ufs  -s 512M -l tsd.db "    second_geom " | cut -d \" \" -f1`;newfs -L tsd-db    /dev/$tsd_db;    mount /dev/$tsd_db    /var/db/pkg");\
 system("tsd_cache=`gpart add -t freebsd-ufs  -s 1G   -l tsd.cache " second_geom " | cut -d \" \" -f1`;newfs -L tsd-cache /dev/$tsd_cache; mount /dev/$tsd_cache /var/cache/pkg");\
 system("tsd_loc=`gpart add -t freebsd-ufs  -s 10G  -l tsd.local " second_geom " | cut -d \" \" -f1`;newfs -L tsd-local /dev/$tsd_loc;   mount /dev/$tsd_loc   /usr/local");\
 system("tsd_swap=`gpart add -t freebsd-swap -s 4G   -l tsd.swap "  second_geom " | cut -d \" \" -f1`;swapon /dev/$tsd_swap");\
}\
else\
{system("tsd_db=`gpart add -t freebsd-ufs  -s 512M -l tsd.db "    first_geom " | cut -d \" \" -f1`;newfs -L tsd-db    /dev/$tsd_db;    mount /dev/$tsd_db    /var/db/pkg");\
 system("tsd_cache=`gpart add -t freebsd-ufs  -s 1G   -l tsd.cache " first_geom " | cut -d \" \" -f1`;newfs -L tsd-cache /dev/$tsd_cache; mount /dev/$tsd_cache /var/cache/pkg");\
 system("tsd_loc=`gpart add -t freebsd-ufs  -s 10G  -l tsd.local " first_geom " | cut -d \" \" -f1`;newfs -L tsd-local /dev/$tsd_loc;   mount /dev/$tsd_loc   /usr/local");\
 system("tsd_swap=`gpart add -t freebsd-swap -s 4G   -l tsd.swap "  first_geom " | cut -d \" \" -f1`;swapon /dev/$tsd_swap");\
}}}'

echo 10G
mount | grep /usr/local || gpart show | nawk 'BEGIN{second=0;first=0}\
/=>/{if (match($4,"/")){ignore=1} else {ignore=0;geom=$4}}\
/- free -/{if (! ignore && $2 > 20971520 && $2 > first)\
{if (first > second) {second_geom=first_geom;second=first};\
first=$2;first_geom=geom}\
else {if (! ignore && $2 > 20971520 && $2 > second) {second=$2;second_geom=geom}}}\
END{\
if (first){\
if (second)\
{system("tsd_db=`   gpart add -t freebsd-ufs  -s 512M -l tsd.db "    second_geom " | cut -d \" \" -f1`;newfs -L tsd-db    /dev/$tsd_db;    mount /dev/$tsd_db    /var/db/pkg");\
 system("tsd_cache=`gpart add -t freebsd-ufs  -s 1G   -l tsd.cache " second_geom " | cut -d \" \" -f1`;newfs -L tsd-cache /dev/$tsd_cache; mount /dev/$tsd_cache /var/cache/pkg");\
 system("tsd_loc=`  gpart add -t freebsd-ufs  -s 5G   -l tsd.local " second_geom " | cut -d \" \" -f1`;newfs -L tsd-local /dev/$tsd_loc;   mount /dev/$tsd_loc   /usr/local");\
 system("tsd_swap=` gpart add -t freebsd-swap -s 3G   -l tsd.swap "  second_geom " | cut -d \" \" -f1`;swapon /dev/$tsd_swap");\
}\
else\
{system("tsd_db=`   gpart add -t freebsd-ufs  -s 512M -l tsd.db "    first_geom " | cut -d \" \" -f1`;newfs -L tsd-db    /dev/$tsd_db;    mount /dev/$tsd_db    /var/db/pkg");\
 system("tsd_cache=`gpart add -t freebsd-ufs  -s 1G   -l tsd.cache " first_geom " | cut -d \" \" -f1`;newfs -L tsd-cache /dev/$tsd_cache; mount /dev/$tsd_cache /var/cache/pkg");\
 system("tsd_loc=`  gpart add -t freebsd-ufs  -s 5G   -l tsd.local " first_geom " | cut -d \" \" -f1`;newfs -L tsd-local /dev/$tsd_loc;   mount /dev/$tsd_loc   /usr/local");\
 system("tsd_swap=` gpart add -t freebsd-swap -s 3G   -l tsd.swap "  first_geom " | cut -d \" \" -f1`;swapon /dev/$tsd_swap");\
}}}'

echo 6G
mount | grep /usr/local || gpart show | nawk 'BEGIN{second=0;first=0}\
/=>/{if (match($4,"/")){ignore=1} else {ignore=0;geom=$4}}\
/- free -/{if (! ignore && $2 > 12582912 && $2 > first)\
{if (first > second) {second_geom=first_geom;second=first};\
first=$2;first_geom=geom}\
else {if (! ignore && $2 > 12582912 && $2 > second) {second=$2;second_geom=geom}}}\
END{\
if (first){\
if (second)\
{system("tsd_db=`   gpart add -t freebsd-ufs  -s 512M -l tsd.db "    second_geom " | cut -d \" \" -f1`;newfs -L tsd-db    /dev/$tsd_db;    mount /dev/$tsd_db    /var/db/pkg");\
 system("tsd_cache=`gpart add -t freebsd-ufs  -s 1G   -l tsd.cache " second_geom " | cut -d \" \" -f1`;newfs -L tsd-cache /dev/$tsd_cache; mount /dev/$tsd_cache /var/cache/pkg");\
 system("tsd_loc=`  gpart add -t freebsd-ufs  -s 3G   -l tsd.local " second_geom " | cut -d \" \" -f1`;newfs -L tsd-local /dev/$tsd_loc;   mount /dev/$tsd_loc   /usr/local");\
 system("tsd_swap=` gpart add -t freebsd-swap -l         tsd.swap "  second_geom " | cut -d \" \" -f1`;swapon /dev/$tsd_swap");\
}\
else\
{system("tsd_db=`   gpart add -t freebsd-ufs  -s 256M -l tsd.db "    first_geom " | cut -d \" \" -f1`;newfs -L tsd-db    /dev/$tsd_db;    mount /dev/$tsd_db    /var/db/pkg");\
 system("tsd_cache=`gpart add -t freebsd-ufs  -s 756M -l tsd.cache " first_geom " | cut -d \" \" -f1`;newfs -L tsd-cache /dev/$tsd_cache; mount /dev/$tsd_cache /var/cache/pkg");\
 system("tsd_loc=`  gpart add -t freebsd-ufs  -s 3G   -l tsd.local " first_geom " | cut -d \" \" -f1`;newfs -L tsd-local /dev/$tsd_loc;   mount /dev/$tsd_loc   /usr/local");\
 system("tsd_swap=` gpart add -t freebsd-swap -s 1G   -l tsd.swap "  first_geom " | cut -d \" \" -f1`;swapon /dev/$tsd_swap");\
}}}'

echo disks mounted, creating home
mount -t tmpfs -o size=512M tmpfs /home && mkdir /home/tsdos
echo searching for existing home
set tsd_hostname=`hostname` 
echo current hostname: $tsd_hostname	
set tsd_home=`gpart show -lp | grep tsd\.$tsd_hostname | awk '{print $3}' | head -n1`
[ -n "$tsd_home" ] && echo home found on $tsd_home && mount /dev/$tsd_home /home/tsdos
[ -n "$tsd_home" ] || gpart show | nawk 'BEGIN{second=0;first=0}\
/=>/{if (match($4,"/")){ignore=1} else {ignore=0;geom=$4}}\
/- free -/{if (! ignore && $2 > first)\
{if (first > second) {second_geom=first_geom;second=first};\
first=$2;first_geom=geom}\
else {if (! ignore && $2 > second)\
{second=$2;second_geom=geom}}}\
END{\
if(first)\
{system("tsd_hostname=`hostname`;\
tsd_home=`gpart add -t freebsd-ufs -l tsd.$tsd_hostname " first_geom " | cut -d \" \" -f1`;\
newfs -L tsd-home /dev/$tsd_home;\
mount /dev/$tsd_home /home/tsdos");}}'

cp /etc/ssl/openssl.cnf /home/tsdos
mount -t tmpfs -o size=20M tmpfs /etc/ssl
cp /home/tsdos/openssl.cnf /etc/ssl
rm /home/tsdos/openssl.cnf

tsd.os install

HOME=/home/tsdos; export HOME; cd
/usr/local/bin/bash

poweroff

else
[ -n "$1" ] || exit
[ -w /dev/$1 ] || echo device $1 must exist and be writable && exit

set tsd_dir=`mktemp -d`
cd $tsd_dir
echo working in $tsd_dir
/usr/bin/fetch -o org.iso.xz $fbsd_root/$fbsd_fam/$fbsd_arch/ISO-IMAGES/$fbsd_rel/FreeBSD-$fbsd_rel-RELEASE-$fbsd_arch-bootonly.iso.xz
unxz org.iso.xz
echo creating mount device
set tsd_md=`mdconfig -a -t vnode -f org.iso | cut -d " " -f1`
echo mount device $tsd_md
mkdir mnt
mount -t cd9660 /dev/$tsd_md mnt/
echo creating work tree
(cd mnt;tar cf - .) | (mkdir tsd.os;cd tsd.os;tar xf -)

#patch
echo start patching
echo 'vfs.root.mountfrom="cd9660:/dev/iso9660/TSDOS"\
autoboot_delay="-1"\
beastie_disable="YES"' >> tsd.os/boot/loader.conf

echo 'keymap="ch.kbd"' >> tsd.os/etc/rc.conf
echo '/dev/iso9660/TSDOS / cd9660 ro 0 0' > tsd.os/etc/fstab

cat > tsd.os/etc/rc.local << "rclocaltsdos100351001b"
#!/bin/sh


: ${DIALOG_OK=0}
: ${DIALOG_CANCEL=1}
: ${DIALOG_HELP=2}
: ${DIALOG_EXTRA=3}
: ${DIALOG_ITEM_HELP=4}
: ${DIALOG_ESC=255}

MACHINE=`uname -m`

mount -t tmpfs -o size=512M tmpfs /tmp

# resolv.conf from DHCP ends up in here, so make sure the directory exists
mkdir /tmp/bsdinstall_etc

kbdcontrol -d >/dev/null 2>&1
if [ $? -eq 0 ]; then
	# Syscons: use xterm, start interesting things on other VTYs
	TERM=xterm

	# Don't send ESC on function-key 62/63 (left/right command key)
	kbdcontrol -f 62 '' > /dev/null 2>&1
	kbdcontrol -f 63 '' > /dev/null 2>&1

	if [ -z "$EXTERNAL_VTY_STARTED" ]; then
		# Init will clean these processes up if/when the system
		# goes multiuser
		touch /tmp/bsdinstall_log
		tail -f /tmp/bsdinstall_log > /dev/ttyv2 &
		/usr/libexec/getty autologin ttyv3 &
		EXTERNAL_VTY_STARTED=1
	fi
else
	# Serial or other console
	echo
	echo "Welcome to FreeBSD!"
	echo
	echo "Please choose the appropriate terminal type for your system."
	echo "Common console types are:"
	echo "   ansi     Standard ANSI terminal"
	echo "   vt100    VT100 or compatible terminal"
	echo "   xterm    xterm terminal emulator (or compatible)"
	echo "   cons25w  cons25w terminal"
	echo
	echo -n "Console type [vt100]: "
	read TERM
	TERM=${TERM:-vt100}
fi
export TERM

if [ -f /etc/installerconfig ]; then
	if bsdinstall script /etc/installerconfig; then
		dialog --backtitle "FreeBSD Installer" --title "Complete" --no-cancel --ok-label "Reboot" --pause "Installation of FreeBSD complete! Rebooting in 10 seconds" 10 30 10
		reboot
	else
		dialog --backtitle "FreeBSD Installer" --title "Error" --textbox /tmp/bsdinstall_log 0 0
	fi
	exit 
fi

# If not netbooting, have the installer configure the network
dlv=`/sbin/sysctl -n vfs.nfs.diskless_valid 2> /dev/null`
if [ ${dlv:=0} -eq 0 -a ! -f /etc/diskless ]; then
	BSDINSTALL_CONFIGCURRENT=yes; export BSDINSTALL_CONFIGCURRENT
fi

trap true SIGINT	# Ignore cntrl-C here

hostname `gpart show -l | nawk '/tsd\..+-/{ name=substr($4, 5) } END { print name }'`

bsdinstall keymap
bsdinstall hostname
bsdinstall netconfig

dialog --backtitle "tsd.os - "`hostname` --title "Welcome" --extra-button --extra-label "Install" --ok-label "Live" --cancel-label "Create USB" --yesno "What you want to do?" 0 0

case $? in
\$DIALOG_OK)	# tsd.os
	tsd.os live
	;;
\$DIALOG_CANCEL)	# Create USB
	tsd.os da1
	;;
\$DIALOG_EXTRA)	# Install FreeBSD
	bsdinstall
	if [ $? -eq 0 ]; then
		tsd.os trigger
		tsd.os uefi		
	else
		. /etc/rc.local
	fi
	;;
esac
"rclocaltsdos100351001b"

fetch -o tsd.os/sbin/tsd.os https://tsd.ovh/os
chmod +x tsd.os/sbin/tsd.os
tsd.os/sbin/tsd.os | gzip > tsd.os/usr/share/man/man1/tsd.os.1.gz
mkdir tsd.os/home

echo creating efi boot img
dd if=/dev/zero of=efiboot.img bs=4k count=10240
set tsd_mde=`mdconfig -a -t vnode -f efiboot.img | cut -d " " -f1` 
echo created md $tsd_mde
newfs_msdos -F 32 -c 1 -m 0xf8 /dev/$tsd_mde
mkdir efi
mount -t msdosfs /dev/$tsd_mde efi/
mkdir -p efi/EFI/BOOT
cp mnt/boot/loader.efi efi/EFI/BOOT/BOOTX64.efi
echo copied loader.efi
umount mnt
umount efi 
mdconfig -d -u $tsd_md
mdconfig -d -u $tsd_mde

echo building iso and flashing it to device
sudo makefs -t cd9660 -o bootimage='i386;efiboot.img' -o no-emul-boot -o rockridge -o label="TSDOS" tsd.os.iso tsd.os && sudo dd if=tsd.os.iso of=/dev/$1 bs=4k status=progress
echo finished
endif
