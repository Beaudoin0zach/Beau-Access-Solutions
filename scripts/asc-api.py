#!/usr/bin/env python3
"""Minimal App Store Connect API client (key 3SAY53224G)."""
import json, sys, time, urllib.request, os
import jwt

KEY_ID = "3SAY53224G"
ISSUER = "bfba81e4-6894-4349-b26b-482a2c7bc75a"
KEY_PATH = os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_3SAY53224G.p8")
BASE = "https://api.appstoreconnect.apple.com"

def token():
    with open(KEY_PATH) as f:
        key = f.read()
    now = int(time.time())
    return jwt.encode({"iss": ISSUER, "iat": now, "exp": now + 900, "aud": "appstoreconnect-v1"},
                      key, algorithm="ES256", headers={"kid": KEY_ID, "typ": "JWT"})

def req(path, method="GET", body=None):
    r = urllib.request.Request(BASE + path, method=method)
    r.add_header("Authorization", f"Bearer {token()}")
    r.add_header("Content-Type", "application/json")
    data = json.dumps(body).encode() if body else None
    try:
        with urllib.request.urlopen(r, data=data) as resp:
            raw = resp.read()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        print(f"HTTP {e.code} on {method} {path}: {e.read().decode()[:400]}", file=sys.stderr)
        return None
