#!/usr/bin/env bash
# git dir
[[ -z $1 || ! -f $1 ]] && { echo 'Git repo file must be passed as first argument'; exit 1; }
[[ -z $2 ]] && { echo 'Directory to put repos must be passed as second argument'; exit 1; }
git_links=$1 # github-links.txt
git_dir=$2  #~/git
mkdir -p "$git_dir" 2>/dev/null
ln -s "$git_links" "$git_dir" 2>/dev/null
cd "$git_dir"

gdb=$(dirname ${git_dir})
gdn=$(basename ${git_dir})
tmp=${gdb}/tmp_${gdn}
gl=$(basename ${git_links})
# download all links in github-links.txt file
#< "$git_links" xargs -I % git clone % # don't use fancy
while read l  || [[ -n "$l" ]]; do
    # skip comment characters
    if [[ ${l} =~ ^#.*$ ]]; then continue; fi
    n=$(basename ${l})
    n="${n%.*}"
    if ls ${tmp}/${n} >/dev/null 2>&1; then
        echo "Found $n in $tmp, moving back"
        mv ${tmp}/${n} ${git_dir}
    else
        git clone ${l} 2>/dev/null
    fi
done < ${git_links}
# done git cloning

# move unused repos to tmp_${git_dir}
for i in $(ls -d ${git_dir}/*); do
    n=$(basename ${i})
    [[ ${n} == ${gl} ]] && continue
    if ! grep ${n} ${git_links} >/dev/null; then
        mkdir -p ${tmp} 2>/dev/null
        mv ${i} ${tmp}
        echo "moved $n to $tmp"
    fi
done
