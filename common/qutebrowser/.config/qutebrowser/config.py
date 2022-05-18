# Documentation:
#   qute://help/configuring.html
#   qute://help/settings.html

import subprocess
import os
from qutebrowser.api import interceptor

# import themes.dracula.draw
# themes.dracula.draw.blood(c, {
#     'spacing': {
#         'vertical': 3,
#         'horizontal': 5
#     }
# })

# idk if my options will be saved 
config.load_autoconfig(True) # Change the argument to True to still load settings configured via autoconfig.yml

config.set('content.cookies.accept', 'all', 'chrome-devtools://*') # no-unknown-3rdparty
config.set('content.cookies.accept', 'all', 'devtools://*')

config.set('content.headers.accept_language', '', 'https://matchmaker.krunker.io/*')

config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}) AppleWebKit/{webkit_version} (KHTML, like Gecko) {upstream_browser_key}/{upstream_browser_version} Safari/{webkit_version}', 'https://web.whatsapp.com/')
config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}; rv:90.0) Gecko/20100101 Firefox/90.0', 'https://accounts.google.com/*')
config.set('content.headers.user_agent', 'Mozilla/5.0 ({os_info}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99 Safari/537.36', 'https://*.slack.com/*')

# Load images automatically in web pages.
config.set('content.images', True, 'chrome-devtools://*')
config.set('content.images', True, 'devtools://*')
# Enable JavaScript.
config.set('content.javascript.enabled', True, 'chrome-devtools://*')
config.set('content.javascript.enabled', True, 'devtools://*')
config.set('content.javascript.enabled', True, 'chrome://*/*')
config.set('content.javascript.enabled', True, 'qute://*/*')
# c.content.unknown_url_scheme_policy = "allow-all"
# Allow websites to show notifications. autoconfig.yml
# Valid values: - true - false - ask
# config.set('content.notifications.enabled', False, 'https://www.reddit.com')

# Aliases for commands. 
c.aliases = {'q': 'close', 'qa': 'quit', 'w': 'session-save --only-active-window', 'wq': 'quit --save', 'wqa': 'quit --save', 'h': 'help', 's': 'screenshot'}
# Without this  option set, `:wq`/ZZ (`:quit --save`) needs to be used to save open tabs (and restore them), while quitting qutebrowser in any other way will not save/restore the session.  
c.auto_save.session = False
c.confirm_quit = ["multiple-tabs", "downloads"]
c.session.lazy_restore = True

c.completion.shrink = True
c.completion.open_categories = [ 'quickmarks', 'bookmarks', 'history', 'searchengines', 'filesystem'] # idk what filesystem is

c.url.start_pages = os.environ["XDG_CONFIG_HOME"] + "/qutebrowser/themes/startpage/index.html"
c.url.default_page = os.environ["XDG_CONFIG_HOME"] + "/qutebrowser/themes/startpage/index.html"
c.tabs.close_mouse_button = "right"
c.tabs.show = 'multiple' # hide the tab bar if one tab
c.tabs.last_close = 'startpage'
c.url.open_base_url = True # Open the searchengine if a shortcut is invoked without parameters.
c.tabs.title.format = "{index}:{audio}{current_title}{private}"
c.colors.statusbar.private.bg = "#5e0802"
c.colors.statusbar.command.private.bg= "#5e0802"
# c.colors.tabs.even.bg = "silver"
# c.colors.tabs.odd.bg = "gainsboro"

c.editor.command = [ os.environ["TERM_LT"], "-c", "qb", "-e", os.environ["EDITOR"], "-f", "{file}", "-c", "normal {line}G{column0}1", ]
c.editor.remove_file = False # Files are in the /tmp
c.spellcheck.languages =  ["en-US", 'pl-PL']
c.content.default_encoding = 'utf-8'
c.downloads.remove_finished = 10000
c.content.autoplay = False
c.content.pdfjs = True ## Display PDFs within qutebrowser - dependency needed
# c.input.spatial_navigation = True # navigate between focusable elements, using arrow keys, how to disable hjkl keys?
# c.content.geolocation = False # default - ask

config.set("fileselect.handler", "external")
config.set( "fileselect.single_file.command", ["st", "-c", "qb", "-e", "vifm", "--choose-file", "{}"])
config.set( "fileselect.multiple_files.command", ["st", "-c", "qb", "-e", "vifm", "--choose-files", "{}"])
config.set( "fileselect.folder.command", ["st", "-c", "qb", "-e", "vifm", "--choose-dir", "{}"])

# dependency needed and executing command :adblock-update
c.content.blocking.method = 'both'
c.content.blocking.adblock.lists = [
        "https://easylist.to/easylist/easylist.txt",
        "https://easylist.to/easylist/easyprivacy.txt",
        "https://raw.githubusercontent.com/FiltersHeroes/PolishAnnoyanceFilters/master/PPB.txt",
        "https://raw.githubusercontent.com/MajkiIT/polish-ads-filter/master/polish-adblock-filters/adblock.txt", 
        "https://raw.githubusercontent.com/olegwukr/polish-privacy-filters/master/anti-adblock.txt"
        ]

# ======================= BINDINGS =================== {{{
config.bind('<Alt-s>', ':set spellcheck.languages ["en-US"]', 'insert') 
config.bind('<Shift-Alt-s>', ':set spellcheck.languages ["pl-PL"]', 'insert')
config.bind('ZZ', ':session-save --only-active-window  ;; later 1000 close')
config.bind('<Ctrl-m>', 'set-cmd-text :set-mark ')
config.bind('xp', 'process')
config.bind('ya', 'yank inline {url:pretty}[{title}]') # “yank asciidoc-formatted link”
config.bind('<Ctrl+T>', 'spawn --userscript translate')
config.bind('<Ctrl+m>', 'spawn --userscript buku.sh')
config.bind('<Escape>', 'mode-enter normal ;; jseval -q document.activeElement.blur()', 'insert') # unfocus input

config.bind('<Ctrl-j>', 'scroll-px 0 50', 'caret')
config.bind('<Ctrl-k>', 'scroll-px 0 -50', 'caret')
# config.bind('<Ctrl-j>', 'scroll-px 0 50', 'hint') # hints are static


# TABS AND WINDOWS
config.bind(',,', 'tab-close')
config.bind('tm', 'tab-mute')
config.bind('tg', 'tab-give')
config.bind('tt', 'tab-select')
config.bind('tc', 'tab-clone')
config.bind('>', 'tab-move +')
config.bind('<', 'tab-move -')
config.bind('<Ctrl-o>', 'tab-focus last')
config.bind('$', 'tab-focus -1')
config.bind('wn', 'open -w')
config.bind('<Ctrl-n>', 'open -p')

# MEDIA
config.bind('<Alt-Shift-w>', 'hint --rapid links spawn -u  mpvplaylist.sh push {hint-url}')
config.bind('<Alt-Ctrl-w>', 'spawn -uv  mpvplaylist.sh play')
config.bind(';w', 'hint links spawn -uv mpvplaylist.sh {hint-url}')
config.bind(';a', 'hint links spawn -uv mpvplaylist.sh audio {hint-url}')
config.bind('<Ctrl-w>', 'spawn -uv view_in_mpv') # stop video and open in mpv

# URL mostly download stuff
urlCmd = 'hint links spawn -u url.sh '
urlCmdRapid = 'hint --rapid links spawn -u url.sh '
config.bind('ea', urlCmd + 'audio {hint-url}')
config.bind('eA', urlCmdRapid + 'audio {hint-url}')
config.bind('et', urlCmd + 'tor {hint-url}')
config.bind('eT', urlCmdRapid + 'tor {hint-url}')
config.bind('ey', urlCmd + 'yt {hint-url}')
config.bind('eY', urlCmdRapid + 'yt {hint-url}')
config.bind('eg', urlCmd + 'gallery {hint-url}')
config.bind('eG', urlCmdRapid + 'gallery {hint-url}')
config.bind('ew', urlCmd + 'wget {hint-url}') # doesn't work
config.bind('eW', urlCmdRapid + 'wget {hint-url}')
config.bind('ek', urlCmd + 'kindle {hint-url}')
config.bind('eK', urlCmdRapid + 'kindle {hint-url}')
config.bind('er', urlCmd + 'read {hint-url}')
config.bind('eR', 'spawn -u ~/.bin/url.lua read {url}')
config.bind('es', urlCmd + 'speed {hint-url}')
config.bind('eS', 'spawn -u ~/.bin/url.lua speed {url}')

#COPY OR CREATE
config.bind('cc', 'spawn -u ~/.bin/note.lua clip {clipboard}')
config.bind('cs', 'spawn -u ~/.bin/note.lua sel {primary}')
config.bind('cs', 'spawn -u ~/.bin/note.lua sel {primary}', 'caret')
# config.bind('ch', 'hint p spawn -u ~/.bin/note.lua sel {clipboard}')
# coping custom hints
config.bind('cb', 'hint code userscript code_select.py')
config.bind('ca', 'hint p userscript p_select.py')

config.bind('cp', 'print') # create PDF

# HINTS
config.bind(';;', 'hint links tab-bg')
config.bind(';m', 'hint media')
config.bind(';y', 'hint links yank-primary')
config.bind(';Y', 'hint --rapid links yank-primary')
config.bind(';c', 'hint links yank')
config.bind(';C', 'hint --rapid links yank')
config.bind(';D', 'hint --rapid links download')
config.bind(';s', 'hint links userscript doi.py')
# :bind d spawn -u doi.py

# LEADER
config.bind('ar', 'config-source')
config.bind('aa', 'config-cycle --temp content.blocking.enabled false true') 
config.bind('ap', 'spawn -u jspdfdownload')
config.bind('al', 'edit-url')
config.bind('au', 'navigate up') # TODO change for 1 stroke
config.bind("aF", "hint links spawn firefox {hint-url}")
config.bind("af", "spawn -u url.sh firefox {url}")
config.bind('at', 'set-cmd-text :screenshot ') # todo bind to print scr and get current date
config.bind('ao', 'spawn -u qutedmenu tab') # TODO change to rofi
config.bind('ad', 'spawn -u open_download')
config.bind('ac', 'download-cancel')

# SEARCH
# TODO carets doesnt' work but zz work
config.bind('ss', 'open -t {primary} ')
config.bind('sS', 'open -t {clipboard} ')
config.bind('ss', 'open -t {primary}', 'caret')
config.bind('sm', 'open -t m {primary} ')
config.bind('sm', 'open -t m {primary}', 'caret')
config.bind('sM', 'open -t m {clipboard} ')
config.bind('sc', 'open -t c {primary} ')
config.bind('sc', 'open -t c {primary}', 'caret')
config.bind('sC', 'open -t c {clipboard} ')
config.bind('st', 'open -t t {primary} ')
config.bind('sT', 'open -t t {clipboard} ')
config.bind('st', 'open -t t {primary}', 'caret')
config.bind('sw', 'open -t w {primary} ')
config.bind('sw', 'open -t w {primary}', 'caret')
config.bind('sW', 'open -t w {clipboard} ')
config.bind('sv', 'open -t y {primary} ')
config.bind('sv', 'open -t y {primary}', 'caret')
config.bind('sV', 'open -t y {clipboard} ')
config.bind('sd', 'open -t d {primary} ')
config.bind('sd', 'open -t d {primary}', 'caret')
config.bind('sD', 'open -t d {clipboard} ')
config.bind('zz', 'spawn -u selection.sh ')
config.bind('zz', 'spawn -u selection.sh', 'caret')
config.bind('zZ', 'spawn -u selection.sh {clipboard}')
# config.bind('as', 'set-cmd-text :session-load ')
config.bind('zs', 'spawn -u session.sh save')
config.bind('zl', 'spawn -u session.sh load')
config.bind('zd', 'spawn -u session.sh delete')
config.bind('<Ctrl-s>', 'open -t {primary} ', 'insert')
config.bind('<Ctrl-i>', 'open -t d {primary} ', 'insert')
config.bind('<Ctrl-Shift-i>', 'open -t d {primary} ', 'insert')
config.bind('<Ctrl-Shift-s>', 'spawn -u selection.sh', 'insert')

# config.bind('J', 'move-to-start-of-next-block', 'caret') # [
# config.bind('K', 'move-to-start-of-prev-block', 'caret')
# config.bind(',r', 'spawn -u readability-js')
# config.bind(',R', 'spawn -u readability')
# config.bind(',F', 'spawn -u openfeeds') - module needed
# move cursor in command mode
# bind go set-cmd-text :open {url:pretty} ;; fake-key -g <Home><Ctrl-Right><Shift-End>
# }}}

# ======================= Command Mode ============= {{{
config.bind('<Ctrl-l>', 'command-accept', 'command')
config.bind('<Ctrl-j>', 'completion-item-focus next', 'command')
config.bind('<Ctrl-k>', 'completion-item-focus prev', 'command')
config.bind('<Ctrl-Shift-j>', 'completion-item-focus next-category', 'command')
config.bind('<Ctrl-Shift-k>', 'completion-item-focus prev-category', 'command')
config.bind('<Ctrl-Delete>', 'completion-item-del', 'command')
# config.bind('<Alt-j>', 'command-history-next', 'command') # c-p /c-n default
# config.bind('<Alt-k>', 'command-history-prev', 'command')
# }}}
# ======================= Redline Insert Mode ============= {{{
# config.bind("<Ctrl-h>", "fake-key <Backspace>", "insert")
config.bind("<Ctrl-l>", "fake-key <Ctrl-Right>", "insert")
config.bind("<Ctrl-h>", "fake-key <Ctrl-Left>", "insert")
config.bind("<Ctrl-a>", "fake-key <Home>", "insert")
config.bind("<Ctrl-e>", "fake-key <End>", "insert")
config.bind("<Ctrl-b>", "fake-key <Left>", "insert")
config.bind("<Ctrl-f>", "fake-key <Right>", "insert")
config.bind("<Mod1-b>", "fake-key <Ctrl-Left>", "insert")
config.bind("<Mod1-f>", "fake-key <Ctrl-Right>", "insert")
config.bind("<Ctrl-p>", "fake-key <Up>", "insert")
config.bind("<Ctrl-n>", "fake-key <Down>", "insert")
config.bind("<Mod1-d>", "fake-key <Ctrl-Delete>", "insert")
config.bind("<Ctrl-d>", "fake-key <Delete>", "insert")
config.bind("<Ctrl-w>", "fake-key <Ctrl-Backspace>", "insert")
config.bind("<Ctrl-u>", "fake-key <Shift-Home><Delete>", "insert")
config.bind("<Ctrl-k>", "fake-key <Shift-End><Delete>", "insert")
config.bind('<Ctrl-y>', 'insert-text {primary}', 'insert') # doesn't work
config.bind("<Ctrl-o>", "edit-text", "insert")
config.bind("ai", "mode-enter insert ;; fake-key <Enter> ;; mode-enter normal" )
# }}}


# engine name (such as `DEFAULT`, or `ddg`) to a URL with a `{}` placeholder. The placeholder will be replaced by the search term, use `{{` and `}}` for literal `{`/`}` braces.  
c.url.searchengines = {
    'DEFAULT': 'https://www.google.com/search?q={}',
    'y': 'https://www.youtube.com/results?search_query={}',
    'w': 'https://en.wikipedia.org/wiki/{}',
    'wp': 'https://pl.wikipedia.org/wiki/{}',
    'c': 'https://www.ceneo.pl/;szukaj-{}',
    'cc': 'https://cenowarka.pl/?fs={}',
    'dd': 'https://duckduckgo.com/?q={}',
    'am': 'https://www.amazon.com/s?k={}',
    'aw': 'https://wiki.archlinux.org/?search={}',
    'au': 'https://aur.archlinux.org/packages?O=0&K={}',
    'a': 'https://allegro.pl/listing?string={}',
    'f': 'https://www.filmweb.pl/search?q={}',
    'tekstowo': 'https://www.tekstowo.pl/wyszukaj.html?search-artist=Podaj+wykonawc%C4%99&search-title={}',
    'so': 'https://stackoverflow.com/search?q={}',
    'wa': 'https://www.wolframalpha.com/input/?i={}',
    'thesaurus': 'https://www.thesaurus.com/browse/{}?s=t',
    'm': 'https://maps.google.com/maps?q={}',
    'gi': 'https://www.google.com/search?q={}&tbm=isch',
    't' :'https://www.deepl.com/en/translator#en/pl/{}',
    'd': 'https://www.diki.pl/slownik-angielskiego?q={}',
    'tt': 'https://translate.google.pl/?hl=pl#pl/en/{}',
    'cam': 'https://dictionary.cambridge.org/spellcheck/english/?q={}', 
    'sci': 'https://sci-hub.se/{}', 
    'git': 'https://github.com/search?q={}'
        }

# ================== Custom hints ======================= {{{
c.hints.selectors["code"] = [ # Selects all code tags whose direct parent is not a pre tag
    ":not(pre) > code",
    "pre"
]
c.hints.selectors["p"] = [
    "p"
]
c.hints.selectors['inputs'] += ['input[type="color"]', 'input[type="file"]', 'input[type="checkbox"]', 'input[type="radio"]', 'input[type="range"]', 'input[type="submit"]', 'input[type="reset"]', 'input[type="button"]', 'input[type="image"]', 'form button' ]
# }}}

# close popup
config.bind('xx', 'jseval (function () { '+
'  var i, elements = document.querySelectorAll("body *");'+
''+
'  for (i = 0; i < elements.length; i++) {'+
'    var pos = getComputedStyle(elements[i]).position;'+
'    if (pos === "fixed" || pos == "sticky") {'+
'      elements[i].parentNode.removeChild(elements[i]);'+
'    }'+
'  }'+
'})();');

# ================== Youtube Add Blocking ======================= {{{
# probably doesn't work
# def filter_yt(info: interceptor.Request):
#     """Block the given request if necessary."""
#     url = info.request_url
#     if (
#         url.host() == "www.youtube.com"
#         and url.path() == "/get_video_info"
#         and "&adformat=" in url.query()
#     ):
#         info.block()
# interceptor.register(filter_yt)
# }}}


# TESTS
# c.downloads.position = "bottom"
# c.scrolling.bar = "always"
# c.content.javascript.can_access_clipboard = True
# c.content.notifications.enabled = True
# c.downloads.location.prompt = False
# c.input.insert_mode.auto_load = True
# c.tabs.last_close = "close"
# c.tabs.mousewheel_switching = False
# c.scrolling.smooth
# config.set("content.register_protocol_handler", True, "*://calendar.google.com")
# config.set("content.register_protocol_handler", True, "*://teams.microsoft.com")
# config.set("content.media.audio_video_capture", True, "*://teams.microsoft.com")
# config.set("content.media.audio_capture", True, "*://teams.microsoft.com")
# config.set("content.media.video_capture", True, "*://teams.microsoft.com")
# config.set("content.desktop_capture", True, "*://teams.microsoft.com")
# config.set("content.cookies.accept", "all", "*://teams.microsoft.com")

