#!/usr/bin/env bash
# Deterministic verification script — laid down by lode-build at dev start to .lode/<project>/verify.sh.
# Purpose: wrap this project's "build + full regression tests" into one command, all pass => exit 0, any failure => non-zero.
# The Stop gate lode-gate.sh actually runs it — "did build/test pass" is a deterministic judgment, handed
# to a program, not the model's verbal self-assessment.
#
# Greenfield: build + this project's tests is enough.
# Brownfield: MUST run [the full existing suite + new tests], and compare against the pre-change baseline —
#             to tell "what you broke" from "what was already broken."
#             Save the baseline once before touching anything (in lode-recon):
#             `bash verify.sh > .lode/<project>/baseline.txt 2>&1 || true`
#
# Replace the commands below for your stack:
set -euo pipefail

# 1) Build
# npm run build

# 2) Full regression tests (existing + new; brownfield especially must not run only this Face's tests)
# npm test

# 3) Optional: typecheck / lint (universal invariants — recommend gating these too)
# npm run typecheck
# npm run lint

echo "verify.sh: replace the placeholder commands above with this project's real build + full-test commands."
exit 0
