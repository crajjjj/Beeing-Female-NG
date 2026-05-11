Scriptname _FME_SC_2TFetal extends ActiveMagicEffect  
{Applies Effects of Fetal Motion Only. Does not apply it.}

; FMR-IE: Standalone - no FM+ dependencies

ImageSpaceModifier property FMEISMFetal1 auto
Sound Property UIHealthHeartbeatALPSD auto
spell property FME_S_PStaggerL auto

SexLabFramework						SexLab

int instanceID2

int RandomM

Actor FMETarget

GlobalVariable		Property	FMVerbose				Auto		; _JSW_BB_VerboseMode is what it's called in the esp IIRC
Actor				property	playerRef				Auto		; Game.GetPlayer() is slow by comparison.  CK should auto-fill, or put in "14" in xEdit
Spell				property	thisSpell2				Auto		; the spell that applies this ME.

event	OnEffectStart(Actor Target, Actor Caster)
; Register for Timer
	FMETarget = Target

	if (Game.GetModByName("SexLab.esm") != 255)
		SexLab = GetMeMy4m(0x000D62, "SexLab.esm") as SexLabFramework
	endIf

	CommonCode2()

    ; Message Randomization
	RandomM = Utility.RandomInt(0,2)
	if RandomM == 0
		if FMETarget == playerRef
			Debug.Notification ("Your unborn flutters within you.")
		else
			Debug.Notification (FMETarget.GetDisplayName()+" gasps as her unborn flutters in her womb.")
		endif
	elseif RandomM == 1
		if FMETarget == playerRef
			Debug.Notification ("Light kicks patter from inside your swollen stomach.")
		else
			Debug.Notification ("Light kicks patter from inside "+FMETarget.GetDisplayName()+"'s swelling stomach.")		
		endif	
	elseif RandomM == 2
		if FMETarget == playerRef
			Debug.Notification ("Your belly twitches slightly from within.")
		else
			Debug.Notification (FMETarget.GetDisplayName()+" cradles her belly as it twitches slightly from within.")	
		endif

	endif
EndEvent

Event OnUpdateGameTIme()
    CommonCode2()
endEvent

event	OnUpdate()

	Sound.StopInstance(instanceID2)	

endEvent

event	OnEffectFinish(Actor akTarget, Actor Caster)

;/	Papyrus quirks 101: it may destroy the main body of the script from memory before running an OnEffectFinish
	which is why I'm locally cacheing everything and checking if they exist, in order to prevent tons of papyrus
	log errors. /;
	actor thePlayer = playerRef
	ImageSpaceModifier thisISM = FMEISMFetal1
	int thisInt = instanceID2
	spell theSpell = thisSpell2
	if SexLab && akTarget
		SexLab.ClearMFG(akTarget)
	endIf
	if thisISM && (akTarget == thePlayer)
		thisISM.Remove()
	endIf
	if thisInt
		Sound.StopInstance(thisInt)
	endIf
	if theSpell && akTarget
		akTarget.RemoveSpell(theSpell)
	endIf

endEvent

Event OnDying(Actor akKiller)

	OnEffectFinish(FMETarget, none)

EndEvent

; ******************************************************

; Main effects below!

function CommonCode2()
    
	if FMETarget != playerRef
		instanceID2 = UIHealthHeartbeatALPSD.play(FMETarget)
		Sound.SetInstanceVolume(instanceID2, Utility.RandomFloat(0.1,0.6))
	else
        FMEISMFetal1.Apply()
		instanceID2 = UIHealthHeartbeatALPSD.play(FMETarget)
		Sound.SetInstanceVolume(instanceID2, Utility.RandomFloat(0.4,0.75))
	endif

; Stagger player & Shake
	FME_S_PStaggerL.cast(FMETarget)
	if FMETarget == playerRef
		Game.ShakeCamera(afStrength=Utility.RandomFloat(0.1,0.2),afDuration=Utility.RandomFloat(0.5,1.0))
		Game.ShakeController(Utility.RandomFloat(0.2,0.4),Utility.RandomFloat(0.2,0.4),Utility.RandomFloat(0.5,1.0))
	endif
 ; Make the player moan
    if SexLab
 	    sslBaseVoice voice = SexLab.PickVoice(FMETarget)
	    voice.Moan(FMETarget, (30 + (Utility.RandomInt(0,99) / 5) as int), false)

    ; Set Player Expression
	    SexLab.ClearMFG(FMETarget)
        int RandomM2 = (Utility.RandomInt(0,99) / 34) as int
        if RandomM2 == 0
            sslBaseExpression Flutt1 = SexLab.GetExpressionByName("Shy")
            Flutt1.ApplyTo(FMETarget, Utility.RandomInt(20,40))
        elseif RandomM2 == 1
	        sslBaseExpression Flutt2 = SexLab.GetExpressionByName("Happy")
            Flutt2.ApplyTo(FMETarget, Utility.RandomInt(10,20))
        else
            sslBaseExpression Flutt3 = SexLab.GetExpressionByName("Pained")
            Flutt3.ApplyTo(FMETarget, Utility.RandomInt(10,15))
        endif
    endif
	
	; Damage is %10 of character's current values.

    FMETarget.DamageActorValue("Stamina",(FMETarget.GetActorValue("Stamina") * 0.1))
    FMETarget.DamageActorValue("Magicka",(FMETarget.GetActorValue("Magicka") * 0.1))

    ; Mini fetal motion chunks
    Utility.Wait(5.0)

	if FMETarget == playerRef
		Game.ShakeCamera(afStrength=Utility.RandomFloat(0.1,0.2),afDuration=Utility.RandomFloat(0.5,1.0))
		Game.ShakeController(Utility.RandomFloat(0.2,0.4),Utility.RandomFloat(0.2,0.4),Utility.RandomFloat(0.5,1.0))
	endif

	Utility.Wait(Utility.RandomFloat(1.0,3.0))

	if FMETarget == playerRef
		Game.ShakeCamera(afStrength=Utility.RandomFloat(0.1,0.2),afDuration=Utility.RandomFloat(0.5,1.0))
		Game.ShakeController(Utility.RandomFloat(0.2,0.4),Utility.RandomFloat(0.2,0.4),Utility.RandomFloat(0.5,1.0))
	endIf

    RegisterForSingleUpdate(3.0)
    RegisterForSingleUpdateGameTime(Utility.RandomFloat(0.2,0.25)) ; Every 12-15 in-game minutes

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