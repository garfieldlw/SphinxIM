#!/bin/bash

TARGET='SphinxIM'

login_user=`/usr/bin/stat -f%Su /dev/console`

/usr/bin/sudo -u "${login_user}" pkill -9 "${TARGET}" || true

/usr/bin/sudo -u "${login_user}" "/Library/Input Methods/${TARGET}.app/Contents/MacOS/${TARGET}" --install || true

echo "${Target}"
