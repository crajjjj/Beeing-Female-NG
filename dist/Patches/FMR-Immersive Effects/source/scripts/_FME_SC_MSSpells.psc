Scriptname	_FME_SC_MSSpells	extends	ActiveMagicEffect	; change this and the filename at some point in the future
{Morning Sickness Spells Script}

;/	there's no reason for this line.   Importing Utility would allow you to not prefix all the Utility
	calls- Utility.Wait() and Utility.RandomInt() could be just Wait() and RandomInt() instead.
	It's IMO pointless to import utility, but then still keep the prefixes.   My personal preference is to
	not import anything.  You can re-import if you want then delete the "Utility." from everything if you prefer. /;
;import Utility

; FMR-IE: Standalone - no FM+ dependencies

; I've separated SexLab out, because we're gonna make it optional.
; it's no longer a property, so you need to clear where it was set in the ESP or you'll get papyrus warnings 
SexLabFramework						SexLab

ImageSpaceModifier	property	FMEISMMorningSickness	auto
Sound				Property	UISkillsGlowSD			auto
spell				property	FME_S_PStaggerL			auto
spell				property	FME_S_Vomit2			auto
; RandomM doesn't need to be a script variable, it's only ever used as a function (or, event) variable.
;int RandomM
int			instanceID
Actor		FMETarget
; new vars

; need to add the below properties in the CK or xEdit
GlobalVariable		Property	FMVerbose				Auto		; _JSW_BB_VerboseMode is what it's called in the esp IIRC
Actor				property	playerRef				Auto		; Game.GetPlayer() is slow by comparison.  CK should auto-fill, or put in "14" in xEdit
Spell				property	thisSpell				Auto		; the spell that applies this ME.

;/	this was called OnWoman.   Don't know what that event is, and what if anything would ever call that event.  I think this may have been 
	your problem with it not applying, nothing had told it to ever start executing this script!  Outside of some few cases,
	every ME starts with the OnEffectStart() block /;
event	OnEffectStart(Actor Target, Actor Caster)

	FMETarget = Target

	;/	now to conditionally grab the SL info we need
		GetMeMyForm is my replacement for GetFormFromFile that a) doesn't require the mod to be present to compile,
		and b) doesn't print papyrus errors if the mod isn't present
		I said before in a message that making it optional was the "advanced course" and I have mixed feelings about
		doing this for you: on one hand it's the "give a man a fish vs. teach him to fish" but OTOH I know trying
		to learn everything at once is overwhelming and discouraging... 
		So here it is, I've given you a fish.   For your own enlightenment, you should review what I did, what the
		custom function does, and feel free to ask questions where you need clarifications.  /;
	if (Game.GetModByName("SexLab.esm") != 255)
		SexLab = GetMeMy4m(0x000D62, "SexLab.esm") as SexLabFramework
	endIf
	
	; CommonCode contains eveything that was common between here and OnUpdateGameTime()
	CommonCode()

	; Message Randomization
	if Utility.RandomInt(0,1) == 0 ;(SchedUpdatr.FetchRandom < 50)
		if FMETarget == playerRef
			Debug.Notification ("You stumble as a sudden wave of nausea overcomes you.")
		elseIf FMVerbose && FMVerbose.GetValue()	; None-safe: BF NG patch may leave the property unfilled
			Debug.Notification (FMETarget.GetDisplayName() + " stumbles as a wave of nausea overcomes her.")
		endif
	else
		if FMETarget == playerRef
			Debug.Notification ("You feel oddly faint for a moment as your vision swims.")
		elseIf FMVerbose && FMVerbose.GetValue()
			Debug.Notification (FMETarget.GetDisplayName() + " feels faint as her vision swims.")
		endif
	endif

endEvent

event	OnUpdateGameTime()

;	Debug.Notification ("MornSick function entered")

	CommonCode()
	; Need to script in stagger spell!	Target.cast(Stagger)

endEvent

event	OnUpdate()

	Sound.StopInstance(instanceID)	

endEvent

event	OnEffectFinish(Actor akTarget, Actor Caster)

;/	Papyrus quirks 101: it may destroy the main body of the script from memory before running an OnEffectFinish
	which is why I'm locally cacheing everything and checking if they exist, in order to prevent tons of papyrus
	log errors. /;
	actor thePlayer = playerRef
	ImageSpaceModifier thisISM = FMEISMMorningSickness
	int thisInt = instanceID
	spell theSpell = thisSpell
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

event	OnDying(Actor akKiller)

	OnEffectFinish(FMETarget, none)

EndEvent

function	CommonCode()
{there's a lot of common code between OnEffectStart() and OnUpdateGameTime() that is moved into here}

	if FMETarget != playerRef
		instanceID = UISkillsGlowSD.play(FMETarget)
		Sound.SetInstanceVolume(instanceID, Utility.RandomFloat(0.5,1.0))
	else
		FMEISMMorningSickness.Apply()
		instanceID = UISkillsGlowSD.play(FMETarget)
		; FM+ has a GlobalVariable for SoundVolume that the player can set in the MCM - do you want to use it on the below line?
		Sound.SetInstanceVolume(instanceID, 1.0)
	endif
	; Stagger character
	int EnableStagger = JsonUtil.GetIntValue("/FMEffects/ConfigContraction.json", "enablestagger", 0)
	if  (EnableStagger==1)
		FME_S_PStaggerL.cast(FMETarget)
		int Rand4=Utility.RandomInt(0,99)
		if (Rand4>=34 && Rand4<=45)
			FME_S_Vomit2.cast(FMETarget,none)
		endif 
	endif
	;/	all the SL-dependent code is here, in this block below.  Granted, the ME is pretty barren without it, 
		but SL is no longer a hard dependency. /;
	if SexLab
		; Make the player moan
		sslBaseVoice voice = SexLab.PickVoice(FMETarget)
		voice.Moan(FMETarget, (30 + (Utility.RandomInt(0,99) / 5) as int), false)
		; Set Random Player Expression
		SexLab.ClearMFG(FMETarget)

;/	Moved the three SL expression lookups.   Instead of calling all three, then only using one of those three,
	now it only calls whichever one it's actually going to use /;
		; Set Random Variable
		int RandomM = (Utility.RandomInt(0,99) / 34) as int
		if RandomM == 0
			sslBaseExpression Queezy1 = SexLab.GetExpressionByName("Pained")
			Queezy1.ApplyTo(FMETarget, Utility.RandomInt(10, 25))
			; theoretically you can simplify these even further, as such:
			;SexLab.GetExpressionByName("Pained").ApplyTo(FMETarget, Utility.RandomInt(10, 25))
		elseif RandomM == 1
			sslBaseExpression Queezy2 = SexLab.GetExpressionByName("Angry")
			Queezy2.ApplyTo(FMETarget, (10 + (Utility.RandomInt(0,99) / 17) as int))
		else
			sslBaseExpression Queezy3 = SexLab.GetExpressionByName("Afraid")
			Queezy3.ApplyTo(FMETarget, (10 + (Utility.RandomInt(0,99) / 9) as int))
		endif
	endIf
	
	; Damage is %15 of character's current values.
	FMETarget.DamageActorValue("Stamina",(FMETarget.GetActorValue("Stamina") * 0.15))
	FMETarget.DamageActorValue("Magicka",(FMETarget.GetActorValue("Magicka") * 0.15))

;	Utility.Wait(3.0)
;	Sound.StopInstance(instanceID)	
;	replace the above two with a RegisterForSingleUpdate() because I hate Wait()
	RegisterForSingleUpdate(3.0)
	RegisterForSingleUpdateGameTime(Utility.RandomFloat(0.2,0.25)) ; Every 12-15 in-game minutes

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