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

## Insemination, Conception & Birth

### Overview

The reproductive system follows this pipeline:

1. **Insemination** -- sperm is deposited via SexLab/OStim orgasm events or the `AddSperm` mod event.
2. **Travel delay** -- sperm must age past `WashOutHourDelay` (default 6 hours) before it is considered "arrived" and eligible for conception.
3. **Contraception & wash-out** -- pills reduce sperm viability; bathing/fluids can remove sperm entirely.
4. **Conception check** -- during the fertility window the system rolls conception chance, weighted by sperm amount, donor virility, and contraception level.
5. **Pregnancy** -- three trimesters with progressive belly/breast scaling, baby health tracking, and combat damage risk.
6. **Birth** -- multi-stage labor with pain, animations, and child actor spawning.

### Insemination

When sperm is added (via `FWController.AddSperm`):

- Sperm amount is scaled by the donor's virility (0.02--1.0, based on time since last sex) and the addon `Sperm_Amount_Scale` multiplier.
- Non-lore-friendly pairings (when `ImpregnateLoreFriendly` is on) have their amount set to `0.0008` -- below the impregnation threshold, so they cannot conceive.
- Sperm is stored as three parallel lists on the mother: `FW.SpermName` (donor), `FW.SpermAmount`, `FW.SpermTime`.
- Sperm remains viable for `SpermDuration` days (default 2), scaled by the donor's `Duration_MaleSperm` addon multiplier.
- Entries older than 50 days are hard-pruned from storage.

| MCM Setting | Default | Effect |
|-------------|---------|--------|
| `SpermDuration` | 2.0 days | How long sperm stays viable |
| `MaleVirilityRecovery` | 1.0 (= 24h) | Time for a male to recover full virility |
| `CreatureSperm` | false | Allow creature males to deposit viable sperm |
| `ImpregnateLoreFriendly` | true | Restrict conception to species-compatible pairs |
| `WashOutHourDelay` | 0.25 days (6h) | Delay before sperm "arrives" and can be washed out or participate in conception |

| Addon Key | Scope | Default | Effect |
|-----------|-------|---------|--------|
| `Sperm_Amount_Scale` | actor/race/global | 1.0 | Multiplier on sperm amount at deposit |
| `Duration_MaleSperm` | actor/race/global | 1.0 | Multiplier on sperm viability duration |
| `Male_Recovery_Scale` | actor/race/global | 1.0 | Multiplier on virility recovery time |

### Contraception & Wash-Out

Contraception is a 0--100% value stored per-actor. It is checked during the conception roll and reduces the effective chance.

- Pills add contraception when consumed (player) or auto-consumed (NPCs, checked in `FWSaveLoad.UpdatePerDay`).
- Contraception decays over time based on `ContraceptionDuration` (addon-tunable, clamped 1--8 days).
- Maximum contraception is capped at 98%.

Wash-out removes sperm entries:
- **No assistance**: `WashOutChance` (default 0%)
- **Swimming/water**: `WashOutWaterChance` (default 2%)
- **Anti-sperm fluid**: `WashOutFluidChance` (default 75%)
- **Bathing in Skyrim**: triggers `WashOutSperm` via integration addon

| Addon Key | Scope | Default | Effect |
|-----------|-------|---------|--------|
| `ContraceptionDuration` | actor/race/global | 1.0 | Multiplier on pill duration |
| `Ignore_Contraception_Prob` | race/global | -1 (off) | Probability that this race's sperm ignores contraception |

### Conception

Conception is checked in `ActiveSpermImpregnationTimed` when the mother has viable sperm. The check requires:

1. **Viable sperm** -- amount >= 0.0009, not expired, father is a valid actor.
2. **Fertility window** -- normally only during ovulation (state 1). Addon key `Allow_Impregnation_For_Any_Period` can bypass this.
3. **Pregnancy eligibility** -- `canBecomePregnant` checks: female, not dead, conception chance roll passes.
4. **Contraception** -- reduces effective chance (can be bypassed by addon `Ignore_Contraception_Prob`).

The conception chance is:

```
base_chance = ConceiveChance (player) / ConceiveChanceFollower / ConceiveChanceNPC
scaled_chance = base_chance * PregnancyChanceActorScale (from addon ChanceToBecomePregnantScale)
roll = RandomFloat(0, 99.9) < scaled_chance
```

If multiple donors have viable sperm, the father is selected weighted by sperm amount plus any `Sperm_Impregnation_Boost`.

| MCM Setting | Default | Effect |
|-------------|---------|--------|
| `ConceiveChance` | 40% | Player conception chance per eligible cycle |
| `ConceiveChanceFollower` | 40% | Follower conception chance |
| `ConceiveChanceNPC` | 40% | Generic NPC conception chance |

| Addon Key | Scope | Default | Effect |
|-----------|-------|---------|--------|
| `ChanceToBecomePregnantScale` | actor/race/global | 1.0 | Multiplier on conception chance |
| `DisablePregnancy` | actor/race/global | 0 | Set to 1 to completely block pregnancy |
| `Allow_Impregnation_For_Any_Period` | actor/race/global | 0 | Allow conception outside ovulation |
| `Sperm_Impregnation_Boost` | actor/race/global | 0 | Bonus weight for father selection |
| `Sperm_Impregnation_Prob_For_Any_Period` | actor/race/global | 0 | Extra % chance added for any-period conception |

### Multiple Pregnancy

After conception, the system rolls for multiples based on total sperm count:

- If total sperm exceeds `MultipleThreshold` (default 85), each unit above rolls for an extra baby.
- Maximum babies per pregnancy: `MaxBabys` (default 3).

| Addon Key | Scope | Default | Effect |
|-----------|-------|---------|--------|
| `Multiple_Threshold_Chance` | actor/race/global | 1.0 | Scale on threshold value |
| `Multiple_Threshold_Max_Babys` | actor/race/global | 1.0 | Scale on max babies cap |

### Pregnancy (States 4--6)

Three trimesters with configurable durations. Each trimester applies progressive belly and breast scaling.

- Baby health starts at 100 and can be reduced by combat damage (`DamageBaby`) or the infection spell.
- If health drops too low and `abortus` is enabled, miscarriage can trigger (states 0--6 of the abortus system).

| MCM Setting | Default | Effect |
|-------------|---------|--------|
| `Trimster1Duration` | 10 days | First trimester length |
| `Trimster2Duration` | 10 days | Second trimester length |
| `Trimster3Duration` | 10 days | Third trimester length |
| `abortus` | true | Enable miscarriage system |

| Addon Key | Scope | Default | Effect |
|-----------|-------|---------|--------|
| `Duration_05_Trimester1` | actor/race/global | 1.0 | Multiplier on first trimester duration |
| `Duration_06_Trimester2` | actor/race/global | 1.0 | Multiplier on second trimester |
| `Duration_07_Trimester3` | actor/race/global | 1.0 | Multiplier on third trimester |
| `Modify_Trimester1_by_FatherRace` | race | 0 | Additive offset from father's race |
| `Modify_Trimester2_by_FatherRace` | race | 0 | Additive offset from father's race |
| `Modify_Trimester3_by_FatherRace` | race | 0 | Additive offset from father's race |

### Birth (State 7)

Labor is a multi-stage process: Vorwehen (early contractions) -> Eroffnungswehen (opening) -> Presswehen (pushing) -> Nachwehen (afterpains). For each child:

- Health check: `UnbornHealth > RandomFloat(0, 35)` determines live birth vs stillbirth.
- Live births call `SpawnChild` and increment `FW.NumBabys`.
- Stillbirths show a message but do not spawn an actor.
- `BeeingFemaleLabor` mod event fires at labor start with Mother, ChildCount, and up to 3 fathers.
- After all children are delivered, state transitions to 8 (Replenish).

| MCM Setting | Default | Effect |
|-------------|---------|--------|
| `BabySpawn` | 1 | Player baby spawn mode (0=none, 1=actor, 2=item/actor, 3=gem) |
| `BabySpawnNPC` | 1 | NPC baby spawn mode |
| `PlayAnimations` | true | Play birth animations |
| `ReplanishDuration` | 30 days | Post-birth recovery length |

| Addon Key | Scope | Default | Effect |
|-----------|-------|---------|--------|
| `Duration_09_LaborPains` | actor/race/global | 0.2 | Labor phase duration scale (20% of base = short) |
| `Duration_10_SecondsBetweenLaborPains` | actor/race/global | 1.0 | Real-time seconds between contractions |
| `Duration_11_SecondsBetweenBabySpawn` | actor/race/global | 1.0 | Real-time seconds between each child spawning |
| `Modify_SecondsBetweenLaborPains_by_FatherRace` | race | 0 | Offset from father's race |
| `Modify_SecondsBetweenBabySpawn_by_FatherRace` | race | 0 | Offset from father's race |
| `Modify_Pain_GivingBirth_by_FatherRace` | race | 1.0 | Pain damage multiplier from father's race |
| `Duration_08_Recovery` | actor/race/global | 1.0 | Recovery phase duration scale |

### Cycle Phases (States 0--3)

The menstrual cycle drives the fertility window and PMS effects.

| MCM Setting | Default | Effect |
|-------------|---------|--------|
| `FollicularDuration` | 5 days | Follicular phase |
| `OvulationDuration` | 2 days | Ovulation (peak fertility) |
| `LutealDuration` | 5 days | Luteal phase |
| `MenstrualDuration` | 2 days | Menstruation |
| `PMSChance` | 25% | Chance PMS triggers during late luteal/menstruation |

| Addon Key | Scope | Default | Effect |
|-----------|-------|---------|--------|
| `Duration_01_Follicular` | actor/race/global | 1.0 | Duration multiplier |
| `Duration_02_Ovulation` | actor/race/global | 1.0 | Duration multiplier |
| `Duration_03_Luteal` | actor/race/global | 1.0 | Duration multiplier |
| `Duration_04_Menstruation` | actor/race/global | 1.0 | Duration multiplier |

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
