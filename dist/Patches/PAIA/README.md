# P.A.I.A patch for BeeingFemale NG

Adds the **Beeing Female** OAR submod that the base P.A.I.A (Pregnancy and
Inflation Animations) is missing. Mesh-only: one `config.json`, no ESP, no
animation files (it reuses P.A.I.A's shared `PAIA Idle` folder).

## Why

P.A.I.A's OAR set ships submods for Fertility Mode, Fill Her Up, and OCum —
each a condition set pointing at the shared `PAIA Idle` animations. The
author's own `Priority List OAR.txt` reserves **91044062 for Beeing Female**,
and the legacy DAR variant even ships a `_CustomConditions\91044062` folder
with `HasSpell("BeeingFemale.esm"|0x0028A0)` — but the OAR port never got the
matching submod, so BF pregnancies play no P.A.I.A idle.

## What it does

`Meshes\...\OpenAnimationReplacer\PAIA\Beeing Female\config.json`:

- priority `91044062` (the author's reserved Beeing Female slot)
- conditions mirror the Fertility Mode submod's structure (disabled
  player-only toggle, `IsFemale`, `NOT IsChild`)
- pregnancy detection: `FactionRank(BeeingFemale.esm:0x8448) >= 5` —
  BF NG's `ParentFaction` carries the cycle state ID, so `>= 5` means
  2nd trimester onward. Same convention as the P.A.I.A Expansion patch,
  and semantically equivalent to the Fertility Mode submod's ">= 33%"
  band.

Install over P.A.I.A (SE / OAR variant). Without P.A.I.A installed the
submod is inert (the shared `PAIA Idle` folder it points at does not
exist).
