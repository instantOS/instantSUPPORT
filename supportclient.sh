#!/bin/bash

# client for providing support over instantSUPPORT

if [ -n "$1" ]; then
    PASSCODE="$1"
else
    PASSCODE="$(imenu -i 'input passcode')"
fi

[ -z "$PASSCODE" ] && exit 1

SERVERNUMBER="$(grep -o '^.' <<< "$PASSCODE")"
SERVERPORT="$(sed 's/^.//g' <<< "$PASSCODE")"

sshpass -p support ssh -o StrictHostKeyChecking=no instantsupport@"$SERVERNUMBER".tcp.ngrok.io -p "$SERVERPORT" -t "tmux attach-session -t supportsession"
