#!/bin/sh
set -eu

ustate="$(fw_printenv -n ustate 2>/dev/null || echo 0)"

if [ "${ustate}" = "1" ]; then
    fw_setenv ustate 0
    fw_setenv bootcount 0
fi
