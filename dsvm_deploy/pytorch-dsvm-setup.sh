#!/usr/bin/env bash

# This script is intended as an initialization script used in azuredeploy.json
# See documentation here: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux#template-deployment

# see abbreviated notes in README.md
# comments below:

# Input args
adminUser=$1
echo $adminUser >> "/home/userscript.log"
publicIP=`dig +short myip.opendns.com @resolver1.opendns.com`
echo $publicIP >> "/home/userscript.log"

WD=/home/$adminUser/notebooks

# Clone the content
mkdir -p /etc/skel/notebooks/workshop
cd /etc/skel/notebooks/workshop
git clone https://github.com/PythonWorkshop/intro-to-nlp-with-pytorch.git

echo WD is $WD

if [ ! -d $WD ]; then
    echo $WD "does not exist - aborting!!" >> "/home/userscript.log"
    exit
else
    cd $WD
    echo "Working in $(pwd)" >> "/home/userscript.log"
fi

# Save host public ip address to the users text file
echo $publicIP >> "/home/$adminUser/usersinfo.csv"

## declare an array of user names to create on vm
declare -a arr=("temp" "storm" "jeangrey" "polaris" "captainmarvel" "quake" "spidergwen" "jessicajones" "arclight" "firestar" "rogue")
## now loop through the above array
for u in "${arr[@]}";
# Create users and generate random password with uppercase and punc chars. Run as root:
do
    sudo useradd -m $u
    p=`openssl rand -hex 4`
    p="P$p!"
    printf "$p\n$p" | sudo passwd $u
    echo $u, $p >> "/home/$adminUser/usersinfo.csv"

    # add user to sudoers
    sudo adduser $u sudo

    ## now create the env...
    condapath=/home/$u/.conda/envs

    if [ ! -d $condapath ]; then
        sudo mkdir -p $condapath
    fi

    ## Update appropriate permissions
    sudo chown -R ${u}:${u} ${condapath}
done
echo "Created users" >> "/home/userscript.log"

# copy the notebooks to the users' profiles
for filename in /home/*; do
  dir=$filename/notebooks
  user=${filename:6}
  cp -r /etc/skel/notebooks/workshop $dir
  chown -R $user $dir/workshop/*
  chown $user $dir/workshop
done

echo "Copied workshop notebooks into user directories" >> "/home/userscript.log"

## now create the env...
condapath=/home/$adminUser/.conda/envs

if [ ! -d $condapath ]; then
    mkdir -p $condapath
fi

#### PYTORCH 1.1 ####

/anaconda/envs/py35/bin/conda create --name pytorch1 python=3.6 ipykernel conda

## update appropriate permissions
chown -R ${adminUser}:${adminUser} ${condapath}

# Install PyTorch 1.x into environment with cuda 9.2 support as DSVM is on this now
/anaconda/envs/pytorch1/bin/python -m conda install pytorch==1.1 torchvision cudatoolkit=9.2 -c pytorch -y

# LibTorch - install into /usr/local/lib
wget https://download.pytorch.org/libtorch/nightly/cu92/libtorch-shared-with-deps-latest.zip
unzip libtorch-shared-with-deps-latest.zip
sudo mv libtorch /usr/local/lib/python3.5/dist-packages/torch

## Install it as a kernel
/anaconda/envs/pytorch1/bin/python -m ipykernel install --name pytorch_preview --display-name "Python 3.6 - PyTorch 1.1"

echo "Done setting up PyTorch 1.1" >> "/home/userscript.log"

## Update appropriate permissions
chown -R ${adminUser}:${adminUser} ${condapath}

## Reboot jupyterhub
systemctl restart jupyterhub

echo "Done!" >> "/home/userscript.log"