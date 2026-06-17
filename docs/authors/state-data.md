# StorageUtil & State Data

Beeing Female NG stores most runtime state in StorageUtil values (prefix `FW.`). This page covers how to read the current state and sperm data, and lists the most important keys.

## Reading State and Sperm Info

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

## StorageUtil Keys

The most important keys (prefix `FW.`) are:

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

A baby item hatches while merely **carried** (the carrier's `GetItemCount(base) > 0`, equipped or not). The player's items hatch into the player's children; an NPC mother's item hatches into the **mother's** own child (placed by her, not a player follower) only when `FW.BabyItemFather` equals the player and she is `Is3DLoaded`. Before each hatch pass, `FWUtility.PruneOrphanBabyIdentities(carrier)` reconciles these lists against inventory: per base form it keeps the oldest `GetItemCount(base)` entries (FIFO) and drops the surplus (plus one matching `FW.Babys` entry each), so a baby item that is sold/dropped/destroyed leaves no orphan entry and produces no child. Only call it for a carrier whose inventory read is trustworthy (the player, or an `Is3DLoaded` NPC) -- an unloaded actor can report a false zero and wrongly prune a valid baby.

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
