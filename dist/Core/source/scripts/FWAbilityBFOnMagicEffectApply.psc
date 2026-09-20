Scriptname FWAbilityBFOnMagicEffectApply extends ActiveMagicEffect

;Magic Effect Monitoring Script for BeeingFemale by Bane Master 03/07/2019 V1.0
;
;3.5.16: the plain ActiveMagicEffect OnMagicEffectApply event was replaced with PO3's
;filtered OnMagicEffectApplyEx.
;
;This script rides on _BFAbilityEffectBeeingFemale - the ability every tracked female
;carries - and OnMagicEffectApply cannot be filtered: the VM raises it for EVERY magic
;effect applied to the actor. Multiplied by every tracked female in the loaded grid
;that is hundreds of thousands of Papyrus stacks per hour in a crowded hold, which
;backs the VM queue up until dialogue, looting and doors take seconds to respond.
;The GoToState() "spam protection" that used to sit here did not help: states only
;skip the body, the stack is still created, queued and dispatched.
;
;PO3_Events_AME.RegisterForMagicEffectApplyEx filters in C++ against just the magic
;effects a Misc add-on asked for (FWAddOn_Misc.OnRegisterMagicEffectFilters), so
;Papyrus is never woken for anything else. When no add-on names an effect - the stock
;setup, without Bathing in Skyrim - nothing is registered and this script costs nothing.

FWSystem property System Auto
;Manager and PlayerRef are filled by BeeingFemaleSE_Opt.esp but NOT by BeeingFemale.esm,
;so both fall back to the FWSystem copies - see GetManager() / GetPlayer(). Do not remove
;either property: they are CK-filled in the optional plugin.
FWAddOnManager property Manager auto
Actor Property PlayerRef Auto

Actor ActorRef

;Bathing re-applies its effect while the animation runs, so one fan-out per this many
;real seconds is plenty and keeps a burst from reaching the add-ons.
float ThrottleSeconds = 2.0
float LastFanOut = 0.0

Event OnEffectStart(Actor target, Actor caster) ; BF re-adds the magic effect to nearby NPC's at each location change but to the Player only on an MCM Reset
	ActorRef = target
	RegisterForModEvent("FW_OMEAToggle", "SetState"); Register the Instance for the MCM enable/disable ModEvent - For NPC's this will be lost on game save/load but reinstated on first location change
	RegisterForModEvent("FW_OMEARefresh", "RefreshFilters"); An add-on's filter set became known or changed
	ApplyFilters()
EndEvent

Event OnEffectFinish(Actor target, Actor caster)
	PO3_Events_AME.UnregisterForAllMagicEffectApplyEx(self)
EndEvent

Event OnPlayerLoadGame() ;This event is only received by the instance attached to the Player
	RegisterForModEvent("FW_OMEAToggle", "SetState") ; The MCM toggle ModEvent on the Player must be registered at each Game Load
	RegisterForModEvent("FW_OMEARefresh", "RefreshFilters")
	ApplyFilters()
EndEvent

;abApplied is deliberately ignored. The vanilla OnMagicEffectApply this replaces fired
;whenever an effect was *being* applied, success or not, and MagicTarget::AddTarget - which
;is what abApplied reports - returns false for an effect already running on the target.
;Bathing re-applies its effect while the animation plays, so gating on abApplied would drop
;exactly the repeats the washout depends on.
Event OnMagicEffectApplyEx(ObjectReference akCaster, MagicEffect akEffect, Form akSource, bool abApplied)
	float t = Utility.GetCurrentRealTime()
	if t < LastFanOut
		; GetCurrentRealTime counts from game launch, but LastFanOut was saved with the
		; effect: after loading a save made late in a session the stored stamp is in the
		; future and would mute the hook for that many real minutes. Treat it as a new
		; session and start the window over.
		LastFanOut = 0.0
	elseif t < LastFanOut + ThrottleSeconds
		return
	endif
	LastFanOut = t

	FWAddOnManager m = GetManager()
	if m;/!=none/;
		m.OnMagicEffectApply(ActorRef, akCaster, akEffect)
	endif
EndEvent

Function SetState(string eventName, string strArg, float numArg, Form sender) ;Called by SendModEvent in the MCM
	ApplyFilters()
	Actor p = GetPlayer()
	if p && ActorRef == p ;One notification, not one per tracked female
		If StorageUtil.GetIntValue(p, "FWAbiltyOnMEApplyDisabled") ;Toggle value as set in MCM
			Debug.Notification("BF: OnMagicEffectApply Disabled")
		Else
			Debug.Notification("BF: OnMagicEffectApply Enabled")
		Endif
	endif
EndFunction

Function RefreshFilters(string eventName, string strArg, float numArg, Form sender) ;Called by an add-on whose filter set changed
	ApplyFilters()
EndFunction

; Registers exactly the magic effects a Misc add-on asked for, and nothing else.
; Always rebuilds from zero, so it is safe to call as often as needed.
Function ApplyFilters()
	if GetState() != "" ;Normalise instances saved in the old Processing/Disabled states
		GoToState("")
	endif
	PO3_Events_AME.UnregisterForAllMagicEffectApplyEx(self)

	Actor p = GetPlayer()
	if p && StorageUtil.GetIntValue(p, "FWAbiltyOnMEApplyDisabled") ;Toggle value as set in MCM
		; Switched off in the MCM. Staying unregistered is genuinely free, where the
		; old Disabled state still paid for a dispatched stack per magic effect.
		return
	endif

	FWAddOnManager m = GetManager()
	if m;/!=none/;
	else
		return
	endif

	Form[] filters = m.GetMagicEffectFilters()
	if filters;/!=none/;
	else
		return
	endif

	int i = filters.Length
	while i > 0
		i -= 1
		if filters[i];/!=none/;
			PO3_Events_AME.RegisterForMagicEffectApplyEx(self, filters[i], true)
		endif
	endWhile
EndFunction

; BeeingFemale.esm fills only System on this script, so resolve the rest through it.
FWAddOnManager function GetManager()
	if Manager;/!=none/;
	elseif System;/!=none/;
		Manager = System.Manager
	endif
	return Manager
endFunction

Actor function GetPlayer()
	if PlayerRef;/!=none/;
	elseif System;/!=none/;
		PlayerRef = System.PlayerRef
	endif
	if PlayerRef;/!=none/;
	else
		PlayerRef = Game.GetPlayer()
	endif
	return PlayerRef
endFunction
