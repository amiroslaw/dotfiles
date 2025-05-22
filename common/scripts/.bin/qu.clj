#!/usr/bin/env bb
;; TODO
;; instead ps-error-handler! use catch output, sometimes you can't do an action but it doesn't generate an error
;; change false to true in ps-error-handler! in kill, delete, restart
;; add documentation and condition checks
;; maybe rename  delete or other actions to remove
;; actions in subcommands are too much, they overlap with normal pueue commands

(require '[babashka.process :as ps :refer [$ shell process sh]]
         '[clojure.string :as str]
         '[babashka.cli :as cli]
         '[clojure.core.match :refer [match]]
         '[cheshire.core :as json])

(declare subcommands kill restart delete reset clean clean-successful make-playlist list-tasks-group list-tasks-all adjust-task menu)

(def TASKS (-> (ps-error-handler! true "pueue status --json")
               (json/parse-string true)
               :tasks
               (->> (map last)
                    (map adjust-task))))
;; THOSE FUNCTIONS NEED TO TAKE 1 ARGUMENT
(def menu-keys-tasks
  [["Alt-k" "<b>kill</b>" kill]
   ["Alt-d" "<b>delete</b>-remove" delete]
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
   ["Alt-m" "<b>m3u</b>-make playlist" make-playlist]
   ["Alt-x" "<b>reset all</b>-remove all (force)" reset]    ;; maybe remove that action - it's not useful and can be dangerous
   ["Alt-r" "<b>restart</b> killed <b>*default</b>" restart]])

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

(defn- adjust-task [task]
  (let [id (:id task)
        group (:group task)
        command (:original_command task)
        title (if-let [label (not-empty (:label task))] label (:command task))
        status (match [(:status task)]
                      [{:Running _}] :Running
                      [{:Queued _}] :Queued
                      [{:Done {:result "Killed"}}] :Killed
                      [{:Done {:result "Success"}}] :Success
                      [{:Done _}] :Failed)]
    {:id id, :group group, :status status, :title title :cmd command}))

(defn- make-playlist [group]
  {:pre [(string? group)]}
  (println "playlist")
  (ps-error-handler! false (format "mpv.lua --makeQueue --input " group)))

(defn- kill [selected]
  {:pre [(or (string? selected) (seq? selected))]}
  (if (sequential? selected)
    (ps-error-handler! false (format "pueue kill %s " (tasks->ids selected)))
    (ps-error-handler! false (format "pueue kill -g %s " selected))))

(defn- kill-any []
  (let [running-task (filter #(= (:status %) :Running) TASKS)]
    (if (empty? running-task)
      (notify! "No running tasks.")
      (ps-error-handler! false "pueue kill --all"))))

(defn- restart [selected]
  {:pre [(or (string? selected) (seq? selected))]}
  (if (sequential? selected)
    (ps-error-handler! false (format "pueue restart -i %s " (tasks->ids selected)))
    (ps-error-handler! false (format "pueue restart -i -g %s " selected))))
;(ps-error-handler! false (format "pueue start -g %s " selected))))

(defn- reset [_]
  (ps-error-handler! false (format "pueue reset --force")))

(defn- delete [selected]
  {:pre [(seq? selected)]}
  (ps-error-handler! false (format "pueue remove %s " (tasks->ids selected))))

(defn- clean [group]
  {:pre [(string? group)]}
  (ps-error-handler! false (format "pueue clean -g %s" group)))

(defn- clean-successful [group]
  {:pre [(string? group)]}
  (ps-error-handler! false (format "pueue clean --successful-only -g %s" group)))

(defn- group-menu-item [group]
  (let [name (first group)
        freq (frequencies (map :status (second group)))
        status (map #(format "%s=%s" (first %) (second %)) freq)]
    (str (trim-col name) "\t" (str/join "; " status))))

(defn- execute-action [action selected]
  {:pre [(or (string? selected) (seq? selected))]}
  (if action
    ((last action) selected)
    (restart selected)))

(defn- create-group-menu [groups]
  (let [group-items (map group-menu-item groups)
        {:keys [out key exit]}
        (rofi-menu! group-items {:prompt (str "All tasks: " (count TASKS)), :width "40%", :format \i, :keys menu-keys-group})]
    (if exit
      {:key key :selected (first (get groups (parse-long (first out))))}
      (println "Exit")
      ;(System/exit 0) TODO
      )))

(defn- create-task-menu [tasks]
  (let [task-items (map #(format "%s\t%s: #%s%s" (:id %) (:status %) (trim-col (:group %)) (:title %)) tasks)
        {:keys [out key exit]}
        (rofi-menu! task-items {:prompt (str "All tasks: " (count tasks)), :multi true, :width "80%", :format \i, :keys menu-keys-tasks})]
    (if exit
      {:key key, :selected (selected-items->tasks tasks out)}
      (menu nil))))

(defn- list-tasks [tasks]
  {:pre [(seq? tasks)]}
  (let [{:keys [selected key]} (create-task-menu (sort-by :id tasks))
        action (get menu-keys-tasks key)]
    (execute-action action selected)))

(defn- list-tasks-all [_]
  (list-tasks TASKS))

(defn- list-tasks-group [group]
  {:pre [(string? group)]}
  (list-tasks (filter #(= (:group %) group) TASKS)))

(defn- menu [_]
  (let [groups (into [] (into (sorted-map) (group-by :group TASKS)))
        {:keys [selected key]} (create-group-menu groups)
        action (get menu-keys-group key)]
    (execute-action action selected)))

(def spec
  {:group {:desc         "Group name to operate on."
           :default      "default"
           :default-desc "Default group name: 'default'."
           :alias        :g}})

(defn help [_]
  (printf " Utility script for managing the pueue program. It's a tool that processes a queue of shell commands.
Using: qu.clj [action] [group] [option] %n%s%s%n
Examples:
  qu.clj kill queueGroupName
  qu.clj kill-any
  qu.clj restart queueGroupName

Dependencies: pueue, rofi, notify-send, zenity "
          (format-cmds! subcommands)
          (cli/format-opts {:spec spec})))

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

  (require '[babashka.deps :as deps])
  (deps/add-deps '{:deps {djblue/portal {:mvn/version "0.58.1"}}})
  (require '[portal.api :as p])
  (add-tap #'p/submit)
  (def p (p/open {:launcher :intellij}))
  (tap> :hello)
  (load-file (str (System/getenv "HOME") "/Documents/dotfiles/common/scripts/.bin/clj/init.clj"))
  (deps/add-deps '{:deps {dev.weavejester/hashp {:mvn/version "0.3.0"}}})
  (require 'hashp.preload)
  (deps/add-deps '{:deps {io.github.paintparty/fireworks {:mvn/version "0.10.4"}}})
  (require '[fireworks.core :refer [? !? ?> !?>]])

  )

(comment
  (cli/dispatch subcommands ["help"])
  (cli/dispatch subcommands ["list"])

  (list-tasks "default")
  (list-tasks nil)
  (json/parse-string (ps-error-handler! false "pueue status --json") true)
  (menu nil)
  (kill-any)
  (menu nil)
  )
