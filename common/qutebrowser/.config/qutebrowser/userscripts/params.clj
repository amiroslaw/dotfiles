#!/usr/bin/env bb

(require '[babashka.process :as ps :refer [$ shell process sh]]
         '[clojure.java.io :as io]
         '[clojure.string :as str])

(def UTF-8 (java.nio.charset.StandardCharsets/UTF_8))

(defn- build-dialog [params]
  (let [param-entries (map #(format "--field='%s' '%s'" (first %) (second %)) params)]
    (format "yad --text-align=center --text='Edit parameters' --form %s --field='Add param name' --field='Add param value'"
            (str/join " " param-entries))))

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
  (let [path (first (str/split url #"\?"))
        param-list (vec (url-params url))
        changed-params (run-dialog param-list)
        url-query (combine-params param-list changed-params)]
    (str path "?" url-query)))

(let [qute-fifo (System/getenv "QUTE_FIFO")
      new-url (change-params (System/getenv "QUTE_URL"))]
  (spit qute-fifo (str "open " new-url) :append true))

(comment
  (change-params (first *command-line-args*))
  (def java "https://allegro.pl/kategoria/informatyka-internet-programowanie-90328?string=java&rok-wydania-od=2010&tematyka=Java&offerTypeBuyNow=1&price_to=50")
  (def ks "https://allegro.pl/kategoria/ksiazki-7?stan=nowe&jezyk-publikacji=polski&string=nowy%20%C5%9Bwiat")
  (def ks "https://allegro.pl/kategoria/ksiazki-7?stan=nowe&jezyk-publikacji=polski")
  (def par "stan=nowe&jezyk-publikacji=polski")
  (flatten (vec (url-params ks)))
  (run-dialog (vec (url-params ks)))
  (println (change-params ks))
  (sh "zenity --forms --title='Add reminder' --add-entry=\"When\" --add-entry=\"Message\"  --add-password=\"Confirm Password\" --add-calendar=\"Expires\" ")
  )
;(defn- build-dialog [params]
;  (let [param-entries (for [param params]
;                        (format "--field='%s' '%s'" (first param) (second param)))
;        entries (str (str/join " " param-entries) " --field='Add param name' --field='Add param value'")]
;    (str "yad --text-align=center --text='Edit parameters' --form " entries)))

