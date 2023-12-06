#!/usr/bin/env bash
# run by ytfzf -u vid.sh
echo "$1" >> /tmp/qb_mpv.m3u
mpv --profile=stream $1 
