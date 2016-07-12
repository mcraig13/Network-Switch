# Network-Switch

This is a script that will be able to change the Raspberry Pi between Wireless Hotspot mode and default WiFi mode.

The Wireless Hotspot mode will allow it to act like a router, allowing other devices to connect to it or act as a go between for other devices.

This is all done using functions in a bash script but can be potentially expanded upon later into a working python executable.

Compatible with:
  - Raspberry Pi Zero
  - Raspberry Pi 1
  - Raspberry Pi 2
  - Raspberry Pi 3

Requires the built in WiFi of the Pi 3 or a dongle attached.

If a dongle is used then you can check that it supports hotspotting by doing the following:
  sudo apt-get install iw
  iw list | less
  
  Check in the iw list for the entry relating to AP mode:
    Supported interface modes:
      - IBSS
      - managed
      - AP          <---
      - AP/VLAN     <---
      - WDS
      - monitor
      - mesh point
      
Further development can have checks in place that will do this for you.
