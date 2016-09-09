#!/usr/bin/env bash
ps -eo pid,command | grep "nginx" | grep -v grep | awk '{print $1}' | xargs kill -9
ps -eo pid,command | grep "passenger" | grep -v grep | awk '{print $1}' | xargs kill -9
ps -eo pid,command | grep "god" | grep -v grep | awk '{print $1}' | xargs kill -9
rm /tmp/god.*.sock || true
god restart || true