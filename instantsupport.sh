#!/bin/bash

sudo pacman -Sy --needed --noconfirm autossh tmux
if ! whoami | grep -q '^root$'; then
	echo "please run this as root"
	exit
fi

# todo: create support user
# todo: tmux wrapper
addsupport() {
	if sudo grep -q 'instantsupport' /etc/sudoers; then
		echo "support user already existing"
		return
	fi
	sudo useradd -m "support" -s /usr/bin/zsh -G wheel,docker,video
	sudo echo "support:support" | chpasswd
	sudo echo "support ALL=(ALL) NOPASSWD: ALL #instantsupport" >>/etc/sudoers
}

removesupport() {
	sudo sed -i '/.*NOPASSWD/d' /etc/sudoers
}

if systemctl is-active sshdsystemctl is-active sshd; then
	systemctl enable sshd
	systemctl start sshd
fi

sudo addsupport
while ! [ -e /tmp/nosupport ]; do
	autossh -M 0 -R "${1:-8080}":localhost:22 support.paperbenni.xyz -p 2222
	sleep 1
done &

sudo -u support tmux new -s supportsession
sudo -u support tmux new -s supportsession
sudo removesupport
pkill autossh
