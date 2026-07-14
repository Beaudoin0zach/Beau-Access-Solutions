---
name: lesson
description: "Capture a transferable, cross-project lesson (a mistake and its fix) into the shared lessons file at ~/.claude/shared/LESSONS.md, which every project's CLAUDE.md imports. Trigger when the user says \"/lesson\", \"log this lesson\", \"capture this mistake so other projects learn from it\", \"add to the shared lessons\", or right after a bug/outage/mis-step whose fix would help in other projects. Do NOT use for project-specific facts (those go in that project's CLAUDE.md or memory) or for findings/leads (use /capture-findings)."
---

# Capture a Cross-Project Lesson

A mistake just got made and fixed. If the lesson **transfers to other projects**, record it
in the shared lessons file so it isn't repeated elsewhere.

The user's description of what happened: **$ARGUMENTS**
(If that's empty, infer the lesson from the current conversation — what broke and how it was
resolved — and confirm the wording with the user before writing.)

## Steps

1. **Decide whether it belongs here.** This file is for *transferable* lessons only —
   tooling, data-pipeline, ops/deploy, process/compliance. If the lesson is really a
   project-*specific* fact (one server's IP, one schema quirk, a single investigation's
   status), do **not** write it here — tell the user it belongs in that project's
   `CLAUDE.md` or per-directory memory instead, and stop. If it's an actionable
   finding/lead rather than a lesson, point them to `/capture-findings`.

2. **Read** `~/.claude/shared/LESSONS.md` and check for an existing entry covering the same
   lesson. If one exists, **update it** rather than adding a duplicate.

3. **Write the entry** under the best-fitting section heading (`Tooling & data pipelines`,
   `Ops & deploy`, or `Process, publication & compliance`; add a new heading only if none
   fit). Match the existing format exactly:

   `- **Lesson (imperative or claim).** What broke → the fix. (source-project, YYYY-MM-DD)`

   Keep it to 2–4 lines. Use today's date. Infer the source project from the working
   directory or the conversation. Be concrete about the *fix* — that's the part future
   sessions act on.

4. **Confirm** to the user: show the entry you added and which section it went under. Note
   that it now loads into every project session via the `@import`, and that the canonical
   file is the one to edit (never the per-project copies).

## Guardrails
- Edit only `~/.claude/shared/LESSONS.md`. Never edit the per-project `CLAUDE.md` import
  lines from this command.
- If the file has grown past ~1 screen of entries, mention that it's due for a prune.
