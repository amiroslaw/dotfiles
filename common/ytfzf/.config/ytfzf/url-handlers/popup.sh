#!/usr/bin/env bash

echo "$1" >> /tmp/qb_mpv.m3u
mpv --x11-name=videopopup --profile=stream-popup $1 
