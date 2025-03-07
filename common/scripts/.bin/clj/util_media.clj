(ns util-media)

(def term-run
  "A term-run command by concatenating environment variables TERM_LT and TERM_LT_RUN"
  (str (System/getenv "TERM_LT") (System/getenv "TERM_LT_RUN")))
(def audio-dir "~/Musics/PODCASTS/")
(def yt-dir "~/Videos/YouTube/")
  ;; TODO add to env
  ;(System/getenv "AUDIO_DIR"))

;; TODO maybe remove normal actions and left with queue actions
(def rofi-keys
  "List of rofi key bindings for different media operations"
  [["Alt-p" "popup" :popup]
   ["Alt-v" "fullscreen" :fullscreen]
   ["Alt-a" "audio" :audio]
   ["Alt-y" "dl-video" :dl-video]
   ["Alt-d" "dl-audio" :dl-audio]
   ["Alt-o" "open in browser" :open]
   ["Ctrl-Alt-p" "popup q" :popup-q]
   ["Ctrl-Alt-v" "fullscreen q" :fullscreen-q]
   ["Ctrl-Alt-a" "audio q" :audio-q]])

;; TODO add label?
;local out, ok = run('yt-dlp -i --print title "' .. url .. '"')
;local cmd = 'pueue add --escape --label "%s" -g dl-video -- '.. cmdDlp

(def actions
  "Map of actions with commands for different media operations"
  (let [tmp {:popup      "mpv --x11-name=videopopup --profile=stream-popup"
             :fullscreen "mpv --profile=stream"
             :audio      (format term-run "audio" (str "mpv --profile=stream-audio "))
             :dl-video   (str "pueue add --escape -g dl-video -- yt-dlp --embed-metadata -o '" yt-dir "%(title)s.%(ext)s' ")
             :dl-audio   (str "pueue add --escape -g dl-audio -- yt-dlp --embed-metadata -f bestaudio -x --audio-format mp3 -o '" audio-dir "%(title)s.%(ext)s' ")
             :open       "xdg-open"}]
    (merge tmp
           {:popup-q      (str "pueue add -g mpv-popup -- " (:popup tmp))
            :fullscreen-q (str "pueue add -g mpv-fullscreen -- " (:fullscreen tmp))
            :audio-q      (str "pueue add -g mpv-audio -- " (:audio tmp))})))

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
