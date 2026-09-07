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
    ; Dependency/slot failures may block a new paint, but must never block the
    ; rank-0/end-of-recovery cleanup paths below.
    ; BF NG patch: pregnancy progress comes from the bridge via StorageUtil
    ; ("FME.Rank", 0..115) instead of GetFactionRank(GenericFaction) - BF's
    ; ParentFaction carries cycle-state IDs (-2..7), not the FMR band scale.
    ; The IsInFaction(GenericFaction) gate is dropped for the same reason;
    ; a nonzero FME.Rank is the "tracked" signal.
    Int currentRank = StorageUtil.GetIntValue(FMETarget, "FME.Rank", 0)
    Bool needsOverlayPaint = currentRank > 0 && currentRank < 115
    if needsOverlayPaint && FMETarget.Is3DLoaded() && !OverlayPreflight(FMETarget)
        FMETarget.RemoveSpell(OverlayUpdater)
        return
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

Bool Function OverlayPreflight(Actor akActor)
    ; SFO supplies both mandatory stretchmark textures. They are dependencies,
    ; not assets distributed by Immersive Effects.
    Bool hasBellyTexture = MiscUtil.FileExists("data/textures/Actors/character/Overlays/SFO/Stretch Pregnancy 1.dds")
    Bool hasBreastTexture = MiscUtil.FileExists("data/textures/Actors/character/Overlays/SFO/Stretch Breasts 2.dds")
    if !hasBellyTexture || !hasBreastTexture
        Debug.Trace("[FMR Immersive Effects] Overlay preflight failed: required SFO texture(s) are missing. Need Stretch Pregnancy 1.dds and Stretch Breasts 2.dds under Data\\textures\\Actors\\character\\Overlays\\SFO\\.", 2)
        return false
    endIf

    ; A getter triggers PapyrusUtil's lazy load before IsGood is queried.
    Int configProbe = JsonUtil.GetIntValue("/FMEffects/Config.json", "usecustomracejson", -1)
    if !JsonUtil.IsGood("/FMEffects/Config.json")
        Debug.Trace("[FMR Immersive Effects] Config.json is missing or invalid: " + JsonUtil.GetErrors("/FMEffects/Config.json"), 2)
    endIf

    Int bodySlotCount = NiOverride.GetNumBodyOverlays()
    if bodySlotCount < 2
        Debug.Trace("[FMR Immersive Effects] Overlay preflight failed: RaceMenu reports " + bodySlotCount + " body overlay slot(s), but the two SFO effects require 2. Verify the correct RaceMenu/RaceMenu VR build and bEnableOverlays=1.", 2)
        return false
    endIf

    Int usableSlots = CountUsableBodyOverlaySlots(akActor)
    if usableSlots < 2
        Debug.Trace("[FMR Immersive Effects] Overlay preflight failed for " + akActor.GetDisplayName() + ": only " + usableSlots + " free or already-owned body overlay slot(s); 2 are required for belly and breast stretchmarks.", 2)
        return false
    endIf

    ; TitKit is optional. Its areola effect needs a third body slot, but it must
    ; never consume one of the two mandatory SFO slots when capacity is tight.
    if TitKit && usableSlots < 3
        Debug.Trace("[FMR Immersive Effects] TitKit texture found, but only " + usableSlots + " body overlay slot(s) are usable for " + akActor.GetDisplayName() + ". Disabling the optional areola effect for this update; TitKit plus both SFO effects require 3.", 2)
        TitKit = false
    endIf

    return true
EndFunction

Int Function CountUsableBodyOverlaySlots(Actor akActor)
    Int nodeCount = NiOverride.GetNumBodyOverlays()
    Bool nodeSex = (akActor.GetLeveledActorBase().GetSex() == 1)
    String bellyNode = StorageUtil.GetStringValue(akActor, "FME.Overlay.bellystretch.body", "")
    String breastNode = StorageUtil.GetStringValue(akActor, "FME.Overlay.breaststretch.body", "")
    String areolaNode = StorageUtil.GetStringValue(akActor, "FME.Overlay.darkernip.body", "")
    Int usableSlots = 0
    Int nodeIter = 0

    while nodeIter < nodeCount
        String nodeName = "Body [Ovl" + nodeIter + "]"
        Bool ownedByFME = (nodeName == bellyNode || nodeName == breastNode || (TitKit && nodeName == areolaNode))
        if ownedByFME
            usableSlots += 1
        else
            String nodeTexture = NiOverride.GetNodeOverrideString(akActor, nodeSex, nodeName, 9, 0)
            if IsEmptyOverlayTexture(nodeTexture)
                usableSlots += 1
            endIf
        endIf
        nodeIter += 1
    endWhile

    return usableSlots
EndFunction

Bool Function IsEmptyOverlayTexture(String texturePath)
    return texturePath == "" || texturePath == "textures\\Actors\\character\\overlays\\default.dds" || texturePath == "textures\\Actors\\character\\Overlays\\default.dds"
EndFunction

Function AreolaUpdate(Actor akActor)
    ; Restructured to match StretchmarkUpdate - rank checks run unconditionally
    ; so the recovery, end-of-recovery, and not-pregnant branches actually fire.
    RCT2 = StorageUtil.GetIntValue(akActor, "FME.Rank", 0) ; BF NG patch: see OnEffectStart
    LastTime2 = akActor.GetFactionRank(FMELastRank)

    if RCT2 <= 0
        ActorOverlayRemove2(akActor, "body", "darkernip", true)
        return
    endIf

    if !akActor.Is3DLoaded()
        return
    endIf

    If (RCT2 >= 1 && RCT2 < 67 && LastTime2 != RCT2)
        float AlpFloat2 = ((RCT2 as int)/67.0)
        int ColorInt2 = InitializeColors(akActor, 0, RCT2, 1)
        ActorOverlayRemove2(akActor, "body", "darkernip", true)
        ActorOverlayAdd2(akActor, "body", "darkernip", "speckle 1 medium", true, ColorInt2, AlpFloat2)
    elseIf (RCT2 >= 67 && RCT2 <= 100 && LastTime2 != RCT2)
        int ColorInt2 = InitializeColors(akActor, 0, RCT2, 2)
        ActorOverlayRemove2(akActor, "body", "darkernip", true)
        ActorOverlayAdd2(akActor, "body", "darkernip", "speckle 1 medium", true, ColorInt2, 1.0)
    elseIf (RCT2 >= 101 && RCT2 < 115 && LastTime2 != RCT2)
        int ColorInt2 = InitializeColors(akActor, 0, RCT2, 3)
        float AlpFloat2 = 1.0 - ((RCT2 - 101) as float / 14.0)
        ActorOverlayRemove2(akActor, "body", "darkernip", true)
        ActorOverlayAdd2(akActor, "body", "darkernip", "speckle 1 medium", true, ColorInt2, AlpFloat2)
    elseIf (RCT2 >= 115)
        ActorOverlayRemove2(akActor, "body", "darkernip", true)
    endIf
endFunction

Function StretchmarkUpdate(Actor akActor)
    ; Restructured: rank checks run unconditionally so the recovery,
    ; end-of-recovery, and not-pregnant branches are reachable. Previously
    ; they were nested inside an If gated on IsInFaction(FMELastRank) &&
    ; IsInFaction(GenericFaction), which meant cleanup never fired - the
    ; actor was always still in those factions when rank dropped to 0/115.
    RCT = StorageUtil.GetIntValue(akActor, "FME.Rank", 0) ; BF NG patch: see OnEffectStart
    LastTime = akActor.GetFactionRank(FMELastRank)

    ; Not pregnant - clear any lingering overlays and drop tracking faction
    if RCT <= 0
        ActorOverlayRemove(akActor, "body", "bellystretch", true)
        ActorOverlayRemove(akActor, "body", "breaststretch", true)
        akActor.SetFactionRank(FMELastRank, 0)
        if akActor.IsInFaction(FMELastRank)
            akActor.RemoveFromFaction(FMELastRank)
        endIf
        FMETarget.RemoveSpell(OverlayUpdater)
        return
    endIf

    if !akActor.Is3DLoaded()
        FMETarget.RemoveSpell(OverlayUpdater)
        return
    endIf

    ; Make sure the actor is tracked by FMELastRank for delta detection
    if !akActor.IsInFaction(FMELastRank)
        akActor.AddToFaction(FMELastRank)
    endIf

    if (RCT >= 14 && RCT < 85 && LastTime != RCT)
        ; Fade-in: alpha climbs from 0/255 at rank 14 to 71/255 at rank 84
        float AlpFloat = ((RCT as int) + -14.0)/255
        float StartAlpha = GetStretchmarkAlpha(LastTime)
        int ColorInt = InitializeColors(akActor, 1, RCT, 1)
        ActorOverlayRemove(akActor, "body", "breaststretch", true)
        ActorOverlayAdd(akActor, "body", "breaststretch", "Stretch Breasts 2", true, ColorInt, StartAlpha)
        ActorOverlayRemove(akActor, "body", "bellystretch", true)
        ActorOverlayAdd(akActor, "body", "bellystretch", "Stretch Pregnancy 1", true, ColorInt, StartAlpha)
        TweenStretchmarkAlpha(akActor, StartAlpha, AlpFloat, LastTime, RCT)
        akActor.SetFactionRank(FMELastRank, (RCT as int))
    elseIf (RCT >= 85 && RCT <= 100 && LastTime != RCT)
        ; Late pregnancy: peak alpha, blue-shift color toward second color point
        float StartAlpha = GetStretchmarkAlpha(LastTime)
        int ColorInt = InitializeColors(akActor, 1, RCT, 2)
        ActorOverlayRemove(akActor, "body", "breaststretch", true)
        ActorOverlayAdd(akActor, "body", "breaststretch", "Stretch Breasts 2", true, ColorInt, StartAlpha)
        ActorOverlayRemove(akActor, "body", "bellystretch", true)
        ActorOverlayAdd(akActor, "body", "bellystretch", "Stretch Pregnancy 1", true, ColorInt, StartAlpha)
        TweenStretchmarkAlpha(akActor, StartAlpha, 0.275, LastTime, RCT)
        akActor.SetFactionRank(FMELastRank, (RCT as int))
    elseIf (RCT >= 101 && RCT < 115 && LastTime != RCT)
        ; Recovery: fade alpha back down to 0 across ranks 101-114
        int ColorInt = InitializeColors(akActor, 1, RCT, 3)
        float AlpFloat = 0.275 * (1.0 - ((RCT - 101) as float / 14.0))
        float StartAlpha = GetStretchmarkAlpha(LastTime)
        ActorOverlayRemove(akActor, "body", "bellystretch", true)
        ActorOverlayAdd(akActor, "body", "bellystretch", "Stretch Pregnancy 1", true, ColorInt, StartAlpha)
        ActorOverlayRemove(akActor, "body", "breaststretch", true)
        ActorOverlayAdd(akActor, "body", "breaststretch", "Stretch Breasts 2", true, ColorInt, StartAlpha)
        TweenStretchmarkAlpha(akActor, StartAlpha, AlpFloat, LastTime, RCT)
        akActor.SetFactionRank(FMELastRank, (RCT as int))
    elseIf (RCT >= 115)
        ; End of recovery - strip overlays and stop tracking
        ActorOverlayRemove(akActor, "body", "bellystretch", true)
        ActorOverlayRemove(akActor, "body", "breaststretch", true)
        akActor.SetFactionRank(FMELastRank, 0)
        akActor.RemoveFromFaction(FMELastRank)
    endIf

    FMETarget.RemoveSpell(OverlayUpdater)
endFunction

float Function GetStretchmarkAlpha(int rank)
    if rank < 14
        return 0.0
    elseIf rank < 85
        return ((rank as int) + -14.0) / 255.0
    elseIf rank <= 100
        return 0.275
    elseIf rank < 115
        return 0.275 * (1.0 - ((rank - 101) as float / 14.0))
    endIf

    return 0.0
EndFunction

Function TweenStretchmarkAlpha(Actor akActor, float startAlpha, float targetAlpha, int oldRank, int newRank)
    ; FMR can jump several ranks between polls. Interpolate those jumps so a
    ; newly discovered overlay visibly fades instead of snapping to its target.
    int rankDelta = newRank - oldRank
    if rankDelta < 0
        rankDelta = 0 - rankDelta
    endIf

    if rankDelta <= 1
        startAlpha = targetAlpha
    endIf

    String bellyNode = StorageUtil.GetStringValue(akActor, "FME.Overlay.bellystretch.body", "")
    String breastNode = StorageUtil.GetStringValue(akActor, "FME.Overlay.breaststretch.body", "")
    Bool NodeSex = (akActor.GetLeveledActorBase().GetSex() == 1)
    int step = 0
    int steps = 8

    while step < steps
        step += 1
        float alpha = startAlpha + ((targetAlpha - startAlpha) * step / steps)
        if bellyNode != ""
            NiOverride.AddNodeOverrideFloat(akActor,NodeSex,bellyNode,8,-1,alpha,TRUE)
        endIf
        if breastNode != ""
            NiOverride.AddNodeOverrideFloat(akActor,NodeSex,breastNode,8,-1,alpha,TRUE)
        endIf
        NiOverride.ApplyNodeOverrides(akActor)
        if rankDelta > 1 && step < steps
            Utility.Wait(0.05)
        endIf
    endWhile
EndFunction

Function ActorOverlayAdd(Actor akActor, String bodyPart,String kind, String textureName, bool commit = true, int Color, float alpha)
	String NodeName = ActorOverlayGetSlot(akActor,bodyPart,kind)
	if NodeName == ""
		Debug.Trace("[FMR Immersive Effects] Could not apply " + kind + " to " + akActor.GetDisplayName() + ": no free " + bodyPart + " overlay slot.", 2)
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
		Debug.Trace("[FMR Immersive Effects] Could not apply optional " + kind + " overlay to " + akActor.GetDisplayName() + ": no free " + bodyPart + " overlay slot.", 2)
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
    ; Removal must only use a slot we previously claimed. Calling
    ; ActorOverlayGetSlot here can claim an unrelated empty slot during cleanup,
    ; and the old code then unset a malformed texture-path key instead of the
    ; StorageUtil slot key, leaving our real slot ownership stuck in the save.
    String slotKey = "FME.Overlay."+kind+"."+bodyPart
    String NodeName = StorageUtil.GetStringValue(akActor,slotKey, "")
    if NodeName == ""
        return
    endif

    Bool NodeSex = (akActor.GetLeveledActorBase().GetSex() == 1)

    NiOverride.RemoveAllNodeNameOverrides(akActor,NodeSex,NodeName)
    NiOverride.AddNodeOverrideString(akActor,NodeSex,NodeName,9,0,"textures\\Actors\\character\\Overlays\\default.dds",TRUE)
    StorageUtil.UnsetStringValue(akActor,slotKey)
    if commit == true
        NiOverride.ApplyNodeOverrides(akActor)
    endif

    Return
EndFunction

Function ActorOverlayRemove2(Actor akActor, String bodyPart,String kind, Bool commit = true)
    String slotKey = "FME.Overlay."+kind+"."+bodyPart
    String NodeName = StorageUtil.GetStringValue(akActor,slotKey, "")
    if NodeName == ""
        return
    endif

    Bool NodeSex = (akActor.GetLeveledActorBase().GetSex() == 1)

    NiOverride.RemoveAllNodeNameOverrides(akActor,NodeSex,NodeName)
    NiOverride.AddNodeOverrideString(akActor,NodeSex,NodeName,9,0,"textures\\Actors\\character\\Overlays\\default.dds",TRUE)
    StorageUtil.UnsetStringValue(akActor,slotKey)
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
    ; Use the actor instance's current race. A leveled actor base can retain the
    ; original race after a player/NPC changes to a custom race.
    string raceName = ""
    Race currentRace = akActor.GetRace()
    if currentRace
        raceName = currentRace.GetName()
    else
        Debug.Trace("[FMR Immersive Effects] Could not resolve the current race for " + akActor.GetDisplayName() + "; treating it as a custom/unknown race.", 2)
    endIf
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
            Debug.Trace("[FMR Immersive Effects] Race '" + raceName + "' is not a built-in mapping; usecustomracejson=1, so CustomRace.json is selected.")
        else
            JsonRaceSpec="/FMEffects/OverlayColors/Breton.json"
            Debug.Trace("[FMR Immersive Effects] Race '" + raceName + "' is not a built-in mapping; usecustomracejson=0, so Breton.json is the fallback. Set it to 1 to use CustomRace.json.", 1)
        endIf
    endIf
    ; Force the selected JSON through PapyrusUtil's lazy loader before testing it.
    Int colorProfileProbe = JsonUtil.GetIntValue(JsonRaceSpec, "cpstretch1", -1)
    if !JsonUtil.IsGood(JsonRaceSpec)
        Debug.Trace("[FMR Immersive Effects] Overlay color JSON is missing or invalid (" + JsonRaceSpec + "): " + JsonUtil.GetErrors(JsonRaceSpec), 2)
        if JsonRaceSpec != "/FMEffects/OverlayColors/Breton.json"
            Int fallbackProbe = JsonUtil.GetIntValue("/FMEffects/OverlayColors/Breton.json", "cpstretch1", -1)
            if JsonUtil.IsGood("/FMEffects/OverlayColors/Breton.json")
                Debug.Trace("[FMR Immersive Effects] Falling back to the valid Breton.json color profile.", 1)
                JsonRaceSpec="/FMEffects/OverlayColors/Breton.json"
            endIf
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
