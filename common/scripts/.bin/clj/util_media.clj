(ns util-media)

(def term-run
  "A term-run command by concatenating environment variables TERM_LT and TERM_LT_RUN"
  (str (System/getenv "TERM_LT") (System/getenv "TERM_LT_RUN")))
(def audio-dir "~/Musics/PODCASTS/")
(def yt-dir "~/Videos/YouTube/")
;; TODO add to env
;(System/getenv "AUDIO_DIR"))

(def rofi-keys
  "List of rofi key bindings for different media operations"
  [["Alt-v" "video in parallel queue" :video]
   ["Alt-p" "popup" :popup]
   ["Alt-a" "audio" :audio]
   ["Alt-y" "dl-video" :dl-video]
   ["Alt-d" "dl-audio" :dl-audio]
   ["Alt-m" "metadata" :metadata]
   ["Alt-o" "open in browser" :open]])

(def actions
  "Map of actions with commands for different media operations"
  {:video      "pueue add -g default --label '%s' -- mpv --profile=stream"
   :popup      "pueue add -g mpv-popup --label '%s' -- mpv --x11-name=videopopup --profile=stream-popup"
   :fullscreen "pueue add -g mpv-fullscreen --label '%s' -- mpv --profile=stream"
   :audio      (str "pueue add -g mpv-audio --label '%s' -- " (format term-run "audio" (str "mpv --profile=stream-audio ")))
   :dl-video   (str "pueue add --escape -g dl-video --label '%s' -- yt-dlp -q --embed-metadata -f bestvideo[height<=1440]+bestaudio/best -o '" yt-dir "%%(title)s.%%(ext)s' ") ;; TODO it doesnt' work
   :dl-audio   (str "pueue add --escape -g dl-audio --label '%s' -- yt-dlp -q --embed-metadata -f bestaudio -x --audio-format mp3 -o '" audio-dir "%%(title)s.%%(ext)s' ")
   :open       "xdg-open"})

(defn- cmd-from-action
  "Get the command from the action map based on the action key"
  [action label]
  (format (get actions action) (clojure.string/escape label {\' "`"})))

(defn- trim-col
  "Trim a column to a specified length, padding with spaces if necessary
 Parameters:
 - column: The string to trim
 - length: The desired length of the output string (default is 20)
 Returns:
 - A string of the specified length"
  ([column] {:post [(string? %)]}
   (trim-col column 20))
  ([column length] {:post [(string? %)]}
   (let [current-length (count column)]
     (if (>= current-length length)
       (str (subs column 0 length))
       (str column (apply str (repeat (- length current-length) " ")))))))

;(defn- trim-col [column]
;  {:post [(string? %)]}
;  (if (nil? column)
;    ""
;    (let [length 20]
;      (if (>= (count column) length)
;        (str " | " (subs column 0 length))
;        (str " | " column (apply str (repeat (- length (count column)) " ")))))))
