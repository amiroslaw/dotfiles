#!/usr/bin/env bb
;; Script for navigating through headers in an HTML.
(require '[clojure.string :as str]
         '[babashka.pods :as pods])
(pods/load-pod 'com.github.jackdbd/jsoup "0.4.0")
(require '[pod.jackdbd.jsoup :as jsoup])

(def UTF-8 (java.nio.charset.StandardCharsets/UTF_8))
(def html-path (System/getenv "QUTE_HTML"))
(def headers (jsoup/select (slurp html-path) "h1, h2, h3, h4, h5, h6"))

(defn- create-header-prefix [tag text]
  (-> (subs tag 1)
      (parse-long)
      (repeat "#")
      (str/join)
      (str " " text)))

(defn- remove-prefix [text]
  (str/replace text #"^#+\s*" ""))

(defn- select-header [headers]
  (if-let [out (-> (map #(create-header-prefix (:tag-name %) (:text %)) headers)
                   (rofi-menu! {:prompt "Jump to header"})
                   :out
                   first)]
    out
    (System/exit 0)))

(defn- execute-qb-command [command]
  (let [qute-fifo (System/getenv "QUTE_FIFO")]
    (spit qute-fifo command :append true)))

(defn- build-url
  "Builds a URL with a Scroll to Text Fragment"
  [text]
  (if-let [qute-url (System/getenv "QUTE_URL")]
    (format "%s#:~:text=%s" (first (str/split qute-url #"#")) text)
    (execute-qb-command "message-error 'QUTE_URL not set'")))

(let [selected-text (remove-prefix (select-header headers))
      selected-header (first (filter #(= (:text %) selected-text) headers))]
  (if-let [anchor (not-empty (:id selected-header))]
    (execute-qb-command (str "scroll-to-anchor " anchor))
    (execute-qb-command (str "open " (build-url selected-text)))))
