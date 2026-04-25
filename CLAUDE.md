# Beeing Female NG

Skyrim SE mod: female reproductive cycle simulation with pregnancy, birth, and child actor management. Hybrid SKSE C++ plugin + Papyrus script system built on CommonLibSSE-NG.

## Build

```sh
# C++ plugin (xmake 2.9.5+, MSVC v143)
xmake f -m release && xmake        # -> dist/Core/skse/plugins/BeeingFemale.dll

# Papyrus scripts (Skyrim SE compiler)
# Project file: skyrimse.ppj
# Sources: dist/Core/source/scripts/*.psc -> dist/Core/scripts/*.pex
```

## Code Conventions

- Papyrus has no `break` or `continue` -- use flags/early returns instead.
- Keep UTF-16 LE BOM encoding for translation files (`dist/Core/Interface/translations/`).
- Keep edits ASCII unless the file already contains non-ASCII.
- `SSEEDIT_locations/` is reference only -- do not compile or import.
- StorageUtil keys use `FW.` prefix. Global lists use `none` as the actor arg.

## Project Structure

```
src/                            C++ SKSE plugin (CommonLibSSE-NG)
dist/Core/
  source/scripts/               71 Papyrus source files (.psc)
  scripts/                      Compiled bytecode (.pex)
  BeeingFemale.esm              Main ESP plugin (quests, forms, factions)
  BeeingFemale/
    AddOn/                      INI add-ons (race, actor, cme, misc, global)
    Couples/                    JSON couple data for import
    HUD/                        Widget layout profiles (default.ini, etc.)
    Names/                      Baby name databases
    Profile/                    Player settings snapshots
  Interface/translations/       Localized strings (20+ languages)
  skse/plugins/                 Compiled .dll output
lib/commonlibsse-ng/            SKSE framework (submodule)
```

## Core Systems & Code Paths

### 1. Game Load / Initialization

Entry: `FWPlayerAlias.OnPlayerLoadGame()` -> `FWSystem.OnGameLoad()`
- `FWAddOnManager.OnGameLoad()` hashes `AddOn/` dir, reloads INIs if changed
- Applies MCM defaults, initializes player/male tracking
- Registers for game-time update events

C++ entry: `main.cpp:SKSEPluginLoad()` -> registers Papyrus native functions, cosave ID `BF10`

### 2. Female Cycle State Machine (`FWAbilityBeeingFemale`)

The core loop. An ActiveMagicEffect on each tracked female that ticks via `OnUpdateGameTime()`.

**States (0-8):**
| State | Name | What Happens |
|-------|------|-------------|
| 0 | Follicular | Early cycle, low fertility |
| 1 | Ovulation | Peak fertility window |
| 2 | Luteal | Post-ovulation |
| 3 | Menstruation | Bleeding, hygiene items, PMS chance |
| 4-6 | Trimester 1-3 | Pregnancy progression, belly/breast scaling, pain |
| 7 | Labor Pains | Multi-stage birth process |
| 8 | Replenish | Post-birth recovery |

Each tick: check duration elapsed -> advance state if done -> apply pain/effects -> update StorageUtil -> refresh widgets.

### 3. Sperm & Impregnation (`FWController`)

Central API for conception logic.

**Flow:** External event (SexLab/OStim orgasm, manual spell) -> `AddSperm` -> sperm stored per-actor with donor/amount/timestamp -> `ActiveSpermImpregnation()` checks fertility window + contraception + conception rate -> on success: creates `FW.ChildFather` entries, emits `BeeingFemaleConception` event, transitions to state 4.

**Sperm lifecycle:** stored amounts degrade over time; water/bathing accelerates washout.

### 4. Pregnancy & Birth

**Pregnancy:** 3 trimesters with progressive belly/breast scaling, baby health tracking (0-100), combat damage to unborn.

**Birth flow:** State 7 -> multi-stage labor (Vorwehen/Eroffnungswehen/Presswehen/Nachwehen) -> `GiveBirth()` -> spawns `FWChildActor` instances -> updates `FW.Babys` global list -> emits `BeeingFemaleLabor` event -> state 8 recovery.

**Abortus:** Miscarriage system triggered by low baby health. States 0-6 (none through stillbirth).

### 5. Child Actor System (`FWChildActor`, `FWChildActorBase`)

Born children as interactive NPCs with:
- Dynamic scaling / growth over configurable time
- 20+ dialogue scripts (`FW_ChildDial*.psc`) for commands (follow, wait, go home, etc.)
- Race inheritance from father, sex determination
- HearthFires adoption faction support

### 6. Add-On Framework (`FWAddOnManager`)

INI-driven extensibility without script editing.
- **Race add-ons** (`FWAddOn_Race`): per-race duration/scale/pain overrides
- **Actor add-ons** (`FWAddOn_Actor`): per-NPC overrides (same knobs as race)
- **CME add-ons** (`FWAddOn_CycleMagicEffect`): assign spells to cycle states
- **Misc add-ons** (`FWAddOn_Misc`): integration hooks (SexLab, OStim, camera, etc.)

Event hooks: `OnGiveBirthStart/End`, `OnLaborPain`, `OnBabySpawn`, `OnMagicEffectApply`

### 7. Integration Layer

- **SexLab** (`BFA_ssl.psc`): hooks orgasm events, Devious Devices awareness, hentairim tag support
- **OStim** (`BFA_Ostim.psc`): API 23+ with NG thread events, condom detection
- **Bathing in Skyrim** (`BFA_BathingInSkyrim.psc`): hygiene/washout interaction

### 8. HUD Widget System

SkyUI-based widgets backed by `BeeingFemaleWidget.swf`:
- `FWStateWidget` -- cycle/pregnancy phase display
- `FWBabyHealthWidget` -- pregnancy chance or unborn health
- `FWContraceptionWidget` -- contraception level/countdown
- `FWPantyWidget` -- menstrual hygiene reminder
- `FWProgressWidget` -- loading/scanning progress
- `FWCoupleWidget` -- debug couple editor
- `FWWidgetController` -- hotkey orchestrator (tap/hold behaviors)

Profiles in `BeeingFemale/HUD/*.ini`, timing in Global Settings INI.

### 9. MCM Configuration (`FWSystemConfig`)

10 pages: Settings, Cycle, Pregnancy, Impregnate, Male, Children, AddOn, Info, Cheat, System. All settings stored as SKSE-persistent properties.

### 10. PMS Effects

10 variant scripts (`BFA_AbilityEffectPMS*.psc`): SexHurt, Algesic, Headache, Lassitude, Depressive, Powerless, Destructive, Faint, Disqualify, HustleBustle. Chance-based during menstruation.

## Key Scripts by Role

| Script | Role |
|--------|------|
| `FWSystem.psc` | Main quest framework, event orchestration |
| `FWController.psc` | Impregnation, conception, state management API |
| `FWAbilityBeeingFemale.psc` | Female cycle state machine (the core loop) |
| `FWAbilityBeeingMale.psc` | Male virility tracking |
| `FWSystemConfig.psc` | MCM configuration (largest script ~6900 lines) |
| `FWAddOnManager.psc` | Add-on discovery, loading, caching |
| `FWChildActor.psc` | Born child actor behavior |
| `FWSaveLoad.psc` | Cosave serialization |

## C++ Native Functions (`src/`)

| Module | Purpose |
|--------|---------|
| `FWUtility.cpp` | File I/O, INI read/write, string ops, form resolution |
| `FWSystem.cpp` | Minimal stubs (most logic moved to Papyrus) |
| `FWChildActor.cpp` | Child actor native bindings |
| `FWChildEnchant.cpp` | Enchantment helpers |
| `FWTextContents.cpp` | Localized string fetching |

## Mod Events API

**Listens for:** `BeeingFemale` command event with string commands: `AddSperm`, `AddContraception`, `WashOutSperm`, `ChangeState`, `DamageBaby`, `HealBaby`, `CheckAbortus`, etc.

**Emits:** `BeeingFemaleConception(Mother, ChildCount, Father0-2)`, `BeeingFemaleLabor(Mother, ChildCount, Father0-2)`

## StorageUtil Keys (prefix `FW.`)

**Per-actor (mother):** `CurrentState`, `StateEnterTime`, `NumChilds`, `UnbornHealth`, `ChildFather` (FormList), `SpermName`/`SpermAmount`/`SpermTime`, `Contraception`, `Abortus`, `Flags`

**Global:** `FW.SavedNPCs` (tracked females), `FW.Babys` (born children)
