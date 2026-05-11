Scriptname _FME_SC_Colostrum extends ActiveMagicEffect  
{Applies Effects of Colostrum Only. Does not apply it.}

int instanceID

OninusLactis	Lactis
SexLabFramework SexLab
int RandomM
Actor FMETarget
bool MME

Event OnEffectStart(Actor Target, Actor Caster)
	
	if (Game.GetModByName("SexLab.esm") != 255)
		SexLab = GetMeMy4m(0x000D62, "SexLab.esm") as SexLabFramework
	endIf
	if (Game.GetModByName("OninusLactis.esp") != 255)
		Lactis = GetMeMy4m(0x000D61, "OninusLactis.esp") as OninusLactis
	endIf

	if MiscUtil.FileExists("data/scripts/MME_Storage.pex") && MiscUtil.FileExists("data/MilkModNEW.esp")
		MME = true
	else
		MME = false
	endIf

	FMETarget = Target
	if Sexlab && !Lactis && MME == false
 		; Make the player moan
 		sslBaseVoice voice = SexLab.PickVoice(Target)
		voice.Moan(Target, 20, false)

		; Set Player Expression
		sslBaseExpression Wet1 = SexLab.GetExpressionByName("Shy")
		sslBaseExpression Wet2 = SexLab.GetExpressionByName("Sad")
		sslBaseExpression Wet3 = SexLab.GetExpressionByName("Afraid")

		if RandomM == 0
			Wet1.ApplyTo(Target, Utility.RandomInt(30,70))
		elseif RandomM == 1
			Wet2.ApplyTo(Target, Utility.RandomInt(20,50))
		elseif RandomM == 2
			Wet3.ApplyTo(Target, Utility.RandomInt(10,30))
		endif
		
		
		; Message Randomization
		RandomM= Utility.RandomInt(0,2)
		if RandomM == 0
			if FMETarget == Game.GetPlayer()
				Debug.Notification ("Your breasts begin leaking milk, moistening your outfit front.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+"'s breasts begin leaking milk, moistening her top.")
			endif
		elseif RandomM == 1
			if FMETarget == Game.GetPlayer()
				Debug.Notification ("Your top becomes wet as your breasts let down unexpectedly.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+"'s front becomes wet as her breasts let down unexpectedly.")
			endif
		elseif RandomM ==2
			If FMETarget == Game.GetPlayer()
				Debug.Notification(" Twin dark spots appear on your nipples as you feel your breast expel a bit of milk.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+"'s gasps slightly as you see twin dark spots appear on her top.")
			endif
		endif

		; Apply front lactation effect - cum shader??
		SexLab.ApplyCum(Target, 2)
	endif

	if Sexlab && Lactis && MME == false
		; Make the player moan
		sslBaseVoice voice = SexLab.PickVoice(Target)
		voice.Moan(Target, 20, false)

		; Set Player Expression
		sslBaseExpression Wet1 = SexLab.GetExpressionByName("Shy")
		sslBaseExpression Wet2 = SexLab.GetExpressionByName("Sad")
		sslBaseExpression Wet3 = SexLab.GetExpressionByName("Afraid")

		if RandomM == 0
			Wet1.ApplyTo(Target, Utility.RandomInt(30,70))
		elseif RandomM == 1
			Wet2.ApplyTo(Target, Utility.RandomInt(20,50))
		elseif RandomM == 2
			Wet3.ApplyTo(Target, Utility.RandomInt(10,30))
		endif
		
		
		; Message Randomization
		RandomM= Utility.RandomInt(0,2)
		if RandomM == 0
			if FMETarget == Game.GetPlayer()
				Debug.Notification ("You feel a slight tingling as your breasts begin expressing off-white milk.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+"'s breasts begin expressing off-white milk, moistening her top.")
			endif
		elseif RandomM == 1
			if FMETarget == Game.GetPlayer()
				Debug.Notification ("Your top becomes damp as your breasts let down a little.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+"'s front becomes damp as her breasts let down a little.")
			endif
		elseif RandomM ==2
			If FMETarget == Game.GetPlayer()
				Debug.Notification(" Twin dark spots appear on your nipples as you feel your breast expel a bit of colostrum.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+"'s gasps slightly as you see twin dark spots appear on her top.")
			endif
		endif
		Lactis.StartNippleLeak(FMETarget,160 as int)
		; Apply nipple leak effect - overlay from lactis
	endif

	if Sexlab && MME == true
		; Make the player moan
		sslBaseVoice voice = SexLab.PickVoice(Target)
		voice.Moan(Target, 20, false)
		; Set Player Expression
		sslBaseExpression Wet1 = SexLab.GetExpressionByName("Shy")
		sslBaseExpression Wet2 = SexLab.GetExpressionByName("Sad")
		sslBaseExpression Wet3 = SexLab.GetExpressionByName("Afraid")
		if RandomM == 0
			Wet1.ApplyTo(Target, Utility.RandomInt(30,70))
		elseif RandomM == 1
			Wet2.ApplyTo(Target, Utility.RandomInt(20,50))
		elseif RandomM == 2
			Wet3.ApplyTo(Target, Utility.RandomInt(10,30))
		endif
		
		
		; Message Randomization
		RandomM= Utility.RandomInt(0,2)
		
		if FMETarget == Game.GetPlayer()
			MilkQUEST MilkQ = Quest.GetQuest("MME_MilkQUEST") as MilkQUEST
			Float RandLactContribute = Utility.RandomFloat(1.0,3.0)
			Float CurrentLact = StorageUtil.GetFloatValue(FMETarget, "MME.MilkMaid.LactacidCount", 0.0)
			Float PregLactBase = 0.5*(1.0+RandomM)*RandLactContribute
			Int FME_ML = StorageUtil.GetFloatValue(FMETarget, "MME.MilkMaid.Level", 0.0) as int
			Float FME_MaxLact = 10.0 + FME_ML*10.0
			Float FME_MaxPossibleLact = PregLactBase + CurrentLact
			if FME_MaxLact <= FME_MaxPossibleLact && FME_MaxLact > CurrentLact
				StorageUtil.SetFloatValue(FMETarget, "MME.MilkMaid.LactacidCount", FME_MaxLact)
			ElseIf FME_MaxLact > FME_MaxPossibleLact && FME_MaxLact > CurrentLact
				StorageUtil.SetFloatValue(FMETarget, "MME.MilkMaid.LactacidCount", FME_MaxPossibleLact)
			endIf
			Float ActualLact = StorageUtil.GetFloatValue(FMETarget, "MME.MilkMaid.LactacidCount", 0.0)
		endIf
		if RandomM == 0
			If FMETarget == Game.GetPlayer()
				Debug.Notification("You feel a slight tingling as your breasts start to produce a little more milk.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+" looks a little uncofortable.")
			endif
		elseif RandomM == 1
			if FMETarget == Game.GetPlayer()
				Debug.Notification ("You feel a tenseness in your chest, as your body starts to produce milk faster.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+" stops for a minute to readjust her top.")
			endif
		elseif RandomM ==2
			if FMETarget == Game.GetPlayer()
				Debug.Notification ("Woah! You feel a rush of hormones as your body starts lactating much harder.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+" stops and lifts one of her breasts; you see a dark spot soak through.")
			endif
		endif
	endIf
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
	if SexLab
		SexLab.ClearMFG(Target)
	endIf
	if Lactis
		Lactis.StopNippleLeak(FMETarget)
	endif
EndEvent

Event OnDying(Actor akKiller)

	Dispel()

EndEvent

form	function	GetMeMy4m(int formNumber, string pluginName)

	int theLO = Game.GetModByName(pluginName)
	if ((theLO == 255) || (theLO == 0)) ; 255 = not found, 0 = no skse
		Debug.Trace(pluginName + " not loaded or SKSE not found", 1)
		return	none
	elseIf (theLO > 255) ; > 255 = ESL
		; the first FIVE hex digits in an ESL are its address, so a formNumber exceeding 0xFFF or below 0x800 is invalid
		if ((Math.LogicalAnd(0xFFFFF000, formNumber) != 0) || (Math.LogicalAnd(0x00000800, formNumber) == 0))
			Debug.Trace("FM+: Invalid FormID " + formNumber + " requested from " + pluginName, 2)
			return	none
		endIf
		theLO -= 256
		return	Game.GetFormEx(Math.LogicalOr(Math.LogicalOr(0xFE000000, Math.LeftShift(theLO, 12)), formNumber))
	else	; regular ESL-free plugin
		return	Game.GetFormEx(Math.LogicalOr(Math.LeftShift(theLO, 24), formNumber))
	endIf

endFunction