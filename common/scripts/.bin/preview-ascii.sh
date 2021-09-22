#!/bin/bash

# killall entr

ls "$1" | entr -n asciidoctor -o "$NOTE/preview.html" -a source-highlighter=highlightjs -a source-language=java -a highlightjs-languages=java,js,lua,sql,css,html,typescript,kotlin -a hardbreaks -a experimental -a toc=left -a toclevels=5 -a icons=font "$1" &

