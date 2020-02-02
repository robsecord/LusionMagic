#!/usr/bin/env bash

APP_NAME="LusionMagic"
APP_REPO="robsecord"

APP_VERSION_STR="v0.1.12"
APP_VERSION=${APP_VERSION_STR:1:6}

NODE_VERSION="12.14.1"
NODE_VERSION_MAJOR=${NODE_VERSION:0:2}

spacing() {
    echo " "
    echo " "
}

spacing
echo "======= Lusion-Installer ======="
echo "${APP_NAME}: v${APP_VERSION}"
echo "Node: v${NODE_VERSION}"
echo " "

spacing
echo "Lusion-Installer: Updating System Sources.."
sudo apt update
sudo apt-get update

spacing
echo "Lusion-Installer: Upgrading System Dependencies.."
sudo apt-get upgrade -y 2>&1
sudo apt-get dist-upgrade -y 2>&1

# Install Xserver, LXDE-gui, lightdm and other nescessary things
spacing
echo "Lusion-Installer: Installing extras.."
sudo apt-get install raspberrypi-ui-mods firefox-esr build-essentials -y
#  libgles2, libgl-mesa-dri, libglew-dev, libpng, libjpeg

# Install Node 12.x
spacing
echo "Lusion-Installer: Downloading NodeJS v${NODE_VERSION}.."
wget "https://nodejs.org/dist/latest-v${NODE_VERSION_MAJOR}.x/node-v${NODE_VERSION}-linux-armv7l.tar.gz"
echo "Lusion-Installer: Extracting NodeJS.."
tar -xzf "node-v${NODE_VERSION}-linux-armv7l.tar.gz"
echo "Lusion-Installer: Moving NodeJS.."
nodeFolder="node-v${NODE_VERSION}-linux-armv7l"
sudo cp -R ${nodeFolder}/* /usr/local/

# Install Electron
#spacing
#echo "Lusion-Installer: Installing Electron.."
#npm install -g electron --unsafe-perm=true --allow-root --arch=armv7l --platform=linux

# Install GIT
#spacing
#echo "Lusion-Installer: Installing GIT.."
#sudo apt-get install -y git

# Install PM2
#spacing
#echo "Lusion-Installer: Installing PM2.."
#sudo npm install -y -g pm2

# Install Lusion App
#spacing
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
unzip "${APP_NAME}-linux-armv7l-${APP_VERSION}.zip"


#cd ~/LusionMagic/ || exit
#spacing
#echo "Lusion-Installer: Installing Dependencies..."
#if npm install ; then
#    echo "Lusion-Installer: Dependencies installed!"
#else
#    echo "Lusion-Installer: Unable to install dependencies."
#    exit;
#fi

# Cleanup
spacing
echo "Lusion-Installer: Cleaning up after install.."
rm -rf node-v*
rm -rf "${APP_NAME}-linux-armv7l-${APP_VERSION}.zip"
sudo apt autoremove --silent -y

spacing
echo "======= Lusion-Installer Complete! ======="
echo " "
