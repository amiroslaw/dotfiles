#!/usr/bin/env bb
;; TODO
;; add more resources - files ; pipe input
;; more advanced templates, json/edn file with model, temperature, language, placeholder.
; escape chars from text? idk if I need for the client
(require '[babashka.process :as ps :refer [$ shell process sh]]
         '[clojure.string :as str]
         '[babashka.cli :as cli]
         '[babashka.http-client :as http]
         '[clojure.java.io :as io]
         '[clojure.core.match :refer [match]]
         '[cheshire.core :as json])

(declare subcommands)

(def analyze-text-prompt ". Answer to that question based to following text:\n\n")
(def templates {:summary              "Summarize following text:\n\n",
                :summary-short        "Summarize following text, be concise:\n\n"
                :summary-adoc         "Summarize (use asciidoc format with lists and bold text if needed) following text:\n\n",
                :grammar              "Modify the following text to improve only grammar and spelling. Don't note about 'modified text'. Don't wrap the answer with quotation marks.:\n\n"
                :grammar-explain      "Modify the following text to improve only grammar and spelling. Don't note about 'modified text'. Don't wrap the answer with quotation marks. Explain nontrivial mistakes.:\n\n"
                :translate-to-english "Translate the following text to English:\n\n",
                :translate-to-polish  "Translate the following text to Polish:\n\n",})
(def default-model (if-let [env (System/getenv "AI_MODEL")]
                     env
                     "llama3:latest"))
(def api-host (if-let [ollama-env (System/getenv "OLLAMA_API_HOST")]
                ollama-env
                "http://localhost:11434"))
(def term-run (str (System/getenv "TERM_LT") (System/getenv "TERM_LT_RUN")))
(def response-dir "/tmp/clj/")
(def url-pattern "https?://[^/]+")

(defn url? [url-str]
  (try (io/as-url url-str)
       true
       (catch Exception _
         false)))

(defn- select-template []
  (if-let [template
           (-> (map name (keys templates))
               (rofi-menu! {:prompt "Select template", :width "30ch"})
               :out
               first
               keyword
               templates)]
    template
    (System/exit 0)))

(defn- prompt-input []
  (let [input (rofi-input! {:prompt "ask  ", :width "70 %"})]
    (if (str/blank? input)
      (System/exit 0)
      input)))

(defn- fetch-models []
  (as-> (str api-host "/api/tags") p
        (http/get p {:throw false})
        (:body p)
        (json/parse-string p true)
        (:models p)
        (map :name p)))

(defn- rofi-model-list []
  (-> (fetch-models)
      (rofi-menu! {:prompt "Select model"})
      :out
      first))

(defn- request-ollama [prompt model-name]
  (as-> (str api-host "/api/generate") p
        (http/post p {:body  (json/generate-string {:model model-name, :prompt prompt, :stream false})
                      :throw false})
        (:body p)
        (json/parse-string p true)
        (:response p)))

(defn- query-ai [prompt opts]
  (let [user (:model opts) list (:list opts)]
    (match [user list]
           [(m :guard some?) false] (request-ollama prompt m)
           [nil true] (request-ollama prompt (rofi-model-list))
           :else (request-ollama prompt default-model))))

(defn- fetch-page-html [url]
  (let [{:keys [exit out]} (sh "rdrview" "-H" "-A" "Mozilla" url "-T" "title")]
    (if (zero? exit)
      out
      (notify-error! (str "Fetching html from page " url) true))))

(defn- html->txt [url]
  (let [{:keys [exit out]} (sh {:in (fetch-page-html url)} "pandoc" "--from" "html" "--to" "plain" "--output" "-")]
    (if (zero? exit)
      out
      (notify-error! (str "Converting html to text " url) true))))

(defn- get-text [opts]
  (cond
    (:url opts) (html->txt (:url opts))
    (:primary opts) (:out (sh "clipster --output -m '' --primary"))
    (:input opts) (:input opts)
    :else (:out (sh "clipster --output -m '' --clipboard"))))

(defn- display-ai-response [response opts]
  (create-dir! response-dir)
  (let [file (.toString (fs/create-temp-file {:dir response-dir :prefix "chat-" :suffix ".adoc"}))]
    (spit file response)
    (case (:output opts)
      :scratchpad (scratchpad! file)
      :dialog (dialog! response)
      (println response))))

(defn- query->display [prompt opts]
  (-> prompt
      (query-ai opts)
      (display-ai-response opts)))

(defn- ask
  "Query AI with provided input."
  [{:keys [dispatch opts]}]
  (if (some #{"ask"} dispatch)
    (query->display (prompt-input) opts)
    (query->display (str (prompt-input) analyze-text-prompt (get-text opts)) opts)))

(defn- template
  "Query AI where prompt is based on a template."
  [{opts :opts}]
  (let [{:keys [actions template]} opts]
    (match [actions template]
           [true _] (query->display (str (select-template) (get-text opts)) opts)
           [nil :summary] (query->display (str (:summary templates) (get-text opts)) opts)
           [nil t] (query->display (str (t templates) (get-text opts)) opts))))

(def spec
  {:output {:desc     "Show AI answer in a text editor or a dialog [scratchpad | dialog]. Generated text is always saved in `tmp` folder"
            :coerce   :keyword
            :validate {:pred   #(contains? #{:scratchpad :dialog} %)
                       :ex-msg (fn [m] (str "Use one of those [scratchpad | dialog]. Provided not valid value for the :output: " (:value m)))}
            :alias    :o}
   :list   {:desc   "Choose an available model."
            :coerce :boolean
            :alias  :l}
   :model  {:desc  "Provide model name that you want to use."
            :alias :m}})

(def spec-source
  {:clip    {:desc   "Analyse text from clipboard - default."
             :coerce :boolean
             :alias  :c}
   :primary {:desc   "Analyse text from primary clipboard."
             :coerce :boolean
             :alias  :p}
   :input   {:desc  "Analyse text from terminal argument."
             :alias :i}
   :url     {:desc     "Analyse text from a page."
             :validate {:pred url? :ex-msg (fn [m] (str "Not a url: " (:value m)))}
             :alias    :u}})

(def spec-template
  {:template     {:desc         "Analyse text from primary clipboard."
                  :coerce       :keyword
                  :default      :summary
                  :default-desc "Summary text"
                  :alias        :t}
   :actions-list {:desc   "Show available actions in a rofi menu."
                  :coerce :boolean
                  :alias  :a}
   ;; maybe add a config file for templates when I need more customisation like model, temperature, language in a json or edn file
   ;:template-file {:desc     "Analyse text from clipboard - default."
   ;                :default  (str (System/getenv "XDG_CONFIG_HOME") "/chat/template.properties")
   ;:coerce   :symbol
   ;:validate #((fs/regular-file? %))
   ;:alias    :f}
   })

(defn- print-help [_]
  (printf "Chat AI. An helper for interact with ollama. %n%s%s%n
  Options for `summary` and `text` commands:%n%s%n
     Examples:
     chat.clj ask -l
     chat.clj text -i 'tell me a joke'
     chat.clj text -p -o display
     chat.clj action -o scratchpad -t 'summary-adoc' -u='https://en.wikipedia.org/wiki/Polish_hussars'
  %nDefault values can be override via system environment. The set values:
  AI_MODEL = %s
  OLLAMA_API_HOST = %s
  TERM_LT and TERM_LT_RUN = %s
  %nDependencies:
   - ollama, clipster, rofi
   - optional for `url` flag: rdrview, pandoc
   - optional for `scratchpad`: nvim "
          (format-cmds! subcommands)
          (cli/format-opts {:spec spec})
          (cli/format-opts {:spec spec-source})
          default-model api-host term-run))

(def subcommands
  [{:cmds ["ask"] :desc "Ask AI." :fn ask :spec spec}
   {:cmds ["text"] :desc "Ask about provided text." :fn ask :spec (merge spec spec-source)}
   {:cmds ["action"] :desc "Take an action from a template. If not provided text will be summarised."
    :fn   template :spec (merge spec spec-source spec-template)}
   {:cmds ["help"] :desc "Show help." :fn print-help}])

;; Testing
(comment
  (cli/dispatch subcommands ["help"])
  (cli/dispatch subcommands ["ask"])
  (cli/dispatch subcommands ["ask" "-o" "dialog"])
  (cli/dispatch subcommands ["ask" "-o" "scratchpad"])
  (cli/dispatch subcommands ["ask" "-l"])
  (cli/dispatch subcommands ["text"])
  (cli/dispatch subcommands ["text" "-i" "tell me a joke"])
  (cli/dispatch subcommands ["text" "-o" "dialog"])
  (def wiki "https://pl.wikipedia.org/wiki/Prawo_natury")
  (cli/dispatch subcommands ["text" "-u" wiki "-l"])
  (cli/dispatch subcommands ["text" "-u" "yt" "-l"])        ; wrong url
  (cli/dispatch subcommands ["action"])
  (cli/dispatch subcommands ["action" "-a"])
  (cli/dispatch subcommands ["action" "-t" "translate-to-english"])
  (cli/dispatch subcommands ["action" "-u" "yt" "args" "llama"]) ; fail
  (cli/dispatch subcommands ["action" "-u" wiki])
  (cli/dispatch subcommands ["action" "-u" "https://sklep.galakta.pl/gry-planszowe/1438-filary-ziemi.html"])

  (html->txt "https://sklep.galakta.pl/gry-planszowe/1438-filary-ziemi.html")
  (def invalid-url "https://slep.galakta.pl/gry-planszowe/1438-filary-ziemi.html")
  (fetch-page-html invalid-url)
  (get-properties! "/home/miro/t.pro")
  (str (url? "https://search.brave.com/search"))
  (str (url? "www.brave.com/search"))
  (rofi-menu! (fetch-models) {:prompt "Select model"})
  )

(comment
  (require '[babashka.deps :as deps])
  (deps/add-deps '{:deps {djblue/portal {:mvn/version "0.58.1"}}})
  (require '[portal.api :as p])
  (add-tap #'p/submit)
  (def p (p/open {:launcher :intellij}))
  (tap> :hello)
  (load-file (str (System/getenv "HOME") "/Documents/dotfiles/common/scripts/.bin/clj/init.clj"))
  )
