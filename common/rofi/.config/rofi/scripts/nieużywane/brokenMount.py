#!/bin/env python3

# heavily inspired by bashmount
# dependencies:
#   * udisks

import sys
from os import system
from subprocess import Popen, PIPE

from helpers import mbrofi

# user variables

# application variables
IGNORE_DEVICES=['sda', 'mapper/root']
BIND_MOUNT = 'alt-m'
BIND_UNMOUNT = 'alt-u'
BIND_REFRESH = 'alt-r'
BIND_OPEN = 'alt-o'
BIND_EJECT = 'alt-e'
script_id = 'mount'
mbconfig = mbrofi.parse_config()
OPEN_CMD = mbconfig['mbmain'].get('file_manager', fallback='pcmanfm')
if script_id in mbconfig:
    lconf = mbconfig[script_id]
    BIND_MOUNT = lconf.get('bind_mount', fallback=BIND_MOUNT)
    BIND_UNMOUNT = lconf.get('bind_unmount', fallback=BIND_UNMOUNT)
    BIND_REFRESH = lconf.get('bind_refresh', fallback=BIND_REFRESH)
    BIND_OPEN = lconf.get('bind_open', fallback=BIND_OPEN)
    BIND_EJECT = lconf.get('bind_eject', fallback=BIND_EJECT)
    IGNORE_DEVICES = lconf.get('ignore_devices', fallback=IGNORE_DEVICES)

print(IGNORE_DEVICES)
try:
    assert isinstance(IGNORE_DEVICES, str)
    IGNORE_DEVICES = IGNORE_DEVICES.split(',')
except AssertionError:
    pass
print(IGNORE_DEVICES)

bindings = ["alt+h"]
bindings += [BIND_MOUNT]
bindings += [BIND_UNMOUNT]
bindings += [BIND_REFRESH]
bindings += [BIND_OPEN]
bindings += [BIND_EJECT]

BIND_HELPLIST = ["Show help menu."]
BIND_HELPLIST += ["Mount device."]
BIND_HELPLIST += ["Unmount device."]
BIND_HELPLIST += ["Refresh devices."]
BIND_HELPLIST += ["Open (mount if necessary) device."]
BIND_HELPLIST += ["Eject device."]

# launcher variables
msg = "Mount or unmount devices. "
msg += bindings[0] + " to show help."
#msg = "Help text. " + bindings[0] + " does something, " +  \
        #bindings[1]  + " does something else."
prompt = "mount:"
answer=""
sel=""
filt=""
index=0

# run correct launcher with prompt and help message
mount_launcher_args = {}
mount_launcher_args['prompt'] = prompt
mount_launcher_args['mesg'] = msg
mount_launcher_args['filter'] = filt
mount_launcher_args['bindings'] = bindings
mount_launcher_args['index'] = index

def is_ignored(devname):
    for igdev in IGNORE_DEVICES:
        if igdev in devname:
            return(True)
    return(False)

def get_mounted(devices):
    mounted = []
    lines = []
    for dev in devices.values():
        if dev.mounted:
            mounted.append(dev)
            line = ''
            line += dev.devname.ljust(10)
            line += '| ' + dev.label.ljust(10)
            lines.append(line)
    return(lines, mounted)


def get_unmounted(devices):
    unmounted = []
    lines = []
    for dev in devices.values():
        if not dev.mounted:
            unmounted.append(dev)
            line = ''
            line += dev.devname.ljust(10)
            line += '| ' + dev.label.ljust(10)
            lines.append(line)
    return(lines, unmounted)

def get_all(devices):
    alld = []
    lines = []
    n = 0
    for dev in devices.values():
        alld.append(dev)
        line = str(n).zfill(2) + ": "
        line += dev.label.ljust(10)
        line += '| '
        line += dev.devname.ljust(10)
        if dev.mounted:
            line += ' (mounted)'
        lines.append(line)
        n += 1
    return(lines, alld)



class device():
    def __init__(self, devname):
        self.devname = devname
        self.category = None
        self.mounted = False
        self.removable = False
        self.mountpath = None
        self.lsblkinfo = None
        self.get_lsblk_info(['NAME', 'TYPE', 'LABEL', 'RM', 'FSTYPE'])
        self.get_mountpath()

    @property
    def label(self):
        return(self.lsblkinfo['LABEL'])
    
    @property
    def name(self):
        return(self.lsblkinfo['NAME'])

    @property
    def type(self):
        return(self.lsblkinfo['TYPE'])

    @property
    def fstype(self):
        return(self.lsblkinfo['FSTYPE'])

    def is_mounted(self):
        process = Popen(['findmnt', '-no', 'TARGET', self.devname])
        exit_code = process.wait()
        if exit_code == 0:
            self.mounted = True
            return(True)
        else:
            self.mounted = False
            return(False)

    def get_mountpath(self):
        process = Popen(['findmnt', '-no', 'TARGET', self.devname],
                        stdout=PIPE)
        answer = process.stdout.read().decode('utf-8').strip()
        exit_code = process.wait()
        if answer:
            self.mountpath = answer
        else:
            self.mountpath = None
        if exit_code == 0:
            self.mounted = True
        else:
            self.mounted = False
        return(answer)

    def get_lsblk_info(self, targets):
        multiple=False
        try:
            assert not isinstance(targets, str)
            target_string = ''
            for target in targets:
                target_string += target + ','
            target_string = target_string[:-1]
            multiple=True
        except AssertionError:
            target_string = targets
        process = Popen(['lsblk', '-dPno', target_string, self.devname],
                        stdout=PIPE)
        answer = process.stdout.read().decode('utf-8')
        exit_code = process.wait()
        info = {}
        if multiple:
            for answer in answer.split():
                key, value = answer.split('=')
                value = value.strip('"')
                if value:
                    info[key] = value
                else:
                    info[key] = None
        else:
            key, value = answer.strip().split('=')
            value = value.strip('"')
            if value:
                info[key] = value
            else:
                info[key] = None
        self.lsblkinfo = info

        if info['RM'] == '1':
            self.removable = True
        else:
            self.removable = False

    def mount(self, opts=None):
        if opts:
            options = ['--options', opts]
        else:
            options = ['--options', 'nosuid,noexec,noatime']
        command = ['udisksctl', 'mount'] + options
        command += ['--block-device', self.devname]
        proc = Popen(command)
        exit_code = proc.wait()
        return(exit_code == 0)

    def unmount(self):
        command = ['udisksctl', 'unmount', '--block-device', self.devname]
        proc = Popen(command, stderr=PIPE)
        out, err =  proc.communicate()
        exit_code = proc.returncode
        return(exit_code == 0, err.decode('UTF-8'))

    def open(self):
        command = OPEN_CMD
        command += " " + self.mountpath
        system(command)

    def eject(self):
        if self.mounted:
            ok, err = self.unmount()
            if not (ok):
                return(ok, err)
        command = ['udisksctl', 'power-off', '--block-device', self.devname]
        proc=Popen(command)
        out, err = proc.communicate()
        exit_code = proc.returncode
        if exit_code == 0:
            return(True, "")
        else:
            return(False, err.decode('UTF-8'))


def get_devices(showr=True, showi=False, showo=True, only_mountable=True):
    process = Popen(['lsblk', '-plno', 'NAME'], stdout=PIPE)

    all_dev = process.stdout.read().decode('utf-8').strip()
    all_dev_l = all_dev.split()
    exit_code = process.wait()

    devices = {}
    for devname in all_dev_l:
        dev = device(devname)
        if (dev.fstype is None or dev.label is None) and only_mountable:
            continue
        if is_ignored(dev.devname):
            continue
        if dev.type == 'part' or dev.type == 'crypt':
            if dev.removable and showr:
                devices[devname] = dev
            elif showi:
                devices[devname] = dev
        elif dev.type == 'disk':
            if len(all_dev_l) == 1:
                continue
            if dev.removable and showr:
                devices[devname] = dev
            elif showi:
                devices[devname] = dev
        elif dev.type == 'rom' and showo:
            devices[devname] = dev
        else:
            continue
    return(devices)


def main(launcher_args, igdev=[]):
    while True:
        devs = get_devices(showi=True)
        entries = get_all(devs)
        answer, exit = mbrofi.rofi(entries[0], launcher_args)
        if exit == 1:
            sys.exit(1)
        else:
            index, filt, sel = answer.strip().split(';')
            index = int(index)
        launcher_args['filter'] = filt
        launcher_args['index'] = index

        if (exit == 0):
            if (index != -1):
                dev = entries[1][index]
                if not dev.mounted:
                    print("mounting " + dev.devname + "...")
                    if (dev.mount()):
                        print("success!")
                    else:
                        mbrofi.rofi_warn("Failed to mount " + dev.devname)
                        break
                dev.get_mountpath()
                dev.open()
                break
        elif (exit == 10):
            helpmsg_list = BIND_HELPLIST
            mbrofi.rofi_help(bindings, helpmsg_list, prompt='mount help:')
        elif (exit == 12):
            if (index != -1):
                dev = entries[1][index]
                if (not dev.mounted):
                    print("Device not mounted, won't unmount.")
                    continue
                print("unmounting " + dev.devname + "...")
                ok, err = dev.unmount()
                if (ok):
                    print("success!")
                else:
                    mbrofi.rofi_warn("Failed to unmount " + dev.devname +
                                     "\n" + err)
                    break
        elif (exit == 11):
            if (index != -1):
                dev = entries[1][index]
                if (dev.mounted):
                    print("Device already mounted, won't mount.")
                    continue
                print("mounting " + dev.devname + "...")
                if (dev.mount()):
                    print("success!")
                else:
                    mbrofi.rofi_warn("Failed to mount " + dev.devname)
                    break
        elif (exit == 13):
            continue
        elif (exit == 14):
            if (index != -1):
                dev = entries[1][index]
                if not dev.mounted:
                    print("mounting " + dev.devname + "...")
                    if (dev.mount()):
                        print("success!")
                    else:
                        mbrofi.rofi_warn("Failed to mount " + dev.devname)
                        break
                dev.get_mountpath()
                dev.open()
                break
        elif (exit == 15):
            if (index != -1):
                dev = entries[1][index]
                print("ejecting " + dev.devname + "...")
                ok, err = dev.eject()
                if (ok):
                    print("success!")
                else:
                    mbrofi.rofi_warn("Failed to eject " + dev.devname +
                                     "\n" + err)
                    break
        else:
            break


if __name__ == '__main__':
    #print(get_devices(showi=True, only_mountable=True))
    main(mount_launcher_args)
    #mbrofi.terminal_open(OPEN_CMD + " ~/gitland")
