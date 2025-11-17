#!/usr/bin/bash

# add text file for every abstract namespace X11 socket
#   the vncserver perl script scans these to check for available displays
for socket in $(ss -l -H --unix src '@/tmp/.X11*' | sed "s/ \+/ /g" | cut -d ' ' -f 5 | sed 's/^@//'); do
    echo "Fake abstract namespace socket $socket"
    mkdir -p $(dirname "$socket")
    echo "Found abstract socket $socket" > "$socket"
    chmod 400 "$socket"
done
~
