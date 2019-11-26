#!/usr/bin/env bash
[[ -z $1 || ! -f $1 ]] && { echo 'Folder structure file must be passed as first argument'; exit 1; }

folder_structure=$1
path=$(dirname ${folder_structure})
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

while read l || [[ -n "$l" ]]; do
    # skip comment characters and empty lines
    if [[ ${l} =~ ^#.*$ || -z ${l} ]]; then continue; fi
    # split on pipe
    IFS='|' read -ra ADDR <<< "$l"
    d=${ADDR[0]} # directory to create and put all repos
    r=${ADDR[1]} # file containing list of all repos
    d="${d/#\~/$HOME}"
    mkdir -p ${d}
    sh ${DIR}/git-download.sh ${path}/${r} ${d}
done < ${folder_structure}