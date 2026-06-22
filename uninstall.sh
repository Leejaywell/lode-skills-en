#!/usr/bin/env bash
# Lodestar uninstaller (for the script install). Removes the user-level Lodestar files + un-wires the
# gate from settings.json. Your per-project .lode/, project CLAUDE.md, and verify.sh are YOUR artifacts
# and are never touched — remove them yourself if you want.
#
# Usage:
#   bash ~/.claude/lode-uninstall.sh                 # left here by the installer; works offline
#   curl -fsSL https://raw.githubusercontent.com/Leejaywell/lode-skills-en/main/uninstall.sh | bash
#   CLAUDE_HOME=/path bash uninstall.sh              # custom Claude home
set -euo pipefail
DEST="${CLAUDE_HOME:-$HOME/.claude}"

# 1) Un-wire the Lodestar gate from settings.json (remove only our two entries; keep all others; prune empties)
if [ -f "$DEST/settings.json" ] && command -v python3 >/dev/null 2>&1; then
  python3 - "$DEST/settings.json" <<'PY'
import json, shutil, sys
path = sys.argv[1]
try:
    with open(path) as f: s = json.load(f)
    if not isinstance(s, dict): raise ValueError
except Exception:
    sys.exit(0)  # unparseable — leave it alone
def ours(cmd): return "lode-hooks/lode-gate.sh" in cmd or "lode-hooks/lode-signal.sh" in cmd
hooks = s.get("hooks", {}); changed = False
for event in list(hooks.keys()):
    groups = []
    for g in hooks.get(event, []):
        kept = [h for h in g.get("hooks", []) if not ours(h.get("command", ""))]
        if len(kept) != len(g.get("hooks", [])): changed = True
        if kept: g["hooks"] = kept; groups.append(g)
    if groups: hooks[event] = groups
    else: hooks.pop(event, None)
if not hooks: s.pop("hooks", None)
if changed:
    shutil.copy(path, path + ".bak")
    with open(path, "w") as f: json.dump(s, f, indent=2, ensure_ascii=False); f.write("\n")
    print("-> un-wired the gate from settings.json (original backed up to settings.json.bak)")
PY
fi

# 2) Remove Lodestar's own files (leaves your other skills/agents alone)
rm -rf "$DEST/lode-hooks" "$DEST/lodestar"
rm -rf "$DEST"/skills/lode-* 2>/dev/null || true
rm -f "$DEST"/agents/lode-review.md "$DEST"/agents/lode-recon.md "$DEST"/agents/lode-evolve.md 2>/dev/null || true

echo "Lodestar removed from $DEST (skills/subagents/gate scripts/source assets)."
echo "  Your per-project files are UNTOUCHED: .lode/, project CLAUDE.md, verify.sh."
echo "  To drop those in a project too:  rm -rf .lode   (and CLAUDE.md/verify.sh by hand if you want)"
echo "  (Plugin install instead? use: /plugin uninstall lodestar@lodestar  and  /plugin marketplace remove lodestar)"

# 3) Finally remove the uninstaller itself (it lives at $DEST root, not in a removed dir)
rm -f "$0" 2>/dev/null || true
