#!/usr/bin/env bb
;; TODO
; function guards
; in rofi-menu keybindings descriptions does't show in msg

(require '[babashka.process :as ps :refer [$ shell process sh]]
         '[clojure.string :as str]
         '[babashka.fs :as fs]
         '[taoensso.timbre :as timbre]
         '[taoensso.timbre.appenders.core :as appenders]
         '[clojure.core.match :refer [match]]
         )

(def default-options {:prompt "Select", :width "500px", :height 23, :multi "", :msg "", :keys "", :format "s"})
(def default-color "#08D9D6")

(timbre/merge-config!
  {:appenders {:spit (appenders/spit-appender {:fname "/tmp/clj/scripts.log"})}})
; it can take a vector as msg wth java exception
(defn log!
  "Logs a message at a specified log level using Timbre. Logs will be saved in /tmp/clj/scripts.log.
    Parameters:
    - msg: The message to be logged.
    - level: The log level, which can be :info, :error, or :warn. Defaults to :info if not provided."
  ([msg] (log! msg :info))
  ([msg level]
   (case level
     :info (timbre/info msg)
     :error (timbre/error msg)
     :warn (timbre/warn msg)
     (timbre/info msg))))

(defn- create-keys-bindings [opts]
  (map-indexed (fn [index [keybinding title]]
                 [(format " -kb-custom-%d '%s' " (inc index) keybinding)
                  (format "<span color='%s'>'%s'</span>:%s " default-color keybinding title)])
               opts))

(defn- add-keys [defaults keys-opt]
  (let [keys (create-keys-bindings keys-opt)
        keybindings (map first keys)
        titles (map second keys)]
    (assoc defaults :keys (str/join " " keybindings)
                    :msg (str (:msg defaults) (str/join " " titles)))))

(defn- combine-options [options]
  (cond-> (merge default-options options)
          (contains? options :multi) (assoc :multi " -multi-select")
          (contains? options :msg) (assoc :msg (str (:msg options) " ")) ;; or change to %n new line
          (contains? options :keys) (add-keys (:keys options))))

(defn notify-error!
  "Notifies the user of an error message and logs it. Optionally exits the program.
  Parameters:
  - msg: The error message to be displayed and logged.
  - exit: A boolean indicating whether to exit the program after notifying and logging the error. Defaults to false."
  ([msg] (notify-error! msg false))
  ([msg exit?]
   (sh "notify-send -u critical" "Error:" msg)
   (log! msg :error)
   (when exit? (System/exit 1))))

(defn ps-error-handler! [exit? cmd & args]
  "Executes a shell command and handles errors.
  Parameters:
  - exit?: A boolean indicating whether to exit the program on error.
  - cmd: The shell command to execute.
  - args: Additional arguments for the shell command.
  Returns the output of the command if successful, otherwise logs and notifies the error."
  (try
    (let [{:keys [out exit err]} (apply sh cmd args)]
      (if (zero? exit)
        out
        (notify-error! err exit?)))
    (catch Exception e
      (notify-error! (.getMessage e) exit?))))

(defn- replace [text pattern color]
  (str/replace text (re-pattern (str pattern)) (format "<span color='%s'>%s</span>" color pattern)))

(defn- apply-style [text styles]
  (let [txt (atom text)]
    (doseq [style styles]
      (if (map? style)
        (doseq [[k v] style] (swap! txt replace k v))
        (swap! txt replace style default-color)))
    @txt))

;(defn escape-rofi-label [label]
;  (string/escape label {\& "&amp;"}))
(defn notify!
  "Send a notification using the 'notify-send' command.
    (notify! \"msg\" \"body red and default styles \" [\"default\" {\" red \" \"pink\"}])
    Parameters:
    - msg: The message to display in the notification.
    - body: Optional. The body text of the notification.
    - style: Optional. The style to apply to the notification body. Vector with text patterns or map with {pattern: colour}."
  ([msg] (notify! msg nil nil))
  ([msg body] (notify! msg body nil))
  ([msg body style] (sh "notify-send" msg (apply-style body style))))

(defn dialog!
  "Displays a dialog using 'rofi' with the given message and optional style.
  Parameters:
    msg   - The message to display in the dialog.
    style - Optional. The style to apply to the message. Vector with text patterns or map with {pattern: colour}."
  ([msg] (dialog! msg nil))
  ([msg style]
   (sh "rofi -markup -e" (apply-style msg style))))

(defn rofi-input!
  "Displays an input dialog using the `rofi` command-line tool with optional configuration.
  Parameters:
  - `options`: An optional map of configuration options for the input dialog. Supported keys include:
    - `:prompt` - A string to display as the prompt in the input dialog.
    - `:width` - A string specifying the width of the input dialog window. It accepts units like '80px', '80%', or '80ch'.
    - `:msg` - A string to display as a message in the input dialog. It supports Pango markup (like html) for styling.
  Returns:
  A string representing the user's input, with any trailing newline characters removed. If the input dialog is escaped, it returns empty string.
  Usage:
  (rofi-input!)
  (rofi-input! {:prompt \"Enter your name\" :msg \"<b>Note:</b> This is a required field.\"})"
  ([] (rofi-input! {}))
  ([options] {:pre [(map? options)]}
   (as-> (combine-options options) opt                      ;; as is not needed
         (format "rofi -monitor -4 -theme-str 'window {width: %s;}' -l 0 -dmenu -p '%s' %s" (:width opt) (:prompt opt) (:msg opt))
         (sh opt)
         (:out opt)
         (str/replace opt #"\n" ""))))

(defn- rofi-dynamic-width [prompt]
  (rofi-input! {:prompt prompt, :width (str (+ 11 (count prompt)) "ch")}))

(defn rofi-number-input!
  "Displays a number input dialog using the `rofi` command-line tool with an optional `prompt`.
  Parameters:
  - `prompt`: An optional string to display as the prompt in the input dialog. Defaults to \"Enter number\" if not provided.

  Returns:
  - A parsed long integer if the user enters a valid number.
  - `nil` if the input dialog is escaped or if the input is empty.
  - If the input is not a valid number, the function recursively re-displays the input dialog.

  Usage:
  ```clojure
  (rofi-number-input!)
  (rofi-number-input! \"Enter your age\")
  ```"
  ([] (rofi-number-input! "Enter number"))
  ([prompt] (rofi-number-input! prompt (rofi-dynamic-width prompt)))
  ([prompt out]
   (let [out-parsed (parse-long out)]
     (cond
       (empty? out) nil                                     ; exit rofi
       (number? out-parsed) out-parsed
       :else (rofi-number-input! prompt (rofi-dynamic-width prompt))))))

(defn- lines->vec [string]
  (vec (str/split-lines string)))

(defn- rofi-menu-return [selected exit]
  (cond
    (= 0 exit) {:out (lines->vec selected), :exit true}
    (= 1 exit) {:out [], :exit nil}                         ; escape rofi
    (and (>= exit 10) (< exit 30)) {:out (lines->vec selected), :key (- exit 10), :exit true} ; keybinding
    :else (do (notify-error! "Rofi error")                  ; error
              {:out [], :err "Rofi error", :exit false})))

(defn rofi-menu!
  "Displays a menu using the `rofi` command-line tool with the given `entries` and optional `options`.

  Parameters:
  - `entries`: A collection of strings or a single string (entries separated with new lines) representing the menu items to be displayed.
  - `options`: An optional map of configuration options for the menu. Supported keys include:
    - `:prompt` - A string to display as the prompt in the menu.
    - `:width` - A string specifying the width of the menu window. It accepts following units: 80px;80%;80ch
    - `:height` - An integer specifying the maximum number of visible entries in the menu. Default: 24
    - `:multi` - A boolean indicating whether multiple selections are allowed, default: false
    - `:msg` - A string of strings to display as a message in the menu.
    - `:keys` - A vector of keybindings for custom actions. It accepts pango markup(html like). Msg should fit in one line otherwise it will show fewer entries, use width to adjust.
    - `:format` - A character specifying the format of the output. Default: 's' - string. 'i'/'d' - index of the selected item 0/1 based index.

  Returns:
  A map with the following keys:
  - `:out` - A vector of selected entries if the user made a selection, an empty vector if the menu was escaped or error appeared.
  - `:key` - An integer representing the custom keybinding was used, or nil otherwise.
  - `:exit` - Represents the output state: true if an item was selected; nil for escape and false for error.
  - `:err` - A string with an error message if an error occurred, or nil otherwise.

  Usage:
  ```clojure
  (def keys [[\"Alt-j\" \"anonymous function\" (fn [] (println \"fun in keys\"))] [\"Alt-q\" \"stop function\" :stop]])
  (def user-options {:prompt \"Prompt name \", :format \\i :width \"500px\", :multi true, :msg \"message body with <b>html</b>\", :keys keys})
  (rofi-menu! [\"a\" \"b\" \"c\"] user-options)
  ```"
  ([entries] (rofi-menu! entries {}))
  ([entries options] {:pre [(map? options)
                            (if (contains? options :keys) (vector? (:keys options)) true)]}
   (let [opt (combine-options options)
         height (if (> (count entries) (:height opt)) (:height opt) (count entries))
         entries (if (string? entries) entries (str/join "\n" entries)) ; todo ? (vec entries)
         msg (when (not-empty (:msg opt)) (format " -markup -mesg \"%s\"" (:msg opt)))]
     (let [{:keys [exit out]}
           (sh {:in entries}
               (format "rofi -format %s %s -monitor -4 -i -l %s -dmenu -p '%s' -theme-str 'window {width:  %s;}' %s %s"
                       (:format opt) (:multi opt) height (:prompt opt) (:width opt) (:keys opt) msg))]
       (rofi-menu-return out exit)))))

(defn create-dir!
  "Creates a directory at the specified path. If the path is invalid, an error notification is triggered.
  A path can have nested directories as mkdir -p."
  [path]
  (try
    (str (fs/create-dirs path))
    (catch Exception e
      (notify-error! (str "Invalid path for a new dir: " path)))))

(def default-scratchpad-dir "/tmp/clj/")
(def default-scratchpad-suffix ".adoc")
(def default-scratchpad-name "scratchpad")
;; TODO add TERM_FONT
(defn scratchpad!
  "Creates or opens a scratchpad text file in a terminal editor.

    If the provided text is a file, it opens the file in the terminal editor.
    Otherwise, it creates a temporary file with the given text and opens it.

    Parameters:
    - txt: The text content or file path to be opened in the editor.
    - opts: An optional map of options:
      - :terminal: Specifies the terminal type (:light or :wez). Wezterm has non-standard cli options.
      - :dir: Directory where the scratchpad file will be created.
      - :name: Name of the scratchpad file.
      - :prefix: Prefix for the scratchpad file name.
      - :suffix: Suffix for the scratchpad file name, it can be an extension file.

    Uses environment variables to determine terminal commands."
  ([txt]
   (scratchpad! txt {:terminal :light, :dir default-scratchpad-dir :suffix default-scratchpad-suffix}))
  ([txt opts]
   (let [term-cmd (if (= (:terminal opts) :wez)
                    (str (System/getenv "TERMINAL") (System/getenv "TERM_RUN"))
                    (str (System/getenv "TERM_LT") (System/getenv "TERM_LT_RUN")))
         dir (if-let [dir (:dir opts)]
               dir
               default-scratchpad-dir)
         name (if-let [name (:name opts)]
                name
                default-scratchpad-name)
         prefix (if-let [prefix (:prefix opts)]
                  (str prefix "-")
                  "")
         suffix (if-let [suffix (:suffix opts)]
                  suffix
                  default-scratchpad-suffix)]
     (println term-cmd)
     (if (fs/regular-file? txt)
       (sh (format term-cmd name (str "nvim " txt)))
       (do (create-dir! dir)
           (let [file (.toString (fs/create-temp-file {:dir dir :prefix prefix :suffix suffix}))]
             (spit file txt)
             (sh (format term-cmd name "nvim") file)))))
   ))

(defn editor!
  "Opens the given input in a GUI editor. It needs 'GUI_EDITOR' environment variable.
  If the input is a regular file, it opens it directly."
  ([input]
   (if-let [editor-name (System/getenv "GUI_EDITOR")]
     (editor! input editor-name)
     (notify-error! "No GUI editor found")))
  ([input editor-name]
   (if (fs/regular-file? input)
     (sh editor-name input)
     (let [file (.toString (fs/create-temp-file {:dir    (create-dir! default-scratchpad-dir)
                                                 :prefix "clj-" :suffix default-scratchpad-suffix}))]
       (spit file input)
       (sh editor-name file)))))

(defn get-properties!
  "Loads properties from a file at the given path if it is a regular file. It needs to be a java properties file.
  Returns a map with the property names and values."
  ([path]
   (if (fs/regular-file? path)
     (doto (new java.util.Properties)
       (.load (new java.io.FileInputStream path))
       (.stringPropertyNames))                              ;; TODO maybe convert keys to keywords
     (notify-error! (str "No config file " path))))
  ([path key]
   (get (get-properties! path) key)))

(defn format-cmds!
  "Format cmds for subcommands from babashka.cli. It is useful for generating a help option."
  [table]
  (format "Commands:%n%s%n"
          (transduce (comp (filter (comp seq :cmds))
                           (map (fn format-row
                                  [{:keys [cmds desc]}]
                                  (format "  %s: %s %n"
                                          (str/join " " cmds)
                                          (if (empty? desc) ""
                                                            desc)))))
                     (fn join-lines
                       ([] "")
                       ([a] a)
                       ([a b] (str a b)))
                     table)))

(def UTF-8 (java.nio.charset.StandardCharsets/UTF_8))
(def url-pattern "https?://[^/]+")
(defn url? [url-str]
  (try (io/as-url url-str)
       true
       (catch Exception _
         false)))

(defn url-params
  "Parses URL parameters.
  There are two arities:
  1. ([url param]) - Returns the value of the specified parameter from the URL or nil.
  2. ([url]) - Returns a map of all parameters and their values from the URL or nil if no parameters."
  ([url param]
   {:pre  [(url? url) (string? param)]
    :post [(or (nil? %) (string? %))]}
   (get (url-params url) param))
  ([url]
   {:pre  [(url? url)]}
   (if-let [params (second (str/split url #"\?"))]
     (-> params
         (java.net.URLDecoder/decode UTF-8)
         (str/split #"&")
         (->> (into {} (map #(str/split % #"="))))))))

(defn http-error-handler!
  ([response] (http-error-handler! response nil))
  ([response json-error-path]
   {:pre [(map? response)]}
   (let [status (:status response)
         body (json/parse-string (:body response) true)]
     (if (= status 200)
       body
       (notify-error! (format "HTTP error: %s\n%s" status (get-in body json-error-path body)) false) ;; TODO change to true
       ))))

(comment
  (require '[portal.api :as p])
  (add-tap #'p/submit)
  (def p (p/open {:launcher :intellij}))
  (tap> :hello))

(comment
  (log! "default")
  (log! "default" :error)
  (log! ["This is an error message with an exception" (Exception. "Test Exception")])
  ;; Log messages but Idk how to change  it or execute
  (timbre/log! {:level     :info
                :output-fn (fn [d] (force (:msg_ d)))
                :args      ["This is an info message"]
                ;:msg_ "This is an info message"
                })
  (timbre/log! :warn nil "test error")
  (timbre/log! :warn :f "test error")
  (get (get-properties! "/home/miro/t.pro") "topic")
  (type (get-properties! "/home/miro/t.pro"))
  (type (get-properties! "~/t.pro"))
  ;; apply-style
  (tap> (apply-style " to powinno być czerwone a to czarne " [{" czerwone " "red", "czarne" "black"}]))
  (tap> (apply-style " to powinno być czerwone a to czarne " [" czerwone " "czarne"]))
  (tap> (apply-style " to powinno być domyślne a to czerwone " ["domyślne" {" czerwone " "red"}]))
  (notify! "msg")
  (notify! "msg" "body z style czerwone i domyślne " ["domyślne" {" czerwone " "red"}])
  (dialog! "msg z style czerwone i domyślne " ["domyślne" {" czerwone " "red"}])
  (dialog! "msg z \"bez\" style")
  (notify-error! "error-msg")

  (tap> (rofi-number-input! "test"))
  (tap> (rofi-input!))
  (tap> (rofi-input! {:prompt "changes" :msg "<b>hello</b>"}))
  (print (notify-error! "err \"msg wit\" q"))
  (tap> (rofi-input! {:prompt "changes"}))
  (print (:out (shell {:out :string} "ls -l")))
  (editor! "jakiś tekst2")
  (editor! "/home/miro/t.txt")

  ;; keys bindings
  (tap> (create-keys-bindings {["Alt-j" "opt title" :stop] ["Alt-q" "stop app" :app]}))
  (def user-options {:prompt "Zmienioe ", :width "50px", :multi "", :msg "<b>hello</b>", :keys ""})
  (def user-options {:prompt "Zmienioe ", :width "50px", :multi true, :msg "<b>hello</b>", :keys ""})
  (tap> (combine-options user-options))

  (tap> (create-keys-bindings [["Alt-j" "opt title" :stop] ["Alt-q" "stop app" :app]]))
  ;(def keys [["Alt-j" "opt title" :run ] ["Alt-q" "stop app" :stop ]])
  (rofi-menu! ["a" "b" "c"] {:format \i})
  (tap> (rofi-menu! ["a" "b" "c"]))
  (tap> (rofi-menu! ["a" "b" "c"] {:prompt "Zmienioe ", :width "504px", :multi "-multi-select"}))
  (def keys [["Alt-j" "anonymous function" (fn [] (println "fun in keys"))] ["Alt-q" "stop function" :stop]])
  (defn stop-fn [] (println "defined function stop evaluated"))
  (def actions {:stop stop-fn, :run (fn [] (println "function run"))})
  (def user-options {:prompt "Zmienioe ", :width "300px", :multi true, :msg "aaa bbb", :keys keys})
  (let [{:keys [out exit]} (rofi-menu! ["a" "b" "c"] user-options)]
    ((last (get keys exit)))                                ;; evaluate function
    ;; functions in separated map
    (((last (get keys exit)) actions))
    ;(if (fu? (get keys exit)))                              ;; jak chcemy mieszać
    )
  (tap> (rofi-menu! ["a" "b" "c"] user-options))
  )
