Scriptname FWAbortionItem extends FWSpell

; Abortion Draught effect - the deliberate counterpart to the abortus the cycle
; can roll on its own. On drink it ends an existing pregnancy through
; Controller.AbortusBaby, the same entry point the MCM cheat uses: unborn health
; drops to 0 and FW.Abortus goes to 2, with
; FW.AbortusInduced marking the loss as deliberate so the BeeingFemaleAbort event
; that follows reports Reason "abortion" rather than "miscarriage".
;
; The loss is NOT instant. AbortusBaby only commits it; BF's staged abortus machine
; resolves it roughly a game day later with the usual pain and bleeding. That is on
; purpose - it reuses the tested path instead of a second, parallel one.
;
; Unlike FWContraceptionItem this takes no magnitude: there is nothing to scale, a
; pregnancy either ends or it does not. The EFIT magnitude on the potion is unread.

actor ActorRef
bool bInit=false

function execute()

	if bInit==false || ActorRef==none
		return
	endif
	; AbortusBaby does not check the MCM Abortus toggle, but castAbortus - which is
	; what actually resolves the loss - does. With abortus off we would commit the
	; state and nothing would ever act on it, and because GiveBirth ignores unborn
	; health in that case the pregnancy would just carry to term. Refuse up front
	; instead of silently eating the draught.
	; Debug.Notification rather than System.Message: the latter takes a localized
	; Contents string, and adding one means resaving the localized ESM, which
	; renumbers its string IDs and desyncs the hand-made translations. Hardcoded
	; English has precedent (FWSystem.GrowChildToAdult does the same).
	if System.cfg.abortus
	else
		Debug.Notification("Nothing happens - abortus is disabled in the Beeing Female settings")
		return
	endif
	; Do not restart a loss that is already under way. AbortusBaby has no
	; mid-abortus guard of its own - unlike DamageBaby and SetBabyHealth, which both
	; bail on FW.Abortus > 1 - so a second draught would knock FW.Abortus back to 2
	; and FW.AbortusTime forward to now, postponing the resolution every time she
	; drinks. Its own state guard cannot help here either: "s < 4 && s == 8" can
	; never be true, so it does not refuse during labor or replenish.
	if StorageUtil.GetIntValue(ActorRef, "FW.Abortus", 0) > 1
		Debug.Notification("Nothing happens - the pregnancy is already ending")
		return
	endif
	; Past here AbortusBaby still no-ops on a woman who is untracked or carries no
	; children, so there is nothing to check for that.
	Controller.AbortusBaby(ActorRef)
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
