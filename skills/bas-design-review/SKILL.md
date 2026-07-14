---
name: bas-design-review
description: Review a UI component, screen, or diff against the Beau Access Solutions design + accessibility standard (bas-platform/docs/design-principles.md). Trigger when working in any BAS app repo (KindredAccess, VA Benefits Navigator, Access Atlas, page-repair, CIT) and the user says "design review", "review this component/screen for UX/a11y", "check this against the design principles", "does this pass our a11y bar", "review the login/chat/empty state", or before merging a UI PR. Focuses on the dynamic-status accessibility spine (typing/send/presence/connectivity), touch targets, reduced-motion, contrast in both themes, and empty/error states. Not for backend, data, or non-UI diffs.
---

# BAS Design Review

Review UI work against the portfolio's shared UX/interaction standard. The source of truth is
`~/projects/bas-platform/docs/design-principles.md` (read it if present; the checklist below is
the offline copy). The platform's ethos: **highest a11y bar forges the best design system** —
review to that bar, not "good enough."

## How to run a review

1. **Scope it.** Identify what changed — a component, a screen, or a diff (`git diff`). If it's
   not UI (backend, data, config), say so and stop; this skill doesn't apply.
2. **Know the app.** The four interaction sections weight differently per app:
   - **KindredAccess** (chat) — send state machine, typing/presence, the a11y spine.
   - **Benefits Navigator** (AI) — streaming/interruptible responses, starter-prompt empty state, uncertainty framing.
   - **Access Atlas** (zero-JS directory) — resilient no-JS navigation, search empty-results, account-free browsing / contribution-only login. Send/typing/presence do NOT apply.
   - **page-repair** (extension) — non-intrusive overlay, injection safety, never fight host-page focus/paste.
   - **CIT** (health tracker) — forms, PHI, the reference a11y bar.
3. **Walk the checklist** below against the change. For each item: pass / fail / N-A, with the
   specific file:line and a concrete fix for every fail.
4. **Report** most-severe first. Lead with anything in the **accessibility spine** — those are the
   findings that fail WCAG 2.2 AA and block the a11y gate.

## The checklist

**Navigation & input**
- Back/escape works on every screen; browser-back preserves place (web).
- Inputs: correct keyboard (`inputmode`/`type`), autofill tokens, paste allowed, 16px+ font,
  validate on blur/submit (not mid-first-entry).

**Feedback & targets**
- Every async action has loading / empty / error / success states.
- Touch targets ≥ 44/48px hit area (WCAG floor 24px, SC 2.5.8); ~8px between; primary action in thumb zone.

**Motion & delight**
- Animations < 300ms **and** have a `prefers-reduced-motion` path (this is a gate, not a nicety).
- Delight is purposeful and non-repeating — flag decoration-only motion.

**Accessibility spine (highest priority — dynamic status)**
- Typing / send-status / presence / connectivity conveyed as **text or shape, never color or animation alone** (SC 1.4.1, 4.1.3).
- Status routed through the shared `aria-live` utility: failures `role="alert"` (assertive), the
  rest `aria-live="polite"`, **announcements debounced** (no re-reading "typing…" per keystroke).
- Contrast ≥ 4.5:1 text / 3:1 large & UI components — **verified in both light and dark themes**.
- Visible focus everywhere (SC 2.4.11, 2.4.13); no cognitive auth puzzle (SC 3.3.8).
- OTP is a single labeled field, not 6 unlabeled boxes.

**Send / empty / error**
- Optimistic send with explicit `queued → sending → sent → delivered → read → failed`; failed
  messages persist with inline retry; offline queues and flushes on reconnect.
- Empty states coach (explain + one CTA, or 3–4 starter chips on first run) — never a blank void.
- Errors are plain-language, blame-free, paired with a recovery action, and preserve user input.

## Output format

A short report: **Blocking** (a11y-spine / WCAG failures), **Should-fix** (fundamentals), **Polish**
(delight). Each finding: `file:line` → what's wrong → the fix. If a whole section is N-A for the app,
say so once rather than marking every line. End with a one-line verdict: does this pass the a11y bar?
