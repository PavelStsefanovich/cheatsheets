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
```

## Merge branches with unrelated history

```bash
git pull <unrelated_branch> --allow-unrelated-histories
# this may result in the merge conflicts; resolve them, commit and push to update remote
git push origin <your_branch>
```

## Tags operations

```bash
# list tags with dates
git log --tags --simplify-by-decoration --pretty="format:%ci %d"
```
