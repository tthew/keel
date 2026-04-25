#!/usr/bin/env bash
# Ralph doc-budget pre-commit gate — issue #231 / PRD FR14j amendment.
#
# Reads thresholds from .githooks/doc-budget.json (single source of truth shared
# with ralph.py _build_doc_budget_block — no parallel byte/line definitions).
#
# Behaviour controlled by RALPH_DOC_BUDGET_ENFORCE:
#   off            — silent; exit 0.
#   warn-in-prompt — emit stderr warning when over threshold; exit 0 (default).
#   halt-in-prompt — emit stderr error when over threshold; exit 1 (blocks commit).
#                    Promotion gates on (a) ≥20 healthy iters in sizes.jsonl,
#                    (b) P90 ≥30% below cap, (c) Phase-1 FP rate <5%.
#
# Override: RALPH_DOC_BUDGET_OVERRIDE=<bytes> raises the bytes cap for the
# current commit only; usage is logged to $RALPH_BASE_DIR/logs/budget-overrides.jsonl
# when $RALPH_BASE_DIR is set.

set -u

repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || repo_root="$(pwd)"
budget_file="${repo_root}/.githooks/doc-budget.json"
mode="${RALPH_DOC_BUDGET_ENFORCE:-warn-in-prompt}"
override="${RALPH_DOC_BUDGET_OVERRIDE:-}"

if [[ "${mode}" == "off" ]]; then
  exit 0
fi

if [[ ! -f "${budget_file}" ]]; then
  # No SSOT file → silently skip (e.g. fresh checkout pre-bootstrap).
  exit 0
fi

# Resolve a Python interpreter — one is guaranteed by ralph.py's runtime.
py=""
for candidate in python3 python; do
  if command -v "${candidate}" >/dev/null 2>&1; then
    py="${candidate}"
    break
  fi
done
if [[ -z "${py}" ]]; then
  # No Python available → degrade silently (the orient-gate is the PRIMARY defense).
  exit 0
fi

# Inline Python: read SSOT, compute size, emit findings list.
findings="$("${py}" - <<PYEOF
import json
import os
import sys
from pathlib import Path

repo_root = Path(${repo_root@Q})
budget_path = repo_root / ".githooks" / "doc-budget.json"
override_raw = os.environ.get("RALPH_DOC_BUDGET_OVERRIDE", "").strip()
override_bytes = None
if override_raw:
    try:
        override_bytes = int(override_raw)
    except ValueError:
        override_bytes = None

try:
    spec = json.loads(budget_path.read_text())
except Exception:
    sys.exit(0)

findings = []
for relpath, limits in spec.get("files", {}).items():
    p = repo_root / relpath
    if not p.exists():
        continue
    raw = p.read_bytes()
    nbytes = len(raw)
    text = raw.decode("utf-8", errors="replace")
    nlines = text.count("\n") + (0 if text.endswith("\n") else 1)

    max_bytes = limits.get("max_bytes")
    max_lines = limits.get("max_lines")
    if max_bytes is not None and override_bytes is not None and override_bytes > max_bytes:
        max_bytes = override_bytes

    if max_bytes is not None and nbytes > max_bytes:
        findings.append(f"{relpath}: {nbytes:,} bytes > cap {max_bytes:,}")
    if max_lines is not None and nlines > max_lines:
        findings.append(f"{relpath}: {nlines:,} lines > cap {max_lines:,}")

print("\n".join(findings))
PYEOF
)"

if [[ -z "${findings}" ]]; then
  exit 0
fi

# Log override usage when applicable (best-effort).
if [[ -n "${override}" && -n "${RALPH_BASE_DIR:-}" ]]; then
  log_dir="${RALPH_BASE_DIR}/logs"
  mkdir -p "${log_dir}" 2>/dev/null || true
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  sha="$(git rev-parse HEAD 2>/dev/null || echo 'pending')"
  printf '{"ts":"%s","sha":"%s","override_bytes":%s}\n' \
    "${ts}" "${sha}" "${override}" >> "${log_dir}/budget-overrides.jsonl" 2>/dev/null || true
fi

if [[ "${mode}" == "halt-in-prompt" ]]; then
  printf '✗ Ralph doc-budget exceeded (mode=%s — commit blocked):\n%s\n' \
    "${mode}" "${findings}" >&2
  printf '\nPrune RALPH.md / .ralph/@plan.md or set RALPH_DOC_BUDGET_OVERRIDE=<bytes> for emergency.\n' >&2
  printf 'See PRD FR14j amendment + issue #231 for rationale.\n' >&2
  exit 1
fi

# warn-in-prompt (default) — surface the signal but never block.
printf '⚠ Ralph doc-budget warning (mode=%s — commit proceeds):\n%s\n' \
  "${mode}" "${findings}" >&2
printf 'Promote RALPH_DOC_BUDGET_ENFORCE=halt-in-prompt only after ≥20 healthy iters, P90 ≥30%% below cap, FP <5%%.\n' >&2
exit 0
