#!/usr/bin/env bash
#for script in scripts/*; do
#  [[ -e "$script" ]] || break  # handle the case of no files
#  sh "$script"
#done
# execute all scripts in the scripts directory
# install brew
if ! command -v brew >/dev/null; then
  URL_BREW='https://raw.githubusercontent.com/Homebrew/install/master/install'

  echo -n '- Installing brew ... '
  echo | /usr/bin/ruby -e "$(curl -fsSL $URL_BREW)" > /dev/null
  if $?; then echo 'OK'; else echo 'NG'; fi
fi
brew bundle
brew bundle cleanup --force
# done installing brew
cdir=$(pwd)

# make dirs
mkdir -p ~/log

# run all scripts in scripts directory
find "$cdir"/scripts -type f -name '*.sh' -exec sh {} \;

# git (can add this to scripts)
git_manager="$cdir/misc-bin-scripts/git-manager.sh"
sh ${git_manager} ${cdir}/git/folder-structure.txt

# link dotfiles
dotfiles_dir=dotfiles
find "$cdir"/${dotfiles_dir}/ -type f -exec ln -fs {} ~/ \;

cd "$cdir" || exit # forgot why i put this

# link bitbar plugins
bitbar_plugins=bitbar-plugins
bitbar_dir=~/bitbar-plugins/
mkdir -p "$bitbar_dir" 2>/dev/null
#sudo find "$cdir"/$bitbar_plugins/ -type f -exec ln -fs {} "$BITBAR_DIR"/ \;
ln -fs "$cdir"/${bitbar_plugins} "$bitbar_dir"

# launchctl (can add this to scripts)
#sh ${cdir}/misc-bin-scripts/launchd-manager.sh ${cdir}/launchd