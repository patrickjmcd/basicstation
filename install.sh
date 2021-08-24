#!/usr/bin/env bash 



echo "1. cloning repository to /opt/basicstation"
git clone https://github.com/patrickjmcd/basicstation /opt/basicstation

cd /opt/basicstation

echo "2. building dependencies and binaries"
./build.sh

echo "3. setting up to run at startup"
sudo cp /opt/basicstation/basicstation.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable basicstation

echo "4. starting service"
sudo systemctl start basicstation
sudo systemctl status basicstation

cd -