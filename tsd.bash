#! /bin/bash

echo
echo
echo creating backup files
[ -f ~/.bashrc ] && ! [ -f ~/.bashrc.orig ] && mv ~/.bashrc ~/.bashrc.orig
[ -f ~/.vimrc ] && ! [ -f ~/.vimrc.orig ] && mv ~/.vimrc ~/.vimrc.orig
[ -f ~/.bash_aliases ] && ! [ -f ~/.bash_aliases.orig ] && mv ~/.bash_aliases ~/.bash_aliases.orig
[ -f ~/.minttyrc ] && ! [ -f ~/.minttyrc.orig ] && mv ~/.minttyrc ~/.minttyrc.orig
[ -f ~/.symbols ] && ! [ -f ~/.symbols.orig ] && mv ~/.symbols ~/.symbols.orig

echo writing .bashrc
cat > ~/.bashrc << "bashrc100351001B"
# ~/.bashrc
# Author: Toni Schranz
# License: feel free to edit and redistribute

case $- in
    *i*) ;;
      *) return;;
esac

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
else
    color_prompt=
fi

#################################################
# options
#################################################

HISTCONTROL=ignoreboth
shopt -s histappend

HISTSIZE=1000
HISTFILESIZE=2000

shopt -s checkwinsize
shopt -s globstar

[ -z $USERNAME ] && USERNAME=$USER

#################################################
# prompt
#################################################

alias hash='hash 2>/dev/null'
color_prompt=yes

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}'
    PS1+=$'\[\e[34m\]\u '
#    PS1+=$'\[\e[93m\]@ '
    PS1+=$'\[\e[32m\]\h '
#    PS1+=$'\[\e[31m\]: '
    PS1+=$'\[\e[33m\]\w'
hash git && PS1+=$'\[\e[94m\]$(__git_ps1)'
    PS1+=$'\[\e[36m\] \$'
    PS1+=$'\[\e[0m\] '
else
    hash git && PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(__git_ps1)\$' ||  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$' 
fi
unalias hash
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

#################################################
# color support
#################################################

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

#################################################
# completions
#################################################

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

[[ $PS1 && -f /usr/local/share/bash-completion/bash_completion.sh ]] && \
source /usr/local/share/bash-completion/bash_completion.sh

[ -f /usr/local/share/git-core/contrib/completion/git-prompt.sh ] && . /usr/local/share/git-core/contrib/completion/git-prompt.sh
[ -f /usr/share/bash-completion/completions/git ] && . /usr/share/bash-completion/completions/git

#################################################
# aliases
#################################################

! [ -f ~/.bash_aliases ] && echo writing .bash_aliases && echo "
alias hash='hash 2>/dev/null'
alias ll='ls -alF'
alias la='ls -A'
alias cl='clear'

hash git && alias ga='git add'
hash git && alias gb='git branch'
hash git && alias gc='git commit'
hash git && alias gd='git diff'
hash git && alias gg='git log'
hash git && alias gl='git pull'
hash git && alias gm='git merge'
hash git && alias go='git checkout'
hash git && alias gp='git push'
hash git && alias gt='git mergetool'
hash git && alias gs='git status'

hash git && alias rb='git rebase'
hash git && alias mg='git merge'
hash git && alias co='git commit'

hash git && alias add='git add'
#alias branch='git branch'
#alias commit='git commit'
#alias fetch='git fetch'
hash git && alias pull='git pull'
hash git && alias merge='git merge'
hash git && alias push='git push'
hash git && alias rebase='git rebase'

hash dotnet && alias run='dotnet run'
hash dotnet && alias build='dotnet build'
hash dotnet && alias new='dotnet new'

#alias db='dotnet build'
#alias bd='dotnet build'

hash git && alias clone='git_clone_mxm'
hash git && alias cln='git_clone_ts'

alias sym='~/.symbols'
alias resetscripts='rm -f ~/.symbols'
alias updateall='hash curl && curl https://tsd.ovh/b | bash || (hash wget && wget -O - https://tsd.ovh/b | bash) || hash fetch && fetch -o - https://tsd.ovh/b | bash'
alias resetfiles='resetscripts; rm -f ~/.bash_aliases ~/.gitconfig ~/.vimrc && [ -f ~/.minttyrc ] && rm -f ~/.minttyrc'
alias resetconfig='resetfiles; rm -f ~/.x ~/.Xdefaults ~/.fehbg ~/.config/i3/config ~/.i3status.conf ~/.config/mc/ini; updateall'
alias leave='resetfiles; __restore_all; [ -f ~/.viminfo ] && rm ~/.viminfo; exit'

hash librecad && alias cad='librecad'
hash virtualbox && alias vbox='virtualbox'
hash vscode && ! hash code && alias code="vscode"

alias l='lynx'
alias c='curl'
alias v='vim -c \"vs.|vertical resize 32|wincmd w|bel term\"'
alias g='grep'
alias f='find -type f -print | xargs grep --color=auto'
## todo FreeBSD find
alias n='nano'
alias t='top'
alias j='jobs'
hash ranger && alias r='ranger'
alias h='host'
hash startx && alias x='startx'
alias s='start'
alias b='https'
alias e='explorer'
alias q='google'

#replacements
hash vim && alias vi='vim'
hash htop && alias top='htop'

#alias completions
hash git && __git_complete go _git_checkout
hash git && __git_complete gb _git_branch
hash git && __git_complete gd _git_diff
hash git && __git_complete gm _git_merge
hash git && __git_complete mg _git_merge
hash git && __git_complete rb _git_rebase
hash git && __git_complete gp _git_push
#hash git && __git_complete branch _git_branch
hash git && __git_complete merge _git_merge
hash git && __git_complete rebase _git_rebase
hash git && __git_complete push _git_push

unalias hash
" > ~/.bash_aliases

. ~/.bash_aliases

#################################################
# config files
#################################################

if [ -f /git-bash.exe ]; then

if [ -d /c/ProgramData/chocolatey/lib/dejavufonts ]; then
	[ -f ~/.minttyrc ] || echo "FontHeight=14
Transparency=medium
Scrollbar=none
Font=DejaVu Sans Mono
FontWeight=400
FontIsBold=no
BoldAsFont=no

ThemeFile=toni
" > ~/.minttyrc
fi

[ -f ~/.minttyrc ] || echo "FontHeight=14
Transparency=medium
Scrollbar=none
FontWeight=400
FontIsBold=no
BoldAsFont=no

ThemeFile=toni
" > ~/.minttyrc

[ -d ~/.mintty/ ] || mkdir ~/.mintty
[ -d ~/.mintty/themes/ ] || mkdir ~/.mintty/themes
[ -f ~/.mintty/themes/toni ] || echo "
ForegroundColour=   236, 240, 241
BackgroundColour=   24,   24,  24
CursorColour=       211,  84,   0
BoldBlack=          52,   73,  94
Black=              44,   62,  80
BoldRed=            231,  76,  60
Red=                192,  57,  43
BoldGreen=          46,  204, 113
Green=              39,  174,  96
BoldYellow=         241, 196,  15
Yellow=             243, 156,  18
BoldBlue=           142,  68, 173
Blue=               52,  152, 219
BoldMagenta=        155,  89, 182
Magenta=            142,  68, 173
BoldCyan=           26,  188,  15
Cyan=               122, 160, 133
BoldWhite=          236, 240, 241
White=              189, 195, 199
" > ~/.mintty/themes/toni

if [ $USERNAME == tschranz ]; then
[ -f ~/.gitconfig ] || echo "[user]
	email = toni@mxm.ch
	name = Toni Schranz - Maxomedia AG
[core]
	editor = vim
[merge]
	tool = vimdiff
" > ~/.gitconfig
else
[ -f ~/.gitconfig ] || echo "[core]
	editor = vim
[merge]
	tool = vimdiff
" > ~/.gitconfig
fi

! [ -f ~/.vimrc ] && echo writing .vimrc && echo "
syntax on

colo default

hi LineNr ctermfg=darkgray
hi phpDocCustomTags ctermfg=white
hi phpDefine ctermfg=darkblue
hi Special ctermfg=cyan
hi Comment ctermfg=darkgray
hi netrwTreeBar ctermfg=darkgray
hi PmenuSel ctermbg=yellow
hi Pmenu ctermfg=darkgray
hi Pmenu ctermbg=gray

let g:netrw_chgwin=2
let g:netrw_banner=0
let g:netrw_liststyle=3

inoremap <C-Space> <C-n>
noremap <C-\$> :vs.<CR>
noremap <C-Enter> :bel term<CR>

au filetypedetect BufNewFile,BufRead *.cshtml setf html
au filetypedetect BufNewFile,BufRead *.hbs setf html

set mouse=a
set number
set secure
set ex
set wildmenu
" > ~/.vimrc && echo written .vimrc
fi

if [ $USERNAME == toni ]; then
[ -f ~/.gitconfig ] || echo "[user]
	email = toni.schranz@gmail.com
	name = Toni Schranz
[core]
	editor = vim
[merge]
	tool = vimdiff
" > ~/.gitconfig
else
[ -f ~/.gitconfig ] || echo "[core]
	editor = vim
[merge]
	tool = vimdiff
" > ~/.gitconfig
fi

! [ -f ~/.vimrc ] && echo writing .vimrc && echo "
syntax on

colo default

hi LineNr ctermfg=darkgray
hi phpDocCustomTags ctermfg=white
hi phpDefine ctermfg=darkblue
hi Special ctermfg=cyan
hi Comment ctermfg=darkgray
hi netrwTreeBar ctermfg=darkgray
hi PmenuSel ctermbg=yellow
hi Pmenu ctermfg=darkgray
hi Pmenu ctermbg=gray

let g:netrw_chgwin=2
let g:netrw_banner=0
let g:netrw_liststyle=3

inoremap <C-@> <C-n>
noremap <C-H> :vs.<CR>
noremap <C-M> :bel term<CR>

inoremap <C-Space> <C-n>
noremap <C-CR> :bel term<CR>

au filetypedetect BufNewFile,BufRead *.cshtml setf html
au filetypedetect BufNewFile,BufRead *.hbs setf html

set mouse=a
set number
set secure
set ex
set wildmenu
" > ~/.vimrc

[ -f /git-bash.exe ] || [ -f ~/.Xdefaults ] || echo "
*background: #050505
*foreground: #dddddd
! Black + DarkGrey
*color0:  #000000
*color8:  #111111
! DarkRed + Red
*color1:  #c0392b
*color9:  #e74c3c
! DarkGreen + Green
*color2:  #27ae60
*color10: #2ecc71
! DarkYellow + Yellow
*color3:  #f39c12
*color11: #f1c40f
! DarkBlue + Blue
*color4:  #3498db
*color12: #8e44ad
! DarkMangenta + Mangenta
*color5:  #8e44ad
*color13: #9b59b6
!DarkCyan + Cyan
*color6:  #7aa085
*color14: #1abc0f
! LightGrey + White
*color7:  #bdc3c7
*color15: #ecf0f1
*scrollBar: false
URxvt.termName: rxvt-unicode-256color
URxvt.font: xft: DejaVu Sans Mono:size=12
" > ~/.Xdefaults

[ -f /git-bash.exe ] || [ -d ~/.config ] || mkdir ~/.config
[ -f /git-bash.exe ] || [ -d ~/.config/i3 ] || mkdir ~/.config/i3
[ -f /git-bash.exe ] || [ -f ~/.config/i3/config ] || echo $'
set $mod Mod4

font pango:DejaVu Sans Mono 9

# class                 border  backgr. text    indicator child_border
client.focused          #000000 #000000 #285577 #000000   #000000
client.focused_inactive #000000 #000000 #888888 #000000   #000000
client.unfocused        #000000 #222222 #888888 #000000   #000000
client.urgent           #000000 #900000 #ffffff #900000   #900000
client.placeholder      #000000 #0c0c0c #ffffff #000000   #0c0c0c

client.background       #050505

exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork

workspace_layout tabbed

set $refresh_i3status killall -SIGUSR1 i3status
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status
bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status

# Use Mouse+$mod to drag floating windows to their wanted position
floating_modifier $mod

# start a terminal
bindsym $mod+Return exec i3-sensible-terminal

# kill focused window
bindsym $mod+Shift+q kill

# start dmenu (a program launcher)
bindsym $mod+d exec dmenu_run
# There also is the (new) i3-dmenu-desktop which only displays applications
# shipping a .desktop file. It is a wrapper around dmenu, so you need that
# installed.
# bindsym $mod+d exec --no-startup-id i3-dmenu-desktop

# alternatively, you can use the cursor keys:
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# move focused windowexec urxvtght

# alternatively, you can use the cursor keys:
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

# split in horizontal orientation
bindsym $mod+Shift+h split h

# split in vertical orientation
bindsym $mod+Shift+v split v

# enter fullscreen mode for the focused container
bindsym $mod+f fullscreen toggle

# change container layout (stacked, tabbed, toggle split)
bindsym $mod+s layout stacking
bindsym $mod+t layout tabbed
bindsym $mod+a layout toggle split

# toggle tiling / floating
bindsym $mod+Shift+space floating toggle

# Define names for default workspaces for which we configure key bindings later on.
# We use variables to avoid repeating the names in multiple places.
set $ws1 1 \U1f39c East
set $ws2 2 \u2692 South
set $ws3 3 \u262e West
set $ws4 4 \U1f56e North
set $ws5 5 \U1f57f SE
set $ws6 6 \U1f5e2 SW
set $ws7 7 \U1f56d NE
set $ws8 8 \U1f585 NW
set $ws9 9 \U1f5ea SSW
set $ws10 10 \u2179 NNO

# switch to workspace
bindsym $mod+1 workspace number $ws1
bindsym $mod+2 workspace number $ws2
bindsym $mod+3 workspace number $ws3
bindsym $mod+4 workspace number $ws4
bindsym $mod+5 workspace number $ws5
bindsym $mod+6 workspace number $ws6
bindsym $mod+7 workspace number $ws7
bindsym $mod+8 workspace number $ws8
bindsym $mod+9 workspace number $ws9
bindsym $mod+0 workspace number $ws10

# move focused container to workspace
bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
bindsym $mod+Shift+3 move container to workspace number $ws3
bindsym $mod+Shift+4 move container to workspace number $ws4
bindsym $mod+Shift+5 move container to workspace number $ws5
bindsym $mod+Shift+6 move container to workspace number $ws6
bindsym $mod+Shift+7 move container to workspace number $ws7
bindsym $mod+Shift+8 move container to workspace number $ws8
bindsym $mod+Shift+9 move container to workspace number $ws9
bindsym $mod+Shift+0 move container to workspace number $ws10

# reload the configuration file
bindsym $mod+Shift+J reload
# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym $mod+Shift+P restart
# exit i3 (logs you out of your X session)
bindsym $mod+Shift+greater exec "i3-nagbar -t warning -m \'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.\' -B \'Yes, exit i3\' \'i3-msg exit\'"

# resize window (you can also use the mouse for that)
mode "resize" {
        # These bindings trigger as soon as you enter the resize mode

        # Pressing left will shrink the window’s width.
        # Pressing right will grow the window’s width.
        # Pressing up will shrink the window’s height.
        # Pressing down will grow the window’s height.
        bindsym h resize shrink width 10 px or 10 ppt
        bindsym t resize grow height 10 px or 10 ppt
        bindsym n resize shrink height 10 px or 10 ppt
        bindsym s resize grow width 10 px or 10 ppt

        # same bindings, but for the arrow keys
        bindsym Left resize shrink width 10 px or 10 ppt
        bindsym Down resize grow height 10 px or 10 ppt
        bindsym Up resize shrink height 10 px or 10 ppt
        bindsym Right resize grow width 10 px or 10 ppt

        # back to normal: Enter or Escape or $mod+r
        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym $mod+p mode "default"
}

bindsym $mod+p mode "resize"

# Start i3bar to display a workspace bar (plus the system information i3status
# finds out, if available)
bar {
        status_command i3status
}


exec --no-startup-id . ~/.fehbg
#exec --no-startup-id pcmanfm --desktop
exec --no-startup-id urxvt -e htop
exec --no-startup-id urxvt -e bash
exec --no-startup-id urxvt -e mc
' > ~/.config/i3/config

[ -f /git-bash.exe ] || [ -f ~/.i3status.conf ] || echo $'
general {
        colors = true
        interval = 1
}

order += "wireless _first_"
order += "ipv6"
order += "ethernet _first_"
#order += "battery all"
order += "cpu_usage"
order += "memory"
order += "disk /"
order += "tztime local"

wireless _first_ {
        format_up = "\u269b (%quality at %essid) %ip"
        format_down = ""
}

ethernet _first_ {
        format_up = "\U1f5a7 %ip (%speed)"
        format_down = ""
}

ipv6 {
        format_up = "\U1f578 %ip"
        format_down = ""
}

battery all {
        format = "%status %percentage %remaining"
}

disk "/" {
        format = "\U1f4be %avail"
}

load {
        format = "%5min"
}

memory {
        format = "\u2620 %used/%available"
        threshold_degraded = "1G"
        format_degraded = "\U1f571 < %available"
}

tztime local {
        format = "\U1f5d3 %Y-%m-%d %H:%M:%S \U1f551 "
}

cpu_usage {
        format = "%cpu0 %cpu1 %cpu2 %cpu3 %cpu4 %cpu5"
}
' > ~/.i3status.conf

[ -f /git-bash.exe ] || [ -d ~/.config/mc ] || mkdir ~/.config/mc
[ -f /git-bash.exe ] || [ -f ~/.config/mc/ini ] || echo '[Midnight-Commander]
skin=nicedark
use_internal_edit=false
' > ~/.config/mc/ini

[ -f /git-bash.exe ] || [ -f ~/.fehbg ] || echo '#!/bin/sh
[ -f ~/.bg.png ] && feh --no-fehbg --bg-tile '~/.bg.png'
[ -f ~/.bg.png ] || ([ -f ~/bg.jpeg ] && feh --no-fehbg --bg-tile '~/bg.jpeg')
' > ~/.fehbg

#################################################
# shell scripts
#################################################

[ -f ~/.symbols ] || echo '#! /bin/bash
#todo: 
#currently displaying 26xx, 27xx
for i in {9728..10239};
do
	c=`printf U+%x $i`;
	printf $c;
	printf " "; 
	printf ${c/U+/"\U"};
	printf $" \t"; 
done
echo' > ~/.symbols

#################################################
# shell functions
#################################################

alias hash='hash 2>/dev/null'

! hash start && hash firefox && function start () { firefox $*; }
! hash start && hash chromium && function start () { chromium $*; }
! hash explorer && hash nautilus && function explorer () { nautilus $*; }

function https () { start "https://$*"; }
function google () { https "google.com/?q=$*"; }

[ `id -u` -gt 0 ] || function xi ()
{
	pkg=$4; [ -z "$pkg" ] && pkg=$3; 
	hash $3 || ! hash $1 || alias $3="echo installing $3 with $1 && $1 $2 $pkg && unalias $3; $3"; 
}

[ `id -u` -gt 0 ] && function xi () 
{
	pkg=$4; [ -z "$pkg" ] && pkg=$3; 
	hash $3 || ! hash $1 || ! hash sudo || alias $3="echo installing $3 with $1 && sudo $1 $2 $pkg && unalias $3; $3"; 
}

function aai () { xi apk "add -y" $*; }
function ai () { xi apt "install -y" $*; }
function si () { xi snap "install -y" $*; }
function pkgi () { xi pkg "install -y" $*; }

function __restore_all {
	[ -f ~/.bashrc.orig ] && [ -f ~/.bashrc ] && mv -b ~/.bashrc ~/.bashrc.bkp && mv ~/.bashrc.orig ~/.bashrc
	[ -f ~/.vimrc.orig ] && ! [ -f ~/.vimrc ] && mv ~/.vimrc.orig ~/.vimrc
	[ -f ~/.bash_aliases.orig ] && ! [ -f ~/.bash_aliases ] && mv ~/.bash_aliases.orig ~/.bash_aliases
	[ -f ~/.minttyrc.orig ] && ! [ -f ~/.minttyrc ] && mv ~/.minttyrc.orig ~/.minttyrc
	[ -f ~/.symbols.orig ] && ! [ -f ~/.symbols ] && mv ~/.symbols.orig ~/.symbols
}

function git_clone_mxm () 
{ 
	cd $REPO_HOME; 
	git clone https://bitbucket.org/maxomedia/$* 2>~/.mxm_clone; 
	cd $(cat ~/.mxm_clone | grep Cloning | cut -d\' -f 2); 
	rm ~/.mxm_clone; 
	git checkout develop;
}

function git_clone_ts () 
{ 
	cd $REPO_HOME; 
	git clone https://github.com/tonischranz/$* 2>~/.ts_clone.$1; 
	cd $(cat ~/.ts_clone.$1 | grep Cloning | cut -d\' -f 2); 
	rm ~/.ts_clone.$1; 
	git checkout develop;
}


function git_work_mxm () 
{ 
	cd $REPO_HOME; 
	#find repo
	#clone if not present
	#cd there
	
	#git checkout -b jira/$1;
}

#################################################
# tools
#################################################

! hash dotnet && [  -d ~/.dotnet ] && PATH=$PATH:~/.dotnet 
! hash php && [  -d ~/.php ] && PATH=$PATH:~/.php 

aai curl
aai git
aai vim
aai lynx
aai php
aai npm
aai ranger
aai mc
aai htop

ai curl
ai git
ai vim
ai lynx
ai php
ai npm
ai ranger
ai mc
ai htop

pkgi curl
pkgi git
pkgi vim
pkgi lynx
pkgi php
pkgi npm
pkgi ranger
pkgi mc
pkgi htop

if [ -f /git-bash.exe ]; then
	hash php || alias php='curl https://windows.php.net/downloads/releases/latest/php-7.4-nts-Win32-vc15-x64-latest.zip -o ~/.php.zip && unzip ~/.php.zip -d ~/.php && rm ~/.php.zip && PATH=$PATH:~/.php && php'
	hash dotnet || alias dotnet='curl https://dotnet.microsoft.com/download/dotnet-core/scripts/v1/dotnet-install.ps1 | powershell && unalias dotnet && PATH=$PATH:~/AppData/Local/Microsoft/dotnet && dotnet'
elif hash curl; then
	hash dotnet || alias dotnet='curl https://dotnet.microsoft.com/download/dotnet-core/scripts/v1/dotnet-install.sh | bash && unalias dotnet && PATH=$PATH:~/.dotnet && dotnet'
fi

#################################################
# utilities
#################################################

#hash g213-led || ! hash apt || ! hash sudo || (echo Installing g810-led for Logitech G213 Prodigy Keyboard && sudo apt install -y g810-led --no-install-recommends)
hash g213-led && g213-led --list-keyboards >/dev/null && g213-led -r 1 000088 && g213-led -r 2 008800 &&  g213-led -r 3 888800 && g213-led -r 4 008888 && g213-led -r 5 888888
#hash g213-led && g213-led --list-keyboards >/dev/null && g213-led -r 1 0000ff && g213-led -r 2 00ff00 &&  g213-led -r 3 ffff00 && g213-led -r 4 00ffff && g213-led -r 5 ffffff

si code
si gimp
si inkscape
si chromium



ai feh
ai firefox
ai gimp
ai inkscape
ai librecad
ai lbreoffice-calc
ai virtualbox virtualbox-qt
ai g213-led g810-led
ai fontforge
ai startx "xinit i3 xserver-xorg fonts-dejavu ttf-font-awesome ttf-ancient-fonts fonts-cns11643"

aai feh
aai firefox
aai gimp
aai inkscape
aai librecad
aai lbreoffice-calc
aai fontforge
aai chromium-browser
xi setup-xorg-base i3wm startx "ttf-dejavu ttf-font-awesome ttf-ancient-fonts xf86-video-fbdev rxvt-unicode"

pkgi vscode
pkgi gimp
pkgi inkscape
pkgi chrome chromium
pkgi feh
pkgi firefox
pkgi gimp
pkgi inkscape
pkgi librecad
pkgi lbreoffice-calc
pkgi bhyve
pkgi docker
pkgi virtualbox virtualbox-ose
pkgi fontforge
pkgi pcmanfm "pcmanfm-qt file-roller"
pkgi pitivi
pkgi openshot
pkgi shotcutter
pkgi vid.stab
pkgi startx "xorg-minimal i3 dmenu i3status i3lock rxvt-unicode feh firefox dejavu font-awesome webfonts zh-CNS11643-font"
pkgi rdesktop
pkgi freerdp
pkgi xrdp

[ "$TERM" == linux ] && ! ps u | [ `grep startx -c` -gt 1 ] && hash startx && startx

unalias hash
unset -f ai si

#################################################
# end
#################################################

REPO_HOME=~
[ -f /git-bash.exe ] && [ -d ~/source/repos ] && REPO_HOME=~/source/repos
[ -f /git-bash.exe ] && [ -d /h ] && [ -d /d/git ] && REPO_HOME=/d/git
[ `pwd` == '/' ] && cd
[ `pwd` == '/h' ] && cd $REPO_HOME

bashrc100351001B

[ -f ~/.bg.png ] || hash curl && curl -o ~/.bg.png https://tsd.ovh/bp
[ -f ~/.bg.png ] || hash wget && wget -O ~/.bg.png https://tsd.ovh/bp
[ -f ~/.bg.png ] || hash fetch && fetch -o ~/.bg.png https://tsd.ovh/bp

echo
exec bash -ic "
echo
echo differences
echo
echo .bashrc && [ -f ~/.bashrc.orig ] && diff ~/.bashrc.orig ~/.bashrc && rm -f ~/.bashrc.orig
echo .vimrc && [ -f ~/.vimrc.orig ] && diff ~/.vimrc.orig ~/.vimrc && rm -f ~/.vimrc.orig
echo .bash_aliases && [ -f ~/.bash_aliases.orig ] && diff ~/.bash_aliases.orig ~/.bash_aliases && rm -f ~/.bash_aliases.orig
echo .minttyrc && [ -f ~/.minttyrc.orig ] && diff ~/.minttyrc.orig ~/.minttyrc &&  rm -f ~/.minttyrc.orig
[ -f ~/.symbols.orig ] && diff ~/.symbols.orig ~/.symbols && rm -f ~/.symbols.orig
"
