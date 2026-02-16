#!/bin/bash

# Sources:
# lepsze ustawienie
# https://leho.kraav.com/blog/combine-xf86-input-evdev-middle-button-wheel-emulation-kensington-orbit-trackball/
# - https://help.ubuntu.com/community/Logitech_Marblemouse_USB
# - https://wiki.archlinux.org/index.php/Mouse_acceleration
# - https://leho.kraav.com/blog/combine-xf86-input-evdev-middle-button-wheel-emulation-kensington-orbit-trackball/
# list the peripherals, note the good number with the device name of the mouse!
#   xinput list
# list parameters from peripheral number 9
#   xinput list-props 9

# Remap for trackpoint
dev="PS/2 Generic Mouse"
dev="$(xinput | grep "$dev\s*.*pointer" | sed -r 's/.*id=(\S+)\s+.*/\1/')"

# Accel Speed
xinput --set-prop "$dev" 'libinput Accel Speed' 1.0
# xinput --set-prop "$dev" 'libinput Accel Speed Default' 0.9

# Enables  middle button emulation. When enabled, pressing the left and right buttons simultaneously produces a middle mouse button click.
xinput --set-prop "$dev" 'libinput Middle Emulation Enabled' 1
# scroll with right button
xinput --set-prop "$dev" 'libinput Button Scrolling Button' 3


# 	libinput Scroll Method Enabled (295):	0, 0, 1
# Aliases to keep what follows concise
# we="Evdev Wheel Emulation"
# tbe="Evdev Third Button Emulation"

# Enable Third Button Emulation so Right-Click is press-hold for more than
# 300ms on the left button while moving less than 2px

#xinput set-prop "$dev" "$tbe" 1
#xinput set-prop "$dev" "$tbe Timeout" 300
#xinput set-prop "$dev" "$tbe Button" 2

# Enable Wheel Emulation on the right button and make it a bit less sensitive
# so it can be comfortably used with things like tab-switching which expect
# detent-by-detent precision
# xinput set-prop "$dev" "$we" 1
# xinput set-prop "$dev" "$we Button" 3
# xinput set-prop "$dev" "$we Inertia" 25
# xinput set-prop "$dev" "$we Axes" 6 7 4 5


# Device 'Kensington USB Orbit':
# 	Coordinate Transformation Matrix (158):	1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000
# 	libinput Natural Scrolling Enabled (292):	0
# 	libinput Natural Scrolling Enabled Default (293):	0
# 	libinput Scroll Methods Available (294):	0, 0, 1
# 	libinput Scroll Method Enabled (295):	0, 0, 1
# 	libinput Scroll Method Enabled Default (296):	0, 0, 1
# 	libinput Button Scrolling Button (297):	3
# 	libinput Button Scrolling Button Default (298):	2
# 	libinput Button Scrolling Button Lock Enabled (299):	0
# 	libinput Button Scrolling Button Lock Enabled Default (300):	0
# 	libinput Middle Emulation Enabled (301):	0
# 	libinput Middle Emulation Enabled Default (302):	0
# 	libinput Accel Speed (303):	0.900000
# 	libinput Accel Speed Default (304):	0.000000
# 	libinput Accel Profiles Available (305):	1, 1
# 	libinput Accel Profile Enabled (306):	1, 0
# 	libinput Accel Profile Enabled Default (307):	1, 0
# 	libinput Left Handed Enabled (308):	0
# 	libinput Left Handed Enabled Default (309):	0
# 	libinput Send Events Modes Available (277):	1, 0
# 	libinput Send Events Mode Enabled (278):	0, 0
# 	libinput Send Events Mode Enabled Default (279):	0, 0
# 	Device Node (280):	"/dev/input/event20"
# 	Device Product ID (281):	1149, 4130
# 	libinput Drag Lock Buttons (310):	<no items>
# 	libinput Horizontal Scroll Enabled (311):	1
