# skills.sh — Agent Skills Directory & CLI

[skills.sh](https://www.skills.sh/) (created by Vercel Labs) is an open directory, registry, and leaderboard for **Agent Skills**—reusable, modular instruction sets, workflows, and domain-specific knowledge for AI coding agents and assistants (such as Claude Code, Cursor, Codex, and GitHub Copilot).

---

## Overview

* **Standardized Format (`SKILL.md`):** Each skill is a portable folder centered around a `SKILL.md` file containing YAML frontmatter (lightweight metadata) and deeper instructions, scripts, or references. Agents pre-load the metadata and read the full instructions on demand (*progressive disclosure*) only when a task matches.
* **Agent-Agnostic CLI (`npx skills`):** Paired with the open-source `skills` CLI, developers can search, install, and update skills across supported agent harnesses directly from GitHub repositories or local paths.
* **Public Leaderboards:** The site tracks installation metrics and activity to surface **All-Time** and **Trending** skills.

---

## Common Use Cases

1. **Enforcing Tech-Stack Best Practices:** Inject official framework rules (e.g., React/Next.js performance patterns) directly into the agent's context instead of relying on outdated training defaults.
2. **Improving UI/UX & Preventing "AI Aesthetic":** Guide agents to plan visual hierarchy, typography, spacing, and accessibility intentionally.
3. **Standardizing Engineering Workflows & Guardrails:** Enforce structured processes (e.g., root-cause debugging, TDD, or *clarify → spec → plan → execute* loops).
4. **Bootstrapping Niche Domain Expertise:** Supply exact APIs and pitfall warnings for specialized tools (e.g., deterministic frame-by-frame video rendering or QA automation).
5. **Cross-Agent Portability & Team Sharing:** Store skills as flat, version-controlled files in Git so teams can share and update guidelines across editors and agent runtimes.

---

## Notable Popular Skills

| Skill | Source (`<owner/repo>`) | Purpose |
| :--- | :--- | :--- |
| `find-skills` | `vercel-labs/skills` | Meta-skill that lets an AI agent search `skills.sh` and pull in relevant skills for your project. |
| `vercel-react-best-practices` | `vercel-labs/agent-skills` | Impact-prioritized React and Next.js performance & architecture guidelines. |
| `web-design-guidelines` | `vercel-labs/agent-skills` | UI/UX and accessibility auditor checking components against Vercel's Web Interface Guidelines. |
| `frontend-design` | `anthropics/skills` | Foundational UI direction skill for deliberate design planning, typography, and layout composition. |
| `skill-creator` | `anthropics/skills` | Utility skill for scaffolding `SKILL.md` files, optimizing descriptions, and benchmarking skills. |
| `remotion-best-practices` | `remotion-dev/skills` | Domain guidance for programmatic video generation in React/Remotion. |
| `systematic-debugging` | `obra/superpowers` | 4-phase root-cause analysis workflow that prevents blind symptom-patching. |

---

## Installation & Source Formats

### Project-Local vs. Global

By default, `npx skills add` installs skills **locally to the current project** (e.g., `./.agents/skills/`, tracked via `skills-lock.json`). Use `-g` / `--global` to install a skill **globally** across all projects for your user (`~/.agents/skills/`):

```bash
# Project-local (default)
npx skills add <owner/repo> --skill <skill-name>

# Global (available across all projects)
npx skills add <owner/repo> --skill <skill-name> -g
# or --global
```

### What `<owner/repo>` Means & Accepted Sources

`<owner/repo>` is the **GitHub repository shorthand** (`<username-or-org>/<repository>`), such as `vercel-labs/agent-skills` for `https://github.com/vercel-labs/agent-skills`.

`npx skills add` also accepts:
* **Pinned version/branch/commit:** `npx skills add owner/repo@v1.2.3`
* **Full GitHub URL or subdirectory:** `npx skills add https://github.com/vercel-labs/agent-skills/tree/main/skills/web-design-guidelines`
* **Local directory path:** `npx skills add ./my-local-skills`

### Common CLI Commands & Flags

```bash
npx skills find                  # Interactive search
npx skills find <query>          # Keyword search on skills.sh
npx skills add <src> --list      # Preview skills in a repo before installing
npx skills add <src> -a <agent>  # Target a specific agent (e.g., claude-code, cursor)
npx skills ls -g                 # List globally installed skills
npx skills update                # Update installed skills
```

---

## Discovering Relevant Skills for Your Project (Agent-Driven Workflow)

To let your AI coding agent automatically inspect any project and discover matching skills:

1. **Install `find-skills` globally (one-time setup):**
   ```bash
   npx skills add vercel-labs/skills --skill find-skills -g
   ```
2. **Prompt your agent inside a project:**  
   Ask your agent to inspect the repository and search for relevant skills (e.g., *"Inspect my project's tech stack and use `find-skills` to recommend relevant skills for it"*).
3. **Agent translates stack and intent into queries:**  
   The agent reads files like `package.json`, `pyproject.toml`, or config files, maps your stack/tasks to keywords (e.g., `react`, `tailwind`, `playwright`, `supabase`), and queries the registry via:
   ```bash
   npx skills find <query>
   ```
4. **Vetting & recommendation:**  
   The agent evaluates `skills.sh` results (descriptions, install counts, source repos) and presents the best matches with their install commands.
5. **Install chosen skills into your project:**  
   Approve or run the project-local install for the skills you want:
   ```bash
   npx skills add <owner/repo> --skill <skill-name>
   ```
   This installs the skill into your project's local agent directory and records it in `skills-lock.json`.
6. **Fallback if nothing matches:**  
   If no existing skill fits a specialized task, the agent handles it directly or can scaffold a new project skill template with `npx skills init [name]`.
