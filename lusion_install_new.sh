#!/bin/bash

echo " "
echo " "
echo "------------------------------------"
echo "------------------------------------"
echo "           Lusion Magic             "
echo "              v0.0.1                "
echo "       Installation Script          "
echo "------------------------------------"
echo "------------------------------------"
echo " "
echo " "

doInstall=1
true=1
false=0

# Define the tested version of Node.js.
NODE_TESTED="v10.1.0"
NPM_TESTED="V6.0.0"
USER=`whoami`
force_arch=

#PM2_FILE=pm2_MagicMirror.json
#pm2setup=$false

# Define helper methods.
function command_exists () { type "$1" &> /dev/null ;}
function verlte() {  [ "$1" = "`echo -e "$1\n$2" | sort -V | head -n1`" ];}
function verlt() { [ "$1" = "$2" ] && return 1 || verlte $1 $2 ;}

function trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}


# put the log where the script is located
logdir=$(dirname $(readlink -f "$0"))
logfile=$logdir/lusion_install.log
echo "LUSION: Install log being saved to $logfile"


date +"LUSION: Install starting - %a %b %e %H:%M:%S %Z %Y" >> $logfile
ARM=$(uname -m)
echo "LUSION: Installing on $ARM processor system" >> $logfile
echo "LUSION: OS is $(lsb_release -a 2>/dev/null)" >> $logfile

if [ $USER == 'root' ]; then
    errorMsg="LUSION: Error - Please logon as a user to execute the installation, not root"
	echo "$errorMsg"
    echo -e "\e[96m$errorMsg\e[90m" | tee -a $logfile
	exit 1
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Update System Software
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo -e "\e[96mLUSION: Updating packages...\e[90m" | tee -a $logfile
upgrade=$false
update=$(sudo apt-get update 2>&1)
echo $update >> $logfile
update_rc=$?
if [ $update_rc -ne 0 ]; then
    echo -e "\e[91mLUSION: Update failed, retrying installation ...\e[90m" | tee -a $logfile
    if [ $(echo $update | grep "apt-secure" | wc -l) -eq 1 ]; then
        update=$(sudo apt-get update --allow-releaseinfo-change 2>&1)
        update_rc=$?
        echo $update >> $logfile
        if [ $update_rc -ne 0 ]; then
            echo "second apt-get update failed" $update | tee -a $logfile
            exit 1
        else
            echo "second apt-get update completed ok" >> $logfile
            upgrade=$true
        fi
    fi
else
    echo "apt-get update  completed ok" >> $logfile
    upgrade=$true
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Upgrade System Software
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ $upgrade -eq $true ]; then
    upgrade_result=$(sudo apt-get upgrade 2>&1)
    upgrade_rc=$?
    echo apt upgrade result ="rc=$upgrade_rc $upgrade_result" >> $logfile
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Install Helper Tools
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo -e "\e[96mLUSION: Installing helper tools ...\e[90m" | tee -a $logfile
sudo apt-get --assume-yes install curl wget git build-essential unzip || exit


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# NodeJS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Check if we need to install or upgrade Node.js.
echo -e "\e[96mLUSION: Check current Node installation ...\e[0m" | tee -a $logfile
NODE_INSTALL=false
if command_exists node; then
	echo -e "\e[0mLUSION: Node currently installed. Checking version number." | tee -a $logfile
	NODE_CURRENT=$(node -v)
	if [ "$NODE_CURRENT." == "." ]; then
	    NODE_CURRENT="V1.0.0"
		echo forcing low Node version  >> $logfile
	fi
	echo -e "\e[0mLUSION: Minimum Node version: \e[1m$NODE_TESTED\e[0m" | tee -a $logfile
	echo -e "\e[0mLUSION: Installed Node version: \e[1m$NODE_CURRENT\e[0m" | tee -a $logfile
	if verlte $NODE_CURRENT $NODE_TESTED; then
		echo -e "\e[96mLUSION: Node should be upgraded.\e[0m" | tee -a $logfile
		NODE_INSTALL=true

		# Check if a node process is currently running.
		# If so abort installation.
		if pgrep "node" > /dev/null; then
			echo -e "\e[91mLUSION: A Node process is currently running. Can't upgrade." | tee -a $logfile
			echo "LUSION: Please quit all Node processes and restart the installer." | tee -a $logfile
			echo $(ps -ef | grep node | grep -v \-\-color) | tee -a $logfile
			exit;
		fi

	else
		echo -e "\e[92mLUSION: No Node.js upgrade necessary.\e[0m" | tee -a $logfile
	fi

else
	echo -e "\e[93mLUSION: Node.js is not installed.\e[0m" | tee -a $logfile
	NODE_INSTALL=true
fi

# Install or upgrade node if necessary.
if $NODE_INSTALL; then

	echo -e "\e[96mLUSION: Installing Node.js ...\e[90m" | tee -a $logfile

	# Fetch the latest version of Node.js from the selected branch
	# The NODE_STABLE_BRANCH variable will need to be manually adjusted when a new branch is released. (e.g. 7.x)
	# Only tested (stable) versions are recommended as newer versions could break the App.
    NODE_STABLE_BRANCH="10.x"
    # sudo apt-get install --only-upgrade libstdc++6
    node_info=$(curl -sL https://deb.nodesource.com/setup_$NODE_STABLE_BRANCH | sudo -E bash - )
    echo Node release info = $node_info >> $logfile
    if [ "$(echo $node_info | grep "not currently supported")." == "." ]; then
        sudo apt-get install -y nodejs
    else
        echo node $NODE_STABLE_BRANCH version installer not available, doing manually >> $logfile
        # no longer supported install
        sudo apt-get install -y --only-upgrade libstdc++6 >> $logfile
        # have to do it manually
        node_vnum=$(echo $NODE_STABLE_BRANCH | awk -F. '{print $1}')
        # get the highest release number in the stable branch line for this processor architecture
        node_ver=$(curl -sL https://unofficial-builds.nodejs.org/download/release/index.tab | grep $ARM | grep -m 1 v$node_vnum | awk '{print $1}')
        echo latest release in the $NODE_STABLE_BRANCH family for $ARM is $node_ver >> $logfile
        curl -sL https://unofficial-builds.nodejs.org/download/release/$node_ver/node-$node_ver-linux-$ARM.tar.gz >node_release-$node_ver.tar.gz
        cd /usr/local
        echo using release tar file = node_release-$node_ver.tar.gz >> $logfile
        sudo tar --strip-components 1 -xzf  $HOME/node_release-$node_ver.tar.gz
        cd - >/dev/null
        rm ./node_release-$node_ver.tar.gz
    fi
    # get the new node version number
    new_ver=$(node -v 2>&1)
    # if there is a failure to get it due to a missing library
    if [ $(echo $new_ver | grep "not found" | wc -l) -ne 0 ]; then
        sudo apt-get install -y --only-upgrade libstdc++6 >> $logfile
    fi
    echo node version is $(node -v 2>&1 >> $logfile)
	echo -e "\e[92mLUSION: Node.js installation Done! version=$(node -v)\e[0m" | tee -a $logfile
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# NPM
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Check if we need to install or upgrade npm.
echo -e "\e[96mLUSION: Check current NPM installation ...\e[0m" | tee -a $logfile
NPM_INSTALL=false
if command_exists npm; then
	echo -e "\e[0mLUSION: NPM currently installed. Checking version number." | tee -a $logfile
	NPM_CURRENT='V'$(npm -v)
	echo -e "\e[0mLUSION: Minimum npm version: \e[1m$NPM_TESTED\e[0m" | tee -a $logfile
	echo -e "\e[0mLUSION: Installed npm version: \e[1m$NPM_CURRENT\e[0m" | tee -a $logfile
	if verlte $NPM_CURRENT $NPM_TESTED; then
		echo -e "\e[96mLUSION: npm should be upgraded.\e[0m" | tee -a $logfile
		NPM_INSTALL=true

		# Check if a node process is currently running.
		# If so abort installation.
		if pgrep "npm" > /dev/null; then
			echo -e "\e[91mLUSION: A npm process is currently running. Can't upgrade." | tee -a $logfile
			echo "LUSION: Please quit all npm processes and restart the installer." | tee -a $logfile
			exit;
		fi

	else
		echo -e "\e[92mLUSION: No npm upgrade necessary.\e[0m" | tee -a $logfile
	fi

else
	echo -e "\e[93mLUSION: npm is not installed.\e[0m" | tee -a $logfile
	NPM_INSTALL=true
fi

# Install or upgrade npm if necessary.
if $NPM_INSTALL; then

	echo -e "\e[96mLUSION: Installing npm ...\e[90m" | tee -a $logfile

	sudo apt-get install -y npm >> $logfile

	# update to the latest.
	echo upgrading npm to latest >> $logfile
	sudo npm i -g npm  >> $logfile
	echo -e "\e[92mLUSION: npm installation Done! version=V$(npm -v)\e[0m" | tee -a $logfile
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Lusion Magic
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Install LusionMagic
#cd ~
#if [ $doInstall == 1 ]; then
#	if [ -d "$HOME/LusionMagic" ] ; then
#		echo -e "\e[93mLUSION: It seems like LusionMagic is already installed." | tee -a $logfile
#		echo -e "LUSION: To prevent overwriting, the installer will be aborted." | tee -a $logfile
#		echo -e "LUSION: Please rename the \e[1m~/LusionMagic\e[0m\e[93m folder and try again.\e[0m" | tee -a $logfile
#		echo ""
#		echo -e "LUSION: If you want to upgrade your installation run \e[1m\e[97mupgrade-script\e[0m from the ~/LusionMagic/installers directory." | tee -a $logfile
#		echo ""
#		exit;
#	fi
#
#	echo -e "\e[96mLUSION: Cloning LusionMagic ...\e[90m" | tee -a $logfile
#	if git clone --depth=1 https://github.com/robsecord/LusionMagic.git; then
#		echo -e "\e[92mLUSION: Cloning LusionMagic Done!\e[0m" | tee -a $logfile
#	else
#		echo -e "\e[91mLUSION: Unable to clone LusionMagic." | tee -a $logfile
#		exit;
#	fi
#
#	cd ~/LusionMagic  || exit
##	if [ $(grep version package.json | awk -F: '{print $2}') == '"2.9.0",' -a $ARM == 'armv6l' ]; then
##	  git fetch https://github.com/MichMich/LusionMagic.git develop >/dev/null 2>&1
##		git branch develop FETCH_HEAD > /dev/null 2>&1
##		git checkout develop > /dev/null 2>&1
##	fi
#	echo -e "\e[96mLUSION: Installing dependencies ...\e[90m" | tee -a $logfile
#	if npm install $force_arch; then
#		echo -e "\e[92mLUSION: Dependencies installation Done!\e[0m" | tee -a $logfile
#	else
#		echo -e "\e[91mLUSION: Unable to install dependencies!" | tee -a $logfile
#		exit;
#	fi
#
#	# Use sample config for start LusionMagic
#	echo setting up initial config.js | tee -a $logfile
#	cp config/config.js.sample config/config.js
#fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Plymouth
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Check if plymouth is installed (default with PIXEL desktop environment), then install custom splashscreen.
#echo -e "\e[96mLUSION: Check plymouth installation ...\e[0m" | tee -a $logfile
#if command_exists plymouth; then
#	THEME_DIR="/usr/share/plymouth/themes"
#	echo -e "\e[90mLUSION: Splashscreen: Checking themes directory.\e[0m" | tee -a $logfile
#	if [ -d $THEME_DIR ]; then
#		echo -e "\e[90mLUSION: Splashscreen: Create theme directory if not exists.\e[0m" | tee -a $logfile
#		if [ ! -d $THEME_DIR/LusionMagic ]; then
#			sudo mkdir $THEME_DIR/LusionMagic
#		fi
#
#		if sudo cp ~/LusionMagic/splashscreen/splash.png $THEME_DIR/LusionMagic/splash.png && sudo cp ~/LusionMagic/splashscreen/LusionMagic.plymouth $THEME_DIR/LusionMagic/LusionMagic.plymouth && sudo cp ~/LusionMagic/splashscreen/LusionMagic.script $THEME_DIR/LusionMagic/LusionMagic.script; then
#			echo
#			if [ "$(which plymouth-set-default-theme)." != "." ]; then
#				if sudo plymouth-set-default-theme -R LusionMagic; then
#					echo -e "\e[92mLUSION: Splashscreen: Changed theme to LusionMagic successfully.\e[0m" | tee -a $logfile
#				else
#					echo -e "\e[91mLUSION: Splashscreen: Couldn't change theme to LusionMagic!\e[0m" | tee -a $logfile
#				fi
#			fi
#		else
#			echo -e "\e[91mLUSION: Splashscreen: Copying theme failed!\e[0m" | tee -a $logfile
#		fi
#	else
#		echo -e "\e[91mLUSION: Splashscreen: Themes folder doesn't exist!\e[0m" | tee -a $logfile
#	fi
#else
#	echo -e "\e[93mLUSION: plymouth is not installed.\e[0m" | tee -a $logfile
#fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PM2
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Use pm2 control like a service LusionMagic
#read -p "Do you want use pm2 for auto starting of your LusionMagic (y/N)?" choice
#if [[ $choice =~ ^[Yy]$ ]]; then
#      echo install and setup pm2 | tee -a $logfile
# 			# assume pm2 will be found on the path
#			pm2cmd=pm2
#			# check to see if already installed
#			pm2_installed=$(which $pm2cmd)
#			up=""
#			if [ $mac == 'Darwin' ]; then
#				 up="--unsafe-perm"
#				 launchctl=launchctl
#				 launchctl_path=$(which $launchctl)
#				 `export PATH=$PATH:${launchctl_path%/$launchctl}`
#			fi
#			# check to see if already installed
#			pm2_installed=$(which $pm2cmd)
#			if [  "$pm2_installed." != "." ]; then
#			    # does it work?
#					pm2_fails=$(pm2 list | grep -i -m 1 "App Name" | wc -l )
#					if [ $pm2_fails != 1 ]; then
#					   # uninstall it
#						 echo pm2 installed, but does not work, uninstalling >> $logfile
#					   sudo npm uninstall $up -g pm2 >> $logfile
#						 # force reinstall
#				     pm2_installed=
#					fi
#			fi
#			# if not installed
#			if [  "$pm2_installed." == "." ]; then
#				# install it.
#				echo pm2 not installed, installing >> $logfile
#				result=$(sudo npm install $up -g pm2 2>&1)
#				echo pm2 install result $result >> $logfile
#				# if this is a mac
#				if [ $mac == 'Darwin' ]; then
#					echo this is a mac, fixup for path >> $logfile
#					# get the location of pm2 install
#					# parse the npm install output to get the command
#					pm2cmd=`echo $result | awk -F -  '{print $1}' | tr -d '[:space:]'`
#					c='/pm2'
#					# get the path only
#					echo ${pm2cmd%$c} >installers/pm2path
#				fi
#			fi
#			echo get the pm2 platform specific startup command >> $logfile
#			# get the platform specific pm2 startup command
#			v=$($pm2cmd startup | tail -n 1)
#			if [ $mac != 'Darwin' ]; then
#				# check to see if we can get the OS package name (Ubuntu)
#				if [ $(which lsb_release| wc -l) >0 ]; then
#					# fix command
#					# if ubuntu 18.04, pm2 startup gets something wrong
#					if [ $(lsb_release  -r | grep -m1 18.04 | wc -l) > 0 ]; then
#						 v=$(echo $v | sed 's/\/bin/\/bin:\/bin/')
#					fi
#				fi
#			fi
#			echo startup command = $v >> $logfile
#			# execute the command returned
#		  $v 2>&1 >> $logfile
#			echo pm2 startup command done >> $logfile
#			# is this is mac
#			# need to fix pm2 startup, only on catalina
#			if [ $mac == 'Darwin' ];then
#        if [ $(sw_vers -productVersion | head -c 6) == '10.15.' ]; then
#					# only do if the faulty tag is present (pm2 may fix this, before the script is fixed)
#					if [ $(grep -m 1 UserName /Users/$USER/Library/LaunchAgents/pm2.$USER.plist | wc -l) -eq 1 ]; then
#						# copy the pm2 startup file config
#						cp  /Users/$USER/Library/LaunchAgents/pm2.$USER.plist .
#						# edit out the UserName key/value strings
#						sed -e '/UserName/{N;d;}' pm2.$USER.plist > pm2.$USER.plist.new
#						# copy the file back
#						sudo cp pm2.$USER.plist.new /Users/$USER/Library/LaunchAgents/pm2.$USER.plist
#					fi
#				fi
#			fi
#		# if the user is no pi, we have to fixup the pm2 json file
#		echo configure the pm2 config file for LusionMagic >> $logfile
#		if [ "$USER"  != "pi" ]; then
#			echo the user is not pi >> $logfile
#			# go to the installers folder`
#			cd installers
#			# edit the startup script for the right user
#			echo change mm.sh >> $logfile
#			 if [ ! -e mm_temp.sh ]; then
#			   echo save copy of mm.sh >> $logfile
#			   cp mm.sh mm_temp.sh
#			 fi
#			 if [ $(grep pi mm_temp.sh | wc -l) -gt 0 ]; then
#			  echo change hard coded pi username  >> $logfile
#				sed 's/pi/'$USER'/g' mm_temp.sh >mm.sh
#			 else
#			  echo change relative home path to hard coded path >> $logfile
#			  hf=$(echo $HOME |sed 's/\//\\\//g')
#			  sed 's/\~/'$hf'/g' mm_temp.sh >mm.sh
#			 fi
#			# edit the pms config file for the right user
#			echo change $PM2_FILE >> $logfile
#			sed 's/pi/'$USER'/g' $PM2_FILE > pm2_MagicMirror_new.json
#			# make sure to use the updated file
#			PM2_FILE=pm2_MagicMirror_new.json
#			# if this is a mac
#			if [ $mac == 'Darwin' ]; then
#				 # copy the path file to the system paths list
#				 sudo cp ./pm2path /etc/paths.d
#				 # change the name of the home path for mac
#				 sed 's/home/Users/g' $PM2_FILE > pm2_MagicMirror_new1.json
#				 # make sure to use the updated file
#				 PM2_FILE=pm2_MagicMirror_new1.json
#			fi
#			echo now using this config file $PM2_FILE >> $logfile
#			# go back one cd level
#			cd - >/dev/null
#		fi
#		echo start LusionMagic via pm2 now >> $logfile
#		# tell pm2 to start the app defined in the config file
#		$pm2cmd start $HOME/LusionMagic/installers/$PM2_FILE
#		# tell pm2 to save that configuration, for start at boot
#		echo save LusionMagic pm2 config now  >> $logfile
#		$pm2cmd save
#		pm2setup=$true
#fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Screen Saver
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Disable Screensaver
# find out if some screen saver running
# get just the running processes and args
# just want the program name (1st token)
# find the 1st with 'saver' in it (should only be one)
# parse with path char, get the last field ( the actual pgm name)

screen_saver_running=$(ps -A -o args | awk '{print $1}' | grep -m1 [s]aver | awk -F\/ '{print $NF}');

# if we found something
if [ "$screen_saver_running." != "." ]; then
    # some screensaver running
    case "$screen_saver_running" in
        mate-screensaver) echo 'mate screen saver' >> $logfile
            #killall mate-screensaver >/dev/null 2>&1
            #$ms -d >/dev/null 2>&1
            gsettings set org.mate.screensaver lock-enabled false	 2>/dev/null
            gsettings set org.mate.screensaver idle-activation-enabled false	 2>/dev/null
            gsettings set org.mate.screensaver lock_delay 0	 2>/dev/null
            echo " $screen_saver_running disabled" >> $logfile
            DISPLAY=:0  mate-screensaver  >/dev/null 2>&1 &
            ;;
        gnome-screensaver) echo 'gnome screen saver' >> $logfile
            gnome_screensaver-command -d >/dev/null 2>&1
            echo " $screen_saver_running disabled" >> $logfile
            ;;
        xscreensaver) echo 'xscreensaver running' | tee -a $logfile
            if [ $(grep -m1 'mode:' ~/.xscreensaver | awk '{print $2}') != 'off' ]; then
                sed -i 's/$xsetting/mode: off/' ~/.xscreensaver
                echo " xscreensaver set to off" >> $logfile
            else
                echo " xscreensaver already disabled" >> $logfile
            fi
            ;;
        gsd-screensaver | gsd-screensaver-proxy)
            setting=$(gsettings get org.gnome.desktop.screensaver lock-enabled)
            setting1=$(gsettings get org.gnome.desktop.session idle-delay)
            if [ "$setting $setting1" != 'false uint32 0' ]; then
                echo disable screensaver via gsettings was $setting and $setting1>> $logfile
                gsettings set org.gnome.desktop.screensaver lock-enabled false
                gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
                gsettings set org.gnome.desktop.session idle-delay 0
            else
                echo gsettings screen saver already disabled >> $logfile
            fi
            ;;
    *) echo "some other screensaver $screen_saver_running" found | tee -a $logfile
        echo "please configure it manually" | tee -a $logfile
        ;;
    esac
elif [ -e "/etc/lightdm/lightdm.conf" ]; then
    # if screen saver NOT already disabled?
    if [ $(grep 'xserver-command=X -s 0 -dpms' /etc/lightdm/lightdm.conf | wc -l) == 0 ]; then
        echo install screensaver via lightdm.conf >> $logfile
        sudo sed -i '/^\[Seat:\*\]/a xserver-command=X -s 0 -dpms' /etc/lightdm/lightdm.conf
    else
        echo screensaver via lightdm already disabled >> $logfile
    fi
elif [ $(which gsettings | wc -l) == 1 ]; then
    setting=$(gsettings get org.gnome.desktop.screensaver lock-enabled)
    setting1=$(gsettings get org.gnome.desktop.session idle-delay)
    if [ "$setting $setting1" != 'false uint32 0' ]; then
        echo disable screensaver via gsettings was $setting and $setting1>> $logfile
        gsettings set org.gnome.desktop.screensaver lock-enabled false
        gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
        gsettings set org.gnome.desktop.session idle-delay 0
    else
        echo gsettings screen saver already disabled >> $logfile
    fi
elif [ -d "/etc/xdg/lxsession" ]; then
    currently_set=$(grep -m1 '\-dpms' /etc/xdg/lxsession/LXDE-pi/autostart)
    if [ "$currently_set." == "." ]; then
        echo disable screensaver via lxsession >> $logfile
        # turn it off for the future
        sudo su -c "echo -e '@xset s noblank\n@xset s off\n@xset -dpms' >> /etc/xdg/lxsession/LXDE-pi/autostart"
        # turn it off now
        export DISPLAY=:0; xset s noblank;xset s off;xset -dpms
    else
        echo lxsession screen saver already disabled >> $logfile
    fi
else
    echo " "
    echo -e "unable to disable screen saver, /etc/xdg/lxsession does not exist" | tee -a $logfile
fi



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Install Complete
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


echo " "
#if [ $pm2setup -eq $true ]; then
#	rmessage="pm2 start LusionMagic"
#else
    rmessage="DISPLAY=:0 npm start"
#fi
echo -e "\e[92mLUSION: Installation Complete!\e[0m" | tee -a $logfile
echo -e "\e[92mLUSION: Run \e[1m\e[97m$rmessage\e[0m\e[92m from the ~/LusionMagic directory to start!\e[0m" | tee -a $logfile
date +"LUSION: Completed at %a %b %e %H:%M:%S %Z %Y" >> $logfile

echo " "
echo " "
echo "------------------------------------"
echo "------------------------------------"
echo "           Lusion Magic             "
echo "      Installation Completed!       "
echo "------------------------------------"
echo "------------------------------------"
echo " "
echo " "
