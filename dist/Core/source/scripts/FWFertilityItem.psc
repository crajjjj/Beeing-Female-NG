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
	; The mild tonic (magnitude ~2) stays a pure Gate 2 nudge.
	if mag >= 3.5
		Controller.setCanBecomePregnant(ActorRef, true)
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
