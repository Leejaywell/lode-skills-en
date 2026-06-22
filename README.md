# Lodestar — Claude Code Edition

[中文](https://github.com/Leejaywell/lode-skills) · **English**

> **Lodestar** — a structured development flow built on Claude Code's native capabilities that walks you from a one-line fuzzy idea to a runnable, shippable product.
> In one line: **you set the star, the AI navigates.**
>
> **Core belief**: Prompts are depreciating; process design is appreciating. AI is no longer a tool but the executor of the entire development process.
> **Humans set the goal, the AI runs the loop**: the human does only two things — **make decisions** and **accept results** — and even "setting the goal" can be ghost-written by the AI.
>
> It splits development into **Spec → Design → Plan → Build → Release**, five independently acceptance-testable stages: deterministic hooks as gates (no wrap-up until build/test pass), an independent subagent for clean review, and rules distilled from real failures. Even if you've only just touched vibe coding, follow along and you'll ship something usable.

---

## How Lodestar is built on Claude Code

| Concept | Claude Code mechanism | Location in this repo |
|---|---|---|
| 11 Skills | `SKILL.md` skills | `skills/lode-*` |
| Top-level rules | `CLAUDE.md` | `CLAUDE.md` |
| Subagents | `Agent` tool + subagents | `agents/lode-review.md` |
| Deterministic rules → gate | **Hooks** (`.claude/settings.json`) | `hooks/` |
| Self-evolution (signals→proposals→rule base) | `CLAUDE.md` rule base + Evolution Runner | `CLAUDE.md` + `skills/lode-evolve` |
| Skill writes only Usage/Done/Guardrails | Skill frontmatter + minimal body | each `SKILL.md` |
| Doc-driven (product-spec→Brief→Plan→Code→Changelog) | in-repo artifacts | `.lode/` runtime artifacts |
| Go = goal+standards+acceptance+constraints+execution strategy | structured Go instruction | `skills/lode-go` |

> Install layout: skills go in `~/.claude/skills/` (or project `.claude/skills/`), subagents in `.claude/agents/`, hooks in `.claude/settings.json`, top-level rules in `CLAUDE.md`.

---

## The 13 skills (seven mainline + six extensions)

> Command = skill name (in Claude Code the slash command is the skill name; the model also auto-triggers by description).

Mainline (`⓪→⑥`):

| # | Command (= skill name) | What it does | Output |
|---|---|---|---|
| 0 | `/lode-recon` | **(brownfield)** Map existing architecture/conventions/commands/baseline | `system-map.md` |
| 1 | `/lode-spec` | **Interrogate** a fuzzy idea into a buildable requirement (brownfield → delta) | `product-spec.md` |
| 2 | `/lode-brief` | Translate "feel" into concrete design decisions (optional) | `design-brief.md` |
| 3 | `/lode-design` | Produce high-fidelity design / clickable prototype (optional) | mockups/prototype |
| 4 | `/lode-plan` | Split into Faces (brownfield: impact analysis/migration/baseline) | `dev-plan.md` |
| 5 | `/lode-build` | Build per the plan, running the four-step audit loop | code + `changelog.md` |
| 6 | `/lode-release` | Privacy audit + package & release (team: PR/CI) | Release |

Extensions (as needed):

| Command (= skill name) | Use |
|---|---|
| `/lode-drive` | **Autonomous driver**: run one goal to completion; resumable, auditable progress ledger |
| `/lode-go` | Write a good **Go** (goal/standards/acceptance/constraints/execution strategy) |
| `/lode-review` | Fan out a **clean-brain** subagent for independent review (incl. regression/security/traceability) |
| `/lode-fix` | Reproduce → locate → minimal fix → regression |
| `/lode-skill` | Build a new skill: grant full capability, don't shred into tools |
| `/lode-evolve` | Distill real failures into rules (self-evolution engine) |

---

## Scope + modes

The lean mainline is tuned for **solo · greenfield · 0→1**; two **mode switches** extend it to old projects and teams (`lode-drive` sets them at the start):
- **Greenfield ↔ brownfield**: old projects first `/lode-recon` for a system map, spec runs as a delta, plan does impact analysis/migration/baseline, verify runs **full regression**.
- **Solo ↔ team**: solo uses the local `review-passed` gate; team/long-lived switches to the **PR/CI gate**, with the subagent review dropping to a pre-PR filter (not a substitute for human review).
- **Safety/compliance**: plus mandatory security review + requirement-code-test traceability.
- Vision: **set one goal → the agent runs it to completion → greenfield or brownfield**. Autonomous ≠ unattended — the human shows up only at "review the PR" and "handle the breaker." Greenfield stays light; old projects/teams get the heavy guardrails.

## Install & use

> Prereq: [Claude Code](https://claude.com/claude-code). Skills and subagents install **user-wide** (`~/.claude/`, available in every project); the gate and `CLAUDE.md` install **per project**.

**1. Install skills + subagents (one line)**
```bash
git clone https://github.com/Leejaywell/lode-skills-en.git
cd lode-skills-en && bash install.sh
```
Copies `skills/lode-*` into `~/.claude/skills/` and `agents/lode-*` into `~/.claude/agents/`. After that, type `/lode-spec`, `/lode-plan`, `/lode-go`… in any project.
(Project-only install: just copy `skills/` and `agents/` into the project's `.claude/`.)

**2. Add the deterministic gate to a project (optional, recommended)** — in your project root:
1. `cp -R <this-repo>/hooks ./hooks && chmod +x ./hooks/*.sh` (the gate scripts resolve `$CLAUDE_PROJECT_DIR/hooks/`).
2. `cp <this-repo>/CLAUDE.md ./CLAUDE.md` (or merge into your existing one).
3. Merge the `hooks` block from `hooks/settings.json` into the project's `.claude/settings.json`.
4. At dev start, lay down `.lode/<project>/verify.sh` from `docs/templates/verify.sh` (wrapping build+test).

With that: before wrapping up a workspace where dev has started, the gate auto-runs `verify.sh` + checks the review marker, and blocks wrap-up if either fails; corrections/dissatisfaction get captured as signals for self-evolution.

## How to use

### A. Autonomous (recommended) — one goal, the agent runs it to the end
```
/lode-drive Finish <goal>
```
`lode-drive` detects **greenfield/brownfield** and **solo/team** itself, decomposes into milestones → Faces, runs each through the four-step audit + regression, maintains a progress ledger (resumable after crashes, auditable when done), replans on divergence, and trips the breaker when stuck. You show up only to **review PRs** and **handle the breaker**.

### B. Manual, step by step — when you want to drive each stage
Greenfield minimal loop:
```
/lode-spec    # interrogate requirements → product-spec.md
/lode-plan    # split into Faces (each Face's acceptance scenarios defined first) → dev-plan.md
/lode-go      # generate the Go for a single Face, send it to execute → four-step audit loop
```
- **Old project**: first `/lode-recon` for a `system-map.md`; spec then runs as a delta (current→target + must-never-break).
- Full chain: before plan you can insert `/lode-brief` (+ optional `/lode-design`); wrap up with `/lode-release` (team: PR/CI).
- Three granularities for executing Faces: main agent runs the whole plan with `lode-build` / one Go per Face (most common) / one Go for all Faces (most efficient once practiced).

> **Tests bind to the requirement**: each Face's "acceptance scenarios" are defined **before building** in plan; tests are written to the scenarios and review verifies against them — closing the "green tests but wrong feature" gap.

### Gate & hooks (deterministic judgments → a program)

Merge `hooks/` (`lode-gate.sh` + `lode-signal.sh` + the hooks block in `settings.json`) into the project's `.claude/settings.json`:

- **Stop gate `lode-gate.sh`**: before wrapping up a workspace where dev has started, ① actually run `.lode/<project>/verify.sh` (build+test, verdict by exit code) ② check the non-empty `review-passed` marker no older than CHANGELOG. **Build/test are actually run by a program, not trusting only the model-written flag.**
- **UserPromptSubmit hook `lode-signal.sh`**: on a correction/dissatisfaction keyword, auto-append the signal to `signals.jsonl` to feed self-evolution.
- Before the first Face, lay down a project-level `verify.sh` per `docs/templates/verify.sh` (wrapping this project's build+test commands).

---

## Three iron rules

1. **Build fewer tools, grant more capability** — don't shred a capability into a pile of special-purpose tools, that's actually dumber; grant the full general capability and let the model compose it. The model's smartness is **released, not designed**.
2. **Don't pre-write rules; set them after hitting the pitfall** — a rule must correspond to one real failure; if deleting it makes the problem recur, it earns its place. Don't set rules for pitfalls you haven't hit; proactively delete the useless ones.
3. **Spend your effort on design, not on whistle-blowing** — stop fiddling with prompts; what's truly valuable is designing the flow and the loop well (what each step produces, what counts as passing, what to do on a pitfall, how to evolve), and leave the rest for the AI to decide.
