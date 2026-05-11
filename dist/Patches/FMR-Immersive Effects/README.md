# FMR-Immersive Effects patch for BeeingFemale NG

Drops the hard `Fertility Mode.esm` master from FMR-IE and reroutes its
overlays / random pregnancy effects so they fire from BeeingFemale NG state.
**No BF NG core changes.** This patch is self-contained.

## Design

FMR-IE was written against Fertility Mode Redux (FMR). Its ESP has
`Fertility Mode.esm` as a hard master, and its bridge script
(`_FME_FMRBridge`) listens for the `FMR_ActorStatus` mod event with a
0..115 pregnancy rank that FMR pushes every poll. Without FMR loaded,
FMR-IE refuses to load.

BF NG already exposes a tracking faction (`ParentFaction`, FormID
`0x008448` in `BeeingFemale.esm`, public API per the BF NG README) and
`FWController.UpdateParentFaction()` writes the cycle state ID to that
actor's rank on every tick. Its rank scale is `-2..7` (state IDs), which
is **not** compatible with FMR-IE's 0..115 percentage band scale — so
this patch does **not** ask FMR-IE's scripts to read pregnancy progress
from a faction at all. Instead:

- The replacement `_FME_FMRBridge.psc` polls `FW.SavedNPCs` every
  ~1.5 game-hours and on `BeeingFemaleConception` / `BeeingFemaleLabor`
  / `BeeingFemale` state-change events. For each tracked actor it
  computes the FMR-compatible 0..115 rank from BF state
  (`FW.CurrentState` + `FW.StateEnterTime` + `FWSystem.getStateDuration`)
  and writes it to **`StorageUtil.SetIntValue(actor, "FME.Rank", rank)`**.
- The patched FMR-IE scripts (`_FME_SC_Overlays`, `_FME_SC_RandEffChooser`)
  read `FME.Rank` from StorageUtil in place of their original
  `actor.GetFactionRank(GenericFaction)` calls. Trimester banding,
  overlay alpha curves, and recovery fade-out math are untouched —
  they see the same 0..115 scale they always did.
- `_FME_SC_3TBH` declares `GenericFaction` but never reads it; its source
  is unchanged.
- The bridge also re-emits `FMR_ActorStatus`, `FMR_BabyDamage`,
  `FMR_BabyDeath`, `FMR_BabyMiscarriage` mod events sourced from BF
  events, so any third-party listener that consumed the original FMR
  events still gets fed.

The `GenericFaction` VMAD property on the three MGEFs is repointed to
`BeeingFemale.esm:ParentFaction` purely so xEdit's Clean Masters can
drop `Fertility Mode.esm`. The scripts never read it.

Trimester rank mapping (computed by the bridge):
`1..33 = T1, 34..66 = T2, 67..100 = T3, 100 = labor, 101..115 = recovery, 0 = not pregnant`.

## Files in this patch folder

```
Patches/FMR-Immersive Effects/
  source/scripts/_FME_FMRBridge.psc          replacement bridge (BF NG-driven)
  source/scripts/_FME_SC_Overlays.psc        patched: reads FME.Rank from StorageUtil
  source/scripts/_FME_SC_RandEffChooser.psc  patched: reads FME.Rank from StorageUtil
  source/scripts/_FME_SC_3TBH.psc            unchanged (kept for build convenience)
  source/scripts/_FME_SC_MSSpells.psc        unchanged
  source/scripts/_FME_SC_2TFetal.psc         unchanged
  source/scripts/_FME_SC_3TFetal.psc         unchanged
  skyrimse.ppj                               Papyrus build project
  README.md                                  this file
```

After building, drop the produced `FMR- Immersive Effects.esp` and
`scripts\*.pex` into this folder so the FOMOD picks them up.

## What needs to be edited in the ESP

### No new records required

- **FACT:** reuse BF NG's `ParentFaction` (FormID `0x008448` in
  `BeeingFemale.esm`).
- **GLOB:** the patched `_FME_SC_MSSpells` is None-safe; clear or remove
  the three `FMVerbose` property fills and the scripts behave as
  if `FMVerbose=0` (NPC notifications skipped, player notifications
  still fire — matches the upstream default). If you want NPC
  notifications, clone `_FME_G_COMMI_SFW` (FE00081E) into the patch
  ESP as `_FME_FMVerbose` with FLTV=1 and repoint the three FMVerbose
  properties at it.

### Repoint / clear VMAD properties on six MGEFs

Three MGEFs hold a `GenericFaction` property pointed at
`Fertility Mode.esm:_JSW_SUB_TrackedFemFaction`. Repoint all three to
`BeeingFemale.esm:ParentFaction` (FormID `0x008448`):

| Record | FormID | Script |
|---|---|---|
| MGEF `_FME_RandEffectChooser` | FE000812 | `_FME_SC_RandEffChooser` |
| MGEF `_FME_ME_3T_BraxtonHicks` | FE000816 | `_FME_SC_3TBH` |
| MGEF `_FME_ME_Overlays` | FE000820 | `_FME_SC_Overlays` |

Three MGEFs hold an `FMVerbose` property pointed at
`Fertility Mode.esm:_JSW_BB_VerboseMode`. Either clear the form
reference (None) — the patched `_FME_SC_MSSpells` guards against
this — or repoint to `_FME_FMVerbose` if you created one:

| Record | FormID | Script |
|---|---|---|
| MGEF `_FME_ME_1T_MornSicSpell` | FE000813 | `_FME_SC_MSSpells` |
| MGEF `_FME_ME_2T_Fetal` | FE000814 | `_FME_SC_2TFetal` |
| MGEF `_FME_ME_3T_Fetal` | FE000815 | `_FME_SC_3TFetal` |

### One unexpected entry

xEdit's "Report masters" lists **MGEF `_FME_ME_3T_Colostrum`
(FE000821)** as having an FMR ref, but its source script
(`_FME_SC_Colostrum`) declares no Auto properties. Most likely a stale
CK-leftover property no source code reads — open its VMAD in xEdit and
repoint or delete whatever property is hiding in there.

## How to build the patch (one-time, manual)

### 1. Stage the original FMR-IE files into this folder

- Copy `FMR- Immersive Effects.esp` from the FMR-IE archive into
  `Patches/FMR-Immersive Effects/`.
- Copy the FMR-IE compiled `.pex` files (everything except the four
  patched scripts) into `Patches/FMR-Immersive Effects/scripts/`.

### 2. Edit the patch ESP in SSEEdit

Load: `Skyrim.esm`, `Update.esm`, `Dawnguard.esm`, `HearthFires.esm`,
`Fertility Mode.esm` (for this step only — do not activate),
`BeeingFemale.esm`, `FMR- Immersive Effects.esp` (the staged copy).

#### 2a. Add `_FME_FMVerbose` (GLOB)

Right-click `_FME_G_COMMI_SFW` (FE00081E) → **Copy as new record into…**
→ target `FMR- Immersive Effects.esp`. In the new record:

- EditorID: `_FME_FMVerbose`
- FNAM: `s` (short) — same as the other `_FME_G_*` globals
- FLTV: `0`

#### 2b. Repoint the VMAD properties

For each row in the tables above:

1. Expand the record's `VMAD - Virtual Machine Adapter` →
   the relevant script entry → `Properties` → the named property
   (`GenericFaction` or `FMVerbose`).
2. Edit the form reference to the new target.

That's six edits total (plus one for the Colostrum mystery property
if it turns out to be FMR-rooted).

#### 2c. Drop the `Fertility Mode.esm` master

Right-click `FMR- Immersive Effects.esp` → **Clean Masters**. xEdit
removes `Fertility Mode.esm` automatically when nothing references it.
If it complains, use **Referenced By** on `_JSW_SUB_TrackedFemFaction` /
`_JSW_BB_VerboseMode` to find the leftover.

`BeeingFemale.esm` should be added automatically as a master because
of the `ParentFaction` reference and the new bridge `.pex`'s
`FWSystem` dependency. If not, **Add Masters…** manually.

Save the ESP. Verify the file header still shows ESL.

### 3. Compile the patched scripts

Adjust paths in `skyrimse.ppj` (Skyrim install root) to match your
tooling. The `Imports` section already points at
`..\dependencies\FMR-Immersive Effects\Data\Source\Scripts` for the
original FMR-IE sources, and at the project's `dist\Core\source\scripts`
for BF NG types (`FWSystem`).

Compile these four scripts and drop the resulting `.pex` files into
`scripts/`:

- `_FME_FMRBridge.psc` — new bridge
- `_FME_SC_Overlays.psc` — patched (reads `FME.Rank`)
- `_FME_SC_RandEffChooser.psc` — patched (reads `FME.Rank`)
- `_FME_SC_3TBH.psc` — unchanged, but recompile so its bytecode stays
  in sync with the rest of the patch's source baseline

(The other three patched-source files — `_FME_SC_MSSpells`,
`_FME_SC_2TFetal`, `_FME_SC_3TFetal` — are unchanged from upstream;
you can leave their original `.pex` in place.)

### 4. Smoke-test

With FMR.esm absent, your load order should load FMR-IE cleanly.
Get pregnant via BF NG. Within ~1.5 game-hours the FMR-IE overlays
(stretchmarks, areola darkening) should ramp with pregnancy progress;
you should see Morning Sickness / Cravings / Braxton-Hicks spells
firing per trimester.

Console-side debug:

- `player.getav storage_FME.Rank` → won't work (not a real AV). Use
  `papyrus log` and look for the bridge's `[FME]` traces, or grep
  Papyrus.0.log for `FME.Rank` calls.
- `player.getfactionrank XX008448` (substitute your BF load-order index
  for `XX`) → state ID from `ParentFaction` (-2..7).

## How the FOMOD installer uses this

`dist/fomod/ModuleConfig.xml` exposes this patch as an optional
component, gated on the user having `FMR- Immersive Effects.esp`
active. Selecting it copies `Patches/FMR-Immersive Effects/*` over the
user's existing FMR-IE install, replacing `FMR- Immersive Effects.esp`,
`_FME_FMRBridge.pex`, `_FME_SC_Overlays.pex`,
`_FME_SC_RandEffChooser.pex`, and `_FME_SC_3TBH.pex`.

## Risks / notes

- Anyone who installs both the original FMR-IE and this patch must let
  the patch win in their mod manager; otherwise the mod will refuse to
  load (FMR.esm still required by upstream FMR-IE).
- The bridge's safety-poll cadence is `TrackedUpdateIntervalHours` =
  1.5h. Overlays only refresh within a trimester at that cadence; if
  you want smoother stretchmark fade-in, drop it to 0.5h or smaller.
- `FME.Rank` is bumped on every `BeeingFemale*` event the bridge
  subscribes to, so trimester transitions take effect promptly even
  between polls.
- `_FME_FMVerbose` defaults to 0 (non-verbose). The MS/Fetal scripts
  use it only to gate notification spam on NPCs; default-off matches
  vanilla quiet behaviour.
- Scene-awareness (skip effects during SexLab/OStim scenes) was in the
  upstream bridge via typed casts to `OSexIntegrationMain` /
  `SexLabFramework`. The replacement bridge drops those typed deps so
  the patch builds without bundling SexLab/OStim sources; the scene
  gate is currently a no-op. Re-add via scene-start/end mod events if
  you want strict skipping.
