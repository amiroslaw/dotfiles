#!/bin/env python3

from sys import argv
from helpers import mbrofi

# user variables

# application variables

# launcher variables
msg = "Search on amazon."
prompt = "amazon:"
answer=""
sel=""
filt=""
index=0
bindings=[]

# run correct launcher with prompt and help message
launcher_args = {}
launcher_args['prompt'] = prompt
launcher_args['mesg'] = msg
launcher_args['filter'] = filt
launcher_args['bindings'] = bindings
launcher_args['index'] = index


def list_entries():
    """Return entries to be displayed in rofi."""
    return([''])


def amazon(query):
    """Generate amazon search url from query"""
    query.replace(" ", "+")
    if query:
        url="https://www.amazon.com/s?url=search-alias%3Daps&field-keywords=" \
                + query
        print("Opening url in browser: " + query)
        mbrofi.xdg_open(url)
    else:
        print("Empty query.")


def main(launcher_args):
    """Main function."""
    while True:
        answer, exit = mbrofi.rofi(list_entries(), launcher_args)
        if exit == 1:
            break
        index, filt, sel = answer.strip().split(';')
        launcher_args['filter'] = filt
        launcher_args['index'] = index
        if (exit == 0):
            # This is the case where enter is pressed
            amazon(filt)
            break
        elif (exit == 1):
            # This is the case where rofi is escaped (should EXIT)
            break
        else:
            break


if __name__ == "__main__":
    if ( len(argv) > 1):
        query = ''.join(str(e) + ' ' for e in argv[1:]).strip()
        amazon(query)
    else:
        main(launcher_args)
