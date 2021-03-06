#!/bin/bash

# yo this is a test comment

export NCURSES_NO_UTF8_ACS=1 

backtitle="Graham's Crappy Server Launcher"
title="Installer"

INPUT=/tmp/menu.sh.$$

OUTPUT=/tmp/output.sh.$$

trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM

#read -p "Enter desired install location: (eg. /home/user/server) " serverpath
dialog --backtitle "$backtitle" --title "$title" \
--inputbox "Enter Desired install location" 8 60 2>"${INPUT}"

if [ "$?" = "0" ]; then
	serverpath=$(<"${INPUT}")
else
	exit 1
fi

export serverdir=$serverpath

if [ ! -d "$serverpath" ]; then
  echo "Making serverdir..."
  mkdir $serverpath
fi

#read -p "Enter desired server name: " servername
dialog --backtitle "$backtitle" --title "$title" \
--inputbox "Enter Desired server name:" 8 20 2>"${INPUT}"

if [ "$?" = "0" ]; then
	servername=$(<"${INPUT}")
else
	exit 1
fi

clear

#echo "Copying files..."
sudo cp minecraftserver.sh /usr/bin/minecraftserver
sudo sed -i 's@<serverpath>@'"$serverpath"'@' /usr/bin/minecraftserver
sudo chmod +x /usr/bin/minecraftserver

sudo sed -i 's@<servername>@'"$servername"'@' /usr/bin/minecraftserver

cp package.json $serverpath/package.json
cp info.js $serverpath/info.js
cp restart.sh $serverpath/restart.sh
chmod +x $serverpath/restart.sh

cd $serverpath
clear
npm install
minecraftserver update

dialog --backtitle "$backtitle" --title "$title" \
	--yesno "Accept eula?" 8 50
eula=$?
if [ $eula = 0 ]; then 
	sed -i 's/eula=false/eula=true/g' eula.txt && read -p "Eula Accepted!"
fi

[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT
minecraftserver

