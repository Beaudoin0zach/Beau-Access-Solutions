# ADR-001: Shared platform architecture & standalone Keycloak identity

**Status:** Accepted
**Date:** 2026-07-07
**Deciders:** Beau Access Solutions LLC
**Related:** [PLATFORM.md](../../PLATFORM.md), [ADR-002](002-umbrella-org-and-repo-topology.md)

> Relocated from the Chronic Illness Tracker repo (where it was drafted as CIT
> ADR-004) to its canonical home in the platform governance repo. CIT keeps a pointer.

## Context

The portfolio's apps are becoming a shared platform. They **share accounts and
identity**, **run on mixed backends** (CIT = Next.js, KindredAccess = Django, future
apps = various), and are **community-developed** over time. At least three tenants
handle sensitive data (CIT = PHI health data; KindredAccess = private social data;
Benefits Navigator = veteran data), so identity must not weaken any app's privacy,
deletion, or accessibility non-negotiables.

Shared identity across heterogeneous backends has essentially one correct pattern: a
standards-based **OIDC/OAuth2** identity provider (IdP) that issues tokens every app's
backend validates independently of its stack. The open questions were **where the IdP
lives** and **what it runs on**.

## Decision

### 1. Identity is a standalone service, not hosted inside any app
An earlier proposal hosted the IdP inside KindredAccess's Django and extracted it
later. **Rejected.** Once an app's backend mints the token that unlocks health data, a
compromise of that app's much larger attack surface becomes a compromise of
health-data authentication. That blast radius is unacceptable for a PHI tenant. The
IdP is its own isolated, minimal, hardened service from day one — own database, own
deployment, decoupled from any app's uptime or churn.

### 2. Layered sessions — federate authentication, never surrender the sensitive-data session
The IdP proves *who you are* (short-lived OIDC token). Sensitive apps exchange that
token for their **own** short-lived, revocable, rate-limited data-access session, and
require **step-up re-auth** for sensitive actions. A stolen identity token therefore
cannot access an app's sensitive data directly. Platform invariant, not a per-app choice.

### 3. Self-hosted, not managed
A shared IdP records which OAuth clients a user authorized — i.e. that an account holds
a grant for the chronic-illness app, which is health-revealing. A managed IdP
(Auth0/Okta/Cognito) would sit in that sensitive path and require a BAA on an
enterprise tier, putting a third party in the auth path against the isolation
principle. Self-hosting keeps no third party in the auth path.

### 4. Keycloak
Among self-hosted OIDC-certified options:
- **Keycloak (chosen)** — boring, proven, hire-able. Batteries-included user store,
  2FA (TOTP/WebAuthn), and step-up (ACR/LoA), so security-critical flows are
  battle-tested rather than hand-rolled.
- **Zitadel (runner-up)** — leaner modern Go IdP, first-class step-up, smaller surface;
  rejected only for a smaller community/hiring pool.
- **Ory Hydra** — minimal certified issuer; rejected for v1 as the largest day-one
  build (needs a paired user-management service; you build the login UI).
- **Managed + BAA** — rejected per §3.

## Consequences

**Positive**
- Health-data authentication is isolated from every app's attack surface.
- A stolen identity token cannot directly access sensitive data (layered sessions + step-up).
- No third party in the auth path; consistent with privacy non-negotiables.
- 2FA and step-up come from a proven implementation, not hand-rolled code.
- CIT's migration surface is tiny: `requireAuth()` (`src/lib/auth/api.ts`) is the single
  swap point; the 30+ route handlers are untouched.

**Negative / costs accepted**
- Keycloak is a heavier self-hosted service: patching, admin-console hardening, uptime
  are ongoing owner responsibilities in the auth path.
- Keycloak's login theme must be re-themed to pass each app's a11y bar.
- Running a standalone IdP before app #2 exists is up-front cost justified by the PHI
  blast-radius argument, not immediate multi-app need.

**Follow-ups**
- Define OIDC clients/scopes and the step-up (ACR) policy (PLATFORM.md Phase 1).
- Swap CIT `requireAuth()` to token-exchange + own session (CIT `docs/mobile/auth-token-exchange.md`).
- Keycloak hardening checklist + login-theme a11y audit as their own tracked tasks.
