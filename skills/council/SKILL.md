---
name: council
description: Convene a council of other AI models to cross-examine an answer, plan, or piece of code. Claude acts as chairman — it sends the SAME question to other locally-installed model CLIs (Gemini, GPT) in parallel, then synthesizes agreements, surfaces disagreements, and delivers its own verdict. Use when you want a second opinion, want to stress-test a decision, suspect Claude might be wrong, or say "council", "/council", "ask the other models", "cross-check this", "get a second opinion", "have them argue", "stress-test this plan". Burns ZERO Claude tokens on the panel calls and needs NO API keys — it shells out to CLIs you already log into.
---

# council — multi-model cross-examination

You (Claude) are the **chairman**. You take a question, send it to two *other*
models running as local CLIs, collect their independent answers, and then do the
one thing a single model can't do for itself: **judge its own blind spots against
a dissenting opinion.**

> An AI shouldn't grade its own homework. The council makes it defend the answer
> against models that have no stake in being right.

| Panel | Call | Backed by |
|---|---|---|
| Gemini | `ask.sh gemini "..."` | your logged-in `gemini` CLI |
| GPT | `ask.sh gpt "..."` | your logged-in `codex` CLI |

Both run **outside** your Claude subscription — they spend **zero Claude tokens**
and need **no API keys**. They use CLIs you have already authenticated.

## How to call

```bash
<skill-dir>/bin/ask.sh gemini "<prompt>"
<skill-dir>/bin/ask.sh gpt    "<prompt>"
```

Call **both panels in parallel** — issue the two Bash commands in a single
response so they run at the same time.

If a panel's CLI isn't installed or isn't logged in, `ask.sh` exits non-zero with
a clear message. **Degrade gracefully**: continue as chairman with whatever
panels answered, and tell the user one seat was empty.

## Workflow

1. **Frame the question.** Turn the user's request (or your own uncertainty) into
   one clear, self-contained prompt. Send the *identical* prompt to both panels —
   same wording, no leading the witness.
2. **Call both panels in parallel.** `ask.sh gemini` + `ask.sh gpt` in one turn.
3. **Chair the synthesis.** Do not just average the answers. Explicitly:
   - State the **points of agreement**.
   - Name the **disagreements** — who said what differently, and why it matters.
   - Give **your own verdict** with reasoning. You are the chairman, not a vote
     counter. If both panels are wrong, say so and explain.
4. **Attribute every claim.** Tag opinions by source: `(Gemini)`, `(GPT)`,
   `(Claude — chair)`. The user should always know which model said what.

## Give the panels enough context

A panel can only judge what it sees. For a code or design question, paste the **relevant
snippet, diff, or file** into the prompt — don't make it reason about code it can't read.
A `git diff` or the specific function usually beats a vague paraphrase.

- Keep it scoped: the changed function + its caller, not the whole repo.
- **Redaction still applies** — see Hard rules. Anything you paste leaves your machine.
  Strip secrets, keys, and private data before sending; abstract proprietary logic if you
  must include it.

## Two ways to run the panels

**Same prompt to both (default).** Identical wording to Gemini and GPT — cleanest way to
see genuine agreement vs. divergence on the same question.

**Different lens each (for hard, multi-faceted calls).** Instead of asking both the same
thing, give each panel the angle it's better at, so they cover more ground than two
identical passes:

- e.g. Gemini → *"focus on architecture, consistency, and maintainability"*
- e.g. GPT → *"focus on edge cases, failure modes, and concrete bugs"*

Then synthesize across the two lenses. Use this when one question has several independent
ways to be wrong — it beats redundancy. For a clean agree/disagree signal, stick with the
same-prompt default.

## Modes (prompt templates)

Pick the framing that fits the request:

- **review** — `"You are a strict reviewer. Review this code/diff/plan for bugs,
  edge cases, and design flaws. Be concise; list real problems with severity:\n\n<content>"`
- **challenge** — `"Critically stress-test this claim/approach. Give the sharpest
  counterpoints and hidden caveats. If it's sound, say so — but try to break it
  first:\n\n<claim>"`
- **consult** — pass the user's question through as-is for an open second opinion.

## Single-panel mode

When you only need one quick outside take instead of a full synthesis:

- Gemini only: `ask.sh gemini "..."`
- GPT only: `ask.sh gpt "..."`

GPT (codex) calls can be heavier/slower — prefer Gemini for cheap quick checks,
and convene the full council for decisions that actually matter.

## Hard rules

- **Never send sensitive data to a panel.** Anything you pass to `ask.sh` leaves
  your machine and goes to an external model. Do **not** send secrets, private
  keys, personal data, credentials, proprietary contracts, or confidential
  business info. The council is for **technical / logical / strategic reasoning**
  you'd be comfortable pasting into a third-party chat. When in doubt, redact or
  abstract before asking.
- **No bypassing, no scraping.** This skill only invokes official CLIs you have
  personally authenticated. It does not extract tokens, automate browsers, or
  circumvent any provider's limits. Each provider's quota and terms are yours to
  respect.
- **The chairman owns the verdict.** Panels advise; you decide. Don't hide behind
  "the models disagreed" — resolve it.

## Setup & troubleshooting

Run the doctor to see which panels are live:

```bash
<skill-dir>/bin/doctor.sh          # presence + version
<skill-dir>/bin/doctor.sh --smoke  # live 1-token round-trip to each panel
```

- Gemini not responding → run `gemini` once interactively to (re)authenticate.
- GPT not responding → run `codex login`.
- Different binary names/paths → set `COUNCIL_GEMINI_BIN` / `COUNCIL_GPT_BIN`.
