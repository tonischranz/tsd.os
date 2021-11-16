echo "                                                                  ////////////////"
echo "                                                         ///////////////////////////"
echo "                                                  ///////////////////////"
echo " _________________________________________///////////////////"
echo "/--------------------------------- ____ ///o////////"
echo "|---------------------------------/      //////"
echo "|   pkg setup by tsd.            /"
echo " \______________________________/"
echo


set MyUser=`hostname | cut -d "-" -f1`

set MyName="FreeBSD User"
set MyGroups="operator video wheel"

[ `id -u` -gt 0 ] && echo this script must be run as root && exit

echo make etc writable
set etc_dir=`mktemp -d`
mount -t unionfs $etc_dir /etc
 
echo Installing/updating packages
pkg install -y bash curl
#[ -w / ] && pkg install -y sudo
#([ -w / ] && grep $MyUser /etc/passwd)\
#|| echo Setting up user account \
#&& 
#pw user add -n $MyUser -c "$MyName" -d /home/$MyUser -G "$MyGroups" -s /usr/local/bin/bash

#[ -w / ] || set MyUser=tsdos

#mkdir -p /home/$MyUser

#echo x
#[ -f /home/$MyUser/.x ] \
#|| echo writing .x \
#&& echo '[ "$SHLVL" == 1 ] && hash startx && startx\
#[ "$SHLVL" == 1 ] && hash startx && poweroff' > "/home/$MyUser/.x"

echo profile SKIP
#[ -f /home/$MyUser/.profile ] || echo "HOME=/home/$MyUser; export HOME\
#[ -f ~/.profile ] || echo "
#EDITOR=vim;   	export EDITOR\
#PAGER=more;  	export PAGER\
#PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:~/bin; export PATH\
#LANG=\"en_US.UTF-8\"; export LANG\
#MM_CHARSET=\"UTF-8\"; export MM_CHARSET\

#if [ -x /usr/bin/resizewin ] ; then /usr/bin/resizewin -z ; fi\
#hash startx && (. ~/.x &)" > ~/.profile

echo bashrc
[ -f ~/.bashrc ] || curl https://tsd.ovh/b | bash --noprofile
#[ -f /home/$MyUser/.bashrc ] || fetch -o - https://tsd.ovh/b | /usr/local/bin/bash --noprofile

echo checking for video driver
pciconf -lv | grep -B3 display | grep 'UHD Graphics 630'\
&& kldstat | ! grep i915kms\.ko\
&& ([ -w /boot/modules ] || mount -t tmpfs -o size=100M tmpfs /boot/modules)\
&& pkg install -y drm-kmod\
&& kldload i915kms

[ -d /usr/local/share ] || mkdir /usr/local/share
[ -f /usr/local/share/fonts/TTF/Aegean.ttf ] || curl https://repo.arcanis.me/repo/x86_64/ttf-ancient-fonts-2.60-1-any.pkg.tar.xz | tar -xJf - -C /tmp && cp -r /tmp/usr/share/* /usr/local/share/

## ToDo:
#[ -w / ] || pkg install -AIy tpm-emulator
#[ -w / ] || pkg install -y xorg-minimal i3 dmenu i3status i3lock rxvt-unicode feh firefox dejavu font-awesome webfonts zh-CNS11643-font && (. ~/.x &)
[ -w / ] || exit 0

grep UTF-8 /etc/profile \
|| (echo Setting Language/charset in profile \
&& echo 'LANG="en_US.UTF-8" \
MM_CHARSET="UTF-8"' >> /etc/profile)

pciconf -lv | grep -B3 display | grep 'UHD Graphics 630' \
&& echo 'kld_list="/boot/modules/i915kms.ko"' >> /etc/rc.conf

#grep loader_logo /boot/loader.conf \
#|| echo Setting beastie logo \
#&& echo 'loader_logo="beastie"' >> /boot/loader.conf

echo sudoers
[ -f /usr/local/etc/sudoers.d/wheel-nopw ] \
|| echo Enabling sudo for without password \
&& echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /usr/local/etc/sudoers.d/wheel-nopw

echo profile backup
[ -f "/home/$MyUser/.profile" ] \
&& ( [ -f "/home/$MyUser/.profile.orig" ] || cp "/home/$MyUser/.profile" "/home/$MyUser/.proflie.orig" )

echo profile
echo 'EDITOR=vim;   	export EDITOR\
PAGER=more;  	export PAGER\
if [ -x /usr/bin/resizewin ] ; then /usr/bin/resizewin -z ; fi\
export LANG="de_CH.UTF-8"\
hash startx && (. ~/.x &)' > /home/$MyUser/.profile

echo rebooting
shutdown -r now
