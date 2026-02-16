#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Library of tools to create rofi interfaces in python

import os
import sys
from subprocess import Popen, PIPE
import struct
from stat import ST_CTIME, ST_ATIME, ST_MTIME, ST_SIZE
from operator import itemgetter
from datetime import datetime

from configparser import ConfigParser

__version__ = '0.0'
__author__ = 'Martin B. Fraga <mbfraga@gmail.com>'


def sizeof_fmt(num, suffix='B'):
    """Get bit number and return formatted size string"""
    for unit in ['', 'Ki', 'Mi', 'Gi', 'Ti', 'Pi', 'Ei', 'Zi']:
        if abs(num) < 1024.0:
            return "%3.1f%s%s" % (num, unit, suffix)
        num /= 1024.0
    return "%.1f%s%s" % (num, 'Yi', suffix)


def rofi(entries, launcher_arguments=False, additional_args=[]):
    """ Call rofi and return a tuple with rofi's stdout as a string separated
    by newlines, and the exit code of rofi as a string.

    Keyword arguments:
    entries -- list of strings that will be displayed by rofi.
    launcher_arguments -- dictionary with rofi arguments (default False)
        ['prompt'] -- string for rofi prompt
        ['mesg'] -- string for rofi help message. Can be empty.
        ['filter'] -- stirng for filter to set in rofi by default
        ['index'] -- string or int to set the default selected row in rofi
        ['format'] -- set format for rofi output
        ['bindings'] -- list of strings, each a binding like 'alt-n'
    additional_args -- any additional arguments that should be sent to rofi
                        (default [])
    """
    if not launcher_arguments:
        command_args = ["rofi", "-dmenu", "-sep", "\\0", "-format", "i;f;s"]
    else:
        command_args = ["rofi", "-dmenu", "-sep", "\\0"]
        if 'prompt' in launcher_arguments:
            command_args += ["-p", launcher_arguments['prompt']]
        if 'mesg' in launcher_arguments:
            if launcher_arguments['mesg']:
                command_args += ["-mesg", launcher_arguments['mesg']]
        if 'filter' in launcher_arguments:
            command_args += ["-filter", launcher_arguments['filter']]
        if 'index' in launcher_arguments:
            command_args += ["-selected-row", str(launcher_arguments['index'])]
        if 'format' in launcher_arguments:
            command_args += ["-format", launcher_arguments['format']]
        else:
            command_args += ["-format", "i;f;s"]
        if 'bindings' in launcher_arguments:
            kb_ct = 1
            for bind in launcher_arguments['bindings']:
                keyentry = "-kb-custom-" + str(kb_ct)
                command_args += [keyentry, bind]
                kb_ct += 1
    # Run rofi
    proc = Popen(command_args + additional_args, stdin=PIPE, stdout=PIPE)
    # send rofi the entries to display
    for e in entries:
        proc.stdin.write((e).encode('utf-8'))
        proc.stdin.write(struct.pack('B', 0))
    proc.stdin.close()
    # read rofi's output and get the exit code
    answer = proc.stdout.read().decode('utf-8')
    answer = answer.strip()
    exit_code = proc.wait()
    if (answer == ''):
        return(None, exit_code)

    return(answer, exit_code)


def rofi_help(bindings, help_strings, help_binding='alt+h', sep="    ",
              prompt="help:", message=None):
    """Display a rofi menu with bindings and and descriptions on what they do.
    Once Enter/Return or the help_binding is pressed, the help menu is exited.

    Keyword arguments:
    bindings -- list of bindings (e.g., ['alt+o','alt+d'])
    help_strings -- list of strings used as descriptions for corresponding
                    bindings (e.g., ['open file','delete file'])
    help_binding -- binding used to open this menu. It will not be shown in the
                    help menu, and can be used to exit menu.
    sep -- string used as separator between the binding and the help string
           (default "    ")
    prompt -- string used as prompt for rofi (default 'help')
    message -- string used as the message for rofi (default None)
    """
    if len(bindings) != len(help_strings):
        print("Error in rofi_help: list of bindings does not have the same"
              + " length as the list of help_strings.")
        sys.exit(1)

    pretty_list = []
    for n in range(len(bindings)):
        if bindings[n] == help_binding:
            continue
        fbind = bindings[n] + sep + help_strings[n]
        pretty_list.append(fbind)
    if message is None:
        message = "List of bindings with descriptions. Press " + help_binding
        message += " to go back."
    launcher_args = {}
    launcher_args['prompt'] = prompt
    launcher_args['mesg'] = message
    launcher_args['bindings'] = [help_binding]
    ans, exit = rofi(pretty_list, launcher_args)
    if exit == 1:
        sys.exit(1)
    else:
        return(True)


def rofi_warn(message):
    """Display simple message string via rofi."""
    proc = Popen(['rofi', '-e', message])
    proc.communicate()


def rofi_ask(question, prompt=None, abort_key=None):
    """Prompt a yes/no question via rofi, and return a boolean.

    Keyword arguments:
    question - string with question to ask the user.
    prompt - string with prompt to set in rofi (default None).
    abort_key - string with key binding to abort entry (default None).
    """
    launcher_args = {}
    if prompt is not None:
        launcher_args['prompt'] = prompt
    if abort_key is not None:
        launcher_args['bindings'] = [abort_key]
    launcher_args['mesg'] = question
    launcher_args['format'] = 'i'
    answer, exit = rofi(['no', 'yes'], launcher_args)
    if exit == 1:
        return(False)
    if answer == "1":
        return(True)
    else:
        return(False)


def rofi_enter(premise, prompt=None, options=[], dfilter=None, bindings=[]):
    """Use rofi to request an entry from the user. Function returns a tuple
    with the selected entry, and the exit code.

    Keyword arguments:
    premise -- string defining the premise on what the user should enter
    prompt -- string for prompt to use (default None)
    options -- list of options that the user can select from (default [])
    dfilter -- default filter for rofi (default None)
    bindings -- list of extra bindings to accept (default []).
    """
    launcher_args = {}
    if prompt is not None:
        launcher_args['prompt'] = prompt
    if dfilter is not None:
        launcher_args['filter'] = dfilter
    launcher_args['bindings'] = ['alt-Return']
    launcher_args['bindings'].extend(bindings)
    launcher_args['mesg'] = premise
    launcher_args['format'] = 'f;s'
    answer, exit = rofi(options, launcher_args)
    if exit == 1:
        return(None, exit)
    elif exit == 10:
        filt, sel = answer.split(';')
        if filt.strip():
            return(filt.strip(), exit)
        else:
            return(None, exit)
    else:
        filt, sel = answer.split(';')
        if sel.strip():
            return(sel.strip(), exit)
        else:
            return(None, exit)


def notify(title, message=None, duration=4000):
    """Send notification via notify-send.

    Keyword arguments:
    title -- string for title of notification
    message -- string for message (default None)
    duration -- duration of notification (default 4000)
    """
    if message is None:
        proc = Popen(['notify-send', '-t', str(duration), title])
    else:
        proc = Popen(['notify-send', '-t', str(duration), title,  message])
    exit_code = proc.communicate()
    return(exit_code)


def clip(clipstring, selection='both'):
    """Send string to clipboard.

    Keyword arguments:
    clipstring -- string to send to clipboard
    selection -- selection to use (default "both")
        primary, clipbord, both
    """
    if (selection == 'primary' or selection == 'both'):
        proc = Popen(['xclip', '-i', '-selection', 'primary'], stdin=PIPE)
        proc.stdin.write((clipstring.encode('utf-8')))
        proc.stdin.close()
        proc.communicate()
    if (selection == 'clipboard' or selection == 'both'):
        proc = Popen(['xclip', '-i', '-selection', 'clipboard'], stdin=PIPE)
        proc.stdin.write((clipstring.encode('utf-8')))
        proc.stdin.close()
        proc.communicate()


def get_clip(selection="clipboard"):
    """Get string from clipboard."""
    if selection == "clipboard":
        proc = Popen(['xclip', '-o', '-selection', 'clipboard'], stdout=PIPE)
        ans = proc.stdout.read().decode('utf-8')
        proc.stdout.close()
    elif selection == "primary":
        proc = Popen(['xclip', '-o', '-selection', 'primary'], stdout=PIPE)
        ans = proc.stdout.read().decode('utf-8')
        proc.stdout.close()
    else:
        print("get_clip only accepts clipboard or primary arguments")
        sys.exit(1)
    return(ans)


def xdg_open(application, wait=True):
    """Open application using xdg-open.

    Keyword arguments:
    application -- string for application to run.
    wait -- boolean on whether the proc.communicate() should be used.
        (default True)
    """
    proc = Popen(['xdg-open', application], stdout=PIPE)
    if wait:
        proc.communicate()


def terminal_open(command, title=None):
    terminal = os.environ['TERMINAL']
    if not terminal:
        terminal = urxvt
    generated_command = terminal
    if title is not None:
        if terminal in ['urxvt', 'xterm', 'gnome-terminal']:
            generated_command += ' -title "' + title + '"'
        elif terminal in ['termite', 'xfce-terminal']:
            generated_command += ' --title "' + title + '"'
        else:
            generated_command = ' -T "' + title + '"'
    os.system(generated_command + " -e " + command)


def run_mbscript(scriptpath, arguments=[]):
    """Run a particular mbscript (for now it must be python).

    Keyword arguments:
    scriptpath -- full path to particular mbscript (including extension)
    arguments -- any arguments that should be passed to the script (default [])
    """
    if not os.path.isfile(scriptpath):
        print("Script '" + scriptpath + "' not found...")
        sys.exit(1)
    proc = Popen([scriptpath] + arguments)
    proc.communicate()


def get_mime_type(filepath):
    """Get mime type using bash (python libraries have been unreliable)."""
    if not os.path.isfile(filepath):
        return(None)
    proc = Popen(['xdg-mime', 'query', 'filetype', filepath], stdout=PIPE)
    mtype = proc.stdout.read().decode('utf-8')
    exit_code = proc.wait()
    if (exit_code != 0):
        sys.exit(1)
    if not mtype:
        mtype = 'None/None'
    return(mtype)


class FileRepo:
    """File repository class. Scans a directory and is able to generate pretty
    lists of strings and sort them by name/date/size/etc.

    Keyword arguments:
        dirpath -- path to directory that should be scanned
    """
    def __init__(self, dirpath=None):
        self.__path = os.path.join(dirpath, "")
        self.__path_len = len(self.__path)
        self.__files = []    # list of files - dicts
        self.__filecount = 0
        self.sorttype = "none"
        self.sortrev = False
        # Line formatting details
        self.__lineformat = ['name', 'cdate']
        self.__linebs = {}
        self.__linebs['name'] = 40
        self.__linebs['adate'] = 18
        self.__linebs['cdate'] = 18
        self.__linebs['mdate'] = 18
        self.__linebs['size'] = 15
        self.__linebs['misc'] = 100

    # Scans the directory for files and populates the file list and linebs
    def scan_files(self, recursive=False):
        """Scans the directory for files and populates the files list and
        linebs. It is not a particularly fast implementation.

        Keyword arguments:
        recursive -- define whether scan should be recursive or not
                     (default True)
        """
        self.__filecount = 0
        self.__files = []
        if recursive:
            for root, dirs, files in os.walk(self.__path, topdown=True):
                for name in files:
                    fp = os.path.join(root, name)
                    fp_rel = fp[self.__path_len:]

                    if (fp_rel[0] == '.'):
                        continue
                    try:
                        stat = os.stat(fp)
                    except:
                        continue

                    file_props = {}
                    file_props['size'] = stat[ST_SIZE]
                    file_props['adate'] = stat[ST_ATIME]
                    file_props['mdate'] = stat[ST_MTIME]
                    file_props['cdate'] = stat[ST_CTIME]
                    file_props['name'] = fp_rel
                    file_props['fullpath'] = fp
                    file_props['misc'] = None

                    self.__files.append(file_props)
                    self.__filecount += 1
        else:
            for f in os.scandir(self.__path):

                fp_rel = f.name
                fp = os.path.join(self.__path, fp_rel)
                if (fp_rel[0] == '.'):
                    continue
                if f.is_dir():
                    continue
                # try:
                #     stat = os.stat(fp)
                # except:
                #     continue

                file_props = {}
                file_props['size'] = f.stat()[ST_SIZE]
                file_props['adate'] = f.stat()[ST_ATIME]
                file_props['mdate'] = f.stat()[ST_MTIME]
                file_props['cdate'] = f.stat()[ST_CTIME]
                file_props['name'] = fp_rel
                file_props['fullpath'] = fp
                file_props['misc'] = None

                self.__files.append(file_props)
                self.__filecount += 1

    def add_file(self, filepath, misc_prop=None):
        """Manually add files to the files list, and get all its file
        properties.

        Keyword arguments:
        filepath -- path to file
        misc_prop -- add a miscellaneous property
        """
        if not os.path.isfile(filepath):
            print(filepath + " is not a file.")
            return
        fp_rel = filepath[self.__path_len:]

        try:
            stat = os.stat(filepath)
        except:
            return
        file_props = {}
        file_props['size'] = stat[ST_SIZE]
        file_props['adate'] = stat[ST_ATIME]
        file_props['mdate'] = stat[ST_MTIME]
        file_props['cdate'] = stat[ST_CTIME]
        file_props['name'] = fp_rel
        file_props['fullpath'] = filepath
        file_props['misc'] = misc_prop

        self.__files.append(file_props)
        self.__filecount += 1

    def sort(self, sortby='name', sortrev=False):
        """Sort files list.

        Keyword arguments:
        sortby -- file property to use for sorting (default 'name')
        sortrev -- whether to reverse the sorting order (default False)
        """
        if sortby not in ['size', 'adate', 'mdate', 'cdate', 'name']:
            print("Key '" + sortby + "' is not valid.")
            print("Choose between size, adate, mdate, cdate or name.")
        self.__files = sorted(self.__files,
                              key=itemgetter(sortby), reverse=not sortrev)
        self.sorttype = sortby
        self.sortrev = sortrev

    def get_property_list(self, prop='name'):
        """Get a list a particular property pertaining to each file in
        files list.
        """
        plist = list(itemgetter(prop)(filen) for filen in self.__files)
        return(plist)

    def path(self):
        """return path"""
        return(self.__path)

    def filenames(self):
        """Get filenames"""
        return(self.get_property_list('name'))

    def filepaths(self):
        """Get filepaths"""
        return(self.get_property_list('fullpath'))

    def filecount(self, include_normal=True):
        """Return number of files in repo."""
        return(self.__filecount)

    def set_lineformat(self, new_lineformat):
        """Set the lineformat to be used in the lines() method.

        Keyword arguments:
        new_lineformat -- list of valid properties.
            e.g., ['name', 'size', 'cdate']"""
        self.__lineformat = new_lineformat

    def lines(self, format_list=None):
        """Return list of lines formatted using format_list argument or
        self.__lineformat."""
        lines = []
        if not format_list:
            format_list = self.__lineformat
        for filen in self.__files:
            line = ""
            for formatn in format_list:
                if formatn in ['adate', 'mdate', 'cdate']:
                    block = datetime.utcfromtimestamp(filen[formatn])
                    block = block.strftime('%d/%m/%Y %H:%M')
                elif formatn == 'size':
                    size = filen[formatn]
                    block = sizeof_fmt(size)
                else:
                    block = str(filen[formatn])

                blocksize = self.__linebs[formatn]
                if len(block) >= blocksize:
                    block = block[:blocksize-2] + '…'

                block = block.ljust(blocksize)
                line += block
            lines.append(line)
        return(lines)

    def grep_files(self, filters_string):
        """grep files for filters. filters_string is a space_separated list of
        words.
        """
        if not self.__files:
            print("No files added to file repo")
            return(1)

        proc = Popen(['grep', '-i', '-I', filters_string] + self.filepaths(),
                     stdout=PIPE)
        answer = proc.stdout.read().decode('utf-8')
        exit_code = proc.wait()

        grep_file_repo = FileRepo(self.__path)
        temp_files = []
        if answer == '':
            return(None)

        for ans in answer.split("\n"):
            if ans:
                ans = ans.split(':', 1)
                if not ans[0] in temp_files:
                    grep_file_repo.add_file(ans[0], ans[1])
                    temp_files.append(ans[0])

        return(grep_file_repo)


def upload_ptpb(rootpath, filename, notify_bool=True, name="File"):
    """Upload file to ptpb.pw and notify via notify-send.

    Keyword arguments:
    rootpath -- root path for file.
    filename -- name of file.
    notify_bool -- boolean to send notification (default True)
    name -- name used to generate nicer notifications (default File).
    """
    from requests import Session, adapters, exceptions

    filepath = os.path.join(rootpath, filename)
    if not os.path.isfile(filepath):
        print("File not found in '" + filepath + "'.")
        return(False)
    url = "https://ptpb.pw"
    files = {'c': open(filepath, 'rb')}
    opts = {'sunset':'432000'}

    s = Session()
    a = adapters.HTTPAdapter(max_retries=3)
    s.mount('https://', a)
    try:
        rh = s.get(url)
    except exceptions.RequestException as e:
        print("Error: Failed to connect to " + url)
        notify(name + ":",
               name + " '" + filename + "'could not be uploaded."
               + " Failed to connect to " + url)
        return False

    if not (rh.status_code == 200):
        print("Error: Failed to connect to " + url)
        print(rh.status_code)
        if notify_bool:
            notify(name + ":", name + " " + filename + "could not be uploaded."
                        + " Failed to connect to " + url)
        return False

    r = s.post(url + "/?u=1", files=files, data=opts)
    if (r.status_code == 200):
        pasteurl = r.headers['Location']
        if notify_bool:
            notify(name + ":", name + " " + filename + " uploaded to:"
                        + " " + pasteurl)
    else:
        if notify_bool:
            notify(name + ":",
                   name + " " + filename + "could not be uploaded."
                   + " Status code: " + r.status_code)
        print("Error: Upload was unsuccessful.")
        print(r.status_code)
        return False

    return(pasteurl)


def parse_config(config_path=None):
    """Parse a configuration file, and return the ConfigParser class result"""
    if config_path is None:
        config_path = os.path.expanduser('~/.config/mbrun/')
    full_path = os.path.join(config_path, 'config')
    config = ConfigParser()
    config.read(full_path)

    return(config)


if __name__ == "__main__":
    # parse_config()
    fr = FileRepo('/home/martin')
    fr.scan_files(recursive=True)
    print(fr.filenames())
    print(fr.path())
    print(fr.filecount())

# EOF
