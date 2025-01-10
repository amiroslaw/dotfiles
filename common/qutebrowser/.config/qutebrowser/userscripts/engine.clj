#!/usr/bin/env bb
; author: https://github.com/amiroslaw
; Script for qutebrowser: it can change the search engine or search text from selected text or from the URL query.
; Examples:
;  engine.clj --change → It will try to extract the parameter `q`, the first argument, and the last segment from the path if won't find previous. After that it will open a dialog to change the search engine.
;  engine.clj --selection b
;; TODO
;; it works but not without qutebrowser
;; edit search text using rofi keybinding?? maybe not - it's better to edit input in nvim from an input in qb

(require '[babashka.process :as ps :refer [$ shell process sh]]
         '[clojure.string :as str]
         '[babashka.cli :as cli])

(def UTF-8 (java.nio.charset.StandardCharsets/UTF_8))
(def config-dir (System/getenv "QUTE_CONFIG_DIR"))
;(def config-dir "/home/miro/.config/qutebrowser")

(defn- execute-qb-command [command]
  (let [qute-fifo (System/getenv "QUTE_FIFO")]
    (spit qute-fifo command :append true)))

(defn- get-search-engines []
  (let [config-file (str config-dir "/config.py")]
    (with-open [reader (io/reader config-file)]
      (doall (filter #(re-matches #".*:.*http.*=\{\}.*" %) (line-seq reader))))))

(defn- extract-domain-name [txt]
  (if (str/starts-with? txt "http")
    (let [pattern #"(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,6}"]
      (str/replace (first (re-seq pattern txt)) "www." ""))
    txt))

(defn- extract-text-between-quotes [text]
  (for [[_ match] (re-seq #"'(.*?)'" text)]
    (extract-domain-name match)))

(defn- build-menu [engines]
  (-> engines
      (->> (map #(str/join ": " (extract-text-between-quotes %))))
      (rofi-menu! {:prompt "Select search engine", :msg "Tip: use ctrl-enter to pass text from input"})
      :out
      first))

(defn- choose-engine []
  (some-> (get-search-engines)
          build-menu
          (str/split #":")
          first))

(defn- get-param-value [param]
  (some-> (second (str/split param #"="))
          (java.net.URLDecoder/decode UTF-8)))

(defn- get-last-path-segment [url]
  (-> url
      (str/split #"\?")
      first
      (str/split #"/")
      last
      (str/replace "_" " ")
      (str/replace "-" " ")))

(defn- get-search-text [link]
  (let [url (str/split link #"\?")
        params (some-> (second url) (str/split #"&"))
        q-param (some #(when (str/starts-with? % "q=") %) params)]
    (cond
      q-param (get-param-value q-param)
      params (get-param-value (first params))
      :else (get-last-path-segment link))))

(defn- change-search-engine []
  (->> (System/getenv "QUTE_URL")
       get-search-text
       (format "open -t %s %s" (choose-engine))
       execute-qb-command))

(defn- search-selected-text [engine]
  (when-let [selected-text (not-empty (System/getenv "QUTE_SELECTED_TEXT"))]
    (cond
      (string? engine) (execute-qb-command (format "open -t %s %s" engine selected-text))
      (boolean? engine) (execute-qb-command (format "open -t %s %s" (choose-engine) selected-text)))))

(def spec
  {:spec
   {:change    {:alias :c
                :desc  "Change search engine, provide to it a query from the URL"}
    :selection {:alias :s
                :desc  "Search a selected text with chosen search engine"}}})

(defn- menu [opts]
  (cond
    (opts :selection) (search-selected-text (opts :selection))
    (opts :change) (change-search-engine)))

(menu (cli/parse-opts *command-line-args* spec))

(comment
  (menu (cli/parse-opts ["-s"] spec))
  (def url "https://search.brave.com/search?q=java+split+params+url&source=web")
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
  (tap> :hello)

  (deps/add-deps '{:deps {io.github.paintparty/fireworks {:mvn/version "0.10.4"}}})
  (require '[fireworks.core :refer [? !? ?> !?>]])
  (load-file (str (System/getenv "HOME") "/Documents/dotfiles/common/scripts/.bin/clj/init.clj"))
  )
