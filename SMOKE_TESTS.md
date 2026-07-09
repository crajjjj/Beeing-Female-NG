# Beeing Female NG — AI Smoke Tests

Pre-release checklist. Each scenario should be verified in-game or by code inspection before tagging a release.

**Priority key:** P0 = blocker, P1 = high, P2 = medium

---

## 1. Game Load & Initialization

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 1.1 | P0 | Fresh install — new save, no prior BF data | `OnGameLoad` completes all 51 load states, `bFirstRun` triggers `initArrays`/`giveStartupSpells`, mod events registered | FWSystem, FWPlayerAlias |
| 1.2 | P0 | Existing save — reload with active pregnancy | Timers restored, `InitState()` routes to correct pregnancy state, belly/breast scale intact | FWAbilityBeeingFemale |
| 1.3 | P0 | Missing SKSE plugin or version mismatch | `ModEnabled = 0`, `CloakingSpellEnabled = 0`, error notification shown, no script errors | FWSystem |
| 1.4 | P1 | Missing PapyrusUtil dependency | Same graceful disable as 1.3 | FWSystem |
| 1.5 | P1 | Double `OnGameLoad` re-entrancy | `bFirstRun` still true on `OnUpdate` → second `OnGameLoad` call does not corrupt state | FWSystem |

## 2. Cycle State Machine (States 0–3)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 2.1 | P0 | Full cycle: Follicular → Ovulation → Luteal → Menstruation → Follicular | State transitions at correct day boundaries, `FW.CurrentState` matches, faction updated | FWAbilityBeeingFemale |
| 2.2 | P1 | PMS effects during Menstruation | PMS spell applied with correct chance; **verify PMS flag clears** on exit (known bug: `bHasPMS==false` is comparison not assignment) | FWAbilityBeeingFemale |
| 2.3 | P1 | State spell switching | Exactly one `StatCycleID_List[i]` spell active; `StatMenstruationCycle` marker during 0–3, `StatPregnancyCycle` during 4–8 | FWAbilityBeeingFemale |
| 2.4 | P1 | Invalid state (≥ 9) recovery | Error logged, no hang, state resets to 0 on next tick | FWAbilityBeeingFemale |
| 2.5 | P2 | Chaurus/Estrus override active then removed | External pregnancy freezes `stateEnterTime`; after removal, BF cycle resumes without being stuck | FWAbilityBeeingFemale |

## 3. Sperm & Impregnation

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 3.1 | P0 | AddSperm during Ovulation (peak fertility) | Sperm stored in `FW.SpermName`/`Amount`/`Time`, `ActiveSpermImpregnation` fires, conception possible | FWController |
| 3.2 | P0 | AddSperm outside fertility window | Sperm stored but `canBecomePregnant` returns false, no conception | FWController |
| 3.3 | P1 | Contraception active | `ContraceptionSpermKillTimed` sets killed sperm to `Sperm_Amount_For_Delete` (BELOW the `>=` relevance threshold) → no conception. Previously it set exactly `Sperm_Min_Amount_For_Impregnation`, which every filter accepted — contraception never blocked | FWController |
| 3.4 | P1 | Multiple fathers — weighted selection | `calculateNumChildren` produces 1–3; father picked by classic weighted-by-amount/relevance selection (bounded, no OOB); `FW.ChildFather` populated correctly. `Sperm_Impregnation_Boost` affects conception CHANCE only, not father choice — the old boost-based pick was deterministic (2 donors → always the older one) and paired sorted weights with unsorted donors (inverted `bSort`) | FWController |
| 3.10 | P1 | Any-period conception (`Allow_Impregnation_For_Any_Period`) | Conceives outside the fertility window per the configured chance; emits `BeeingFemaleConception` (was missing); per-donor chance not inherited from the previous donor (stale-variable fix); no OOB at the last donor | FWController `MyActiveSpermImpregnationTimedForAnyPeriod` |
| 3.5 | P2 | Non-lore-friendly pairing | Sperm amount zeroed to `Sperm_Amount_For_Delete`, no conception | FWController |
| 3.9 | P1 | Creature father unloads before conception | `FW.SpermRace` mirror persists donor race. Sperm entries preserved when actor is None. All-None-donors fallback conceives with stored race. MCM cheat bypasses washout delay | FWController, FWUtility |
| 3.6 | P2 | NPC pregnancy disabled in MCM | `cfg.NPCCanBecomePregnant = false` → NPCs skipped, no error | FWController |
| 3.7 | P1 | `BeeingFemaleConception` mod event | Fires with correct Mother, ChildCount, Father0–2 args | FWController |
| 3.8 | P1 | Sperm expiry after 50+ game days | Entries older than `SpermDeleteTime` pruned via `RemoveSpermMirrorAt`, lists stay consistent | FWSaveLoad, FWUtility |
| 3.11 | P1 | Mild Fertility Tonic (magnitude ~2) | `ApplyFertilityTonic` floors magnitude to 2.0 and adds `FW.Fertility` (Gate 2 boost: +6.25%/pt at ovulation, +1%/pt luteal). On an INFERTILE cycle (state <4, `canBecomePregnant`==false) it grants ONE extra `ConceiveChance` Gate 1 roll — a nudge, not a guarantee; does nothing if the cycle is already fertile | FWController `ApplyFertilityTonic`, FWFertilityItem |
| 3.12 | P1 | Potent Fertility Tonic (magnitude ~4) | Same Gate 2 boost PLUS `setCanBecomePregnant(true)` forces the current cycle fertile for the rest of its window | FWController `ApplyFertilityTonic` |
| 3.13 | P2 | Fertility stacking & decay | `AddFertilityTimed` caps at `MaxFertility=8.0`; re-dosing soon adds a prorated slice (floor +1) and refreshes `FW.FertilityTime`; decays over `GetPillDuration` like contraception; `AddFertility` alone never forces fertile (Gate 1 untouched) | FWController `AddFertilityTimed`/`getFertilityTimed` |
| 3.14 | P2 | Tonic reflected in chance preview/widgets | `getRelativePregnancyChance(includeFertility=true)` adds the boost; Baby-Health widget cache key includes quantized fertility; MCM Info page shows `~<ovulation chance>%` only while a tonic is active | FWController, FWBabyHealthWidget, FWSystemConfig |
| 3.15 | P2 | Tonic does not cancel contraception | Active contraception still runs `ContraceptionSpermKillTimed` first; a dosed actor must let contraception lapse before the tonic can help | FWController |
| 3.16 | P1 | Futa donor gated by BF's Allow FF Cum (all paths) | With toggle OFF: female-sexed donor blocked in `processPair` (SexLab separate-orgasm, P+ cum FX, mixed scenes included) and in OStim/mod-event paths. With toggle ON: futa inseminates on every path, including legacy aggregate orgasm (`GetSpermDonorFromList` falls back to a gender-1 donor when no male present). SexLab's own `allowFFCum` config is no longer consulted — P+ has no MCM for it | BFA_ssl, BFA_Ostim |
| 3.17 | P1 | Futa pregnancy toggle (`FutaPregnancy`, MCM Settings) | Toggle OFF: female in the SOS schlongified faction (0xAFF8, Schlongs of Skyrim.esp — verified vs shipped esp) OR in TNG's `TNG_Gentified` FormList (0xE00, TheNewGentleman.esp; holds actor refs, base checked as fallback) returns -13 from `IsValidateFemaleActor` — not tracked, no cycle spell from cloak/scan, existing tracked futa drops on re-scan. **Sire-only must still work**: donor-side validation passes `bIgnoreFuta=true` (BFA_ssl/BFA_Ostim `processPair`, `onAddSperm`, `onAddActorSperm`) so with Allow FF Cum ON a futa inseminates while herself excluded. Toggle ON (default) or neither mod present: behavior identical to before. Combos: on/on=both, FF on/this off=sire-only, both off=excluded | FWSystem, FWSystemConfig, BFA_ssl, BFA_Ostim |

## 4. Pregnancy & Birth (States 4–8)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 4.1 | P0 | Full pregnancy: Tri 1 → 2 → 3 → Labor → Replenish → Follicular | All transitions fire, belly/breast scaling progresses and resets | FWAbilityBeeingFemale, FWController |
| 4.2 | P0 | Labor multi-stage sequence | Vorwehen → Eroffnungswehen → Presswehen → Nachwehen complete, animations play. Birth_S2/S3 decoupled from pain gate (commit 4ecc49e) | FWController |
| 4.3 | P0 | GiveBirth spawns correct children | Live births added to `FW.Babys`, stillbirths excluded; `BeeingFemaleLabor` fires at labor start; `FW.NumBabys` counts live births only | FWController, FWSystem |
| 4.4 | P1 | GiveBirth re-entrancy guard | Second `GiveBirth` within 0.25 days blocked by `FW.GivingBirth` FormList | FWController |
| 4.5 | P1 | GiveBirth after crash/reload | Stale `FW.GivingBirth` clears after 0.25-day window, birth proceeds normally | FWController |
| 4.6 | P1 | State 8 faction sync after birth | `FW.CurrentState = 8` written directly — verify `UpdateParentFaction` also fires | FWController |
| 4.7 | P1 | Combat damage to unborn | `DamageBaby` reduces `UnbornHealth`; at zero, miscarriage triggers | FWController |

## 5. Miscarriage (Abortus)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 5.1 | P1 | Abortus during Trimester 1 | `abortus > 1` blocks advance to states 4–6, returns to cycle | FWAbilityBeeingFemale |
| 5.2 | P1 | Stillbirth during Trimester 3 | `abortus > 2` blocks state 7, notification shown | FWAbilityBeeingFemale |
| 5.3 | P2 | Abortus disabled in MCM | `cfg.abortus == false` → suppressed regardless of health | FWController |

## 6. Male Virility

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 6.1 | P1 | Virgin male (never had sex) | `GetVirility` returns 1.0 (full) | FWController |
| 6.2 | P1 | Virility immediately after sex | Returns near floor (0.02), sperm amount scaled low | FWController |
| 6.3 | P0 | Virility recovery over time | **Check operator precedence**: formula is `GameDaysPassed - LastSexTime / recoveryDays` — division binds before subtraction, likely producing wrong results | FWController |
| 6.4 | P2 | Male recovery scale stacking | `ActorMaleRecoveryScale` from addon applied correctly on top of base recovery | FWController, FWAddOnManager |
| 6.5 | P2 | Sex-changed actor (male → female) | `BeeingMaleSpell` dispelled, `BeeingFemaleSpell` applied on next update tick | FWAbilityBeeingMale |

## 7. Child Actor System

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 7.1 | P0 | Child spawned with correct parents | `Mother`/`Father` set, relationship ranks assigned, `FW.Babys` updated | FWChildActor |
| 7.2 | P1 | Child growth over time | `UpdateSize()` interpolates from `_SmallSizeScale` to `modifiedFinalScale` over duration | FWChildActor |
| 7.3 | P1 | Fully grown child (grow-up toggle OFF) | Growth flag cleared, `Manager.AddToSLandBF` called, scale stable, actor stays a child — see §22 for toggle ON | FWChildActor |
| 7.4 | P2 | Child perks from INI | `GivePerks()` iterates `ChildPerkFile[0..127]` without array overrun | FWChildActor |
| 7.5 | P1 | Child deletion | State → `MarkForDelete` → disabled → removed from `FW.Babys` → `Delete()` | FWChildActor |
| 7.6 | P2 | Child dialogue commands | Follow, wait, go home orders dispatch via `Order` setter | FWChildActor, FW_ChildDial* |
| 7.7 | P2 | Race inheritance from father | Child race matches father where addon permits | FWChildActor |
| 7.8 | P0 | Save/reload with active children | `InitChild()` restores StorageUtil values, name, factions, scale | FWChildActor |
| 7.9 | P2 | Delete all children (`deleteChildren`) | All four entry types removed (FWChildActor, FWChildItem, plain Actor, **armor base** for item babies); player's carried baby items removed; `FW.BabyItem*` identity lists cleared; no FormList orphans | FWSaveLoad |
| 7.10 | P1 | Baby item hatches into the SAME baby | Item born as "Sofie (girl)" hatches into a girl named Sofie; race context (incl. creature father race) carried from birth via mother-keyed `FW.BabyItem*` lists; item sex roll uses configurable `ResolveChildGender`, not a fixed 53% | FWSystem, FWAbilityBeeingFemale |
| 7.11 | P1 | Twin baby items (shared armor base) | Two `FW.Babys` entries + two identity entries; each hatch consumes one identity FIFO (birth order); both children get distinct recorded names/sexes; per-baby DOB (no shared `FW.ChildArmor.dob` last-writer-wins) | FWAbilityBeeingFemale, FWUtility |
| 7.12 | P1 | Legacy baby item (born pre-3.5.1) | No `FW.BabyItemArmor` entry → hatch falls back to shared `FW.ChildArmor.*` keys (old behavior: re-rolled name/sex); no errors, item still hatches | FWAbilityBeeingFemale |
| 7.13 | P2 | MCM baby item rows | Children tab shows the recorded baby name + per-baby countdown from birth-time DOB; legacy items show armor name + shared dob ("Paused" until first equip) | FWSystemConfig |

## 8. NPC Scanning & Spell Application

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 8.1 | P0 | Scan finds nearby females | `FindActors` quest runs, up to 7 aliases filled, `BeeingFemaleSpell` applied | FWPlayerAlias |
| 8.2 | P1 | Scan finds nearby males | `BeeingMaleSpell` applied to valid males | FWPlayerAlias |
| 8.3 | P1 | Actor exclusions | Children, ElderRace, ElderRaceVampire excluded by `ValidateActor` | FWPlayerAlias |
| 8.4 | P2 | Location change triggers rescan | `OnLocationChange` → 0.25s delay → Processing → new scan | FWPlayerAlias |
| 8.5 | P1 | Male actor spell path correctness | Males get `BeeingMaleSpell` not `BeeingFemaleSpell` (known copy-paste risk in `ProcessActor`) | FWPlayerAlias |
| 8.6 | P1 | Mannequin exclusion | Validators return -12 for race Name+EditorID containing Manakin (vanilla misspelling), Manikin (USMP), Mannequin, or Femmequin — vanilla mannequins were previously NOT matched ("Mannequin" never occurs in the vanilla record). Info spell reports "is a mannequin", not "is a child" | FWSystem `IsMannequinRaceName` |
| 8.7 | P2 | Last-seen scan ignores creatures | `getLastSeenNPCs` passes the ActorTypeNPC keyword to `ScanCellNPCs` so creatures (and the scanned woman herself) don't consume the 10-slot cap in farms/stables/caves | FWAbilityBeeingFemale |
| 8.8 | P2 | Sleep partner scan is capped | `findSleepPartner` validates closest + at most 5 more cell actors (skipping the already-tried closest); creatures stay in the pool for CreatureSperm setups | FWAbilityBeeingBase |
| 8.9 | P1 | Temporary refs never ambient-tracked | BOTH ambient discovery paths — the cloak (FWCloaking) and the FindActors alias scan (FWPlayerAlias.ProcessActor) — skip actors with FF-prefixed FormIDs (signed int in [-16777216, -1]), so runtime leveled spawns get no cycle/male spells and their engine-side deletion can't orphan ActiveMagicEffect instances. Exemption: FF refs that are `IsPlayerTeammate()` or in FollowerFaction (spawned companions) ARE tracked. BF's own spawned children still reach the custom-child recast; sex-scene paths (BFA_ssl/BFA_Ostim) are deliberately unaffected. The two gates must stay in sync | FWCloaking, FWPlayerAlias |
| 8.10 | P2 | Last-seen scan throttled per woman | `getLastSeenNPCs` runs at most once per game hour per actor (`FW.LastSeenScan`) — door-hopping no longer triggers one cell scan per tracked woman per load screen. A stored 0.0 means never-scanned and does NOT throttle (new-game first hour would otherwise suppress every first scan) | FWAbilityBeeingFemale |
| 8.11 | P1 | Effect (re)start has no fixed wait, belly still re-applies | `OnEffectStart` no longer runs `Utility.Wait(1.0)`, but `SetBelly()` stays (OnEffectFinish's ResetBelly clears the morph at teardown; mode-1 node scaling never survives 3D reload — a loaded pregnant NPC must not stay flat until her next game-hour tick). `RemoveSPIDitems` runs outside the `Is3DLoaded` gate (inventory ops don't need 3D); the tick's `InstantBornChilds` branch covers `currentState>7` as the fallback for a 3D-load race at effect start. Verify no suspended `FWAbilityBeeingFemale` stacks pile up in saves after heavy load-door traffic | FWAbilityBeeingFemale |

## 9. Save/Load & NPC Persistence

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 9.1 | P0 | Per-actor state survives save/reload | `FW.SavedNPCs` FormList + all per-actor StorageUtil keys intact | FWSaveLoad |
| 9.2 | P1 | NPC time-skip > 60 game days | `UpdatePerDay` skips catchup, calls `CreateFemaleActor(Woman, true)` to reset instead | FWSaveLoad |
| 9.3 | P1 | NPC pill auto-consumption | NPC with pill items: pill consumed when `contraceptionTime + (duration * 0.85) < currentTime`, `FW.Contraception` increases | FWSaveLoad |
| 9.4 | P1 | Delete actor cleans all keys | `Delete(Woman)` removes all `FW.*` StorageUtil keys, no orphaned data | FWSaveLoad |
| 9.5 | P1 | Reset NPC data preserves player | `ResetNpcData(false)` clears all NPCs, player re-added to `FW.SavedNPCs` | FWSaveLoad |
| 9.6 | P1 | `hasWillBecomePregnant()` return path | Function has no explicit `return false` — returns `None` implicitly if actor is not pregnant; verify callers handle this | FWSaveLoad |
| 9.7 | P1 | Idle-untrack drains in batches | `FWSystem.OnUpdate` walks up to 10 `FW.SavedNPCs` slots per tick, drops up to 5 untrack-eligible idle women, and still runs at most ONE `Data.Update` per tick. Probing the player ends the scan (player-only list costs 1 probe, not 10). Untrack also clears `FW.LastSeenScan`/`FW.LastSeenNPCs`/`FW.LastSeenNPCsTime` | FWSystem |
| 9.8 | P2 | Tracking add is idempotent and race-proof | `CreateFemaleActor` (re)asserts `FW.SavedNPCs` membership unconditionally with `FormListAdd(..., false)` — no duplicates ever, and a `TryUntrackIdleFemale` interleaving between the `hasSaved` read and the add can no longer strand fresh cycle keys on an untracked woman. `FWSaveLoad.Delete` removes ALL list instances (allInstances=true) so legacy duplicate entries purge in one pass, and also clears `FW.LastLoaded`/`FW.LastSeenScan`/last-seen pools | FWController, FWSaveLoad |

## 10. Equip/Unequip & Consumables

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 10.1 | P1 | Equip tampon/napkin during menstruation | `Effect_VaginalBloodLow` and `Effect_VaginalBloodHigh` dispelled, panty widget hides | FWPlayerAlias |
| 10.2 | P1 | Equip **bloody** tampon/napkin variant | **Gap**: bloody variants do NOT trigger blood effect dispel — verify this is intentional or fix | FWPlayerAlias |
| 10.3 | P2 | Unequip tampon during menstruation | Blood effects should reappear; currently only widget updates, visual may be missing | FWPlayerAlias |
| 10.4 | P2 | Panty widget states | Menstruation + nothing = STATUS_NEEDED; + normal item = hidden; + bloody item = STATUS_BLOODY | FWPantyWidget |
| 10.5 | P2 | `RemoveSPIDitems(woman)` | Removes normal tampons only, not called spuriously on actors who should keep them | FWSystem |
| 10.6 | P2 | Infection spell + HealDrink cure | Consuming a `HealDrink[]` item dispels `FWInfectionSpell`; non-HealDrink potions do nothing | FWInfectionSpell |
| 10.7 | P2 | Infection damage escalation | Damage scales 1.0 → 2.5 per tick over time, baby health decreases | FWInfectionSpell |

## 11. Add-On Framework

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 11.1 | P0 | Addon INI loading on first run | `RefreshAddOnH` scans `AddOn/` folder, loads all enabled INIs by type | FWAddOnManager |
| 11.2 | P1 | Addon hot-reload on hash change | Directory hash changes between saves → full refresh triggered | FWAddOnManager |
| 11.3 | P1 | Missing required mod dependency | Addon with unmet `required` field skipped, no script error | FWAddOnManager |
| 11.4 | P2 | Race addon overrides | Per-race duration/scale/pain values applied to cycle | FWAddOn_Race |
| 11.5 | P2 | CME addon spells | Cycle-state magic effects cast/dispelled on transitions | FWAddOn_CycleMagicEffect |
| 11.6 | P2 | Global addon settings | `FW.AddOn.Global_*` StorageUtil keys populated from global INI | FWAddOnManager |

## 12. Integration — SexLab

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 12.1 | P0 | SexLab legacy orgasm → AddSperm | `OrgasmStart`/`HookOrgasmStart` hooked, father/amount correct | BFA_ssl |
| 12.2 | P0 | SexLab P+ 2.17.1+ orgasm → AddSperm | `SexLabApplyCumFX` event path used when `SexLabUtil` plugin ≥ 34668560 | BFA_ssl |
| 12.3 | P1 | Oral cum type skipped | P+ path: `aiType == 2` (oral) → no sperm added | BFA_ssl |
| 12.4 | P1 | Anal cum with `NoVaginalCumChance` | `aiType == 1` (anal) → proceeds only if `RandomInt(1,100) <= cfg.NoVaginalCumChance` | BFA_ssl |
| 12.5 | P1 | Devious Devices belt blocks vaginal | `zad_DeviousBelt` keyword → sperm blocked | BFA_ssl |
| 12.6 | P2 | DD anal plug + vaginal animation | Anal plug does NOT block vaginal sperm (only blocks if `bool_cameInsideAnal`) | BFA_ssl |
| 12.7 | P1 | Creature sperm | Blocked unless `cfg.CreatureSperm == true` | BFA_ssl |
| 12.8 | P1 | Birth prevents SexLab scene | `OnGiveBirthStart` adds mother to `AnimatingFaction`; `OnGiveBirthEnd` removes | BFA_ssl |
| 12.9 | P2 | Hentairim tag fallback | Animation with no Hentairim stage tags falls back to `hasTag("Vaginal")`/`hasTag("Anal")` | BFA_ssl, FWHentairimUtils |

## 13. Integration — OStim

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 13.1 | P0 | OStim NG orgasm → AddSperm | Sperm path uses `FertilityModeAddSperm` compat event (OStim sends this natively); `ostim_start` is only a child-actor guard | BFA_Ostim |
| 13.2 | P1 | OStim API version < 23 | Graceful no-op: retries 10× at 5s intervals, then gives up silently | BFA_Ostim |
| 13.3 | P1 | Condom detection | `System.CheckForCondome(Female, Male)` → pair skipped when condom worn | BFA_Ostim |
| 13.4 | P1 | Child actor in OStim scene | Actor in `FW.Babys` FormList → `OStim.ForceStop()` called | BFA_Ostim |
| 13.5 | P2 | FF (female-female) cum | Only proceeds if `cfg.AllowFFCum == true` and "male" passes `IsValidateFemaleActor` | BFA_Ostim |
| 13.6 | P2 | `FertilityModeAddSperm` compat event | External Fertility Mode event received and processed correctly | BFA_Ostim |

## 14. Integration — Other Mods

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 14.1 | P2 | Bathing in Skyrim washout | Bathing event triggers `WashOutSperm` with appropriate reduction | BFA_BathingInSkyrim |
| 14.2 | P2 | SlaveTats birth count tattoos | MCM toggle off by default. Enable → tattoos composed from 1/2/3/4/8/12 denominations. Disable → removed immediately. Requires SlaveTats.esp | FWController, FWSystemConfig |
| 14.3 | P2 | SlaveTats semen circle | Regular semen circle when cum inside, hearts variant during ovulation. Applied on AddSperm, updated on WashOut, removed on toggle-off. MCM Refresh re-applies even when `FW.SemenTattooState` is unchanged (force flag) | FWController, FWSystemConfig |
| 14.4 | P2 | SlaveTats womb state tattoo ("BF Womb tattoo" pack, section "BF PW") | Exactly one tattoo at a time, swapped only on state change (`FW.WombTattooState`): baseline/ovulation; semen fill tiers by summed viable amount (normal 3/9/full, ovulation 3/11/full/full2); fertilization for first day of trimester 1 then phases 1–3; 2/3/4Babies from trimester 2 when multiples (`FW.NumChilds`, not the lifetime `FW.NumBabys` tally); Birth in labor; back to baseline in recovery. Player only (gate inside `ApplyWombTattoo`); updates each tick and on sperm/birth events. Toggle-off removes the current tattoo; MCM Refresh re-applies even when `FW.WombTattooState` is unchanged (force flag). Textures (BC7 2048) ship via the optional FOMOD "SlaveTats Tattoo Packs" step, visible/pre-selected only when SlaveTats.esp is active | FWController, FWSystemConfig, FWAbilityBeeingFemale, ModuleConfig.xml |
| 14.5 | P2 | Womb tattoo NPC opt-in (`Global_WombTattooNPCs`) | Default OFF → womb tattoo player-only. Set `=true` in `Default Global Settings.ini` → `ApplyWombTattoo` also broadcasts to tracked female NPCs (gated by `WombTattooNPCsAllowed`). MCM "Refresh Tattoos" runs `RefreshWombTattooNPCs`: re-applies to NPCs when ON, strips leftover overlays from them when OFF. Player handled separately. Requires SlaveTats.esp | FWController `ApplyWombTattoo`/`RefreshWombTattooNPCs`, FWAddOnManager |

## 15. HUD Widgets

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 15.1 | P1 | Cycle widget updates on state change | `FWStateWidget` reflects current state icon/text | FWStateWidget |
| 15.2 | P1 | Baby health widget during pregnancy | Shows unborn health 0–100 | FWBabyHealthWidget |
| 15.3 | P2 | Contraception widget countdown | Shows level and remaining duration | FWContraceptionWidget |
| 15.4 | P2 | Widget hotkey toggle | Tap/hold behaviors show/hide correctly | FWWidgetController |
| 15.5 | P2 | HUD profile load | `BeeingFemale/HUD/*.ini` profiles apply correct layout | FWWidgetController |

## 16. Couple System

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 16.1 | P2 | Spouse auto-detection | `GetRelationshipRank >= 4` or `HasAssociation(Spouse)` within 1000 units → husband set | FWCoupleWidget |
| 16.2 | P2 | Couple JSON persistence | `BeeingFemale/Couples/<ModID>_<FormID>.json` created with Husband, Affairs, Partners | FWCoupleWidget |
| 16.3 | P2 | Stale husband form (mod removed) | `GetFormValue` returns None while `HasFormValue` true → should not cause infinite 5s polling | FWCoupleWidget |
| 16.4 | P2 | CoupleMaker off by default | MCM Cheat toggle starts off (and resets off on every game load via `OnGameLoad`); panel hidden at init (no lingering empty frame), hotkeys do nothing while off | FWCoupleWidget, FWSystem |
| 16.6 | P2 | MCM toggle shows/hides panel | Enable → empty editor panel appears reading "Look at a woman + hold E"; disable → hides instantly (no stale NPC text on re-enable); H/G/P held before a woman is selected shows a hint notification | FWCoupleWidget |
| 16.7 | P2 | Invalid targets rejected | Validator gates compare `>0`: mannequins/children/creatures can't be selected or set as Husband/Affair/Partner; H on an invalid target with rank >=0 unsets Husband (previously dead code) | FWCoupleWidget |
| 16.5 | P1 | Auto-insemination uses partners independently of affairs | Daily couples pass: a woman with assigned Partners but NO Affairs still gets her partners in the weighted donor pool (2× each). Previously the Partners branch was gated on the Affairs count (`ca>0`) so partners-only couples were skipped | FWSystem (daily impregnation) |

## 17. MCM Configuration

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 17.1 | P0 | All 10 MCM pages render | Settings, Cycle, Pregnancy, Impregnate, Male, Children, AddOn, Info, Cheat, System — no script errors | FWSystemConfig |
| 17.2 | P1 | Settings persist across save/load | SKSE-persistent properties survive save cycle | FWSystemConfig |
| 17.3 | P2 | Cheat page: force state change | Manual state override applies correctly. Null checks on crosshair target (commit 530c34a) | FWSystemConfig |
| 17.5 | P1 | Cheat page: force impregnation with creature | MCM cheat passes `bShowTravelingSperm=true` to bypass washout delay. Creature father found immediately | FWSystemConfig |
| 17.6 | P2 | PlayAnimations toggle | FNIS gate removed — Nemesis users can enable (commit 530c34a) | FWSystemConfig |
| 17.4 | P2 | System page: mod reset | Full reset clears StorageUtil, re-runs init | FWSystem |
| 17.7 | P2 | VisualScaling index survives SLIF removal | A save/profile carrying VisualScaling=5 (BodyMorph, 6-entry SLIF list) into a non-SLIF setup is clamped to the 5-entry list's BodyMorph index — Pregnancy page menu renders, no array OOB | FWSystemConfig `SetVisualScalingOptions` |

## 18. Mod Events API

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 18.1 | P1 | External `BeeingFemale` → `AddSperm` | Mod event received, sperm added to target | FWController |
| 18.2 | P1 | External `BeeingFemale` → `ChangeState` | State transition applied | FWController |
| 18.3 | P1 | External `BeeingFemale` → `DamageBaby`/`HealBaby` | Unborn health modified within bounds | FWController |
| 18.4 | P2 | Emitted `BeeingFemaleConception` | Args (Mother, ChildCount, Fathers) correct and parseable by external mods | FWController |
| 18.5 | P2 | Emitted `BeeingFemaleLabor` | Args correct, fires at start of `GiveBirth` (before child spawning loop) | FWController |
| 18.8 | P1 | `AddSperm` with invalid male donor | Mod event with a mannequin/dead/forbidden donor is rejected (`validateM2>0`); previously any negative validation code passed as truthy and stored sperm | FWSystem `onBeeingFemaleCommand` |
| 18.6 | P2 | External `BeeingFemale` → `AddFertility` | Raw Gate 2 boost added via `AddFertility`; does NOT touch the per-cycle fertile flag; capped at 8 | FWController `AddFertility`, FWSystem |
| 18.7 | P2 | External `BeeingFemale` → `DrinkFertilityTonic` | Routes through `ApplyFertilityTonic`: numArg <3.5 = mild (boost + one Gate 1 nudge), ≥3.5 = potent (boost + forces this cycle fertile) — parity with the in-game potion | FWController `ApplyFertilityTonic`, FWSystem |

## 19. SPID Item Distribution

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 19.1 | P1 | Female NPCs receive items | Contraception (10%), tampons (40–50%), panty (20%) distributed per rules | SPID INI |
| 19.2 | P1 | Bandits/Forsworn excluded | No contraception or tampons on bandit/forsworn NPCs | SPID INI |
| 19.3 | P1 | Mannequins excluded | No items on mannequin actors — filters use wildcards `-*Manakin*,-*Manikin*,-*Mannequin*,-*Femmequin*` (the old exact `-MannequinRace` matched nothing: the vanilla EditorID is `ManakinRace`) | SPID INI |
| 19.4 | P2 | Merchant stock | `JobMerchantFaction` members have all consumable types (2–6 units, 100%) | SPID INI |
| 19.5 | P2 | `_BF_ContraceptionHighest` requires addon | Only appears when `BeeingFemaleBasicAddOn.esp` loaded; absent without it | SPID INI |
| 19.6 | P2 | Males receive no items | No male distribution rules — confirm males are clean | SPID INI |
| 19.7 | P2 | Fertility Tonics distributed | `_BF_FertilityTonicMild`/`_BF_FertilityTonicPotent` seeded to female NPCs (loot, same odds as ContraceptionLow/Medium) and `JobMerchantFaction` vendors (6/4 units, 100%), referenced by EditorID (FormIDs assigned by `BF_GenerateFertilityPotion.pas`) | SPID INI |

## 20. C++ Native Plugin

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 20.1 | P0 | Plugin loads on game start | `SKSEPluginLoad` succeeds, cosave ID `BF10` registered | main.cpp |
| 20.2 | P0 | Papyrus native functions registered | `FWUtility`, `FWChildActor`, `FWTextContents` bindings available | src/*.cpp |
| 20.3 | P1 | `GetDirectoryHash` stable | Same folder → same hash; changed file → different hash | FWUtility.cpp |
| 20.4 | P1 | `AddSpermMirror`/`RemoveSpermMirrorAt` | FormList stays sorted and consistent with Amount/Time lists | FWUtility.cpp |
| 20.5 | P2 | INI read/write | `getIniCBool/String/Int/Float` return correct values | FWUtility.cpp |
| 20.6 | P2 | Localized string fetching | Correct strings for all 20+ translation files | FWTextContents.cpp |

## 21. PMS Effects

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 21.1 | P1 | All 10 PMS variants apply/remove cleanly | Effect applied on enter, actor values restored on `OnEffectFinish` | BFA_AbilityEffectPMS* |
| 21.2 | P1 | PMSAlgesic resistance restore | -30% resistances saved at start, restored exactly on finish (test with 0 base resist) | BFA_AbilityEffectPMSAlgesic |
| 21.3 | P1 | PMSFaint stamina drain | Drain every 2 game-hours, stamina hits floor but actor does not die | BFA_AbilityEffectPMSFaint |
| 21.4 | P2 | PMSSexHurt during SexLab P+ | Uses `HookStageStart`/`HookOrgasmStart` which P+ still sends — works with both legacy and P+ | BFA_AbilityEffectPMSSexHurt |
| 21.5 | P2 | PMSSexHurt position check | Damage only for position index 0 (receiver); initiator takes no damage | BFA_AbilityEffectPMSSexHurt |

## 22. Child → Adult Transition (Grow-Up)

MCM "Children grow into adults" (Children page, default OFF) or add-on `GrowUpToAdult` keys. Path A = in-place graduation (`!IsChild()`, the no-add-on default); Path B = base-swap (child-race base from a BabyActor add-on).

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 22.1 | P0 | Toggle OFF (default) | Maturity behavior identical to pre-feature: final scale, no transition, no new factions — save-compat baseline | FWChildActor, FWSystem |
| 22.2 | P0 | Path A in-place graduation | Same actor keeps name/inventory/relationships/orders; HearthFires adoption factions removed; vanilla PotentialFollower(0) + CurrentFollower(-1) factions added — "Follow me" dialogue appears (voice permitting); still listed in MCM Children tab | FWSystem `GrowChildToAdult` |
| 22.3 | P0 | Path B base-swap | Adult spawns at child's spot from AdultActor INI list (or same-sex parent fallback); name "X Dovahkiir", inventory, `FW.Child.*` keys transferred; vanilla PotentialFollower(0) + CurrentFollower(-1) added — "Follow me" recruits them; child deleted via `DeleteChild`/MarkForDelete; `FW.Babys` holds adult, not child | FWSystem, FWChildActor |
| 22.4 | P1 | Shipped "BF Adult Pack" add-on (Default Adult Actors.ini + BeeingFemaleAdultPack.esp) | All 10 races resolve a BFAP_* base: proper name (no "Prisoner"), no dark face, dressed (farm clothes / AdultOutfit / roughspun), baked follower voice, follower dialogue available, sandboxes when unrecruited; deleting the INI restores parent-base fallback | FWAddOnManager, Default Adult Actors.ini, Adult Pack esp |
| 22.5 | P1 | Voice survives save/reload | `FW.Child.VoiceType` re-applied to voiceless base by `OnGameLoad` FW.Babys walk on every load | FWSystem |
| 22.6 | P1 | Custom (non-FWChildActor) child sex/race | Daughter grows into a FEMALE adult — sex/race derived from the actor base, not the absent `FW.Child.Flag`/`FW.Child.Race` keys | FWSystem `GrowChildToAdult` |
| 22.7 | P1 | Transition failure retries | Parents unloaded + no add-on base at maturity → `AbortGrowUp` re-arms `StartGrowing`; FWChildActor retries next game-time tick, custom child retries on effect restart; after 10 failures `FW.Child.GrowUpFailed=1` and the child permanently stays a grown child (terminal, logged) | FWSystem, FWChildActor |
| 22.8 | P1 | Re-entrancy at maturity | OnLoad + OnUpdateGameTime double-fire → `AdjustIntValue` guard yields exactly ONE adult; flag pinned back to 1 by the losing thread | FWSystem `GrowChildToAdult` |
| 22.9 | P1 | Creature children exempt | Race without `ActorTypeNPC` → no transition ever: order spells keep working, no follower/marriage factions, scale ramp only | FWSystem `GrowChildToAdult` |
| 22.10 | P1 | Grown adults: scene eligibility + retained commands | OStim scenes NOT force-stopped (`GrownUp` check); parent order powers still target grown adults of both paths: teleport orders (come here / go home / meet point) work via direct MoveTo, BF follow order only sets the teammate flag (no follow package — actual following via vanilla "Follow me"); BF command dialogue absent (child-race actor replaced; in-place graduates never had it); `OnUpdateGameTime` maintenance continues for in-place graduates, skipped only for the condemned Path B child (`MarkForDelete` state) | BFA_Ostim, FWSpellChildOrder, FWChildActor |
| 22.11 | P2 | Marriage INI flag | `Global_AllowAdultMarriage` absent → adult has no PotentialMarriageFaction even when the parent base had it; `=1` in a global add-on INI → Mara dialogue appears (voice permitting; MaleKhajiit has no marriage lines) | FWSystem `ApplyAdultFactions` |
| 22.12 | P2 | Add-on INI removal | Deleting/disabling an AdultActor INI → `ClearRaceAddOns` wipes `AdultActor_*`/`AdultActorVoice_*` lists and `GrowUpToAdult` on races at next refresh — no stale bases | FWAddOnManager |
| 22.13 | P2 | Parent-base fallback gates | Same/opposite-sex parent base used only if it is NOT the player and NOT unique (`IsUnique`) — no player clones, no second Lydia; opposite-sex parent additionally requires matching base sex; all rejected → abort/retry, child stays | FWSystem `GrowChildToAdult` |
| 22.14 | P2 | NPC×NPC parents | Transition fires off-screen; adult sandboxes on inherited/preset packages; not listed in player's Children tab | FWSystem |
| 22.15 | P2 | Already-grown custom adult on cell load | `FinalizeMature` re-runs on effect restart → `GrownUp==1` early return: no re-transition, no repeated gate cost | FWDefaultCustomChildEffect |
| 22.16 | P2 | Mod reset (`deleteChildren`) | Grown adults are BF-spawned and ARE deleted on reset/uninstall — intended; dissolves a marriage to one | FWSaveLoad |
| 22.17 | P2 | MCM growth tracking | Children tab value column shows remaining time to maturity per child (FWChildActor: `SizeDuration`×scale; custom: mature-time slider), "Grown" at full size, current location name for grown-up adults; baby items keep their hatch countdown | FWSystemConfig `GetChildGrowthStatus` |
| 22.18 | P1 | Trained stats carry into the adult | Train a FWChildActor's skills via the skill menu → the Path B adult has those values (`FW.Child.Stat*` → `SetActorValue`, zeros skipped); custom children keep the base's defaults | FWSystem `CopyTrainedStat` |
| 22.19 | P2 | `AdultOutfit_*` INI keys | Race/actor/global outfit key → add-on-base adult wears it via `SetOutfit` (no roughspun tunic); no key → tunic fallback; parent-base copies unaffected | FWAddOnManager `GetAdultOutfit`, FWSystem |
| 22.20 | P1 | Retroactive grow-up (Cheat page) | "Grow up children now" transitions every already-fully-grown child; honors the same gate as the automatic path (incl. `-1` blocks); skips grown-up/failed/creature entries and baby items; notification shows the count; page refreshes | FWSystemConfig `GrowUpGrownChildrenNow` |
| 22.21 | P1 | `GrowUpToAdult = -1` hard block | Actor-level `-1` keeps that parent's children child forever even with the MCM toggle ON; race-level `-1` likewise; actor `1` overrides race `-1`; legacy `=true` INIs still read as 1 | FWAddOnManager `ActorGrowUpToAdult` |
| 22.22 | P2 | Grow-up notification | Player children show "<name> has grown into an adult" on both transition paths; NPC×NPC children stay silent | FWSystem `GrowChildToAdult` |
| 22.23 | P1 | Children-page grow/hatch selector | Dropdown lists the player's not-yet-grown NPC-race children (with status) and carried baby items (recorded names; twins map to their own FIFO identity entries); button disabled until a selection is made and asks for confirmation; mid-growth in-place child force-grows WITH final scale and stopped growth machinery; baby item hatches into the recorded baby and the item is consumed; legacy item hatches old-style; selection resets when leaving the page; creatures and grown adults are not listed | FWSystemConfig `BuildGrowTargets`/`TextGrowSelected`, FWSystem `ForceGrowChildToAdult` |
| 22.24 | P0 | Born children grow over the configured Mature Time | `InitChild` seeds `_SizeDuration` from `ActorCustomMatureTimeInHours(none)/24` (unscaled base days); `UpdateSize` applies `ActorMatureTimeScale` separately. A newborn no longer snaps to full size — or, with grow-up ON, to an adult — on its first growth tick. Was: `_SizeDuration` never assigned → 0 → `modifiedSizeDuration` 0 → instant. Affected FWChildActor-script children only; custom/plain-actor children were always fine | FWChildActor `InitChild`/`UpdateSize` |
| 22.25 | P1 | Grow-up never leaves kid + adult together | `GrowChildToAdult` (Path B) calls `child.Disable(true)` immediately after the adult is placed, before the deferred `DeleteChild` (MarkForDelete, ~3s). Even if the real `Delete` is blocked (HearthFires adoption alias) or interrupted by a cell change, the child is hidden at once | FWSystem `GrowChildToAdult` |
| 22.26 | P1 | Grown-adult protection (`Global_ProtectGrownAdult`) | Global-only INI tri-state applied at transition: `1` = `SetProtected(true)`; `-1` = `SetProtected(false)`+`SetEssential(false)` (fully killable); `0` (default) = leave the ESP base flag untouched. A base shared with a LIVING parent (parent-clone fallback) is never flipped | FWSystem `ApplyAdultFactions`, FWAddOnManager `GrownAdultProtectMode` |
| 22.27 | P2 | Living grown-up in the info window | Info spell / MCM on a LIVING grown-up shows normal male/female NPC info (cycle/pregnancy/virility), not the child card, with lineage appended inline ("(child of A & B)"); a DEAD grown-up keeps the child card (lineage + death age) | FWController `showRankedInfoBox` |
| 22.28 | P2 | Deceased children in MCM Children tab | Dead children (incl. dead grown adults) show "Dead" via `GetChildGrowthStatus`; the display loop and the click handler both include dead entries so row indexes stay aligned; "Remove deceased children" runs `PruneDeceasedChildren` (player's dead children only, backwards iteration, Disable+Delete, dropped from `FW.Babys`) | FWSystemConfig `GetChildGrowthStatus`/`PruneDeceasedChildren` |

---

## 23. Known Bugs & Fragile Areas

These are confirmed or high-confidence issues found during code inspection. Each should be triaged as fix-or-accept before release.

| # | P | Issue | Location | Impact |
|---|---|-------|----------|--------|
| 23.1 | ~P1~ | ~~**PMS flag: comparison instead of assignment** — `bHasPMS==false` does not clear the flag~~ **FIXED** | FWAbilityBeeingFemale | 6 occurrences changed `==` to `=` |
| 23.2 | ~P0~ | ~~**Virility operator precedence** — missing parentheses around subtraction~~ **FIXED** | FWController `GetVirility` | Added parens: `(GameDaysPassed - LastSexTime) / (recovery * scale)` |
| 23.3 | P2 | **ProcessActor female branch missing cleanup** — male branch removes `BeeingFemaleSpell` on gender change, but female branch was missing `RemoveSpell(BeeingMaleSpell)` — **fixed** | FWPlayerAlias `ProcessActor` | Gender change male→female could leave both spells active |
| 23.4 | P2 | **GiveBirth state write** — `FW.CurrentState = 8` and `UpdateParentFaction` are separate calls but consecutive native ops; as tight as Papyrus allows | FWController `GiveBirth` | Accepted — no meaningful fix possible |
| 23.5 | ~P2~ | ~~**Stale GivingBirth guard** — 0.25-day window may allow duplicate births on fast reload after crash~~ **FIXED** — timestamp-based staleness check clears flag after 0.25 game days (commit 4ecc49e) | FWController `GiveBirth` | Self-heals after stack dumps |
| 23.6 | ~~ | ~~**PMSSexHurt missing P+ hook**~~ **NOT A BUG** — P+ still sends `HookStageStart`/`HookOrgasmStart`/`HookAnimationEnd` events; PMSSexHurt uses stage hooks, not cum events | BFA_AbilityEffectPMSSexHurt | Works with both legacy and P+ |
| 23.7 | ~P2~ | ~~**`hasWillBecomePregnant()` implicit None return**~~ **FIXED** — added `return false` | FWSaveLoad | Function now returns false when actor is not pregnant |
| 23.8 | ~~ | ~~**Bloody tampon/napkin equip gap**~~ **BY DESIGN** — bloody items are auto-equipped by cycle state machine which manages blood effects; no need to dispel on equip | FWPlayerAlias, FWAbilityBeeingFemale | Not a bug |
| 23.9 | ~~ | ~~**Unequip tampon no effect reapply**~~ **BY DESIGN** — next cycle tick reapplies blood effects; widget updates immediately as visual cue | FWPlayerAlias | Not a bug |
| 23.10 | P2 | **NPC children lost out of range** — `InstantBornChilds` only fires when `Is3DLoaded()` is true | FWAbilityBeeingFemale | NPCs completing pregnancy while player is away lose children silently |
| 23.11 | ~P2~ | ~~**Child learnSpell AI freeze** — 50+ second `Utility.Wait()` with AI locks, no recovery on interruption~~ **MITIGATED** — OnLoad fix restores AI state | FWChildActor | Actor recovers on cell reload |
| 23.12 | P2 | **Addon INI comma in mod name** — `required` split on `","` breaks parsing | FWAddOnManager | Addon with comma-containing dependency name silently skipped |
| 23.13 | ~P2~ | ~~**Hardcoded scan alias count**~~ **FIXED** — now uses `FoundFemales.Length` | FWPlayerAlias | Dynamically matches quest alias count |
| 23.14 | P2 | **Couple widget stale husband polling** — form goes None while key exists → infinite 5s re-poll | FWCoupleWidget | Wasted CPU cycles, potential log spam |
| 23.15 | ~P1~ | ~~**Birth animations skipped when pain scale zero** — Birth_S2/S3 gated by `my_BirthPain`~~ **FIXED** — animations now gated only by `cfg.PlayAnimations` (commit 4ecc49e) | FWController `GiveBirth` | Low pain near shrines no longer suppresses delivery sequence |
| 23.16 | ~P1~ | ~~**Father selection OOB** — `a[j+1]` accessed past array bounds with 2+ donors~~ **FIXED** — loop condition tightened + post-loop advancement (commit 479c2d8) | FWController `ActiveSpermImpregnationTimed` | Father selection no longer biased |
| 23.17 | ~P1~ | ~~**Female baby list wrong counter** — 8 loops used `mCount` instead of `fCount`~~ **FIXED** (commit 530c34a) | FWBabyItemList | Female baby mesh/armor selection correct |
| 23.18 | ~P1~ | ~~**Male baby armor wrong key** — `BabyMesh_Male` instead of `BabyArmor_Male`~~ **FIXED** (commit 530c34a) | FWAddOnManager `GetBabyArmor` | Male baby armor lookup correct |
| 23.19 | ~P1~ | ~~**Creature fathers lost on unload** — sperm entries deleted when actor None, no race fallback~~ **FIXED** — `FW.SpermRace` mirror restored, None entries preserved until expired, `AddChildFather` stores race fallback (commit 3fe384d) | FWController, FWUtility | Creature race persists through unload |
| 23.20 | ~P1~ | ~~**MCM cheat ignores fresh sperm** — washout delay blocks immediate force-impregnation~~ **FIXED** — cheat passes `bShowTravelingSperm=true` (commit 3fe384d) | FWSystemConfig | Cheat works immediately after insemination |
| 23.21 | ~P1~ | ~~**Dead SexLab event registrations on System quest**~~ **FIXED** — removed orphaned registrations (commit e56921b) | FWSystemConfig | No handler existed on target script |
| 23.22 | ~P2~ | ~~**SexLab anal cum double-roll** — `NoVaginalCumChance` rolled twice independently~~ **FIXED** — single roll reused (commit e56921b) | BFA_ssl `OrgasmSeparate` | Consistent anal conception chance |
| 23.23 | ~P1~ | ~~**ContraceptionSpermKillTimed null crash** — `.GetRace()` on None actor~~ **FIXED** — null-safe fallback to global setting (commit 3fe384d) | FWController | No crash on unloaded creature donors |
| 23.24 | ~P1~ | ~~**Inverted `bSort` in sperm weight helpers** — `GetRelevantSpermFloatTimed` (+ ForAnyPeriod variant) sorted when asked NOT to~~ **FIXED** — impregnation paths paired DESC-sorted weights with insertion-ordered donors | FWController | Father weights now belong to the right donors |
| 23.25 | ~P1~ | ~~**Boost-based father pick deterministic at default settings** — determinator = 0 with shipped boost 0: two donors → always the older; newest donor never picked~~ **FIXED** — classic bounded weighted pick restored in both sites; boost remains a conception-chance knob | FWController | Weighted father selection works as documented |
| 23.26 | ~P1~ | ~~**Contraception sperm-kill was a no-op** — killed amount set to exactly `Sperm_Min_Amount_For_Impregnation`, accepted by every `>=` filter (speed-up variant set 0.1)~~ **FIXED** — kills set `Sperm_Amount_For_Delete` | FWController | Contraception actually prevents conception now (balance change) |
| 23.27 | ~P1~ | ~~**Any-period conception: missing `BeeingFemaleConception` event, stale per-donor chance, unfixed pre-479c2d8 OOB**~~ **FIXED** — event emitted, chance reset per donor, classic bounded pick | FWController `MyActiveSpermImpregnationTimedForAnyPeriod` | External listeners (FMR-IE bridge, FAR) see any-period conceptions |
| 23.28 | ~P2~ | ~~**`setNumBabys` raise branch never ran** — `int i=cur; while i<cur`~~ **FIXED** — `while i<num` + none-safe logging; `AddContraceptionTimed` also clamped the pre-add value instead of the new total | FWController | NumChilds and ChildFather lists stay aligned when raising baby count |
| 23.29 | P2 | **Neon-red body glow from blood effect shaders** — LE-era EFSH records render additively-bright under SE bloom: `_BFVaginalBleedingLow` (0x6EB8), `High` (0x6EB9), `Big` (0xAF63), `_BFVaginalWater` (0xBFA0) in BeeingFemale.esm. Fix is record-side (xEdit override: darken Fill color keys, lower Fill/Edge Full Alpha Ratios) or darken `textures\beeingfemale\VaginalBlood*.dds`. Script-side inverted imod throttle in BFA_VisualEffects (red screen flash stacking) **FIXED** | BeeingFemale.esm EFSH, BFA_VisualEffects | Most visible during menstruation without hygiene items and at birth/abortus |
| 23.31 | ~P1~ | ~~**Grown adults got no follower factions** — `ApplyAdultFactions` relied on the CK `ChildFollowerFaction*` properties, which ship UNFILLED in the ESM (VMAD formids None), so no vanilla "Follow me" dialogue ever appeared~~ **FIXED** — vanilla PotentialFollowerFaction (0x5C84D, rank 0) + CurrentFollowerFaction (0x5C84E, rank -1) added directly; the CK slots remain honored if an add-on ESP fills them. Existing grown adults need the factions via console or a re-transition | FWSystem `ApplyAdultFactions` | Affects every adult grown before the fix |
| 23.30 | ~P1~ | ~~**NPC hygiene auto-equip never worked** — `EquipNapkin`/`EquipTampon` equipped the BLOODY variant, which the actor never owns (`EquipItem` on a not-owned form is a silent no-op), so NPCs carried tampons but bled all period; the unconditional tick call could also re-equip the player's soiled napkin~~ **FIXED** — equip the Normal variant (the flow roll soils it naturally); auto-equip gated to NPCs, the player keeps the panty widget as the prompt | FWAbilityBeeingFemale `EquipNapkin`/`EquipTampon` | NPCs now actually wear hygiene items during menstruation |
| 23.32 | ~P1~ | ~~**Auto-insemination skipped partners-only couples** — the regular-partners branch in the daily impregnation guarded on the Affairs count (`ca>0`) instead of the Partners count, so assigned partners were only added to the donor pool when the woman also had an affair~~ **FIXED** — guard uses `cp>0` | FWSystem (daily impregnation) | Assigned partners now used independently |
| 23.33 | ~P0~ | ~~**FWChildActor `_SizeDuration` never initialized** — defaulted to 0 → `modifiedSizeDuration` 0 → child snapped to full size and, with grow-up ON, transitioned at birth (kid + adult appearing together)~~ **FIXED** — `InitChild` seeds it from the configured mature time; `GrowChildToAdult` also `Disable`s the replaced child immediately as a safety net | FWChildActor, FWSystem | Affected built-in child actors only, not child-model packs |

---

*Last updated: 2026-07-04*
