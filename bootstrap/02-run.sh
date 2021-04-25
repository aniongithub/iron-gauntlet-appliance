#!/bin/bash -e

echo "Copying files..."
mkdir ${ROOTFS_DIR}/etc/iron-gauntlet
cp /bootstrap-resources/src/* ${ROOTFS_DIR}/etc/iron-gauntlet/
cp /bootstrap-resources/iron-gauntlet.service ${ROOTFS_DIR}/etc/systemd/system/iron-gauntlet.service

echo "Installing pip dependencies..."
on_chroot << EOF
pip3 install -r /etc/iron-gauntlet/requirements.txt
EOF

echo "Registering service to run at boot..."
on_chroot << EOF
systemctl enable iron-gauntlet
EOF