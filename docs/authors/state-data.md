# StorageUtil & State Data

Beeing Female NG stores most runtime state in StorageUtil values (prefix `FW.`). This page covers how to read the current state and sperm data, and lists the most important keys.

## Reading State and Sperm Info

```papyrus
; Current cycle/pregnancy state (0..8) -- read straight from StorageUtil
int s = StorageUtil.GetIntValue(PlayerRef, "FW.CurrentState", 0)

; Whether the actor currently has conception-relevant sperm. Prefer BF's own
; check over scanning FW.SpermAmount yourself -- HasRelevantSperm applies the
; same amount / timing / traveling-sperm rules BF uses internally.
FWController bf = Game.GetFormFromFile(0x182A, "BeeingFemale.esm") as FWController
bool isCumInside = bf.HasRelevantSperm(PlayerRef)
```

If Beeing Female is an **optional** dependency, do not type a property or variable to `FWController` directly -- that hard-binds your script to BF at load time, and it will fail to load when BF is absent. Keep a plain `Quest` handle and do the cast inside a small `Global` helper, so the `FWController` type resolves only lazily when BF is actually installed:

```papyrus
; In a separate script -- compiles without BF present; the cast resolves only when called
bool function HasRelevantSperm(Quest fwControllerQuest, Actor akTarget) Global
	return (fwControllerQuest as FWController).HasRelevantSperm(akTarget)
endFunction
```

## StorageUtil Keys

The most important keys (prefix `FW.`) are:

- `FW.SavedNPCs` (FormList, global): tracked female actors managed by the system.
- `FW.CurrentState` (Int, per-actor: mother): current cycle state index (0-8).
- `FW.StateEnterTime` (Float, per-actor: mother): game days timestamp when the current state started.
- `FW.LastUpdate` (Float, per-actor: mother): last update timestamp for the actor.
- `FW.LastLoaded` (Float, per-actor: mother): game days timestamp of when the actor was last 3D-loaded; drives idle-NPC untracking (see [Tracking lifecycle](#tracking-lifecycle)).
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

### Tracking lifecycle

Tracked females are **not** kept forever. When the player has been away from a non-pregnant, idle woman for `IdleUntrackDays` (3) in-game days, BF removes her cycle spell, drops her from `FW.SavedNPCs`, and clears only her transient cycle keys (`FW.CurrentState`, `FW.StateEnterTime`, `FW.LastUpdate`, `FW.Flags`, `FW.LastLoaded`). This bounds the tracked-actor count and stops her background cycle ticks over a long playthrough.

Deliberately **preserved** across an untrack: lifetime history (`FW.NumBirth`, `FW.NumBabys`) and the donor/lineage mirrors (`FW.SpermRace`, `FW.ChildFatherRace`). A woman is **never** dropped while pregnant, in labor, recovering, mid-miscarriage (`FW.Abortus > 1`), contracepting, carrying sperm (`FW.SpermName`), or pregnant by another mod (Chaurus/Estrus). Dead women are fully purged (`FWSaveLoad.Delete`) and have their spell stripped.

Ambient discovery (both the cloak and the alias scan) also skips **temporary references** (FF-prefixed FormIDs -- runtime leveled spawns): the engine deletes such refs outright on cell reset, so granting them the cycle ability would strand orphaned ActiveMagicEffect instances and tracking entries in the save. Two exceptions: persistent runtime companions (player teammates / follower-faction members) are still tracked, and sex-scene integrations (SexLab/OStim) can still track a temporary actress explicitly.

An untracked woman is re-discovered by the cloak and given a **fresh** cycle (via `CreateFemaleActor`) on her next encounter -- her exact prior cycle position is not restored. If your add-on caches per-actor BF data, treat tracking as transient: re-read on the BF events rather than assuming a woman stays in `FW.SavedNPCs`.

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

A baby item hatches while merely **carried** (the carrier's `GetItemCount(base) > 0`, equipped or not). The player's items hatch into the player's children; an NPC mother's item hatches into the **mother's** own child (placed by her, not a player follower) only when `FW.BabyItemFather` equals the player and she is `Is3DLoaded`. Before each hatch pass, `FWUtility.PruneOrphanBabyIdentities(carrier)` reconciles these lists against inventory: per base form it keeps the oldest `GetItemCount(base)` entries (FIFO) and drops the surplus, so a baby item that is sold/dropped/destroyed leaves no orphan identity entry and produces no child. It deliberately does **not** touch `FW.Babys` -- that global list holds armor *base* forms shared across all mothers, so removing one by base could delete a different mother's live entry; stale `FW.Babys` armor entries are harmless (the hatch gate skips bases the carrier no longer holds) and are cleaned by the game-load purge. Only call it for a carrier whose inventory read is trustworthy (the player, or an `Is3DLoaded` NPC) -- an unloaded actor can report a false zero and wrongly prune a valid baby.

## Access examples

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

**Multi-child / multi-father logic:** when a pregnancy has multiple children, `FW.NumChilds` stores the count and `FW.ChildFather` stores one father per child (so twins can share a father or have different fathers). Systems that need a single "primary" father typically use index `0`.

Keys under `FW.AddOn.*` are reserved for add-on configuration/overrides and are documented in the add-on INI examples.
