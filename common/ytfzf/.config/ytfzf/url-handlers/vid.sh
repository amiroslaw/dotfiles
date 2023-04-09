#!/usr/bin/env bash

echo "$1" >> /tmp/qb_mpv.m3u
mpv --profile=stream $1 
