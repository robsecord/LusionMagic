#!/usr/bin/env bash

# Install Node 12.x
curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
sudo apt-get install -y nodejs
sudo apt-get install -y git
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
