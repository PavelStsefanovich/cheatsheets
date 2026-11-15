# Cursor developer crash course (CLI-first)

Mental model: Cursor is a **layered agent stack**. You shape behavior with files on disk; the agent discovers them and decides when to use them. CLI and IDE share most of that surface.

---

## 1. Primitive map (what goes where)

| Primitive | Job | Where | When it loads |
|---|---|---|---|
| **Rules** | Persistent policy / conventions | `.cursor/rules/*.mdc`, also root `AGENTS.md` / `CLAUDE.md` | Always, or when globs match |
| **Skills** | Procedural playbooks (workflows + scripts) | `.cursor/skills/`, `.agents/skills/`, `~/.cursor/skills/` | Auto by description, or `/skill-name` |
| **Subagents** | Isolated specialists with own context | `.cursor/agents/*.md`, `~/.cursor/agents/` | Parent delegates via Task |
| **Hooks** | Deterministic gates / side effects | `.cursor/hooks.json` + scripts | On lifecycle events |
| **MCP** | External tools/APIs | `~/.cursor/mcp.json`, `.cursor/mcp.json` | Session start (approved) |
| **CLI config** | Permissions, sandbox, approval, statusline | `~/.cursor/cli-config.json`, project `.cursor/cli.json` | CLI session |
| **User rules** | Personal always-on prefs | Cursor settings (not files) | All sessions for you |

### Decision guide

- **Always true, short, policy-like** → Rule (`alwaysApply: true`) — e.g. “never commit without review”
- **True only for certain files** → Rule with `globs` — e.g. Go package layout for `**/*.go`
- **Multi-step workflow the agent should follow** → Skill — e.g. TDD loop, deploy checklist, `/create-pr` style flow
- **Needs its own context / parallel / different model** → Subagent — e.g. explorer, reviewer, security auditor
- **Must be enforced by code, not hope** → Hook — e.g. block `curl`/`rm -rf`, format after edit, gate MCP
- **Talks to GitHub/Jira/DB/browser** → MCP
- **Runs outside Cursor UI (CI, bots)** → SDK (`@cursor/sdk` / `cursor-sdk`) or `agent -p`

**Anti-pattern:** stuffing long workflows into always-on rules. That burns context every turn. Prefer skills + progressive disclosure.

---

## 2. Rules

```markdown
---
description: TypeScript error-handling conventions
globs: **/*.{ts,tsx}
alwaysApply: false
---

# Error handling
- Never empty catch
- Wrap and rethrow with cause
```

**Practices**

- One concern per rule; keep under ~50 lines when possible
- `alwaysApply: true` only for hard team policy
- Use `AGENTS.md` for a single repo “operating manual” the CLI also reads
- Dynamic “apply intelligently” rules without globs are skill-shaped — migrate with `/migrate-to-skills`

---

## 3. Skills

```text
.cursor/skills/land-it/
  SKILL.md          # required
  references/       # optional, loaded on demand
  scripts/          # optional, agent executes
```

```markdown
---
name: land-it
description: Ship a PR merge-ready. Use when landing a branch, fixing CI, or triage review comments.
disable-model-invocation: false   # true = slash-only
paths:                            # optional file scoping
  - "**/*"
---
```

**Practices**

- Description = WHAT + WHEN (agent uses it for discovery)
- Default `disable-model-invocation: true` for dangerous/expensive workflows you want only via `/`
- Keep `SKILL.md` lean; put deep docs in `references/`
- Nested dirs are fine; identity = folder that contains `SKILL.md`
- Monorepo: put skills under `apps/web/.cursor/skills/` — auto-scoped to that tree
- Don’t put custom skills in `~/.cursor/skills-cursor/` (Cursor-managed)

**Invoke**

- Auto: agent matches description
- Explicit: `/land-it`
- Sticky session: Custom Mode (Option/Alt+Enter on the skill)

Useful built-ins for CLI folks: `/update-cli-config`, `/statusline`, `/create-rule`, `/create-skill`, `/create-hook`, `/create-subagent`, `/loop`, `/autopilot`, `/split-to-prs`, `/sdk`

---

## 4. Hooks (enforcement layer)

```json
{
  "version": 1,
  "hooks": {
    "beforeShellExecution": [
      {
        "command": ".cursor/hooks/approve-network.sh",
        "matcher": "curl|wget|nc ",
        "failClosed": true
      }
    ],
    "afterFileEdit": [
      { "command": ".cursor/hooks/format.sh" }
    ],
    "subagentStop": [
      { "command": ".cursor/hooks/chain-review.sh", "loop_limit": 3 }
    ]
  }
}
```

**High-value events for CLI workstations**

- `beforeShellExecution` / `beforeMCPExecution` — gate network, prod, secrets
- `afterFileEdit` — format/lint
- `beforeSubmitPrompt` — block secrets in prompts
- `subagentStart` / `subagentStop` — control or chain multi-agent loops
- `sessionStart` — inject env/context

Command hooks: JSON in → JSON out. Exit `2` = deny. Prefer `failClosed: true` for security hooks.

---

## 5. CLI workstation setup

```bash
curl https://cursor.com/install -fsS | bash
agent                  # interactive
agent "fix flaky test" # with prompt
agent -p "..." --output-format json   # scripts/CI
```

### Recommended project layout

```text
repo/
  AGENTS.md                 # high-level agent brief
  .cursor/
    rules/                  # policy
    skills/                 # workflows
    agents/                 # custom subagents
    hooks.json + hooks/     # enforcement
    mcp.json                # project MCP (optional)
    cli.json                # project CLI overrides
```

### Personal layer

```text
~/.cursor/
  cli-config.json           # permissions, sandbox, approvalMode, statusLine
  mcp.json                  # global MCP
  skills/                   # personal skills
  agents/                   # personal subagents
  hooks.json + hooks/       # personal gates
```

### CLI knobs that matter

| Setting | Why |
|---|---|
| `approvalMode`: `allowlist` vs yolo/`--force` | Safety vs speed |
| `permissions.allow` / `deny` | `Shell(**)`, `Mcp(name, tool)` patterns |
| `sandbox.mode` + network allowlist | Contain shell |
| `subagentModels.explore` | Cost/speed for Explore |
| `statusLine` | Model, cwd, context %, worktree |
| Project `.cursor/cli.json` | Repo-specific overrides (merged deeper-wins) |

### Daily CLI muscle memory

| Action | How |
|---|---|
| Plan first | `agent --plan` or Shift+Tab / `/plan` |
| Read-only | `--mode=ask` / `/ask` |
| Isolated edits | `agent --worktree "…"` |
| Cloud handoff | prepend `&` to a message |
| Resume | `agent resume` / `--continue` / `agent ls` |
| MCP | `agent mcp list` / `enable` / `disable` / `list-tools` |
| Review diffs | Ctrl+R |
| Compress context | `/summarize` |

ACP: `agent acp` exposes the CLI as an ACP server over stdio for custom clients.

---

## 6. Agent customization how-to

### Layering (precedence intuition)

1. Hooks can **block/rewrite** (hard gate)
2. Always-on rules + `AGENTS.md` (ambient policy)
3. Glob/path-scoped rules & skills (when files match)
4. Explicit `/skill` or Custom Mode (sticky playbook)
5. Subagent system prompt (isolated specialist)
6. Your message (intent)

### Practical recipes

**Team baseline**

1. `AGENTS.md` — repo map, how to run tests, “ask before X”
2. Always-apply rules for git/safety
3. Glob rules per language/stack
4. Project skills for ship/review/deploy
5. Hooks for format + dangerous shell

**Personal CLI ergonomics**

1. Tighten `cli-config.json` allowlist
2. Statusline with model + context %
3. Personal skills: your PR/commit style
4. Sync `~/.cursor/skills/` for Cloud Agents if you use them

**Slash-only vs auto skills**

- Auto: discovery-heavy (“when user mentions Datadog…”)
- Slash-only (`disable-model-invocation: true`): expensive, rare, or policy-sensitive (`/autopilot`, deploy)

---

## 7. Orchestration & multi-agent

### A. In-session subagents (CLI + IDE + Cloud)

Parent agent launches Task/subagents:

- **Explore** / **Browser** — built-in, context isolation
- **Custom** — `.cursor/agents/foo.md`

```markdown
---
name: verifier
description: Validates completed work. Use proactively after implementations.
model: inherit
readonly: true
---
Run tests, check acceptance criteria, report pass/fail with gaps.
```

**Patterns**

- Parallel research: multiple explore/general agents on different areas
- Sequential pipeline: implement → verifier → security-review
- Background: long CI watch / research while parent continues
- Skill vs subagent: skill = one-shot playbook in same context; subagent = separate context/expertise

### B. Hook-chained loops

`subagentStop` can return `followup_message` to continue a loop (with `loop_limit`). Useful for “review until clean” without you babysitting every hop.

### C. Built-in orchestration skills

| Skill | Pattern |
|---|---|
| `/loop 5m check deploy` | Recurring local/cloud ticks |
| `/autopilot` | PR merge-ready loop (conflicts → comments → CI) |
| `/split-to-prs` | Decompose large work into reviewable PRs |
| Best-of-N / worktrees | Parallel attempts in isolated checkouts (`--worktree`) |

### D. Cloud Agents

- Mid-CLI: `& do the long refactor`
- Good for unattended work; pick up at cursor.com/agents
- Project skills travel with the repo; personal skills need Sync Skills

### E. Programmatic orchestration (SDK)

Three shapes:

1. `Agent.prompt(...)` — one-shot script/CI
2. `Agent.create` + `send` — multi-turn, streaming
3. `Agent.resume(id)` — continue across processes

```typescript
import { Agent } from "@cursor/sdk";

const result = await Agent.prompt("Fix failing tests", {
  apiKey: process.env.CURSOR_API_KEY!,
  model: { id: "composer-2.5" },
  local: { cwd: process.cwd() }, // or cloud: { repos: [...] }
});
```

Also: `agent -p` for simple shell/CI without the SDK.

**Trap list:** always set `local` or `cloud` explicitly; distinguish startup errors vs run failures; always `wait()` / dispose agents.

---

## 8. Opinionated “good workstation” checklist

1. Install CLI, auth once, run `agent` from repo root
2. Add `AGENTS.md` + 2–5 focused rules
3. Convert repeatable workflows → project skills
4. Add custom subagents only for review/verify/explore-style isolation
5. Hooks for format + shell/MCP policy (`failClosed` on security)
6. MCP only for tools you actually use; `agent mcp enable` allowlist
7. CLI: sandbox on for daily work; allowlist approval; statusline on
8. Prefer `--worktree` / Plan mode for risky changes
9. Use `/autopilot` or Cloud `&` for unattended PR care
10. Keep always-on context tiny; put depth in skills/references

---

## 9. Quick “when I’m stuck” map

| Goal | Reach for |
|---|---|
| Teach conventions | Rules / `AGENTS.md` |
| Teach a procedure | Skill |
| Isolate expensive research | Subagent (Explore/custom) |
| Enforce / audit | Hook |
| Connect external system | MCP |
| Automate outside Cursor | SDK or `agent -p` |
| Watch PR to green | `/autopilot` + `/loop` |
| Split a monster branch | `/split-to-prs` |

---

## Docs

- [CLI using](https://cursor.com/docs/cli/using)
- [Skills](https://cursor.com/docs/skills)
- [Hooks](https://cursor.com/docs/hooks)
- [Subagents](https://cursor.com/docs/subagents)
- [SDK TypeScript](https://cursor.com/docs/sdk/typescript)
