#!/usr/bin/env bash

APP_NAME="LusionMagic"
APP_REPO="robsecord"

APP_VERSION_STR="v0.1.11"
APP_VERSION=${APP_VERSION_STR:1:6}

NODE_VERSION="12.14.1"
NODE_VERSION_MAJOR=${NODE_VERSION:0:2}

echo " "
echo "======= Lusion-Installer ======="
echo "${APP_NAME}: v${APP_VERSION}"
echo "Node: v${NODE_VERSION}"
echo " "

echo "Lusion-Installer: Updating System Sources.."
sudo apt update
sudo apt-get update

echo "Lusion-Installer: Upgrading System Dependencies.."
sudo apt-get upgrade -y 2>&1
sudo apt-get dist-upgrade 2>&1

# Install Xserver, LXDE-gui, lightdm and other nescessary things
echo "Lusion-Installer: Installing extras.."
sudo apt-get install raspberrypi-ui-mods firefox-esr build-essentials -y

# Install Node 12.x
echo "Lusion-Installer: Downloading NodeJS v${NODE_VERSION}.."
wget "https://nodejs.org/dist/latest-v${NODE_VERSION_MAJOR}.x/node-v${NODE_VERSION}-linux-armv7l.tar.gz"
echo "Lusion-Installer: Extracting NodeJS.."
tar -xzf "node-v${NODE_VERSION}-linux-armv7l.tar.gz"
echo "Lusion-Installer: Moving NodeJS.."
sudo cp -R "node-v${NODE_VERSION}-linux-armv7l/*" /usr/local/

# Install Electron
#echo "Lusion-Installer: Installing Electron.."
#npm install -g electron --unsafe-perm=true --allow-root --arch=armv7l --platform=linux

# Install GIT
#echo "Lusion-Installer: Installing GIT.."
#sudo apt-get install -y git

# Install PM2
#echo "Lusion-Installer: Installing PM2.."
#sudo npm install -y -g pm2

# Install Lusion App
#cd ~
#echo "Lusion-Installer: Cloning Repo..."
#if git clone --depth=1 "https://github.com/${APP_REPO}/${APP_NAME}.git"; then
#    echo "Lusion-Installer: Cloning repo done!"
#else
#    echo "Lusion-Installer: Unable to clone repo."
#    exit;
#fi
echo "Lusion-Installer: Downloading ${APP_NAME}.."
wget "https://github.com/${APP_REPO}/${APP_NAME}/releases/download/v${APP_VERSION}/${APP_NAME}-linux-armv7l-${APP_VERSION}.zip"
echo "Lusion-Installer: Extracting ${APP_NAME}.."
unzip "${APP_NAME}-linux-armv7l-${APP_VERSION}.zip" -d "~/${APP_NAME}"


#cd ~/LusionMagic/ || exit
#echo "Lusion-Installer: Installing Dependencies..."
#if npm install ; then
#    echo "Lusion-Installer: Dependencies installed!"
#else
#    echo "Lusion-Installer: Unable to install dependencies."
#    exit;
#fi

# Cleanup
echo "Lusion-Installer: Cleaning up after install.."
rm -rf node-v*
rm -rf "${APP_NAME}-linux-armv7l-${APP_VERSION}.zip"
#sudo apt autoremove --silent

echo "======= Lusion-Installer Complete! ======="
echo " "
