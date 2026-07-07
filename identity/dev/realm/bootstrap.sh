#!/usr/bin/env bash
# Realm-as-code (reference bootstrap) for the platform Keycloak.
#
# Creates the `bas` realm and the `cit-web` client with the settings CIT's
# /api/auth/session endpoint expects: Authorization-Code + PKCE (S256), a
# PAIRWISE `sub` (BAS ADR-003), and audience/azp scoped to the client so a token
# minted for a sibling app is rejected.
#
# This is a REFERENCE script — kcadm syntax and mapper names are version-specific.
# Validate against the pinned Keycloak (identity/dev/docker-compose.yml, 26.x),
# then EXPORT the resulting realm to identity/dev/realm/bas-realm.json — the export
# is the authoritative artifact (--import-realm loads it). See ../README.md.
#
# Usage (against the local dev Keycloak):
#   docker compose -f identity/dev/docker-compose.yml exec keycloak \
#     bash /opt/keycloak/data/import/realm/bootstrap.sh
set -euo pipefail

KC=/opt/keycloak/bin/kcadm.sh
REALM="${REALM:-bas}"
CIT_REDIRECT_WEB="${CIT_REDIRECT_WEB:-http://localhost:3000/api/auth/session*}"
CIT_REDIRECT_NATIVE="${CIT_REDIRECT_NATIVE:-com.beauaccesssolutions.cit://oauth*}" # Expo AppAuth scheme
ACCESS_TOKEN_LIFESPAN="${ACCESS_TOKEN_LIFESPAN:-300}"  # 5 min — short-lived identity token

# 1. Authenticate (dev creds; prod uses a locked-down admin — hardening §2).
"$KC" config credentials --server http://localhost:8080 --realm master \
  --user "${KC_ADMIN:-admin}" --password "${KC_ADMIN_PASSWORD:-admin}"

# 2. Realm.
"$KC" create realms -s realm="$REALM" -s enabled=true \
  -s accessTokenLifespan="$ACCESS_TOKEN_LIFESPAN" \
  -s sslRequired=external || echo "realm may already exist"

# 3. cit-web client: public, PKCE, standard flow only.
CID=$("$KC" create clients -r "$REALM" \
  -s clientId=cit-web \
  -s publicClient=true \
  -s standardFlowEnabled=true \
  -s implicitFlowEnabled=false \
  -s directAccessGrantsEnabled=false \
  -s 'attributes."pkce.code.challenge.method"=S256' \
  -s "redirectUris=[\"$CIT_REDIRECT_WEB\",\"$CIT_REDIRECT_NATIVE\"]" \
  -i)
echo "created cit-web client: $CID"

# 4. Pairwise `sub` (ADR-003): the same user gets a different, stable sub per app,
#    so CIT's sub never correlates with KindredAccess / Benefits Navigator.
"$KC" create "clients/$CID/protocol-mappers/models" -r "$REALM" \
  -s name=pairwise-sub \
  -s protocol=openid-connect \
  -s protocolMapper=oidc-sub-mapper \
  -s 'config."pairwise.sub.algorithm.salt"=' \
  || echo "NOTE: verify the pairwise sub mapper name for your KC version (oidc-sub-mapper / oidc-pairwise-subject-mapper)"

# 5. Audience: ensure aud includes cit-web so CIT's verifier can enforce it.
"$KC" create "clients/$CID/protocol-mappers/models" -r "$REALM" \
  -s name=cit-web-audience \
  -s protocol=openid-connect \
  -s protocolMapper=oidc-audience-mapper \
  -s 'config."included.client.audience"=cit-web' \
  -s 'config."access.token.claim"=true' \
  || echo "audience mapper may already exist"

cat <<EOF

Done (reference run). Next:
  - Enable 2FA/step-up + apply the accessible login theme (hardening §5, §6).
  - Add a test user with a verified email.
  - Export the realm and commit it as the authoritative config:
      $KC get realms/$REALM -r $REALM > /opt/keycloak/data/import/realm/bas-realm.json
  - Set CIT env: KEYCLOAK_ISSUER=<issuer>/realms/$REALM, KEYCLOAK_CLIENT_ID=cit-web
EOF
