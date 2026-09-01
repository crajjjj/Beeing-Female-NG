# Troubleshooting & Logs

When something misbehaves, the logs almost always say why. This page lists where every relevant log lives, how to turn on Papyrus logging (off by default), and what to attach when reporting a problem.

!!! tip "Quick links"
    - Mod missing from the MCM? Work through the checklist in [Getting Started](getting-started.md#the-mod-does-not-show-up-in-the-mcm).
    - A hygiene item keeps getting knocked off? See [Item Slots & Conflicts](../authors/item-slots.md) (quick fix: switch to tampons).
    - NPCs carry tampons/potions although you disabled NPC items? See [NPCs keep getting tampons and potions with item distribution turned off](#npcs-keep-getting-tampons-and-potions-with-item-distribution-turned-off).
    - Birth happens but no animation plays? See [Birth animations not playing](#birth-animations-not-playing) (usually: run FNIS/Nemesis, then enable **Play Animations**).

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

## A child is stuck in a modded cell (won't follow or teleport)

If you give birth in (or leave a child in) a cell added by another mod — a player home, a camp, a dungeon — the child may refuse to follow you out on foot, even though the same actor travels normally once they **grow into an adult**.

**Why it happens.** Children are managed by BF's own order system, not the vanilla follower engine, and the follow behavior needs a **navmesh path to the exit**. Many small modded cells ship without proper navmesh links to the outside (and often without a Location record), so the child's AI can't path out and simply re-issuing "Follow me" won't move it. A grown adult is a standard follower added to the vanilla follower factions, so it is no longer bound by this — which is why the same actor comes and goes freely once mature.

**Confirm it's this.** Open the child's **info window** (MCM **Children** tab → click the child) — if the location reads **"Somewhere in Skyrim"** instead of a real place name, the cell has no Location record. That's a strong sign you've hit this, since such cells usually also lack the navmesh links the child needs to walk out.

**Workarounds, most reliable first:**

1. **Console teleport (always works).** Open the console (`~`), **left-click the child** so its RefID appears at the top of the console, type `moveto player`, press Enter, close the console. The child snaps to your exact position regardless of Location data. Then talk to them and pick **"Follow me"** again. (To send a child *to* a known follower/NPC instead, select the child and use `moveto <RefID>`.)
2. **Use the right child-call scroll.** BF gives you two child-call scrolls at startup — and only one of them teleports:
    - **Scroll of the immediate children** (`_BFChildCallScroll2`, FormID `0x5AB69` in `BeeingFemale.esm`) — in-game description *"Teleports your children to you,"* and that is literal: it **teleports all of your children to your position from anywhere**, regardless of cell or Location data. **This is the one to use for a stranded child.** It is also sold by general-goods merchants and seeded onto NPCs by the SPID patch, so you can restock it. ("Immediate" means your *immediate family*, not nearby.)
    - **Scroll of the children** (`_BFChildCallScroll1`, FormID `0x5AB67`) — only re-issues the follow order; it does **not** teleport, so it cannot pull out a child that can't path to the exit.

    Out of the teleport scroll? Buy it from a general-goods merchant, loot it off NPCs, or console it in: type `help "immediate children" 4` to find its load-order FormID, then `player.additem <id> 1`.
3. **"Go home" first.** Order the child **"Go home"** via dialogue, then rejoin them at their home (a vanilla cell) and re-issue **"Follow me"** there. (This only helps if the child can path home in the first place — if it can't, use the scroll or console.)

> Note: simply re-picking **"Follow me"** while standing next to the child usually won't get it out of such a cell — the order is set, but the AI still has no path to the exit. The teleport scroll (#2) or `moveto player` (#1) are what actually relocate it.

**Avoid:** importing a *still-a-child* actor into a follower framework (NFF/EFF/AFT) to force it out. While a child, BF manages its AI directly and the two systems conflict; and at the grow-up transition the child actor is replaced by a new adult actor, leaving the framework with a stale reference. Wait until the child becomes an adult, then import freely — that is fully supported.

## NPCs keep getting tampons and potions with item distribution turned off

**Symptoms.** The MCM toggle **"NPCs are having relevant items"** (Settings page) is off, yet female NPCs still spawn with contraception potions, tampons, and pads; menstruating NPCs wear pads; and even after you empty their inventory with a follower-management or similar mod, the items come back later.

**Why it happens.** Before 3.5.13, the optional **SPID item distribution** patch seeded these items into every female NPC's personal inventory, not just vendor stock. SPID works at the engine level — it cannot see MCM settings, and it re-seeds items whenever an NPC respawns or her cell resets, which is why removing them never stuck. (Separately, the post-birth recovery state restocked contraception on mothers without checking the toggle — also fixed in 3.5.13.)

**Fix.**

1. **Update to 3.5.13 or newer.** The SPID patch now only stocks vendors; NPC-carried items are handed out exclusively by the mod itself, honoring the MCM toggle. Reinstall the mod so the updated `BeeingFemaleSE-Opt-SPID_DISTR.ini` replaces the old one.
2. **Clean an existing save (optional).** Items seeded before the update stay in NPC inventories. To purge them, open `Data\BeeingFemale\AddOn\Default Global Settings.ini`, set `Global_RemoveSPIDitems=true`, and play a session — BF strips its own items (tampons, pads, contraception, wash-out fluids, tonics, child-call scrolls) from each tracked female as you encounter her. Vendors are never stripped, so shops stay stocked. Set the flag back to `false` afterwards: while it is on, it also removes BF items you hand to NPCs yourself.

!!! note
    Giving items to NPCs by hand still works with the toggle off — a follower carrying contraception drinks it on schedule, and a menstruating NPC with tampons or pads in her inventory equips them. The toggle only controls whether BF *gives* NPCs items on its own.

## Birth animations not playing

If the mother gives birth but just stands there — no lying down, no labor animation — work through these in order. The birth itself (baby spawn, recovery, events) still happens regardless; only the *visuals* are affected.

There are **two separate animation layers**, and they fail for different reasons:

- **Core birth events** — `LayDownBirth`, `Birth_S1/S2/S3`, `GetupBirth`. These are custom animations BF triggers with `Debug.SendAnimationEvent`.
- **OAR labor pack** (optional) — the alternate lying-down labor loop, an [Open Animation Replacer](https://www.nexusmods.com/skyrimspecialedition/mods/92109) set BF ships under `meshes/.../OpenAnimationReplacer/BFL/`.

### 1. Run your behavior tool (FNIS / Nemesis / Pandora)

**This is the most common cause.** BF's birth animations are custom animations registered through `FNIS_BeeingFemale_List.txt`. The engine only knows about them after you **run your behavior generator and let it patch** — otherwise BF fires the birth event but nothing is registered to it, so the actor just stands there.

- **FNIS users:** run **GenerateFNISforUsers.exe**, confirm Beeing Female appears in the mod list, then launch.
- **Nemesis / Pandora users:** run the engine, tick its boxes, **Update/Launch**, then start the game.

Re-run it whenever you install or update BF. (BF does **not** hard-block if you skip this — it just can't show the animation.)

### 2. Turn on "Play Animations" in the MCM

**MCM → Beeing Female → Settings page → "Play Animations."** It must be **enabled**. With it off, BF skips all birth animation events on purpose (the birth still completes silently). The reset-to-default state for this toggle is *off*, so a fresh profile may need it switched on.

Next to that toggle the MCM shows the **animation version** (e.g. `1`). If it reads a mismatch like `0/1`, the behavior patch isn't registered — go back to step 1. Note this readout only updates **in third person** (an engine limitation of animation-variable checks), so check it there.

### 3. Furniture or heavy bondage = deliberate silent birth

BF **intentionally** skips the animation if, when labor fires, the mother is:

- **occupying furniture** — a chair, bed, crafting station, or any furniture-bound idle, or
- **in heavy Devious Devices bondage** — armbinder, yoke, etc.

Forcing a birth animation on top of those breaks both, so BF gives birth without it. The Papyrus log says exactly which:

```
FWController.IsBirthAnimationBlocked: <actor> is occupying furniture - birth animation will be skipped (silent birth)
FWController.IsBirthAnimationBlocked: <actor> is in heavy bondage - birth animation will be skipped (silent birth)
```

**Fix:** get the mother off furniture / out of restraints before the third trimester ends.

### 4. The actor must be loaded (and use third person to *see* your own)

Animations only play on an actor whose 3D is loaded. A mother in an unloaded or distant cell won't animate — move closer, or wait for her to load.

For your **own** character the animation still plays in first person — you just can't see it, because the camera is looking out *through* your character rather than at her body. Switch to third person to actually watch it. (This is also why the animation-version readout in step 2 only updates in third person.)

### 5. OAR labor variants, and the "NOT IsChild" condition

This is **only** about the optional variety pack **"Labor Animations - Beeing Female"** (by Laethas) — 24 OAR alternates that *replace* the base `Birth_S1/S2/S3` for variety. It's not what makes birth animate (that's steps 1–2). First confirm **Open Animation Replacer** is loading (`SKSE\skse64.log` → `OpenAnimationReplacer`).

All 24 variants gate on the same `IsChild` (negated) + `IsFemale` + `Random` conditions. OAR's `IsChild` keys off the actor's **race** (the engine child flag), not apparent age — and some custom races carry that flag, so a mother on such a race fails it and OAR skips every variant. You'll then get the **plain** base birth (if your behavior tool registered it), or **nothing** if you rely on the OAR pack alone.

**Fix:** disable the `IsChild` condition across the whole set — easiest in OAR's in-game editor (open **"Labor Animations - Beeing Female"** → disable `IsChild` on each `Labor N`; saved to an update-safe `user.json`), or by removing the `IsChild` block from each `BFL/700001`…`700024/config.json`. Risk is minimal — these are cosmetic, and BF only triggers labor on tracked fertile females anyway.

### 6. Still nothing? Capture a log

Enable Papyrus logging (above), trigger a birth, then search `Papyrus.0.log` for:

- `FWController.GiveBirth:` — the line includes `playAnimations=true/false`. If it says `false` with no furniture/bondage line nearby, the MCM toggle (step 2) is off.
- `IsBirthAnimationBlocked` — confirms a furniture/bondage skip (step 3).

Attach that with the items below.

## Reporting a problem

When you report an issue, attach:

1. `SKSE\BeeingFemale.log` (or `SKSE\skse64.log` if `BeeingFemale.log` is missing).
2. `Logs\Script\Papyrus.0.log`, captured **with Papyrus logging enabled** while reproducing the problem.
3. Your load order and the BF version (MCM **Info / System** page), plus whether you are on SE, AE, or VR.

A clear "what I did → what happened → what I expected" plus those two logs is usually enough to pinpoint the cause.
