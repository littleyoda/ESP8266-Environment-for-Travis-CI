#!/usr/bin/env bash

# we need bash 4 for associative arrays
if [ "${BASH_VERSION%%[^0-9]*}" -lt "4" ]; then
  echo "BASH VERSION < 4: ${BASH_VERSION}" >&2
  exit 1
fi

wget -c https://downloads.arduino.cc/arduino-1.8.3-linux64.tar.xz
tar xf arduino-1.8.3-linux64.tar.xz
mv arduino-1.8.3 $HOME/arduino_ide

export PATH="$HOME/arduino_ide:$PATH"

arduino --pref "boardsmanager.additional.urls=http://arduino.esp8266.com/stable/package_esp8266com_index.json" --install-boards esp8266:esp8266 --save-prefs
arduino --install-library USBHost 

arduino --board esp8266:esp8266:nodemcuv2 --pref build.path=$HOME/mybuild --pref "compiler.warning_level=default" --save-prefs 

# Fixing a Problem with the boards.txt
sed -i.bak 's/nodemcu.menu.FlashSize.4M3M/nodemcu/g' $HOME/.arduino15/packages/esp8266/hardware/esp8266/2.3.0/boards.txt
sed -i.bak 's/nodemcuv2.menu.FlashSize.4M3M/nodemcuv2/g' $HOME/.arduino15/packages/esp8266/hardware/esp8266/2.3.0/boards.txt

