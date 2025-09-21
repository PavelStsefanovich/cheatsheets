# uv
An extremely fast Python package and project manager, written in Rust.

Home Page: https://docs.astral.sh/uv/
GitHub page: https://github.com/astral-sh/uv



## Installation & Update
```bash
# Install on macOS and Linux.
curl -LsSf https://astral.sh/uv/install.sh | sh
# or
wget -qO- https://astral.sh/uv/install.sh | sh

# Show version
uv -V

# Update itself to the latest version
uv self update
```


## Python Versions
```bash
# Install Python versions
uv python install 3.10 3.11 3.12
```


## Projects
uv manages project dependencies and environments, with support for lockfiles, workspaces, etc., similar to Poetry:
```bash
# Init project
uv init example
cd example

# Install dependencies
uv add ruff

# Update lock file
uv lock

# Create new virtual environment
uv venv
# with specific Python version
uv venv -p 3.12.0

# Update exising virtual environment with any changes
uv sync

# Run project
uv run main.py
```


## Scripts
uv manages dependencies and environments for single-file scripts
```bash
# Add inline metadata declaring script dependencies (adds "import" statements)
uv add --script example.py requests

# Immediately run the script in an isolated virtual environment
uv run example.py
```
