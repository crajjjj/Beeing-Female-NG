Scriptname _FME_SC_RandEffChooser extends ActiveMagicEffect  
{Script for choosing what random effect is applied
depends on current actor state (factionRank)}

actor			FMETarget

faction			Property		GenericFaction	Auto			; not used by me, probably needed by w234aew

Spell			Property		_FME_S_1T_MornSick		Auto	; Effect spells
Spell           Property		_FME_S_Craving  		Auto
Spell           Property		_FME_S_2T_Fetal 		Auto
;Spell           Property		_FME_S_MotionPain 		Auto
Spell           Property		_FME_S_3T_Fetal 		Auto
Spell           Property		_FME_S_3T_Braxton 		Auto
Spell           Property        _FME_S_3T_Colostrum     Auto
Spell           Property		_FME_S_3T_Lactation 	Auto
Spell           Property        RandEffChooserSpell     Auto

;	script variables
int     ChooseInt
int		RandInt
int     RoughCurrentTime

; Event lock codes
int _eventNone = 0
;int _eventLabor = 1
int _eventSpawn = 2

Event OnEffectStart(Actor akActor, Actor Caster)
    FMETarget = akActor
    ; BF NG patch: progress comes from the bridge via StorageUtil.
    ; BF's ParentFaction (the only BF-side tracker) carries state IDs, not
    ; the 0..115 band this script's trimester switches expect.
    RoughCurrentTime = StorageUtil.GetIntValue(FMETarget, "FME.Rank", 0)
    int Ticker = JsonUtil.GetIntValue("/FMEffects/Config.json", "ticker", 10)
    ;Debug.Notification("Random Effect  is 2 in "+Ticker)
    if (RoughCurrentTime > 1 && RoughCurrentTime < 34)
        ; First Trimester Effects; first, decide on whether to apply effect or not
        RandInt = Utility.RandomInt(1,Ticker) as int
        if (RandInt < 3)
            ; Then, Apply Spell, by fetching random int 1-# available effects in trimester. For 1T there's only 1, morning sickness
            ChooseInt = Utility.RandomInt(0,2) as int
            if (ChooseInt == 0)
                _FME_S_1T_MornSick.Cast(FMETarget,FMETarget) ; should be cast, I think
            elseif (ChooseInt == 1)
                _FME_S_1T_MornSick.Cast(FMETarget,FMETarget) ; should be cast, I think
            elseif (ChooseInt == 2)
                ; Not Sure craving script will work yet, wasn't completely implemented in BFAP
                _FME_S_Craving.Cast(FMETarget,FMETarget)
            endIf    
        endIf
    elseIf (RoughCurrentTime >= 34  && RoughCurrentTime < 67)
        ; Second Trimester Effects; first, decide on whether to apply effect or not
        RandInt = Utility.RandomInt(1,Ticker) as int
        if (RandInt < 3)
            ; Then, Apply Spell, by fetching random int 1-# available effects in trimester. For 2T there's only 2 RN, morning sickness & Fetal Flutter
            ChooseInt = Utility.RandomInt(0,1) as int
            if (ChooseInt == 0)
                _FME_S_2T_Fetal.Cast(FMETarget,FMETarget); should be cast, I think
            elseif (ChooseInt == 1)
                _FME_S_Craving.Cast(FMETarget,FMETarget)
                ; Craving script works, wasn't completely implemented in BFAP
            endIf
        EndIf
    elseIf (RoughCurrentTime >= 67  && RoughCurrentTime <= 100)
        ; Third trimester, play more frequent kicks (15%)
        RandInt = Utility.RandomInt(1,Ticker) as int
        if (RandInt < 3)
            ; Then, Apply Spell, by fetching random int 1-# available effects in trimester. For 3T there's 3, fetal kick, braxton-hicks, and lactation
            ChooseInt = Utility.RandomInt(0,3) as int
            if (ChooseInt == 0)
                _FME_S_3T_Fetal.Cast(FMETarget,FMETarget) ; should be cast, I think
            elseif (ChooseInt == 1)
                _FME_S_3T_Colostrum.Cast(FMETarget,FMETarget) ; should be cast, I think
            elseIf (ChooseInt == 2)
                _FME_S_3T_Braxton.Cast(FMETarget,FMETarget) ; should be cast, I think
            elseif (ChooseInt == 3)
                _FME_S_Craving.Cast(FMETarget,FMETarget)
            endIf
        endIf
    elseIf (RoughCurrentTime >= 101 && RoughCurrentTime <= 104)
        ; Early recovery - lactation, colostrum, cravings
        RandInt = Utility.RandomInt(1,Ticker) as int
        if (RandInt < 3)
            ChooseInt = Utility.RandomInt(0,2) as int
            if (ChooseInt == 0)
                _FME_S_3T_Lactation.Cast(FMETarget,FMETarget)
            elseIf (ChooseInt == 1)
                _FME_S_3T_Colostrum.Cast(FMETarget,FMETarget)
            elseif (ChooseInt == 2)
                _FME_S_Craving.Cast(FMETarget,FMETarget)
            endIf
        endIf
    elseIf (RoughCurrentTime >= 105 && RoughCurrentTime <= 115)
        ; Late recovery - mostly lactation
        RandInt = Utility.RandomInt(1,Ticker) as int
        if (RandInt < 3)
            ChooseInt = Utility.RandomInt(0,2) as int
            if (ChooseInt == 0)
                _FME_S_3T_Lactation.Cast(FMETarget,FMETarget)
            elseIf (ChooseInt == 1)
                _FME_S_3T_Lactation.Cast(FMETarget,FMETarget)
            elseif (ChooseInt == 2)
                _FME_S_Craving.Cast(FMETarget,FMETarget)
            endIf
        endIf
    endIf
    FMETarget.RemoveSpell(RandEffChooserSpell)
endEvent

Event OnDying(Actor akKiller)
    FMETarget.RemoveSpell(RandEffChooserSpell)
EndEvent

Event OnEffectFinish(Actor akActor, Actor Caster)
    akActor=FMETarget
    FMETarget.RemoveSpell(RandEffChooserSpell)
endEvent

Event OnUnload()
    FMETarget.RemoveSpell(RandEffChooserSpell)
endEvent

Event OnCellDetach()
    FMETarget.RemoveSpell(RandEffChooserSpell)
endEvent