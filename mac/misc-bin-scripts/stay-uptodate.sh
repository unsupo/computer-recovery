#!/usr/bin/env bash
# make sure mac dock is as expected
# dockutil --list --homeloc /Volumes/Macintosh\ HD/home

# manage mac app store. with mas
# upgrade app store applications
mas=/usr/local/bin/mas
brew=/usr/local/bin/brew_
function get_date(){
    date '+%y%m%d'
}
datefile=~/log/stayuptodate.date

if [[ -f ${datefile} && get_date -le $(cat ${datefile}) ]]; then
    exit 0
fi

echo '-----------------------------------------------------'
date
# mas for mac applications
echo "updating mac applications"
${mas} upgrade || exit 1

# brew
echo "updating and upgrading brew"
${brew} update && ${brew} upgrade && ${brew} cask upgrade
[[ $? > 0 ]] && exit 1

get_date > ${datefile}
date
echo '-----------------------------------------------------'