#!/bin/bash -e

apt-get install -y \
    nano \
    wget \
    jq \
    wiringpi \
    python3-dev \
    python3-pip \
    libatlas-base-dev

echo "Copying files..."
mkdir /etc/iron-gauntlet
cp src/* /etc/iron-gauntlet/
cp iron-gauntlet.service /etc/systemd/system/iron-gauntlet.service

echo "Installing pip dependencies..."
pip3 install -r /etc/iron-gauntlet/requirements.txt

echo "Registering service to run at boot..."
systemctl enable iron-gauntlet