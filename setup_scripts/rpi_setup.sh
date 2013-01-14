#!/bin/bash

# Run this script as root ie:
# sudo -s
# bash <(wget -q -O - https://raw.github.com/ninjablocks/utilities/pi/setup_scripts/rpi_setup.sh)

set -e

bold=`tput bold`;
normal=`tput sgr0`;
username="pi"

# Setup the timezone
echo -e "\n→ ${bold}Setting up Sydney as the default timezone.${normal}\n";
sudo echo "Australia/Sydney" | sudo tee /etc/timezone;
sudo dpkg-reconfigure --frontend noninteractive tzdata;

# Updating apt-get
echo -e "\n→ ${bold}Updating apt-get${normal}\n";
sudo apt-get update > /dev/null;

echo -e "\n→ ${bold}Installing ntpdate${normal}\n";
sudo apt-get -qq -y -f -m install ntpdate > /dev/null;
sudo /etc/init.d/ntp stop
# Add NTP Update as a daily cron job
echo -e "\n→ ${bold}Create the ntpdate file${normal}\n";
sudo touch /etc/cron.daily/ntpdate;
echo -e "\n→ ${bold}Add ntpdate ntp.ubuntu.com${normal}\n";
sudo echo "ntpdate ntp.ubuntu.com" > /etc/cron.daily/ntpdate;
echo -e "\n→ ${bold}Making ntpdate executable${normal}\n";
sudo chmod 755 /etc/cron.daily/ntpdate;


# Update the timedate
echo -e "\n→ ${bold}Updating the time${normal}\n";
sudo ntpdate ntp.ubuntu.com pool.ntp.org;
sudo /etc/init.d/ntp start



# Download and install the Essential packages.
echo -e "\n→ ${bold}Installing git${normal}\n";
sudo apt-get -qq -y -f -m  install git > /dev/null; 
# echo -e "\n→ ${bold}Installing g++${normal}\n";
# sudo apt-get -qq -y -f -m  install g++;
echo -e "\n→ ${bold}Installing node${normal}\n";
sudo apt-get -qq -y -f -m  install nodejs > /dev/null;
sudo ln -s /usr/bin/nodejs /usr/bin/node 
echo -e "\n→ ${bold}Installing npm${normal}\n"; 
sudo apt-get -qq -y -f -m  install npm > /dev/null;
echo -e "\n→ ${bold}Installing ruby1.9.1-dev${normal}\n"; 
sudo apt-get -qq -y -f -m  install ruby1.9.1-dev > /dev/null;
# echo -e "\n→ ${bold}Installing make${normal}\n"; 
# sudo apt-get -qq -y -f -m  install make;
# echo -e "\n→ ${bold}Installing build-essential${normal}\n"; 
# sudo apt-get -qq -y -f -m  install build-essential;
echo -e "\n→ ${bold}Installing avrdude${normal}\n"; 
sudo apt-get -qq -y -f -m  install avrdude > /dev/null;
# echo -e "\n→ ${bold}Installing libgd2-xpm-dev${normal}\n"; 
# sudo apt-get -qq -y -f -m  install libgd2-xpm-dev;
# echo -e "\n→ ${bold}Installing libv4l-dev${normal}\n"; 
# sudo apt-get -qq -y -f -m  install libv4l-dev;

# echo -e "\n→ ${bold}Installing subversion${normal}\n"; 
# sudo apt-get -qq -y -f -m  install subversion;
# echo -e "\n→ ${bold}Installing libjpeg8-dev${normal}\n"; 
# sudo apt-get -qq -y -f -m  install libjpeg8-dev;
# echo -e "\n→ ${bold}Installing imagemagick${normal}\n"; 
# sudo apt-get -qq -y -f -m  install imagemagick;

echo -e "\n→ ${bold}Installing psmisc${normal}\n"; 
sudo apt-get -qq -y -f -m  install psmisc > /dev/null;

echo -e "\n→ ${bold}Installing curl${normal}\n"; 
sudo apt-get -qq -y -f -m  install curl > /dev/null;


# Install Sinatra
echo -e "\n→ ${bold}Installing the sinatra gem${normal}\n"; 
sudo gem install sinatra  --verbose --no-rdoc --no-ri > /dev/null;

# Install getifaddrs
echo -e "\n→ ${bold}Installing the getifaddrs gem${normal}\n"; 
sudo gem install system-getifaddrs  --verbose --no-rdoc --no-ri > /dev/null;


# Create the Ninja Blocks utilities folder
echo -e "\n→ ${bold}Create the Ninja Blocks Utilities Folder${normal}\n"; 
sudo mkdir -p  /opt/utilities;   


# Clone the Ninja Utilities into /opt/utilities
echo -e "\n→ ${bold}Fetching the Utilities Repo from Github${normal}\n";
git clone https://github.com/ninjablocks/utilities.git /opt/utilities > /dev/null;
cd /opt/utilities;
git checkout master; #this will change once release is finished


echo -e "\n→ ${bold}Copying init scripts into place${normal}\n";
sudo sed -i 's/exit 0$/\/opt\/utilities\/bin\/ninjapi_start\nexit 0/' /etc/rc.local


# Copy /etc/udev/rules.d/ scripts into place
echo -e "\n→ ${bold}Copy /etc/udev/rules.d/ scripts into place${normal}\n";
sudo cp /opt/utilities/udev/* /etc/udev/rules.d/;


# Create Ninja Directory (-p to preserve if already exists).
echo -e "\n→ ${bold}Create the Ninja Directory${normal}\n";
sudo mkdir -p /opt/ninja;


# Clone the Ninja Client into opt
echo -e "\n→ ${bold}Clone the Ninja Client into opt${normal}\n";
git clone https://github.com/ninjablocks/client.git /opt/ninja > /dev/null;
cd /opt/ninja;
git checkout master;
sudo sed -i 's/ttyO1/null/' beagle.js


echo -e "${bold}Pulling down RPI binaries${normal}";
cd /tmp;
wget https://s3.amazonaws.com/ninjablocks/binaries/pi/rpi-binaries.tgz > /dev/null;
tar -C / -xzf rpi-binaries.tgz > /dev/null;
echo -e "${bold}Deploying RPI binaries${normal}";
rm rpi-binaries.tgz;
sudo ln -s /opt/ninja/node_modules/forever/bin/forever /usr/bin/forever

# # Install the node packages
# echo -e "\n→ ${bold}Install the node packages${normal}\n";
# cd /opt/ninja;
# npm install;

# Create directory /etc/opt/ninja
echo -e "\n→ ${bold}Adding /etc/opt/ninja${normal}\n";
sudo mkdir -p /etc/opt/ninja;

# Set user as the owner of this directory.
echo -e "\n→ ${bold}Set ${username} user as the owner of this directory${normal}\n";
sudo chown -R ${username} /opt/;


# Add /opt/utilities/bin to root's path
echo -e "\n→ ${bold}Adding /opt/utilities/bin to root's path${normal}\n";
echo 'export PATH=/opt/utilities/bin:$PATH' >> /root/.bashrc;

# Add /opt/utilities/bin to user's path
echo -e "\n→ ${bold}Adding /opt/utilities/bin to ${username}'s path${normal}\n";
echo 'export PATH=/opt/utilities/bin:$PATH' >> /home/${username}/.bashrc;

# Set the beagle's environment
echo -e "\n→ ${bold}Setting the beagle's environment to stable${normal}\n";
echo 'export NINJA_ENV=stable' >> /home/${username}/.bashrc;

# Add ninja_update to the hourly cron
echo -e "\n→ ${bold}Add ninja_update to the hourly cron${normal}\n";
ln -s /opt/utilities/bin/ninja_update /etc/cron.hourly/ninja_update;

# Run the setserial command so we can flash the Arduino later
echo -e "\n→ ${bold}Getting serial number from system${normal}\n";
sudo /opt/utilities/bin/ninjapi_get_serial;

echo -e "Running system update script"
sudo /opt/utilities/bin/ninja_update_system;

echo -e "\n→ ${bold}Guess what? We're done!!!${normal}\n";

echo -e "Before you reboot, write down this serial-- this is what you will need to activate your new Pi!"

echo -e "--------------------------------------------------------------"
echo -e "|                                                            |"
echo -e "|           Your NinjaPi Serial is: `cat /etc/opt/ninja/serial.conf`         |"
echo -e "|                                                            |"
echo -e "--------------------------------------------------------------"

