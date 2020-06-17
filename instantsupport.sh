#!/bin/bash

if ! whoami | grep -q '^root$'; then
	echo "please run this as root (with sudo)"
	exit
fi

if command -v autossh && command -v tmux; then
	echo "starting"
else
	sudo pacman -Sy --needed --noconfirm autossh tmux
fi

# todo: create support user
# todo: tmux wrapper
addsupport() {
	if grep -q 'instantsupport' /etc/sudoers; then
		echo "support user already set up"
		return
	fi

	if getent passwd | grep -q '^support:'; then
		echo "user support already existing"
		return
	fi

	groupadd docker
	groupadd video
	groupadd wheel
	useradd -m "support" -s /usr/bin/zsh -G wheel,docker,video
	echo "support:support" | chpasswd
	echo "support ALL=(ALL) NOPASSWD: ALL #instantsupport" >>/etc/sudoers
}

removesupport() {
	touch /tmp/nosupport
	sed -i '/.*NOPASSWD/d' /etc/sudoers
}

if ! systemctl is-active sshd; then
	systemctl enable sshd
	systemctl start sshd
fi

addsupport
while ! [ -e /tmp/nosupport ]; do
	autossh -M 0 -R "${1:-8080}":localhost:22 support.paperbenni.xyz -p 2222
	sleep 1
done &

sudo -u support tmux new -s supportsession
sudo -u support tmux attach-session -t supportsession
removesupport
pkill autossh
sleep 1
rm /tmp/nosupport
