#!/usr/bin/env bb

;(ns checkout
(require '[babashka.process :as ps :refer [$ shell process sh]]
         '[clojure.string :as str]
         '[clojure.core.match :refer [match]]
         )
;)

(comment
  (require '[portal.api :as p])
  (add-tap #'p/submit)
  (def p (p/open {:launcher :intellij}))
  (tap> :hello)
  (load-file (str (System/getenv "HOME") "/Documents/dotfiles/common/scripts/.bin/clj/init.clj"))
  )

(defn- run-rofi [dir]
  (when-let [selected (as-> dir p
                 (sh "git" "-C" p "branch")
                 (:out p)
                 (rofi-menu! p {:prompt "git checkout", :width "25ch"})
                 (:out p)
                 (first p))]
    (str/trim selected)))

(let [dir (first *command-line-args*)]
  (if (and dir (fs/directory? dir))
    (if (->> (run-rofi dir)
              (sh "git" "-C" dir "checkout")
              (:exit)
              (zero?))
      (notify! "Switched branch")
      (notify-error! "Couldn't switch branch"))
    (notify-error! "Invalid directory path")))

(comment
  )
