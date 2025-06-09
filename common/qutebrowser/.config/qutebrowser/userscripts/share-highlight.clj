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

(defn- create-text-fragment [txt]
  (let [words (str/split txt #"\s+")]
    (if (< (count words) 11)
      (encode-text words)
      (str (encode-text (take 4 words)) "," (encode-text (take-last 4 words))))))

(defn extract-match [text selection]
  (let [words (str/split text #"\s+")
        sel-words (str/split selection #"\s+")]
    (->> (partition (count sel-words) 1 words)              ;; Sliding window of selection size
         (map #(str/join " " %))
         (filter #(every? (fn [sel-word] (str/includes? % sel-word)) sel-words))
         first)))

(defn- build-url [url selection page]
  {:pre [(url? url) (string? selection) (string? page)] :post [(string? %)]}
  (let [match (extract-match page selection)]
    (format "%s#:~:text=%s" url (create-text-fragment match))))

(let [qute-url (System/getenv "QUTE_URL")
      page (slurp (System/getenv "QUTE_TEXT"))
      selected-text (System/getenv "QUTE_SELECTED_TEXT")    ;; or (ps-error-handler! true "clipster -p -o")
      url (build-url qute-url selected-text page)]
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

  (def text "Lisp is a functional programming language. Clojure is a functional programming language.")
  (def selection "sp is a functional prog")

  )
