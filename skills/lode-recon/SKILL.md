---
name: lode-recon
description: "Lodestar mainline ⓪ (brownfield). Recon before touching old code: map the existing architecture, conventions, build/test/run commands, hotspots, and test baseline into a system map. Use when the goal lands in an existing project (not greenfield) and you must change/extend/migrate without breaking what's there. Trigger: /lode-recon"
---

# Recon (Codebase Recon)

The brownfield entry step (greenfield projects skip it). **Before** spec/plan, map the existing system into a `System-Map.md`, so spec knows "what the current state is" and plan knows "where touching it will blow up."

> First principle: planning without understanding the existing system is changing someone else's code blindfolded. See clearly first, then act.

## Usage (when to use)

- The goal lands in an **existing project** (has code, has history), not from scratch.
- You're changing/extending/migrating existing behavior, and **must not break the current state**.
- The first step before `lode-spec` (delta mode) / `lode-plan`.

## How to recon (see, don't guess)

Prefer structured tools over plain reading: if codegraph/LSP is available, use it for "who calls whom, what does changing this ripple into"; otherwise grep + read the key files. Focus on:

1. **Architecture & boundaries**: modules/layers, entry points, data flow, external deps and integration points.
2. **Conventions**: naming, directory organization, error handling, configuration, existing code style (later changes must "look like it").
3. **How to run it**: the **real** build / test / run / lint commands (raw material for verify.sh).
4. **Test baseline**: are existing tests **currently all green**, what's covered, which areas are untested (changing those is high-risk).
5. **Hotspots & risk**: high coupling, giant files, untested core paths, security/data-sensitive surfaces.

## Done (what counts as acceptable)

Produce `.lode/<project>/System-Map.md` (starter template in `docs/templates/System-Map.md`), satisfying:
- Architecture map: modules/layers + key entry points + data flow, enough to locate code from it.
- Conventions list: naming/dirs/error-handling/config/style — so later changes "look like the existing code."
- **Runnable commands**: real build, test, run, lint commands (feed straight into `verify.sh`).
- **Baseline snapshot**: run the existing tests once, record the current green/red status and coverage blind spots — this is the reference frame for later judging "what did I break."
- Risk areas: name the high-coupling / untested / security-sensitive spots, for plan's impact analysis.

## Guardrails (red lines)

- **Look, don't touch**: no business code, no refactor in recon; record what needs changing into the map, leave it for plan/build.
- Argue with evidence: architecture conclusions come from actual call relations/code, not from imagining the repo name.
- The baseline must **actually run** the tests once, not assume "it should be green."
- The map serves "safe changes," not completeness — focus on the areas you'll touch, don't write an encyclopedia for the whole repo.
