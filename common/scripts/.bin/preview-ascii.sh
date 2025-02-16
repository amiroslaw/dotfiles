#!/bin/bash

killall entr

ls "$1" | entr -n asciidoctor -o "$NOTE/preview.html" -a source-highlighter=highlight.js -a source-language=java -a highlightjs-languages=java,js,lua,sql,css,html,typescript,kotlin -a hardbreaks -a experimental=true -a toc=left -a toclevels=5 -a icons=font@ -a allow-uri-read=true -a backend=html5 -a sectanchors=true -a sectlinks=true -a table-stripes=even  -a imagesoutdir=./img -a imagesdir=./img -a plantuml-format=svg "$1" &

# bug with asciidoctor-diagram
# ls "$1" | entr -n asciidoctor -o "$NOTE/preview.html" -a source-highlighter=highlight.js -a source-language=java -a highlightjs-languages=java,js,lua,sql,css,html,typescript,kotlin -a hardbreaks -a experimental=true -a toc=left -a toclevels=5 -a icons=font@ -a allow-uri-read=true -a backend=html5 -a sectanchors=true -a sectlinks=true -a table-stripes=even -r asciidoctor-diagram -a imagesoutdir=./img -a imagesdir=./img -a plantuml-format=svg "$1" &

"$BROWSER" "$NOTE/preview.html" &
# --trace debug

# ls "$1" | entr -n asciidoctor -o "$NOTE/preview.html" -a source-highlighter=highlight.js -a source-language=java -a highlightjs-languages=java,js,lua,sql,css,html,typescript,kotlin -a hardbreaks -a experimental=true -a toc=left -a toclevels=5 -a icons=font@ -a allow-uri-read=true "$1" &

# outdir
# outfile
# iconsdir

# https://docs.asciidoctor.org/asciidoc/latest/attributes/document-attributes-ref/#source-highlighting-and-formatting-attributes
#
# asciidocFX:
# allow-uri-read=true
# showtitle=true
# idprefix=true is def
# apply-data-line=true ??
# apply-image-cacher=true
# imagesdir=images
#
#
# source-highlighter=highlight.js
# * coderay
# * highlight.js
# * pygments
# * rouge


# :doctype: article
# :encoding: utf-8
# :lang: en
# :toc: left
# :numbered:
