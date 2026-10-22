#!/bin/sh
pkill -x xray || true
sleep 0.3
setsid xray run -config /usr/local/etc/xray/config.json >>/proc/1/fd/1 2>&1 &
