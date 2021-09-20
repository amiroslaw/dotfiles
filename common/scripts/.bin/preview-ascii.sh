#!/bin/bash

# killall entr

ls "$NOTE/$1" | entr -n asciidoctor -o "$NOTE/preview.html" -a source-highlighter=highlightjs -a hardbreaks "$NOTE/$1" &
