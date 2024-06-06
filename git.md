# Git configuration and advanced usage

> This guide assumes Ubuntu 20.04 as host OS

## Initial Git config

```bash
# set your global commit name and email address
git config --global user.name "Your Name"
git config --global user.email "youremail@yourdomain.com"

# verify global config
git config --list
```

## Origin operations

```bash
# show only remote URL
git config --get remote.origin.url

# show full origin configuration
git remote show origin
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

# compare tags
git diff tag1 tag2

# show log between tags
git log tag1..tag2

# show only list of changed files
git diff tag1 tag2 --stat

# show diff for a particular file
git diff tag1 tag2 -- some/file/name
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
