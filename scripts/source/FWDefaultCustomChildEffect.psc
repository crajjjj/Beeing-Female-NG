Scriptname FWDefaultCustomChildEffect extends ActiveMagicEffect

FWAddOnManager property BF_AddOnManager auto
Spell Property _BF_DefaultCustomChildSpell Auto
MagicEffect Property _BF_DefaultCustomChildEffect Auto
GlobalVariable Property GameDaysPassed Auto

float DayOfBirth
float CurrentAgeInHours
float MatureTimeInHours

float MatureTimeStep
float ScaleStep

int MatureStep
float initialScale
float finalScale

float CurrentScale
int CurrentMatureStep

Actor TargetActor

Event OnEffectStart(Actor akTarget, Actor akCaster)
;	Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: akTarget = " + akTarget + ", and akCaster = " + akCaster)
	TargetActor = akTarget
	DayOfBirth = StorageUtil.GetFloatValue(TargetActor, "FW.Child.DOB", -1)
	finalScale = BF_AddOnManager.ActorFinalScale(TargetActor)

	if(DayOfBirth == -1)
		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: Started for the first time on actor: " + akTarget + " by caster: " + akCaster)
		DayOfBirth = GameDaysPassed.GetValue()

		StorageUtil.SetFloatValue(TargetActor, "FW.Child.DOB", DayOfBirth)
		StorageUtil.SetIntValue(TargetActor, "FW.Child.IsCustomChildActor", 1)

		MatureTimeInHours = BF_AddOnManager.ActorCustomMatureTimeInHours(TargetActor)
		if(MatureTimeInHours > 0)
			MatureStep = BF_AddOnManager.ActorMatureStep(TargetActor)
			MatureTimeStep = MatureTimeInHours / MatureStep

			if MatureTimeStep < 1.0	; Must NOT be smaller than 1, else the frequent call of SetScale() in "FWDefaultCustomChildEffect" script may cause CTD!
				MatureTimeStep = 1.0
			endIf

			ScaleStep = BF_AddOnManager.ActorMatureScaleStep(TargetActor)		
			initialScale = BF_AddOnManager.ActorInitialScale(TargetActor)
				
			TargetActor.SetScale(initialScale)

	;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: MatureStep = " + MatureStep)
	;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: MatureTime = " + MatureTimeInHours + " hours")
	;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: initialScale = " + initialScale)
	;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: finalScale = " + finalScale)
	;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: MatureTimeStep = " + MatureTimeStep + " hours")
	;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: ScaleStep = " + ScaleStep)
				
			RegisterForSingleUpdateGameTime(MatureTimeStep)
		else
			FinalizeMature()
		endIf
	else
		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: restarted for some reason on actor: " + akTarget + " by caster: " + akCaster)

		CurrentAgeInHours = 24 * (GameDaysPassed.GetValue() - DayOfBirth)
		MatureTimeInHours = BF_AddOnManager.ActorCustomMatureTimeInHours(TargetActor)
		if(CurrentAgeInHours < MatureTimeInHours)
			if(MatureTimeInHours > 0)
				MatureStep = BF_AddOnManager.ActorMatureStep(TargetActor)
				MatureTimeStep = MatureTimeInHours / MatureStep

				if MatureTimeStep < 1.0	; Must NOT be smaller than 1, else the frequent call of SetScale() in "FWDefaultCustomChildEffect" script may cause CTD!
					MatureTimeStep = 1.0
				endIf

				ScaleStep = BF_AddOnManager.ActorMatureScaleStep(TargetActor)		
				initialScale = BF_AddOnManager.ActorInitialScale(TargetActor)
					
		;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: MatureStep = " + MatureStep)
		;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: MatureTime = " + MatureTimeInHours + " hours")
		;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: initialScale = " + initialScale)
		;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: finalScale = " + finalScale)
		;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: MatureTimeStep = " + MatureTimeStep + " hours")
		;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: ScaleStep = " + ScaleStep)
					
				RegisterForSingleUpdate(1.0)
			else
				FinalizeMature()
			endIf
		else
			FinalizeMature()
		endIf
	endIf
EndEvent

Event OnUpdate()
	CurrentAgeInHours = 24 * (GameDaysPassed.GetValue() - DayOfBirth)
	CurrentMatureStep = (CurrentAgeInHours / MatureTimeStep) as int

	if(CurrentAgeInHours < MatureTimeInHours)
		CurrentScale = initialScale + (CurrentMatureStep * ScaleStep)
		TargetActor.SetScale(CurrentScale)

;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: CurrentMatureStep = " + CurrentMatureStep)
;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: CurrentScale = " + CurrentScale)
		RegisterForSingleUpdateGameTime(MatureTimeStep)
	else
		FinalizeMature()
	endIf
EndEvent

Event OnUpdateGameTime()
	CurrentAgeInHours = 24 * (GameDaysPassed.GetValue() - DayOfBirth)
	CurrentMatureStep = (CurrentAgeInHours / MatureTimeStep) as int

	if(CurrentAgeInHours < MatureTimeInHours)
		CurrentScale = initialScale + (CurrentMatureStep * ScaleStep)
		TargetActor.SetScale(CurrentScale)

;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: CurrentMatureStep = " + CurrentMatureStep)
;		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: CurrentScale = " + CurrentScale)
		RegisterForSingleUpdateGameTime(MatureTimeStep)
	else
		FinalizeMature()
	endIf
endEvent

Function FinalizeMature()
;	Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: Finished mature process. Removing...")	
	TargetActor.SetScale(finalScale)
	BF_AddOnManager.AddToSLandBF(TargetActor)
endFunction

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	if(TargetActor.Is3DLoaded())
		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: Finished for some unknown reason!")
		if((!TargetActor.HasSpell(_BF_DefaultCustomChildSpell)) || (!TargetActor.HasMagicEffect(_BF_DefaultCustomChildEffect)))
			Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: re-casting!")
			TargetActor.AddSpell(_BF_DefaultCustomChildSpell)
		endIf
	else
		Debug.Trace("BeeingFemaleSE_Opt - FWDefaultCustomChildEffect: Finished as player is far away from the actor " + TargetActor)
		StorageUtil.SetIntValue(TargetActor, "FW.Child.DispelledCustomChildActor", 1)
	endIf
endEvent

Event OnDeath(Actor akKiller)
	StorageUtil.SetFloatValue(TargetActor, "FW.Child.DOD", GameDaysPassed.GetValue())

	StorageUtil.SetIntValue(TargetActor, "FW.Child.DispelledCustomChildActor", 0)
	StorageUtil.UnsetIntValue(TargetActor, "FW.Child.DispelledCustomChildActor")

	FWChildActor ca = akKiller as FWChildActor
	if(ca && !ca.IsDead())
		ca.AddExp(TargetActor.GetLevel() * 2)
	endif
endEvent