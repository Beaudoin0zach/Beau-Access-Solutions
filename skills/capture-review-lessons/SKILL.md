---
name: capture-review-lessons
description: Sweep a completed peer review, code review, security/accessibility audit, or remediation effort and record its transferable lessons into the three-tier lessons system (machine-wide shared file, BAS-platform file, or project memory). Trigger when the user says "capture review lessons", "document the lessons from this review", "what should other projects learn from this", "update the lessons files", "log what we learned", or after any multi-finding review/audit/remediation wraps up in any repo. Use this for sweeping a whole body of review work; for capturing ONE ad-hoc lesson, /lesson is the lighter tool.
---

# Capture Review Lessons

After a review or remediation, the findings scroll away — but the *failure modes* behind
them will recur in other projects unless recorded where future sessions load them. This
skill sweeps a completed review and files each lesson in the right tier.

## The three tiers

1. `~/.claude/shared/LESSONS.md` — **machine-wide**, transferable lessons only
   (tooling, data pipelines, ops/deploy, process). Imported by every project's CLAUDE.md.
2. `~/projects/bas-platform/LESSONS.md` — lessons that transfer **between Beau Access
   Solutions apps** but nowhere else (Keycloak/OIDC gotchas, shared-UI and cross-app
   safety conventions, mobile-wrapper patterns). Only BAS app repos import this.
3. The current project's own `CLAUDE.md` / memory — single-project facts.

The tier question for each lesson: *"would another project make this same mistake?"*
Yes, any project → tier 1. Only another BAS app → tier 2. Only this codebase → tier 3,
or skip entirely if the fix's tests now make the mistake impossible to repeat.

## Steps

1. **Find the review material.** Look for review/audit reports and remediation docs in
   the repo root (`PEER_REVIEW*.md`, `*AUDIT*.md`, `REMEDIATION*.md`), and scan recent
   history — `git log --oneline -30` — for `fix:`/`security:`/`a11y:`-type commits.
   If the review happened in the current conversation, use that directly.

2. **Read both shared files first** and check for entries covering the same ground.
   Update or strengthen an existing entry rather than adding a near-duplicate — two
   slightly different versions of one lesson are worse than either alone.

3. **Extract and classify.** From findings that were real and fixed, distill the
   failure mode + remedy, and assign a tier. Quality bar: a lesson is a *transferable
   failure mode with its fix*, not a changelog line. "Fixed the login bug" is not a
   lesson; "a security feature isn't done until its enforcement point is
   negative-tested" is. Aim for the 2–5 strongest lessons, not exhaustive coverage —
   these files load into every session, so every weak entry taxes all future work.

4. **Write the entries** under the best-fitting section heading, matching the existing
   format exactly:

   `- **Lesson (imperative or claim).** What broke → the fix. (source-project, YYYY-MM-DD)`

   Keep each entry 2–4 lines. Be concrete about the *fix* — that's the part future
   sessions act on. Use today's date; infer source-project from the working directory.

5. **Check the imports.** If this repo's CLAUDE.md doesn't import the lessons files,
   append at the end (BAS apps get both lines; non-BAS repos only the first):

   ```
   ---
   <!-- Shared cross-project lessons. Edit the canonical file, not here. -->
   @~/.claude/shared/LESSONS.md
   <!-- BAS-platform-only lessons. Canonical file lives in bas-platform. -->
   @~/projects/bas-platform/LESSONS.md
   ```

   BAS apps as of 2026-07: chronic-illness-tracker (CIT), kindredaccess,
   access-directory, benefits-navigator, a11y-probe, marketing-site, page-repair,
   and bas-platform itself (see `~/projects/bas-platform/repos/`).

6. **Report.** Show the user each entry added or updated and which file/section it
   went into, plus anything classified as tier 3 and where it was put. If a shared
   file has grown past roughly one screen of entries, flag that it's due for a prune.

## Guardrails

- Edit only the canonical files — never a per-project copy of an imported file.
- Don't file actionable findings/leads here; that's `/capture-findings` territory.
  Don't file one-off lessons mid-task; that's `/lesson`.
- Recording zero lessons is a valid outcome — say so rather than padding.

## Example

Input finding: "2FA enrollment UI shipped, but login was a stock LoginView that never
checked devices; rate-limit path list named routes that don't exist."

Output entry (tier 1, under *Ops & deploy*):

`- **A security feature isn't done until its enforcement point is wired and
negative-tested.** 2FA enrollment shipped and told users they were protected — but
login never checked devices; likewise the rate limiter's STRICT_PATHS named routes
that didn't exist. → For every protection, write the negative test ("password alone
must NOT authenticate"; "every protected path resolves") — green tests on the
feature's own pages prove nothing about enforcement. (kindredaccess, 2026-07-13)`
