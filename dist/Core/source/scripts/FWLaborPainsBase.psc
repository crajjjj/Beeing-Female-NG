Scriptname FWLaborPainsBase extends activemagiceffect  

FWSystem property System auto
float property DamageBase auto
float property UpdateDelay auto
int property KindOfPains auto
bool property Silent = false auto
actor ActorRef


Event OnEffectStart(Actor akTarget, Actor akCaster)
	ActorRef=akTarget
	Utility.Wait(Utility.RandomFloat( (UpdateDelay*0.75) + 2, (UpdateDelay* 1.1) + 2))
	OnUpdateGameTime()
endEvent

function OnUpdateGameTime()
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
	If self as string == "[FWLaborPainsBase <None>]" ;Tkc (Loverslab): optimization
	else;If self as string != "[FWLaborPainsBase <None>]"
		RegisterForSingleUpdateGameTime( Utility.RandomFloat(UpdateDelay*0.75,UpdateDelay* 1.1))
	EndIf

	; Drive the pain face through labor AND the push - this effect (Presswehen) stays
	; active across the whole GiveBirth sequence, so it covers the birth. We ONLY set
	; "Pained" (never clear) so we coexist with GiveBirth's own face calls (both want
	; "Pained"). BUT only while still in Labor Pains (FW.CurrentState == 7): GiveBirth
	; flips the state to 8 (Replenish) at its end while this effect can still linger a
	; moment, so once the state has moved on we RELAX the face instead - otherwise a
	; late contraction tick keeps the grimace on after the birth is done. Scaled by
	; this contraction's magnitude, capped below the push max. Audible actors only.
	if !Silent
		if StorageUtil.GetIntValue(ActorRef, "FW.CurrentState", 0) == 7
			int painStrength = ((DamageBase + rnd) * 4.0) as int
			if painStrength > 70
				painStrength = 70
			elseif painStrength < 15
				painStrength = 15
			endif
			System.Mimik(ActorRef, "Pained", painStrength)
		else
			System.Mimik(ActorRef) ; birth done / state moved on -> relax (the relief smile is handled in OnEffectFinish)
		endif
	endif
endFunction

; Relax the face when this contraction effect ends (push finishes / state leaves
; labor), so no pained grimace lingers post-birth. Mimik no-ops on a None/unloaded
; actor, so this is safe even if the actor unloaded.
Event OnEffectFinish(Actor akTarget, Actor akCaster)
	; Fires exactly once, when this contraction effect is removed - the reliable
	; post-birth hook (the per-tick path can miss the moment if the effect is yanked
	; first). If the state has moved to Replenish (8), this is the push contraction
	; ending after birth: show a relief smile, hold it, then relax. Cache System into
	; a local BEFORE the wait - the effect is being torn down and property access can
	; go stale across a wait (Papyrus quirk).
	if !Silent && akTarget
		FWSystem sys = System
		if StorageUtil.GetIntValue(akTarget, "FW.CurrentState", 0) == 8
			sys.Mimik(akTarget, "Happy", 40) ; relief smile after birth
			Utility.Wait(10.0)               ; hold ~10s
			sys.Mimik(akTarget)              ; then relax to neutral
		else
			sys.Mimik(akTarget) ; mid-labor transition (e.g. Eroeffnungswehen ended) -> just relax
		endif
	endif
endEvent

; 02.06.2019 Tkc (Loverslab) optimizations: Changes marked with "Tkc (Loverslab)" comment