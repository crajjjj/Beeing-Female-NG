Scriptname _FME_SC_3TBH extends ActiveMagicEffect

; FMR-IE: Standalone - no FM+ dependencies

SexLabFramework SexLab

faction	property GenericFaction auto
ImageSpaceModifier property FMEISMBraxHickL auto
ImageSpaceModifier property FMEISMBraxHickM auto
ImageSpaceModifier property FMEISMBraxHickH auto

;spell property _BFA_SP_Stagger auto
spell property FME_S_PStaggerL auto
spell property FME_S_PStaggerM auto
spell property FME_S_PStaggerH auto
spell property FME_S_Birth auto

Sound Property WPNBowPullLPMSD auto
int instanceID4
int RandBirthProbAfter3t
int RandomM4
int BirthRandInt
int RCTB
float RandBirthProbAfter3tF
float Exponent
float NaturalE
float VarianceCalc
float PDF
int PDFR
int WillBirth
Actor FMETarget

Event OnEffectStart (Actor Target, Actor Caster)
	; Register for Timer
	FMETarget = Target
	; Is Sexlab Present
	WillBirth = 0
	if (Game.GetModByName("SexLab.esm") != 255)
		SexLab = GetMeMy4m(0x000D62, "SexLab.esm") as SexLabFramework
	endIf
	; Fire repeating effects
	ContractionHit()
	; If Target Not in Combat/Riding/Moving, apply Bleedout. 
	int EnableStagger = JsonUtil.GetIntValue("/FMEffects/ConfigContraction.json", "enablestagger", 0)
	;Debug.Notification ("IsStaggerEnabled = "+EnableStagger)
	if (FMETarget.IsInCombat() == false) || (FMETarget.IsOnMount() == false) || (FMETarget.IsRunning() == true) || (FMETarget.IsSprinting() == true) && (EnableStagger==1)
		
		if(FMETarget.IsWeaponDrawn())
			FMETarget.SheatheWeapon()
		endIf
		
		Debug.SendAnimationEvent(FMETarget, "IdleForceDefaultState")

		Debug.SendAnimationEvent(FMETarget, "BleedOutStart")
		Utility.Wait(3.5)
		Debug.SendAnimationEvent(FMETarget, "BleedOutStop")

	endif
; Message Randomization
	
EndEvent

Event OnUpdateGameTIme()
    ContractionHit()
endEvent

event	OnUpdate()
	Sound.StopInstance(instanceID4)
	if Sexlab
		SexLab.ClearMFG(FMETarget)
	endif
	; FMR Compatibility: Birth triggering disabled - FMR handles its own birth logic
	; Contraction effects (sound, stagger, expressions, messages) still play via ContractionHit()
endEvent

Event OnEffectFinish(Actor Target, Actor Caster)

	FMEISMBraxHickL.Remove()
	FMEISMBraxHickM.Remove()
	FMEISMBraxHickH.Remove()
	Sound.StopInstance(instanceID4)
	if Sexlab
		SexLab.ClearMFG(Target)
	endif
	; FMR Compatibility: Birth triggering removed - FMR handles birth via its own system

EndEvent

Event OnDying(Actor akKiller)

	Dispel()

EndEvent

; ******************************************************

; Main effects below!

function ContractionHit()

	; Image Space Modifier Chooser

	if FMETarget != Game.GetPlayer()
		instanceID4 = WPNBowPullLPMSD.play(FMETarget)
		Sound.SetInstanceVolume(instanceID4, Utility.RandomFloat(0.5,0.75))
		RandomM4 = Utility.RandomInt(0,2)
		if RandomM4 == 0
			FME_S_PStaggerL.Cast(FMETarget)
		elseif RandomM4 == 1
			FME_S_PStaggerM.Cast(FMETarget)
		elseif RandomM4 == 2
			FME_S_PStaggerH.Cast(FMETarget)
		endif
	else
		instanceID4 = WPNBowPullLPMSD.play(FMETarget)
		Sound.SetInstanceVolume(instanceID4, 1.0)
		Game.ShakeCamera(afStrength=Utility.RandomFloat(0.4,0.6),afDuration=Utility.RandomFloat(1.5,2.0))
		Game.ShakeController(Utility.RandomFloat(0.4,1.0),Utility.RandomFloat(0.4,1.0),Utility.RandomFloat(1.5,2.0))
        RandomM4 = Utility.RandomInt(0,2)		
		if RandomM4 == 0
			FMEISMBraxHickL.Apply(1.0)
			FME_S_PStaggerL.Cast(FMETarget)
		elseif RandomM4 == 1
			FMEISMBraxHickM.Apply(1.0)
			FME_S_PStaggerM.Cast(FMETarget)
		elseif RandomM4 == 2
			FMEISMBraxHickH.Apply(1.0)
			FME_S_PStaggerH.Cast(FMETarget)
		endif
	endif
	
	 ; Make the player moan
    if Sexlab
 	    sslBaseVoice Owie = SexLab.PickVoice(FMETarget)
	    Owie.Moan(FMETarget, Utility.RandomInt(80,100), false)

		; Set Player Expression
	    SexLab.ClearMFG(FMETarget)
	    
	    if RandomM4 == 0
	        sslBaseExpression Owie1 = SexLab.GetExpressionByName("Afraid")
		    Owie1.ApplyTo(FMETarget, Utility.RandomInt(50,80))
	    elseif RandomM4 == 1
            sslBaseExpression Owie2 = SexLab.GetExpressionByName("Angry")
	    	Owie2.ApplyTo(FMETarget, Utility.RandomInt(30,50))
    	elseif RandomM4 == 2
            sslBaseExpression Owie3 = SexLab.GetExpressionByName("Pained")
		    Owie3.ApplyTo(FMETarget, Utility.RandomInt(40,60))
	    endif
    endIf
	; Do Mana/Stamina Damage to Actor
    FMETarget.DamageActorValue("Stamina",(FMETarget.GetActorValue("Stamina") * 0.25))
    FMETarget.DamageActorValue("Magicka",(FMETarget.GetActorValue("Magicka") * 0.25))
	; Play Messages
	if RandomM4 == 0
		if FMETarget == Game.GetPlayer()
			Debug.Notification ("Your belly tightens painfully as a contraction rips through your midsection!")
		else 
			Debug.Notification (FMETarget.GetDisplayName()+" gasps in pain as a contraction rips through her midsection!")
		endif
	elseif RandomM4 == 1
		if FMETarget == Game.GetPlayer()
			Debug.Notification ("You stumble as your lower body cramps painfully!")
		else
			Debug.Notification (FMETarget.GetDisplayName()+" cries out and stumbles as her lower body cramps painfully!")
		endif
	elseif RandomM4 == 2
		if FMETarget == Game.GetPlayer()	
			Debug.Notification ("A paralyzing pain envelops your swollen pregnant body!")
		else
			Debug.Notification ("A paralyzing pain envelops "+FMETarget.GetDisplayName()+"'s swollen pregnant body!")
		endif
	endif
	
    RegisterForSingleUpdate(3.0)
    RegisterForSingleUpdateGameTime(Utility.RandomFloat(0.16,0.2)) ; Every 10-12 in-game minutes
endfunction

int function Round(float afValue)
    Int CLNG=Math.Ceiling(afValue)
    Int FLR=Math.Floor(afValue)
    Float DistUp=CLNG-afValue
    Float DistDown=afValue-FLR
    if DistUp<DistDown
        Return CLNG
        ;Debug.Notification ("RoundUp")
    else
        Return FLR
        ;Debug.Notification ("RoundDown")
    endif
endFunction

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