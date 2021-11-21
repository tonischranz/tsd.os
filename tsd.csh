echo "                                                                  ////////////////"
echo "                                                         ///////////////////////////"
echo "                                                  ///////////////////////"
echo " _________________________________________///////////////////"
echo "/--------------------------------- ____ ///o////////"
echo "|---------------------------------/      //////"
echo "|   pkg setup by tsd.            /"
echo " \______________________________/"
echo

[ `id -u` -gt 0 ] && echo this script must be run as root && exit

echo make etc writable
set etc_dir=`mktemp -d`
mount -t unionfs $etc_dir /etc
 
echo Installing/updating packages
pkg install -y bash curl

echo changing root shell
pw usermod root -s /usr/local/bin/bash

echo writing .profile
[ -f /root/.profile ] || echo '\
EDITOR=vim;   	export EDITOR\
PAGER=more;  	export PAGER\
PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:~/bin; export PATH\
LANG="en_US.UTF-8"; export LANG\
MM_CHARSET="UTF-8"; export MM_CHARSET\
\
[ -f ~/.bashrc ] || curl https://tsd.ovh/b | bash\
\
if [ -x /usr/bin/resizewin ] ; then /usr/bin/resizewin -z ; fi\
hash startx || bash\
hash startx && (. ~/.x &)' > /root/.profile

echo setting up ttys
echo 'console	none				unknown	off insecure\
#\
ttyv0	"/usr/libexec/getty autologin"	xterm	onifexists secure\
# Virtual terminals\
ttyv1	"/usr/libexec/getty Pc"		xterm	onifexists secure\
ttyv2	"/usr/libexec/getty Pc"		xterm	onifexists secure\
ttyv3	"/usr/libexec/getty Pc"		xterm	onifexists secure\
ttyv4	"/usr/libexec/getty Pc"		xterm	onifexists secure\
ttyv5	"/usr/libexec/getty Pc"		xterm	onifexists secure\
ttyv6	"/usr/libexec/getty Pc"		xterm	onifexists secure\
ttyv7	"/usr/libexec/getty Pc"		xterm	onifexists secure\
ttyv8	"/usr/local/bin/xdm -nodaemon"	xterm	off secure\
# Serial terminals\
# The dialup keyword identifies dialin lines to login, fingerd etc.\
ttyu0	"/usr/libexec/getty 3wire"	vt100	onifconsole secure\
ttyu1	"/usr/libexec/getty 3wire"	vt100	onifconsole secure\
ttyu2	"/usr/libexec/getty 3wire"	vt100	onifconsole secure\
ttyu3	"/usr/libexec/getty 3wire"	vt100	onifconsole secure\
# Dumb console\
dcons	"/usr/libexec/getty std.9600"	vt100	off secure' > /etc/ttys


pkg install -y vim mc

grep UTF-8 /etc/profile \
|| (echo Setting Language/charset in profile \
&& echo 'LANG="en_US.UTF-8" \
MM_CHARSET="UTF-8"' >> /etc/profile)
