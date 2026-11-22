Scriptname FWPCBirth Hidden
{Bridge to PCBirth (PCB_Childbirth.esp), an optional mod whose birth scene Beeing Female can
 play for the player instead of its own lay-down animation.

 This is the only script typed against PCB_Controller, so an install without PCBirth breaks
 nothing but this file, and nothing calls it there: every caller checks
 FWSystem.IsPCBirthInstalled() first. That check lives outside on purpose: a script whose
 types cannot be linked cannot answer anything.
 PCBirth ships no source; the controller's names were read from its compiled script and the
 compile-time header lives outside the repo (see the ppj import).}

; PCB_Main, the quest that carries PCB_Controller
int function ControllerID() global
	return 0x800
endFunction

; PCB_DeliveredBaby, the misc item a PCBirth scene leaves on the ground for each birth
int function NewbornID() global
	return 0x808
endFunction

PCB_Controller function GetController() global
	return Game.GetFormFromFile(ControllerID(), "PCB_Childbirth.esp") as PCB_Controller
endFunction

; PCBirth runs a pregnancy of its own for the player (conception after a SexLab scene, belly,
; widget). Next to Beeing Female that is a second pregnancy on the same woman, so it is
; switched off and a running one is ended. PCBirth's scene itself needs no pregnancy: with
; its own pregnancy off it plays on request.
; Returns true when something was changed.
bool function TakeOverPregnancy() global
	PCB_Controller pcb = GetController()
	if !pcb
		return false
	endif
	bool changed = false
	if pcb.PregnancyEnabled
		pcb.PregnancyEnabled = false
		changed = true
	endif
	if pcb.IsPregnant() && !pcb.IsSceneActive()
		pcb.EndPregnancy(true)
		changed = true
	endif
	return changed
endFunction

; Starts one PCBirth scene of one birth, or of three in a row (PCBirth has no other counts).
; False when PCBirth did not take it: a scene of its own is running, it is busy with its
; care or milk animation, or the controller is missing.
bool function StartScene(bool abTriplets) global
	PCB_Controller pcb = GetController()
	if !pcb || pcb.IsSceneActive()
		return false
	endif
	; StartScene reads BabyCount once, before it returns, so the player's own MCM
	; choice goes back right after.
	int oldCount = pcb.BabyCount
	if abTriplets
		pcb.BabyCount = 3
	else
		pcb.BabyCount = 1
	endif
	pcb.StartScene()
	pcb.BabyCount = oldCount
	return pcb.IsSceneActive()
endFunction

bool function IsSceneActive() global
	PCB_Controller pcb = GetController()
	return pcb && pcb.IsSceneActive()
endFunction

function StopScene() global
	PCB_Controller pcb = GetController()
	if pcb
		pcb.AbortScene()
	endif
endFunction

; Removes the newborn items PCBirth's scene left around the mother. Beeing Female delivers
; its own child right after, and both would be the same baby twice.
function RemoveNewborns(ObjectReference akCenter) global
	Form newborn = Game.GetFormFromFile(NewbornID(), "PCB_Childbirth.esp")
	if !newborn || !akCenter
		return
	endif
	int guard = 6
	while guard > 0
		guard -= 1
		ObjectReference ref = Game.FindClosestReferenceOfTypeFromRef(newborn, akCenter, 1500.0)
		if !ref || ref.IsDisabled()
			guard = 0
		else
			ref.Disable()
			ref.Delete()
		endif
	endWhile
endFunction
