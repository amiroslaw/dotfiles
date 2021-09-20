#!/bin/bash

ls $1 | entr asciidoctor -o $NOTE/preview.html -a source-highlighter=highlightjs -a hardbreaks $1
