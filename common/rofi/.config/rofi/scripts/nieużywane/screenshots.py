#!/bin/env python3

import os
import sys
from subprocess import Popen, PIPE

from helpers import mbrofi

# user variables

screenshot_directory='~/Pictures/screenshots/'
BIND_UPLOAD = 'alt-u'
BIND_PREVIEW = 'alt-p'
BIND_RENAME = 'alt-r'
BIND_SORTNAME = 'alt-1'
BIND_SORTDATE = 'alt-2'
BIND_SORTSIZE = 'alt-3'
script_id = 'screenshots'
mbconfig = mbrofi.parse_config()
if script_id in mbconfig:
    lconf = mbconfig[script_id]
    screenshot_directory = lconf.get("screenshot_directory"
                                        , fallback='~/Pictures/screenshots')
    BIND_UPLOAD = lconf.get("bind_upload", fallback='alt-u')
    BIND_PREVIEW = lconf.get("bind_preview", fallback='alt-p')
    BIND_RENAME = lconf.get("bind_rename", fallback='alt-r')
    BIND_SORTNAME = lconf.get("bind_sortname", fallback='alt-1')
    BIND_SORTDATE = lconf.get("bind_sortdate", fallback='alt-2')
    BIND_SORTSIZE = lconf.get("bind_sortsize", fallback='alt-3')


# application variables
bindings = ["alt+h"]
bindings += [BIND_UPLOAD]
bindings += [BIND_PREVIEW]
bindings += [BIND_RENAME]
bindings += [BIND_SORTNAME]
bindings += [BIND_SORTDATE]
bindings += [BIND_SORTSIZE]

# list of strings to use in the help menu for each binding.
BIND_HELPLIST = ["Show help menu."]
BIND_HELPLIST += ["Upload screenshot."]
BIND_HELPLIST += ["Preview using external browser, and return to script after."]
BIND_HELPLIST += ["Rename screenshot"]
BIND_HELPLIST += ["Sort list by name, press again to toggle order."]
BIND_HELPLIST += ["Sort list by date, press again to toggle order."]
BIND_HELPLIST += ["Sort list by size, press again to toggle order."]

# launcher variables
msg = "Enter to open screenshot. alt-h for help."
prompt = "screenshots:"
answer = ""
sel = ""
filt = ""
index = 0
SCREENSHOT_DIRECTORY = os.path.expanduser(screenshot_directory)

if not (os.path.isdir(SCREENSHOT_DIRECTORY)):
    print('Creating ' + SCREENSHOT_DIRECTORY + '...')
    os.makedirs(SCREENSHOT_DIRECTORY)

# run correct launcher with prompt and help message
launcher_args = {}
launcher_args['prompt'] = prompt
launcher_args['mesg'] = msg
launcher_args['filter'] = filt
launcher_args['bindings'] = bindings
launcher_args['index'] = index


def rename_screenshot(filename):
    """Rename screenshot."""
    filepath=os.path.join(SCREENSHOT_DIRECTORY, filename)
    if not os.path.isfile(filepath):
        print("Screenshot " + filepath + " not found...")

    msg2 = "Rename " + filepath + ". Write new name and press enter."
    prompt2 = "screenshots (rename):"
    newsel, ext = filename.split('.')
    command = ['rofi', '-dmenu', '-p', prompt2, '-mesg', msg2, '-format', 'f',
                '-filter', newsel]

    proc = Popen(command, stdout=PIPE)
    ans = proc.stdout.read().decode("utf-8")
    exit_code = proc.wait()

    if ans == '':
        return(False)
    if exit_code == 1:
        return(False)
    if ans.strip():
        newname = ans.strip() + '.' + ext
        newpath = os.path.join(SCREENSHOT_DIRECTORY, newname)
        if os.path.isfile(newpath):
            emsg = "file '" + filepath + "' exists, can't rename '" + filename
            emsg += "' to '" + newname + "'."
            print(emsg)
            mbrofi.rofi_warn(emsg)
        else:
            print("   " + filename + " to " + newname + ".")
            os.rename(filepath, newpath)
            return(True)


def main_rofi_function(elist):
    """Call main rofi function and return the selection, filter, selection
    index, and exit code. Don't return any of these in case of rofi being 
    escaped.
    """
    answer, exit = mbrofi.rofi(elist, launcher_args)
    if exit == 1:
        return(False, False, False, 1)
    index, filt, sel = answer.strip().split(';')
    return(index, filt, sel, exit)


def main():
    """Main function."""
    SFR = mbrofi.FileRepo(dirpath=SCREENSHOT_DIRECTORY)
    SFR.scan_files(recursive=False)
    sortby="cdate"
    sortrev=False
    sortchar=""
    SFR.sort(sortby, sortrev)
    while True:
        if sortrev:
            sortchar = "^"
        else:
            sortchar = "v"
        launcher_args['mesg'] =  msg + " sorted by: " + \
                                sortby + "[" + sortchar + ']'
        index, filt, sel, exit = main_rofi_function(SFR.filenames())
        print("index:", str(index))
        print("filter:", filt)
        print("selection:", sel)
        print("exit:", str(exit))
        print("------------------")

        launcher_args['filter'] = filt
        launcher_args['index'] = index

        if (exit == 0):
            filepath=os.path.join(SCREENSHOT_DIRECTORY, sel)
            # This is the case where enter is pressed
            if os.path.isfile(filepath):
                mbrofi.xdg_open(filepath)
            break
        elif (exit == 1):
            # this is the case where rofi is escaped (should exit)
            break
        elif (exit == 10):
            message = "List of bindings with descriptions. Press alt-h"
            message += " to go back. Screenshot directory: '"
            message += SCREENSHOT_DIRECTORY + "'"
            mbrofi.rofi_help(launcher_args['bindings'], BIND_HELPLIST
                            , prompt='screenshots help:', message=message)
        elif (exit == 11):
            print('uploading ' + sel)
            pasteurl = mbrofi.upload_ptpb(SCREENSHOT_DIRECTORY, sel
                                        , notify_bool=True, name="Screenshot")
            if pasteurl:
                pasteurl = pasteurl.strip()
                mbrofi.clip(pasteurl)
            break
        elif (exit == 12):
            filepath=os.path.join(SCREENSHOT_DIRECTORY, sel)
            print('Previewing' + filepath)
            if os.path.isfile(filepath):
                mbrofi.xdg_open(filepath)
            SFR.scan_files(recursive=False)
            SFR.sort(sortby, sortrev)
        elif (exit == 13):
            print('renaming ' + sel)
            rename_success = rename_screenshot(sel)
            if rename_success:
                SFR.scan_files(recursive=False)
                SFR.sort(sortby, sortrev)
            else:
                print("meh")
        elif (exit == 14):
            if sortby == "name":
                sortrev = (not sortrev)
            else:
                sortby = "name"
                sortrev = True
            SFR.sort(sortby, sortrev)
        elif (exit == 15):
            if sortby == "cdate":
                sortrev = (not sortrev)
            else:
                sortby = "cdate"
                sortrev = False
            SFR.sort(sortby, sortrev)
        elif (exit == 16):
            if sortby == "size":
                sortrev = (not sortrev)
            else:
                sortby = "size"
                sortrev = True
            SFR.sort(sortby, sortrev)
        else:
            break


if __name__ == "__main__":
    if (len(sys.argv) > 1):
        launcher_args['filter'] = sys.argv[1]
    main()
