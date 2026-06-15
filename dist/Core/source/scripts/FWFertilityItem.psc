Scriptname FWFertilityItem extends FWSpell

; Fertility Tonic effect - the symmetric counterpart of FWContraceptionItem.
; On drink it grants the woman a timed conception-chance boost (FW.Fertility),
; which FWAbilityBeeingFemale adds to its impregnation roll. It deliberately
; does NOT touch contraception: a fertility booster should not override a
; deliberate contraceptive that is already killing the sperm.

actor ActorRef
bool bInit=false

function execute()

	if bInit==false || ActorRef==none
		return
	endif
	float mag = GetMagnitude()
	if mag <2
		mag=2
	endif
	Controller.AddFertility(ActorRef, mag)
	; Potent tier (the higher-magnitude tonic, magnitude ~4) is a "fertility
	; treatment": on top of the Gate 2 conception-roll boost above, it forces the
	; current cycle's "can become pregnant" flag (Gate 1) on, so a cycle that
	; rolled infertile becomes fertile for the rest of its window. The flag is
	; re-rolled at the next cycle boundary, so the effect naturally expires.
	if mag >= 3.5
		Controller.setCanBecomePregnant(ActorRef, true)
	elseif Controller.GetFemaleState(ActorRef) < 4 && Controller.canBecomePregnant(ActorRef) == false
		; Mild tier (magnitude ~2): it cannot guarantee fertility like the potent
		; tonic, but it does "nudge" Gate 1. If the current cycle rolled infertile,
		; grant one extra fertility roll at the actor's normal ConceiveChance (the
		; same roll the cycle boundary uses, so per-actor/race scaling still
		; applies). Net effect: roughly one additional chance for the cycle to be
		; fertile (e.g. 40% -> ~64%), still well below the potent tonic's
		; guaranteed flip. No effect once she is already fertile this cycle or
		; pregnant; like the potent flag, it clears at the next cycle boundary.
		if System.canBecomePregnant(ActorRef)
			Controller.setCanBecomePregnant(ActorRef, true)
		endif
	endif
endfunction

Event OnWoman(Actor akTarget, Actor akCaster)
	ActorRef = akCaster
	execute()
endEvent

Event OnInit()
	bInit=true
	parent.OnInit()
	execute()
endEvent
