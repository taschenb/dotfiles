#! /bin/sh
# Play the URL currently in the clipboard with mpv
#
# Dependency: mpv, xclip

if which mpv > /dev/null 2>&1; then
    if which xclip > /dev/null 2>&1; then
	/usr/bin/mpv $(xclip -o)
    fi
fi
