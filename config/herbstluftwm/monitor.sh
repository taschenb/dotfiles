#! /bin/sh
# Setup monitors for herbstluftwm
#
# Set the default resolution on all connected monitors.
# On the main monitor, pad for the panel.
#
# The main monitor is the first display that is not LVDS1, or in case there is
# no such display, LVDS1.
# This makes the external display of the notebook to main and if there is no
# external display, the notebook display itself is being used

PAD_HEIGHT=18

notebook_monitor=$(xrandr | awk '/LVDS.?1 connected/ { print $1; }')
main_monitor=$(xrandr | awk '/ connected/ { print $1; }' | \
                grep -v LVDS | \
                sed -n '1p')

# Disable all disconnected outputs for better detection by hc
xrandr | awk '/disconnected/ { print $1; }' | \
    while read -r output; do
        xrandr --output "$output" --off
    done

if [ $main_monitor ]; then
    xrandr --output $main_monitor --above $notebook_monitor --auto

    herbstclient detect_monitors

    # Pad to make room for polybar.
    # The Ordering of the monitors is chronologically, which leads to
    # the hc-monitor 0 to correspond to notebook one (LVDS-1)
    herbstclient pad 0 0            # Notebook (LVDS)
    herbstclient pad 1 $PAD_HEIGHT  # Main monitor
else
    herbstclient detect_monitors

    herbstclient pad 0 $PAD_HEIGHT
fi

# Set the background to scale correctly
if which feh > /dev/null 2>&1; then
    background=~/.config/herbstluftwm/background.jpg
    [ -f "$background" ] && feh --bg-scale "$background"
fi
