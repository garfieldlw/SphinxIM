#!/bin/bash

TARGET='SphinxIM'

login_user=`/usr/bin/stat -f%Su /dev/console`

/usr/bin/sudo -u "${login_user}" "/Library/Input Methods/${TARGET}.app/Contents/MacOS/${TARGET}" --stop || true

/usr/bin/sudo -u "${login_user}" pkill -9 "${TARGET}" || true

echo "${Target}"
