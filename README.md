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

- Migrated from legacy SKSE/CommonLibSSE to CommonLibSSE-NG.
- Switched build system to xmake (no VS solution required).
- Updated plugin entry point to `SKSEPluginLoad` with NG logging/serialization.
- Papyrus native registration updated to NG signatures; scripts unchanged.
- Added a player damage cap in `dist/Core/source/scripts/FWSystem.psc` so difficulties below 4 cannot reduce health below 1 HP.
- Removed FNIS/OAR gating so animation playback is no longer forced off when FNIS is missing.
- Labor pains duration can be tuned via `Global_Duration_09_LaborPains` in `dist/Core/BeeingFemale/AddOn/Global Settings.ini`.
- Integrated fixes from BeeingFemaleSE Opt by aliceqwer3141 and Beeing Female SE 2.8.1 Patch V14d by Bane Master and Garkin.
- Modified the SexLab add-on and added an OStim add-on.
- Bathing in Skyrim Renewed addon added.
- ChildItems grow to kids if growth is enabled after growthtime. (for player as mother only)
- Parent faction repurposed for tracked female actor state tracking

  Changelog:
	https://github.com/crajjjj/Beeing-Female-NG/releases

## Notes

- `xmake-requires.lock` is tracked to keep dependency versions stable.
- Papyrus sources live in `dist/Core/Source/Scripts`.
- SSEEDIT_locations is just for reference. Don't compile or import

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
- MCM: System/Cheats page, `AutoCouples Import`.

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

### Capabilities

- Global/default tunables for cycle timings, pregnancy chance, belly/breast scaling, pain, multiple births, and baby spawn pacing.
- Per-race or per-actor overrides (pregnancy scales, duration multipliers, protected child flags, etc.).
- Custom baby actor/item/armor selection for parent race/actor (with fallback behavior).
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
  - `AddSperm` (numArg = donor FormID): add sperm from the donor to the sender; donor must resolve to an Actor.
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
- `FW.UnbornHealth` (Float, per-actor: mother): unborn baby health (0-100).
- `FW.LastConception` (Float, per-actor: mother): game time of last conception.
- `FW.Abortus` (Int, per-actor: mother): abortus state flag (0 none, 1 imminent, 2 incipient, 3 incomplete, 4 complete, 5 missed abortion, 6 miscarriage/stillbirth).
- `FW.AbortusTime` (Float, per-actor: mother): game time when abortus started.
- `FW.Contraception` (Float, per-actor: mother): current contraception strength (0-100).
- `FW.ContraceptionTime` (Float, per-actor: mother): game time when contraception last changed.
- `FW.SpermName` (FormList, per-actor: mother): list of sperm donors (actors).
- `FW.SpermAmount` (FloatList, per-actor: mother): sperm amounts for each donor.
- `FW.SpermTime` (FloatList, per-actor: mother): timestamps for each donor entry.
- `FW.LastSeenNPCs` (FormList, stored on mother): recent nearby NPCs cached for partner selection/impregnation logic.
- `FW.LastSeenNPCsTime` (FloatList, stored on mother): timestamps aligned with `FW.LastSeenNPCs` entries (same index).
- `FW.Babys` (FormList, global): active child actor forms tracked by the system.
- `FW.BornChildFather` (FormList, per-actor: mother): list of fathers for born children.
- `FW.BornChildTime` (FloatList, per-actor: mother): timestamps for born children.
- `FW.LastBornChildTime` (Float, per-actor: mother/father): last birth time for a parent.

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
