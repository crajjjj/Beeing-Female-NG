Scriptname FWAbilityBeeingMale extends FWAbilityBeeingBase

Bool IsSpouse

GlobalVariable Property ModEnabled Auto
Spell Property BeeingMaleSpell Auto
Spell Property BeeingFemaleSpell Auto
MagicEffect Property _BFAbilityEffectBeeingMale Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	if ModEnabled.GetValue() As int ;Tkc (Loverslab): optimization
	else;if System.ModEnabled.GetValueInt()!=1
		Self.Dispel()
		Return
	endif
	;IsPlayer = (akTarget == Game.GetPlayer())
	IsPlayer = (akTarget == PlayerRef) ;Tkc (Loverslab): optimization. PlayerRef added in FWAbilityBeeingBase
	IsFollower = akTarget.IsInFaction(System.FollowerFaction)
	IsSpouse = akTarget.IsInFaction(PlayerMarriedFaction)
	parent.OnEffectStart(akTarget, akCaster)
	ActorRef = akTarget
	ActorRefBase = akTarget.GetLeveledActorBase() ;Tkc (Loverslab): optimization. was not used anywhere but added it below
	If IsPlayer
		System.PlayerMale = Self
		System.Player = none
	EndIf

	if ActorRef.HasMagicEffect(_BFAbilityEffectBeeingMale)
		If IsPlayer || IsFollower || IsSpouse ;Bane 04/07/19: Stack Dump Prevention - For NPC's effect is reapplied on every location change, a 5 hourly update check on non-followers/spouses is unecessary
			RegisterForSingleUpdateGameTime(5)
		EndIf
		If IsPlayer
			; The OnSleepStart/OnSleepStop logic in FWAbilityBeeingBase is all
			; IsPlayer-gated, so a sleep registration on an NPC instance only
			; spawns one no-op stack per male per player sleep.
			RegisterForSleep()
		EndIf
		;If IsPlayer
		;	RegisterForSingleUpdate(5) ;Tkc (Loverslab): optimization, commented because there is no male actions in parent OnUpdate function of FWAbilityBeeingBase script
		;EndIf
	Else
		Return
	endif
	bInitSpell=true
	OnPlayerLoadGame()
EndEvent

function OnPlayerLoadGame()
	if bInit;/==true/; && bInitSpell;/==true/; ;&& Self as String != "[FWAbilityBeeingMale <None>]"
		if IsPlayer
			Utility.WaitMenuMode(1)
			;IsFollower = ActorRef.IsInFaction(System.FollowerFaction) && IsPlayer == false - Never true as only received by the player
			Controller.UpdateParentFaction(ActorRef)
			equipChild()
			return
		endif
		; NPC path: called from OnEffectStart, which re-fires on every actor
		; load. It must not park the stack (the old WaitMenuMode(1)): an effect
		; torn down mid-wait strands the stack in the save forever - the same
		; mechanism FWAbilityBeeingFemale::OnEffectStart removed its Wait for.
		; The refresh work below is idempotent, so throttle it instead.
		float now = Utility.GetCurrentGameTime()
		float last = StorageUtil.GetFloatValue(ActorRef, "FW.MaleInitTime", -100.0)
		if now >= last && now - last < 0.04 ; ~1 game hour
			return
		endif
		StorageUtil.SetFloatValue(ActorRef, "FW.MaleInitTime", now)
		if StorageUtil.FormListFind(none, "FW.SavedNPCs", ActorRef) >= 0
			; UpdateParentFaction early-outs for actors not in FW.SavedNPCs -
			; apply that gate locally so the untracked majority never queues on
			; the shared Controller instance at all
			Controller.UpdateParentFaction(ActorRef)
		endif
		equipChild()
	endif
endfunction

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	;If System && (System.PlayerMale == Self)
	If System ;Tkc (Loverslab): optimization
		if (System.PlayerMale == Self)
			System.PlayerMale = None
		EndIf
	EndIf
	;If ActorRef && ActorRef.HasSpell(System.BeeingMaleSpell)
	If ActorRef ;Tkc (Loverslab): optimization
		if ActorRef.HasSpell(BeeingMaleSpell)
			ActorRef.RemoveSpell(BeeingMaleSpell)
		EndIf
	EndIf
EndEvent

;Event OnUpdate()
	;RegisterForSingleUpdate(5) ;Tkc (Loverslab): optimization, commented because there is no male actions in parent OnUpdate function of FWAbilityBeeingBase script
	;parent.OnUpdate()
;EndEvent

Event OnUpdateGameTime()
	if System ;Tkc (Loverslab): optimization
	else;if System==none
		return
	endif
	if Controller ;Tkc (Loverslab): optimization
	else;if System.Controller == none
		return
	endif
	Controller.UpdateParentFaction(ActorRef)
	if ActorRefBase.GetSex();!=0 ;Tkc (Loverslab): optimization
		if ActorRef.HasSpell(BeeingFemaleSpell) ;Tkc (Loverslab): optimization
		else;if ActorRef.HasSpell(System.BeeingFemaleSpell)==false
			;if System.IsValidateActor(ActorRef)>0
			if System.IsValidateFemaleActor(ActorRef)>0 ;Tkc (Loverslab): optimization, changed to validated female because here is only female actions and it will be faster
				ActorRef.AddSpell(BeeingFemaleSpell)
			endif
		endif
		Self.Dispel()
		Return
	endif
	if IsPlayer
		if System.PlayerMale ;Tkc (Loverslab): optimization
		else;if System.PlayerMale==none
			System.PlayerMale=self
			System.Player=none
		endif
	endif
	If ActorRef.HasMagicEffect(_BFAbilityEffectBeeingMale)
		if Self as String == "[FWAbilityBeeingMale <None>]"
		else;if Self as String != "[FWAbilityBeeingMale <None>]"
			; Re-registration must keep the same stack-dump-prevention gate as
			; OnEffectStart, or one tick is enough to keep an NPC ticking for
			; life. Recomputed (not the cached flags) so dismissed followers /
			; divorced spouses drop out of the update loop too.
			IsFollower = ActorRef.IsInFaction(System.FollowerFaction)
			IsSpouse = ActorRef.IsInFaction(PlayerMarriedFaction)
			If IsPlayer || IsFollower || IsSpouse
				RegisterForSingleUpdateGameTime(5)
			EndIf
		EndIf
	EndIf
endEvent

; 07 jule 2019 Tkc (Loverslab) optimizations: Changes marked with "Tkc (Loverslab)" comment