---
name: prune-lessons
description: Prune and consolidate the shared lessons files (~/.claude/shared/LESSONS.md and ~/projects/bas-platform/LESSONS.md) when they grow past their budget — graduate entries whose fixes are now enforced by tests/CI/skills, compress verbose war stories, merge duplicates, relocate project-specific facts, and archive everything removed. Trigger when the user says "prune the lessons", "the lessons file is too long", "clean up LESSONS.md", "graduation pass", "consolidate the lessons", or when a capture pass flags that a file has grown past ~1 screen of entries.
---

# Prune Lessons

The lessons files are `@import`ed into every session's context — every entry taxes
every future session, and attention dilutes as the files grow. Ten sharp lessons
change behavior; a hundred get skimmed. This skill keeps them sharp by removing
weight without destroying knowledge.

## The graduation principle

Prose is the *weakest* form of institutional memory; tests, CI checks, lint rules,
skills, and templates are the strong forms. A lesson whose fix is now *enforced*
somewhere no longer needs its full war story in every session — the mistake became
impossible rather than remembered. Graduation is the preferred prune: the entry
shrinks to a one-liner pointing at the enforcement, or disappears entirely.

## Classify every entry

Read both files, then place each entry in exactly one bucket:

1. **GRADUATED** — the fix is enforced by a test, CI check, lint rule, skill, or
   template. *Verify before claiming this:* grep the repo the entry cites for the
   named test/check; an entry's own "→ add a CI check" suggestion is an aspiration,
   not enforcement, until the check exists. Graduated entries compress to 1–2 lines
   with a pointer (e.g., "enforced by `core/tests/test_safety.py::SafetyGateFailClosedTest`").
2. **STALE** — no longer true (config landed, decision reversed, date passed).
   Delete, after confirming against current reality — an entry with an expiry
   (e.g., a recusal window) stays until the date actually passes.
3. **MISFILED** — actually a single-project fact. Move it to that project's
   CLAUDE.md (only if the repo is reachable; otherwise compress in place and flag).
4. **DUPLICATE / OVERLAPPING** — same failure mode as another entry, possibly
   across the two files. Merge into the sharper one; if it lives in both the
   machine-wide and BAS files, keep the version at the widest applicable scope
   and shorten the other to a cross-reference.
5. **VERBOSE** — right lesson, too much war story. Keep the failure mode and the
   fix; cut narrative detail that doesn't change what a future session does.
   Target 2–4 lines.
6. **ACTIVE** — earning its keep as-is. Leave untouched. Entries dated within the
   last ~2 weeks default to ACTIVE — they haven't had a chance to graduate yet.

## Guardrails

- **Archive first, always.** `~/.claude/shared/LESSONS.md` is not version-controlled.
  Before writing anything, copy every entry you will remove or compress verbatim into
  `~/.claude/shared/LESSONS-archive.md` (create with a header if missing), under a
  dated section. Pruning relocates knowledge; it never destroys it.
- **Verify enforcement claims in the repo, not from the entry's text.** If you can't
  reach the cited repo, the entry cannot GRADUATE — at most compress it (VERBOSE).
- **Never weaken the fix.** Compression cuts narrative, not remedy. If shortening
  would lose the actionable part, the entry wasn't VERBOSE.
- **Don't prune to zero.** Some lessons (methodology, judgment calls, process rules)
  have no possible enforcement and stay prose forever. That's fine — they're exactly
  what the file is for.
- **Keep the entry format** (`- **Lesson.** what → fix. (source, date)`) so
  `/lesson` and `/capture-review-lessons` continue to match it.

## Report

Show the user: per-bucket counts, each graduated/moved/merged entry with its
destination, before/after line counts per file, and anything you *wanted* to
graduate but couldn't verify (with what enforcement would unlock it). If the
file is still over budget after the pass, say which ACTIVE entries are the next
candidates and what enforcement would let them graduate.
