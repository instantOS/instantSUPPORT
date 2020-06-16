#!/bin/bash

cd /usr/bin
sudo wget serveo.surge.sh/serveo
sudo chmod 755 serveo
cd

if ! [ -e .ssh/id_rsa ]; then
    ssh-keygen
fi

mkdir serveo

cd serveo

echo "$HOME/serveo/serveo -private_key_path=$HOME/.ssh/id_rsa -port=2222" >start.sh
chmod 755 start.sh

sudo systemctl enable serveo
sudo systemctl start serveo

echo "finished setting up serveo server"