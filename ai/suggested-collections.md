# Suggested Lightweight Agent Skills, Rules & Collections

A curated reference of lightweight `SKILL.md` and `AGENTS.md` resources usable in **Antigravity (`agy`)** and **Cursor** for safe, semi-autonomous development of **AWS web applications (containerized & serverless)** and **local tools**.

> **Guiding Principle:** Install skills **per-project** into `.agents/skills/` and cherry-pick only the 1–3 skills that match a repo's stack. Keep always-on rules (`AGENTS.md`) short (~15–25 lines) and rely on progressive disclosure for everything else.

---

## 1. Core `agent-lite` Baseline

Repository: [https://github.com/PavelStsefanovich/agent-lite](https://github.com/PavelStsefanovich/agent-lite) — A zero-bloat, per-project alternative to heavy agent process frameworks (`obra/superpowers`). Designed to be isolated to individual projects, compatible with any coding agent, and effortlessly removable.

- **`AGENTS.md`:** Triage by blast radius, ban full implementation code inside plans, enforce root-cause debugging, and require post-edit verification.
- **`systematic-debugging`:** Reproduce → Isolate → Fix → Verify.
- **`tdd-lite`:** Single-context Red-Green-Refactor without subagent bloat.
- **`verify-before-done`:** Require exact observed test/build output before claiming completion.

---

## 2. Official Anthropic Skills (`anthropics/skills`)

Repository: [https://github.com/anthropics/skills/tree/main/skills](https://github.com/anthropics/skills/tree/main/skills)

| Skill | Best For | Why Use It |
| :--- | :--- | :--- |
| [`webapp-testing`](https://github.com/anthropics/skills/tree/main/skills/webapp-testing) | Containerized & serverless web apps | Uses Python + Playwright to verify local running apps, console/network logs, and UI states before deploying to AWS. |
| [`frontend-design`](https://github.com/anthropics/skills/tree/main/skills/frontend-design) | Web UI development | Enforces an explicit design plan before generating React/HTML/Tailwind code and avoids generic boilerplate UI. |
| [`mcp-builder`](https://github.com/anthropics/skills/tree/main/skills/mcp-builder) | Local tools development | Structured workflow for building MCP servers (Python or TypeScript SDKs) to expose local scripts/utilities safely to agents. |
| [`skill-creator`](https://github.com/anthropics/skills/tree/main/skills/skill-creator) | Custom AWS / Docker workflows | Helps author and test your own project-scoped `SKILL.md` runbooks (e.g., `aws-preflight`, `container-smoke-test`). |

*(Skip `docx`, `pdf`, `pptx`, `xlsx`, and `claude-api` unless a specific project requires document generation or direct Anthropic SDK work.)*

---

## 3. Containers, IaC & AWS Collections

| Collection | Link | What It Covers |
| :--- | :--- | :--- |
| **Docker Agent Skills** | [https://github.com/docker/skills](https://github.com/docker/skills) | Official Docker skills for hardened multi-stage `Dockerfile`s, Docker Compose wiring, and sandboxed local container testing. |
| **HashiCorp Agent Skills** | [https://github.com/hashicorp/agent-skills](https://github.com/hashicorp/agent-skills) | Official Terraform / OpenTofu & Packer skills: module refactoring, Terraform tests, style guides, and state/stack workflows. |
| **AWS Builder Skills** | [https://github.com/aws-samples/sample-agent-skills-for-builders](https://github.com/aws-samples/sample-agent-skills-for-builders) | AWS serverless & container patterns (Lambda, Fargate, API Gateway, SQS/SNS/EventBridge, DynamoDB streams), cold starts, SnapStart, and 502/504 debugging. |

---

## 4. Web Apps, Standards & Discovery

| Resource | Link | What It Covers |
| :--- | :--- | :--- |
| **Vercel Agent Skills** | [https://github.com/vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | Lightweight React/Next.js performance and architecture skills (zero-waterfall data fetching, bundle-size reduction) paired with `AGENTS.md`. |
| **AGENTS.md Standard** | [https://agents.md](https://agents.md) | Cross-agent project instruction standard supported by Antigravity, Cursor, Codex, Claude Code, Copilot, Windsurf, and OpenCode. |
| **Netresearch Agent Rules** | [https://github.com/netresearch/agent-rules-skill](https://github.com/netresearch/agent-rules-skill) | Meta-skill that generates a concise, stack-specific `AGENTS.md` from `package.json`, `pyproject.toml`, `go.mod`, etc. |
| **Awesome Agent Skills** | [https://github.com/VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | Curated catalog of 1,000+ vendor and community `SKILL.md` skills. Use as a menu to cherry-pick 1–2 skills per project. |
| **AgenticSkills** | [https://agenticskills.io/](https://agenticskills.io/) | Find AI Agent Skills worth installing. |

---

## 5. Skill Package Managers (Optional)

- **`skills` CLI (Vercel Labs):** [https://github.com/vercel-labs/skills](https://github.com/vercel-labs/skills) — Pull individual skills directly into a project (`npx skills add docker/skills`).
- **`skilld`:** [https://github.com/skilld-dev/skilld](https://github.com/skilld-dev/skilld) — Privacy-friendly, open-source CLI alternative for searching, auditing, and installing `SKILL.md` packages.

---

## 6. Agent Frameworks & Python SDKs

| Resource | Link | What It Covers |
| :--- | :--- | :--- |
| **Superpowers** | [https://github.com/obra/superpowers](https://github.com/obra/superpowers) | An agentic skills framework & SDLC methodology to guide development (quite heavy; see `agent-lite` above for a lightweight alternative). |
| **antigravity-sdk-python** | [https://github.com/google-antigravity/antigravity-sdk-python](https://github.com/google-antigravity/antigravity-sdk-python) | A Python library for building AI agents that leverage the full power of Google Antigravity. |
| **Cursor Python SDK** | [https://cursor.com/docs/sdk/python](https://cursor.com/docs/sdk/python) | Cursor SDK allowing use of the runtime, harness, and models of the Cursor IDE from your own scripts, apps, and backend workflows. |

---

## 7. Recommended AWS Safety Guardrail (Add to Project `AGENTS.md`)

When running agents semi-autonomously on AWS projects, add these 2 lines to the project's `AGENTS.md`:

```markdown
- **AWS & IaC Safety:** Run local/read-only checks autonomously (`docker build`, `sam validate`, `cdk synth`, `cdk diff`, `terraform plan`, `webapp-testing`).
- **Explicit Approval for Mutations:** Never run `cdk deploy`, `terraform apply`, `sam deploy`, or mutating `aws` CLI commands without explicit user confirmation.
```
