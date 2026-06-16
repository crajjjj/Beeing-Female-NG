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

## Events BF emits

- `BeeingFemaleConception` (ModEvent): pushed as `Mother` (Form), `ChildCount` (Int), `Father0` (Form), `Father1` (Form), `Father2` (Form). Fathers may be `None` if unknown.
- `BeeingFemaleLabor` (ModEvent): pushed as `Mother` (Form), `ChildCount` (Int), `Father0` (Form), `Father1` (Form), `Father2` (Form). Fired on labor start and on direct `GiveBirth` calls.
- `BeeingFemale` (ModEvent): command-style event; see the ChangeState subscription example below if you want to listen for `ChangeState` commands.

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
