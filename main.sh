#!/bin/bash

# Author: Christopher Afeku Junior [BlackOps]
# Date Created: 21-09-22
# Last Modified: 21-09-22

# Description:
# A simple bash script to automate the installation and setup of a newly installed Debian or RHEL Linux Operating System for use. 
# This script is reusable and supports both Debian & RHEL operating systems.

# Usage:
# Make this script executable and run with sudo privileges.
# You can change package versions from the variable section.

###### Variables Section ########
package_manager="apt" # You can choose between "apt" and "yum".
java_version="11.0.2-open"
utilities=" zip unzip gdebi-core tar curl wget ubuntu-restricted-extras build-essential manpages-dev net-tools"
git="git"
python_version="python3.10.7"

echo "Updating apt repositories"
sudo $package_manager update && sudo $package_manager upgrade -y
echo "Update complete"\n\n

echo "Installing Utility Packages"
sudo $package_manager install $utilities -y
echo "Utilities installed"\n\n

echo "Installing SDKMan"
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
echo "SDKMan Successfully Installed"

echo "Installing OpenJDK 11 & Setting As Default"
sdk install java $java_version
echo "OpenJDK 11 Successfully Installed"

echo "Installing Git Requirements And Git"
if $package_manager=="apt"; then
    add-apt-repository ppa:git-core/ppa && $package_manager update && $package_manager install $git
    sudo $package_manager update
elif $package_manager=="yum"; then
    $package_manager install $git
else
    echo "Unsupported Package Manager"
fi

echo "Installing Python3"
sudo $package_manager install $python_version
sudo $package_manager update
echo $python_version "Install Complete"\n\n

echo "Installing Node.js"
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo $package_manager install -y nodejs

echo "Installing Visual Studio Code"
if $package_manager=="apt"; then
    sudo $package_manager update && sudo $package_manager install software-properties-common apt-transport-https -y
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    sudo $package_manager install code && sudo $package_manager update && sudo $package_manager upgrade -y
    echo "VS Code Install Complete"\n\n
elif $package_manager=="yum"; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    $package_manager check-update && sudo $package_manager install code
    echo "VS Code Install Complete"\n\n
else
    echo "Unsupported Package Manager"
fi

echo "Installing Skype"
sudo $package_manager update && sudo $package_manager install snapd -y
sudo snap install skype -- classic
echo "Skype Installed Successfully"

echo "Installing VLC"
sudo $package_manager update && sudo $package_manager install vlc -y
echo "VLC Installed Successfully"

echo "Installing Docker"
if $package_manager=="apt"; then
    sudo $package_manager remove docker docker-engine docker.io containerd runc
    sudo $package_manager update
    sudo $package_manager install ca-certificates gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo $package_manager update
    sudo $package_manager install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo service docker start
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    echo "Docker Installed Successfully"
elif $package_manager=="yum"; then
    sudo $package_manager remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
    sudo $package_manager install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo $package_manager install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo systemctl start docker
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    echo "Docker Installed Successfully"
else
    echo "Unsupported Package Manager"
fi

echo "All Done, Enjoy!"
exit 0
