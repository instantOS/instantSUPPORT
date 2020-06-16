#!/bin/bash

sudo pacman -Sy --needed --noconfirm autossh tmux
if ! whoami | grep -q '^root$'; then
	echo "please run this as root"
	exit
fi

# todo: create support user
# todo: tmux wrapper
addsupport() {
	if grep -q 'instantsupport' /etc/sudoers; then
		echo "support user already existing"
		return
	fi
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

addsupport
while ! [ -e /tmp/nosupport ]; do
	autossh -M 0 -R "${1:-8080}":localhost:22 support.paperbenni.xyz
done

sudo -u support tmux new -s supportsession
sudo -u support tmux new -s supportsession
removesupport
pkill autossh
