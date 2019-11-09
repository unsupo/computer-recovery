# git dir
git_links=$1 # github-links.txt
git_dir=$2  #~/git
mkdir -p $git_dir
ln -s $git_links $git_dir
cd $git_dir
# download all links in github-links.txt file
< $git_links xargs -I % git clone %
# done git cloning