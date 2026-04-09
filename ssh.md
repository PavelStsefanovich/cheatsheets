# SSH CONFIGURATION AND OPERATIONS

## Create SSH key pair

```bash
# Check if a pair exists already
ls -al ~/.ssh

# Create new SSH key (optionally enter passphrase)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy Public Key (put it onto the target server)
cat ~/.ssh/id_ed25519.pub
```

### Test Connection

```bash
# Example: GitLab
# Test connection
ssh -T git@gitlab.com

# Clone repository
git clone git@gitlab.com:username/project-name.git
```
