#!/usr/bin/env bash
# Illustrative walkthrough (the skill runs inside Claude Code and calls your real Gemini/GPT
# logins). Scripted so the GIF is stable; the structure mirrors examples/code-review.md.
set -euo pipefail
say(){ printf '\033[1;36m$ %s\033[0m\n' "$1"; sleep .5; }
p(){ printf '%b\n' "$1"; sleep "${2:-.5}"; }

echo; printf '\033[1mStop letting one AI grade its own homework.\033[0m\n'; sleep 1.1; echo
say '/council review this Go cache for concurrency bugs:'
p '    var cache = map[string]int{}'
p '    func Get(k string) int    { return cache[k] }'
p '    func Set(k string, v int) { cache[k] = v }' .8
p '\033[2m  → asking Gemini …   asking GPT …   (parallel, zero Claude tokens)\033[0m' 1.6
echo
p '\033[32m✅ consensus (Gemini + GPT):\033[0m concurrent map read/write → data race, will panic under load' .8
p '\033[33m⚠  split:\033[0m   Gemini → sync.RWMutex        GPT → sync.Map' .9
p '\033[1m⚖  verdict (Claude, chair):\033[0m RWMutex — faster than sync.Map for a read-heavy cache,'
p '                            and the race is on both paths, so guard both.' .6
p '    func Get(k string) int { mu.RLock(); defer mu.RUnlock(); return cache[k] }' 1.8
echo
printf '\033[2millustrative — runs in Claude Code via your existing Gemini/GPT CLI logins. No API keys.\033[0m\n'; sleep 2
