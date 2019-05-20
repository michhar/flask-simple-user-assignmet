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

echo WD is $WD

if [ ! -d $WD ]; then
    echo $WD does not exist - aborting!!
    exit
else
    cd $WD
    echo "Working in $(pwd)" >> "/home/userscript.log"
fi

# Save host public ip address to the users text file
echo $publicIP >> "/home/$adminUser/usersinfo.csv"

## declare an array of user names to create on vm
declare -a arr=("storm" "jeangrey" "polaris" "captainmarvel" "quake" "spidergwen" "jessicajones" "arclight" "firestar" "rogue")
## now loop through the above array
for u in "${arr[@]}";
# Create users and generate random password. Run as root:
do
    sudo useradd -m $u
    p=`openssl rand -hex 5`
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



## now create the env...
condapath=/home/$adminUser/.conda/envs

if [ ! -d $condapath ]; then
    mkdir -p $condapath
fi

#### PYTORCH 1.0 ####

/anaconda/envs/py35/bin/conda create --name pytorch10 python=3.6 ipykernel conda

## update appropriate permissions
chown -R ${adminUser}:${adminUser} ${condapath}

# Install PyTorch 1.0 into environment with cuda 9.2 support as DSVM is on this now
/anaconda/envs/pytorch10/bin/python -m conda install pytorch torchvision cudatoolkit=9.2 -c pytorch -y

# LibTorch - install into /usr/local/lib
wget https://download.pytorch.org/libtorch/nightly/cu92/libtorch-shared-with-deps-latest.zip
unzip libtorch-shared-with-deps-latest.zip
sudo mv libtorch /usr/local/lib/python3.5/dist-packages/torch

## Install it as a kernel
/anaconda/envs/pytorch10/bin/python -m ipykernel install --name pytorch_preview --display-name "Python 3.6 - PyTorch latest"

echo "Done setting up PyTorch latest" >> "/home/userscript.log"

#### PYTORCH 0.4.1 ####

/anaconda/envs/py35/bin/conda create --name pytorch041 python=3.6 ipykernel conda numpy pyyaml scipy ipython mkl

## update appropriate permissions
chown -R ${adminUser}:${adminUser} ${condapath}

# # Install PyTorch 0.4.1 into environment with cuda 9.2 support as DSVM is on this now
/anaconda/envs/pytorch041/bin/python -m conda install -c soumith magma-cuda92
/anaconda/envs/pytorch041/bin/conda install torchvision pytorch==0.4.1 -c pytorch

## Install it as a kernel
/anaconda/envs/pytorch041/bin/python -m ipykernel install --name pytorch_041 --display-name "Python 3.6 - PyTorch 0.4.1"

echo "Done setting up PyTorch 0.4.1" >> "/home/userscript.log"

#### PYTORCH 0.3.1 ####

/anaconda/envs/py35/bin/conda create --name pytorch031 python=3.6 ipykernel conda numpy pyyaml scipy ipython mkl

## update appropriate permissions
chown -R ${adminUser}:${adminUser} ${condapath}

# # Install PyTorch 0.3.1 into environment with cuda 9.2 support as DSVM is on this now
/anaconda/envs/pytorch031/bin/python -m conda install -c soumith magma-cuda92
/anaconda/envs/pytorch031/bin/conda install torchvision pytorch==0.3.1 -c pytorch

## Install it as a kernel
/anaconda/envs/pytorch031/bin/python -m ipykernel install --name pytorch_031 --display-name "Python 3.6 - PyTorch 0.3.1"

echo "Done setting up PyTorch 0.3.1" >> "/home/userscript.log"

## Update appropriate permissions
chown -R ${adminUser}:${adminUser} ${condapath}

## Reboot jupyterhub
systemctl restart jupyterhub

echo "Done!" >> "/home/userscript.log"