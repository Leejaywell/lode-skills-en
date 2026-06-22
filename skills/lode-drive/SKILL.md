---
name: lode-drive
description: "Lodestar autonomous driver. Take one goal and run the whole mainline autonomously: detect greenfield/brownfield and solo/team mode → break into milestones and Faces → run each through the four-step audit + regression → commit/open PR → update a progress ledger → replan on divergence → until the goal is met or the breaker trips. Use when the user 'sets one goal and wants the agent to run it to completion autonomously.' Trigger: /lode-drive"
---

# Drive (Autonomous Driver)

Lodestar's autonomous brain. This is what makes "one goal → run to completion → greenfield or brownfield" real: it doesn't write a single Go, it **drives the whole mainline loop**, running to the end on a resumable **progress ledger**.

> Autonomous ≠ unattended. It drives the whole way; the human shows up at just two points: **reviewing PRs** and **handling the breaker**.

## Usage (when to use)

- The user gives one goal and wants the agent to **run the entire goal to completion autonomously**, without babysitting each step.
- The goal may span many Faces / many Sessions, needing to survive crashes and be auditable when done.

## Set two modes at the start (they decide how heavy the guardrails are)

1. **Greenfield ↔ brownfield**: existing code means brownfield → first `lode-recon` to produce `system-map.md`, spec runs in delta mode, plan does impact analysis, verify runs **full regression**. Greenfield uses the lean flow.
2. **Solo ↔ team**: solo uses the local `review-passed` gate; team/long-lived switches to the **PR/CI gate** — completion = PR passes CI + required approvals merged.

## How to run (the drive loop)

1. **Set the goal**: write it into `.lode/<project>/goal.md` (goal + acceptance-testable done criteria).
2. **Decompose**: goal → milestones → ordered Faces (each Face a Goal, tagged with dependencies/parallelizability/blast-radius). Write into `dev-plan.md`.
3. **Open the ledger**: `.lode/<project>/ledger.jsonl`, one record per Face (status + commit/PR + time).
4. **Loop**: read the ledger → pick the next **unblocked** Face → do it with `lode-build` → **four-step audit + full regression** → commit (team mode: open PR, wait for CI/review) → **update the ledger** → next.
5. **Replan**: a Face reveals the plan was wrong → go back to `lode-plan`, fix the plan, then continue; **don't grind on a stale plan**.
6. **Circuit breaker**: ≥3 consecutive failures on the same Face, or a token-budget overrun → stop and ask the user, laying out the sticking point and what's known in one go.
7. **Wrap up**: all milestones met → run `lode-release` (or merge the final PR) → self-check against goal.md's done criteria.

## Done (what counts as acceptable)

- `goal.md` + `dev-plan.md` + `ledger.jsonl` all present and continuously updated; at any moment the ledger shows "where it's at, what's left."
- Every Face passed the four-step audit + regression gate (team mode: PR merged), faithfully recorded in the ledger.
- Goal met = every done criterion in `goal.md` satisfied, argued with evidence (command output/PRs/reviews).
- A mid-run crash can resume losslessly from the ledger; the whole run is auditable.

## Guardrails (red lines)

- **The ledger is the truth**: a status is written `passed` only after the four-step audit/regression/PR actually pass — no optimistic early marking.
- **Breaker over grinding**: the gate blocks "bad completion," the breaker blocks "expensive non-completion"; if stuck, stop, don't burn tokens.
- Brownfield must `lode-recon` first and must run full regression; **no baseline, no touching old code**.
- In team mode, "completion" = merged, not a local marker; the subagent review is only a pre-PR filter, not a substitute for human review.
- One goal, one ledger; parallel Faces don't touch the same file, the main agent merges conflicts.
- Decision authority always stays with the human: confirm before irreversible outward actions (push is covered by the PR flow; store submission/deploy).
