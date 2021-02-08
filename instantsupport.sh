#!/usr/bin/env bash

# basically teamviewer but for ssh and without requiring prior installation
# run using bash <"$(curl -Ls git.io/instantsupport)"

getgrok() {
    if ! uname -m | grep -q 'x86_64'; then
        echo 'architecture not supported'
        exit 1
    fi

    [ -e ~/ngrok ] || mkdir ~/ngrok
    cd ~/ngrok || exit 1
    if ! [ -e ./ngrok ]; then
        if command -v wget; then
            wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.tgz
        else
            curl -O https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.tgz
        fi
        tar zxvf ./*.tgz
        rm ./*.tgz
    fi
    curl -s https://pastebin.com/raw/Qr78VtxB >tokens.txt
    TRYTOKEN="$(shuf tokens.txt | head -1)"
    [ -e ~/.ngrok2 ] || mkdir ~/.ngrok2
    echo "authtoken: $TRYTOKEN" >~/.ngrok2/ngrok.yml
    echo 'setting up the connection, please wait...'
}

if [ -e /tmp/nosupport ]; then
    echo "instantsupport might already be running. Run"
    echo "sudo rm /tmp/nosupport"
    echo "to force run instantsupport"
    exit
fi

if ! whoami | grep -q '^root$'; then
    echo "please run this as root (with sudo)"
    exit
fi

if command -v pacman; then
    if command -v tmux; then
        echo "starting"
    else
        sudo pacman -Sy --needed --noconfirm tmux
    fi
else
    echo "it is recommended to run instantSUPPORT on an arch based system. "
    echo "you may have to manuall install tmux"
fi

addsupport() {
    if grep -q 'instantsupport' /etc/sudoers; then
        echo "support user already set up"
        return
    fi

    if getent passwd | grep -q '^instantsupport:'; then
        echo "user support already existing"
        return
    fi

    groupadd docker &>/dev/null
    groupadd video &>/dev/null
    groupadd wheel &>/dev/null

    useradd -m "instantsupport" -s /usr/bin/zsh -G wheel,docker,video
    echo "instantsupport:support" | chpasswd
    echo "instantsupport ALL=(ALL) NOPASSWD: ALL #instantsupport" >>/etc/sudoers
}

removesupport() {
    touch /tmp/nosupport
    sed -i '/.*NOPASSWD/d' /etc/sudoers
    killall -u instantsupport
    sleep 2
    if ps -u instantsupport; then
        killall -u instantsupport
    fi
    userdel instantsupport
}

if command -v systemctl; then
    if ! systemctl is-active sshd; then
        systemctl enable sshd
        systemctl start sshd
    fi
    if ! systemctl is-active NetworkManager; then
        systemctl enable NetworkManager
        systemctl start NetworkManager
    fi

elif command -v rc-service; then
    rc-service sshd start
fi

addsupport

while :; do
    if ! [ -e /tmp/nosupport ]; then
        getgrok
        ~/ngrok/ngrok tcp -region us -log stderr 22 &>/tmp/ngroklog
        sleep 0.3
        while pgrep ngrok; do
            sleep 0.4
        done
    else
        echo "ssh session ended"
        pkill ngrok
        sleep 1
        rm /tmp/nosupport
        exit
    fi
done &

while [ -z "$NGROKURL" ]; do
    NGROKURL="$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'public_url":"[^"]*"' | grep -o '"[^"]*"$' | grep -o '[^"]*')"
    NGROKPORT="$(grep -o '[0-9]*$' <<<"$NGROKURL")"
    NGROKSERVER="$(grep -o '[0-9]*.tcp.ngrok' <<<"$NGROKURL" | grep -o '[0-9]*')"
    sleep 1
done

sudo -u instantsupport tmux new-session -s supportsession "echo '
 _           _              _   ____  _   _ ____  ____   ___  ____ _____
(_)_ __  ___| |_ __ _ _ __ | |_/ ___|| | | |  _ \|  _ \ / _ \|  _ \_   _|
| |  _ \/ __| __/ _  |  _ \| __\___ \| | | | |_) | |_) | | | | |_) || |
| | | | \__ \ || (_| | | | | |_ ___) | |_| |  __/|  __/| |_| |  _ < | |
|_|_| |_|___/\__\__,_|_| |_|\__|____/ \___/|_|   |_|    \___/|_| \_\|_|


your code is $NGROKSERVER$NGROKPORT

securely send it to the person giving support
please do not close or interact with this window
until the support person has connected'; bash" \; \
    split-window "echo 'shell to write stuff in' ; bash" \; \
    select-layout even-vertical

# sudo -u support tmux attach-session -t supportsession
sleep 1
removesupport

echo "quitting instantsupport"
while pgrep ngrok; do
    echo "disconnecting ssh"
    pkill ngrok
    sleep 1
done
