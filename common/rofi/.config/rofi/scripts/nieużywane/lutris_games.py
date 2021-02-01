#!/bin/env python3

import os
import sys
from subprocess import Popen, PIPE
from operator import itemgetter
from distutils.spawn import find_executable

from lutris import pga
#from lutris.services.steam import (AppManifest, get_appmanifests,
#get_steamapps_paths)

from helpers import mbrofi


# user variables

BIND_INSTALL = 'alt-u'
BIND_STEAM = 'alt-s'
STEAM_ONLY = False
LUTRIS_EXE = 'lutris'
script_id = 'lutris'
mbconfig = mbrofi.parse_config()
if script_id in mbconfig:
    lconf = mbconfig[script_id]
    BIND_INSTALL = lconf.get("bind_install", fallback='alt-u')
    BIND_STEAM = lconf.get("bind_steam", fallback='alt-s')
    STEAM_ONLY = lconf.getboolean("steam_only", fallback=False)
    LUTRIS_EXE = lconf.get('lutris_exe', fallback='lutris')


# application variables
bindings = ["alt+h"]
bindings += [BIND_INSTALL]
bindings += [BIND_STEAM]

# list of strings to use in the help menu for each binding.
BIND_HELPLIST = ["Show help menu."]
BIND_HELPLIST += ["Show uninstalled games."]
BIND_HELPLIST += ["Show only steam games."]

# launcher variables
msg = "Enter to game. alt-h for help."
prompt = "lutris:"
answer = ""
sel = ""
filt = ""
index = 0

# run correct launcher with prompt and help message
launcher_args = {}
launcher_args['prompt'] = prompt
launcher_args['mesg'] = msg
launcher_args['filter'] = filt
launcher_args['bindings'] = bindings
launcher_args['index'] = index

def get_installed_games():
    """Get a list of installed games via lutris. Each game is a dict."""
    games_list = pga.get_games()
    glist = []
    for game in games_list:
        if game['installed']:
            glist.append(game)
    return(glist)


def get_uninstalled_games():
    """Get a list of installed games via lutris. Each game is a dict."""
    games_list = pga.get_games()
    glist = []
    for game in games_list:
        if not game['installed']:
            glist.append(game)
    return(glist)


def generate_entries(games_list):
    """Generate entries for rofi based on a game list obtained via 
    pga.get_games()
    """
    display_list = []
    name_plen = 40
    for game in games_list:
        game_name = game['name']
        if len(game_name) > name_plen-2:
            game_name = game_name[:name_plen-1] + '…'
        if game['runner']:
            dispname = game_name.ljust(name_plen) + game['runner']
        else:
            dispname = game_name.ljust(name_plen)
        display_list.append(dispname)
    return(display_list)


def show_install_menu(return_key):
    """Show a rofi menu with uninstalled games. Right now it doesn't isntall
    them.
    """
    games_list = get_uninstalled_games()
    display_list = generate_entries(games_list)
    largs = {}
    largs['prompt'] = "lutris (uninstalled):"
    largs['mesg'] = "See uninstalled games (does not install them). Press '"
    largs['mesg'] += return_key +  "' to go back."
    largs['bindings'] = [return_key]
    largs['format'] = 'i'
    ans, exit = mbrofi.rofi(display_list, largs, ['-i'])
    if (exit == 1):
        sys.exit(1)
    elif (exit == 10) or (not ans):
        return(True)
    else:
        return(True)


def main():
    """Main function."""
    steam_only = False
    while True:
        games_list = get_installed_games()
        if steam_only:
            tmp_list = []
            for game in games_list:
                if game['runner'] == 'steam':
                    tmp_list.append(game)
            games_list = tmp_list
            launcher_args['prompt'] = "lutris (steam_only):"
        else:
            launcher_args['prompt'] = "lutris:"
        display_list = generate_entries(games_list)
        answer, exit = mbrofi.rofi(display_list, launcher_args, ['-i'])
        if exit != 1:
            index, filt, sel = answer.strip().split(';')
            launcher_args['filter'] = filt
            launcher_args['index'] = index
        else:
            break
        print("index:", str(index))
        print("filter:", filt)
        print("selection:", sel)
        print("exit:", str(exit))
        print("------------------")


        if (exit == 0):
            selected_game = games_list[int(index)]
            slug = selected_game['slug']
            cmd = []
            cmd.append(LUTRIS_EXE)
            print(selected_game)
            if slug != 'lutris':
                cmd.append('lutris:rungame/' + slug)
            Popen(cmd).communicate()
            break
        elif (exit == 1):
            # this is the case where rofi is escaped (should exit)
            break
        elif (exit == 10):
            message = "List of bindings with descriptions. Press alt-h"
            message += " to go back."
            mbrofi.rofi_help(launcher_args['bindings'], BIND_HELPLIST
                            , prompt='screenshots help:', message=message)
        elif (exit == 11):
            show_install_menu(BIND_INSTALL)
        elif (exit == 12):
            steam_only=(not steam_only)
        else:
            break


if __name__ == "__main__":
    if (len(sys.argv) > 1):
        launcher_args['filter'] = sys.argv[1]
    main()
