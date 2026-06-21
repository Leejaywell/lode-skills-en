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
| Doc-driven (Product-Spec→Brief→Plan→Code→Changelog) | in-repo artifacts | `.lode/` runtime artifacts |
| Go = goal+standards+acceptance+constraints+execution strategy | structured Go instruction | `skills/lode-go` |

> Install layout: skills go in `~/.claude/skills/` (or project `.claude/skills/`), subagents in `.claude/agents/`, hooks in `.claude/settings.json`, top-level rules in `CLAUDE.md`.

---

## The 11 skills (six mainline + five extensions)

> Command = skill name (in Claude Code the slash command is the skill name; the model also auto-triggers by description).

Mainline (`①→⑥`):

| # | Command (= skill name) | What it does | Output |
|---|---|---|---|
| 1 | `/lode-spec` | **Interrogate** a fuzzy idea into a buildable requirement (blunt, no flattery) | `Product-Spec.md` |
| 2 | `/lode-brief` | Translate "feel" into concrete design decisions (optional) | `Design-Brief.md` |
| 3 | `/lode-design` | Produce high-fidelity design / clickable prototype (optional) | mockups/prototype |
| 4 | `/lode-plan` | Split into Faces, each independently acceptance-testable and runnable | `DEV-PLAN.md` |
| 5 | `/lode-build` | Build per the plan, running the four-step audit loop | code + `CHANGELOG.md` |
| 6 | `/lode-release` | Privacy audit + package & release | Release |

Extensions (as needed):

| Command (= skill name) | Use |
|---|---|
| `/lode-go` | Write a good **Go** (goal/standards/acceptance/constraints/execution strategy); the AI writes it most accurately |
| `/lode-review` | Fan out a **clean-brain** subagent for independent review (completion gate) |
| `/lode-fix` | Reproduce → locate → minimal fix → regression |
| `/lode-skill` | Build a new skill: grant full capability, don't shred into tools |
| `/lode-evolve` | Distill real failures into rules (self-evolution engine) |

---

## Scope

Lodestar is built for **solo · 0→1 · greenfield · ship a demoable/releasable product** — strongest inside that box.
- ✅ **Good fit**: a person/small project going idea→MVP, prototype validation, greenfield.
- ⚠️ **Use with care / augment**: team collaboration (subagent review is self-review, not a substitute for peer review / PR), brownfield refactors and cross-module migration, long-lived maintenance, safety/compliance-critical systems — layer team review and stronger acceptance on top.
- In one line: it's good at "building the new," not "making the old safe."

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

**Go is the entry point of the loop.** All the standards and rules set earlier are ultimately handed to the AI via one `Go`. There are three ways to execute the dev plan:

1. **DevBuilder**: the main agent uses `lode-build` directly to write code and run the whole plan.
2. **One Go at a time (most common)**: `lode-go` writes the first Face as a Go; copy and send it to execute, looping to completion.
3. **One Go for everything (most efficient, once practiced)**: have `lode-go` plan all Faces holistically into one Go and develop it all in one pass.

Minimal loop:
```
/lode-spec    # interrogate requirements → Product-Spec.md
/lode-plan    # split into Faces → DEV-PLAN.md
/lode-go      # generate the Go
# copy the Go, send to the AI to execute → auto-development + four-step audit loop
```
Full chain: before spec you can run `/lode-go` to turn a one-line idea into a Go; before plan insert `/lode-brief` (+ optional `/lode-design`); wrap up with `/lode-release`.

### Gate & hooks (deterministic judgments → a program)

Merge `hooks/` (`lode-gate.sh` + `lode-signal.sh` + the hooks block in `settings.json`) into the project's `.claude/settings.json`:

- **Stop gate `lode-gate.sh`**: before wrapping up a workspace where dev has started, ① actually run `.lode/<project>/verify.sh` (build+test, verdict by exit code) ② check the non-empty `REVIEW_PASSED` marker no older than CHANGELOG. **Build/test are actually run by a program, not trusting only the model-written flag.**
- **UserPromptSubmit hook `lode-signal.sh`**: on a correction/dissatisfaction keyword, auto-append the signal to `signals.jsonl` to feed self-evolution.
- Before the first Face, lay down a project-level `verify.sh` per `docs/templates/verify.sh` (wrapping this project's build+test commands).

---

## Three iron rules

1. **Build fewer tools, grant more capability** — don't shred a capability into a pile of special-purpose tools, that's actually dumber; grant the full general capability and let the model compose it. The model's smartness is **released, not designed**.
2. **Don't pre-write rules; set them after hitting the pitfall** — a rule must correspond to one real failure; if deleting it makes the problem recur, it earns its place. Don't set rules for pitfalls you haven't hit; proactively delete the useless ones.
3. **Spend your effort on design, not on whistle-blowing** — stop fiddling with prompts; what's truly valuable is designing the flow and the loop well (what each step produces, what counts as passing, what to do on a pitfall, how to evolve), and leave the rest for the AI to decide.
