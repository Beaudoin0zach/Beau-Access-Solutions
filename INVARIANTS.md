# Platform invariants

Five rules that hold across every Beau Access Solutions app. They are enforced **by
construction** (tooling, repo boundaries, CI), not by discipline. They map onto each
app's own non-negotiables (e.g. CIT's privacy, deletion, i18n, and a11y gates) and
never relax them.

### 1. Layered sessions
The identity service proves *who you are* (short-lived OIDC token). Sensitive apps
**exchange** that token for their **own** short-lived, revocable, rate-limited
data-access session, and require **step-up re-auth** for sensitive actions. An
identity token is never itself a data-access credential — a stolen one cannot read an
app's sensitive data directly.
*Enforcement:* standalone minimal IdP; each sensitive app owns its session layer.

### 2. No platform tracking on sensitive pages
The shared `ui` package is telemetry-free and side-effect-free. Analytics is a
separate, opt-in package. An ESLint import-boundary rule makes importing analytics
into a PHI/sensitive route a **build failure**. Each app owns its own CSP — the
platform cannot inject a `script-src`.

### 3. Decoupled deletion / export
The identity service stores identity only, keyed by `sub`. Each app owns its data
lifecycle. Platform-account deletion emits a fan-out signal, but every app's delete
and export endpoints stay independently callable and complete. No app ever "asks
identity" for its users' data.

### 4. Contribution boundary
Sensitive backends stay in their **own repos** — trust boundary = repo boundary. They
are never pulled into the shared monorepo. PHI paths get CODEOWNERS + required review
+ branch protection. Shared `ui` / `auth` / `config` stay wide open to contributors.

### 5. i18n ownership
Shared `ui` components are content-agnostic — every user-facing string arrives via
props / i18n context, zero hardcoded copy (lint-enforced). String catalogs are
per-app owned; each app keeps its own human-review gate for translated languages
(e.g. CIT's fluent-Spanish-review requirement). The platform never injects strings.
