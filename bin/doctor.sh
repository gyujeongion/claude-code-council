#!/usr/bin/env bash
#
# doctor.sh — check that the council panel CLIs are installed and reachable.
#
# Run this after install (or when /council misbehaves) to see which panels are
# available. It does NOT send a real prompt by default; pass --smoke to do a
# tiny live round-trip to each detected CLI.
#
# Usage:
#   doctor.sh           # presence + version check
#   doctor.sh --smoke   # also send a 1-token live prompt to each panel

set -uo pipefail

SMOKE=0
[[ "${1:-}" == "--smoke" ]] && SMOKE=1

ok()   { printf '  \033[32m✓\033[0m %s\n' "$*"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$*"; }
info() { printf '  \033[2m·\033[0m %s\n' "$*"; }

check_provider() {
  local name="$1" override="$2" default="$3"
  local bin
  bin="${override:-$default}"
  if ! command -v "$bin" >/dev/null 2>&1 && [[ ! -x "$bin" ]]; then
    bad "$name: '$bin' not found on PATH"
    info "    install it, log in once, or set the override env var"
    return 1
  fi
  local resolved; resolved="$(command -v "$bin" 2>/dev/null || echo "$bin")"
  ok "$name: $resolved"
  return 0
}

echo "claude-code-council — doctor"
echo
echo "Panels:"

GEM_OK=1; GPT_OK=1
check_provider "Gemini (gemini)" "${COUNCIL_GEMINI_BIN:-}" "gemini" || GEM_OK=0
check_provider "GPT (codex)"     "${COUNCIL_GPT_BIN:-}"    "codex"  || GPT_OK=0

if [[ $SMOKE -eq 1 ]]; then
  echo
  echo "Smoke test (live 1-token round-trip):"
  HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ $GEM_OK -eq 1 ]]; then
    if R="$("$HERE/ask.sh" gemini 'reply with exactly: OK' 2>/dev/null)" && [[ -n "$R" ]]; then
      ok "Gemini responded: $(echo "$R" | tr -d '\n' | cut -c1-40)"
    else
      bad "Gemini did not respond — log in by running 'gemini' once"
    fi
  fi
  if [[ $GPT_OK -eq 1 ]]; then
    if R="$("$HERE/ask.sh" gpt 'reply with exactly: OK' 2>/dev/null)" && [[ -n "$R" ]]; then
      ok "GPT responded: $(echo "$R" | tr -d '\n' | cut -c1-40)"
    else
      bad "GPT did not respond — run 'codex login'"
    fi
  fi
fi

echo
if [[ $GEM_OK -eq 1 || $GPT_OK -eq 1 ]]; then
  echo "At least one panel is available. /council can run (it degrades gracefully if one panel is absent)."
else
  echo "No panels available. Install at least one of: gemini-cli, OpenAI codex CLI."
  exit 1
fi
