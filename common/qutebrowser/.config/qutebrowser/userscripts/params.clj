#!/usr/bin/env bb

(require '[babashka.process :as ps :refer [$ shell process sh]]
         '[clojure.java.io :as io]
         '[clojure.string :as str])

(def UTF-8 (java.nio.charset.StandardCharsets/UTF_8))

(defn- get-params [query]
  (-> query
      (java.net.URLDecoder/decode UTF-8)
      (str/split #"&")
      (->> (map #(str/split % #"=")))))

(defn- build-dialog [params]
  (let [param-entries (map #(format "--field='%s' '%s'" (first %) (second %)) params)]
    (format "yad --text-align=center --text='Edit parameters' --form %s --field='Add param name' --field='Add param value'"
            (str/join " " param-entries))))

(defn- build-dialog [params]
  (let [param-entries (for [param params]
                        (format "--field='%s' '%s'" (first param) (second param)))
        entries (str (str/join " " param-entries) " --field='Add param name' --field='Add param value'")]
    (str "yad --text-align=center --text='Edit parameters' --form " entries)))

(defn- run-dialog [params]
  (if-let [out (-> params
                   build-dialog
                   sh
                   :out
                   (str/split #"\|")
                   butlast)]
    out
    (System/exit 0)))

(defn- join-key-with-value
  ([list] (join-key-with-value (first list) (second list)))
  ([key value] (str key "=" (java.net.URLEncoder/encode value UTF-8))))

(defn- combine-params [original-params changed-values]
  (let [zmap (zipmap (map first original-params) changed-values)
        params (str/join "&" (map #(join-key-with-value %) zmap))]
    (if-let [last-param (not-empty (last changed-values))]
      (str params "&" (join-key-with-value (nth changed-values (count original-params)) last-param))
      params)))

(defn- change-params [url]
  (let [[path query] (str/split url #"\?")
        param-list (get-params query)
        changed-params (run-dialog param-list)
        url-query (combine-params param-list changed-params)]
    (str path "?" url-query)))


(let [qute-fifo (System/getenv "QUTE_FIFO")
      new-url (change-params (System/getenv "QUTE_URL"))]
  (with-open [writer (io/writer qute-fifo :append true)]
    (.write writer (str "open " new-url))))

