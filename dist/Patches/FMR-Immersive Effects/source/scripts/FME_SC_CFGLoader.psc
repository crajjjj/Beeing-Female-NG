Scriptname FME_SC_CFGLoader extends ActiveMagicEffect  

actor			FMETarget

Spell           Property        CFGSpell     Auto

GlobalVariable Property COMMH_NSFW Auto
GlobalVariable Property COMMH_SFW Auto
GlobalVariable Property COMMI_NSFW Auto
GlobalVariable Property COMMI_SFW Auto

Event OnEffectStart(Actor akActor, Actor Caster)
    ; Stretchmark is working, Areola isn't
    ; FIND OUT 16 RED 8 BLUE
    FMETarget = akActor
    Debug.Trace("Starting Dialogue Quest Vars")
    float ProbHS = JsonUtil.GetFloatValue("/FMEffects/ConfigDialogue.json", "probhsfw", 50.0)
    Debug.Notification ("Prob SFW Hellos = "+ProbHS)
    COMMH_SFW.SetValue(Round(ProbHS))
    float ProbHN = JsonUtil.GetFloatValue("/FMEffects/ConfigDialogue.json", "probhnsfw", 50.0)
    Debug.Notification ("Prob NSFW Hellos = "+ProbHN)
    COMMH_NSFW.SetValue(Round(ProbHN))
    float ProbIS = JsonUtil.GetFloatValue("/FMEffects/ConfigDialogue.json", "probisfw", 50.0)
    Debug.Notification ("Prob SFW Idles = "+ProbIS)
    COMMI_SFW.SetValue(Round(ProbIS))
    float ProbIN = JsonUtil.GetFloatValue("/FMEffects/ConfigDialogue.json", "probinsfw", 50.0)
    Debug.Notification ("Prob NSFW Idles = "+ProbIN)
    COMMI_NSFW.SetValue(Round(ProbIN))
    Debug.Notification ("Dialogue Settings Updated")
    Debug.Trace("FMIE - Setup Complete")
    FMETarget.RemoveSpell(CFGSpell)
endEvent

Event OnDying(Actor akKiller)
    FMETarget.RemoveSpell(CFGSpell)
EndEvent

Event OnEffectFinish(Actor akActor, Actor Caster)
    akActor=FMETarget
    FMETarget.RemoveSpell(CFGSpell)
endEvent

Event OnUnload()
    FMETarget.RemoveSpell(CFGSpell)
endEvent

Event OnCellDetach()
    FMETarget.RemoveSpell(CFGSpell)
endEvent

int function Round(float afValue)
    Int CLNG=Math.Ceiling(afValue)
    Int FLR=Math.Floor(afValue)
    Float DistUp=CLNG-afValue
    Float DistDown=afValue-FLR
    if DistUp<DistDown
        Return CLNG
        Debug.Notification ("RoundUp")
    else
        Return FLR
        Debug.Notification ("RoundDown")
    endif
endFunction