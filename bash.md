# Bash configuration and advanced usage

> This guide assumes Ubuntu 20.04 as host OS

## Config

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
