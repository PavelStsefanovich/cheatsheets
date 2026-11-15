# Development Workstation Security Guide (Windows 11 + WSL2)

> **Environment:** Windows 11 Host + WSL2 (Linux)  
> **Scope:** GitHub CLI (`gh`), Git SSH, AWS CLI v2, Pulumi (AWS S3 backend), Terragrunt / OpenTofu (AWS S3 backend), VS Code (GitHub), and Antigravity CLI (`agy`) / IDE extension.

---

## 1. Overview & Security Goals

This guide establishes a workstation security workflow that allows you to work productively immediately while awaiting a hardware security key (YubiKey), and then transition seamlessly to hardware-backed authentication.

### Core Security Principles

1. **Zero Plaintext Long-Lived Credentials at Rest:** Never store static AWS access keys, unencrypted SSH private keys, or persistent API tokens in dotfiles or environment scripts.
2. **Short-Lived, Ephemeral Sessions (Pre-YubiKey):** Rely on time-bounded sessions (`ssh-agent` TTLs, AWS SSO / `aws-vault` STS credentials, and in-memory tokens).
3. **Hardware-Backed Transition (YubiKey Ready):** Migrate cleanly to FIDO2 / WebAuthn (`ed25519-sk` and security key MFA/Passkeys) requiring physical presence/touch.
4. **Complete End-of-Day (EOD) Teardown:** Explicitly revoke and purge all cached credentials, agent keys, state caches, and Windows Credential Manager tokens at the end of every workday so that local access to the machine does not grant automatic access to cloud or source-control resources.

---

## 2. Per-Tool Authentication & YubiKey Transition

### A. Git & GitHub CLI (`gh`)

#### Today (Pre-YubiKey)
1. **Generate a passphrase-protected temporary SSH key** (never store an unencrypted private key on disk):
   ```bash
   ssh-keygen -t ed25519 -a 100 -f ~/.ssh/id_ed25519_temp -C "temp-pre-yubikey"
   ```
2. **Load into `ssh-agent` with an 8-hour TTL** so it expires automatically in memory:
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add -t 8h ~/.ssh/id_ed25519_temp
   ```
3. **GitHub CLI (`gh`)** — avoid leaving persistent OAuth tokens in `~/.config/gh/hosts.yml`:
   - **Option 1 (Ephemeral Browser Session):** Run `gh auth login -p ssh -w` at the start of the day and let the EOD teardown script revoke the token and remove `~/.config/gh/hosts.yml` via `gh auth logout`.
   - **Option 2 (Zero Disk Storage):** Export a short-lived fine-grained Personal Access Token (PAT) only in your active terminal session so it disappears when the shell closes:
     ```bash
     read -rsp "GH_TOKEN: " GH_TOKEN && export GH_TOKEN
     ```

#### When the YubiKey Arrives
1. **Use Windows 11 native OpenSSH (8.9+)** on the Windows host (which natively triggers Windows WebAuthn prompts for YubiKey) and bridge the Windows `ssh-agent` named pipe into WSL2 using `npiperelay.exe` + `socat`.
   - *Why this over `usbipd-win`?* Both Windows 11 (VS Code, browsers) and WSL2 (`git`, `ssh`) can share the YubiKey concurrently without manually attaching/detaching USB devices.
2. **Generate a hardware-backed FIDO2 SSH key** in Windows PowerShell requiring physical touch (`verify-required` also enforces PIN/touch):
   ```powershell
   ssh-keygen.exe -t ed25519-sk -O resident -O verify-required -C "yubikey-fido2"
   ```
3. **Retire the temporary key:** Remove the temporary public key from your GitHub account settings and securely wipe the local key pair:
   ```bash
   shred -u ~/.ssh/id_ed25519_temp*
   ```

---

### B. AWS CLI v2

#### Today (Pre-YubiKey)
- **Never** populate `~/.aws/credentials` with static `aws_access_key_id` and `aws_secret_access_key` pairs.
- **If using AWS IAM Identity Center (SSO):**
  - Configure a profile via `aws configure sso` with a short session duration (4–8 hours) and TOTP MFA on your phone.
  - Authenticate each day:
    ```bash
    aws sso login --profile <your-profile>
    export AWS_PROFILE=<your-profile>
    ```
- **If using an IAM User:**
  - Enforce MFA on the IAM user and use [`aws-vault`](https://github.com/99designs/aws-vault) to store encrypted base credentials and inject temporary STS credentials (`GetSessionToken` / `AssumeRole`) strictly into a subshell:
    ```bash
    aws-vault exec <profile> --duration=4h -- bash
    ```

#### When the YubiKey Arrives
- Register your YubiKey as a **FIDO2 Security Key / Passkey** in AWS IAM Identity Center (or as an IAM hardware MFA device). Every `aws sso login` or `aws-vault` session refresh will then require physical interaction with the YubiKey.

---

### C. Pulumi (AWS S3 Backend)

#### Today & With YubiKey
- **Backend Authentication:** When using a self-managed AWS S3 state backend (`pulumi login s3://<bucket-name>`), Pulumi does **not** use a Pulumi Cloud API token. Access is governed entirely by your active ephemeral AWS session (`AWS_PROFILE` or `aws-vault` subshell).
- **Secrets Provider (Critical):** Do **not** use the local passphrase secrets provider (which encourages storing `PULUMI_CONFIG_PASSPHRASE` in `.env` files or shell profiles). Initialize stacks with **AWS KMS**:
  ```bash
  pulumi stack init <stack-name> --secrets-provider="awskms://alias/<kms-key-alias>?region=<region>"
  ```
  Using AWS KMS guarantees that encrypting or decrypting stack secrets is impossible without an active, authenticated AWS session.

---

### D. Terragrunt / OpenTofu (AWS S3 Backend)

#### Today & With YubiKey
- Like Pulumi, OpenTofu and Terragrunt authenticate to the S3 state backend using your active ephemeral AWS SSO / STS session.
- **Prevent Local State & Plan Exposure:**
  1. **Remote Backend Encryption & Locking:** Enforce `encrypt = true`, `kms_key_id = "..."`, and `use_lockfile = true` in your S3 backend configuration.
  2. **OpenTofu Client-Side State & Plan Encryption:** Configure an `encryption` block using `key_provider "aws_kms"` so that any cached state or plan files cannot be inspected offline without live AWS KMS access.
  3. **End-of-Day Cleanup:** Always purge `.terragrunt-cache`, `.terraform`, `*.tfplan`, and any local `terraform.tfstate*` files at the end of the day (automated in the teardown script below).

---

### E. VS Code (GitHub)

#### Today (Pre-YubiKey)
- Even when connected to a WSL2 workspace via the Remote-WSL extension, VS Code's UI and GitHub authentication provider run on the **Windows 11 host** and store OAuth tokens inside **Windows Credential Manager** (`SecretStorage`).
- At the end of the day:
  1. Close VS Code (if left open, tokens can remain resident in process memory).
  2. Sign out via **Accounts (bottom-left Activity Bar) → GitHub → Sign Out**, or let the teardown script purge matching entries from Windows Credential Manager using `cmdkey.exe`.

#### When the YubiKey Arrives
- Register the YubiKey as a **WebAuthn Security Key / Passkey** on your GitHub account. Signing back into VS Code will prompt Windows 11 for a YubiKey touch.

---

### F. Antigravity CLI (`agy`) & IDE Extension

#### Why `agy` CLI Has `/logout` While the VS Code Extension Does Not
1. **Control Model:**
   - **Antigravity CLI (`agy`):** Runs in a terminal without graphical window chrome, menus, or status bars, so `/` commands handle both agent tasks and application lifecycle controls (`/logout`, `/exit`, `/quit`, `/help`).
   - **VS Code / Antigravity IDE Extension:** Reserves `/` strictly for agent workflow and prompt commands (`/plan`, `/goal`, `/compact`, `/schedule`, `/browser`, `/grill-me`, `/teamwork`, `/learn`, `/boost`). Application-level sign-out lives in the IDE's graphical **Accounts** menu / Command Palette (`Ctrl+Shift+P`).
2. **Credential Storage Split (WSL2 vs. Windows 11):**
   - `agy` CLI stores its OAuth token directly inside WSL2 (`~/.gemini/antigravity-cli/antigravity-oauth-token`), which `/logout` removes.
   - The VS Code / IDE extension runs on the Windows 11 host and stores credentials in Windows Credential Manager via OS keyring / `SecretStorage`.

#### Today (Pre-YubiKey) & With YubiKey
- **Today:** Authenticate with your Google Account (with 2-Step Verification enabled). Run `/logout` in `agy` before closing, or let the unified teardown script wipe `~/.gemini/antigravity-cli/antigravity-oauth-token` and any host credential entries.
- **When YubiKey Arrives:** Add the YubiKey as a **Passkey / Security Key** on your Google Account (and optionally enroll in Google's **Advanced Protection Program**).

---

## 3. Unified End-of-Day Teardown Solution

This replaces any standalone `agy` token-wipe hook in `~/.bashrc` with one unified script (`~/.local/bin/eod-lockdown.sh`) plus shell integration.

### Step 1: Create `~/.local/bin/eod-lockdown.sh`

Make it executable (`chmod +x ~/.local/bin/eod-lockdown.sh`):

```bash
#!/usr/bin/env bash
set -euo pipefail

QUIET=false
if [[ "${1:-}" == "--quiet" ]]; then
    QUIET=true
fi

log() {
    if [[ "$QUIET" == false ]]; then
        echo "$@"
    fi
}

log "🔒 Starting End-of-Day credential teardown..."

# 1. Antigravity CLI (agy) OAuth token and local auth caches
rm -f ~/.gemini/antigravity-cli/antigravity-oauth-token
rm -rf ~/.gemini/antigravity-cli/*auth* ~/.config/antigravity/*auth* 2>/dev/null || true
log "✓ Removed Antigravity CLI OAuth token and local auth caches"

# 2. Flush all SSH keys from ssh-agent memory
if ssh-add -l >/dev/null 2>&1; then
    ssh-add -D >/dev/null 2>&1 || true
    log "✓ Cleared all SSH keys from ssh-agent"
fi

# 3. Revoke and remove GitHub CLI session
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    gh auth logout --hostname github.com >/dev/null 2>&1 || true
    log "✓ Logged out of GitHub CLI"
fi
rm -f ~/.config/gh/hosts.yml

# 4. Log out of AWS SSO, aws-vault, and wipe local CLI token caches
if command -v aws >/dev/null 2>&1; then
    aws sso logout >/dev/null 2>&1 || true
fi
if command -v aws-vault >/dev/null 2>&1; then
    aws-vault clear >/dev/null 2>&1 || true
fi
rm -rf ~/.aws/sso/cache/* ~/.aws/cli/cache/*
log "✓ Cleared AWS SSO, aws-vault, and CLI session caches"

# 5. Clear Pulumi local backend state & cached credentials
if command -v pulumi >/dev/null 2>&1; then
    pulumi logout --all >/dev/null 2>&1 || true
fi
rm -f ~/.pulumi/credentials.json
log "✓ Logged out of Pulumi backends"

# 6. Purge Terragrunt / OpenTofu local caches, plan files, and local state in ~/workshop
if [ -d "$HOME/workshop" ]; then
    find "$HOME/workshop" -type d \( -name ".terragrunt-cache" -o -name ".terraform" \) -prune -exec rm -rf {} +
    find "$HOME/workshop" -type f \( -name "*.tfplan" -o -name "terraform.tfstate*" \) -delete
    log "✓ Purged local Terragrunt/OpenTofu caches, plan files, and state artifacts"
fi

# 7. Clear Windows Credential Manager entries for GitHub, VS Code, Antigravity, and Gemini via WSL interop
if command -v cmdkey.exe >/dev/null 2>&1; then
    cmdkey.exe /list | grep -iE "Target:.*(github|vscode|antigravity|gemini)" | sed 's/.*Target: //;s/\r//' | while read -r target; do
        cmdkey.exe /delete:"$target" >/dev/null 2>&1 || true
        log "✓ Removed Windows credential: $target"
    done
fi

log "✅ Lockdown complete. Close VS Code if open; all tools will require re-authentication on next start."
```

> **Note:** Run `cmdkey.exe /list` in WSL2 once while signed into VS Code and extensions to verify the exact target names stored by your Windows host, and adjust the `grep -iE` pattern in Step 7 if needed.

### Step 2: Update `~/.bashrc`

Remove the single-purpose `agy` `EXIT` trap from `~/.bashrc` and replace it with the unified `eod` alias and `EXIT` trap:

```bash
# Manual End-of-Day lockdown (clears active shell env vars, runs teardown, clears session history)
alias eod='unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE GH_TOKEN GITHUB_TOKEN PULUMI_CONFIG_PASSPHRASE && ~/.local/bin/eod-lockdown.sh && history -c'

# Automatically run full teardown when the final interactive bash session closes
trap 'if [ $(pgrep -u "$USER" -x -c bash) -le 1 ]; then ~/.local/bin/eod-lockdown.sh --quiet; fi' EXIT
```

---

## 4. Host-Level Hardening (Windows 11 + WSL2)

Even if you step away without running `eod`, harden the Windows 11 + WSL2 host so physical or local access cannot exploit active sessions:

1. **BitLocker Full-Disk Encryption + Pre-Boot PIN:**
   - Enable BitLocker on your Windows 11 system drive (and any secondary drive holding WSL2 `.vhdx` disks) so `ext4.vhdx` and Windows Credential Manager databases are encrypted at rest.
2. **Short Screen Auto-Lock & Quick Lock:**
   - Configure Windows 11 screen timeout / Dynamic Lock to `<= 5 minutes` and always lock with `Win + L` when stepping away.
3. **Terminate WSL2 Automatically on Workstation Lock:**
   - Running `wsl --shutdown` in PowerShell stops the WSL2 VM kernel immediately, wiping `ssh-agent` memory, `/tmp`, and any lingering shell environment variables.
   - Bind a **Windows Task Scheduler** task to trigger on **Workstation Lock** (Security Audit **Event ID `4800`**; note that auditing for Workstation Lock/Unlock must be enabled in Local Security Policy if not already active) to run:
     ```powershell
     wsl.exe -e bash -lc "~/.local/bin/eod-lockdown.sh --quiet"
     wsl.exe --shutdown
     ```
