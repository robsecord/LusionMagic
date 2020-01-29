#!/usr/bin/env bash

# Install Node 12.x
#curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
#sudo apt-get install -y nodejs
wget https://nodejs.org/dist/latest-v12.x/node-v12.14.1-linux-armv7l.tar.gz
tar -xzf node-v12.14.1-linux-armv7l.tar.gz
sudo cp -R node-v12.14.1-linux-armv7l/* /usr/local/

# Install GIT
sudo apt install -y git

# Install PM2
sudo npm install -y -g pm2

# Cleanup
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
