Scriptname FME_SC_Lact3T extends ActiveMagicEffect
{Applies Effects of Lactation Only. Does not apply it.}

; FMR-IE: Standalone - no FM+ dependencies

Potion			Property	BreastMilk		Auto ; "Jug of Milk", added proportionally to the amount of milk expressed

int instanceID

OninusLactis	Lactis
SexLabFramework SexLab
bool MME
int RandomM
Actor FMETarget

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
			If FMETarget == Game.GetPlayer()
				Debug.Notification("You feel a slight tingling as twin dark spots appear on your nipples. Your breasts are expelling a bit of milk.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+"'s gasps slightly as you see twin dark spots appear on her top.")
			endif
		elseif RandomM == 1
			if FMETarget == Game.GetPlayer()
				Debug.Notification ("Your breasts begin leaking some milk, causing a mess as it drips down your outfit front.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+"'s breasts begin leaking some milk, moistening her top.")
			endif
		elseif RandomM ==2
			if FMETarget == Game.GetPlayer()
				Debug.Notification ("Oh! You feel relieved as your top soaks, your breasts squirting a large amount of milk.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+"'s front becomes wet as her breasts let down greatly.")
			endif
		endif
		Lactis.StartNippleSquirt(FMETarget,RandomM)
		; Apply front lactation effect - lactis
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
			Float RandMilkContribute = Utility.RandomFloat(1.0,3.0)
			Float CurrentMilk = MME_Storage.getMilkCurrent(FMETarget)
			Float PregMilkBase = 0.5*(1.0+RandomM)*RandMilkContribute
			Int FME_ML = MME_Storage.getMaidLevel(FMETarget)
			Float FME_MaxMilk = 4.0 + FME_ML*2.0
			Float FME_MaxPossibleMilk = PregMilkBase + CurrentMilk
			if FME_MaxMilk <= FME_MaxPossibleMilk && FME_MaxMilk > CurrentMilk
				MME_Storage.setMilkCurrent(FMETarget, FME_MaxMilk, false)
			ElseIf FME_MaxMilk > FME_MaxPossibleMilk && FME_MaxMilk > CurrentMilk
				MME_Storage.setMilkCurrent(FMETarget, FME_MaxPossibleMilk, false)
			endIf
			Float ActualMilk = MME_Storage.getMilkCurrent(FMETarget)
		endIf
		if RandomM == 0
			If FMETarget == Game.GetPlayer()
				Debug.Notification("Your chest tingles as your milk begins to come in.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+" looks a little uncofortable.")
			endif
		elseif RandomM == 1
			if FMETarget == Game.GetPlayer()
				Debug.Notification ("Your breasts feel bloated, a little more milk has been added.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+" stops for a minute to readjust her top.")
			endif
		elseif RandomM ==2
			if FMETarget == Game.GetPlayer()
				Debug.Notification ("Woah! Your breasts grow heavy with yet more milk.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+" stops and lifts one of her breasts; you see a dark spot soak through.")
			endif
		endif
	endIf
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
	if !MME
		if RandomM == 0
			If FMETarget == Game.GetPlayer()
				Debug.Notification("You store the little bit of milk you collected.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+" puts the bit of milk she collected away.")
				endif
			FMETarget.AddItem(BreastMilk,1,true)
		elseif RandomM == 1
			if FMETarget == Game.GetPlayer()
				Debug.Notification ("You managed to collect a decent amount of milk, which you store for later.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+" stores the milk she collected for her baby.")
			endif
			FMETarget.AddItem(BreastMilk,2,true)
		elseif RandomM ==2
			if FMETarget == Game.GetPlayer()
				Debug.Notification ("Wow, that was a lot of milk! You store away the bottles you filled.")
			else
				Debug.Notification (FMETarget.GetDisplayName()+" stops to organize the large amount of milk she collected.")
			endif
			FMETarget.AddItem(BreastMilk,3,true)
		endif
	endIf
	if SexLab
		SexLab.ClearMFG(Target)
	endIf
	if Lactis
		Lactis.StopNippleSquirt(FMETarget)
	endif
EndEvent

Event OnDying(Actor akKiller)

	Dispel()

EndEvent

; FMR-IE: Standalone form loader (no FM+ dependency)
form function GetMeMy4m(int formNumber, string pluginName)
	int theLO = Game.GetModByName(pluginName)
	if ((theLO == 255) || (theLO == 0))
		return none
	elseIf (theLO > 255)
		if ((Math.LogicalAnd(0xFFFFF000, formNumber) != 0) || (Math.LogicalAnd(0x00000800, formNumber) == 0))
			return none
		endIf
		theLO -= 256
		return Game.GetFormEx(Math.LogicalOr(Math.LogicalOr(0xFE000000, Math.LeftShift(theLO, 12)), formNumber))
	else
		return Game.GetFormEx(Math.LogicalOr(Math.LeftShift(theLO, 24), formNumber))
	endIf
endFunction