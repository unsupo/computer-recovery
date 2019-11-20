#!/usr/bin/env bash

[[ -z $1 || ! -d $1 ]] && { echo 'Launchd script directory must be passed as first argument'; exit 1; }

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

for i in $(find $1 -type f -name '*.plist' -print); do
    p=${DIR}/${i}
    chmod a+x ${p}
    launchctl load ${p}
    ln -sf ${p} ~/Library/LaunchAgents/ 2>/dev/null
    exit_status=$(launchctl list $(basename ${i}) | grep LastExitStatus | grep -Eo '[0-9]+')
    if [[ ${exit_status} != "0" ]]; then
        echo "$p failed with exit code: $exit_status, unloading"
        launchctl status $(basename ${i})
        launchctl unload ${p}
    fi
done