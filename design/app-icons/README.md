# App icon family (v4 — approved 2026-07-18)

Master SVGs (1024×1024) for the five iOS apps. Shared system: deep per-app hue,
cream `#F5F1E8` glyph, gold `#E8B44A` accent. All pairs verified ≥4.5:1 (glyph)
/ ≥3:1 (accent) numerically — see the contrast check in the 2026-07-18 session.

| File | App | Concept |
|---|---|---|
| `access-atlas.svg` | Access Atlas | the app's own favicon mark (compass star + faint ring), scaled |
| `benefit-navigator.svg` | Benefit Navigator | M1 service helmet, side profile, gold star |
| `kindredaccess.svg` | KindredAccess | two cupped hands lifting a heart |
| `disability-wiki.svg` | Disability Wiki | DW letterforms filled with the muted Disability Pride flag |
| `baseline.svg` | Baseline (CIT) | B° on its baseline — "your baseline vitals" |

**Rasterize** (macOS): `qlmanage -t -s 1024 -o . <file>.svg` → drop the PNG into the
app's `AppIcon.appiconset`. Note the two `<text>` icons (DW, Baseline) render with
Avenir Next — rasterize on a Mac, don't ship the raw SVG through a non-macOS pipeline.

**Not yet wired into any app** — icon changes are native-shell changes: update the
asset catalog, bump the build, re-archive (runbook in docs/mobile-and-testflight.md).

Design decisions of note: BN deliberately not a shield/bell (user direction:
realistic helmet); KA went through broken-heart and handset-hook mis-reads before
the crescent hands; DW letters replaced a plain flag band (user: standout type).
