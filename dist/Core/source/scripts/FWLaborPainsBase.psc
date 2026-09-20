Scriptname FWLaborPainsBase extends activemagiceffect  

FWSystem property System auto
float property DamageBase auto
float property UpdateDelay auto
int property KindOfPains auto
bool property Silent = false auto
actor ActorRef

Spell _ownAbility
bool _ownAbilityResolved = false


Event OnEffectStart(Actor akTarget, Actor akCaster)
	ActorRef=akTarget
	Utility.Wait(Utility.RandomFloat( (UpdateDelay*0.75) + 2, (UpdateDelay* 1.1) + 2))
	OnUpdateGameTime()
endEvent

; The ability that carries this effect, keyed off KindOfPains (unique per
; variant) so no CK property filling is needed on the four magic effects.
; Cached: an orphaned effect resolves this once and then dies.
Spell function GetOwnAbility()
	if _ownAbilityResolved
		return _ownAbility
	endif
	_ownAbilityResolved = true
	int formID = 0
	if KindOfPains == 7
		formID = 0x0053C4 ; _BFAbilityLabor_PremonitoryPains
	elseif KindOfPains == 8
		formID = 0x0053C2 ; _BFAbilityLabor_FirstStagePains
	elseif KindOfPains == 10
		formID = 0x0053BF ; _BFAbilityLabor_BreakingDownPains
	elseif KindOfPains == 11
		formID = 0x0053BE ; _BFAbilityLabor_AfterPains
	endIf
	if formID
		_ownAbility = Game.GetFormFromFile(formID, "BeeingFemale.esm") as Spell
	endIf
	return _ownAbility
endFunction

; True when FW.CurrentState has moved past the phase this effect belongs to.
;
; The valid sets are deliberately generous by one phase: a state's onExitState
; runs from InitState(), which changeState() calls AFTER it has already written
; the new FW.CurrentState, so the normal teardown window legitimately sees the
; next state. Being loose there keeps this check from ever racing the state
; machine; the orphan case it exists for is many phases off, not one.
;
;   KindOfPains  7  Premonitory pains  added in 3rd trimester >90%  -> 6, 7
;   KindOfPains  8  First stage pains  added in labor <50%          -> 7, 8
;   KindOfPains 10  Bearing-down pains added in labor >=50%         -> 7, 8
;   KindOfPains 11  After pains        added in replenish           -> 8, 0
;
; An untracked actor reads 0 (the StorageUtil default the grimace check below
; also relies on), which counts as orphaned for 7, 8 and 10 - that is what
; silences a woman whose FW.* data was wiped by an MCM reset while the ability
; stayed behind. 11 cannot lean on it, because 0 is equally its own legitimate
; teardown state; a wiped actor loses that one to FWUtility.ClearLaborAbilities
; instead, which is also what strips the two KindOfPains 3 variants below.
bool function IsOrphaned()
	int s = StorageUtil.GetIntValue(ActorRef, "FW.CurrentState", 0)
	if KindOfPains == 7
		return s != 6 && s != 7
	elseif KindOfPains == 8 || KindOfPains == 10
		return s != 7 && s != 8
	elseif KindOfPains == 11
		; 0 is the phase after replenish (follicular), so it is this variant's
		; share of the one-phase slack above - not an orphan. It is also the
		; untracked default, but a wiped actor gets her abilities stripped by
		; FWUtility.ClearLaborAbilities, so nothing is left here to catch.
		return s != 8 && s != 0
	endIf
	return false ; unknown variant - never self-remove
endFunction

function OnUpdateGameTime()
	; Orphan self-heal, FIRST thing in the tick.
	;
	; This script is a self-rescheduling timer: every tick arms the next one,
	; and the abilities are torn down exclusively by the owning state's
	; onExitState. A transition that never fires (the post-birth "Update"
	; ModEvent lost, a stack dump during the birth scene, an actor unloaded
	; mid-labor) therefore leaves the ability on her and this loop moaning
	; forever, while FW.CurrentState already reads as recovered.
	;
	; The check has to sit ahead of PlayPainSound rather than just guarding the
	; reschedule below, because OnEffectStart calls this function DIRECTLY - a
	; guard on the reschedule alone would still fire one moan on every game
	; load for as long as the stale ability sits in her spell list.
	;
	; Removing the ability matters beyond the sound: LaborPains_State gates the
	; birth on HasSpell(Effect_Presswehen) == false, so a stale push ability
	; would suppress the 50% birth trigger on her next pregnancy and push
	; delivery out to the end of the full labor duration.
	if ActorRef ;/!=none/;
	else
		return ; no target left to hurt - let the loop die rather than re-arm
	endIf
	if IsOrphaned()
		FW_log.WriteLog("FWLaborPainsBase: orphaned labor effect (KindOfPains=" + KindOfPains + ") on " + ActorRef + " at FW.CurrentState=" + StorageUtil.GetIntValue(ActorRef, "FW.CurrentState", 0) + " - removing ability")
		Spell own = GetOwnAbility()
		if own && ActorRef.HasSpell(own)
			ActorRef.RemoveSpell(own) ; ends this effect - nothing below runs
		endIf
		return ; no sound, no damage, no reschedule
	endIf

	float rnd=Utility.RandomFloat(-1.0,1.0)
	if Silent ;Tkc (Loverslab): optimization
	else;if Silent==false
		System.PlayPainSound(ActorRef,(DamageBase+rnd) *4)
	endif

	; Find the list of fathers
	int my_num_men = StorageUtil.FormListCount(ActorRef, "FW.ChildFather")
	float my_LaborPains_DamageScale = 0
	float temp_LaborPains_DamageScale = 0
	actor a = none
	race abr = none
	while my_num_men > 0
		my_num_men -= 1
		a = (StorageUtil.FormListGet(ActorRef, "FW.ChildFather", my_num_men) As Actor)
		if a
			temp_LaborPains_DamageScale = StorageUtil.GetFloatValue(a, "FW.AddOn.Modify_Pain_LaborPains_by_FatherRace", 1.0)
			if(temp_LaborPains_DamageScale == 1.0)
				abr = a.GetRace()
				if abr
					temp_LaborPains_DamageScale = StorageUtil.GetFloatValue(abr, "FW.AddOn.Modify_Pain_LaborPains_by_FatherRace", 1.0)
				endIf
			endIf

			if(temp_LaborPains_DamageScale > my_LaborPains_DamageScale)
				my_LaborPains_DamageScale = temp_LaborPains_DamageScale
			endIf
		endIf
	endWhile
	my_LaborPains_DamageScale *= ((DamageBase + rnd) * (System.getDamageScale(3, ActorRef)))

	if(my_LaborPains_DamageScale > 0)
		System.DoDamage(ActorRef, my_LaborPains_DamageScale, KindOfPains)
	endIf
	; Contraction grimace WAVE - ownership handoff. The contraction drives the face
	; ONLY during OPENING contractions: still in Labor Pains (FW.CurrentState == 7) AND
	; GiveBirth not yet running (actor not in FW.GivingBirth). Once the push starts the
	; actor is in FW.GivingBirth and GiveBirth owns the face (it has the birth-stage
	; context), so we don't touch it. Grimace 3-4s, then relax until the next
	; contraction. Done BEFORE rescheduling so the wait can't overlap the next tick.
	; Audible (non-Silent) actors only.
	if !Silent && StorageUtil.GetIntValue(ActorRef, "FW.CurrentState", 0) == 7 && StorageUtil.FormListFind(none, "FW.GivingBirth", ActorRef) < 0
		int painStrength = ((DamageBase + rnd) * 4.0) as int
		if painStrength > 70
			painStrength = 70
		elseif painStrength < 15
			painStrength = 15
		endif
		System.Mimik(ActorRef, "Pained", painStrength) ; grimace
		Utility.Wait(Utility.RandomFloat(3.0, 4.0))     ; hold 3-4s
		; relax only if it's still an opening contraction; if the push began during the
		; wait, leave the face to GiveBirth rather than wiping it.
		if StorageUtil.GetIntValue(ActorRef, "FW.CurrentState", 0) == 7 && StorageUtil.FormListFind(none, "FW.GivingBirth", ActorRef) < 0
			System.Mimik(ActorRef)
		endif
	endif

	If self as string == "[FWLaborPainsBase <None>]" ;Tkc (Loverslab): optimization
	else;If self as string != "[FWLaborPainsBase <None>]"
		RegisterForSingleUpdateGameTime( Utility.RandomFloat(UpdateDelay*0.75,UpdateDelay* 1.1))
	EndIf
endFunction

; Relax our opening-contraction grimace when this effect ends - UNLESS GiveBirth is
; driving the face (the push and post-birth relief belong to GiveBirth). Mimik no-ops
; on a None/unloaded actor, so this is safe even if the actor unloaded.
Event OnEffectFinish(Actor akTarget, Actor akCaster)
	if !Silent && akTarget && StorageUtil.FormListFind(none, "FW.GivingBirth", akTarget) < 0
		System.Mimik(akTarget)
	endif
endEvent

; 02.06.2019 Tkc (Loverslab) optimizations: Changes marked with "Tkc (Loverslab)" comment