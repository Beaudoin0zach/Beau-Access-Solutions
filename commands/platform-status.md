---
description: Read the real state of every Beau Access Solutions app (git/PRs/deploys) and reconcile it against the platform TRACKER.md
---

# Platform status — real state (Beau Access Solutions)

Report the **actual** state of the BAS platform by inspecting the repos
directly, then reconcile it against the hand-maintained tracker and surface
drift. This is BAS-specific and reads from the platform hub at
`~/projects/bas-platform` regardless of which directory you invoke it from.

## 1. Gather real state

Run the status script (absolute path — works from any cwd):

```
~/projects/bas-platform/scripts/platform-status.sh
```

It fetches each app repo under the hub's `repos/`, and for every app reports:
current branch (and whether it's pushed), ahead/behind `origin/main`,
uncommitted changes, last commit, open PRs across every remote (via `gh`), and
a deploy health probe for the known-live endpoints. Use `--no-net` for a fast
offline pass, or `--json` to process the output.

Do not hand-type any of these facts — take them from the script output. If the
hub isn't at `~/projects/bas-platform`, stop and say so rather than guessing.

## 2. Reconcile against TRACKER.md

Read `~/projects/bas-platform/TRACKER.md` (sections 1 "Portfolio & platform
onboarding", 2 "Deployment & hosting", and **2b "iOS / TestFlight"**) and compare
its claims to the script's real state. Flag every mismatch, e.g.:

- **Remote slug** differs (TRACKER's repo column vs the real remotes; note that
  some apps have >1 remote — an `origin` plus an old/canonical one).
- **PR status** — TRACKER says "PR not opened" but the script found an open PR,
  or says a branch is unmerged when it has landed on main (branch shows
  `0 ahead / N behind`).
- **Deploy status** — TRACKER's ✅/⬜ vs the actual HTTP health code (the script
  now probes CIT, Access Atlas, KindredAccess, Benefits Navigator, page-repair,
  and a Keycloak-prod infra line).
- **Mobile / TestFlight (§2b)** — the iOS apps aren't in `repos/`, so check them
  by hand against `~/projects/bas-platform/docs/mobile-and-testflight.md`:
  the two webview wrappers (Access Atlas, KindredAccess) reflect edits via **web
  deploy**, while **Baseline (CIT)** is a native Expo app needing `eas update` /
  `eas build`. Watch for mobile source repos (`bas-apps`, `kindredaccess-ios`,
  `bas-frontend`) that have **no git remote** — surface any that are unbacked.
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

If there is drift, offer to update `~/projects/bas-platform/TRACKER.md` to match
reality (and bump its `**Last updated:**` line). Only edit after the user
confirms, or if they invoked this with an explicit "and fix it" instruction —
otherwise just report.
