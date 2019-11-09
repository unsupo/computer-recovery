#!/usr/bin/env bash
# pass in a script and a script to overwrite that script
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "must pass 2 arguments: first is command to override and second is script that overrides it"
  exit 1
fi
path=$(command -v $1)
new_path="$path""_"

[ "$(readlink "$path")" == "$2" ] && exit 0

# if $1 is a symbolic link
if [ -L "$path" ]; then
  ln -sf "$(readlink "$path")" "$new_path"
  rm "$path"
else
  cp "$path" "$new_path"
fi
ln -s "$2" "$path"