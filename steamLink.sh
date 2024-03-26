#!/bin/bash

autostartService=steamlink_autostart.service
autostartServiceFile=~/.config/systemd/user/$autostartService

# Print help prompt
help() {
	echo "Valid Options:
    -e      Enable Steam Link
    -d      Disable Steam Link
    -a      Autostart function
    -h      Show this help text"
	exit
}

check_autostart() {
	service="[Unit]
Description=Steam Autostart Oneshot
Requires=plasma-kwin_x11.service

[Service]
Type=oneshot
ExecStart=$HOME/.scripts/steamLink.sh -a

[Install]
WantedBy=default.target"
	if [ ! "$service" = "$(cat $autostartServiceFile)" ]; then
		# echo "$service"
		echo "Updating service file..."
		echo "$service" >"$autostartServiceFile"
	fi
}

set_mon_dual() {
	xrandr --output DVI-D-0 --off --output HDMI-0 --off --output DP-0 --primary --mode 2560x1440 --pos 1050x0 --rotate normal --output DP-1 --off --output DP-2 --off --output DP-3 --mode 1680x1050 --pos 0x0 --rotate left --output DP-4 --off --output DP-5 --off
}

set_mon_single() {
	xrandr --output DVI-D-0 --off --output HDMI-0 --off --output DP-0 --primary --mode 2560x1440 --pos 0x0 --rotate normal --output DP-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-5 --off
}

ask_reboot() {
	read -r -p "The system will reboot now to apply changes, is that okay? [Y/n]: " rchoice
	case $rchoice in
	[yY]*) ;;
	[nN]*) echo "Cancelled Reboot" && exit ;;
	*) ;;
	esac
	echo "Rebooting..."
	sudo systemctl reboot
	exit
}

autostart() {
	set_mon_single
	steam
	exit
}

enable() {
	echo "Enabling Steam Link mode:
Enabling autologin, and steam autostart.
"
	sudo systemctl disable lemurs.service
	sudo systemctl enable sddm.service
	check_autostart
	systemctl --user enable "$autostartService"
	ask_reboot
}

disable() {
	echo "Disabling Steam Link mode:
Disabling autologin, and steam autostart.
"
	sudo systemctl disable sddm.service
	sudo systemctl enable lemurs.service
	set_mon_dual
	check_autostart
	systemctl --user disable "$autostartService"
	ask_reboot
}

# Get desired action
while getopts edah flag; do
	case "${flag}" in
	e) enable ;;
	d) disable ;;
	a) autostart ;;
	h) help ;;
	\?) echo "[ERROR] Invalid option provided." && help ;;
	esac
done

# If no options are given:
echo "No options provided"
help
