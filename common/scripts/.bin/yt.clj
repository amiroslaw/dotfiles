#!/usr/bin/env bb
(require '[babashka.process :as ps :refer [$ shell process sh]]
         '[clojure.string :as str]
         '[babashka.cli :as cli]
         '[babashka.http-client :as http]
         '[clojure.core.match :refer [match]]
         '[babashka.classpath :as cp]
         '[clojure.java.io :as io]
         '[cheshire.core :as json])
(cp/add-classpath (str (System/getenv "HOME") "/.bin/clj"))
(require '[util-media :as media])
(import '[java.time Duration])
;; TODO refactoring: convert rest to entity with unified fields - title, channel, date, description, videoId
;; not all options implemented spec-source - clip, primary, maybe it is not needed

(declare subcommands)
(def UTF-8 (java.nio.charset.StandardCharsets/UTF_8))

(def base-url "https://www.googleapis.com/youtube/v3/")
(def yt-watch-url "https://www.youtube.com/watch?v=")

(defn- get-property [key]
  {:pre [(string? key)] :post [(string? %)]}
  (-> (str (System/getenv "PRIVATE") "/keys.properties")
      (get-properties! key)
      (or (notify-error! (str "Key not found: \n" key) false))))

(defn- prompt-input []
  {:post [(string? %)]}
  (let [input (rofi-input! {:prompt "Search yt videos  ", :width "50 %"})]
    (if (str/blank? input)
      (System/exit 0)
      input)))

;; todo, change to clipcat
(defn- clipboard [type]
  {:pre [(string? type)]}
  (ps-error-handler! true (str "clipster --output -m '' --" type)))

;; Data Fetching
(defn- fetch-playlist [id]
  {:pre  [(string? id)]
   :post [(vector? %)]}
  (-> (str base-url "playlistItems"
           "?key=" (get-property "yt_api_key")
           "&playlistId=" id
           "&part=snippet"                                  ;; status is for live
           ;"&fields=items(snippet(resourceId(videoId)))"
           "&fields=items(snippet(title,channelTitle,publishedAt,description,resourceId))"
           "&maxResults=50")
      (http/get {:throw false})
      (http-error-handler! [:error :message])
      :items))

(defn- fetch-user-playlists
  "Fetches playlists from the user's channel."
  [channel-id]
  {:pre [(string? channel-id)] :post [(vector? %)]}
  (-> (str base-url "playlists"
           "?key=" (get-property "yt_api_key")
           "&channelId=" channel-id
           "&part=snippet"
           "&fields=items(id,snippet(title,description))"
           "&maxResults=50") ;; default is 5, max is 50
      (http/get {:throw false})
      (http-error-handler! [:error :message])
      :items))

(defn- fetch-videos [query]
  (when-not (string? query)
    (System/exit 0))
  (-> (str base-url "search"
           "?key=" (get-property "yt_api_key")
           "&q=" query
           "&part=snippet"
           "&fields=items(id(videoId),snippet(title,channelTitle,publishedAt,description))"
           "&maxResults=50"
           "&type=video"
           "&safeSearch=moderate"                           ;; none, moderate, strict
           "&videoDimension=2d")
      (http/get {:throw false})
      (http-error-handler! [:error :message])
      :items))

(defn- fetch-metadata
  [video-ids]
  {:pre [(string? video-ids)]}
  (-> (str base-url "videos"
           "?key=" (get-property "yt_api_key")
           "&id=" video-ids                                 ;; can take multiple ids
           "&part=snippet,contentDetails,statistics"
           "&fields=items(id,snippet(title,channelTitle,publishedAt,description,liveBroadcastContent),contentDetails(duration),statistics(viewCount,likeCount,commentCount))")
      (http/get {:throw false})
      (http-error-handler! [:error :message])
      :items))

;; METADATA
(defn- live-status [meta]
  {:post [(string? %)]}
  (match [(:liveBroadcastContent (:snippet meta)) (:viewCount (:statistics meta))]
         [_ nil] "\uD83D\uDCB5 Paid"
         ["upcoming" _] "\uD83D\uDCC6 Upcoming"
         ["live" _] "\uD83D\uDD34 Live"
         ["none" _] ""))

(defn- format-duration [s]
  {:post [(string? %)]}
  (if s
    (let [duration (Duration/parse s)
          hours (.toHoursPart duration)
          minutes (.toMinutesPart duration)
          seconds (.toSecondsPart duration)]
      (format "%02d:%02d:%02d" hours minutes seconds))
    ""))

(defn- format-date [s]
  {:pre  [(string? s)]
   :post [(string? %)]}
  (first (str/split s #"T")))

(defn- format-metadata [meta]
  {:post [(string? %)]}
  (if-not meta
    "\uD83D\uDED1 Private video"
    (let [{:keys [snippet contentDetails statistics]} meta
          {:keys [title channelTitle publishedAt description liveBroadcastContent]} snippet
          {:keys [duration]} contentDetails
          {:keys [viewCount likeCount commentCount]} statistics]
      (format "%s - %s \n%s | %s | %s \n%s \uD83D\uDC4D | %s \uDB80\uDD99 | %s \uDB82\uDC5F \n\n%s"
              title channelTitle
              (format-duration duration)
              (format-date publishedAt)
              (live-status meta)
              likeCount
              (or viewCount "0")
              commentCount
              description))))

(defn- url->id [url]
  {:post [(string? %)]}
  (cond
    (not (url? url)) (notify-error! (str "Not a valid URL: " url) true)
    (url-params url "v") (url-params url "v")
    (str/includes? url "/shorts/") (last (str/split url #"/"))
    :else (notify-error! (str "No video ID found in URL: " url) true)))

(defn- metadata
  [{opts :opts}]
  (let [data-list (fetch-metadata (url->id (:url opts)))
        text-status (format-metadata (first data-list))]
    (if (:notify opts)
      (notify! text-status)
      (println text-status))))

(defn- item->menu [item]
  {:pre  [(map? item)] :post [(string? %)]}
  (let [snippet (:snippet item)
        date (first (str/split (:publishedAt snippet) #"T"))]
    (format "%s | %s | %s" date (media/trim-col (:channelTitle snippet)) (:title snippet))))

(defn- response->video [res]
  {:pre  [(map? res)] :post [(map? %)]}
  (let [title (get-in res [:snippet :title])
        id-from-playlist (get-in res [:snippet :resourceId :videoId])
        id (get-in res [:id :videoId] id-from-playlist)]
    {:url (str yt-watch-url id), :title title}))
;; TODO add safe subs
;(if (<= (count title) 50)
;  title
;  (subs title 50))

(defn- rofi-selections->videos
  "Converts selected menu items to maps with URL and title."
  [items response]
  (->> (rofi-indexes->inputs items response)
       (map response->video)))

(defn- rofi-video-menu [response]
  {:pre  [(vector? response) (every? map? response)]
   :post [(map? %)]}
  (let [menu (map item->menu response)
        {:keys [out key exit]}
        (-> menu
            (rofi-menu! {:prompt "Select video", :width "80%", :format \i, :keys media/rofi-keys, :multi true, :msg "default action: <b>fullscreen</b>"}))]
    (if exit
      {:items out, :key key}
      (System/exit 0))))

(defn- response->playlist [res]
  {:pre  [(map? res)] :post [(map? %)]}
  (let [title (get-in res [:snippet :title])
        desc (get-in res [:snippet :description])
        id (:id res)]
    {:id id, :title title, :desc desc}))

(defn- rofi-playlists-menu [response]
  {:pre  [(sequential? response)] :post [(sequential? %)]}
  (let [menu response
        {:keys [out exit]}
        (-> menu
            (rofi-menu! {:prompt "Select playlist", :width "80%", :format \i }))]
    (if exit
      out
      (System/exit 0))))

(defn- query [opts]
  (let [query (match [opts]
                     [{:query q}] q
                     [{:clip _}] (clipboard "clip")
                     [{:primary _}] (clipboard "primary")
                     [{:url u}] u
                     :else (prompt-input))]
    (java.net.URLEncoder/encode query UTF-8)))

(defn- execute-actions!
  "Execute the specified action for each video in the list
  Parameters:
  - videos: A list of videos to process
  - action: The action to execute, which should be a key in the actions map"
  [videos action]
  {:pre [(seq? videos) (keyword? action)]}
  (doseq [video videos]
    (ps-error-handler! false (media/cmd-from-action action (:title video)) (:url video))))

(defn- rofi-videos [response]
  {:pre [(vector? response) (every? map? response)]}
  (let [{:keys [items key]} (rofi-video-menu response)
        videos (rofi-selections->videos items response)
        action (last (get media/rofi-keys key))]
    (case action
      nil (execute-actions! videos :fullscreen)
      :metadata (do (doseq [v videos] (metadata {:opts {:notify true :url (:url v)}})) (rofi-videos response))
      (execute-actions! videos action))))

(defn- format-m3u-item [meta]
  (let [url (str yt-watch-url (:id meta))
        title (get-in meta [:snippet :title] "-")
        duration (get-in meta [:contentDetails :duration])
        seconds (if duration (.toSeconds (Duration/parse duration)) -1)]
    (format "#EXTINF:%d,%s%n%s%n" seconds title url)))

(defn- create-playlist [playlist]
  (let [m3u-items (->> playlist
                       (map :snippet)
                       (map :resourceId)
                       (map :videoId)
                       (str/join ",")
                       fetch-metadata
                       (map format-m3u-item))
        playlist-title (rofi-input! {:prompt "Playlist title"})]
    (with-open [wrtr (io/writer (str playlist-title ".m3u"))]
      (.write wrtr (str "#EXTM3U\n"))
      (.write wrtr (format "#PLAYLIST: %s\n" playlist-title))
      (doseq [line m3u-items]
        (.write wrtr line)))))

(defn- select-user-playlist [id]
  {:pre [(string? id)]}
  (let [response (fetch-user-playlists id)
        playlists (map response->playlist response)
        rofi-items (map #(format "%s\t | %s" (:title %)   (first (str/split (:desc %) #"\n")) ) playlists)
        selected (rofi-playlists-menu rofi-items)
        playlist (rofi-indexes->inputs selected playlists)]
    (:id (first playlist))))

(defn- playlist
  [{opts :opts}]
  (let [list-id (match [opts]
                     [{:url u}] (url-params u "list")
                     [{:channel _}] (select-user-playlist (get-property "yt_channels"))
                     [{:channel-id i}] (select-user-playlist i)
                     :else  (notify-error! "No playlist URL or channel ID provided" false))
        playlist (fetch-playlist list-id)]
    (if (:m3u opts)
      (create-playlist playlist)
      (rofi-videos playlist))))

(defn- search-videos
  [{opts :opts}]
  (rofi-videos (fetch-videos (query opts))))

(defn- url-spec [desc]
  {:desc  desc
   :validate {:pred url? :ex-msg (fn [m] (str "Not a url: " (:value m)))}
   :alias    :u})

(def spec-search
  {:input {:desc   "Provide search string query in rofi input. Default if not provided a different option."
           :coerce :boolean
           :alias  :i}
   :query {:desc  "Provide search string query in terminal."
           :alias :q}})

(def spec-stats
  {:url (url-spec "The URL of the video.");; TODO allow multiple urls
  :notify {:desc   "Create notification with a video status."
            :coerce :boolean
            :alias  :n}})

(def spec-playlist
  {:url (url-spec    "Take a URL from terminal argument.")
   :channel-id  {:desc  "Get the channel playlists, provide the channel id."
          :validate {:pred string? :ex-msg (fn [m] (str "Not a string: " (:value m)))}
          :alias    :d}
   :channel  {:desc "Get the channel playlists. Script will fetch its id from the key `yt_channels` in the properties file ."
              :coerce :boolean
              :alias  :h}
   :m3u {:desc   "Create m3u playlist from a Youtube playlist."
         :coerce :boolean
         :alias  :m}}) ;; TODO add saving path
;local DIR_PLAYLISTS = os.getenv 'HOME' .. '/Templates/mpvlists'

(def spec-source
  {:clip    {:desc   "Take a URL from clipboard - default."
             :coerce :boolean
             :alias  :c}
   :primary {:desc   "Take a URL from primary clipboard."
             :coerce :boolean
             :alias  :p}})

(defn- print-help [_]
  (printf "A script that interacts with YouTube API.  %n%s
Options for providing input for all commands:%n%s%n
Options for `search` command:%n%s%n
Options for `stats` command:%n%s%n
Options for `palylist` command:%n%s%n
Examples:
   yt.clj search --query 'babashka'
   yt.clj search --input
   yt.clj search --clip
   yt.clj stats --notify -u 'https://www.youtube.com/watch?v=hoCk655vgtc'
   yt.clj playlist --m3u --clip
   yt.clj playlist -d UCX6b17PVsYBQ0ip5gyeme-Q
  source <(yt.clj completions)  → source zsh completions
%nDefault values can be override via system environment. The values:
TERM_LT and TERM_LT_RUN = %s
%nDependencies:
 - clipster, rofi "
          (format-cmds! subcommands)
          (cli/format-opts {:spec spec-source})
          (cli/format-opts {:spec spec-search})
          (cli/format-opts {:spec spec-stats})
          (cli/format-opts {:spec spec-playlist})
          media/term-run))

(def subcommands
  [{:cmds ["search"] :desc "Search videos." :fn search-videos :spec (merge spec-search spec-source)}
   {:cmds ["playlist"] :desc "List a Youtube playlist in rofi menu (default) or create (m3u) playlist." :fn playlist :spec spec-playlist}
   {:cmds ["stats"] :desc "Retrieve metadata form the video." :fn metadata :spec (merge spec-source spec-stats)}
   {:cmds [] :desc "Show help." :fn print-help}])

(when (= *file* (System/getProperty "babashka.file"))
  (cli/dispatch (conj subcommands {:cmds ["completions"] :fn (partial completion! subcommands)}) *command-line-args*))

(comment
  (cli/dispatch subcommands ["help"])

  (cli/dispatch subcommands ["stats" "-n" "-u" "https://www.youtube.com/watch?v=3JZ_D3ELwOQ"])
  (cli/dispatch subcommands ["stats" "-u" "https://www.youtube.com/watch?v=uXi8PXU2oS4"]) ; short
  (cli/dispatch subcommands ["stats" "-u" "https://www.youtube.com/shorts/Gs0GpLx75rQ"]) ; short
  (cli/dispatch subcommands ["stats" "-u" "https://www.youtube.com/Gs0GpLx75rQ"]) ; no id

  (cli/dispatch subcommands ["stats" "-u" "https://www.youtube.com/watch?v=xKqK8AR2W4U"]) ;; online
  (cli/dispatch subcommands ["stats" "-u" "https://www.youtube.com/watch?v=dus7vXctRBE"]) ;; wspierający ended stream
  (cli/dispatch subcommands ["stats" "-u" "https://www.youtube.com/watch?v=rItfOh3qnfs"]) ;; scheduled
  (cli/dispatch subcommands ["stats" "-u" "https://www.youtube.com/watch?v=h2WdKyX0zMg"]) ;; support
  (cli/dispatch subcommands ["stats" "-u" "https://www.youtube.com/watch?v=QrAEubM4f6o"]) ;; private

  (cli/dispatch subcommands ["stats" "-u" "https://www.youtube.com/watch?v=3JZ_D3ELwOQ" "-u" "https://www.youtube.com/watch?v=3JZ_D3ELwOQ"])
  (cli/dispatch subcommands ["playlist"])
  (cli/dispatch subcommands ["playlist" "-d" "UCX6b17PVsYBQ0ip5gyeme-Q"])
  ;;
  (cli/dispatch subcommands ["search" "-q" "short black animation"])
  (cli/dispatch subcommands ["search" "-q" "clojure"])
  (cli/dispatch subcommands ["search" "-i"])
  (cli/dispatch subcommands ["search" "-p"])

  (url-params "https://www.youtube.com/watch?v=XYmWdNlikNw&list=PLyvQyFCJcBAELIjEHFZECH6pfcywBqTBT" "list")
  (cli/dispatch subcommands ["playlist" "-m" "-u" "https://www.youtube.com/watch?v=XYmWdNlikNw&list=PLyvQyFCJcBAELIjEHFZECH6pfcywBqTBT"])
  (response->menu (cli/dispatch subcommands ["search" "-q" "clojure"]))
  (def res [{:id      {:videoId "MF-A46cTYUY"}
             :snippet {:publishedAt  "2025-02-26T08:22:19Z"
                       :title        "Alex Engelberg guests on Apr"
                       :description  "Welcome! Special guest Alex "
                       :channelTitle "apropos clojure"}}])
  (response->menu res)

  (def date "2025-02-26T08:22:19Z")
  (def item {:id      {:videoId "MF-A46cTYUY"}
             :snippet {:channelTitle "apropos clojure"
                       :description  "Welcome! Special guest Alex Engelberg!"
                       :publishedAt  "2025-02-26T08:22:19Z"
                       :title        "Alex Engelberg guests on Apropos Clojure 2025-02-25"}})
  (trim-col "apropos clojure")

  ;; Replace with your duration string
  (def duration-str "PT1H30M15S")
  (println (format-duration "PT4M14S"))
  (println (format-duration "2024-02-26T08:22:19Z"))
  (? (completion subcommands nil))
  (? (first subcommands))
  )

(comment
  (require '[babashka.deps :as deps])
  (deps/add-deps '{:deps {djblue/portal {:mvn/version "0.58.1"}}})
  (require '[portal.api :as p])
  (add-tap #'p/submit)
  (def p (p/open {:launcher :intellij}))
  (tap> :hello)
  (load-file (str (System/getenv "HOME") "/Documents/dotfiles/common/scripts/.bin/clj/init.clj"))

  (deps/add-deps '{:deps {dev.weavejester/hashp {:mvn/version "0.3.0"}}})
  (require 'hashp.preload)

  (deps/add-deps '{:deps {io.github.paintparty/fireworks {:mvn/version "0.10.4"}}})
  (require '[fireworks.core :refer [? !? ?> !?>]])
  )
