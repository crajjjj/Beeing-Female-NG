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
| 3.3 | P1 | Contraception active | `ContraceptionSpermKillTimed` reduces sperm below threshold, no conception | FWController |
| 3.4 | P1 | Multiple fathers — weighted selection | `calculateNumChildren` produces 1–3, father selection weighted by amount + addon boost, `FW.ChildFather` populated correctly | FWController |
| 3.5 | P2 | Non-lore-friendly pairing | Sperm amount zeroed to `Sperm_Amount_For_Delete`, no conception | FWController |
| 3.6 | P2 | NPC pregnancy disabled in MCM | `cfg.NPCCanBecomePregnant = false` → NPCs skipped, no error | FWController |
| 3.7 | P1 | `BeeingFemaleConception` mod event | Fires with correct Mother, ChildCount, Father0–2 args | FWController |
| 3.8 | P1 | Sperm expiry after 50+ game days | Entries older than `SpermDeleteTime` pruned via `RemoveSpermMirrorAt`, lists stay consistent | FWSaveLoad, FWUtility |

## 4. Pregnancy & Birth (States 4–8)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 4.1 | P0 | Full pregnancy: Tri 1 → 2 → 3 → Labor → Replenish → Follicular | All transitions fire, belly/breast scaling progresses and resets | FWAbilityBeeingFemale, FWController |
| 4.2 | P0 | Labor multi-stage sequence | Vorwehen → Eroffnungswehen → Presswehen → Nachwehen complete, animations play | FWController |
| 4.3 | P0 | GiveBirth spawns correct children | `FW.NumChilds` children spawned, added to `FW.Babys`, `BeeingFemaleLabor` event fires | FWController, FWSystem |
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
| 7.3 | P1 | Fully grown child | Growth flag cleared, `Manager.AddToSLandBF` called, scale stable | FWChildActor |
| 7.4 | P2 | Child perks from INI | `GivePerks()` iterates `ChildPerkFile[0..127]` without array overrun | FWChildActor |
| 7.5 | P1 | Child deletion | State → `MarkForDelete` → disabled → removed from `FW.Babys` → `Delete()` | FWChildActor |
| 7.6 | P2 | Child dialogue commands | Follow, wait, go home orders dispatch via `Order` setter | FWChildActor, FW_ChildDial* |
| 7.7 | P2 | Race inheritance from father | Child race matches father where addon permits | FWChildActor |
| 7.8 | P0 | Save/reload with active children | `InitChild()` restores StorageUtil values, name, factions, scale | FWChildActor |
| 7.9 | P2 | Delete all children (`deleteChildren`) | All three types (FWChildActor, FWChildItem, plain Actor) removed, no FormList orphans | FWSaveLoad |

## 8. NPC Scanning & Spell Application

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 8.1 | P0 | Scan finds nearby females | `FindActors` quest runs, up to 7 aliases filled, `BeeingFemaleSpell` applied | FWPlayerAlias |
| 8.2 | P1 | Scan finds nearby males | `BeeingMaleSpell` applied to valid males | FWPlayerAlias |
| 8.3 | P1 | Actor exclusions | Children, ElderRace, ElderRaceVampire excluded by `ValidateActor` | FWPlayerAlias |
| 8.4 | P2 | Location change triggers rescan | `OnLocationChange` → 0.25s delay → Processing → new scan | FWPlayerAlias |
| 8.5 | P1 | Male actor spell path correctness | Males get `BeeingMaleSpell` not `BeeingFemaleSpell` (known copy-paste risk in `ProcessActor`) | FWPlayerAlias |
| 8.6 | P2 | Mannequin exclusion | SPID distribution excludes mannequins (commit fd21817) | SPID config |

## 9. Save/Load & NPC Persistence

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 9.1 | P0 | Per-actor state survives save/reload | `FW.SavedNPCs` FormList + all per-actor StorageUtil keys intact | FWSaveLoad |
| 9.2 | P1 | NPC time-skip > 60 game days | `UpdatePerDay` skips catchup, calls `CreateFemaleActor(Woman, true)` to reset instead | FWSaveLoad |
| 9.3 | P1 | NPC pill auto-consumption | NPC with pill items: pill consumed when `contraceptionTime + (duration * 0.85) < currentTime`, `FW.Contraception` increases | FWSaveLoad |
| 9.4 | P1 | Delete actor cleans all keys | `Delete(Woman)` removes all `FW.*` StorageUtil keys, no orphaned data | FWSaveLoad |
| 9.5 | P1 | Reset NPC data preserves player | `ResetNpcData(false)` clears all NPCs, player re-added to `FW.SavedNPCs` | FWSaveLoad |
| 9.6 | P1 | `hasWillBecomePregnant()` return path | Function has no explicit `return false` — returns `None` implicitly if actor is not pregnant; verify callers handle this | FWSaveLoad |

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
| 13.1 | P0 | OStim NG orgasm → AddSperm | `ostim_start` event hooked, `processPair` calls `AddSperm` with correct args | BFA_Ostim |
| 13.2 | P1 | OStim API version < 23 | Graceful no-op: retries 10× at 5s intervals, then gives up silently | BFA_Ostim |
| 13.3 | P1 | Condom detection | `System.CheckForCondome(Female, Male)` → pair skipped when condom worn | BFA_Ostim |
| 13.4 | P1 | Child actor in OStim scene | Actor in `FW.Babys` FormList → `OStim.ForceStop()` called | BFA_Ostim |
| 13.5 | P2 | FF (female-female) cum | Only proceeds if `cfg.AllowFFCum == true` and "male" passes `IsValidateFemaleActor` | BFA_Ostim |
| 13.6 | P2 | `FertilityModeAddSperm` compat event | External Fertility Mode event received and processed correctly | BFA_Ostim |

## 14. Integration — Other Mods

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 14.1 | P2 | Bathing in Skyrim washout | Bathing event triggers `WashOutSperm` with appropriate reduction | BFA_BathingInSkyrim |
| 14.2 | P2 | SlaveTats baby tracker | Tattoo applied/removed per BabyTracker config | BabyTracker |

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
| 16.4 | P2 | Widget disabled by default | New install: `CFG_Enabled = false`, hotkeys do nothing | FWCoupleWidget |

## 17. MCM Configuration

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 17.1 | P0 | All 10 MCM pages render | Settings, Cycle, Pregnancy, Impregnate, Male, Children, AddOn, Info, Cheat, System — no script errors | FWSystemConfig |
| 17.2 | P1 | Settings persist across save/load | SKSE-persistent properties survive save cycle | FWSystemConfig |
| 17.3 | P2 | Cheat page: force state change | Manual state override applies correctly | FWSystemConfig |
| 17.4 | P2 | System page: mod reset | Full reset clears StorageUtil, re-runs init | FWSystem |

## 18. Mod Events API

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 18.1 | P1 | External `BeeingFemale` → `AddSperm` | Mod event received, sperm added to target | FWController |
| 18.2 | P1 | External `BeeingFemale` → `ChangeState` | State transition applied | FWController |
| 18.3 | P1 | External `BeeingFemale` → `DamageBaby`/`HealBaby` | Unborn health modified within bounds | FWController |
| 18.4 | P2 | Emitted `BeeingFemaleConception` | Args (Mother, ChildCount, Fathers) correct and parseable by external mods | FWController |
| 18.5 | P2 | Emitted `BeeingFemaleLabor` | Args correct, fires after birth completes | FWController |

## 19. SPID Item Distribution

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 19.1 | P1 | Female NPCs receive items | Contraception (10%), tampons (40–50%), panty (20%) distributed per rules | SPID INI |
| 19.2 | P1 | Bandits/Forsworn excluded | No contraception or tampons on bandit/forsworn NPCs | SPID INI |
| 19.3 | P1 | Mannequins excluded | No items on mannequin actors (commit fd21817) | SPID INI |
| 19.4 | P2 | Merchant stock | `JobMerchantFaction` members have all consumable types (2–6 units, 100%) | SPID INI |
| 19.5 | P2 | `_BF_ContraceptionHighest` requires addon | Only appears when `BeeingFemaleBasicAddOn.esp` loaded; absent without it | SPID INI |
| 19.6 | P2 | Males receive no items | No male distribution rules — confirm males are clean | SPID INI |

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

---

## 22. Known Bugs & Fragile Areas

These are confirmed or high-confidence issues found during code inspection. Each should be triaged as fix-or-accept before release.

| # | P | Issue | Location | Impact |
|---|---|-------|----------|--------|
| 22.1 | ~P1~ | ~~**PMS flag: comparison instead of assignment** — `bHasPMS==false` does not clear the flag~~ **FIXED** | FWAbilityBeeingFemale | 6 occurrences changed `==` to `=` |
| 22.2 | P0 | **Virility operator precedence** — `GameDaysPassed - LastSexTime / recoveryDays` evaluates as `GameDaysPassed - (LastSexTime / recoveryDays)` instead of `(GameDaysPassed - LastSexTime) / recoveryDays` | FWController `GetVirility` | Virility calculation wrong for any non-zero LastSexTime |
| 22.3 | P2 | **ProcessActor female branch missing cleanup** — male branch removes `BeeingFemaleSpell` on gender change, but female branch was missing `RemoveSpell(BeeingMaleSpell)` — **fixed** | FWPlayerAlias `ProcessActor` | Gender change male→female could leave both spells active |
| 22.4 | P1 | **GiveBirth non-atomic state write** — `FW.CurrentState = 8` written directly, `UpdateParentFaction` is separate call | FWController `GiveBirth` | Interruption between the two leaves faction stale |
| 22.5 | P2 | **Stale GivingBirth guard** — 0.25-day window may allow duplicate births on fast reload after crash | FWController `GiveBirth` | Rare but possible double-spawn |
| 22.6 | ~~ | ~~**PMSSexHurt missing P+ hook**~~ **NOT A BUG** — P+ still sends `HookStageStart`/`HookOrgasmStart`/`HookAnimationEnd` events; PMSSexHurt uses stage hooks, not cum events | BFA_AbilityEffectPMSSexHurt | Works with both legacy and P+ |
| 22.7 | P2 | **`hasWillBecomePregnant()` implicit None return** — no `return false` at end of function | FWSaveLoad | Callers may receive None instead of false |
| 22.8 | P2 | **Bloody tampon/napkin equip gap** — `OnObjectEquipped` only checks normal variants, not bloody | FWPlayerAlias | Blood effects not dispelled when equipping bloody items |
| 22.9 | P2 | **Unequip tampon no effect reapply** — removing tampon during menstruation doesn't re-add blood VFX | FWPlayerAlias | Visual inconsistency (widget shows "needed" but no blood effect) |
| 22.10 | P2 | **NPC children lost out of range** — `InstantBornChilds` only fires when `Is3DLoaded()` is true | FWAbilityBeeingFemale | NPCs completing pregnancy while player is away lose children silently |
| 22.11 | P2 | **Child learnSpell AI freeze** — 50+ second `Utility.Wait()` with AI locks, no recovery on interruption | FWChildActor | Actor permanently frozen if script interrupted |
| 22.12 | P2 | **Addon INI comma in mod name** — `required` split on `","` breaks parsing | FWAddOnManager | Addon with comma-containing dependency name silently skipped |
| 22.13 | P2 | **Hardcoded scan alias count** — `iActorIdx = 7` must match `FindActors` quest alias count | FWPlayerAlias | Extra aliases ignored; fewer aliases → None dereference (guarded) |
| 22.14 | P2 | **Couple widget stale husband polling** — form goes None while key exists → infinite 5s re-poll | FWCoupleWidget | Wasted CPU cycles, potential log spam |

---

*Last updated: 2026-04-26*
