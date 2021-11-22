#!/bin/csh
hash tsd.os || (hash fetch && mkdir -p ~/bin && fetch -o ~/bin/tsd.os https://tsd.ovh/os && chmod +x ~/bin/tsd.os)

set fbsd_root=https://download.freebsd.org/ftp/releases
set fbsd_arch=amd64
set fbsd_fam=amd64
set fbsd_rel=13.0

echo "FreeBSD live-system by tsd.                                       ////////////////"
echo "                                                         ///////////////////////////"
echo "                                                  ///////////////////////"
echo " _________________________________________///////////////////"
echo "/--------------------------------- ____ ///o////////"
echo "|---------------------------------/      //////"
echo "|   tsd.os                       /"
echo " \______________________________/"
echo

[ -n "$1" ] || echo "Usage: tsd.os live          - boot live system\
       tsd.os install       - install base pkgs\
       tsd.os ui            - install xorg,firefox\
       tsd.os libs          - install /usr/include /usr/lib\
       tsd.os <dev>         - create live usb"; echo

if ("$1" == install) then
	curl https://tsd.ovh/c | csh

else if ("$1" == libs) then
        mkdir /tmp/base
        mount -t tmpfs -o size=8G tmpfs /tmp/base/
        cd /tmp/base/
        curl https://download.freebsd.org/ftp/releases/$fbsd_arch/$fbsd_rel-RELEASE/base.txz -o base.txz && tar -xJf base.txz && mount -t unionfs /tmp/base/usr/include/ /usr/include/ &&  mount -t unionfs /tmp/base/usr/lib/ /usr/lib/ && echo overlayed lib/include

else if ("$1" == ui) then
	curl https://tsd.ovh/cu | csh

else if ("$1" == live) then
[ -w / ] && (echo / must be mounted readonly for live-system; exit 1)

mkdir -p /var/cache/pkg

echo checking for swap
gpart show -p | awk '/freebsd-swap/{system("swapon /dev/" $3)}'
swapinfo -h

echo creating tmpfs
mount -t tmpfs -o size=1512M tmpfs /var/db/pkg
mount -t tmpfs -o size=3512M tmpfs /var/cache/pkg
mount -t tmpfs -o size=12512M tmpfs /usr/local
mount -t tmpfs -o size=512M tmpfs /root

cp /etc/ssl/openssl.cnf /root
mount -t tmpfs -o size=20M tmpfs /etc/ssl
cp /root/openssl.cnf /etc/ssl
rm /root/openssl.cnf

pkg install -y curl

tsd.os install

else
[ -n "$1" ] || exit
[ -w /dev/$1 ] || echo device $1 must exist and be writable && exit

set tsd_dir=`mktemp -d`
mount -t tempfs -o size=4G tempfs $tsd_dir
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

dialog --backtitle "tsd.os - "`hostname` --title "Welcome" --extra-button --extra-label "Install FreeBSD" --ok-label "Desktop" --cancel-label "shell" --yesno "What you want to do?" 0 0

case $? in
$DIALOG_OK)	# tsd.os Desktop
	tsd.os live
	tsd.os ui
	;;
$DIALOG_CANCEL)	# tsd.os shell	
	tsd.os live
	;;
$DIALOG_EXTRA)	# Install FreeBSD
	bsdinstall
	;;
esac
"rclocaltsdos100351001b"

fetch -o tsd.os/sbin/tsd.os https://tsd.ovh/os
chmod +x tsd.os/sbin/tsd.os
tsd.os/sbin/tsd.os | gzip > tsd.os/usr/share/man/man1/tsd.os.1.gz
mkdir tsd.os/home
mkdir tsd.os/usr/ports


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
