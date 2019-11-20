# Git
This directory contains folder structure for how
i want git to be structured.

The script will read ./git/folder-structure.txt
and split first by line then by pipe.  The first
comma index is where on the file system to put
the repos and the next is what repos to put there.

The script should also cleanup, if it exists in
the directory but not in the file then move it to
git-tmp.