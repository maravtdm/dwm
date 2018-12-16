#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps
if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi
if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi
if [ -f $userresources ]; then
    xrdb -merge $userresources
fi
if [ -f $usermodmap ]; then
    xmodmap $usermodmap
fi

# D-Bus
if which dbus-launch >/dev/null && test -z "$DBUS_SESSION_BUS_ADDRESS"; then
        eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi
 
## Statusbar
sp="$(echo -ne " ")"

print_power() {
	status="$(cat /sys/class/power_supply/ADP1/online)"
  battery="$(cat /sys/class/power_supply/BAT0/capacity)"
  timer="$(acpi -b | grep "Battery" | awk '{print $5}' | cut -c 1-5)"
  if [ "${status}" == 1 ]; then
    echo -ne "${sp}  ${battery}%"
  else
	  echo -ne "${sp} ${battery}% (${timer})"
  fi
}

print_wifiqual() {
  wifiessid="$(/sbin/iwconfig 2>/dev/null | grep ESSID | cut -d: -f2)"
  wifiawk="$(echo $wifiessid | awk -F',' '{gsub(/"/, "", $1); print $1}')"
  wificut="$(echo $wifiawk | cut -d' ' -f1 | cut -d'/' -f1)"
  echo -ne "${sp} ${wificut}"
}

print_volume(){
    mix=`amixer get Master | tail -1`
    vol="$(amixer get Master | tail -n1 | sed -r 's/.*\[(.*)%\].*/\1/')"
    if [[ $mix == *\[off\]* ]];then
      echo -e "${sp} OFF"
    elif [[ $mix == *\[on\]* ]]; then
      echo -e "${sp} ${vol}%"
    else
      echo -e "${sp} ---"
    fi
}

print_datetime() {
  datetime="$(date "+%H:%M %a%d %b")"
  echo -ne "${sp} ${datetime}"
}

while true; do
xsetroot -name "$(print_power)$(print_wifiqual)$(print_volume)$(print_datetime)"
done &

setxkbmap fr
feh --bg-scale $HOME/.config/i3/classic.png & 
# Touchpad off
xinput disable 16
xinput disable 17
# Power button off
xinput disable 6


# Start the window manager:
exec /usr/local/bin/dwm

