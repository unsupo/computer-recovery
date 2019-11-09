# the following gets the origin url of a git repo
# need to recursively run this command once to get all git urls
# git config --get remote.origin.url

# move git and create a wrapper for hooks
sh "$(pwd)/utilities/wrapper.sh" brew "$(pwd)/utilities/brew"