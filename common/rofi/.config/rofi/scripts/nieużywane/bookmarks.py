#!/bin/env python3

import sys
import os
from helpers import mbrofi
from subprocess import Popen

# user variables

# application variables
bookmark_directory = '~/bookmarks/'
BIND_NEW = 'alt-n'
BIND_DEL = 'alt-d'
BIND_CHGURL = 'alt-u'
BIND_RENAME = 'alt-r'
script_id = 'bookmarks'
mbconfig = mbrofi.parse_config()
BROWSER = mbconfig['mbmain'].get('browser', fallback='firefox')
if script_id in mbconfig:
    lconf = mbconfig[script_id]
    bookmark_directory = lconf.get("bookmark_directory",
                                   fallback='~/bookmarks/')
    BIND_NEW = lconf.get('bind_new', fallback=BIND_NEW)
    BIND_DEL = lconf.get('bind_del', fallback=BIND_DEL)
    BIND_CHGURL = lconf.get('bind_chgurl', fallback=BIND_CHGURL)
    BIND_RENAME = lconf.get('bind_rename', fallback=BIND_RENAME)

BOOKMARK_DIRECTORY = os.path.expanduser(bookmark_directory)

bindings = ["alt+h"]
bindings += [BIND_NEW]
bindings += [BIND_DEL]
bindings += [BIND_RENAME]
bindings += [BIND_CHGURL]

BIND_HELPLIST = ["Show help menu."]
BIND_HELPLIST += ["Create new bookmark."]
BIND_HELPLIST += ["Bookmark bookmark."]
BIND_HELPLIST += ["Change bookmark's name."]
BIND_HELPLIST += ["Change bookmark's url."]

# launcher variables
msg = "Press Enter to open bookmark. "
msg += bindings[0] + " to show help."
# msg = "Help text. " + bindings[0] + " does something, " +  \
# bindings[1]  + " does something else."
prompt = "bookmarks:"
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


def new_bookmark(name, url):
    """ Create a new bookmark from a name and a url."""
    if '/' in name:
        subdir = name.rsplit('/', 1)[0]
        if subdir:
            subpath = os.path.join(BOOKMARK_DIRECTORY, subdir)
            try:
                os.makedirs(subpath)
            except FileExistsError:
                pass
    book_path = os.path.join(BOOKMARK_DIRECTORY, name)
    if os.path.isfile(book_path):
        print("Bookmark '" + book_path + "' was found...ignoring 'add'")
        return(0)

    bookfile = open(book_path, 'w')
    bookfile.write(url.strip())
    bookfile.close()


def del_bookmark(book_name):
    """ Delete bookmark. Remove subdirectories if they are empty."""
    book_path = os.path.join(BOOKMARK_DIRECTORY, book_name)
    if os.path.isfile(book_path):
        os.remove(book_path)
    if '/' in book_name:
        book_sub = book_name.split('/')[:-1]
        if len(book_sub) > 0:
            for n in range(len(book_sub)):
                cs = ''.join(sd + '/' for sd in book_sub[:len(book_sub)-n])
                subpath = os.path.join(BOOKMARK_DIRECTORY, cs)
                if len(os.listdir(subpath)) < 1:
                    os.rmdir(subpath)


def change_bookmark_url(book_name, new_url):
    """ Change the url for an existing bookmark."""
    book_path = os.path.join(BOOKMARK_DIRECTORY, book_name)
    if not os.path.isfile(book_path):
        print("Bookmark does not exist, ignoring 'change url' request.")
        return(False)
    with open(book_path, 'r+') as bookfile:
        bookfile.seek(0)
        bookfile.write(new_url.strip())
        bookfile.truncate()
        bookfile.close()


def change_bookmark_name(book_name, new_name):
    book_path = os.path.join(BOOKMARK_DIRECTORY, book_name)
    new_path = os.path.join(BOOKMARK_DIRECTORY, new_name)
    if os.path.isfile(new_path):
        print("'" + new_name + "' bookmark already exists. Won't overwrite...")
        return
    if book_path == new_path:
        print("Bookmark name not changed, ignoring 'change name' request.")
        return
    pass
    if '/' in new_name:
        subdir = new_name.rsplit('/', 1)[0]
        if subdir:
            subpath = os.path.join(BOOKMARK_DIRECTORY, subdir)
            try:
                os.makedirs(subpath)
            except FileExistsError:
                pass
    os.rename(book_path, new_path)
    if '/' in book_name:
        book_sub = book_name.split('/')[:-1]
        if len(book_sub) > 0:
            for n in range(len(book_sub)):
                cs = ''.join(sd + '/' for sd in book_sub[:len(book_sub)-n])
                subpath = os.path.join(BOOKMARK_DIRECTORY, cs)
                if len(os.listdir(subpath)) < 1:
                    os.rmdir(subpath)


def open_bookmark(name):
    book_path = os.path.join(BOOKMARK_DIRECTORY, name)
    print('name: ' + name)
    print('path: ' + book_path)
    if not os.path.isfile(book_path):
        print("Bookmark '" + name + "' was not found...ignoring 'open'")
        return(False)

    bookfile = open(book_path, 'r')
    url = bookfile.readline()
    bookfile.close()
    print('url: ' + url)
    Popen([BROWSER, url]).communicate()
    return(True)


def rofi_add_bookmark(book_name=None, book_url=None,  abort_key=None):
    """ Ask a few questions via rofi to get the bookmark name and url, necessary
    to create a new bookmark. If valid, the bookmark is created.
    """
    add_args = {}
    add_args['prompt'] = "bookmark name:"
    add_args['mesg'] = "Write bookmark name."
    add_args['format'] = 'f'
    if abort_key is not None:
        print(abort_key)
        add_args['bindings'] = [abort_key]
    if book_name is None:
        answer, exit = mbrofi.rofi([''], add_args)
        if exit == 0 and answer is not None:
            book_name = answer.strip()
        elif exit == 1:
            sys.exit()
        else:
            return(0)
    if book_url is None:
        add_args['prompt'] = "bookmark url:"
        add_args['mesg'] = "Creating bookmark '" + book_name + "'. "
        add_args['mesg'] += "Write bookmark url."
        answer, exit = mbrofi.rofi([''], add_args)
        if exit == 0 and answer is not None:
            book_url = answer.strip()
        elif exit == 1:
            sys.exit()
        else:
            return(0)

    if book_name.strip() and book_url.strip():
        new_bookmark(book_name, book_url)


def rofi_change_url_bookmark(book_name, abort_key=None):
    book_path = os.path.join(BOOKMARK_DIRECTORY, book_name)
    bookfile = open(book_path, 'r')
    old_url = bookfile.readline()
    bookfile.close()
    change_args = {}
    change_args['prompt'] = "bookmark url:"
    change_args['mesg'] = "Changing url for bookmark '" + book_name + "'"
    change_args['filter'] = old_url
    change_args['format'] = 'f'
    if abort_key is not None:
        change_args['bindings'] = [abort_key]
    answer, exit = mbrofi.rofi([old_url], change_args)
    print(answer)
    if exit == 1:
        sys.exit(1)
    elif exit == 0 and answer:
        new_url = answer.strip()
        if new_url == old_url:
            print("Url not changed.")
            return(False)
        change_bookmark_url(book_name, new_url)
    else:
        return(False)


def rofi_change_name_bookmark(book_name, abort_key=None):
    book_path = os.path.join(BOOKMARK_DIRECTORY, book_name)
    if not os.path.isfile(book_path):
        print("No file selected for rename. Ignoring...")
        return
    change_args = {}
    change_args['prompt'] = "bookmark name:"
    change_args['mesg'] = "Changing name for bookmark '" + book_name + "'"
    change_args['filter'] = book_name
    change_args['format'] = 'f'
    if abort_key is not None:
        change_args['bindings'] = [abort_key]
    answer, exit = mbrofi.rofi([book_name], change_args)
    if exit == 1:
        sys.exit(1)
    elif exit == 0 and answer:
        new_name = answer.strip()
        if new_name == book_name:
            print("Url not changed.")
            return(False)
        change_bookmark_name(book_name, new_name)
    else:
        return(False)


def main(launcher_args):
    """Main function."""
    BFR = mbrofi.FileRepo(dirpath=BOOKMARK_DIRECTORY)
    BFR.scan_files(recursive=True)
    while True:
        answer, exit = mbrofi.rofi(BFR.filenames(), launcher_args)
        if exit == 1:
            return(0)
        index, filt, sel = answer.strip().split(';')
        print("index:", str(index))
        print("filter:", filt)
        print("selection:", sel)
        print("exit:", str(exit))
        print("------------------")

        launcher_args['filter'] = filt
        launcher_args['index'] = index
        if (exit == 0):
            # This is the case where enter is pressed
            if int(index) < 0:
                rofi_add_bookmark(book_name=filt.strip(), abort_key=BIND_NEW)
                launcher_args['filter'] = ''
                BFR.scan_files(recursive=True)
            else:
                open_bookmark(sel.strip())
                break
        elif exit == 10:
            helpmsg_list = BIND_HELPLIST
            mbrofi.rofi_help(bindings, helpmsg_list, prompt='bookmarks help:')
        elif exit == 11:
            if filt:
                rofi_add_bookmark(book_name=filt.strip(), abort_key=BIND_NEW)
                launcher_args['filter'] = ''
                BFR.scan_files(recursive=True)
            else:
                rofi_add_bookmark(abort_key=BIND_NEW)
                launcher_args['filter'] = ''
                BFR.scan_files(recursive=True)
        elif exit == 12:
            if int(index) < 0:
                print("No bookmark selected for deletion...ignoring")
                continue
            bookmark = sel.strip()
            ans = mbrofi.rofi_ask("Are you sure you want to delete bookmark " +
                                  "'" + bookmark + "'?",
                                  prompt='delete bookmark:',
                                  abort_key=BIND_DEL)
            if ans:
                del_bookmark(bookmark)
                BFR.scan_files(recursive=True)
        elif exit == 13:
            rofi_change_name_bookmark(sel.strip(), BIND_RENAME)
            BFR.scan_files(recursive=True)
        elif exit == 14:
            rofi_change_url_bookmark(sel.strip(), BIND_CHGURL)
        else:
            break


if __name__ == '__main__':
    if not os.path.isdir(BOOKMARK_DIRECTORY):
        print("Bookmark directory does not exist at '" + BOOKMARK_DIRECTORY +
              "', creating it...")
        os.makedirs(BOOKMARK_DIRECTORY)
    main(launcher_args)
    # print('add')
    # print('---')
    # add_bookmark('hello', 'world')
    # print()
    # print('open')
    # print('----')
    # open_bookmark('hello')
