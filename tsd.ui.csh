echo "                                                                  ////////////////"
echo "                                                         ///////////////////////////"
echo "                                                  ///////////////////////"
echo " _________________________________________///////////////////"
echo "/--------------------------------- ____ ///o////////"
echo "|---------------------------------/      //////"
echo "|   tsd.os Desktop               /"
echo " \______________________________/"
echo

echo checking for video driver
pciconf -lv | grep -B3 display | grep 'Intel Corporation'\
&& ([ -w /boot/modules ] || mount -t tmpfs -o size=100M tmpfs /boot/modules)\
&& pkg install -y drm-kmod\
&& kldload drm
&& kldload i915kms

echo lxqt sddm xorg-minimal fonts tools
pkg install -y lxqt sddm xorg-minimal setxkbmap automount
#pkg install -y xorg-minimal i3 i3status dmenu rxvt-unicode xterm setxkbmap
pkg install -y symbola junicode zh-CNS11643-font
#pkg install -y dejavu
pkg install -y chromium
#pkg install -y firefox feh
