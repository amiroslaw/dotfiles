# mbrun

Series of useful scripts revolving around rofi that I have made. They depend
on a library found in `helpers/mbrofi.py` meant to minimize maintenace of
each individual script. This can be used as a nice platform for anyone that
wants to make a quick rofi interface in python. However, it is not meant to be
a real project in any way, so consequential idiosyncracies abound--buyer
beware.

The idea is to make it very easy for me to go from an idea to a useful script,
to keep a uniform look to all the scripts, and to be able to generate a global
menu from where to launch them.

For many of these, they can be trivially made to be standalone by copying the
few functions from mbrofi that they rely on. Please feel free to use or get
inspiration from any of these scripts for your own personal needs.

## list of scripts
* template.py -- does nothing. Only serves as a template to build new scripts.
* amazon.py -- do an amazon search
* bookmarks.py -- file-based bookmark manager
* define.py -- define word using sdcv dictionary application
* google.py -- do a google search
* lutris.py -- launch games via lutris
* network.py -- manage network (mostly wifi) via NetworkManager (WIP)
* screenshots.py -- manage screenshot directory. preview/rename/upload 
                    screenshots. Uploads to ptpb.pw for now.
* sshot.py -- take screenshots of specific monitors, whole screen, a
              selected window, or a custom selection. Upload/delay
              supported. Uploads to ptpb.pw for now, and uses
              screenshots.py for interactive mode.
* youtube.py -- do a youtube search.
* mount.py -- show mountable drives (mount, unmount, open)

## Ideas

### Scripts

* dotfiles.py -- quickly open or go to specific dotfiles.
* gitland.py -- quickly open git repos in gitland (maybe check their status.)
* record.py -- like sshot but for screen recordings.
* qn.py -- add a qn launcher.
* quotes.py -- manage quotes/poems (a bit redundant perhaps)
* convert.py -- convert units.
* calculator.py -- simple calculator with history.
* music.py -- manage music via mpd.
* downloads.py -- manage the downloads directory...help keep it clean.
* ptpb.py -- manage sending things to ptpb.pw

### Features

* fzf interface -- create a library that can open scripts in rofi or fzf. Will
    require redoing most scripts...and probably adding a hotkey manager for
    rofi and fzf (can use the one in [qn](https://github.com/mbfraga/qn))

* cli interfaces for all scripts -- some already have rudimentary functionality
    here.

* Need to figure out best way to lay out the scripts, Ideally they would be
    included in PATH and allow CLI control.

* Add ability for scripts to keep/show entry histories

## layout

* mbmain -- script manager which allows enabling and disabling of scripts from
            the global menu. It also generates the global menu and can be used
            as the launcher for every other script in here. It should be able
            to enable any symlinked launcher as well--allowing the user to add
            other rofi apps to it.

* helpers/mbrofi.py -- helper script that is used in virtually every other
                       script in here.

* ~/.config/mbrun/config -- configuration file following ini format. It is
    meant to be able to set configurations for every script, without adding
    hard dependencies on the scripts themselves. See section below on
    __adding configuration__ for more info.

## dependencies

For mbmain and mbrofi, the dependencies are:

* rofi
* python3 (built on 3.5.4)
* xclip
* notify-send


Other scripts will have other dependencies. Some are common dependencies found
in most decent repos, others are more esoteric ones found chiefly on git.
Ideally I will make getting them as easy as possible. Below is a list of the
dependencies for each script.

* sshot.py
   - xrandr
   - maim

* screenshots.py
   - python-requests

* define.py
   - sdcv
   - You can define your favorite dictionary file, but make sure you have one,
       otherwise sdcv doesn't do anything. Default: dictd_www.dict.org_gcide
   - You can define your favorite thesaurus file, but make sure you have one,
       otherwise the thesaurus functionality doesn't do anything. 
       Default: Moby Thesaurus II 

* lutris.py
   - lutris

* network.py
   - libnm

* mount.py
   - udisks2

## installation

Start by cloning the repository. Make sure all the dependencies are met for the
scripts that you actually want to use.

```bash
cd ~/gitland
git clone https://github.com/mbfraga/mbrun
```
For now, you have to keep all the files here in the same directory. The only
thing you need is to put mbmain in PATH. A simple symlink is enough here. For
this example I'll put it in `~/bin`, but you have to make sure that it actually
is in PATH.

```bash
ln -s /home/mbfraga/gitland/mbrun/mbmain ~/bin/
```

Copy the example configuration to the config directory and name it **config**.
Edit this configuration however you want.

```bash
mkdir ~/.config/mbrun
cp config.example ~/.config/mbrun/config
```

Now you can use mbmain through cli commands, or run mbmain to get the rofi
interface. Either way you can enable and disable scripts. You can then use
plain mbmain as a global launcher. For example, you can map it in i3 to
something like `Mod4+f`.



## adding configuration

To add a configuration to a script, you have to first start by giving it a
somewhat unique identifier (could be just the name of the script). In this
example the identifier is **template**. Note that in this explanation I start
by showing how to set the configuration itself. Ideally, the configuration file
doesn't need to have any values set. The script should parse this in a way that
it can handle configurations not specifically defined in the config file.

We start by going to the config file in `~/.config/mbrun/config` and adding the
header as follows:

```ini
[template]
```

We want to add bindings for opening a file and deleting a file, and a setting
to enable or disable the message in rofi. To do this we need to add any key
name we want and the value. See the following example:

```ini
[template]
bind_open = alt-o
bind_delete = alt-d
show_mesg = False
```

Note that I could have chosen any names for the keys instead of bind_open,
bind_delete, and show_mesg. The only requirement is that you use the same name
in your script.

Now we go to the script itself, where we have to parse these settings. We start
by calling `mbrofi.parse_config()` and storing its value in a variable that
i'll name mbconfig.

```python
from helpers import mbrofi

mbcofig = mbrofi.parse_config()
```

We start by setting some default values (I will choose different ones than
those set in the configuration file to make things clear) for the variables we
want to handle via the config file. We should also set a variable to be the
identifier we settled on before, **template**, and start an **if** block that
will check if there are any actual configuration values for **template** in
`~/.config/mbrun/config`.  Else the default values are kept. This allows us to
gracefully make the configuration file optional.

```python
from helpers import mbrofi

mbconfig = mbrofi.parse_config()
bind_open = 'alt-n'
bind_delete = 'alt-g'
show_mesg = True
script_ident = "template"
if script_indent in mbconfig:
   pass

```

We create a variable to hold the configurations specific to the identifier we
care about--just for convenience. Finally, we can use the `get()`,
`getboolean()` and other methods in ConfigParser to set the variables to what
was defined in the configuration file. We can also be safe by adding fallbacks
(I don't think this is technically necessary).

```python
from helpers import mbrofi

mbconfig = mbrofi.parse_config()
bind_open = 'alt-n'
bind_delete = 'alt-g'
show_mesg = True
script_ident = "template"
if script_indent in mbconfig:
   tempconf = mbconfig[script_ident]
   show_mesg = tempconf.getboolean("show_mesg", fallback=True)
   bind_enable = tempconf.get("bind_enable", fallback='alt-n')
   bind_disable = tempconf.get("bind_disable", fallback='alt+g')

```

These 10 lines are all that is needed to give your script the ability to have
configurations in `~/.config/mbrun/config`. 


