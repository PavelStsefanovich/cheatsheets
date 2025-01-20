# Bash configuration and advanced usage

> This guide assumes Ubuntu 20.04 as host OS


## Config

### ~/.bashrc
```bash
# prompt
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@MY_DISTRO\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@MY_DISTRO:\w\$ '
fi
unset color_prompt force_color_prompt

# if using CQ Cloud Profile Manager v2+, you can include current profile context variables
    PS1='\n\[\033[01;35m\]$CQ_CURRENT_PROFILE\[\033[01;30m\]|\[\033[01;34m\]$CQ_CURRENT_REGION\[\033[01;30m\]|\[\033[01;31m\]$CQ_CURRENT_K8S\n${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@MY_DISTRO\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# env vars
PATH=/home/pstsefanovich/.local/bin:$PATH
export GH_USER_NAME="gh_user"
export GH_API_KEY=`cat /mnt/c/keys/github/api_key.txt`

# bash completion
source /etc/bash_completion
source <(kubectl completion bash)
complete -F __start_kubectl k

# aliases
alias k=kubectl
alias tg="terragrunt"
alias tp="terragrunt plan"
alias ti="terragrunt init"
alias ta="terragrunt apply"
alias taa="terragrunt apply -auto-approve"
alias tro="terragrunt refresh"
alias td="terragrunt destroy"
alias tda="terragrunt destroy -auto-approve"
alias ame="aws sts get-caller-identity"
```

## Command: find
```bash
# find file recursively in current directory
find . -name "file.name" -type f

# find file and delete
find . -name "file.name" -type f -exec rm -r "{}" \;

# find directory recursively in current directory
find . -name "dir.name" -type d

# find directory and delete (with content)
find . -name "dir.name" -type d -exec rm -rf "{}" \;

# find files and rename
find -type f -name "*text*" -exec rename -- 's/basename\.ext/basename_new\.ext/' {} \;
```

## Comman: grep
```bash
# find all files containing specific text in current directory recursively
grep -lr example

# find all files containing specific text in specific directory recursively
grep -lr <text> <directory_path>/*
```
