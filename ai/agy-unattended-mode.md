# Running `agy` Unattended Without Prompting

You can configure `agy` to run without prompting you until a task is complete using **session flags**, **persistent configuration**, or **headless print mode**.

---

## 1. Full Auto-Approve for One Session (Fastest)

Launch `agy` with:

```bash
agy --dangerously-skip-permissions
```

This auto-approves all tool and command permission requests without prompting until you exit.

* **Safer variant:** Add `--sandbox` to keep terminal and filesystem access restricted to your workspace:
  ```bash
  agy --dangerously-skip-permissions --sandbox
  ```
* **Headless / single-prompt run:** Add `-p` (`--print`) so it runs the task to completion and exits:
  ```bash
  agy -p "Build and test the project" --dangerously-skip-permissions
  ```

---

## 2. Auto-Approve Edits Only (Safer Middle Ground)

If you want file edits approved automatically while still prompting for risky shell commands:

```bash
agy --mode accept-edits
```

---

## 3. Persistent Configuration (Always On)

You can configure this permanently via `/config` or `/permissions` inside `agy`, or by editing `~/.gemini/antigravity-cli/settings.json`:

```json
{
  "agentMode": "accept-edits",
  "toolPermission": "always-proceed",
  "permissions": {
    "allow": [
      "command(git)",
      "command(npm test)"
    ],
    "deny": [
      "command(rm -rf)"
    ]
  }
}
```

Using `"toolPermission": "always-proceed"` with a `"deny"` list lets `agy` run without nagging you while still blocking destructive commands.

---

## Tip for Long-Running Tasks

If you want `agy` to keep working autonomously until a multi-step job is completely finished (rather than stopping early to check in), you can also use the `/goal` slash command inside the session.
