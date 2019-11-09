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
  if [ $? -eq 0 ]; then echo 'OK'; else echo 'NG'; fi
fi
brew bundle
brew bundle cleanup --force
# done installing brew

# run all scripts in scripts directory
find scripts -type f -name '*.sh' -exec sh {} \;

cdir=$(pwd)
git_downloader="./misc-bin-scripts/git-download.sh"
sh $git_downloader github-links.txt ~/.git
sh $git_downloader gitwork-links.txt ~/.git_work

# link dotfiles
dotfiles_dir=dotfiles
find $dotfiles_dir/ -type f -exec ln -fs "$cdir"/{} ~/ \;

cd "$cdir" || exit

# link bitbar plugins
bitbar_plugins=bitbar-plugins
find $bitbar_plugins/ -type f -exec ln -fs "$cdir"/{} "$BITBAR_DIR"/ \;
