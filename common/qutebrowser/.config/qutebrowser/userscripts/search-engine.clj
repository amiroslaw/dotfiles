#!/usr/bin/env bb
;; Script for changing search engine in qutebrowser. It will extract the parameter `q`, first argument, last segment from the path and open a dialog to change the search engine.
(require '[clojure.string :as str])

(def UTF-8 (java.nio.charset.StandardCharsets/UTF_8))

(defn- execute-qb-command [command]
  (let [qute-fifo (System/getenv "QUTE_FIFO")]
    (with-open [writer (io/writer qute-fifo :append true)]
      (.write writer command))))

(defn- get-param-value [param]
  (some-> (second (str/split param #"="))
          (java.net.URLDecoder/decode UTF-8)))

(defn- get-last-path-segment [url]
  (-> url
      (str/split #"\?")
      first
      (str/split #"/")
      last
      (str/replace "_|-" " ")))

(defn- get-search-text [link]
  (let [url (str/split link #"\?")
        params (some-> (second url) (str/split #"&"))
        q-param (some #(when (str/starts-with? % "q=") %) params)]
    (cond
      q-param (get-param-value q-param)
      params (get-param-value (first params))
      :else (get-last-path-segment link))))

(let [search (get-search-text (System/getenv "QUTE_URL"))
      engine (rofi-input! {:prompt "Engine  ", :width "20 ch"})]
  (execute-qb-command (format "open -t %s %s" engine search)))

(comment
  (def url "https://search.brave.com/search?q=java+split+params+url&source=web")
  (def url "https://en.wikipedia.org/wiki/Clojure_script")
  (def url "https://en.wikipedia.org/wiki/Clojure-script")
  (def url "https://www.youtube.com/results?search_query=any+param&source=web")
  (get-search-text url)
  )

(comment
  (require '[babashka.deps :as deps])
  (deps/add-deps '{:deps {djblue/portal {:mvn/version "0.58.1"}}})
  (require '[portal.api :as p])
  (add-tap #'p/submit)
  (def p (p/open {:launcher :intellij}))

  (deps/add-deps '{:deps {io.github.paintparty/fireworks {:mvn/version "0.10.4"}}})
  (require '[fireworks.core :refer [? !? ?> !?>]])
  (tap> :hello)
  (load-file (str (System/getenv "HOME") "/Documents/dotfiles/common/scripts/.bin/clj/init.clj"))
  )
