#!/usr/bin/env bash

# Install Node 12.x
curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
sudo apt-get install -y nodejs
#sudo apt-get install gcc g++ make
sudo apt autoremove --silent


# Install Lusion App
cd ~
echo -e "\e[96mCloning repo...\e[90m"
if git clone --depth=1 https://github.com/robsecord/LusionMagic.git; then
    echo -e "\e[92mCloning repo done!\e[0m"
else
    echo -e "\e[91mUnable to clone repo."
    exit;
fi

cd ~/LusionMagic/ || exit
echo -e "\e[96mInstalling dependencies...\e[90m"
if npm install ; then
    echo -e "\e[92mDependencies installed!\e[0m"
else
    echo -e "\e[91mUnable to install dependencies."
    exit;
fi

echo -e "\e[Building App...\e[90m"
if npm run build ; then
    echo -e "\e[App built successfully!\e[0m"
else
    echo -e "\e[91mUnable to build app."
    exit;
fi
