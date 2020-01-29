#!/usr/bin/env bash

echo "LusionMagic: Updating System Sources.."
sudo apt update
sudo apt-get update

echo "LusionMagic: Upgrading System Dependencies.."
sudo apt-get upgrade -y 2>&1

# Install Node 12.x
#curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
#sudo apt-get install -y nodejs
echo "LusionMagic: Downloading NodeJS.."
wget https://nodejs.org/dist/latest-v12.x/node-v12.14.1-linux-armv7l.tar.gz
echo "LusionMagic: Extracting NodeJS.."
tar -xzf node-v12.14.1-linux-armv7l.tar.gz
echo "LusionMagic: Moving NodeJS.."
sudo cp -R node-v12.14.1-linux-armv7l/* /usr/local/

# Install GIT
echo "LusionMagic: Installing GIT.."
sudo apt-get install -y git

# Install PM2
echo "LusionMagic: Installing PM2.."
sudo npm install -y -g pm2

# Cleanup
echo "LusionMagic: Cleaning up after install.."
rm -rf node-v*
#sudo apt autoremove --silent

# Install Lusion App
cd ~
echo "LusionMagic: Cloning Repo..."
if git clone --depth=1 https://github.com/robsecord/LusionMagic.git; then
    echo "LusionMagic: Cloning repo done!"
else
    echo "LusionMagic: Unable to clone repo."
    exit;
fi

cd ~/LusionMagic/ || exit
echo "LusionMagic: Installing Lusion Dependencies..."
if npm install ; then
    echo "LusionMagic: Dependencies installed!"
else
    echo "LusionMagic: Unable to install dependencies."
    exit;
fi
