Scriptname BFConsumer extends Quest
{Beeing Female NG integration sample.

 This is the whole pattern for the common case: mod events out, mod events in,
 StorageUtil for state. It compiles against PapyrusUtil and the vanilla sources
 ONLY - no Beeing Female script is in the import path, so your mod builds on a
 machine where BF is not installed and gains no hard dependency on it.

 Cycle states (FW.CurrentState):
   0 Follicular  1 Ovulating  2 Luteal  3 Menstruating
   4 1st trimester  5 2nd trimester  6 3rd trimester
   7 Labor pains  8 Replenish (post-birth recovery)}

; ---------------------------------------------------------------------------
; Detection - gate the whole integration on this, and skip it when absent.
; ---------------------------------------------------------------------------

bool Function IsBFInstalled() global
	return Game.GetModByName("BeeingFemale.esm") != 255
EndFunction

Event OnInit()
	if IsBFInstalled()
		RegisterForModEvent("BeeingFemaleConception", "OnBFConception")
		RegisterForModEvent("BeeingFemaleLabor", "OnBFLabor")
	endif
EndEvent

Event OnPlayerLoadGame()
	; registrations do not survive a load - re-register every time
	if IsBFInstalled()
		RegisterForModEvent("BeeingFemaleConception", "OnBFConception")
		RegisterForModEvent("BeeingFemaleLabor", "OnBFLabor")
	endif
EndEvent

; ---------------------------------------------------------------------------
; Events BF emits. Fathers may be None when the donor is unknown or unloaded.
; ---------------------------------------------------------------------------

Event OnBFConception(Form Mother, int ChildCount, Form Father0, Form Father1, Form Father2)
	Actor mum = (Mother as Actor)
	if !mum
		return
	endif
	Debug.Trace("[BFConsumer] " + mum + " conceived " + ChildCount + " child(ren)")
EndEvent

Event OnBFLabor(Form Mother, int ChildCount, Form Father0, Form Father1, Form Father2)
	Actor mum = (Mother as Actor)
	if !mum
		return
	endif
	Debug.Trace("[BFConsumer] " + mum + " has gone into labor")
EndEvent

; ---------------------------------------------------------------------------
; Reading her state. StorageUtil is PapyrusUtil - BF just writes these keys.
; ---------------------------------------------------------------------------

bool Function IsPregnant(Actor akFemale) global
	int iState = StorageUtil.GetIntValue(akFemale, "FW.CurrentState")
	return iState >= 4 && iState <= 7
EndFunction

int Function GetUnbornHealth(Actor akFemale) global
	{0..100, or 100 when nothing is tracked.}
	return StorageUtil.GetIntValue(akFemale, "FW.UnbornHealth", 100)
EndFunction

; ---------------------------------------------------------------------------
; Driving BF. SendModEvent is a vanilla Form method; the sender IS the target,
; so send from the female. The full command list is in the ModEvents docs.
; ---------------------------------------------------------------------------

Function Inseminate(Actor akFemale, Actor akMale) global
	; AddSperm stores it; AddSpermImpregnate also rolls conception immediately
	akFemale.SendModEvent("BeeingFemale", "AddSperm", akMale.GetFormID() as float)
EndFunction

Function GiveContraception(Actor akFemale, float afPercent = 100.0) global
	akFemale.SendModEvent("BeeingFemale", "AddContraception", afPercent)
EndFunction

Function HealUnborn(Actor akFemale, float afAmount = 25.0) global
	akFemale.SendModEvent("BeeingFemale", "HealBaby", afAmount)
EndFunction
