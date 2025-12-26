Scriptname FWPlayerAlias extends ReferenceAlias  

FWSystem property System auto
FWTextContents property Contents auto

spell property CloakAbility auto
actor property PlayerRef auto
int property Interval Auto
spell property BeeingFemaleSpell auto
spell property BeeingMaleSpell auto
spell property BeeingNUFemaleSpell auto

Race Property ElderRace Auto
Race Property ElderRaceVampire Auto

Globalvariable property CloakingSpellEnabled auto

Perk Property _BFPCP_PlayerMenstruation Auto

Armor kArmorItem

int oldSex = 0
Int iStateUpdateInterval

;Tkc (Loverslab): properties for reworked scan
Quest Property FindActors Auto ;Scanquest
ReferenceAlias[] Property FoundFemales Auto ; Female aliases from scanquest
ReferenceAlias[] Property FoundMales Auto ; Male aliases from scanquest


FWPantyWidget property PantyWidget auto
armor property Sanitary_Napkin_Normal auto
armor property Tampon_Normal auto
spell property Effect_VaginalBloodLow auto
spell property Effect_VaginalBloodHigh auto
Globalvariable property ModEnabled auto

Event OnInit()
	;RegisterForSingleUpdate(1)
	
	If self
		Actor SelfActor = GetReference() as Actor
		if(SelfActor)
			oldSex = SelfActor.GetActorBase().GetSex()
		endIf
	EndIf
	OnPlayerLoadGame()
	;RegisterForMenu("RaceSex Menu")
EndEvent

Event OnMenuOpen(string menuName)
	if menuName=="RaceSex Menu"
		oldSex=PlayerRef.GetLeveledActorBase().GetSex()
		;System.Message("Race Menu open",System.MSG_Debug)
		if System.Player;/!=none/; ;by Tkc (Loverslab)
			System.Player.ResetBelly()
		endif
	endIf
endEvent

Event OnMenuClose(string menuName)
	if menuName=="RaceSex Menu"
		;System.Message("Race Menu closed",System.MSG_Debug)
		
		System.CheckPlayerSex()
		
		if System.Player;/!=none/; ;Tkc (Loverslab): optimization
			System.Player.GetBaseMeasurements(true)
			System.Player.SetBelly()
		endif
	endIf
endEvent

Event OnUpdate()
	GoToState("Processing")
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	;if CloakingSpellEnabled.GetValueInt();/==1/; && System.ModEnabled.GetValueInt();/==1/; ;Tkc (Loverslab): optimization; commented because onenterstate same conditions
		RegisterForSingleUpdate(0.25)
	;EndIf
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	PantyWidget.UpdateContent()
	kArmorItem = akBaseObject as Armor
	if kArmorItem
	  	If (kArmorItem == Sanitary_Napkin_Normal || kArmorItem == Tampon_Normal)
			PlayerRef.DispelSpell(Effect_VaginalBloodLow)				
			PlayerRef.DispelSpell(Effect_VaginalBloodHigh)
		Endif
	EndIf
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	PantyWidget.UpdateContent()
EndEvent

Function OnModReset() ;***Added by Bane
	RegisterForSingleUpdate(5)
	UnregisterForAllMenus()
	RegisterForMenu("RaceSex Menu")
EndFunction

Event OnPlayerLoadGame()
	RegisterForSingleUpdate(2.5)
	UnregisterForAllMenus()
	RegisterForMenu("RaceSex Menu")
	Utility.WaitMenuMode(1)
	System.OnGameLoad()
	Interval = 15
	If PlayerRef.HasPerk(_BFPCP_PlayerMenstruation);by Tkc (Loverslab)
	else;If !PlayerRef.HasPerk(_BFPCP_PlayerMenstruation)
		PlayerRef.AddPerk(_BFPCP_PlayerMenstruation)
	EndIf
EndEvent

Event OnRaceSwitchComplete()
	System.Message(Contents.RaceSwitchedCompleted,System.MSG_Debug)
;/original>
	If oldSex != GetActorReference().GetActorBase().GetSex()
		If GetActorReference().GetActorBase().GetSex() == 0
			If (! GetActorReference().HasSpell(BeeingMaleSpell))
				GetActorReference().AddSpell(BeeingMaleSpell)
			EndIf
			If (GetActorReference().HasSpell(BeeingFemaleSpell))
				GetActorReference().RemoveSpell(BeeingFemaleSpell)
			EndIf
		Else
			If (! GetActorReference().HasSpell(BeeingFemaleSpell))
				GetActorReference().AddSpell(BeeingFemaleSpell)
			EndIf
			If (! GetActorReference().HasSpell(BeeingMaleSpell)) ;Tkc , here is error, must be removed '!'
				GetActorReference().RemoveSpell(BeeingMaleSpell)
			EndIf
		EndIf
		oldSex = GetActorReference().GetActorBase().GetSex()
	EndIf
/; ;<original	
	;Tkc (Loverslab): optimization
	Actor SelfActor = GetReference() as Actor
	int newSex = SelfActor.GetActorBase().GetSex() ;Tkc (Loverslab): optimization ; will be using three times after this
	If oldSex == newSex
	else;If oldSex != GetActorReference().GetActorBase().GetSex()
		If newSex == 0;"if male"
			If (SelfActor.HasSpell(BeeingMaleSpell)) ;Tkc (Loverslab): optimization
			else;If (! GetActorReference().HasSpell(BeeingMaleSpell))
				SelfActor.AddSpell(BeeingMaleSpell)
			EndIf
			If (SelfActor.HasSpell(BeeingFemaleSpell))
				SelfActor.RemoveSpell(BeeingFemaleSpell)
			EndIf
		Else;"if female"
			If (SelfActor.HasSpell(BeeingFemaleSpell)) ;Tkc (Loverslab): optimization
			else;If (! GetActorReference().HasSpell(BeeingFemaleSpell))
				SelfActor.AddSpell(BeeingFemaleSpell)
			EndIf
			If (SelfActor.HasSpell(BeeingMaleSpell)) ;Tkc (Loverslab): fix here. Removed '!'
				SelfActor.RemoveSpell(BeeingMaleSpell)
			EndIf
		EndIf
		oldSex = newSex
	EndIf
EndEvent

Function ProcessActor(Actor akTarget, bool IsFemale = true); Tkc (Loverslab): optimization: IsFemale added to split male and female processing
;/original before questscan was added
	;String sName = akTarget.GetActorBase().GetName()
	;If sName == ""
	;	sName = akTarget.GetLeveledActorBase().GetName()
	;EndIf
	;Debug.Trace("BF: " + sName+ " " + akTarget as string + " is in ProcessActor.")
	;Debug.Notification("BF: " + sName+ " " + akTarget as string + " is in ProcessActor.")
	If akTarget.Is3DLoaded() ;Tkc (Loverslab): optimization
	else;If !akTarget.Is3DLoaded() ;In my tests BeeingFemale effects fail to get applied if the character is not 3D Loaded
		Return
	EndIf
	;If akTarget.GetFormID() < 4278190080;Exclude Temporary References (FormID > 0xFF000000)
		If akTarget.HasSpell(BeeingFemaleSpell)
			if akTarget.HasMagicEffect(BeeingFemaleSpell.GetNthEffectMagicEffect(0))
			else;if !akTarget.HasMagicEffect(BeeingFemaleSpell.GetNthEffectMagicEffect(0))
				;Debug.Trace("BF: " + sName + " has Female Spell but not the Effect - removed")
				akTarget.RemoveSpell(BeeingFemaleSpell)
				;Utility.WaitMenuMode(0.5)
			endif
			Return
		endif
		if akTarget.HasSpell(BeeingMaleSpell)
			if akTarget.HasMagicEffect(BeeingMaleSpell.GetNthEffectMagicEffect(0))
			else;if !akTarget.HasMagicEffect(BeeingMaleSpell.GetNthEffectMagicEffect(0))
				;Debug.Trace("BF: " + sName + " has Male Spell but not the Effect - removed")
				akTarget.RemoveSpell(BeeingMaleSpell)
				;Utility.WaitMenuMode(0.5)
			endif
			Return
		endif
		
		If ValidateActor(akTarget)
			If System.IsValidateMaleActor(akTarget) > 0;(akTarget.GetLeveledActorBase().GetSex() == 0)
				if akTarget.HasSpell(BeeingMaleSpell) ;Tkc (Loverslab): optimization
				else;if akTarget.HasSpell(BeeingMaleSpell)==false
					;Debug.Trace("BF: "+ sName + " is male - Add BeeingMaleSpell")
					akTarget.AddSpell(BeeingMaleSpell)
				endif
			ElseIf (akTarget.GetLeveledActorBase().IsUnique())
				;if akTarget.HasSpell(BeeingFemaleSpell)==false  && System.IsValidateFemaleActor(akTarget) > 0
				if akTarget.HasSpell(BeeingFemaleSpell) ;Tkc (Loverslab): optimization
				else
				if System.IsValidateFemaleActor(akTarget) > 0
					;Debug.Trace("BF: " + sName + " is female unique - Add BeeingFemaleSpell")
					akTarget.AddSpell(BeeingFemaleSpell)
				endif
				endif
			ElseIf BeeingNUFemaleSpell
				if akTarget.HasSpell(BeeingNUFemaleSpell)
				else;if akTarget.HasSpell(BeeingNUFemaleSpell)==false 
					;Debug.Trace("BF: " + sName + " is female non-unique - Add BeeingNUFemaleSpell")
					akTarget.AddSpell(BeeingNUFemaleSpell)
				endif
			EndIf
		Endif
	;EndIf
	Utility.WaitMenuMode(0.5) ;Throttle Process
/;;;;;;;;;;;
	;Tkc (Loverslab) rewrited for quest aliases scan
	if akTarget; Tkc (Loverslab): skip if empty alias
		;String sName = akTarget.GetActorBase().GetName()
		;If sName == ""
		;	sName = akTarget.GetLeveledActorBase().GetName()
		;EndIf
		;Debug.Trace("BF: " + sName+ " " + akTarget as string + " is in ProcessActor.")
		;Debug.Notification("BF: " + sName+ " " + akTarget as string + " is in ProcessActor.")
		if IsFemale		
			;If (akTarget.GetLeveledActorBase().IsUnique())
				if akTarget.HasSpell(BeeingFemaleSpell)
					;Debug.Trace("BF: " + sName + " has Female Spell but not the Effect - removed")
					akTarget.RemoveSpell(BeeingFemaleSpell)
					Return
				else;if akTarget.HasSpell(BeeingFemaleSpell)==false
					;Debug.Trace("BF: " + sName + " is female unique - Add BeeingFemaleSpell")
					akTarget.AddSpell(BeeingFemaleSpell)
				endif
;			Else;If BeeingNUFemaleSpell
;				if akTarget.HasSpell(BeeingNUFemaleSpell)
;					akTarget.RemoveSpell(BeeingNUFemaleSpell)
;					Return
;				else;if akTarget.HasSpell(BeeingNUFemaleSpell)==false 
;					;Debug.Trace("BF: " + sName + " is female non-unique - Add BeeingNUFemaleSpell")
;					akTarget.AddSpell(BeeingNUFemaleSpell)
;				endif
;			Endif
		else			
			if akTarget.HasSpell(BeeingMaleSpell)
				;Debug.Trace("BF: " + sName + " has Female Spell but not the Effect - removed")
				akTarget.RemoveSpell(BeeingFemaleSpell)
				Return
			else;if akTarget.HasSpell(BeeingMaleSpell)==false
				;Debug.Trace("BF: "+ sName + " is male - Add BeeingMaleSpell")
				akTarget.AddSpell(BeeingMaleSpell)
			endif
		Endif
		Utility.WaitMenuMode(0.5) ;Throttle Process
	Endif
;;;;;;;;;
EndFunction

;/Bool Function ValidateActor(Actor akActor)
	;Return (!akActor.IsChild() && akActor.GetRace() != ElderRace && akActor.GetRace() != ElderRaceVampire)
	if akActor.IsChild()
	else;!akActor.IsChild()
		race r = akActor.GetRace()
		if r == ElderRace
		else;akActor.GetRace() != ElderRace
			if r == ElderRaceVampire
			else;akActor.GetRace() != ElderRaceVampire)
				Return true
			endif
		endif
	endif
	Return false
EndFunction/; 

State Processing

	Event OnBeginState()
		iStateUpdateInterval = Interval
		;If CloakingSpellEnabled.GetValueInt();/==1/; && System.ModEnabled.GetValueInt();/==1/;  ;Tkc (Loverslab): optimization
		If ModEnabled.GetValue() As int ;Tkc (Loverslab): optimization
		If CloakingSpellEnabled.GetValue() As int
			;/Actor[] CellActors = MiscUtil.ScanCellNPCs(PlayerRef, 2048.0)
			Int iActorIdx = CellActors.Length
			;debug.trace("BF: Checking " + iActorIdx + " actors for BF spells")
			While iActorIdx
				iActorIdx -=1
				ProcessActor(CellActors[iActorIdx])
			EndWhile/;
			;;;;;;;;;;;;;;;;;;;
			; Tkc (Loverslab): Get actors by ScanQuest aliases
			;Added conditions for aliases:
			;get distance to Player < 2048
			;IsActor==1
			;Is3DLoaded==1
			;IsInCombat==0
			;IsMale\IsFemale == 1
			;IsCommandedActor==0
			;IsChild==0
			;GetVoiceType=ChildVoice==0
			;GetRace>ElderRace==0
			;IsGhost==0
			;HasMagicEffect BF\BM == 0
			;;All equal conditions in the script do not need anymore		
			FindActors.Start()
			Utility.Wait(0.5)
			Int iActorIdx = 7 ;FoundFemales.Length
				;debug.trace("BF: Checking " + iActorIdx + " males and females for BF spells")
			While iActorIdx
				iActorIdx -=1
					;debug.trace("BF: Checking #" + iActorIdx + " female actor alias ='" + FoundFemales[iActorIdx].GetActorReference() + "'.")
				ProcessActor(FoundFemales[iActorIdx].GetReference() as Actor)
					;debug.trace("BF: Checking #" + iActorIdx + " male actor alias ='" + FoundMales[iActorIdx].GetActorReference() + "'.")
				ProcessActor(FoundMales[iActorIdx].GetReference() as Actor, false)
			EndWhile
			FindActors.Stop()
			;;;;;;;;;;;;;;;;;
		EndIf
		EndIf
		;Debug.Trace("- Register for single update("+Interval+")")
		GoToState("")
	EndEvent

	Event OnUpdate()
		;Catch Any pending events
	EndEvent

	Event OnLocationChange(Location akOldLoc, Location akNewLoc)
		iStateUpdateInterval = 5
	EndEvent

	Event OnEndState()
		RegisterForSingleUpdate(iStateUpdateInterval)
	EndEvent

EndState

; 07.06.2019 Loverslab Tkc fix and code optimizations. Changes marked with " ;Tkc (Loverslab): optimization" comment. Rewrited for scan with quest aliases