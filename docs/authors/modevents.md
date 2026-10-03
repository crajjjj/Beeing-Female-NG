# Papyrus ModEvents

Beeing Female NG listens for a few mod events you can emit from your own Papyrus scripts.

## Events BF listens for

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
- `dhlp-Suspend` / `dhlp-Resume` (SendModEvent): the shared DHLP scene-coordination convention used by Devious Devices, Conditional Expressions Extended, and similar mods. While one or more `dhlp-Suspend` events are outstanding (more suspends than resumes), BF **defers the start of the birth scene** — it will not strip, lock, animate, or move the mother until the matching `dhlp-Resume` arrives. The wait is capped (~15 minutes) so a mod that forgets to resume can never block birth forever, and the counter resets on every game load. BF ignores its own broadcast of these events (see below), so emitting them from your mod only affects BF, never causes it to suspend itself.

!!! note "Already-tracked vs. auto-tracking commands"
    Two listeners back the `BeeingFemale` command event. The central system handles the conception/state commands (`AddContraception`, `AddFertility`, `DrinkFertilityTonic`, `AddSperm`, `AddSpermImpregnate`, `WashOutSperm`, `ChangeState`, `InfoBox`, `DamageBaby`, `HealBaby`, `CanBecomePregnant`, `CanBecomePMS`) and will **start tracking** the female if she isn't already. The remaining commands (`Update`, `Belly`, `Birth`, `Dispel`, `CheckAbortus`, `ConceptionChance`, `TestScale`) are handled by the per-actor cycle ability, so they only do something on a female who is **already tracked** (has the BeeingFemale ability) — on an untracked actor they are no-ops.

## Events BF emits

- `BeeingFemaleConception` (ModEvent): pushed as `Mother` (Form), `ChildCount` (Int), `Father0` (Form), `Father1` (Form), `Father2` (Form). Fathers may be `None` if unknown.
- `BeeingFemaleLabor` (ModEvent): pushed as `Mother` (Form), `ChildCount` (Int), `Father0` (Form), `Father1` (Form), `Father2` (Form). Fired on labor start and on direct `GiveBirth` calls.
- `BeeingFemaleBirth` (ModEvent): pushed as `Mother` (Form), `Father` (Form), `Baby` (Form), `BabyName` (String), `BabySex` (Int: 0 male, 1 female, -1 unknown). Fired **once per child that reaches the world**, so twins raise it twice, each with that child's own father. `Baby` is the child Actor when the baby spawns as an actor, or the baby-item armor **base** form while she carries it - twins sharing a base push an identical form, so pair it with `BabyName`. Not fired when nothing spawned (the baby-gem setting, or a spawn that failed because the race has no child base), and not fired for a stillbirth.
- `BeeingFemaleStillbirth` (ModEvent): pushed as `Mother` (Form), `Father` (Form). Fired once per child lost to the stillbirth roll at birth. Those children never reach the spawn path, so they raise no `BeeingFemaleBirth` - this is what lets you reconcile per-child births against the `ChildCount` from `BeeingFemaleLabor`.
- `BeeingFemaleChildSpawned` (ModEvent): pushed as `Mother` (Form), `Father` (Form), `Child` (Form), `ChildName` (String). Fired once when a child is physically in the world as an Actor: either a carried baby item that finished its growth timer, or a baby born directly as an actor - in that case it follows `BeeingFemaleBirth` immediately.
- `BeeingFemaleAdultChildSpawned` (ModEvent): pushed as `Mother` (Form), `Father` (Form), `Adult` (Form), `Child` (Form), `ChildName` (String). Fired once when a child grows up. On the in-place graduation path `Adult` and `Child` are the same actor; on the replacement path `Child` is the child actor that was swapped out - and that actor is already disabled and queued for deletion by the time you see it, so read what you need from it inside the handler and do **not** store the form: holding it blocks the delete and leaves a ghost actor in the save.
- `BeeingFemaleAbort` (ModEvent): pushed as `Mother` (Form), `Father` (Form), `AbortusState` (Int), `Reason` (String). Fired **once**, at the point the pregnancy actually ends - not when `FW.Abortus` is first raised, because state 1 is "threatened" and can still recover, and the staged loss takes several game days to resolve. `AbortusState` is the `FW.Abortus` value that resolved it (2 incipient, 3 incomplete, 4 complete, 5 missed abortion, 6 stillbirth), so an early loss is distinguishable from a third-trimester one; it is `0` when the loss was forced outside the staged machine, which is what the Chaurus and Estrus states do when they take over an existing pregnancy. `Reason` flattens that to `abortion` when the loss was induced through one of the `Abortus*` entry points, `stillbirth` for state 6, otherwise `miscarriage`. One event per resolved loss, with one caveat: `castAbortus` clears `FW.Abortus` only after the loss sequence has played (~15 s), so a `CheckAbortus` command landing inside that window can drive a second resolution and a second event. Guard against a repeat if your handler is not idempotent.
- `BeeingFemale` (ModEvent): command-style event; see the ChangeState subscription example below if you want to listen for `ChangeState` commands.

!!! note "One `Father`, or `Father0-2`?"
    A pregnancy can have up to three fathers, which is why `BeeingFemaleConception` and `BeeingFemaleLabor` push `Father0`, `Father1` and `Father2`. The per-child events push a single `Father` instead: by the time a child is spawned BF has already resolved which father it belongs to (`FW.ChildFather` is indexed per child), so one father per event is the more precise answer, not a lossy one. `BeeingFemaleAbort` pushes `FW.ChildFather[0]`, read before the list is cleared.

    Every emitted event puts the mother first, then the father(s), then the subject of the event, then its details. Handlers are positional, so keep that order.
- `dhlp-Suspend` / `dhlp-Resume` (SendModEvent): broadcast around the **birth scene** so DHLP-aware mods back off while the mother is stripped / locked / animated. `dhlp-Suspend` fires once when a birth commits; `dhlp-Resume` fires once when the last in-progress birth finishes (the pair is reference-counted, so overlapping NPC births stay balanced and an interrupted birth still resumes). BF sends these from its own quest, so its own listener filters them out by `sender` — your mod sees them like any other suspend/resume. If your mod manages facial expressions, posing, or camera, treat a BF `dhlp-Suspend` as "do not touch this actor until `dhlp-Resume`".

## Examples

Sending the command event (`SendModEvent` is a Form method):

```papyrus
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

Subscribing to the emitted events:

```papyrus
Event OnInit()
	RegisterForModEvent("BeeingFemaleConception", "OnBeeingFemaleConception")
	RegisterForModEvent("BeeingFemaleLabor", "OnBeeingFemaleLabor")
	RegisterForModEvent("BeeingFemaleBirth", "OnBeeingFemaleBirth")
	RegisterForModEvent("BeeingFemaleStillbirth", "OnBeeingFemaleStillbirth")
	RegisterForModEvent("BeeingFemaleChildSpawned", "OnBeeingFemaleChildSpawned")
	RegisterForModEvent("BeeingFemaleAdultChildSpawned", "OnBeeingFemaleAdultChildSpawned")
	RegisterForModEvent("BeeingFemaleAbort", "OnBeeingFemaleAbort")
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

Event OnBeeingFemaleBirth(Form akMother, Form akFather, Form akBaby, string asBabyName, int aiBabySex)
	; Once per child. akBaby is an Actor, or the baby-item armor base form.
EndEvent

Event OnBeeingFemaleStillbirth(Form akMother, Form akFather)
	; Once per child lost to the stillbirth roll - no BeeingFemaleBirth for these.
EndEvent

Event OnBeeingFemaleChildSpawned(Form akMother, Form akFather, Form akChild, string asChildName)
	; The child is now a real actor in the world.
EndEvent

Event OnBeeingFemaleAdultChildSpawned(Form akMother, Form akFather, Form akAdult, Form akChild, string asChildName)
	; akAdult == akChild when the child graduated in place.
EndEvent

Event OnBeeingFemaleAbort(Form akMother, Form akFather, int aiAbortusState, string asReason)
	; asReason is "abortion", "miscarriage" or "stillbirth".
EndEvent
```

Listening for `BeeingFemale` command events (e.g. `ChangeState`):

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

Forcing an abortus (requires a pregnant actor and abortus enabled in config):

```papyrus
; Reduce unborn health, then force a check
FemaleActor.SendModEvent("BeeingFemale", "DamageBaby", 999)
FemaleActor.SendModEvent("BeeingFemale", "CheckAbortus")
```
