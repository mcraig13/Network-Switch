#!/bin/bash

wifiFile="interfaces-wifi"
hotspotFile="interfaces-hotspot"

function setToWifi {
    	sudo rm /etc/network/interfaces
    	sudo cp interfaces-wifi /etc/network/interfaces
	whiptail --title "Network Switch" --msgbox "Network has been set to Wifi. Choose Ok to continue." 10 60
}

function createWifi {
    	echo "auto lo
	iface lo inet loopback
	iface eth0 inet manual
	allow-hotplug wlan0
	iface wlan0 inet static
        address 192.168.0.40
        netmask 255.255.255.0
    	wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf" >> interfaces-wifi
}

function setToHotspot {
	sudo rm /etc/network/interfaces
    	sudo cp interfaces-hotspot /etc/network/interfaces
}

function createHotspot {
    	echo "auto lo
	allow-hotplug wlan0
	iface wlan0 inet static
        address 10.5.5.1
        netmask 255.255.255.0" >> interfaces-hotspot
}

function reboot {
	if (whiptail --title "Network Switch" --yesno "Network has been set to hotspot, would you like to reboot now?" 10 60) then
    		sudo reboot
	else
		echo "No hotspot for you then."
	fi
}

function restartNetwork {
    	sudo /etc/init.d/networking stop
	sudo systemctl daemon-reload
	sudo /etc/init.d/networking start
}

OPTION=$(whiptail --title "Network Switch" --menu "Choose your option" 15 60 4 \
"1" "Wifi" \
"2" "Hotspot" \
"3" "Restart Network" 3>&1 1>&2 2>&3)

if [ $OPTION = 1 ]; then
	if [ -f "$wifiFile" ]; then
		setToWifi
        restartNetwork
  	else
        createWifi
        setToWifi
        restartNetwork
    fi
elif [ $OPTION = 2 ]; then
    if [ -f "$hotspotFile" ]; then
        setToHotspot
        reboot
    else
        createHotspot
        setToHotspot
        reboot
    fi
elif [ $OPTION = 3 ]; then
    restartNetwork
    whiptail --title "Network Restarted" --msgbox "Network has been restarted. Now you will need to connect to a Wifi network else it will fail. Whether it says it's connected or not it's probably lying to you. /...End of rant.../" 10 60
else
    whiptail --title "Cancelled" --msgbox "Operation cancelled. Choose Ok to continue." 10 60
fi
