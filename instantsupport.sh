#!/bin/bash

if ! whoami | grep -q '^root$'; then
	echo "please do not run this as root"
	exit
fi

# todo: create support user
# todo: tmux wrapper

if systemctl is-active sshdsystemctl is-active sshd; then
	systemctl enable sshd
	systemctl start sshd
fi
