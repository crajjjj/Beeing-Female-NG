Scriptname _FME_SC_Overlays extends ActiveMagicEffect

Actor FMETarget

faction			    Property	GenericFaction	        Auto
faction     		Property	FMELastRank		        Auto		; Used to track when overlays are updated, so that they don't over-update (only updates when Rank does)
Actor				property	playerRef				Auto		; Game.GetPlayer() is slow by comparison.  CK should auto-fill, or put in "14" in xEdit
Spell				property	OverlayUpdater			Auto		; the spell that applies this ME.

;int RCT = FMETarget.GetFactionRank(GenericFaction) as int
;int LastTime = FMETarget.GetFactionRank(FMELastRank) as int


int LastTime2
int RCT2
int LastTime
int RCT

string JsonRaceSpec
int UseCustomRaceJSON = 0
float RAStepSizeLone
int RADir
float GAStepSizeLone
int GADir
float BAStepSizeLone
int BADir

float RSStepSizeLone
int RSDir
float GSStepSizeLone
int GSDir
float BSStepSizeLone
int BSDir

bool	TitKit

Event OnEffectStart(Actor akActor, Actor Caster)
    FMETarget = akActor
    ; Check if actor is both 3D loaded and being tracked by both FM+ via Generic Faction and FM+ - Immersive Effects by the FMELastRank Overlay tracking faction
    if MiscUtil.FileExists("data/textures/actors/TitKit/speckle 1 medium.dds")
        TitKit = true
    Else
        TitKit = false
    endIf
    if TitKit
        ;Debug.Notification ("New Soft Integration Method Works!")
        AreolaUpdate(FMETarget)
    endIf
    StretchmarkUpdate(FMETarget)
    FMETarget.RemoveSpell(OverlayUpdater)
EndEvent

Event OnDying(Actor akKiller)
    FMETarget.RemoveSpell(OverlayUpdater)
EndEvent

Event OnEffectFinish(Actor akActor, Actor Caster)
    FMETarget = akActor
    FMETarget.RemoveSpell(OverlayUpdater)
endEvent

Event OnUnload()
    FMETarget.RemoveSpell(OverlayUpdater)
endEvent

Event OnCellDetach()
    FMETarget.RemoveSpell(OverlayUpdater)
endEvent

Function AreolaUpdate(Actor akActor)
    RCT2 = StorageUtil.GetIntValue(akActor, "FME.Rank", 0)
    LastTime2 = akActor.GetFactionRank(FMELastRank)
    ; BF NG patch: GenericFaction may be None after the master-swap step
    ; (the patched ESP can leave the property unfilled), so we use
    ; FME.Rank 1..100 as the "BF is tracking this actor in a pregnancy state"
    ; signal instead of IsInFaction(GenericFaction). The <= 100 bound matters:
    ; upstream FMR dropped GenericFaction at birth, which is what let the
    ; recovery ranks (101-115) fall through to the fade-out branches below.
    ; FMELastRank is still consulted because it is a local FMR-IE faction.
    If akActor.IsInFaction(FMELastRank) && akActor.Is3DLoaded() && RCT2 > 0 && RCT2 <= 100
        RCT2 = StorageUtil.GetIntValue(akActor, "FME.Rank", 0)
        LastTime2 = akActor.GetFactionRank(FMELastRank)
        If (RCT2 >= 1 && RCT2 < 67 && LastTime2 != RCT2)
            float AlpFloat2=((RCT2 as int)/67.0)
            int ColorInt2=InitializeColors(akActor,0,RCT2,1)
            ActorOverlayRemove2(akActor, "body", "darkernip", true)
            ActorOverlayAdd2(akActor, "body", "darkernip" , "speckle 1 medium",true,ColorInt2, AlpFloat2)
        elseIf (RCT2 >= 67 && RCT2 <= 100 && LastTime2 != RCT2)
            int ColorInt2=InitializeColors(akActor,0,RCT2,2)
            ActorOverlayRemove2(akActor, "body", "darkernip", true)
            ActorOverlayAdd2(akActor, "body", "darkernip","speckle 1 medium",true,ColorInt2, 1.0)
        endIf
    ; FMR Compatibility: Recovery uses positive range 101-115 (not FM+'s negative -85 to -115)
    elseIf (RCT2 >= 101 && RCT2 < 115 && LastTime2 != RCT2)
        ; Recovery period - gradually fade areola darkening
        int ColorInt2=InitializeColors(akActor,0,RCT2,3)
        float AlpFloat2=1.0 - ((RCT2 - 101) as float / 14.0)  ; Fade from 1.0 to 0 over recovery
        ActorOverlayRemove2(akActor, "body", "darkernip", true)
        ActorOverlayAdd2(akActor, "body", "darkernip" , "speckle 1 medium",true,ColorInt2, AlpFloat2)
    elseIf (RCT2 >= 115)
        ; End of recovery - remove areola overlay
        ActorOverlayRemove2(akActor, "body", "darkernip", true)
    elseif RCT2 <= 0
        ; Not pregnant - remove overlay
        ActorOverlayRemove2(akActor, "body", "darkernip", true)
    else
        return
    endIf
endFunction

Function StretchmarkUpdate(Actor akActor)
    RCT = StorageUtil.GetIntValue(akActor, "FME.Rank", 0)
    LastTime = akActor.GetFactionRank(FMELastRank)
    ; BF NG patch: see AreolaUpdate's matching comment (incl. why <= 100).
    If akActor.IsInFaction(FMELastRank) && akActor.Is3DLoaded() && RCT > 0 && RCT <= 100
        ; If the actor is, pull those values for faction rank to use in the logic path
        RCT = StorageUtil.GetIntValue(akActor, "FME.Rank", 0)
        LastTime = akActor.GetFactionRank(FMELastRank)
        If (RCT >= 14 && RCT < 85 && LastTime != RCT)
            ; From the start of scaling until 85% through, increase stretchmark opacity until alpha of 70 is reached
            float AlpFloat=((RCT as int) + -14.0)/255 ; check if this should be 100 or 255
            ; (14-14 gives an alpha of 0, so first visibility is at 15)
            int ColorInt=InitializeColors(akActor,1,RCT,1)
            ActorOverlayRemove(akActor, "body", "breaststretch", true)
            ActorOverlayAdd(akActor, "body", "breaststretch" , "Stretch Breasts 2",true,ColorInt, AlpFloat)
            ActorOverlayRemove(akActor, "body", "bellystretch", true)
            ActorOverlayAdd(akActor, "body", "bellystretch" , "Stretch Pregnancy 1",true,ColorInt, AlpFloat)
            ; Update the last faction tracking
            akActor.SetFactionRank(FMELastRank,(RCT as int))
        elseIf (RCT >= 85 && RCT <= 100 && LastTime != RCT)
            ; From 85% until typical pregnancy completion (100%), slowly blue-shift the color of the stretchmarks
            int ColorInt=InitializeColors(akActor,1,RCT,2)
            ; Interesting that Papyrus doesn't complain about multiplying a hex by a base 10 number
            ActorOverlayRemove(akActor, "body", "breaststretch", true)
            ActorOverlayAdd(akActor, "body", "breaststretch" , "Stretch Breasts 2",true,ColorInt, 0.275)
            ActorOverlayRemove(akActor, "body", "bellystretch", true)
            ActorOverlayAdd(akActor, "body", "bellystretch" , "Stretch Pregnancy 1",true,ColorInt, 0.275)
            ; Update the last faction tracking
            akActor.SetFactionRank(FMELastRank,(RCT as int))
        endIf
        ; FMR Compatibility: No overdue state, pregnancy ends at 100
        ;Check if actor is being tracked by FMR but not IE (ex. very beginning of pregnancy)
    elseif akActor.Is3DLoaded() && RCT > 0 && RCT <= 115 && !akActor.IsInFaction(FMELastRank)
        ; BF NG patch: bootstrap — bridge has written FME.Rank but the actor
        ; isn't yet in FMR-IE's own FMELastRank tracking faction. Add them so
        ; the next OverlayUpdater pass enters the main draw branch.
        akActor.AddToFaction(FMELastRank)
    ; FMR Compatibility: Recovery uses positive range 101-115 (not FM+'s negative -85 to -115)
    elseIf (RCT >= 101 && RCT < 115 && LastTime != RCT)
        ; Recovery period - gradually fade stretchmarks
        int ColorInt=InitializeColors(akActor,1,RCT,3)
        float AlpFloat=0.275 * (1.0 - ((RCT - 101) as float / 14.0))  ; Fade from 0.275 to 0
        ActorOverlayRemove(akActor, "body", "bellystretch", true)
        ActorOverlayAdd(akActor, "body", "bellystretch" , "Stretch Pregnancy 1",true,ColorInt, AlpFloat)
        ActorOverlayRemove(akActor, "body", "breaststretch", true)
        ActorOverlayAdd(akActor, "body", "breaststretch" , "Stretch Breasts 2",true,ColorInt, AlpFloat)
        ; Update the last faction tracking
        akActor.SetFactionRank(FMELastRank,(RCT as int))
    elseIf (RCT >= 115)
        ; End of recovery, remove stretchmarks
        ActorOverlayRemove(akActor, "body", "bellystretch", true)
        ActorOverlayRemove(akActor, "body", "breaststretch", true)
        ; Update the last faction tracking
        akActor.SetFactionRank(FMELastRank,0)
        ; Tracking complete, remove from faction
        akActor.RemoveFromFaction(FMELastRank)
    elseif RCT <= 0
        ; Not pregnant - cleanup overlays
        ActorOverlayRemove(akActor, "body", "bellystretch", true)
        ActorOverlayRemove(akActor, "body", "breaststretch", true)
        akActor.SetFactionRank(FMELastRank,0)
        akActor.RemoveFromFaction(FMELastRank)
    else
        Return
    endif
    FMETarget.RemoveSpell(OverlayUpdater)
endFunction

Function ActorOverlayAdd(Actor akActor, String bodyPart,String kind, String textureName, bool commit = true, int Color, float alpha)
	String NodeName = ActorOverlayGetSlot(akActor,bodyPart,kind)
	if NodeName == ""
		return
	endif
	textureName = "textures\\Actors\\character\\Overlays\\SFO\\"+textureName+".dds"
	Bool NodeSex = (akActor.GetLeveledActorBase().GetSex() == 1)
	
	NiOverride.AddNodeOverrideString(akActor,NodeSex,NodeName,9, 0,textureName,TRUE)
	NiOverride.AddNodeOverrideFloat(akActor,NodeSex,NodeName,8,-1,alpha,TRUE)
	NiOverride.AddNodeOverrideInt(akActor,NodeSex,NodeName,7,-1,color, TRUE)
	;; NiOverride.AddNodeOverrideInt(Who,NodeSex,NodeName,0,-1,0,TRUE)
	;; NiOverride.AddNodeOverrideFloat(Who,NodeSex,NodeName,0,-1,1.0,TRUE)
	NiOverride.ApplyNodeOverrides(akActor)
	
endFunction

Function ActorOverlayAdd2(Actor akActor, String bodyPart,String kind, String textureName, bool commit = true, int Color, float alpha)
	String NodeName = ActorOverlayGetSlot(akActor,bodyPart,kind)
	if NodeName == ""
		return
	endif
	textureName = "textures\\Actors\\TitKit\\"+textureName+".dds"
	Bool NodeSex = (akActor.GetLeveledActorBase().GetSex() == 1)
	
	NiOverride.AddNodeOverrideString(akActor,NodeSex,NodeName,9, 0,textureName,TRUE)
	NiOverride.AddNodeOverrideFloat(akActor,NodeSex,NodeName,8,-1,alpha,TRUE)
	NiOverride.AddNodeOverrideInt(akActor,NodeSex,NodeName,7,-1,color, TRUE)
	;; NiOverride.AddNodeOverrideInt(Who,NodeSex,NodeName,0,-1,0,TRUE)
	;; NiOverride.AddNodeOverrideFloat(Who,NodeSex,NodeName,0,-1,1.0,TRUE)
	NiOverride.ApplyNodeOverrides(akActor)
	
endFunction

Function ActorOverlayRemove(Actor akActor, String bodyPart,String kind, Bool commit = true)
    String NodeName = ActorOverlayGetSlot(akActor,bodyPart,kind)
    if NodeName == ""
        return
    endif

    Bool NodeSex = (akActor.GetLeveledActorBase().GetSex() == 1)
    String textureName = "textures\\Actors\\character\\Overlays\\SFO\\"+textureName+".dds"

    NiOverride.RemoveAllNodeNameOverrides(akActor,NodeSex,NodeName)
    NiOverride.AddNodeOverrideString(akActor,NodeSex,NodeName,9,0,"textures\\Actors\\character\\Overlays\\default.dds",TRUE)
    StorageUtil.UnsetStringValue(akActor,textureName)
    if commit == true
        NiOverride.ApplyNodeOverrides(akActor)
    endif

    Return
EndFunction

Function ActorOverlayRemove2(Actor akActor, String bodyPart,String kind, Bool commit = true)
    String NodeName = ActorOverlayGetSlot(akActor,bodyPart,kind)
    if NodeName == ""
        return
    endif

    Bool NodeSex = (akActor.GetLeveledActorBase().GetSex() == 1)
    String textureName = "textures\\Actors\\TitKit\\"+textureName+".dds"

    NiOverride.RemoveAllNodeNameOverrides(akActor,NodeSex,NodeName)
    NiOverride.AddNodeOverrideString(akActor,NodeSex,NodeName,9,0,"textures\\Actors\\character\\Overlays\\default.dds",TRUE)
    StorageUtil.UnsetStringValue(akActor,textureName)
    if commit == true
        NiOverride.ApplyNodeOverrides(akActor)
    endif

    Return
EndFunction


String Function ActorOverlayGetSlot(Actor akActor, String bodyPart,String kind )
    {find the next available overlay slot, or the slot we were already using.}
    
        String NodeName
    
        ;; prefix the overlay name.
    
        String textureName = "FME.Overlay."+kind+"."+bodyPart
    
        ;; see if we already selected a node.
    
        NodeName = StorageUtil.GetStringValue(akActor,textureName, "")
        If(NodeName != "")
            Return NodeName
        EndIf
    
        ;; alright lets find an empty slot and gank it.
    
        ;int Function GetNumBodyOverlays() native global
        ;int Function GetNumHandOverlays() native global
        ;int Function GetNumFeetOverlays() native global
        ;int Function GetNumFaceOverlays() native global
        
        
        Int NodeCount = 0;
        String PartName = "";
        if bodyPart == "body"
            NodeCount = NiOverride.GetNumBodyOverlays()
            PartName = "Body"
        endif
        
        if bodyPart == "hand"
            NodeCount = NiOverride.GetNumHandOverlays()
            PartName = "Hands"
        endif
        
        if bodyPart == "feet"
            NodeCount = NiOverride.GetNumFeetOverlays()
            PartName = "Feet"
        endif
    
        if bodyPart == "face"
            NodeCount = NiOverride.GetNumFaceOverlays()
            PartName = "Face"
        endif
        
        
        Int NodeIter = 0
        Bool NodeSex = (akActor.GetLeveledActorBase().GetSex() == 1)
        String NodeTexture
    
        While(NodeIter < NodeCount)
            NodeName = PartName+" [Ovl" + NodeIter + "]"
            NodeTexture = NiOverride.GetNodeOverrideString(akActor,NodeSex,NodeName,9,0)
    
            If(NodeTexture == "" || NodeTexture == "textures\\Actors\\character\\overlays\\default.dds")
                ;; mine now.
                StorageUtil.SetStringValue(akActor,textureName,NodeName)
                Return NodeName
            EndIf
    
            NodeIter += 1
        EndWhile
        Return ""
EndFunction

int Function InitializeColors(Actor akActor,bool OverlayType,int RCT4,int ColorState)
    UseCustomRaceJSON=Jsonutil.GetIntValue("/FMEffects/Config.json", "usecustomracejson", 0)
    ;Debug.Notification("Use Custom Race = "+UseCustomRaceJSON)
    string raceName
    raceName = (akActor.GetLeveledActorBase().GetRace() as form).GetName()
    ;Debug.Notification ("Player Race is"+raceName)
    if  raceName == "Argonian";|| ActorRace=VampireVersion
        JsonRaceSpec="/FMEffects/OverlayColors/Argonian.json"
    elseif  raceName == "Breton" ;|| ActorRace=VampireVersion
        JsonRaceSpec="/FMEffects/OverlayColors/Breton.json"
    elseif raceName == "Dark Elf" ;|| ActorRace=VampireVersion
        JsonRaceSpec="/FMEffects/OverlayColors/DarkElf.json"
    elseif raceName == "High Elf" ;|| ActorRace=VampireVersion
        JsonRaceSpec="/FMEffects/OverlayColors/HighElf.json"
    elseif raceName == "Imperial" ;|| ActorRace=VampireVersion
        JsonRaceSpec="/FMEffects/OverlayColors/Imperial.json"
    elseif raceName == "Khajiit" ;|| ActorRace=VampireVersion
        JsonRaceSpec="/FMEffects/OverlayColors/Khajit.json"
    elseif raceName == "Nord" ;|| ActorRace=VampireVersion
        JsonRaceSpec="/FMEffects/OverlayColors/Nord.json"
    elseif raceName == "Orc" ;|| ActorRace=VampireVersion
        JsonRaceSpec="/FMEffects/OverlayColors/Orc.json"    
    elseif raceName == "Redguard" ;|| ActorRace=VampireVersion
        JsonRaceSpec="/FMEffects/OverlayColors/Redguard.json"
    elseif raceName == "Wood Elf" ;|| ActorRace=VampireVersion
        JsonRaceSpec="/FMEffects/OverlayColors/WoodElf.json"
    else
        if UseCustomRaceJSON==1
            JsonRaceSpec="/FMEffects/OverlayColors/CustomRace.json"
        else
            JsonRaceSpec="/FMEffects/OverlayColors/Breton.json"
        endIf
    endIf
    if ColorState==1
        if OverlayType==0
            int CPAreola1=Jsonutil.GetIntValue(JsonRaceSpec, "cpareola1", 0)
            ;Debug.Notification("Color Point Areola1 = "+CPAreola1)
            Return CPAreola1
        ElseIf OverlayType==1
            int CPStretch1=Jsonutil.GetIntValue(JsonRaceSpec, "cpstretch1", 0)
            ;Debug.Notification("Color Point Stretch1 = "+CPStretch1)
            Return CPStretch1
        EndIf
    ElseIf ColorState==2
        if OverlayType==0
            ; Pull and calculate all RGB Color Endpoints as integers - DARKENING NIPPLES
            int CPAreola1=Jsonutil.GetIntValue(JsonRaceSpec, "cpareola1", 0)
            int DesiredAreolaR1=Math.RightShift(CPAreola1,16)
            int GBAreolaIntermediary1=CPAreola1-Math.LeftShift(DesiredAreolaR1,16)
            int DesiredAreolaG1=Math.RightShift(GBAreolaIntermediary1,8)
            int DesiredAreolaB1=GBAreolaIntermediary1-Math.LeftShift(DesiredAreolaG1,8)
            int CPAreola2=Jsonutil.GetIntValue(JsonRaceSpec, "cpareola2", 0)
            int DesiredAreolaR2=Math.RightShift(CPAreola2,16)
            int GBAreolaIntermediary2=CPAreola2-Math.LeftShift(DesiredAreolaR2,16)
            int DesiredAreolaG2=Math.RightShift(GBAreolaIntermediary2,8)
            int DesiredAreolaB2=GBAreolaIntermediary2-Math.LeftShift(DesiredAreolaG2,8)
            ; Convert integers to floated stepsize - DARKENING NIPPLES
            If (DesiredAreolaR1>DesiredAreolaR2)
                RAStepSizeLone=((DesiredAreolaR1-DesiredAreolaR2)/34.0)
                RADir=(-1)
            elseIf (DesiredAreolaR1<DesiredAreolaR2)
                RAStepSizeLone=((DesiredAreolaR2-DesiredAreolaR1)/34.0)
                RADir=(1)
            else
                RAStepSizeLone=(0)
                RADir=(1)
            endIf
            ;Debug.Notification ("Red Step Size is "+RAStepSizeLone+" with direction "+RADir)
            If (DesiredAreolaG1>DesiredAreolaG2)
                GAStepSizeLone=((DesiredAreolaG1-DesiredAreolaG2)/34.0)
                GADir=(-1)
            elseIf (DesiredAreolaG1<DesiredAreolaG2)
                GAStepSizeLone=((DesiredAreolaG2-DesiredAreolaG1)/34.0)
                GADir=(1)
            else
                GAStepSizeLone=(0)
                GADir=(1)
            endIf
            ;Debug.Notification ("Green Step Size is "+GAStepSizeLone+" with direction "+GADir)
            If (DesiredAreolaB1>DesiredAreolaB2)
                BAStepSizeLone=((DesiredAreolaB1-DesiredAreolaB2)/34.0)
                BADir=(-1)
            elseIf (DesiredAreolaB1<DesiredAreolaB2)
                BAStepSizeLone=((DesiredAreolaB2-DesiredAreolaB1)/34.0)
                BADir=(1)
            else
                BAStepSizeLone=0.0
                BADir=(1)
            endIf
            ;Debug.Notification ("Blue Step Size is "+BAStepSizeLone+" with direction "+BADir)
            ; IN TRANSITION ZONE 
            float RACurrentColorFloat=DesiredAreolaR1+RADir*(RCT4+ -66)*RAStepSizeLone
            int RACurrentInt=round(RACurrentColorFloat)*0x10000
            float GACurrentColorFloat=DesiredAreolaG1+GADir*(RCT4+ -66)*GAStepSizeLone
            int GACurrentInt=round(GACurrentColorFloat)*0x100
            float BACurrentColorFloat=DesiredAreolaB1+BADir*(RCT4+ -66)*BAStepSizeLone
            int BACurrentInt=round(BACurrentColorFloat)
            int FinalColorAreola=RACurrentInt + GACurrentInt + BACurrentInt
            Return FinalColorAreola
            ;Debug.Notification ("Areola Color Point 1 Setting is "+CPAreola1)
            ;Debug.Notification ("Areola Color Point 2 Intended Setting is "+CPAreola2)
            ;Debug.Notification ("Current Areola Color is "+FinalColorAreola)
        ElseIf OverlayType==1
            int CPStretch1=Jsonutil.GetIntValue(JsonRaceSpec, "cpstretch1", 0)
            int DesiredStretchR1=Math.RightShift(CPStretch1,16)
            int GBStretchIntermediary1=CPStretch1-Math.LeftShift(DesiredStretchR1,16)
            int DesiredStretchG1=Math.RightShift(GBStretchIntermediary1,8)
            int DesiredStretchB1=GBStretchIntermediary1-Math.LeftShift(DesiredStretchG1,8)
            int CPStretch2=Jsonutil.GetIntValue(JsonRaceSpec, "cpstretch2", 0)
            int DesiredStretchR2=Math.RightShift(CPStretch2,16)
            int GBStretchIntermediary2=CPStretch2-Math.LeftShift(DesiredStretchR2,16)
            int DesiredStretchG2=Math.RightShift(GBStretchIntermediary2,8)
            int DesiredStretchB2=GBStretchIntermediary2-Math.LeftShift(DesiredStretchG2,8)
            ; Convert integers to floated stepsize - STRETCHMARKS
            If (DesiredStretchR1>DesiredStretchR2)
                RSStepSizeLone=((DesiredStretchR1-DesiredStretchR2)/15.0)
                RSDir=(-1)
            elseIf (DesiredStretchR1<DesiredStretchR2)
                RSStepSizeLone=((DesiredStretchR2-DesiredStretchR1)/15.0)
                RSDir=(1)
            else
                RSStepSizeLone=(0)
                RSDir=(1)
            endIf
            If (DesiredStretchG1>DesiredStretchG2)
                GSStepSizeLone=((DesiredStretchG1-DesiredStretchG2)/15.0)
                GSDir=(-1)
            elseIf (DesiredStretchG1<DesiredStretchG2)
                GSStepSizeLone=((DesiredStretchG2-DesiredStretchG1)/15.0)
                GSDir=(1)
            else
                GSStepSizeLone=(0)
                GSDir=(1)
            endIf
            If (DesiredStretchB1>DesiredStretchB2)
                BSStepSizeLone=((DesiredStretchB1-DesiredStretchB2)/15.0)
                BSDir=(-1)
            elseIf (DesiredStretchB1<DesiredStretchB2)
                BSStepSizeLone=((DesiredStretchB2-DesiredStretchB1)/15.0)
                BSDir=(1)
            else
                BSStepSizeLone=0.0
                BSDir=(1)
            endIf
            ; IN TRANSITION ZONE 
            float RSCurrentColorFloat=(RCT4+ -85)*RSStepSizeLone
            int RSCurrentInt=round(RSCurrentColorFloat)*0x10000
            float GSCurrentColorFloat=(RCT4+ -85)*GSStepSizeLone
            int GSCurrentInt=round(GSCurrentColorFloat)*0x100
            float BSCurrentColorFloat=(RCT4+ -85)*BSStepSizeLone
            int BSCurrentInt=round(BSCurrentColorFloat)
            int FinalColorStretch=CPStretch1 + RSDir*RSCurrentInt + GSDir*GSCurrentInt + BSDir*BSCurrentInt
            ;Debug.Notification ("Stretch Color Point 1 Setting is "+CPStretch1)
            ;Debug.Notification ("Stretch Color Point 2s Intended Setting is "+CPStretch2)
            ;Debug.Notification ("Current Stretch Color is "+FinalColorStretch)
            Return FinalColorStretch
        EndIf
    ElseIf ColorState==3
        if OverlayType==0
            int CPAreola1=Jsonutil.GetIntValue(JsonRaceSpec, "cpareola2", 0)
            ;Debug.Notification("Color Point Areola2 = "+CPAreola1)
            Return CPAreola1
        ElseIf OverlayType==1
            int CPStretch1=Jsonutil.GetIntValue(JsonRaceSpec, "cpstretch2", 0)
            ;Debug.Notification("Color Point Stretch2 = "+CPStretch1)
            Return CPStretch1
        EndIf
    EndIf
EndFunction

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