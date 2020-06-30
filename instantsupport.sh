#!/bin/bash

if [ -e /tmp/nosupport ]; then
	echo "instantsupport might already be running. Run"
	echo "sudo rm /tmo/nosupport"
	echo "to force run instantsupport"
	exit
fi

if ! whoami | grep -q '^root$'; then
	echo "please run this as root (with sudo)"
	exit
fi

if command -v pacman; then
	if command -v autossh && command -v tmux; then
		echo "starting"
	else
		sudo pacman -Sy --needed --noconfirm autossh tmux
	fi
else
	echo "it is recommended to run instantSUPPOR on an arch based system. "
	echo "you may have to manuall install autossh and tmux"
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

if command -v systemctl; then
	if ! systemctl is-active sshd; then
		systemctl enable sshd
		systemctl start sshd
	fi
elif command -v rc-service; then
	rc-service sshd start
fi

addsupport

while :; do
	if ! [ -e /tmp/nosupport ]; then
		autossh -o StrictHostKeyChecking=no -M 0 -R "${1:-8080}":localhost:22 support.paperbenni.xyz -p 2222
		sleep 10
	else
		echo "ssh session ended"
		rm /tmp/nosupport
		exit
	fi
done &

sudo -u support tmux new -s supportsession
# sudo -u support tmux attach-session -t supportsession
removesupport

echo "quitting instantsupport"
while pgrep autossh; do
	echo "disconnecting ssh"
	pkill autossh
	sleep 1
done
