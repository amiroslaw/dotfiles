#!/bin/env python3
# Based heavily on netowrkmanager_dmenu.by firecat53
# https://github.com/firecat53/networkmanager-dmenu
import sys
import gi
gi.require_version('NM', '1.0')
from gi.repository import GLib, NM  # pylint: disable=wrong-import-position
from subprocess import Popen, PIPE


from helpers import mbrofi

# user variables
BIND_REFRESH = 'alt-r'
BIND_CONNECT = 'alt-c'

script_id = 'network'
mbconfig = mbrofi.parse_config()
if script_id in mbconfig:
    BIND_REFRESH = lconf.get('bind_refresh', fallback=BIND_REFRESH)
    BIND_CONNECT = lconf.get('bind_connect', fallback=BIND_CONNECT)

bindings = ["alt+h"]
bindings += [BIND_REFRESH]
bindings += [BIND_CONNECT]

# application variables
CLIENT = NM.Client.new(None)
LOOP = GLib.MainLoop()
CONNS = CLIENT.get_connections()

BIND_HELPLIST = ["Show help menu."]
BIND_HELPLIST += ["Refresh networks."]
BIND_HELPLIST += ["Connect to network."]

# launcher variables
msg = "Manage network."
prompt = "network:"
answer=""
sel=""
filt=""
index=0
bindings=bindings

# run correct launcher with prompt and help message
launcher_args = {}
launcher_args['prompt'] = prompt
launcher_args['mesg'] = msg
launcher_args['filter'] = filt
launcher_args['bindings'] = bindings
launcher_args['index'] = index


def list_entries():
    """Return entries to be displayed in rofi."""

    conns_cur = [i for i in CONNS if
                     i.get_setting_wireless() is not None and
                     i.get_setting_wireless().get_mac_address() ==
                     adapter.get_permanent_hw_address()]
    return(conns_cur)


def ssid_to_utf8(nm_ap):
    """ Convert binary ssid to utf-8 """
    ssid = nm_ap.get_ssid()
    if not ssid:
        return ""
    ret = NM.utils_ssid_to_utf8(ssid.get_data())
    if sys.version_info.major < 3:
        return ret.decode(ENC)
    return ret


def ap_security(nm_ap):
    """Parse the security flags to return a string with 'WPA2', etc. """
    flags = nm_ap.get_flags()
    wpa_flags = nm_ap.get_wpa_flags()
    rsn_flags = nm_ap.get_rsn_flags()
    sec_str = ""
    if ((flags & getattr(NM, '80211ApFlags').PRIVACY) and
            (wpa_flags == 0) and (rsn_flags == 0)):
        sec_str += " WEP"
    if wpa_flags != 0:
        sec_str += " WPA1"
    if rsn_flags != 0:
        sec_str += " WPA2"
    if ((wpa_flags & getattr(NM, '80211ApSecurityFlags').KEY_MGMT_802_1X) or
            (rsn_flags & getattr(NM, '80211ApSecurityFlags').KEY_MGMT_802_1X)):
        sec_str += " 802.1X"
    # If there is no security use "--"
    if sec_str == "":
        sec_str = "--"
    return sec_str.lstrip()


def get_passphrase():
    """Get a password

    Returns: string
    """

    command = ['pinentry-qt']
    proc = Popen(command, stdout=PIPE, stdin=PIPE).communicate( \
            input=b'setdesc Get network password\ngetpin\n')[0]
    if proc:
        print(proc)
        res = proc.decode('utf-8').split("\n")[2]
        if res.startswith("D "):
            pin = res.split("D ")[1]
    return(pin)


def create_ap_list(adapter, active_connections):
    """Generate list of access points. Remove duplicate APs , keeping strongest
    ones and the active AP

    Args: adapter
          active_connections - list of all active connections
    Returns: aps - list of access points
             active_ap - active AP
             active_ap_con - active Connection
    """
    aps = []
    ap_names = []
    active_ap = adapter.get_active_access_point()
    aps_all = sorted(adapter.get_access_points(),
                     key=lambda a: a.get_strength(), reverse=True)
    conns_cur = [i for i in CONNS if
                 i.get_setting_wireless() is not None and
                 i.get_setting_wireless().get_mac_address() ==
                 adapter.get_permanent_hw_address()]
    try:
        ap_conns = active_ap.filter_connections(conns_cur)
        active_ap_name = ssid_to_utf8(active_ap)
        active_ap_con = [active_conn for active_conn in active_connections
                         if active_conn.get_connection() in ap_conns]
    except AttributeError:
        active_ap_name = None
        active_ap_con = []
    if len(active_ap_con) > 1:
        raise ValueError("Multiple connection profiles match"
                         " the wireless AP")
    active_ap_con = active_ap_con[0] if active_ap_con else None
    for nm_ap in aps_all:
        ap_name = ssid_to_utf8(nm_ap)
        if nm_ap != active_ap and ap_name == active_ap_name:
            # Skip adding AP if it's not active but same name as active AP
            continue
        if ap_name not in ap_names:
            ap_names.append(ap_name)
            aps.append(nm_ap)
    return aps, active_ap, active_ap_con


def choose_adapter(client):
    """If there is more than one wifi adapter installed, ask which one to use
    """
    devices = client.get_devices()
    devices = [i for i in devices if i.get_device_type() == NM.DeviceType.WIFI]

    if not devices:
        return None
    elif len(devices) == 1:
        return devices[0]

    device_names = [d.get_iface() for d in devices]
    print(device_names)
    rofi_largs={}
    rofi_largs['prompt'] = "network (choose adapter):"
    rofi_largs['format'] = "i"
    ans, exit = mbrofi.rofi(device_names, rofi_largs)
    if exit == 1:
        sys.exit()
    device_selected = devices[int(ans.strip())]

    return(device_selected)


def main(launcher_args):
    """Main function."""
    while True:
        active = CLIENT.get_active_connections()
        adapter = choose_adapter(CLIENT)
        max_name_l = 20
        max_sec_l = 15
        max_str_l = 3
        if adapter:
            aps, active_ap, active_ap_con = create_ap_list(adapter, active)
            apname_list = []
            for ap in aps:
                bars = str(ap.get_strength()).rjust(3)
                is_active = ap.get_bssid() == active_ap.get_bssid()
                line = ""
                line += ssid_to_utf8(ap)[:max_name_l].ljust(max_name_l)
                line += " | " + bars[:max_str_l].ljust(max_str_l)
                line += " | " + ap_security(ap)[:max_sec_l].ljust(max_sec_l)
                line += " | "
                if is_active:
                    line += "(active)"
                apname_list.append(line)
        else:
            apname_list = []

        answer, exit = mbrofi.rofi(apname_list, launcher_args)
        if exit == 1:
            break

        index, filt, sel = answer.strip().split(';')
        launcher_args['filter'] = filt
        launcher_args['index'] = index

        if (exit == 0):
            print(ssid_to_utf8(aps[int(index)]))
        elif (exit == 10):
            helpmsg_list = BIND_HELPLIST
            mbrofi.rofi_help(bindings, helpmsg_list, prompt='network help:')
        elif (exit == 11):
            continue
        else:
            break


if __name__ == "__main__":
    main(launcher_args)
