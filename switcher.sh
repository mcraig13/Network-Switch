#!/bin/bash

wifiFile="interfaces-wifi"
hotspotFile="interfaces-hotspot"
hostapdFile="hostapd.conf"


function setToStatic {
	staticIP=$(whiptail --inputbox "Enter the IP you wish to set to" 10 30 3>&1 1>&2 2>&3)
	sudo rm /etc/network/interfaces
	sudo echo "auto lo
	iface lo inet loopback
	iface eth0 inet dhcp
	allow hotplug wlan0
	iface wlan0 inet static
	address $staticIP
	netmask 255.255.255.0" >> /etc/network/interfaces

	whiptail --ok-button Done --msgbox "Static IP has been set to $staticIP" 10 30
}

function setToWifi {
    	sudo rm /etc/network/interfaces
    	sudo cp interfaces-wifi /etc/network/interfaces
	whiptail --title "Network Switch" --msgbox "Network has been set to Wifi. Choose Ok to continue." 10 60
}

function createWifi {
    	echo "auto lo
	iface lo inet loopback
	iface eth0 inet dhcp
	allow-hotplug wlan0
	auto wlan0
	iface wlan0 inet manual
	iface default inet dhcp
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

function setHostapd {
	sudo rm /etc/hostapd/hostapd.conf
	sudo cp hostapd.conf /etc/hostapd
}

function createHostapd {
	echo "interface=wlan0
	driver=nl80211
	ssid=RPiHotspot
	country_code=GB
	hw_mode=g
	channel=6
	ieee80211n=1
	macaddr_acl=0
	auth_algs=1
	ignore_broadcast_ssid=0
	wpa=2
	wpa_passphrase=raspberry
	wpa_key_mgmt=WPA-PSK
	wpa_pairwise=TKIP
	rsn_pairwise=CCMP" >> hostapd.conf
}

function deleteHostapd {
	sudo rm /etc/hostapd/hostapd.conf
}

function restartHostapd {
	sudo service hostapd stop
	sudo service hostapd start
}

function reboot {
	if (whiptail --title "Network Switch" --yesno "Network has been set to hotspot, would you like to reboot now?" 10 60) then
    		sudo reboot
	else
		echo "No hotspot for you then."
	fi
}

function restartNetwork {
	sudo ifdown wlan0 && sudo ifup wlan0
}

OPTION=$(whiptail --title "Network Switch" --menu "Choose your option" 15 60 4 \
"1" "Wifi" \
"2" "Hotspot" \
"3" "Set Static IP" \
"4" "Restart Network" 3>&1 1>&2 2>&3)

if [ $OPTION = 1 ]; then
	if [ -f "$wifiFile" ]; then
		setToWifi
		deleteHostapd
        	restartNetwork
  	else
        	createWifi
        	setToWifi
		deleteHostapd
        	restartNetwork
    	fi
elif [ $OPTION = 2 ]; then
	if [ ! -f "$hotspotFile" ]; then
        	createHotspot
	elif [ ! -f "$hostapdFile" ]; then
		createHostapd
    	elif [ -f "$hotspotFile" ] && [ -f "$hostapdFile" ]; then
        	setToHotspot
		setHostapd
		restartNetwork
		restartHostapd
    	fi
elif [ $OPTION = 3 ]; then
	setToStatic
	restartNetwork
elif [ $OPTION = 4 ]; then
    	restartNetwork
    	whiptail --title "Network Restarted" --msgbox "Network has been restarted." 10 60
else
   	whiptail --title "Cancelled" --msgbox "Operation cancelled. Choose Ok to continue." 10 60
fi
