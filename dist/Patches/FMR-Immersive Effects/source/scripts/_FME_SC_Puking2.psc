Scriptname _FME_SC_Puking2 extends activemagiceffect  

SPELL Property _FME_S_Vomit  Auto  

Float Property duration = 1.25 Auto  

Bool Property Breakout = False Auto Hidden 

Int Property minStamina = 0 Auto  

Float Property endTime  Auto  

Float Property recastTime = 0.2 Auto  

Event OnEffectStart(Actor akTarget, Actor akCaster)
    if akTarget.getAv("Stamina")>=minStamina
        breakout = False
        endTime=utility.getCurrentRealTime()+duration
        while !breakout && utility.GetCurrentRealTime() < endTime
            _FME_S_Vomit.cast(akTarget)
            utility.wait(recastTime)
        endWhile
    endIf 
endEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
    breakout = True
endEvent