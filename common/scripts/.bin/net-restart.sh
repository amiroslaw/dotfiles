#!/bin/bash

modprobe -r ath9k_htc  
modprobe ath9k_htc

# maybe it is not necessary
# nmcli device wifi connect WIFIDOM password $(awk '{print $2}' /home/miro/Documents/Ustawienia/stow-private/wifi)
# nmcli device wifi connect WIFIDOM password $(awk '{print $2}' $USER_HOME/Documents/dotfiles/private/wifi)

