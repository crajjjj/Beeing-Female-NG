# Troubleshooting & Logs

When something misbehaves, the logs almost always say why. This page lists where every relevant log lives, how to turn on Papyrus logging (off by default), and what to attach when reporting a problem.

!!! tip "Quick links"
    - Mod missing from the MCM? Work through the checklist in [Getting Started](getting-started.md#the-mod-does-not-show-up-in-the-mcm).
    - A hygiene item keeps getting knocked off? See [Item Slots & Conflicts](../authors/item-slots.md) (quick fix: switch to tampons).

## Where the logs are

All logs live under your **My Games** folder. The exact path depends on your edition:

- **Skyrim SE / AE:** `Documents\My Games\Skyrim Special Edition\`
- **Skyrim VR:** `Documents\My Games\Skyrim VR\`

The paths below use the SE folder; swap in `Skyrim VR` if you are on VR.

| Log | Path | What it tells you |
|-----|------|-------------------|
| **Beeing Female plugin log** | `SKSE\BeeingFemale.log` | The bundled `BeeingFemale.dll` (SKSE plugin) writes here. If this file is **missing**, the DLL never loaded. |
| **SKSE log** | `SKSE\skse64.log` (`sksevr.log` on VR) | Why a plugin was rejected — usually a wrong game version or a missing Address Library. Search it for `BeeingFemale`. |
| **Papyrus script log** | `Logs\Script\Papyrus.0.log` | Script-side errors and traces (the cycle, conception, children, add-on framework). **Only written when Papyrus logging is enabled — see below.** |

!!! note "Mod Organizer 2 users"
    Logs still go to the real `Documents\My Games\...` folder, **not** into MO2's virtual file system or the Overwrite folder. Open them directly from Documents — don't go looking in the Overwrite folder for them.

## Enabling Papyrus logging

Papyrus logging is **off by default** (it adds a little overhead, so it ships disabled). Turn it on only while diagnosing a problem, then turn it back off.

Edit **`Skyrim.ini`** (in the My Games folder above) and add or update this section:

```ini
[Papyrus]
bEnableLogging=1
bEnableTrace=1
bLoadDebugInformation=1
```

- `bEnableLogging` — writes the `Papyrus.0.log` file at all.
- `bEnableTrace` — includes `Debug.Trace` lines (what BF and most mods log).
- `bLoadDebugInformation` — adds script/line names to errors so they are actually readable.

Then **launch the game through SKSE**, reproduce the issue, and quit. The fresh log is `Logs\Script\Papyrus.0.log` (older runs roll over to `Papyrus.1.log`, `Papyrus.2.log`).

!!! warning "Mod Organizer 2: edit the profile INI"
    MO2 keeps a per-profile copy of `Skyrim.ini` and ignores the one in Documents. Edit it via **MO2 → Tools (wrench/screwdriver icon) → INI Editor → Skyrim.ini**, add the `[Papyrus]` block there, and save. Editing the Documents copy will have no effect.

!!! tip "Turn it back off afterwards"
    When you are done, set `bEnableLogging=0` (or remove the block). Long sessions with tracing on produce very large logs and a small performance cost.

## What to look for

In `Papyrus.0.log`, search for Beeing Female's script names — most start with **`FW`** (e.g. `FWSystem`, `FWController`, `FWSystemConfig`, `FWAbilityBeeingFemale`). Useful patterns:

- `Failed to load script FWSystemConfig` or `... is not a valid type` — a **missing requirement** (usually a wrong-version PapyrusUtil/SkyUI, or a leftover copy of the old Beeing Female). See the [Getting Started checklist](getting-started.md#the-mod-does-not-show-up-in-the-mcm).
- `X is not a function on a None object` / `Cannot call ... on a None` — a form binding came back empty, often a missing or out-of-order plugin.
- BF's own diagnostics are written through its internal logger, so filtering for `FW` or `BeeingFemale` surfaces them.

In `SKSE\skse64.log`, a line like `plugin BeeingFemale ... reported as incompatible` (or a version mismatch) explains why `BeeingFemale.log` is absent.

## Reporting a problem

When you report an issue, attach:

1. `SKSE\BeeingFemale.log` (or `SKSE\skse64.log` if `BeeingFemale.log` is missing).
2. `Logs\Script\Papyrus.0.log`, captured **with Papyrus logging enabled** while reproducing the problem.
3. Your load order and the BF version (MCM **Info / System** page), plus whether you are on SE, AE, or VR.

A clear "what I did → what happened → what I expected" plus those two logs is usually enough to pinpoint the cause.
