#!/usr/bin/env bash
####### this doesn't work because of brew not liking the relink since it's not the link that brew lays down
# the following gets the origin url of a git repo
# need to recursively run this command once to get all git urls
# git config --get remote.origin.url

# move git and create a wrapper for hooks
sh "$(pwd)/utilities/wrapper.sh" git "$(pwd)/utilities/git"