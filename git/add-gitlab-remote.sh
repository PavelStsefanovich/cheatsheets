#!/bin/bash

# --- 1. Configuration and Argument Parsing ---
GROUP=""

# g is optional. If not provided, GROUP remains empty.
while getopts "g:" opt; do
  case $opt in
    g) GROUP="$OPTARG/" ;; 
    \?) echo "Usage: $0 [-g group_name]" >&2; exit 1 ;;
  esac
done

# --- 2. Retrieve GitHub URL ---
GITHUB_URL=$(git remote get-url origin 2>/dev/null)

if [ -z "$GITHUB_URL" ]; then
    echo "Error: No 'origin' remote found."
    exit 1
fi

# --- 3. Parse GitHub URL and Transform ---
# Removes the prefix (git@github.com: or https://github.com/)
CLEAN_PATH=$(echo "$GITHUB_URL" | sed -E 's|^(git@github\.com:\|https://github\.com/)||')

# Extract Org and Repo
ORG_NAME=$(echo "$CLEAN_PATH" | cut -d'/' -f1)
REPO_NAME=$(echo "$CLEAN_PATH" | cut -d'/' -f2)

# Convert Org Name to lower case
ORG_LOWER=${ORG_NAME,,}

# --- 4. Construct GitLab URL ---
# If GROUP is empty, it results in: git@gitlab.com:org-lower/repo-name
# If GROUP is 'app351/', it results in: git@gitlab.com:org-lower/app351/repo-name
GITLAB_URL="git@gitlab.com:${ORG_LOWER}/${GROUP}${REPO_NAME}"

# Ensure .git suffix exists and clean up any double slashes
if [[ "$GITLAB_URL" != *.git ]]; then
    GITLAB_URL="${GITLAB_URL}.git"
fi
GITLAB_URL=$(echo "$GITLAB_URL" | sed 's|//|/|g')

echo "Detected GitHub: $GITHUB_URL"
echo "Target GitLab:   $GITLAB_URL"

# --- 5. Setup Remotes ---
# Setup 'gitlab' remote
if ! git remote | grep -q "^gitlab$"; then
    git remote add gitlab "$GITLAB_URL"
    echo "Added 'gitlab' remote."
else
    git remote set-url gitlab "$GITLAB_URL"
    echo "Updated 'gitlab' remote URL."
fi

# Setup 'all' remote (recreate for clean state)
if git remote | grep -q "^all$"; then
    git remote rm all
fi

git remote add all "$GITHUB_URL"
git remote set-url --add --push all "$GITHUB_URL"
git remote set-url --add --push all "$GITLAB_URL"

echo "Created 'all' remote for dual-sync."
echo "----------------------------------------------------"
git remote -v
echo "----------------------------------------------------"
echo "To push to both: git push all <branch>"
