```markdown
# 🚀 Claude Code — Ultimate Cheat Sheet (2025 Edition)

## 🧩 Installation

### macOS / Linux / WSL
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### Windows (CMD)
```bash
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

### Windows (PowerShell)
```powershell
irm https://claude.ai/install.ps1 | iex
```

## ⚡ Core Commands

### Launch interactive shell
```bash
claude
```

### Run a one‑off prompt
```bash
claude "Explain quantum computing like I'm five"
```

### Pipe input into Claude
```bash
cat server.log | claude "summarize errors"
```

### Use a specific model
```bash
claude --model claude-3.7-sonnet
```

### Check version
```bash
claude --version
```

### Update CLI
```bash
claude update
```

## 📁 Working With Files

### Ask Claude about a file
```bash
claude -f app.py "explain what this script does"
```

### Multiple files
```bash
claude -f src/ -f README.md "generate documentation"
```

### Upload a directory
```bash
claude -f project/ "audit this codebase"
```

## 🧠 Context & Memory

### Set system prompt
```bash
claude --system "You are a strict TypeScript reviewer"
```

### Provide additional context
```bash
claude -c context.txt "improve this design"
```

## 🛠️ Developer Power Moves

### Generate code
```bash
claude "write a Python script that monitors CPU usage"
```

### Refactor code
```bash
claude -f main.go "refactor for readability"
```

### Explain code
```bash
claude -f index.js "explain this to a junior dev"
```

### Create tests
```bash
claude -f utils.py "write pytest tests"
```

### Debug via pipe
```bash
npm test 2>&1 | claude "help me fix these failures"
```

## 🐳 DevOps & Shell Integration

### Summarize Docker containers
```bash
docker ps | claude "summarize what these containers do"
```

### Analyze logs
```bash
journalctl -u nginx | claude "find root cause"
```

### Generate scripts
```bash
claude "write a bash script to rotate logs"
```

## 📦 Project Scaffolding

### Create a new project
```bash
claude "scaffold a FastAPI project with auth"
```

### Generate architecture diagrams (text-based)
```bash
claude "create a mermaid diagram for this microservice"
```

## 🔍 Search & Research

### Summarize a URL
```bash
claude "summarize https://example.com/article"
```

### Compare two things
```bash
claude "compare PostgreSQL vs MongoDB for analytics workloads"
```

## 🧪 Advanced Usage

### Temperature control
```bash
claude --temperature 0.2 "be precise"
```

### JSON output
```bash
claude --json "return structured data about this log"
```

### Streaming mode
```bash
claude --stream "explain this step by step"
```

### Save output to file
```bash
claude "generate release notes" > RELEASE_NOTES.md
```

## 🎯 Practical Workflows

### Code Review
```bash
claude -f src/ "perform a deep code review and list issues by severity"
```

### Bug Reproduction
```bash
claude -f bug_report.txt -f logs/ "find likely root cause"
```

### API Design
```bash
claude "design a REST API for a todo app with endpoints and schemas"
```

### Documentation
```bash
claude -f project/ "generate a full README with examples"
```
```
