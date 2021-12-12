echo "                                                                  ////////////////"
echo "                                                         ///////////////////////////"
echo "                                                  ///////////////////////"
echo " _________________________________________///////////////////"
echo "/--------------------------------- ____ ///o////////"
echo "|---------------------------------/      //////"
echo "|   tsd.os Desktop               /"
echo " \______________________________/"
echo

echo x
[ -f /root/.x ] \
|| echo writing .x \
&& echo 'startx' > /root/.x

echo xinit
[ -f /root/.xinitrc ] \
|| echo writing .xinitrc \
&& echo 'setxkbmap ch; i3' > /root/.xinitrc

echo checking for video driver
pciconf -lv | grep -B3 display | grep 'UHD Graphics 630'\
&& ([ -w /boot/modules ] || mount -t tmpfs -o size=100M tmpfs /boot/modules)\
&& pkg install -y drm-kmod\
&& kldload drm
&& kldload i915kms

echo xorg i3 fonts tools
pkg install -y xorg-minimal i3 i3status dmenu rxvt-unicode xterm setxkbmap
pkg install -y noto-basic symbola dejavu zh-CNS11643-font
pkg install -y firefox feh
