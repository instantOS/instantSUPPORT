#!/bin/bash

# install everything needed for the instantSUPPORT server

if ! command -v serveo; then
    cd /usr/bin
    sudo wget serveo.surge.sh/serveo
    sudo chmod 755 serveo
fi
cd

if ! [ -e .ssh/id_rsa ]; then
    ssh-keygen
fi

mkdir serveo

cd serveo

echo "/usr/bin/serveo -private_key_path=$HOME/.ssh/id_rsa -port=2222" >start.sh
chmod 755 start.sh

curl -s https://raw.githubusercontent.com/instantOS/instantSUPPORT/master/serveo.service |
    sed "s~HOME~$HOME~g" | sudo tee /etc/systemd/system/serveo.service

sudo systemctl enable serveo
sudo systemctl start serveo

echo "finished setting up serveo server"
