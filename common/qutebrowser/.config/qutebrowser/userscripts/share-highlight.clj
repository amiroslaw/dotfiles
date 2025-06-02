#!/usr/bin/env bb

(require '[clojure.string :as str]
         '[babashka.process :as ps :refer [$ shell process sh]])

(def UTF-8 (java.nio.charset.StandardCharsets/UTF_8))

(defn- encode-text [text]
  {:pre [(sequential? text)] :post [(string? %)]}
  (-> (str/join " " text)
      (java.net.URLEncoder/encode UTF-8)
      (str/replace "-", "%2D")
      (str/replace "+" "%20")))

(defn- create-text-fragment [trimmed]
  (if (< (count trimmed) 11)
    (encode-text trimmed)
    (str (encode-text (take 4 trimmed)) "," (encode-text (take-last 4 trimmed)))))

(defn- build-url [url selection]
  {:pre [(url? url) (string? selection)] :post [(string? %)]}
  (let [words (str/split selection #" ")
        trimmed (rest (pop words))]
    (format "%s#:~:text=%s" url (create-text-fragment trimmed))))

(let [qute-url (System/getenv "QUTE_URL")
      selected-text (System/getenv "QUTE_SELECTED_TEXT") ;; or (ps-error-handler! true "clipster -p -o")
      url (build-url qute-url selected-text)]
  (notify! url)
  (sh {:in url} "clipster -c "))

(comment
  (def short "The three main uses of the en dash are:")
  (def long "The en dash is commonly used to indicate a closed range of values – a range with clearly defined and finite upper and lower boundaries – roughly signifying what might otherwise be communicated by the word")
  (build-url "https://en.wikipedia.org/wiki/Dash" long)

  (sh {:in
       (build-url "https://en.wikipedia.org/wiki/Dash"
                  ;"he three main uses of the en dash are:"
                  short
                  ;(ps-error-handler! true "clipster -p -o")
                  )
       } "clipster -c ")
  )
