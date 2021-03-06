#!/usr/bin/env bash

# we need bash 4 for associative arrays
if [ "${BASH_VERSION%%[^0-9]*}" -lt "4" ]; then
  echo "BASH VERSION < 4: ${BASH_VERSION}" >&2
  exit 1
fi

mkdir $HOME/mybuild
mkdir $HOME/releases

# Install Arduino to ~/arduino_ide
wget -c https://downloads.arduino.cc/arduino-1.8.3-linux64.tar.xz
tar xvf arduino-1.8.3-linux64.tar.xz
mv arduino-1.8.3 $HOME/arduino_ide
export PATH="$HOME/arduino_ide:$PATH"


arduino --pref "boardsmanager.additional.urls=http://arduino.esp8266.com/stable/package_esp8266com_index.json" --install-boards esp8266:esp8266:2.4.1 --save-prefs
arduino --install-library USBHost 

# Default to NodeMCU V2
arduino --board esp8266:esp8266:nodemcuv2 --pref build.path=$HOME/mybuild --pref "compiler.warning_level=default" --save-prefs 

# Fixing a Problem with the boards.txt
# ld: cannot open linker script file {build.flash_ld}: No such file or directory
# choosing "4M (3M SPIFFS)" Configuration
file=`find $HOME/.arduino15/packages/esp8266/ -type f -name 'boards.txt'`
echo Changing $file

sed -i.bak 's/nodemcu.menu.FlashSize.4M3M/nodemcu/g' $file
sed -i.bak 's/nodemcuv2.menu.FlashSize.4M3M/nodemcuv2/g' $file
sed -i.bak 's/d1_mini.menu.FlashSize.4M3M/d1_mini/g' $file
sed -i.bak 's/esp8285.menu.FlashSize.1M128/esp8285/g' $file

for i in nodemcu nodemcuv2 d1_mini esp8285
do
	echo "${i}.build.f_cpu=80000000L" >> $file
done

function lwip()
{
	file=`find $HOME/.arduino15/packages/esp8266/ -type f -name 'boards.txt'`
	for i in nodemcu nodemcuv2 d1_mini esp8285
	do
		sed -i.bak "s/${i}.menu.LwIPVariant.${1}/${i}/g" $file
	done
}

function replaceStringWithGitHubTag() {
	cd "$3"
	gitversion=`git describe --tags`
	sed -i.bak "s#${2}#${gitversion}#g" $1
}

function build()
{
	local ino=$1
	local board=$2
	local inoFilename=`basename "$1"`	
	local filename=`basename "$inoFilename" .ino`	
	echo $ino $board	
	rm -rf $HOME/mybuild/*
	cd $HOME/arduino_ide
	./arduino --board esp8266:esp8266:$board  --save-prefs
  	./arduino --verify "$ino"
  	ls -l $HOME/mybuild
  	ls -l $HOME/releases
  	cp $HOME/mybuild/"${inoFilename}.bin" "$HOME/releases/${filename} ${board}.bin"
}
	