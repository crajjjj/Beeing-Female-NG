Scriptname _FME_SC_3TFetal extends ActiveMagicEffect  
{Applies Effects of Fetal Motion Only. Does not apply it.}

; FMR-IE: Standalone - no FM+ dependencies

ImageSpaceModifier property FMEISMFetal2 auto
Sound Property UIHealthHeartbeatALPSD auto
spell property FME_S_PStaggerM auto

SexLabFramework						SexLab

int instanceID3

int RandomM

Actor FMETarget

GlobalVariable		Property	FMVerbose				Auto		; _JSW_BB_VerboseMode is what it's called in the esp IIRC
Actor				property	playerRef				Auto		; Game.GetPlayer() is slow by comparison.  CK should auto-fill, or put in "14" in xEdit
Spell				property	thisSpell3				Auto		; the spell that applies this ME.

Event OnEffectStart (Actor Target, Actor Caster)
; Register for Timer
	FMETarget = Target

	if (Game.GetModByName("SexLab.esm") != 255)
		SexLab = GetMeMy4m(0x000D62, "SexLab.esm") as SexLabFramework
	endIf

	CommonCode3()
	; Every 6-20 in-game minutes

; Message Randomization
	RandomM = Utility.RandomInt(0,2)
	if RandomM == 0
		if FMETarget == Game.GetPlayer()
			Debug.Notification ("Your unborn quivers strongly within you.")
		else
			Debug.Notification (FMETarget.GetDisplayName()+"'s unborn quivers strongly within her.")
		endif
	elseif RandomM == 1
		if FMETarget == Game.GetPlayer()
			Debug.Notification ("Strong kicks hammer from inside your gravid womb.")
		else
			Debug.Notification (FMETarget.GetDisplayName()+" grunts as strong kicks hammer from inside her gravid womb.")
		endif
	elseif RandomM == 2
		if FMETarget == Game.GetPlayer()
			Debug.Notification ("Your belly rolls and bulges from the motion within.")
		else
			Debug.Notification (FMETarget.GetDisplayName()+"'s belly bulges visibly from the motion within.")
		endif
	endif
EndEvent

Event OnUpdateGameTIme()
    CommonCode3()
endEvent

event	OnUpdate()
	Sound.StopInstance(instanceID3)	
endEvent

event	OnEffectFinish(Actor akTarget, Actor Caster)
;/	Papyrus quirks 101: it may destroy the main body of the script from memory before running an OnEffectFinish
	which is why I'm locally cacheing everything and checking if they exist, in order to prevent tons of papyrus
	log errors. /;
	actor thePlayer = playerRef
	ImageSpaceModifier thisISM = FMEISMFetal2
	int thisInt = instanceID3
	spell theSpell = thisSpell3
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

	Dispel()

EndEvent

; ******************************************************

; Main effects below!

function CommonCode3()
	

	if FMETarget != Game.GetPlayer()
		instanceID3= UIHealthHeartbeatALPSD.play(FMETarget)
		Sound.SetInstanceVolume(instanceID3, Utility.RandomFloat(0.33,0.75))
	else
        FMEISMFetal2.Apply(Utility.RandomFloat(0.6,1.0))
		instanceID3= UIHealthHeartbeatALPSD.play(FMETarget)
		Sound.SetInstanceVolume(instanceID3, Utility.RandomFloat(0.75,1.0))
	endif

; Stagger player & Shaking
	FME_S_PStaggerM.cast(FMETarget)
	if FMETarget == Game.GetPlayer()
		Game.ShakeCamera(afStrength=Utility.RandomFloat(0.3,0.4),afDuration=Utility.RandomFloat(1.0,1.5))
		Game.ShakeController(Utility.RandomFloat(0.3,0.7),Utility.RandomFloat(0.3,0.7),Utility.RandomFloat(1.0,1.5))
	endif
 ; Make the player moan
    if Sexlab
 	    sslBaseVoice voice = SexLab.PickVoice(FMETarget)
	    voice.Moan(FMETarget, Utility.RandomInt(50,70), false)

; Set Player Expression
	    SexLab.ClearMFG(FMETarget)
        int RandomM3 = (Utility.RandomInt(0,99) / 34) as int
        if RandomM3 == 0
            sslBaseExpression Kick1 = SexLab.GetExpressionByName("Shy")
            Kick1.ApplyTo(FMETarget, Utility.RandomInt(30,70))
        elseIf RandomM3 == 1
            sslBaseExpression Kick2 = SexLab.GetExpressionByName("Happy")
            Kick2.ApplyTo(FMETarget, Utility.RandomInt(20,50))
        else
            sslBaseExpression Kick3 = SexLab.GetExpressionByName("Pained")
            Kick3.ApplyTo(FMETarget, Utility.RandomInt(30,60))
        endIf
    endIf
; Do Mana/Stamina Damage to Actor
    FMETarget.DamageActorValue("Stamina",(FMETarget.GetActorValue("Stamina") * 0.15))
    FMETarget.DamageActorValue("Magicka",(FMETarget.GetActorValue("Magicka") * 0.15))

; Mini fetal motion chunks
	Utility.Wait(6.0)
	if FMETarget == Game.GetPlayer()
		Game.ShakeCamera(afStrength=Utility.RandomFloat(0.3,0.4),afDuration=Utility.RandomFloat(1.0,1.5))
		Game.ShakeController(Utility.RandomFloat(0.4,0.7),Utility.RandomFloat(0.4,0.7),Utility.RandomFloat(1.0,1.5))
	endif

    if Sexlab
        sslBaseVoice voice = SexLab.PickVoice(FMETarget)
	    voice.Moan(FMETarget, Utility.RandomInt(30,50), false)
    endIf

	Utility.Wait(Utility.RandomFloat(1.5,4.0))

	if FMETarget == Game.GetPlayer()
		Game.ShakeCamera(afStrength=Utility.RandomFloat(0.3,0.4),afDuration=Utility.RandomFloat(1.0,1.5))
		Game.ShakeController(Utility.RandomFloat(0.4,0.7),Utility.RandomFloat(0.4,0.7),Utility.RandomFloat(1.0,1.5))
	endif

    if Sexlab
        sslBaseVoice voice = SexLab.PickVoice(FMETarget)
	    voice.Moan(FMETarget, Utility.RandomInt(50,70), false)
    endIf

	Utility.Wait(Utility.RandomFloat(1.5,4.0))

	if FMETarget == Game.GetPlayer()
		Game.ShakeCamera(afStrength=Utility.RandomFloat(0.3,0.4),afDuration=Utility.RandomFloat(1.0,1.5))
		Game.ShakeController(Utility.RandomFloat(0.4,0.7),Utility.RandomFloat(0.4,0.7),Utility.RandomFloat(1.0,1.5))
	endif
    if Sexlab
        sslBaseVoice voice = SexLab.PickVoice(FMETarget)
 	    voice.Moan(FMETarget, Utility.RandomInt(25,40), false)
    endIf

    RegisterForSingleUpdate(2.0)
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