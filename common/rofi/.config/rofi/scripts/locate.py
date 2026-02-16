#!/usr/bin/env bash
# xdg-open "$(locate ~/Documents ~/Downloads | rofi -threads 0 -width 100 -dmenu -i -p "locate:")"
xdg-open "$(locate ~/Documents ~/Downloads ~/Code | rofi -threads 0 -width 100 -dmenu -i -p "locate:")"
#exclude
# ~/Documents/.debris ~/Code/.debris ~/Code/SourceCode/Spring apps/glossary/node_modules
