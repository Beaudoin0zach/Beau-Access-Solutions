# ADR-002: BAS umbrella, repo topology, and no committed cross-repo symlinks

**Status:** Accepted
**Date:** 2026-07-07
**Deciders:** Beau Access Solutions LLC
**Related:** [PLATFORM.md](../../PLATFORM.md), [ADR-001](001-platform-architecture-and-identity.md)

## Context

Beau Access Solutions LLC owns a growing portfolio of accessibility apps (CIT,
KindredAccess, Benefits Navigator, Access Atlas, a11y-probe, page-repair) plus the
marketing site. Cross-cutting decisions (identity, invariants, contribution rules)
were living buried in the CIT repo at a machine-specific absolute path, and app repos
referenced them fragilely. We needed a single owner for overarching decisions without
collapsing the apps into one repo — which would violate the repo-boundary invariant
(ADR-001 / invariant #4).

A separate question came up during setup: should shared docs be wired across repos
with **symlinks** so nothing breaks when files move?

## Decision

### 1. The umbrella is a governance *org*, not a mono-repo
"Own the decisions and house everything" resolves to: BAS owns the decisions and
**contains many separate repos**, not one repo containing all code. Sensitive backends
stay sovereign in their own repos (trust boundary = repo boundary). This governance
repo (`Beaudoin0zach/Beau-Access-Solutions`, local dir `bas-platform/`) holds only the
cross-cutting docs/decisions and, later, shared low-sensitivity config.

### 2. The marketing site stays a separate repo
beauaccesssolutions.com (Astro + Netlify) has a different audience and deploy surface
from internal architecture/PHI-governance docs. It is not folded into this repo.

### 3. Reference shared docs by URL; no committed cross-repo symlinks
App repos point at governance docs by **GitHub URL**, with the five invariants inlined
as a local fallback and a redirect stub left where a doc used to live. Committed
symlinks are rejected because git stores a symlink as its target path, not content: an
absolute-path or cross-repo symlink **dangles on clone** (breaking it for
contributors) and **dies in CI/containers** where the path doesn't exist — the exact
breakage they were meant to prevent, plus it re-couples repos at the filesystem level.
Shared *code* will be shared via pnpm workspaces / published packages (worst case a
submodule), never hand-committed symlinks.

### 4. Local navigation symlinks are allowed, gitignored
A `repos/` directory of symlinks to each property is kept for local convenience only.
It is gitignored — machine-local, never committed, never reaches CI, cannot dangle.

## Consequences

- One canonical, stable home for decisions; app pointers use durable URLs.
- Apps and sensitive backends stay isolated in their own repos with their own review gates.
- No fragile filesystem coupling; nothing breaks on clone or in CI.
- Cost: shared code needs real dependency mechanisms (workspaces/packages), which is
  the correct tradeoff over symlink shortcuts.

**Follow-ups**
- Push this repo to its GitHub remote so the URL pointers resolve.
- When shared packages land, set up the pnpm/Turborepo workspace in the design-system repo.
