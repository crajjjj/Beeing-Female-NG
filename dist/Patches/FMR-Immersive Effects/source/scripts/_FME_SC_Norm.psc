; THIS SCRIPT RENDERED REDUNDANT BY MU DYNAMIC NORMAL MAPS


Scriptname _FME_SC_Norm extends activemagiceffect  
;
;Race Property Argonian  Auto  
;Faction Property GenericFaction  Auto  
;Race Property Khajiit  Auto  
;_FME_SC_MCM Property MCM  Auto  
;Form Property PizzaNapkin  Auto
;Race Property VampLord  Auto  
;Race Property Werewolf  Auto  
;  
;Actor 	ActorRef
;Race race_current
;int RCT5
;bool isFemale
;string name

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DEBUG ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EVENTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The magic effect, called when spell is first added to actor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ACTUAL SCRIPT STUFF ;;;;;;;;;;;;;;;;;;;;;;;;;;

;Event OnEffectStart(Actor akActor, Actor Caster)
;	ActorRef = akActor
;	name = ActorRef.GetBaseObject().GetName()
;	isFemale = ActorRef.GetActorBase().GetSex() as bool
;	;race_current = ActorRef.GetRace()
;	if isFemale
;		Debug.TraceUser("FMIE", "OnEffectStart       " + name)
;		RegisterForModEvent("_FME_ApplyNormalMaps", "ApplyPregNormalEvent")
;		RegisterForNiNodeUpdate()
;		NormalMapChecker(ActorRef)
;		RegisterForUpdateGameTime(1.0)
;	endIf
;EndEvent
;
;Event OnPlayerLoadGame()
;	Debug.TraceUser("FMIE", "OnPlayerLoadGame    " + name)
;	RegisterForModEvent("_FME_ApplyNormalMaps", "ApplyPregNormalEvent")
;	MCM.SendUpdateEvent()
;endEvent
;
;Event OnNiNodeUpdate(ObjectReference akActor)
;	Debug.TraceUser("FMIE", "OnNiNodeUpdate      " + name)
;	NormalMapChecker(ActorRef)
;EndEvent
;
;Event OnUpdateGameTime()
;	NormalMapChecker(ActorRef)
;EndEvent
;
;Event OnEffectFinish(Actor akActor, Actor Caster)
;	UnregisterForModEvent("_FME_ApplyNormalMaps")
;	UnregisterForUpdateGameTime()
;	UnregisterForNiNodeUpdate()
;	NormalMapChecker(ActorRef)
;EndEvent
;
;event	OnDying(Actor akKiller)
;
;	OnEffectFinish(ActorRef, none)
;
;EndEvent
;
;Event ApplyPregNormalEvent()
;	Debug.TraceUser("FMIE", "ApplyPregNormalEvent " + name)
;	ApplyPregNormalMaps()
;EndEvent
;
;Function NormalMapChecker(Actor akActor)
;	GoToState("Busy")
;	race_current = ActorRef.GetRace()
;	If (akActor == None)
;		Debug.TraceUser("FMIE", "akActor == none    " + name)
;		return
;	elseIf (race_current == Werewolf || race_current == Vamplord)
;		Debug.TraceUser("FMIE", "IsBeastForm         " + name)
;		return
;	EndIf
;	ApplyPregNormalMaps()
;	GoToState("")
;EndFunction
; Find normal map texture path
;string Function GetPregNormalPath(int RCT6)
;	string path = "textures\\dw\\pregnormals\\"
;	;If (race_current == Argonian)
;	;	path += "argonian\\"
;	;ElseIf (race_current == Khajiit)
;	;	path += "khajiit\\"
;	;EndIf
;	race_current = ActorRef.GetRace()
;	If (race_current == Argonian)
;		path += "argonian\\"
;	ElseIf (race_current == Khajiit)
;		path += "khajiit\\"
;	EndIf
;	
;	; FMR Compatibility: Pregnancy 1-100 linear, Recovery 101-115 fades out
;	If (RCT6 >= 1 && RCT6 < 20)
;		path += "20\\femalebody_1_msn.dds"
;	elseIf (RCT6 >= 20 && RCT6 < 40)
;		path += "40\\femalebody_1_msn.dds"
;	elseIf (RCT6 >= 40 && RCT6 < 60)
;		path += "60\\femalebody_1_msn.dds"
;	elseIf (RCT6 >= 60 && RCT6 < 80)
;		path += "80\\femalebody_1_msn.dds"
;	elseIf (RCT6 >= 80 && RCT6 <= 100)
;		path += "100\\femalebody_1_msn.dds"
;	elseIf (RCT6 >= 101 && RCT6 < 105)
;		; Recovery: belly shrinking, use 80%
;		path += "80\\femalebody_1_msn.dds"
;	elseIf (RCT6 >= 105 && RCT6 < 109)
;		path += "60\\femalebody_1_msn.dds"
;	elseIf (RCT6 >= 109 && RCT6 < 113)
;		path += "40\\femalebody_1_msn.dds"
;	elseIf (RCT6 >= 113 && RCT6 <= 115)
;		path += "20\\femalebody_1_msn.dds"
;	else
;		path += "none.dds"
;	endif
;	; Debug.TraceUser("SkillBasedMuscle", path)
;	return path
;EndFunction

;Function ApplyPregNormalMaps()
;	RCT5 = ActorRef.GetFactionRank(GenericFaction)
;	string bodyTexPath = GetPregNormalPath(RCT5)
;	if (NiOverride.HasSkinOverride(ActorRef, isFemale, false, 0x80, 9, 1)) ;Feet
;		NiOverride.RemoveSkinOverride(ActorRef, isFemale, false, 0x80, 9, 1)
;	endif
;	if (NiOverride.HasSkinOverride(ActorRef, isFemale, false, 0x04, 9, 1)) ;Body
;		NiOverride.RemoveSkinOverride(ActorRef, isFemale, false, 0x04, 9, 1)
;	endif
;	if MiscUtil.FileExists("data\\" + bodyTexPath)
;		NiOverride.AddSkinOverrideString(ActorRef, isFemale, false, 0x80, 9, 1, bodyTexPath, true) ;Feet
;		NiOverride.AddSkinOverrideString(ActorRef, isFemale, false, 0x04, 9, 1, bodyTexPath, true) ;Body
;	endif
;	NiOverride.ApplySkinOverrides(ActorRef)
;
;	if  !(ActorRef.GetEquippedArmorInSlot(33))
;		Debug.TraceUser("FMIE", "GetEquippedArmor    " + name)
		;Debug.Notification ("Let's get you cleaned up")
;		ActorRef.EquipItem(PizzaNapkin, 0, 1)
;		Utility.Wait(0.005)
;		;Debug.Notification ("DONE")
;		ActorRef.RemoveItem(PizzaNapkin, 1, 1)
;	endif
;
;endFunction



;state Busy
;	Function NormalMapChecker(Actor akActor)
;		Debug.TraceUser("FMIE", "NormalMapChecker BUSY   " + name)
;	EndFunction
;endState
;

