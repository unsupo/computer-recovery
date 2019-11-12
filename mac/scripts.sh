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

# run all scripts in scripts directory
find "$cdir"/scripts -type f -name '*.sh' -exec sh {} \;

git_downloader="$cdir/misc-bin-scripts/git-download.sh"
sh "$git_downloader" "$cdir"/github-links.txt ~/git
sh "$git_downloader" "$cdir"/gitwork-links.txt ~/git_work

# link dotfiles
dotfiles_dir=dotfiles
find "$cdir"/$dotfiles_dir/ -type f -exec ln -fs {} ~/ \;

cd "$cdir" || exit

# link bitbar plugins
bitbar_plugins=bitbar-plugins
mkdir -p "$BITBAR_DIR"
#sudo find "$cdir"/$bitbar_plugins/ -type f -exec ln -fs {} "$BITBAR_DIR"/ \;
ln -fs "$cdir"/$bitbar_plugins "$BITBAR_DIR"