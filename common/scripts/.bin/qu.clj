#!/usr/bin/env bb

(require '[babashka.process :as ps :refer [$ shell process sh]]
         '[clojure.string :as str]
         '[babashka.cli :as cli]
         '[clojure.core.match :refer [match]]
         '[cheshire.core :as json])

(declare subcommands create-task-menu create-group-menu menu-keys-tasks menu-keys-group menu)

(defn- define-status
  "Defines a keyword status based on the task status map."
  [stat]
  {:pre [(map? stat)] :post [(keyword? %)]}
  (match [stat]
         [{:Running _}] :Running
         [{:Queued _}] :Queued
         [{:Done {:result "Killed"}}] :Killed
         [{:Done {:result "Success"}}] :Success
         [{:Done _}] :Failed))

(defn- adjust-task
  "Normalize a task map for display and processing."
  [task] {:pre [(map? task)] :post [(map? %)]}
  {:id     (:id task)
   :group  (:group task)
   :status (define-status (:status task))
   :title  (or (not-empty (:label task)) (:command task))
   :cmd    (:original_command task)})

(def TASKS (delay (-> (ps-error-handler! true "pueue status --json")
                      (json/parse-string true)
                      :tasks
                      (->> (map last)
                           (map adjust-task)))))

(defn- tasks->ids [tasks]
  {:pre [(seq? tasks)] :post [(string? %)]}
  (->> tasks
       (map :id)
       (str/join " ")))

(defn- selected-items->tasks [tasks selected-menu-items]
  (->> selected-menu-items
       (map parse-long)
       (map #(nth tasks %))))

(defn- trim-col
  "Trim a column to a specified length, padding with spaces if necessary
 Parameters:
 - column: The string to trim
 - length: The desired length of the output string (default is 20)
 Returns:
 - A string of the specified length"
  ([column] {:post [(string? %)]}
   (trim-col column 15))
  ([column length] {:post [(string? %)]}
   (let [current-length (count column)]
     (if (>= current-length length)
       (str (subs column 0 length))
       (str column (apply str (repeat (- length current-length) " ")))))))

(defn- extract-url
  "Extracts the fires URL from the txt string. If no URL is found, returns an empty string."
  [txt] {:pre [(string? txt)]}
  (or (first (re-find #"(https?://[^\s]+)" txt)) ""))       ;; use re-seq for multiple urls

(defn- cmds->urls [cmds]
  {:pre [(seq? cmds)] :post [(string? %)]}
  (->> cmds
       (map :cmd)
       (map extract-url)
       (str/join " ")))

(defn- json->log [log]
  (let [task (:task log)
        {:keys [id group label command status]} task]
    {:id id :group group :label label :command command :output (:output log) :url (extract-url command) :status (define-status status)}))

(defn- format-log [log]
  {:pre [(map? log)] :post [(string? %)]}
  (let [fmt "== %d%nID: %3d\t Group: %s\t Status: %s%n Label:%s%nCommand:%n%s%nURL:%n%s%nOutput:%n%s%n"]
    (format fmt (:id log) (:id log) (:group log) (:status log) (:label log) (:command log) (:url log) (:output log))))

(defn- log [selected]
  {:pre [(or (string? selected) (seq? selected))]}
  (let [json (-> (ps-error-handler! true (format "pueue log --json --full --all")) ;; it can be listed by group or ids
                 (json/parse-string true))
        logs (map json->log (map last json))
        filtered-logs (if (string? selected)
                        (filter #(= (:status %) :Failed) logs)
                        (filter #(contains? (set (map :id selected)) (:id %)) logs))
        txt (str/join "\n" (map format-log filtered-logs))]
    (scratchpad! txt)))

(defn- copy
  "Copy the URL of the selected tasks into the clipboard."
  [selected] {:pre [(seq? selected)]}
  (sh {:in (cmds->urls selected)} "clipster -c"))
;(sh {:in (cmds->urls selected) } "xclip -selection clipboard" ); freeze with xclip

(defn- open
  "Open the URL of the selected tasks in the default browser."
  [selected] {:pre [(seq? selected)]}
  (ps-error-handler! true (format "%s %s" (System/getenv "BROWSER") (cmds->urls selected))))

(defn- make-playlist
  "Creates an mpv playlist for tasks in a specific group."
  [group]
  {:pre [(string? group)]}
  (ps-error-handler! true (format "mpv.lua --makeQueue --input %s" group)))

(defn- kill [selected]
  {:pre [(or (string? selected) (seq? selected))]}
  (if (sequential? selected)
    (ps-error-handler! true (format "pueue kill %s " (tasks->ids selected)))
    (ps-error-handler! true (format "pueue kill -g %s " selected))))

(defn- kill-any [_]
  (let [running-task (filter #(= (:status %) :Running) @TASKS)]
    (if (empty? running-task)
      (notify! "No running tasks.")
      (ps-error-handler! true "pueue kill --all"))))

(defn- restart
  "Restart failed or successful task(s)"
  [selected]
  {:pre [(or (string? selected) (seq? selected))]}
  (if (sequential? selected)
    (do
      (ps-error-handler! true (format "pueue restart -i %s " (tasks->ids selected)))
      (ps-error-handler! true (format "pueue start %s " (tasks->ids selected))))
    (do
      (ps-error-handler! true (format "pueue restart -i -g %s " selected))
      (ps-error-handler! true (format "pueue start -g %s " selected)))))

(defn- reset
  "Remove all jobs in a group, first kill them if necessary."
  [_]
  (ps-error-handler! true (format "pueue reset --force")))

(defn- delete
  "Remove tasks from the list. Running or paused tasks need to be killed first."
  [selected]
  {:pre [(seq? selected)]}
  (ps-error-handler! true (format "pueue remove %s " (tasks->ids selected))))

(defn- clean
  "Remove all finished (with failed and killed) tasks from the list"
  [group]
  {:pre [(string? group)]}
  (ps-error-handler! true (format "pueue clean -g %s" group)))

(defn- clean-successful
  "Remove all successful finished tasks from the list"
  [group]
  {:pre [(string? group)]}
  (ps-error-handler! true (format "pueue clean --successful-only -g %s" group)))

(defn- execute-action [action selected]
  {:pre [(or (string? selected) (seq? selected))]}
  (if action
    ((last action) selected)
    (restart selected)))

(defn- group-menu-item
  "Formats a group entry for display in the group menu."
  [group]
  (let [name (first group)
        freq (frequencies (map :status (second group)))
        status (map #(format "%s=%s" (first %) (second %)) freq)]
    (str (trim-col name) "\t" (str/join "; " status))))

(defn- list-tasks [tasks]
  {:pre [(seq? tasks)]}
  (let [{:keys [selected key]} (create-task-menu (sort-by :id > tasks))
        action (get menu-keys-tasks key)]
    (execute-action action selected)))

(defn- list-tasks-all [_]
  (list-tasks @TASKS))

(defn- list-tasks-group [group]
  {:pre [(string? group)]}
  (list-tasks (filter #(= (:group %) group) @TASKS)))

(defn- create-task-menu [tasks]
  (let [task-items (map #(format "%s\t%s: #%s%s" (:id %) (:status %) (trim-col (:group %)) (:title %)) tasks)
        {:keys [out key exit]}
        (rofi-menu! task-items {:prompt (str "All tasks: " (count tasks)), :multi true, :width "80%", :format \i, :keys menu-keys-tasks})]
    (if exit
      {:key key, :selected (selected-items->tasks tasks out)}
      (menu nil))))

(defn- create-group-menu [groups]
  (let [group-items (map group-menu-item groups)
        {:keys [out key exit]}
        (rofi-menu! group-items {:prompt (str "All tasks: " (count @TASKS)), :width "650px", :format \i, :keys menu-keys-group})]
    (if exit
      {:key key :selected (first (get groups (parse-long (first out))))}
      (System/exit 0))))

(defn- menu [_]
  (let [groups (into [] (into (sorted-map) (group-by :group @TASKS)))
        {:keys [selected key]} (create-group-menu groups)
        action (get menu-keys-group key)]
    (execute-action action selected)))

;; THOSE FUNCTIONS NEED TO TAKE 1 ARGUMENT
(def menu-keys-tasks
  [["Alt-k" "<b>kill</b>" kill]
   ["Alt-d" "<b>delete</b>-remove" delete]
   ["Alt-l" "<b>log</b>" log]
   ["Alt-o" "<b>open</b> url" open]
   ["Alt-c" "<b>copy</b> url" copy]
   ["Alt-r" "<b>restart</b>-restart <b>*default</b>" restart]
   ;; TODO maybe clean all successful tasks
   ;["Alt-m" "m3u" make-playlist]; mpv.lua support only groups
   ])
(def menu-keys-group
  [["Alt-k" "<b>kill</b> running" kill]
   ["Alt-d" "<b>clean</b> not running" clean]
   ["Alt-c" "<b>clean</b> successful" clean-successful]
   ["Alt-a" "<b>list all</b>" list-tasks-all]
   ["Alt-l" "<b>list</b>" list-tasks-group]
   ["Alt-L" "<b>log</b> failed" log]
   ["Alt-m" "<b>m3u</b>-make playlist" make-playlist]
   ["Alt-x" "<b>reset all</b>-remove all (force)" reset]    ;; maybe remove that action - it's not useful and can be dangerous
   ["Alt-r" "<b>restart</b> killed <b>*default</b>" restart]])

(def spec
  {:group {:desc         "Group name to operate on."
           :default      "default"
           :default-desc "Default group name: 'default'."
           :alias        :g}})

(defn help [_]
  (printf "Utility script for managing the pueue program. It's a tool that processes a queue of shell commands.
Using: qu.clj [action] [option] %n%s%s%n
Examples:
  qu.clj kill queueGroupName
  qu.clj kill-any
  qu.clj restart queueGroupName
  qu.clj list

Dependencies: pueue, rofi, notify-send, mpv.lua, zenity, clipster "
          (format-cmds! subcommands)
          (cli/format-opts {:spec spec})))

;; they overlap with normal pueue commands, some of them can be removed
(def subcommands
  [{:cmds ["menu"] :desc "Show rofi menu." :fn menu}
   {:cmds ["kill"] :desc "Stop any running job." :fn kill :spec spec}
   {:cmds ["kill-any"] :desc "Stop any running job." :fn kill-any}
   {:cmds ["restart"] :desc "Restart a killed job." :fn restart :spec spec}
   {:cmds ["clean"] :desc "Remove successful jobs from a group." :fn clean :spec spec}
   {:cmds ["list"] :desc "List all jobs." :fn list-tasks-all}
   {:cmds ["list-group"] :desc "List jobs from a group" :fn list-tasks-group :spec spec}
   {:cmds ["help"] :desc "Show help." :fn help}
   {:cmds [] :desc "Show help." :fn help}])

(when (= *file* (System/getProperty "babashka.file"))
  (cli/dispatch subcommands *command-line-args*))

(comment

  (load-file (str (System/getenv "HOME") "/Documents/dotfiles/common/scripts/.bin/clj/init.clj"))
  (deps/add-deps '{:deps {dev.weavejester/hashp {:mvn/version "0.3.0"}}})
  (require 'hashp.preload)
  (deps/add-deps '{:deps {io.github.paintparty/fireworks {:mvn/version "0.10.4"}}})
  (require '[fireworks.core :refer [? !? ?> !?>]])
  (require '[babashka.deps :as deps])
  (deps/add-deps '{:deps {djblue/portal {:mvn/version "0.58.1"}}})
  (require '[portal.api :as p])
  (add-tap #'p/submit)
  (def p (p/open {:launcher :intellij}))
  (tap> :hello)

  )

(comment
  (cli/dispatch subcommands ["help"])
  (cli/dispatch subcommands ["list"])

  (list-tasks "default")
  (list-tasks nil)
  (json/parse-string (ps-error-handler! true "pueue status --json") true)
  (kill-any)
  (menu nil)
  )
