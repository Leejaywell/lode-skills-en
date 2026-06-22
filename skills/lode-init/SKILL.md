---
name: lode-init
description: "Lodestar extension skill · project init. One-shot scaffolds the per-project files Lodestar needs but a plugin install won't auto-deploy: the top-level rules CLAUDE.md + a .lode/<project>/verify.sh skeleton + the .lode directory. Use when the user just installed Lodestar (especially as a plugin), is starting in a project for the first time, and the project has no CLAUDE.md/verify.sh yet. Trigger: /lode-init"
---

# Init (project initialization)

Extension skill. Lays down, in one shot, the files Lodestar needs to run that are **per-project** and that a plugin install does NOT auto-deploy. After installing the skills/subagents/gate (plugin or script), run this once in the **target project root** to be ready to go.

> Why it exists: a plugin can ship skills/agents/hooks, but the top-level operating rules `CLAUDE.md` are per-project — the plugin won't write them into your project. lode-init closes that "last manual residue."

## Usage (when to use)

- Just installed Lodestar and starting in a project for the **first** time.
- The project has no top-level `CLAUDE.md` (operating rules) or `.lode/<project>/verify.sh` yet.

## What it does (scaffold three things, fill what's missing)

`<project>` = the current project's directory name.

1. **Top-level rules `CLAUDE.md` → project root**: Lodestar's operating conventions.
   - Source location: plugin install → `${CLAUDE_PLUGIN_ROOT}/CLAUDE.md`; script install → the repo you cloned. Probe with `echo "$CLAUDE_PLUGIN_ROOT"` first; if empty, look under `~/.claude` or the clone dir; **if you can't find it, stop and ask the user where Lodestar is installed** — don't regenerate one from memory (it'll be stale).
2. **`.lode/<project>/verify.sh` skeleton**: copy from `docs/templates/verify.sh`, `chmod +x`. This is the build+test script the wrap-up gate actually runs — **lay the skeleton now; the real commands are filled by `lode-recon` / the first `lode-build`**.
3. **`.lode/<project>/` directory**: create it; all later artifacts (spec/plan/changelog…) land here.

> A script install (non-plugin) still needs the `hooks` block from `hooks/settings.json` merged into `.claude/settings.json` — that's not lode-init's job, see README. A plugin install already has the gate active.

## Done (what counts as good)

- The project root has `CLAUDE.md` (created this run, or confirmed present with a merge note).
- `.lode/<project>/verify.sh` exists and is executable.
- Close with a one-line pointer: greenfield → next is `lode-spec`, brownfield → next is `lode-recon`.

## Guardrails (red lines)

- **Never overwrite an existing `CLAUDE.md` / `verify.sh`**: if present, tell the user how to merge; don't silently clobber their files.
- **Scaffold only**: don't guess the project's build/test commands — that's `lode-recon`'s job.
- If you can't find the source files, stop and ask; don't fabricate a stale `CLAUDE.md`.
