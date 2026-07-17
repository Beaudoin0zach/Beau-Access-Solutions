#!/usr/bin/env bash
# Targeted, re-runnable creation of the `benefits-navigator-web` client on the
# LIVE `bas` realm — WITHOUT re-running the full bootstrap.
#
# Why a per-client script: identity/dev/realm/bootstrap.sh builds the whole realm
# and is NOT idempotent against a live realm (it `create`s the realm + every
# client and would error / duplicate on a second run). Benefits Navigator is the
# last app onto the IdP, so its client must be added to an already-populated
# prod realm in isolation. This mirrors how the BN block in bootstrap.sh creates
# the client (confidential + PKCE, pairwise sub, audience), but standalone and
# safe to run against production.
#
# Benefits Navigator uses django-allauth's `openid_connect` provider, so the
# redirect URI is allauth's callback:
#   https://<bn-host>/accounts/oidc/keycloak/login/callback/
# (provider_id `keycloak` — see benefits_navigator/oidc_config.py in the BN repo
#  and docs/deploy/benefits-navigator-oidc-integration.md).
#
# Usage (ON the Keycloak host, after copying secrets.env there):
#   set -a; . secrets.env; set +a          # BN_PAIRWISE_SALT, BN_CLIENT_SECRET
#   KC_ADMIN=<admin> KC_ADMIN_PASSWORD=<pw> \
#   BN_REDIRECT_WEB='https://vabenefitsnavigator.org/accounts/oidc/keycloak/login/callback/' \
#     bash create-benefits-navigator-client.sh
#
# ⚠️ Confirm the CANONICAL prod domain before running — the redirect URI must
#    match BN's deployed host exactly (vabenefitsnavigator.org is the assumed
#    canonical per the scope doc; verify against BN's DigitalOcean app).
set -euo pipefail

KC="${KC:-/opt/keycloak/bin/kcadm.sh}"
REALM="${REALM:-bas}"
CLIENT_ID="benefits-navigator-web"

BN_REDIRECT_WEB="${BN_REDIRECT_WEB:-}"
if [[ -z "$BN_REDIRECT_WEB" ]]; then
  echo "ERROR: BN_REDIRECT_WEB is required (the allauth callback URL)." >&2
  echo "  e.g. https://vabenefitsnavigator.org/accounts/oidc/keycloak/login/callback/" >&2
  exit 1
fi
BN_POST_LOGOUT="${BN_POST_LOGOUT:-${BN_REDIRECT_WEB%/*}/*}"

# Pairwise-sub salt (ADR-003) MUST be the stable prod value from secrets.env.
# A single-host redirect (one HTTPS callback) means NO Sector Identifier URI is
# needed here — unlike cit-web, whose multi-host redirects require one.
if [[ -z "${BN_PAIRWISE_SALT:-}" ]]; then
  echo "ERROR: BN_PAIRWISE_SALT is unset — source secrets.env first (ADR-003:" >&2
  echo "       the salt must be the STABLE prod value, never a dev placeholder)." >&2
  exit 1
fi
if [[ -z "${BN_CLIENT_SECRET:-}" ]]; then
  echo "ERROR: BN_CLIENT_SECRET is unset — source secrets.env first." >&2
  exit 1
fi

# Authenticate (prod uses a locked-down admin — see keycloak hardening §2).
"$KC" config credentials --server "${KC_SERVER:-http://localhost:8080}" --realm master \
  --user "${KC_ADMIN:-admin}" --password "${KC_ADMIN_PASSWORD:?set KC_ADMIN_PASSWORD}"

# Idempotency: never create a second client with the same clientId. If it already
# exists, reuse it and just re-assert the secret + mappers below.
BN_CID=$("$KC" get clients -r "$REALM" -q clientId="$CLIENT_ID" --fields id --format csv --noquotes || true)
if [[ -n "$BN_CID" ]]; then
  echo "NOTE: $CLIENT_ID already exists ($BN_CID) — re-asserting secret + mappers, not recreating."
else
  BN_CID=$("$KC" create clients -r "$REALM" \
    -s clientId="$CLIENT_ID" \
    -s publicClient=false \
    -s standardFlowEnabled=true \
    -s implicitFlowEnabled=false \
    -s directAccessGrantsEnabled=false \
    -s 'attributes."pkce.code.challenge.method"=S256' \
    -s "redirectUris=[\"$BN_REDIRECT_WEB\"]" \
    -s "attributes.\"post.logout.redirect.uris\"=$BN_POST_LOGOUT" \
    -i)
  echo "created $CLIENT_ID client: $BN_CID"
fi

# Client secret — set from BN_CLIENT_SECRET so the value is known + reproducible
# (this is BN's OIDC_RP_CLIENT_SECRET).
"$KC" update "clients/$BN_CID" -r "$REALM" -s "secret=$BN_CLIENT_SECRET" \
  && echo "set $CLIENT_ID secret from BN_CLIENT_SECRET"

# Pairwise `sub` (ADR-003): BN's sub never correlates with the other apps'.
"$KC" create "clients/$BN_CID/protocol-mappers/models" -r "$REALM" \
  -s name=pairwise-subject \
  -s protocol=openid-connect \
  -s protocolMapper=oidc-sha256-pairwise-sub-mapper \
  -s "config.\"pairwiseSubAlgorithmSalt\"=$BN_PAIRWISE_SALT" \
  -s 'config."id.token.claim"=true' \
  -s 'config."access.token.claim"=true' \
  || echo "pairwise mapper may already exist"

# Audience: ensure aud/azp includes benefits-navigator-web so a token minted for a
# sibling app is rejected if BN adds strict aud enforcement.
"$KC" create "clients/$BN_CID/protocol-mappers/models" -r "$REALM" \
  -s name="${CLIENT_ID}-audience" \
  -s protocol=openid-connect \
  -s protocolMapper=oidc-audience-mapper \
  -s "config.\"included.client.audience\"=$CLIENT_ID" \
  -s 'config."access.token.claim"=true' \
  || echo "audience mapper may already exist"

# -----------------------------------------------------------------------------
# GUARD (ADR-003): the client MUST carry a pairwise-sub mapper, or its `sub` is
# the raw, correlatable user id — a platform-invariant breach. Single-host
# redirect means no sector-URI failure mode, so a missing mapper here is fatal.
# -----------------------------------------------------------------------------
if "$KC" get "clients/$BN_CID/protocol-mappers/models" -r "$REALM" --fields protocolMapper 2>/dev/null \
     | grep -q oidc-sha256-pairwise-sub-mapper; then
  echo "OK: $CLIENT_ID has a pairwise-sub mapper (ADR-003)"
else
  echo "FATAL: $CLIENT_ID is MISSING its pairwise-sub mapper — ADR-003 breach." >&2
  exit 1
fi

cat <<EOF

Done. Set these on BN's DigitalOcean app, then redeploy:
  KEYCLOAK_ISSUER=https://id.beauaccesssolutions.com/realms/$REALM
  OIDC_RP_CLIENT_ID=$CLIENT_ID
  OIDC_RP_CLIENT_SECRET=<BN_CLIENT_SECRET>   # the value just set above

Verify: https://<bn-host>/accounts/oidc/keycloak/login/ 302s to the issuer with
client_id=$CLIENT_ID (PKCE), Keycloak renders login, the round-trip lands
authenticated, and a same-verified-email SSO user links to (not duplicates) the
existing local account.
EOF
