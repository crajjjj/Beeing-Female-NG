# Beeing Female NG

SKSE plugin built with CommonLibSSE-NG and xmake.

## Requirements

- Visual Studio 2022 (MSVC v143)
- xmake 2.9.5+
- CommonLibSSE-NG checked out at `lib/commonlibsse-ng`

## Setup


To add the submodule in a fresh clone:

```sh
git submodule add https://github.com/CharmedBaryon/CommonLibSSE-NG.git lib/commonlibsse-ng
git submodule update --init --recursive
```

## Build

Debug:

```sh
xmake f -m debug
xmake
```

Release:

```sh
xmake f -m release
xmake
```

## Output

The plugin and PDB (debug only) are copied to:

```
dist/Core/skse/plugins
```

## Changes

  Changelog:
	https://github.com/crajjjj/Beeing-Female-NG/releases

## User Guide

See [USER_GUIDE.md](USER_GUIDE.md) for a non-technical guide covering the menstrual cycle, insemination, conception, pregnancy, birth, children, widgets, and MCM settings.

## Notes

- `xmake-requires.lock` is tracked to keep dependency versions stable.
- Papyrus sources live in `dist/Core/Source/Scripts`.
- SSEEDIT_locations is just for reference. Don't compile or import

## Widgets

Beeing Female NG ships a set of SkyUI-based HUD widgets (backed by `BeeingFemale/BeeingFemaleWidget.swf`) that display live cycle/pregnancy state on screen. All widgets are positioned, scaled, and anchored through MCM settings stored on the quest.

### State Widget (`FWStateWidget`)

Displays the current cycle or pregnancy phase for the player (or a tracked NPC target).

- **Female actors**: shows the cycle state name (Follicular, Ovulation, Luteal, Menstruation, 1st/2nd/3rd Trimester, Labor Pains, Replenish), a matching icon, a fill bar representing progress through the current state, and elapsed time since the state began.
- **Male actors**: shows virility percentage and estimated time until full virility recovery.
- Hidden in immersive message mode.
- Configurable fill direction, color, dark color, flash color, and icon position.

### Baby Health Widget (`FWBabyHealthWidget`)

Dual-mode widget that changes display based on the actor's current state.

- **Cycle phase (states 0–3)**: shows the player's relative pregnancy chance as a percentage.
- **Pregnancy (states 4–7)**: shows unborn baby health (0–100). Displays `0` when abortus has been triggered.
- Suppressed until baby health drops to 8 or below (alert-only mode), unless already in a non-cycle state under immersive mode settings.

### Contraception Widget (`FWContraceptionWidget`)

Shows the active contraception level for the player.

- Displays contraception strength (0–100%) as a fill bar and numeric label.
- Countdown shows time remaining before the effect expires; shows "Overdue" when lapsed.
- Only visible when contraception was applied within the past 8 in-game days.
- Configurable fill direction, color, dark color, flash color, and icon position.

### Progress Widget (`FWProgressWidget`)

Temporary loading/status widget shown during background operations (initialization, add-on scanning, file checks, etc.).

- Shows an icon, a short status message, and an optional percentage bar.
- Fades in when a task starts and flashes before fading out on completion.
- Icon names map to built-in constants on the script (e.g. `ICN_Init`, `ICN_AddOn`, `ICN_Search`, `ICN_Sperm`).

### Panty Widget (`FWPantyWidget`)

Monitors the player's menstrual hygiene item during menstruation (state 3). Polls every in-game hour.

- **Bloody icon** – shown when a soiled sanitary napkin or tampon is equipped.
- **Needed icon** – shown when menstruating with no hygiene item worn (reminder).
- **Hidden** when not menstruating, or when a clean hygiene item is worn.

### Couple Widget (`FWCoupleWidget`)

Developer/debug widget for editing NPC couple data interactively in-game. Reads and writes `Data/BeeingFemale/Couples/<ModName>_<FormHex>.json`. Must be enabled in MCM.

- **E (hold 1.5 s)** – select a female NPC as the active subject.
- **H (hold 1.5 s)** – assign or clear the husband for the selected female.
- **G (hold 1.5 s)** – add or remove an affair partner.
- **P (hold 1.5 s)** – add or remove a regular partner.
- Auto-detects existing spouses via relationship rank (≥ Lover) or the vanilla `Spouse` association type.

### Widget Controller (`FWWidgetController`)

Orchestrates the State, Baby Health, and Contraception widgets via a configurable hotkey.

- **Tap hotkey**: show all three widgets for 5 seconds, then auto-hide.
- **Hold 1.2 s**: keep widgets visible until the hotkey is pressed again to dismiss.
- **Hold 5 s**: open the ranked info box for the player instead.

### HUD Profiles (`Data/BeeingFemale/HUD/*.ini`)

Widget layout is driven by INI profile files in `Data/BeeingFemale/HUD/`. The active profile defaults to `default.ini`. When more than one `.ini` file exists in that folder, the MCM exposes a dropdown to switch between profiles at runtime.

Each file contains one section per widget. All keys are optional — omitted keys fall back to the previously loaded value.

**Common keys (all widgets):**

| Key | Description |
|-----|-------------|
| `PositionX` | Horizontal pixel offset from the anchor point. |
| `PositionY` | Vertical pixel offset from the anchor point. |
| `Enabled` | `true`/`false` — whether the widget is shown at all. |
| `Alpha` | Opacity, 0–100. |
| `HAnchor` | Horizontal anchor: `left`, `right`, or `center`. |
| `VAnchor` | Vertical anchor: `top`, `bottom`, or `center`. |
| `Scale` | Size multiplier (`1.0` = 100%). |

**Extra keys for `[StateWidget]` and `[ContraceptionWidget]`:**

| Key | Description |
|-----|-------------|
| `FillDirection` | Direction the bar fills: `left` or `right`. |
| `Color` | Bar fill color as hex (`0xRRGGBB`). |
| `DarkColor` | Bar background/dark color as hex. |
| `FlashColor` | Flash highlight color as hex. |
| `IconPosition` | Side the icon sits on: `left` or `right`. |

**Shipped profiles:**

- `dist/Core/BeeingFemale/HUD/default.ini` — standard layout (state widget bottom-left, contraception bottom-right, baby/panty top-right area).
- `dist/Core/BeeingFemale/HUD/LeftOver.ini` — alternate layout with both cycle widgets stacked on the bottom-left.

To create a custom layout, copy `default.ini` to a new file (e.g., `mylayout.ini`) in the same folder, edit the values, and select it in the MCM under the widget profile dropdown.

### Widget Timing (Global Settings INI)

Widget fade timing can be tuned via a `type=global` add-on INI (see `dist/Core/BeeingFemale/AddOn/GlobalSettingsExample/AddOn Global Settings Example.ini`). Only one global add-on may be active at a time.

| Key | Default | Description |
|-----|---------|-------------|
| `Global_WidgetFadeOutTime` | `3` (s) | Time the widget stays visible before fading out. `0` uses the system default of 3 s. |
| `Global_WidgetFlashShowTime` | `0.01` (s) | Fade-in duration for widgets that flash on appearance. `0` or negative uses the system default. |
| `Global_WidgetNoFlashShowTime` | `0.2` (s) | Fade-in duration for widgets that appear without a flash. `0` or negative uses the system default. |

## For Modders

### Couples Import

Beeing Female NG can auto-import sperm donors from JSON couple files and apply them to the matching female actor.

How it works:
- It scans `Data/BeeingFemale/Couples/*.json` (via `FWUtility.GetFileNames("Couples","json")`).
- Each filename should be `ModName_FormHex.json`. The split uses the last `_`, so mod names may contain underscores.
- The female actor is resolved from the filename as `ModName:FormHex`.
- Donors are pulled from the JSON keys `husband` (single form), `partners` (form list), and `affairs` (form list).
- One donor is chosen at random and applied via `SendModEvent("BeeingFemale", "AddSpermImpregnate", donorFormID)`.

How to run it:
- MCM: First page, `Couples Import`.

Notes:
- The `.json` extension check is case-insensitive.
- Errors are logged with `FW_log.WriteLog` if the file name is invalid, the female cannot be resolved, or no donor is found.
- Female validation rejection codes (from `System.IsValidateFemaleActor`):
  - `-10`: actor is `None` or has no `ActorBase`.
  - `-3`: actor sex is male.
  - `-2`: actor is dead OR has ghost keyword (when ghosts are not allowed).
  - `-1`: actor is summoned (when summoned females aren’t allowed) OR in a forbidden faction/keyword.
  - `-5`: actor is the player but player relevance is disabled.
  - `-6`: actor is a follower but follower relevance is disabled.
  - `-7`: actor is an NPC (non‑follower) but NPC relevance is disabled.
  - `-11`: actor is a creature and creature sperm is disabled.
  - `-8`: actor is a child race or in forbidden races.
  - `-9`: actor is an elder race and elder females are disabled.

## Add-on Framework

Beeing Female NG ships an INI-driven add-on framework that lets external mods extend or override pregnancy/cycle behavior without editing core scripts. Add-ons are discovered from `dist/Core/BeeingFemale/AddOn/*.ini` and loaded at runtime. Example folders in `dist/Core/BeeingFemale/AddOn` have detailed explanation on parameters. Use them as templates.

### Add-on Types

- `misc`: scripted hooks (camera, birth effects, integrations like SexLab/OStim, Bathing in Skyrim).
- `race`: per-race tuning (durations, scales, pregnancy chance, protected/PC dialogue, custom baby actors/items).
- `actor`: per-actor overrides (same knobs as race, but scoped to a single actor).
- `cme`: cycle magic effect lists for each stage (Always/Sometimes).
- `global`: global defaults and `Global_*` settings (see `Global Settings.ini`); only one global add-on may be active at a time.

### Capabilities

- Global/default tunables for cycle timings, pregnancy chance, belly/breast scaling, pain, multiple births, and baby spawn pacing.
- Per-race or per-actor overrides (pregnancy scales, duration multipliers, protected child flags, etc.).
- Custom baby actor/item/armor selection for parent race/actor (with fallback behavior).
- Custom adult actor/voice selection for the grow-up feature (`AdultActor_*` -- see "Adult Actor Add-ons" below).
- Integration hooks via misc add-ons (SexLab/OStim/Bathing in Skyrim).
- Add-on event hooks: `OnGiveBirthStart/End`, `OnLaborPain`, `OnBabySpawn`, `OnMagicEffectApply`, camera start/stop.

### Default Behaviors

- Uses global defaults from `Global Settings.ini` (or internal defaults if not set).
- If no custom baby actor is found, falls back to the parent actor base.
- Pregnancy visuals are driven by trimester scales plus `BellyMaxScale` and respect the selected visual scaling mode.
- Add-on lists refresh on game load when the AddOn directory hash changes or cached data is invalid.

## Integrations

- OStim: optional integration via `dist/Core/source/scripts/BFA_Ostim.psc` that listens for OStim orgasm events and applies sperm/impregnation logic when a male and female pair have vaginal sex (supports OStim API 23+ with NG thread events when available).
- SexLab: optional integration via `dist/Core/source/scripts/BFA_ssl.psc` and `dist/Core/source/scripts/BFA_AbilityEffectPMSSexHurt.psc` that hooks orgasm and stage events to apply sperm/impregnation logic and PMS sex-hurt effects; also uses the SexLab AnimatingFaction and optionally Devious Devices keywords when present. Recognises hentairim tags now and is more precise

## Bundled Optional Patches

`dist/Patches/` ships compatibility patches exposed as optional FOMOD components (`dist/fomod/ModuleConfig.xml`):

| Patch | What it does |
|-------|--------------|
| `SPID` | Spell Perk Item Distributor INI seeding BF's hygiene / contraception / pregnancy-test items into vendor and container loot. |
| `Fertility Adventures Redux` | Wires FAR's pregnancy quests, child-support storylines, and announcement dialogue to BF NG cycle events (Conception / Labor / state ticks) instead of Fertility Mode. |
| `PAIA` | Adds the Beeing Female OAR submod the base P.A.I.A is missing (the author reserved priority 91044062 for it but only shipped a legacy DAR condition). Pregnant idle plays at `ParentFaction` rank >= 5 (2nd trimester onward). Mesh-only. |
| `PAIAExpansion` | Repoints P.A.I.A Expansion's OAR conditions onto BF's `ParentFaction` so trimester idles, sit/sleep adjustments, and inflation poses follow BF pregnancies. Mesh-only. |
| `FMR-Immersive Effects` | Drops FMR-IE's hard `Fertility Mode.esm` master; a replacement bridge script derives FMR's 0..115 pregnancy rank from BF state and drives the overlays / random pregnancy effects from it. See the patch folder's README for the full design and build steps. |

Patches that integrate via the add-on framework (RS Children child actors, creature child actors) live in the FOMOD as well but install into `BeeingFemale/AddOn/`.


### Reading State and Sperm Info

Use StorageUtil to read the current state and inspect stored sperm data. Details bellow

```papyrus
; Current state (0..8)
int s = StorageUtil.GetIntValue(PlayerRef, "FW.CurrentState", 0)

; Check if there is significant sperm stored
int sa = StorageUtil.FormListCount(PlayerRef, "FW.SpermName")
bool isCumInside = false
while sa > 0
	sa -= 1
	float amo = StorageUtil.FloatListGet(PlayerRef, "FW.SpermAmount", sa)
	if amo > 0.3
		isCumInside = true
	endif
endwhile
```

### ParentFaction Pregnancy Ranks

Tracked actors (those in `FW.SavedNPCs`) get their `ParentFaction` rank updated when their state changes. You can read this rank to drive animations or other external logic.

- Rank is set to the actor's current `FW.CurrentState` value.
- Recovery (`FW.CurrentState` = `8`) is mapped to `-1` in the faction rank.
- If no valid state is present, rank is set to `-2`.

Rank (as read from `ParentFaction`) - Description - State ID:

- `-1` - Replenish (recovery) - `8`
- `0` - Follicular - `0`
- `1` - Ovulation - `1`
- `2` - Luteal - `2`
- `3` - Menstruation - `3`
- `4` - 1st Trimester - `4`
- `5` - 2nd Trimester - `5`
- `6` - 3rd Trimester - `6`
- `7` - Labor Pains - `7`


Papyrus example:

```papyrus
Faction ParentFaction = Game.GetFormFromFile(0x008448, "BeeingFemale.esm") as Faction
int state = ParentFaction.GetFactionRank(SomeActor)
```

### Papyrus ModEvents

Beeing Female NG listens for a few mod events you can emit from your own Papyrus scripts.

- `BeeingFemale` (SendModEvent): command-style event; sender must be an Actor (typically the female).
  - `AddContraception` (numArg = %): add contraception to the sender; values > 0 only.
  - `AddFertility` (numArg = magnitude): add a raw fertility (Gate 2) conception-roll boost to the sender; the magnitude is the boost size (capped internally at 8). This is the low-level knob and does **not** touch the per-cycle fertile flag (Gate 1).
  - `DrinkFertilityTonic` (numArg = potency): apply a full Fertility Tonic of the given potency, exactly as if the sender drank one. Potency < 3.5 is a mild tonic (Gate 2 boost, plus a one-roll Gate 1 nudge on an infertile cycle); potency >= 3.5 is a potent tonic (Gate 2 boost **and** forces this cycle fertile). Use this for parity with the in-game potions; use `AddFertility` if you only want the raw boost.
  - `AddSperm` (numArg = donor FormID): add sperm from the donor to the sender; donor must resolve to an Actor.
  - `AddSpermImpregnate` (numArg = donor FormID): like `AddSperm`, but also runs an immediate impregnation attempt.
  - `WashOutSperm` (numArg = %): wash out a percentage of stored sperm on the sender; strength scales the configured washout chances (higher % increases the effective washout chance for that call).
  - `ChangeState` (numArg = 0..8): force a cycle state by index; only valid for female actors.
    - `0` Follicular, `1` Ovulating, `2` Luteal, `3` Menstruating
    - `4` 1st Trimester, `5` 2nd Trimester, `6` 3rd Trimester
    - `7` Labor pains, `8` Replenish from birth
    - Note: UI-only states `20` (Pregnant) and `21` (Pregnant by chaurus) are not valid targets here.
  - `InfoBox` (numArg = sort mode): open the info window for the sender; 100 is the default sort mode.
  - `DamageBaby` / `HealBaby` (numArg = amount): apply damage/heal to the unborn baby of the sender.
  - `CanBecomePregnant` / `CanBecomePMS` (numArg = 1 or 0): toggle eligibility flags for the sender (1 = allow, 0 = disallow).
  - `TestScale` (numArg = scale): run a scaling test on the sender (debug).
  - `CheckAbortus` (numArg unused): run the abortus state machine on the sender; it may start/advance/resolve abortus based on unborn health, trimester timing, and randomness.
  - `Update` (numArg unused): refresh cached data/state for the sender.
  - `Belly` / `Birth` (numArg unused): refresh belly visuals for the sender.
  - `Dispel` (numArg unused): dispel the BeeingFemale effect on the sender.
  - `ConceptionChance` (numArg = 1 player, 2 follower, 3 npc): update auto-impregnation flags for the sender based on target group.
- `AddActorSperm` and `AddSperm` (ModEvent): push two Actor forms (woman first, donor second). Both must be valid actors; adds sperm without using a command string.

Beeing Female NG also emits mod events you can subscribe to:

- `BeeingFemaleConception` (ModEvent): pushed as `Mother` (Form), `ChildCount` (Int), `Father0` (Form), `Father1` (Form), `Father2` (Form). Fathers may be `None` if unknown.
- `BeeingFemaleLabor` (ModEvent): pushed as `Mother` (Form), `ChildCount` (Int), `Father0` (Form), `Father1` (Form), `Father2` (Form). Fired on labor start and on direct `GiveBirth` calls.
- `BeeingFemale` (ModEvent): command-style event; see the ChangeState subscription example below if you want to listen for `ChangeState` commands.

Examples:

```papyrus
; BeeingFemale command event (SendModEvent is a Form method)
FemaleActor.SendModEvent("BeeingFemale", "AddContraception", 100)
FemaleActor.SendModEvent("BeeingFemale", "AddFertility", 4)            ; raw Gate 2 boost
FemaleActor.SendModEvent("BeeingFemale", "DrinkFertilityTonic", 4)     ; full potent-tonic behavior (>=3.5 forces this cycle fertile)
FemaleActor.SendModEvent("BeeingFemale", "AddSperm", MaleActor.GetFormID())
FemaleActor.SendModEvent("BeeingFemale", "AddSpermImpregnate", MaleActor.GetFormID())
FemaleActor.SendModEvent("BeeingFemale", "WashOutSperm", 100)
FemaleActor.SendModEvent("BeeingFemale", "ChangeState", 3)
FemaleActor.SendModEvent("BeeingFemale", "InfoBox", 100)
FemaleActor.SendModEvent("BeeingFemale", "DamageBaby", 30)
FemaleActor.SendModEvent("BeeingFemale", "HealBaby", 60)
FemaleActor.SendModEvent("BeeingFemale", "CanBecomePregnant", 1)
FemaleActor.SendModEvent("BeeingFemale", "CanBecomePMS", 1)
FemaleActor.SendModEvent("BeeingFemale", "TestScale", 1.0)
FemaleActor.SendModEvent("BeeingFemale", "CheckAbortus")
FemaleActor.SendModEvent("BeeingFemale", "Update")
FemaleActor.SendModEvent("BeeingFemale", "Belly")
FemaleActor.SendModEvent("BeeingFemale", "Birth")
FemaleActor.SendModEvent("BeeingFemale", "Dispel")
FemaleActor.SendModEvent("BeeingFemale", "ConceptionChance", 2)
```

Event subscription example:

```papyrus
Event OnInit()
	RegisterForModEvent("BeeingFemaleConception", "OnBeeingFemaleConception")
	RegisterForModEvent("BeeingFemaleLabor", "OnBeeingFemaleLabor")
EndEvent

Event OnBeeingFemaleConception(Form akMother, int aiChildCount, Form akFather0, Form akFather1, Form akFather2)
	Actor Mother = akMother as Actor
	Actor Father0 = akFather0 as Actor
	Actor Father1 = akFather1 as Actor
	Actor Father2 = akFather2 as Actor
EndEvent

Event OnBeeingFemaleLabor(Form akMother, int aiChildCount, Form akFather0, Form akFather1, Form akFather2)
	Actor Mother = akMother as Actor
	Actor Father0 = akFather0 as Actor
	Actor Father1 = akFather1 as Actor
	Actor Father2 = akFather2 as Actor
EndEvent
```

BeeingFemale ChangeState subscription example:

```papyrus
Event OnInit()
	RegisterForModEvent("BeeingFemale", "OnBeeingFemaleCommand")
EndEvent

Event OnBeeingFemaleCommand(string eventName, string strArg, float numArg, Form sender)
	if strArg == "ChangeState"
		Actor woman = sender as Actor
		int newState = numArg as int
		; handle state change here
	endif
EndEvent
```

Abortus trigger example (requires a pregnant actor and abortus enabled in config):

```papyrus
; Reduce unborn health, then force a check
FemaleActor.SendModEvent("BeeingFemale", "DamageBaby", 999)
FemaleActor.SendModEvent("BeeingFemale", "CheckAbortus")
```

### StorageUtil Keys

Beeing Female NG stores most runtime state in StorageUtil values. The most important keys (prefix `FW.`) are:

- `FW.SavedNPCs` (FormList, global): tracked female actors managed by the system.
- `FW.CurrentState` (Int, per-actor: mother): current cycle state index (0-8).
- `FW.StateEnterTime` (Float, per-actor: mother): game days timestamp when the current state started.
- `FW.LastUpdate` (Float, per-actor: mother): last update timestamp for the actor.
- `FW.Flags` (Int, per-actor: mother): bit flags for cycle options (e.g., can become pregnant/PMS).
- `FW.NumChilds` (Int, per-actor: mother): number of unborn children.
- `FW.ChildFather` (FormList, stored on mother): list of fathers (one entry per child, matching `FW.NumChilds`).
- `FW.ChildFatherRace` (FormList, stored on mother): each father's race, recorded at conception -- fallback when the father actor has unloaded (creature fathers).
- `FW.ChildFatherStr` (StringList, stored on mother): string identifier per father, used by the UI when the actor cannot be resolved.
- `FW.UnbornHealth` (Float, per-actor: mother): unborn baby health (0-100).
- `FW.LastConception` (Float, per-actor: mother): game time of last conception.
- `FW.Abortus` (Int, per-actor: mother): abortus state flag (0 none, 1 imminent, 2 incipient, 3 incomplete, 4 complete, 5 missed abortion, 6 miscarriage/stillbirth).
- `FW.AbortusTime` (Float, per-actor: mother): game time when abortus started.
- `FW.Contraception` (Float, per-actor: mother): current contraception strength (0-100).
- `FW.ContraceptionTime` (Float, per-actor: mother): game time when contraception last changed.
- `FW.SpermName` (FormList, per-actor: mother): list of sperm donors (actors).
- `FW.SpermAmount` (FloatList, per-actor: mother): sperm amounts for each donor.
- `FW.SpermTime` (FloatList, per-actor: mother): timestamps for each donor entry.
- `FW.SpermRace` (FormList, per-actor: mother): each donor's race, recorded at `AddSperm` time -- persists when the donor actor unloads, so sperm entries with a `None` actor stay valid.
- `FW.LastSeenNPCs` (FormList, stored on mother): recent nearby NPCs cached for partner selection/impregnation logic.
- `FW.LastSeenNPCsTime` (FloatList, stored on mother): timestamps aligned with `FW.LastSeenNPCs` entries (same index).
- `FW.Babys` (FormList, global): active child actor forms tracked by the system.
- `FW.BornChildFather` (FormList, per-actor: mother): list of fathers for born children.
- `FW.BornChildTime` (FloatList, per-actor: mother): timestamps for born children.
- `FW.LastBornChildTime` (Float, per-actor: mother/father): last birth time for a parent.

Born children (entries in `FW.Babys`) carry their own per-actor keys:

- `FW.Child.Mother` / `FW.Child.Father` (Form): the child's parents.
- `FW.Child.Name` (String): first name (display name also carries the last name).
- `FW.Child.DOB` / `FW.Child.DOD` (Float): birth/death timestamps in game days.
- `FW.Child.Race` (Form): the child's intended race (may differ from the spawned base's race).
- `FW.Child.ParentActor` (Form): the parent whose add-on configuration drives growth settings.
- `FW.Child.IsCustomChildActor` (Int): `1` for plain-actor children (copies of a parent base, no `FWChildActor` script).
- `FW.Child.Order` (Int): current order for plain-actor children (set by the parent order powers).
- `FW.AddOn.StartGrowing` (Int, on the child): armed at spawn, cleared when growth completes.
- `FW.Child.GrownUp` (Int): `1` once the child has transitioned into an adult (grow-up feature).
- `FW.Child.GrowUpAttempts` / `FW.Child.GrowUpFailed` (Int): transition retry bookkeeping; after 10 failed attempts `GrowUpFailed=1` and the child permanently stays a grown child.
- `FW.Child.VoiceType` (Form): voice assigned to an add-on adult base at transition; re-applied on every game load (base mutations do not persist in saves).
- `FW.Child.Stat*` / `FW.Child.Perks` / `FW.Child.PerksLevel`: persisted stats and perk picks for `FWChildActor` children.

Baby items (BabySpawn "item" mode) record each baby's identity on the **mother** in parallel lists, written at birth and consumed FIFO when the item hatches (inventory references do not survive saves, so identity is never keyed on the placed item):

- `FW.BabyItemArmor` (FormList): the armor base form, used to match items to entries.
- `FW.BabyItemName` (StringList) / `FW.BabyItemSex` (IntList): the name and sex announced at birth -- the hatched child keeps them.
- `FW.BabyItemRace` (FormList): race context resolved at birth (preserves creature father race across unloads).
- `FW.BabyItemFather` (FormList) / `FW.BabyItemDOB` (FloatList): per-baby father and birth timestamp.

StorageUtil access examples:

```papyrus
; Per-actor state
int state = StorageUtil.GetIntValue(ActorRef, "FW.CurrentState", 0)
float lastConception = StorageUtil.GetFloatValue(ActorRef, "FW.LastConception", 0.0)
int numChilds = StorageUtil.GetIntValue(ActorRef, "FW.NumChilds", 0)

; Fathers list
int fatherCount = StorageUtil.FormListCount(ActorRef, "FW.ChildFather")
Actor father0 = StorageUtil.FormListGet(ActorRef, "FW.ChildFather", 0) as Actor

; Global tracked actors
int trackedCount = StorageUtil.FormListCount(none, "FW.SavedNPCs")
Actor trackedActor = StorageUtil.FormListGet(none, "FW.SavedNPCs", 0) as Actor
```

Multi-child / multi-father logic: when a pregnancy has multiple children, `FW.NumChilds` stores the count and `FW.ChildFather` stores one father per child (so twins can share a father or have different fathers). Systems that need a single "primary" father typically use index `0`.

Keys under `FW.AddOn.*` are reserved for add-on configuration/overrides and are documented in the add-on INI examples.


### Custom Race Add-ons

Use a race add-on INI to customize pregnancy/cycle behavior per custom race.

1) Copy `dist/Core/BeeingFemale/AddOn/CustomRace AddOn Example.ini` and rename it.
2) In `[AddOn]`:
   - Set `name`, `description`, `author`, and `type=race`.
   - Set `required=YourRacePlugin.esp` (optional but recommended. Races for ActorTypeNPC should have "child" as part of the name).
   - Set `enabled=true` if you want it active by default (or enable it in MCM later).
3) Set `races=N`, then add `[Race1]...[RaceN]` sections.
4) In each `[RaceN]`, set `id=PluginName:FormID` (hex FormID without `0x`; commas allowed).
5) Edit the per-race settings you need (durations, pain scales, pregnancy chance, etc.).
6) (Optional) If you need custom baby actors/items, follow `dist/Core/BeeingFemale/AddOn/ChildActor AddOn Example.ini`.

After saving the INI, enable the add-on in the BeeingFemale MCM if it is not enabled by default.

### Custom Actor Add-ons

Use an actor add-on INI to customize pregnancy/cycle behavior for specific actors.

1) Copy `dist/Core/BeeingFemale/AddOn/CustomActor AddOn Example.ini` and rename it.
2) In `[AddOn]`:
   - Set `name`, `description`, `author`, and `type=actor`.
   - Set `required=YourPlugin.esp` (optional but recommended).
   - Set `enabled=true` if you want it active by default (or enable it in MCM later).
3) Set `actors=N`, then add `[Actor1]...[ActorN]` sections.
4) In each `[ActorN]`, set `id=PluginName:FormID` (hex FormID without `0x`; commas allowed).
5) Edit the per-actor settings you need (durations, pain scales, pregnancy chance, etc.).

After saving the INI, enable the add-on in the BeeingFemale MCM if it is not enabled by default.

### Adult Actor Add-ons (Grow-Up Feature)

When **"Children grow into adults"** is enabled (MCM Children page), a child that finishes growing transitions into a real adult NPC. The adult's actor base is resolved from add-on INI lists, using the same mechanics and INI format as the `BabyActor_*` keys. The keys can be declared per race, per actor, or globally (resolution order: actor add-on, then race add-on, then global; if no list provides a base, the adult is spawned as a copy of the same-sex parent's base -- generic bases only: the player's base and unique NPC bases are never cloned, and with no usable base the transition aborts and retries).

| Key | Meaning |
|-----|---------|
| `AdultActor_Male` / `AdultActor_Female` | Comma-separated `PluginName:FormID` list of adult ActorBases. One entry is picked at random per transition, so longer lists give more variety. |
| `AdultActor_MalePlayer` / `AdultActor_FemalePlayer` | Optional dedicated lists for the player's own children; checked before the generic lists. |
| `AdultActorVoice_Male` / `AdultActorVoice_Female` | VoiceType (`PluginName:FormID`) applied to resolved bases that ship without a voice (such as the vanilla chargen presets). Bases that already have a voice keep it. Pick a follower-capable voice if you want the adult recruitable. |
| `AdultOutfit_Male` / `AdultOutfit_Female` | Outfit (`PluginName:FormID`) applied to adults spawned from add-on bases (entry 0; actor -> race -> global). Without it those adults get the roughspun-tunic fallback. Parent-base copies keep their base's own outfit. |
| `GrowUpToAdult` | Per-race/per-actor explicit override: `1` = always grow (even with the MCM toggle off), `-1` = never grow (even with it on). `Global_GrowUpToAdult` in a global add-on INI enables the feature globally. Legacy `GrowUpToAdult=true` still reads as `1`. |
| `Global_AllowAdultMarriage` | Global add-on INI only (`=1`): grown adults join the vanilla marriage pool (voice permitting). Off by default; no MCM equivalent. |

The shipped `dist/Core/BeeingFemale/AddOn/Default Adult Actors.ini` maps all 10 vanilla races (including vampire variants) to the **BF Adult Pack** bases (`BeeingFemaleAdultPack.esp`, ESL-flagged): 10 dedicated adults per race and sex, generated from Skyrim's chargen presets so their faces are computed live (no FaceGen files, no dark-face), with proper names, a real class, baked-in follower voices, a farm-clothes outfit, and a sandbox AI package. Delete or disable the INI to fall back to parent-base copies. A copyable template showing all grow-up keys ships in `AddOn/AdultGrowUpExample/`; the pack itself can be regenerated with the xEdit script in `tools/xedit/BFAP_GenerateAdultPack.pas`.

#### Shipping adult NPCs with their own dialogue ("Mom"/"Dad" lines)

BF's spoken parent-child greetings come from the HearthFires adoption dialogue, which only exists for child voice types -- grown adults lose them. An add-on plugin can bring them back, because `AdultActor_*` bases resolve from **any** installed plugin, including one that also contains dialogue:

1) Create a plugin with your adult ActorBases (custom faces, or duplicates of vanilla presets).
2) Add a faction to the plugin and put it in each base's faction list -- actors spawned from the base inherit it, so your dialogue can be conditioned on `GetInFaction` with no scripting. (Conditioning on a custom VoiceType assigned to your bases works too; BF never overrides a voice the base already has.)
3) Add dialogue topics conditioned on that faction. Useful extra conditions:
   - `GetRelationshipRank >= 3` toward the player -- BF sets rank 3 on the player's grown children at transition, so only *your* children greet you as a parent.
   - `GetPCIsSex` -- picks "Mom" vs "Dad" lines for the player.
4) Reference the bases from an `AdultActor_*` INI (`AdultActor_Female=YourPlugin.esp:FormID,...`). When your plugin is not installed the forms resolve to none and the normal fallback applies, so the INI is safe to ship.
5) Voice the lines, or leave them silent with subtitles (players can use Fuz Ro D-oh for readable timing).

Everything else -- spawning, follower factions, relationships, persistence across saves -- is handled by BF at transition time.
