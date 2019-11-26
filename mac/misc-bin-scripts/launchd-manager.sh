#!/usr/bin/env bash

[[ -n $1 && -d $1 ]] || { echo "Launchd script directory must be passed as first argument and exist: $1"; exit 1; }

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

for i in $(find $1 -type f -name '*.plist' -print); do
    p=${i}
    chmod a+x ${p}
    ln -sf ${p} ~/Library/LaunchAgents/ 2>/dev/null
    launchctl load ${p} 2>/dev/null
    n=$(basename ${p})
    n=${n%.*}
    exit_status=$(launchctl list ${n} | grep LastExitStatus | grep -Eo '[0-9]+')
    if [[ ${exit_status} != "0" ]]; then
        echo "$p failed with exit code: $exit_status, unloading"
        launchctl list ${n}
        launchctl unload ${p}
    fi
done