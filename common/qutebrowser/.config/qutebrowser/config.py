# Documentation:
#   qute://help/configuring.html
#   qute://help/settings.html

# ======================= Config default ============= {{{
import subprocess
import os
from qutebrowser.api import interceptor

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
# CORS
config.set('content.local_content_can_access_remote_urls', True)
# }}}

# ======================= CONFIG ============= {{{
# ======================= Theme ============= {{{
config.source('themes/base16/default/base16-seti.config.py')
# config.source('themes/onedark/onedark.py')
c.url.start_pages = "~/.config/qutebrowser/themes/startpage/index.html"
c.url.default_page = "~/.config/qutebrowser/themes/startpage/index.html"
c.tabs.title.format = "{index}:{audio}{current_title}{private}"
c.colors.statusbar.private.bg = "#5e0802"
c.colors.statusbar.command.private.bg= "#5e0802"
c.colors.statusbar.url.success.http.fg="#f179f7"
# c.colors.statusbar.url.success.https.fg="#ebe834"
# c.colors.tabs.even.bg = "silver"
# c.colors.tabs.odd.bg = "gainsboro"
# }}}

# Aliases for commands. 
c.aliases = {'q': 'close', 'qa': 'quit', 'w': 'session-save --only-active-window', 'wq': 'quit --save', 'wqa': 'quit --save', 'h': 'help', 's': 'screenshot'}
# Without this  option set, `:wq`/ZZ (`:quit --save`) needs to be used to save open tabs (and restore them), while quitting qutebrowser in any other way will not save/restore the session.  
c.auto_save.session = False
c.confirm_quit = ["multiple-tabs", "downloads"]
c.session.lazy_restore = True
# c.downloads.location.directory = os.environ["XDG_DOWNLOAD_DIR"]
c.downloads.location.directory =  "/home/miro/Downloads"
# c.downloads.location.prompt = False

c.completion.shrink = True
c.completion.open_categories = [ 'quickmarks', 'bookmarks', 'history', 'searchengines', 'filesystem'] # idk what filesystem is
c.scrolling.smooth = True
c.tabs.close_mouse_button = "right"
c.tabs.show = 'multiple' # hide the tab bar if one tab
c.tabs.new_position.unrelated = 'next'
c.tabs.last_close = 'startpage'
c.tabs.background = True
c.url.open_base_url = True # Open the searchengine if a shortcut is invoked without parameters.

c.editor.command = [ os.environ["TERM_LT"], "-c", "qb", "-e", os.environ["EDITOR"], "-f", "{file}", "-c", "normal {line}G{column0}1", ]
c.editor.remove_file = False # Files are in the /tmp
c.spellcheck.languages =  ["en-US", 'pl-PL']
c.content.default_encoding = 'utf-8'
c.downloads.remove_finished = 10000
c.content.autoplay = False
# c.content.pdfjs = True ## Display PDFs within qutebrowser - dependency needed
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
# }}}

# ======================= BINDINGS general =================== {{{
config.unbind('ad')
# changing style
config.bind('<Ctrl-R>', 'config-cycle content.user_stylesheets "~/.config/qutebrowser/css/solarized-light.css" "~/.config/qutebrowser/css/apprentice.css" "~/.config/qutebrowser/css/darculized.css" "~/.config/qutebrowser/css/gruvbox.css" "~/.config/qutebrowser/css/solarized-dark.css"  ""')
config.bind(',,', 'tab-close')

config.bind('<Alt-s>', ':set spellcheck.languages ["en-US"]', 'insert') 
config.bind('<Shift-Alt-s>', ':set spellcheck.languages ["pl-PL"]', 'insert')
config.bind('gj', 'spawn -u headers.lua')
config.bind('gh', 'history -t')
config.bind('gp', 'open -t ;; process')
config.bind('gf', 'fullscreen')
config.bind('gl', 'open -t ;; messages')
config.bind('gs', 'view-source') # -p
config.bind('gS', 'view-source --edit') 
config.bind('gb', 'back -t')
# override 
config.bind('J', 'scroll left')
config.bind('K', 'scroll right')

config.bind('<Ctrl+T>', 'spawn --userscript translate')

config.bind('<Ctrl+m>', 'spawn --userscript buku.sh')
config.bind('M', 'bookmark-add --toggle')
config.bind('<Escape>', 'mode-enter normal ;; jseval -q document.activeElement.blur()', 'insert') # unfocus input
config.bind("<Ctrl-v>", "hint inputs --first ;; cmd-later 200 insert-text {clipboard}")
config.bind('<F7>', 'open -t file:///home/miro/Documents/notebook/preview.html')
config.bind('<F1>', 'spawn preview-ascii.sh ' + os.environ["XDG_CONFIG_HOME"] + "/qutebrowser/qt-default-bindings.adoc ;; cmd-later 1000 open -t file:///home/miro/Documents/notebook/preview.html")

config.bind('<Ctrl-j>', 'scroll-px 0 50', 'caret')
config.bind('<Ctrl-k>', 'scroll-px 0 -50', 'caret')
# config.bind('<Ctrl-j>', 'scroll-px 0 50', 'hint') # hints are static
config.bind('<Alt-a>', 'navigate next')
config.bind('<Alt-x>', 'navigate prev')
# }}}

# ======================= TABS AND WINDOWS ============= {{{
config.bind(',t', 'open -t file://' + os.environ["XDG_CONFIG_HOME"] + '/qutebrowser/themes/startpage/index.html')
config.bind('l', 'tab-next')
config.bind('h', 'tab-prev')
config.bind('tm', 'tab-mute')
config.bind('tg', 'tab-give')
config.bind('tc', 'tab-clone')
config.bind('>', 'tab-move +')
config.bind('<', 'tab-move -')
config.bind('tt', 'cmd-set-text -sr :tab-select ')
config.bind('<Ctrl-o>', 'tab-focus last')
config.bind('$', 'tab-focus -1')
config.bind('wn', 'open -w')
config.bind('<Ctrl-n>', 'open -w')
# }}}

# ======================= JSEVAL ============= {{{
# maybe jseval could be replace with click-element, or have the most frequent usage e.g. zcys - zc(click)y(youtube)s(subscribe button)
# The `:click-element` command now can also click elements based on its ID (`id`), a CSS selector (`css`), a position (`position`), or click the currently focused element (`focused`).
# Syntax: :click-element [--target target] [--force-event] [--select-first] filter [value]
config.bind('zr', 'jseval -q document.getElementById("reload-button").click()') # reload page

CYCLE_INPUTS = "jseval -q -f /usr/share/qutebrowser/scripts/cycle-inputs.js"
config.bind('<Alt-n>', CYCLE_INPUTS)
config.bind('<Alt-n>', CYCLE_INPUTS, 'insert')

# deezer
config.bind('zn', 'jseval -q document.querySelector(".player-controls li:nth-child(5) button").click()')
config.bind('zt', 'jseval -q document.querySelector("[aria-label=\'View lyrics\']").click()')
# config.bind('zp', 'jseval -q document.querySelector(".player-controls li:nth-child(3) button").click()')

# general
config.bind('za', 'jseval -qf ~/.config/qutebrowser/js/general-alert.js')
config.bind('zl', 'jseval -qf ~/.config/qutebrowser/js/general-save.js') 
config.bind('zu', 'jseval -qf ~/.config/qutebrowser/js/general-unsave.js') 
config.bind('zc', 'jseval -qf ~/.config/qutebrowser/js/general-copy.js') 
config.bind('zs', 'jseval -qf ~/.config/qutebrowser/js/general-sort.js') 
config.bind('zh', 'jseval -qf ~/.config/qutebrowser/js/general-home.js')
config.bind('zf', 'jseval -qf ~/.config/qutebrowser/js/general-filter.js')
config.bind('zd', 'jseval -qf ~/.config/qutebrowser/js/general-delete.js')
config.bind('zj', 'jseval -qf ~/.config/qutebrowser/js/general-next.js')
config.bind('zk', 'jseval -qf ~/.config/qutebrowser/js/general-previous.js')
# }}}

# ======================= HINTS ============= {{{
config.bind('f', 'hint links tab-bg')
config.bind('F', 'hint links')
config.bind(';;', 'hint all')
config.bind(';d', 'hint all download')
config.bind(';D', 'hint --rapid all download')
config.bind(';a', 'hint --rapid links tab-bg')
config.bind(';y', 'hint links yank-primary')
config.bind(';Y', 'hint --rapid links yank-primary')
config.bind(';c', 'hint links yank')
config.bind(';C', 'hint --rapid links yank')
config.bind(';x', 'hint all delete')
config.bind(';m', 'hint all right-click')
config.bind(';q', 'hint media')
config.bind(';s', 'hint links userscript doi.py')
# :bind d spawn -u doi.py

# ======================= URL, MEDIA scripts ============= {{{
# hints for media and 
# types: h-hint; l-link/location →url from current site; a-all → rapid 
# bind-type-script: ahk
urlCmdHint= 'hint links spawn '
urlCmdRapid = 'hint --rapid links spawn '
# rdrview
config.bind('alf', 'spawn -u readermode.lua')
config.bind('ahf', 'hint links userscript readermode.lua')
config.bind('aaf', 'hint --rapid links userscript readermode.lua')

config.bind('ahd', urlCmdHint+ 'url.lua --audio "{hint-url}"')
config.bind('aad', urlCmdRapid + 'url.lua --audio "{hint-url}"')
config.bind('ald', 'spawn url.lua --audio "{url}"')
config.bind('aht', urlCmdHint+ 'url.lua --tor "{hint-url}"')
config.bind('aat', urlCmdRapid + 'url.lua --tor "{hint-url}"')
config.bind('ahy', urlCmdHint+ 'url.lua --video "{hint-url}"')
config.bind('aay', urlCmdRapid + 'url.lua --video "{hint-url}"')
config.bind('aly', 'spawn url.lua --video "{url}"')
config.bind('ahg', urlCmdHint+ 'url.lua --gallery "{hint-url}"')
config.bind('aag', urlCmdRapid + 'url.lua --gallery "{hint-url}"')
config.bind('alg', 'spawn url.lua --gallery "{url}"')
config.bind('ahw', urlCmdHint+ 'url.lua --wget "{hint-url}"')
config.bind('aaw', urlCmdRapid + 'url.lua --wget "{hint-url}"')
config.bind('alw', 'spawn url.lua --wget "{url}"')
config.bind('ahk', urlCmdHint+ 'url.lua --kindle --email "{hint-url}"')
config.bind('aak', urlCmdRapid + 'url.lua --kindle "{hint-url}"')
config.bind('alk', 'spawn url.lua --kindle --email "{url}"')
config.bind('ahr', urlCmdHint+ 'url.lua --read "{hint-url}"')
config.bind('alr', 'spawn url.lua --read "{url}"')
config.bind('ahs', urlCmdHint+ 'url.lua --speed "{hint-url}"')
config.bind('als', 'spawn url.lua --speed "{url}"')
# MEDIA
config.bind('<Ctrl-w>', 'hint --rapid links spawn mpv.lua --push {hint-url}')
config.bind('<Shift-w>', 'spawn -uv ~/.config/qutebrowser/userscripts/view_in_mpv') # stop video and open in mpv; override qb script
config.bind('ahv', urlCmdHint + '-v mpv.lua --videoplay {hint-url}')
config.bind('aav', 'spawn -v mpv.lua --videolist --save --input')
config.bind('alv', 'spawn -v mpv.lua --videoplay "{url}"')
config.bind('ahp', urlCmdHint + '-v mpv.lua --popupplay {hint-url}')
config.bind('aap', 'spawn -v mpv.lua --popuplist --save --input')
config.bind('alp', 'spawn -v mpv.lua --popupplay {url}')
config.bind('aha', urlCmdHint + '-v mpv.lua --audioplay {hint-url}')
config.bind('aaa', 'spawn -v mpv.lua --audiolist --save --input')
config.bind('ala', 'spawn -v mpv.lua --audioplay "{url}"')
config.bind(';w', 'hint links spawn -uv mpv-queue.sh {hint-url}')
config.bind(';W', 'spawn -uv mpv-queue.sh {url}')
config.bind(';p', 'hint video userscript yt.lua')
config.bind(';P', 'spawn --userscript yt.lua')
config.bind('alm', 'spawn -v mpv.lua --makeOnline --input "{url}"')
# }}}

# ======================= COPING OR CREATE ============= {{{
config.bind('cn', 'spawn -u ~/.bin/note.lua sel {primary}')
config.bind('cn', 'spawn -u ~/.bin/note.lua sel {primary}', 'caret')
config.bind('cN', 'spawn -u ~/.bin/note.lua clip {clipboard}')
# select custom hints - use hint_wrapper if you need to pass an argument in hint
config.bind('ck', 'hint code userscript select.lua')
config.bind('cK', 'hint --rapid code userscript select.lua')
config.bind('cc', 'spawn -u hint_wrapper copyable select.lua --url')
config.bind('ca', 'spawn -u hint_wrapper copyable select.lua --adoc')
config.bind('cu', 'spawn -u hint_wrapper links select.lua --adoc-url')
config.bind('cC', 'hint --rapid copyable userscript select.lua')
config.bind('ch', 'spawn -u hint_wrapper copyable select.lua --split') #hunk -multi-select → S-enter 
config.bind('cs', 'spawn -u hint_wrapper copyable select.lua --speed')
config.bind('cr', 'spawn -u hint_wrapper copyable select.lua --read')
config.bind('cg', 'spawn -u hint_wrapper copyable select.lua --search')
config.bind('cl', 'spawn -u hint_wrapper copyable select.lua --search:l') # search with deepl
config.bind('ct', 'spawn -u hint_wrapper copyable select.lua --search:t')
config.bind('cd', 'spawn -u hint_wrapper copyable select.lua --search:d')
config.bind('cm', 'spawn -u hint_wrapper copyable select.lua --search:m')
config.bind('cw', 'spawn -u hint_wrapper copyable select.lua --search:w')
config.bind('cv', 'spawn -u hint_wrapper copyable select.lua --search:y') # yt
# duplicate ';y'
config.bind('cy', 'hint links yank')
config.bind('cY', 'hint --rapid links yank')

config.bind('cp', 'print') # create PDF

config.bind('ci', 'hint images download')
config.bind('cI', 'hint --rapid images download')
# config.bind('cic', 'hint images spawn -v xclip -selection clipboard -t image/png -i {hint-url}') script with downloading to tmp and from that copy to clipboard

config.bind('pc', 'open -t {primary}')
config.bind('pC', 'open -t {clipboard}')
config.bind('yu', 'yank inline {url:pretty}[{title}]') # “yank asciidoc-formatted link”
# }}}

# ======================= LEADER and SESSION ============= {{{
config.bind('er', 'config-source')
config.bind('ep', 'spawn -u jspdfdownload')
config.bind('eu', 'edit-url')
config.bind('ef', "spawn firefox {url}")
config.bind('eF', "hint links spawn firefox {hint-url}")
config.bind('eo', 'spawn -u qutedmenu tab') # TODO change to rofi
config.bind('ed', 'spawn -u ~/.config/qutebrowser/userscripts/open_download')
config.bind('ec', 'download-cancel')
config.bind('en', 'spawn -u newsboat-yt-url.sh')

config.bind('es', 'spawn -u session.sh save')
config.bind('el', 'spawn -u session.sh load')
config.bind('ex', 'spawn -u session.sh delete')
config.bind('ew', 'spawn -u session.sh webapp')
# config.bind('es', 'cmd-set-text --space :session-load ')
config.bind('ZZ', ':session-save --only-active-window ;; cmd-later 500 close')    

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

# ======================= Redline and Insert Mode ============= {{{
# config.bind("<Ctrl-h>", "fake-key <Backspace>", "insert")
config.bind("<Ctrl-l>", "fake-key <Ctrl-Right>", "insert")
config.bind("<Ctrl-h>", "fake-key <Ctrl-Left>", "insert")
config.bind("<Ctrl-a>", "fake-key <Home>", "insert")
config.bind("<Alt-a>", "fake-key <Ctrl-a>", "insert")
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
config.bind("<Ctrl-Shift-d>", "fake-key <Shift-End><Delete>", "insert")
config.bind('<Ctrl-y>', 'insert-text {primary}', 'insert') # doesn't work
config.bind("<Ctrl-i>", "edit-text", "insert")
config.bind("<Ctrl-i>", "edit-text")
# :bind gI hint inputs --first ;; mode-enter insert ;; cmd-later 50 edit-text
config.bind('ei', "mode-enter insert ;; fake-key <Enter> ;; mode-enter normal" )
config.bind('<Ctrl-j>', 'fake-key <Down>', 'insert')
config.bind('<Ctrl-k>', 'fake-key <Up>', 'insert')
# }}}

# ================== set-cmd and config ======================= {{{
config.bind('xx', 'jseval -q -f ~/.config/qutebrowser/js/close-popup.js')

config.bind('xa', 'config-cycle --temp --print content.blocking.enabled false true')
config.bind('xj', 'config-cycle --temp --print input.spatial_navigation false true')
config.bind('xw', 'config-cycle --temp --print qt.workarounds.remove_service_workers true false')

config.bind('xp', 'cmd-set-text --space :screenshot ') # todo bind to print scr and get current date
config.bind('xs', 'cmd-set-text --space :scroll-to-anchor ')
# }}}

# ======================= Searchengines ============= {{{
# engine name (such as `DEFAULT`, or `ddg`) to a URL with a `{}` placeholder. The placeholder will be replaced by the search term, use `{{` and `}}` for literal `{`/`}` braces.  
c.url.searchengines = {
    'DEFAULT': 'https://www.google.com/search?q={}',
    'g': 'https://www.google.com/search?q={}',
    'dd': 'https://duckduckgo.com/?q={}',
    'b': 'https://search.brave.com/search?q={}',
    'y': 'https://www.youtube.com/results?search_query={}',
    'p': 'https://piped.kavin.rocks/results?search_query={}',
    'w': 'https://en.wikipedia.org/wiki/{}',
    'wp': 'https://pl.wikipedia.org/wiki/{}',
    'c': 'https://www.ceneo.pl/;szukaj-{}',
    'cc': 'https://cenowarka.pl/?fs={}',
    'am': 'https://www.amazon.com/s?k={}',
    'aw': 'https://wiki.archlinux.org/?search={}',
    'au': 'https://aur.archlinux.org/packages?O=0&K={}',
    'a': 'https://allegro.pl/listing?string={}',
    'f': 'https://www.filmweb.pl/search?q={}',
    'ly': 'https://www.tekstowo.pl/wyszukaj.html?search-artist=Podaj+wykonawc%C4%99&search-title={}',
    'so': 'https://stackoverflow.com/search?q={}',
    'wa': 'https://www.wolframalpha.com/input/?i={}',
    'syn': 'https://www.thesaurus.com/browse/{}?s=t',
    'm': 'https://maps.google.com/maps?q={}',
    'gi': 'https://www.google.com/search?q={}&tbm=isch',
    'l' :'https://www.deepl.com/en/translator#en/pl/{}',
    'd': 'https://www.diki.pl/slownik-angielskiego?q={}',
    't': 'https://translate.google.pl/?hl=pl#pl/en/{}',
    'cam': 'https://dictionary.cambridge.org/spellcheck/english/?q={}', 
    'sci': 'https://sci-hub.se/{}', 
    'gh': 'https://github.com/search?q={}',
    'gr': "https://github.com/search?q={}&type=repositories"
}

# ======================= SEARCH bindings ============= {{{
config.bind('ss', 'open -b g {primary} ')
config.bind('sS', 'open -b g {clipboard} ')
config.bind('ss', 'spawn -u selection.sh g', 'caret')
config.bind('sk', 'open -b dd {primary} ')
config.bind('sK', 'open -b dd {clipboard} ')
config.bind('sk', 'spawn -u selection.sh dd', 'caret')
config.bind('si', 'open -b gi {primary} ')
config.bind('sI', 'open -b gi {clipboard} ')
config.bind('si', 'spawn -u selection.sh gi', 'caret')
config.bind('sm', 'open -b m {primary} ')
config.bind('sM', 'open -b m {clipboard} ')
config.bind('sm', 'spawn -u selection.sh m', 'caret')
config.bind('sb', 'open -b b {primary} ')
config.bind('sB', 'open -b b {clipboard} ')
config.bind('sb', 'spawn -u selection.sh b', 'caret')
config.bind('sc', 'open -b c {primary} ')
config.bind('sC', 'open -b c {clipboard} ')
config.bind('sc', 'spawn -u selection.sh c', 'caret')
config.bind('so', 'open -b cc {primary} ')
config.bind('sO', 'open -b cc {clipboard} ')
config.bind('so', 'spawn -u selection.sh cc', 'caret')
config.bind('sa', 'open -b a {primary} ')
config.bind('sA', 'open -b a {clipboard} ')
config.bind('sa', 'spawn -u selection.sh a', 'caret')
config.bind('st', 'open -b t {primary} ')
config.bind('sT', 'open -b t {clipboard} ')
config.bind('st', 'spawn -u selection.sh t', 'caret')
config.bind('sl', 'open -b l {primary} ')
config.bind('sL', 'open -b l {clipboard} ')
config.bind('sl', 'spawn -u selection.sh l', 'caret')
config.bind('sw', 'open -b w {primary} ')
config.bind('sW', 'open -b w {clipboard} ')
config.bind('sw', 'spawn -u selection.sh w', 'caret')
config.bind('sf', 'open -b f {primary} ')
config.bind('sF', 'open -b f {clipboard} ')
config.bind('sf', 'spawn -u selection.sh f', 'caret')
config.bind('sy', 'open -b y {primary} ')
config.bind('sY', 'open -b y {clipboard} ')
config.bind('sy', 'spawn -u selection.sh y', 'caret')
config.bind('sp', 'open -b p {primary} ')
config.bind('sP', 'open -b p {clipboard} ')
config.bind('sp', 'spawn -u selection.sh p', 'caret')
config.bind('sd', 'open -b d {primary} ')
config.bind('sD', 'open -b d {clipboard} ')
config.bind('sd', 'spawn -u selection.sh d', 'caret')

config.bind('sg', 'cmd-set-text --space :open -t site:{url} ')

config.bind('zz', 'spawn -u selection.sh ')
config.bind('zz', 'spawn -u selection.sh', 'caret')
config.bind('zZ', 'spawn -u selection.sh {clipboard}')
config.bind('<Ctrl-s>', 'open -t {primary} ')
config.bind('<Ctrl-l>', 'open -t l {primary} ')
config.bind('<Ctrl-k>', 'open -t d {primary} ')
config.bind('<Ctrl-Shift-s>', 'spawn -u selection.sh')
config.bind('<Ctrl-s>', 'open -t {primary} ', 'insert')
config.bind('<Ctrl-l>', 'open -t l {primary} ', 'insert')
config.bind('<Ctrl-k>', 'open -t d {primary} ', 'insert')
config.bind('<Ctrl-Shift-s>', 'spawn -u selection.sh', 'insert')
# }}}
# }}}

# ================== Custom hints ======================= {{{
# Selects all code tags whose direct parent is not a pre tag
c.hints.selectors["code"] = [ ":not(pre) > code", "pre", "div.enlighter" ]
c.hints.selectors["p"] = [ "p" ]
c.hints.selectors["copyable"] = [ "p", "ul", "ol", "table", "strong", "header", "article", "section", "main", 
    "h1", "h2", "h3", "h4", "h5", "h6", "blockquote", "i", "dl", "mark" ]
c.hints.selectors['inputs'] += ['input[type="color"]', 'input[type="file"]', 'input[type="checkbox"]', 'input[type="radio"]', 'input[type="range"]', 'input[type="submit"]', 'input[type="reset"]', 'input[type="button"]', 'input[type="image"]', 'form button', 'select', '.dropdown' ]
c.hints.selectors["video"] = [ "ytd-thumbnail a#thumbnail", '.video-grid > div > a:first-child', 'a.router-link-active.router-link-exact-active' ]
# }}}

# ======================= Unused bindings ============= {{{
# config.bind('[', 'scroll left')
# config.bind(']', 'scroll right')
# }}}

# ======================= Test ============= {{{

# c.downloads.position = "bottom"
# c.scrolling.bar = "always"
# c.content.javascript.can_access_clipboard = True
# c.content.notifications.enabled = True
# c.input.insert_mode.auto_load = True
# c.tabs.last_close = "close"
# c.tabs.mousewheel_switching = False
# config.set("content.register_protocol_handler", True, "*://calendar.google.com")
# config.set("content.register_protocol_handler", True, "*://teams.microsoft.com")
# config.set("content.media.audio_video_capture", True, "*://teams.microsoft.com")
# config.set("content.media.audio_capture", True, "*://teams.microsoft.com")
# config.set("content.media.video_capture", True, "*://teams.microsoft.com")
# config.set("content.desktop_capture", True, "*://teams.microsoft.com")
# config.set("content.cookies.accept", "all", "*://teams.microsoft.com")

# config.bind('J', 'move-to-start-of-next-block', 'caret') # [
# config.bind('K', 'move-to-start-of-prev-block', 'caret')
# config.bind(',R', 'spawn -u readability')
# rdrview -B qutebrowser - bład
# config.bind(',F', 'spawn -u openfeeds') - module needed
# move cursor in command mode
# bind go cmd-set-text :open {url:pretty} ;; fake-key -g <Home><Ctrl-Right><Shift-End>
# }}}

# vim: foldmethod=marker
