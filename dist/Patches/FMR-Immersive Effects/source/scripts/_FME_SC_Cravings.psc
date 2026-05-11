Scriptname _FME_SC_Cravings extends ActiveMagicEffect

import Utility

; FMR-IE: Standalone - no FM+ dependencies

FormList Property Food_Salty Auto
FormList Property Food_Sweet Auto
FormList Property Food_Carb Auto

SexLabFramework						SexLab

Sound Property UIHealthHeartbeatALPSD auto
int instanceID
int RandomM
int RandomN
int ticker
int n
int s
Actor FMETarget
form FoodName

Event  OnEffectStart (Actor Target, Actor Caster)
	
    ; Register for Timer
	if (Game.GetModByName("SexLab.esm") != 255)
		SexLab = GetMeMy4m(0x000D62, "SexLab.esm") as SexLabFramework
	endIf
	FMETarget = Target
    ; Message Randomization
	RandomM = RandomInt(0,2)
	if RandomM == 0
		if FMETarget == Game.GetPlayer()
			Debug.Notification ("You have a sudden craving for something salty...")
		else
			Debug.Notification (FMETarget.GetDisplayName()+" gasps as a loud groan emanates from her belly.")
		endif
	elseif RandomM == 1
		if FMETarget == Game.GetPlayer()
			Debug.Notification ("A sudden craving for something sweet comes over you.")
		else
			Debug.Notification ("You notice a low grumbling coming from "+FMETarget.GetDisplayName()+"'s belly.")		
		endif	
	elseif RandomM == 2
		if FMETarget == Game.GetPlayer()
			Debug.Notification ("Your belly grumbles loudly as you have a sudden craving for something filling.")
		else
			Debug.Notification (FMETarget.GetDisplayName()+" licks her lips as she starts thinking about food.")	
		endif
	endif
	RandomN = RandomInt(2,4)
	ticker = 0
    CravingDecider(ticker, RandomM, RandomN)
EndEvent

Event OnUpdateGameTIme()
    CravingDecider(ticker, RandomM, RandomN)
endEvent

;Event OnObjectEquipped(Form type, ObjectReference ref)

;EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)

	Sound.StopInstance(instanceID)
	SexLab.ClearMFG(Target)

EndEvent

Event OnDeath(Actor akKiller)

	Dispel()

EndEvent

; ******************************************************

; Main effects below!

function CravingDecider(int tick, int RandM, int RandN)
    if FMETarget == Game.GetPlayer()
        if tick >= RandN
            CravingGrumbleEat(RandM)
            ticker = 0
        else
            CravingGrumble(RandM)
            ticker = tick + 1
        endIf
        RegisterForSingleUpdateGameTime (RandomFloat(0.08,0.12)) ; Every 5-10 in-game minutes
    else
        CravingGrumble(RandomM)
        RegisterForSingleUpdateGameTime (RandomFloat(0.1,0.2)) ; Every 6-12 in-game minutes
    endif
endFunction

function CravingGrumble(int RandM)

	if FMETarget != Game.GetPlayer()
		instanceID = UIHealthHeartbeatALPSD.play(FMETarget)
		Sound.SetInstanceVolume(instanceID, RandomFloat(0.1,0.3))		
	else
		instanceID = UIHealthHeartbeatALPSD.play(FMETarget)
		Sound.SetInstanceVolume(instanceID, RandomFloat(0.4,0.75))
	endif
    if Sexlab
    ; Make the player moan
 	    sslBaseVoice voice = SexLab.PickVoice(FMETarget)
	    voice.Moan(FMETarget, RandomInt(20,30), false)
    
    ; Set Player Expression
	    SexLab.ClearMFG(FMETarget)
	    sslBaseExpression Crav1 = SexLab.GetExpressionByName("Shy")
	    sslBaseExpression Crav2 = SexLab.GetExpressionByName("Sad")
	    sslBaseExpression Crav3 = SexLab.GetExpressionByName("Afraid")

	    if RandM == 0
	    	Crav1.ApplyTo(FMETarget, RandomInt(20,40))
	    elseif RandM == 1
	    	Crav2.ApplyTo(FMETarget, RandomInt(10,20))
	    elseif RandM == 2
		Crav3.ApplyTo(FMETarget, RandomInt(10,15))
	    endif
    endIf
	Wait(RandomFloat(1.0,3.0))

	Sound.StopInstance(instanceID)

endfunction

function CravingGrumbleEat(int RandM)

	if FMETarget != Game.GetPlayer()
		instanceID = UIHealthHeartbeatALPSD.play(FMETarget)
		Sound.SetInstanceVolume(instanceID, RandomFloat(0.1,0.3))		
	else
		instanceID = UIHealthHeartbeatALPSD.play(FMETarget)
		Sound.SetInstanceVolume(instanceID, RandomFloat(0.4,0.75))
	endif
    if Sexlab
    ; Make the player moan
 	    sslBaseVoice voice = SexLab.PickVoice(FMETarget)
	    voice.Moan(FMETarget, RandomInt(20,30), false)

    ; Set Player Expression
    	SexLab.ClearMFG(FMETarget)
    	sslBaseExpression Crav1 = SexLab.GetExpressionByName("Shy")
    	sslBaseExpression Crav2 = SexLab.GetExpressionByName("Sad")
    	sslBaseExpression Crav3 = SexLab.GetExpressionByName("Afraid")

    	if RandM == 0
    		Crav1.ApplyTo(FMETarget, RandomInt(20,40))
    	elseif RandM == 1
    		Crav2.ApplyTo(FMETarget, RandomInt(10,20))
    	elseif RandM == 2
    		Crav3.ApplyTo(FMETarget, RandomInt(10,15))
	    endif
    endIf
; Equip item from correct formlist (salty, sweet, or carbs)
    if RandM == 0
        s = Food_Salty.GetSize() - 1
        n = RandomInt(0,s)
		wait(0.01)
		FoodName = Food_Salty.GetAt(n)
        FMETarget.AddItem(FoodName)
		string Zname = FoodName.GetName()
        Debug.Notification("Ugh! Tired of your stomach grumbling, you eat a "+Zname+".")
        wait(0.01)
        FMETarget.EquipItem(FoodName)
    elseif RandM == 1
        s = Food_Sweet.GetSize() - 1
        n = RandomInt(0,s)
		wait(0.01)
		FoodName = Food_Sweet.GetAt(n)
        FMETarget.AddItem(FoodName)
		string Zname = FoodName.GetName()
        Debug.Notification("You quickly pull a "+Zname+"out of your bag and eat it.")
        wait(0.04)
        FMETarget.EquipItem(FoodName)
    elseif RandM == 2
        s = Food_Salty.GetSize() - 1
        n = RandomInt(0,s)
		wait(0.01)
		FoodName = Food_Carb.GetAt(n)
        FMETarget.AddItem(FoodName)
		string Zname = FoodName.GetName()
        Debug.Notification("You're so hungry! You wolf down a "+Zname+" to satisfy your craving.")
        wait(0.04)
        FMETarget.EquipItem(FoodName)
    endIf
	Wait(RandomFloat(1.0,3.0))
	Sound.StopInstance(instanceID)
endfunction

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
