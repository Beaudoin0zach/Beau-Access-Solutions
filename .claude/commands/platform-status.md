---
description: Read the real state of every platform app (git/PRs/deploys) and reconcile it against TRACKER.md
---

# Platform status — real state

Report the **actual** state of the platform by inspecting the repos directly,
then reconcile it against the hand-maintained `TRACKER.md` and surface drift.

## 1. Gather real state

Run the status script from the hub root:

```
scripts/platform-status.sh
```

This fetches each app repo under `repos/`, and for every app reports: current
branch (and whether it's pushed), ahead/behind `origin/main`, uncommitted
changes, last commit, open PRs (via `gh`), and a deploy health probe for the
known-live endpoints. Use `--no-net` for a fast offline pass, or `--json` if
you want to process the output.

Do not hand-type any of these facts — take them from the script output.

## 2. Reconcile against TRACKER.md

Read `TRACKER.md` (sections 1 "Portfolio & platform onboarding" and 2
"Deployment & hosting" especially) and compare its claims to the script's
real state. Flag every mismatch, e.g.:

- **Remote slug** differs (TRACKER's `CLAUDE.md pointer` / repo column vs the
  real `origin`).
- **PR status** — TRACKER says "PR not opened" but the script found an open PR
  (or vice-versa: TRACKER says a branch is ready but it isn't pushed).
- **Deploy status** — TRACKER's ✅/⬜ vs the actual HTTP health code.
- **Branch/onboarding** state that has clearly moved on since TRACKER's
  `Last updated` date.

## 3. Report

Present two short sections:

**Real state** — a compact per-app table (app · branch · pushed? · ahead/behind
· open PRs · deploy) straight from the script.

**Drift vs TRACKER.md** — a bullet per mismatch, each as
`<app>: TRACKER says X → actually Y`. If everything matches, say
"TRACKER.md is accurate."

## 4. Offer to reconcile

If there is drift, offer to update `TRACKER.md` to match reality (and bump its
`**Last updated:**` line). Only edit after the user confirms, or if they
invoked this with an explicit "and fix it" instruction — otherwise just report.
