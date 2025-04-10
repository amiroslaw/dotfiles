#!/usr/bin/env bb
;; TODO
;; unique url remove-duplicate-urls has bug; distinct in sql won't work; maybe forget about duplication and check out if timestamps in mpv works
;; add copying url, title? to clipboard
;; maybe add label to pueue - I would have to pass title or query for the title in util-media
;; add error handling
(require '[babashka.cli :as cli]
         '[babashka.pods :as pods]
         '[babashka.fs :as fs]
         '[babashka.classpath :as cp]
         '[babashka.process :as ps :refer [$ shell process sh]])
(cp/add-classpath (str (System/getenv "HOME") "/.bin/clj"))
(require '[util-media :as media])

(pods/load-pod 'org.babashka/go-sqlite3 "0.2.7")
(require '[pod.babashka.go-sqlite3 :as sql])

(def db-query-limit 500)
(def db {:qutebrowser
         {:path  (str (System/getenv "HOME") "/.local/share/qutebrowser/history.sqlite"),
          :query (str "SELECT DISTINCT CASE WHEN INSTR(url, '&') > 0 THEN SUBSTR(url, 1, INSTR(url,'&') -1) ELSE url END as url, strftime('%m-%d', DATETIME(ROUND (atime), 'unixepoch')) as data, title FROM History WHERE url LIKE 'https://www.youtube%' AND url LIKE '%watch?v%' ORDER BY atime DESC LIMIT " db-query-limit)},
         :newsboat
         {:path  (str (System/getenv "HOME") "/.local/share/newsboat/cache.db"),
          :query (str "SELECT DISTINCT strftime('%m-%d', DATETIME(ROUND(pubDate), 'unixepoch')) as data, author, title ,url FROM rss_item WHERE url LIKE 'https://www.youtube%' AND unread = 1 ORDER BY pubDate DESC LIMIT " db-query-limit)}})

(defn- query-history! [db-name]
  {:pre [(keyword? db-name)]}
  (try
    (sql/query (get-in db [db-name :path]) (get-in db [db-name :query]))
    (catch Exception e
      (notify-error! (str "Query database\n" (.getMessage e)) true))))

(defn- trim-col [column]
  {:post [(string? %)]}
  (if (nil? column)
    ""
    (str " | " (media/trim-col column 20))))

(defn- history->menu
  "Converts database item to a rofi menu format."
  [history]
  {:post [(every? string? %)]}
  (map (fn [row] (str (:data row) (trim-col (:author row)) " | " (:title row))) history))

(defn- items->videos
  "Converts selected menu items to video entries."
  [items history]
  (->> items
       (map parse-long)
       (map (fn [i] (select-keys (get history i) [:url :title])))))

(defn- rofi-history [history keys]
  (let [{:keys [out key exit]}
        (-> history
            history->menu
            (rofi-menu! {:prompt "Select video", :width "80%", :format \i, :keys keys, :multi true, :msg "<b>fullscreen</b>: default action; <b>*q</b>: add to pueue\n"}))]
    (if exit
      {:videos (items->videos out history) :action (last (get keys key))}
      (System/exit 0))))

(defn- execute-actions!
  "Execute the specified action for each URL from the video list
  Parameters:
  - videos: A list of the videos
  - action: The action to execute, which should be a key in the actions map"
  [videos action]
  (doseq [video videos] (ps-error-handler! false (media/cmd-from-action action (:title video)) (:url video))))

(defn- run [db keys default]
  (let [history (query-history! db)
        {:keys [videos action]} (rofi-history history keys)]
    (if action
      (execute-actions! videos action)
      (execute-actions! videos default))))

(def spec {:spec
           {:qutebrowser {:alias :q
                          :desc  "Search youtube videos from qutebrowser history"}
            :newsboat    {:alias :n
                          :desc  "Search youtube videos from newsboat database"}
            :help        {:alias :h :desc "Print this help"}}})

(defn- print-help []
  (printf "A script for searching links from database.
  Options:%n%s
  %nSystem environment for playing audio in terminal:
  TERM_LT and TERM_LT_RUN = %s
  Database paths:
  qutebrowser = %s
  newsboat = %s
  %nDependencies:
   - quetebrowser, newsbout, rofi, mpv
   - optional: pueue"
          (cli/format-opts spec)
          media/term-run
          (get-in db [:qutebrowser :path])
          (get-in db [:newsboat :path])))

(defn- menu [opts]
  (cond
    (opts :qutebrowser) (run :qutebrowser media/rofi-keys :fullscreen)
    (opts :newsboat) (run :newsboat media/rofi-keys :fullscreen)
    (opts :help) (print-help)
    :else (print-help)))

(menu (cli/parse-opts *command-line-args* spec))

(comment
  (count (query-history!))
  (run :qutebrowser media/rofi-keys :fullscreen)
  (run :newsboat media/rofi-keys :fullscreen)

  (trim-col "apropos clojure")

  (deps/add-deps '{:deps {io.github.paintparty/fireworks {:mvn/version "0.10.4"}}})
  (require '[fireworks.core :refer [? !? ?> !?>]])

  (defn- remove-duplicate-urls [history]
    (let [unique-urls (atom [])]
      (filter (fn [item]
                (let [url (:url item)]
                  (if (contains? @unique-urls url)
                    false
                    (do
                      (swap! unique-urls conj url)
                      true))))
              history)))
  )

;(defn- query-history! [db-name]
;  (try
;    (let [path (str (fs/copy (get-in db [db-name :path]) "/tmp/" {:replace-existing true}))] ; Copy database as it might be locked and in use from current
;      (sql/query path (get-in db [db-name :query])))
;    (catch java.nio.file.NoSuchFileException e
;      (notify-error! (str "No database\n" (.getMessage e)) true))
;    (catch Exception e
;      (notify-error! (str "Query database\n" (.getMessage e)) true))))
