# Contributing to the BAS platform

This repo governs cross-cutting decisions. Most code lives in the individual app
repos; this repo is docs, decisions, and (eventually) shared config.

## Ground rules

- **Read [INVARIANTS.md](INVARIANTS.md) first.** They are non-negotiable and enforced
  by construction. A change that weakens one needs its own ADR arguing why.
- **Decisions are ADRs.** Anything expensive to reverse (identity, data model, auth,
  encryption, adding a third-party service) gets a record in [docs/adr/](docs/adr/).
  Short is fine: context, decision, consequences.
- **The PHI contribution boundary is real.** Sensitive backends (CIT, KindredAccess,
  Benefits Navigator) live in their own repos behind CODEOWNERS review. Outside
  contributors are welcome in the shared `ui` / `auth` / `config` packages and in
  docs; PHI-handling code paths require maintainer review and are not drive-by
  mergeable (invariant #4).

## Adding an app to the platform

1. It keeps its own repo and stack (no monorepo absorption).
2. Its backend becomes an OIDC **resource server**: validate a Keycloak identity
   token, then — if it holds sensitive data — exchange it for its own revocable
   session and enforce step-up (invariant #1).
3. It adopts the shared `ui` design system and its own string catalogs (invariant #5).
4. It publishes its own CSP and keeps analytics out of sensitive routes (invariant #2).
5. Its deletion/export stay independently complete (invariant #3).

## No committed cross-repo symlinks

Reference shared docs by **URL**, not by filesystem path or symlink. Committed
symlinks pointing across repos (or at absolute machine paths) dangle on clone and die
in CI. Local navigation symlinks under `repos/` are gitignored and machine-local only.
See [ADR-002](docs/adr/002-umbrella-org-and-repo-topology.md).
