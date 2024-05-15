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
```
