# Git configuration and advanced usage

> This guide assumes Ubuntu 20.04 as host OS


## Initial Git config

```bash
# minimum config
git config --global user.name "Your Name"
git config --global user.email "youremail@yourdomain.com"

# additional config
git config --global init.defaultBranch main
git config --global core.editor "'C:/Program Files/Notepad++/notepad++.exe' -multiInst -nosession"
git config --global merge.tool p4merge
git config --global mergetool.p4merge.path "C:/Program Files/Perforce/p4merge.exe"
git config --global diff.tool p4merge
git config --global difftool.p4merge.path "C:/Program Files/Perforce/p4merge.exe"
git config --global alias.hist "log --all --graph --decorate --oneline"

# credentials (Windows)
git config --global credential.helper wincred

# credentials (WSL)
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
# older version of Git:
# git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-wincred.exe"
# Microsoft Docs: https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-git

# verify global config
git config --list
```

## New Git repo
```bash
# Create a new repository on remote hosting (GitHub/GitLab/etc.).
# To avoid errors, do not initialize the new repository with README, license, or gitignore files.

# initialize the local directory as a Git repository.
git init --initial-branch=main

# add the files, stage them commit
git add .
git commit -m "First commit"

# add the remote repository URL
git remote add origin <remote_repo_url>
git remote -v # this verifies the new remote URL

# push local repo to remote
git push origin main
```


## Remote operations

```bash
# show only remote URL
git config --get remote.origin.url

# show full origin configuration
git remote show origin

# add remote
git remote add <remote> <url>.git

# push local branch/tags to specific remote
git push -u <remote> <local_branch>
git push -u <remote> --all
git push -u <remote> --tags

# set specifi remote to track local branch
git branch --set-upstream <local_branch> <remote>/<remote_branch>
```

## Revert changes

```bash
# revert the workspace to the last commit
git reset --hard HEAD

# revert to a specific commit and delete all commits after that
# (!) this rewrites Git history,
# so be carefull with commits that have already been pushed
git reset --hard <some_commit>
# to add a note of the reset operation to the history:
git reset --soft HEAD@{1}
git commit -m "Reverting to the state at commit <some_commit>"
git push -f
```


## Merge branches with unrelated history

```bash
git pull <unrelated_branch> --allow-unrelated-histories
# this may result in the merge conflicts; resolve them, commit and push to update remote
git push origin <your_branch>
```


## Tags operations

```bash
# pull latest tags
git pull --tags

# list tags with dates
git log --tags --simplify-by-decoration --pretty="format:%ci %d"

# list gags with commit hashes
git show-ref --tags

# show hash for single tag
git show-ref {tag_name}

# show details of the commit hash
git show {commit_sha}

# compare tags
git diff tag1 tag2

# show log between tags
git log tag1..tag2

# show only list of changed files
git diff tag1 tag2 --stat

# show diff for a particular file
git diff tag1 tag2 -- some/file/name
```


## Update Local Workspace After Main Branch Rename On Remote
Assuming old default branch was `main` and new one is `v1`

```bash
git branch -m main v1
git fetch origin
git branch -u origin/v1 v1
git remote set-head origin -a 
```



## Submodules
A Git repository may include reference to another repository using [Git Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

```bash
# clone parent and simultaneously initialize submodlue repo
git clone --recurse-submodules https://github.com/parent_repo.git

# if cloned as usual, initialize submodule repo later
cd <parent_repo_root_dir>
git submodule update --init --recursive

# Submodule repository reference always points to the specific commit SHA.
# To change the commit that you want to point to, run the following command
# while replacing <commit_sha> and <submodule_repo_dir_name> with correct value:
cd <parent_repo_root_dir>
git update-index --cacheinfo 160000,<commit_sha>,<submodule_repo_dir_name>

# to make this change permanent for everyone, commit and push to remote origin.
```

> NOTE: Visual Studio Code manages index update automatically.


### Troubleshooting
Regardless of the way Git index is updated (VS Code or manually), it may result in the "detached HEAD" state in the submodule repository.
In order to merge your local changes back into the branch that submodule originally pointed to, do the following:

```bash
cd <submodule_repo_dir>
git branch tmp
git checkout <original_submodule_branch>
git merge tmp
git push
git branch -d tmp
```


## MacOS Notes

```bash
# use keychain to cache Git secret (https://medium.com/codex/git-credentials-on-macos-caching-updating-and-deleting-your-git-credentials-8d22b6126533)
git config --global credential.helper osxkeychain
```

## Links
- [10 Secret Git Commands](https://dev.to/arpitstack/10-secret-git-commands-that-will-save-you-5-hours-every-week-1mpn)
