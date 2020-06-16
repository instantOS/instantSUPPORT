#!/bin/bash

if ! whoami | grep -q '^root$'; then
	echo "please do not run this as root"
	exit
fi

# todo: create support user
# todo: tmux wrapper
addsupport() {
	useradd -m "support" -s /usr/bin/zsh -G wheel,docker,video
	echo "support:support" | chpasswd
	echo "support ALL=(ALL) NOPASSWD: ALL #instantsupport" >>/etc/sudoers
}

removesupport() {
	sed -i '/.*NOPASSWD/d' /etc/sudoers
}

if systemctl is-active sshdsystemctl is-active sshd; then
	systemctl enable sshd
	systemctl start sshd
fi
