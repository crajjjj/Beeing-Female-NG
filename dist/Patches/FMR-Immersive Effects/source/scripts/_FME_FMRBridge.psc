Scriptname _FME_FMRBridge extends Quest
{Bridge: drives FMR-Immersive Effects from BeeingFemale NG state.
Replaces the original FMR-IE bridge so the mod no longer requires Fertility Mode.}

import StorageUtil

; --- CK-filled spell properties (must keep for binding) ---
Spell Property _FME_S_1T_MornSick   Auto
Spell Property _FME_S_Craving       Auto
Spell Property _FME_S_2T_Fetal      Auto
Spell Property _FME_S_3T_Fetal      Auto
Spell Property _FME_S_3T_Braxton    Auto
Spell Property _FME_S_3T_Colostrum  Auto
Spell Property _FME_S_3T_Lactation  Auto
Spell Property RandEffChooserSpell  Auto
Spell Property OverlayUpdater       Auto

Actor Property PlayerRef Auto

; --- Tunables ---
Float Property TrackedUpdateIntervalHours = 1.5 Auto Hidden
{Safety poll for overlay refresh. BF NG also fires per-actor events, so this is
a backstop, not the primary trigger.}

; --- Cached state ---
FWSystem _bfSystem
Bool     _hasSexLab = false
Bool     _hasOStim  = false
String   _espName = "FMR- Immersive Effects.esp"
Faction  _fmeLastRank

; Note: this script intentionally does NOT carry a Faction property.
; The contract between the bridge and the patched FMR-IE scripts is the
; StorageUtil key "FME.Rank" (0..115 on the FMR-compatible scale, 0 when
; not pregnant). The bridge derives that rank from FW state and writes it
; in RefreshActor; the patched _FME_SC_Overlays and _FME_SC_RandEffChooser
; read it back via StorageUtil.GetIntValue, replacing the upstream
; GetFactionRank(GenericFaction) reads. GenericFaction is therefore
; redundant in the patched ESP — the property fills can be cleared.
; (_fmeLastRank above is not a CK property either: it is FMR-IE's own
; _FMELastRank delta-tracking faction, resolved lazily via GetFormFromFile
; so the patch ESP needs no new VMAD fills. See EnsureProperties.)

;================================================================================
; Init
;================================================================================
Event OnInit()
    EnsureProperties()
    DetectFrameworks()
    RegisterEvents()
    RegisterForSingleUpdateGameTime(TrackedUpdateIntervalHours)
EndEvent

; Self-heal for CK/ESP fills the patch ESP is missing or carries wrong:
; - The upstream ESP (through 1.0.0-b.1, which our patch ESP was built from)
;   filled the Spell property _FME_S_2T_Fetal with MGEF _FME_ME_2T_Fetal
;   (0x814) instead of SPEL _FME_S_2T_Fetal (0x802). The type mismatch makes
;   the VM drop the fill, so the property loads as None and second-trimester
;   fetal-movement effects silently never fire. Upstream fixed the fill in the
;   b.2 ESP; we fix it here at runtime so the patch ESP needs no xEdit rebuild.
; - _FMELastRank (0x877) is FMR-IE's own overlay delta-tracking faction; the
;   upstream b.2 bridge gained it as a CK property for cleanup. We resolve it
;   lazily instead of adding a VMAD fill.
; Auto property assignments persist in the save, and every call after the
; first is just cheap None-checks.
Function EnsureProperties()
    if _FME_S_2T_Fetal == none
        _FME_S_2T_Fetal = Game.GetFormFromFile(0x802, _espName) as Spell
    endIf
    if _fmeLastRank == none
        _fmeLastRank = Game.GetFormFromFile(0x877, _espName) as Faction
    endIf
EndFunction

; Public entry point — called by the MCM "Reset Player Effects" button
; (upstream 1.0.0-b.2). Opt-in only: the "stuck" signal is ambiguous
; (mid-recovery, between polls), so this never runs automatically.
Function ResetPlayerEffects()
    if PlayerRef == none
        return
    endIf
    CleanupEffects(PlayerRef)
    StorageUtil.UnsetFloatValue(PlayerRef, "FME.NextEffectTime")
    Debug.Notification("FME: Player effects reset")
EndFunction

; NOTE: no OnPlayerLoadGame here - Quest scripts never receive that event
; (it only reaches the player actor's aliases/effects). Mod-event
; registrations and the pending single-update survive save/load, and
; OnUpdateGameTime re-arms itself FIRST and re-detects frameworks each
; pass, so the bridge self-heals without a load hook.

Function RegisterEvents()
    UnregisterForAllModEvents()
    RegisterForModEvent("BeeingFemaleConception", "OnBeeingFemaleConception")
    RegisterForModEvent("BeeingFemaleLabor",      "OnBeeingFemaleLabor")
    RegisterForModEvent("BeeingFemale",           "OnBeeingFemaleStateChange")
EndFunction

Function DetectFrameworks()
    _hasSexLab = (Game.GetModByName("SexLab.esm") != 255)
    _hasOStim  = (Game.GetModByName("OStim.esp")  != 255)
EndFunction

;================================================================================
; BF system access
;================================================================================
FWSystem Function GetSystem()
    if _bfSystem == none
        _bfSystem = Game.GetFormFromFile(0x04000D62, "BeeingFemale.esm") as FWSystem
    endIf
    return _bfSystem
EndFunction

Float Function GetStateDuration(Int stateId, Actor a)
    FWSystem sys = GetSystem()
    if sys == none
        return 0.0
    endIf
    return sys.getStateDuration(stateId, a)
EndFunction

;================================================================================
; Rank derivation (used to pick which spell to cast — not written anywhere)
;
; Mirrors BeeingFemale.esm:BF_PregnancyTrackerFaction's rank semantics so the
; bridge's effect-roll bucketing stays in sync with the overlay's color bands.
;================================================================================
Int Function ComputeRank(Actor mother)
    Int stateId = StorageUtil.GetIntValue(mother, "FW.CurrentState", -1)
    if stateId < 0
        return 0
    endIf

    Float now        = Utility.GetCurrentGameTime()
    Float stateEnter = StorageUtil.GetFloatValue(mother, "FW.StateEnterTime", 0.0)

    if stateId == 4 || stateId == 5 || stateId == 6
        Float dur4  = GetStateDuration(4, mother)
        Float dur5  = GetStateDuration(5, mother)
        Float dur6  = GetStateDuration(6, mother)
        Float total = dur4 + dur5 + dur6
        if total <= 0.0
            return 1
        endIf
        Float elapsed = 0.0
        if stateId == 4
            elapsed = now - stateEnter
        elseIf stateId == 5
            elapsed = dur4 + (now - stateEnter)
        else
            elapsed = dur4 + dur5 + (now - stateEnter)
        endIf
        Int pct = ((elapsed / total) * 100.0) as Int
        if pct < 1
            pct = 1
        endIf
        if pct > 100
            pct = 100
        endIf
        return pct
    elseIf stateId == 7
        return 100
    elseIf stateId == 8
        Float duration = GetStateDuration(8, mother)
        if duration <= 0.0
            return 101
        endIf
        Int rec = (((now - stateEnter) / duration) * 14.0) as Int
        if rec < 0
            rec = 0
        endIf
        if rec > 14
            rec = 14
        endIf
        return 101 + rec
    endIf

    return 0
EndFunction

;================================================================================
; Effect dispatch
;================================================================================
Function RefreshActor(Actor mother)
    if mother == none
        return
    endIf
    EnsureProperties()
    Int prevRank = StorageUtil.GetIntValue(mother, "FME.Rank", 0)
    Int rank = ComputeRank(mother)

    ; FME.Rank is the contract between the bridge and the patched FMR-IE
    ; scripts (Overlays, RandEffChooser). The patched scripts read this
    ; StorageUtil key in place of the original GetFactionRank(GenericFaction)
    ; call, because BF NG's ParentFaction (the only BF-side tracking faction
    ; we point GenericFaction at) holds state IDs (-2..7), not the
    ; FMR-compatible 0..115 percentage band FMR-IE's banding logic expects.
    StorageUtil.SetIntValue(mother, "FME.Rank", rank)

    SendStatusEvent(mother, rank)

    ; Kick the overlay refresh while pregnant/recovering, and exactly ONCE
    ; when the rank drops to 0, so the overlay script's cleanup branches
    ; (elseif RCT <= 0) remove the stretchmark / areola textures. Gating the
    ; rank==0 case on prevRank avoids re-running NiOverride removals on every
    ; never-pregnant tracked NPC each poll.
    ; pconlyoverlay JSON flag (upstream b.2): 1 -> the player may be painted
    ; even without loaded 3D; anything else -> only 3D-loaded actors.
    Bool canOverlay = mother.Is3DLoaded()
    if !canOverlay && mother == PlayerRef
        canOverlay = (JsonUtil.GetIntValue("/FMEffects/Config.json", "pconlyoverlay", 10) == 1)
    endIf
    if (rank > 0 || prevRank != 0) && canOverlay && OverlayUpdater
        mother.AddSpell(OverlayUpdater, false)
    endIf

    if rank <= 0
        StorageUtil.UnsetFloatValue(mother, "FME.NextEffectTime")
        return
    endIf

    ; Skip random-effect rolls during active labor. ComputeRank pins labor
    ; to 100, which would otherwise fall through the T3 band and let fetal
    ; kicks, Braxton-Hicks, cravings, etc. fire while the actor is
    ; mid-delivery. The overlay update above still runs so the rank-driven
    ; visuals stay consistent.
    if StorageUtil.GetIntValue(mother, "FW.CurrentState", -1) == 7
        return
    endIf

    ; Decide whether to fire a random pregnancy effect on the same cadence
    ; the original FMR-IE bridge used.
    Float now        = Utility.GetCurrentGameTime()
    Float nextEffect = StorageUtil.GetFloatValue(mother, "FME.NextEffectTime", 0.0)

    if nextEffect == 0.0
        StorageUtil.SetFloatValue(mother, "FME.NextEffectTime", now + (Utility.RandomFloat(1.0, 3.0) / 24.0))
        return
    endIf
    if now < nextEffect
        return
    endIf

    ; Same key RandEffChooser and the MCM slider use, so retuning the rate in
    ; the MCM now affects the bridge too. (JsonUtil comes from PapyrusUtil,
    ; which the compile already imports for StorageUtil — no new dependency.)
    Int ticker = JsonUtil.GetIntValue("/FMEffects/Config.json", "ticker", 10)
    if Utility.RandomInt(1, ticker) < 3
        RollRandomEffect(mother, rank)
    endIf
    StorageUtil.SetFloatValue(mother, "FME.NextEffectTime", now + (Utility.RandomFloat(1.0, 4.0) / 24.0))
EndFunction

Function SendStatusEvent(Actor mother, Int rank)
    ; Recent FMR sends FMR_ActorStatus with FOUR args: (Form mother, int rank,
    ; string lastFather, int fatherRaceId). Papyrus silently drops a mod event
    ; whose arg list doesn't match the receiver's handler signature, so a
    ; third-party listener written against current FMR would never hear a
    ; 2-arg send. Mirror the shape, sourcing father data from BF NG state
    ; ("" / 0 when unknown; the race id is the Race form's FormID).
    String fatherName = ""
    Int fatherRaceId = 0
    Actor father = StorageUtil.FormListGet(mother, "FW.ChildFather", 0) as Actor
    if father
        fatherName = father.GetDisplayName()
    endIf
    Race fatherRace = StorageUtil.FormListGet(mother, "FW.ChildFatherRace", 0) as Race
    if fatherRace
        fatherRaceId = fatherRace.GetFormID()
    endIf

    Int h = ModEvent.Create("FMR_ActorStatus")
    if h
        ModEvent.PushForm(h, mother)
        ModEvent.PushInt(h, rank)
        ModEvent.PushString(h, fatherName)
        ModEvent.PushInt(h, fatherRaceId)
        ModEvent.Send(h)
    endIf
EndFunction

Bool Function IsActorInScene(Actor a)
    ; Scene-awareness was originally implemented via typed casts to
    ; OSexIntegrationMain / SexLabFramework. Keeping that here would force
    ; the patch to bundle OStim + SexLab source paths into its build, which
    ; the rest of the patch deliberately avoids. State-change events from BF
    ; NG are not normally fired mid-scene anyway, so this gate is left as a
    ; no-op. If you want strict scene-skip, subscribe to OStim/SexLab scene
    ; start/end mod events and maintain a small actor-in-scene set here.
    return false
EndFunction

Function RollRandomEffect(Actor a, Int rank)
    if IsActorInScene(a)
        return
    endIf

    Int roll = Utility.RandomInt(0, 3)

    if rank >= 1 && rank < 34
        if roll <= 1
            if _FME_S_1T_MornSick
                _FME_S_1T_MornSick.Cast(a, a)
            endIf
        else
            if _FME_S_Craving
                _FME_S_Craving.Cast(a, a)
            endIf
        endIf
    elseIf rank >= 34 && rank < 67
        if roll <= 1
            if _FME_S_2T_Fetal
                _FME_S_2T_Fetal.Cast(a, a)
            endIf
        else
            if _FME_S_Craving
                _FME_S_Craving.Cast(a, a)
            endIf
        endIf
    elseIf rank >= 67 && rank <= 100
        if roll == 0
            if _FME_S_3T_Fetal
                _FME_S_3T_Fetal.Cast(a, a)
            endIf
        elseIf roll == 1
            if _FME_S_3T_Braxton
                _FME_S_3T_Braxton.Cast(a, a)
            endIf
        elseIf roll == 2
            if _FME_S_3T_Colostrum
                _FME_S_3T_Colostrum.Cast(a, a)
            endIf
        else
            if _FME_S_Craving
                _FME_S_Craving.Cast(a, a)
            endIf
        endIf
    elseIf rank >= 101 && rank <= 115
        if roll <= 1 && _hasSexLab
            if _FME_S_3T_Lactation
                _FME_S_3T_Lactation.Cast(a, a)
            endIf
        elseIf roll == 2 || (roll <= 1 && !_hasSexLab)
            if _FME_S_3T_Colostrum
                _FME_S_3T_Colostrum.Cast(a, a)
            endIf
        else
            if _FME_S_Craving
                _FME_S_Craving.Cast(a, a)
            endIf
        endIf
    endIf
EndFunction

Function CleanupEffects(Actor a)
    if a == none
        return
    endIf
    EnsureProperties()
    if _FME_S_1T_MornSick
        a.DispelSpell(_FME_S_1T_MornSick)
    endIf
    if _FME_S_Craving
        a.DispelSpell(_FME_S_Craving)
    endIf
    if _FME_S_2T_Fetal
        a.DispelSpell(_FME_S_2T_Fetal)
    endIf
    if _FME_S_3T_Fetal
        a.DispelSpell(_FME_S_3T_Fetal)
    endIf
    if _FME_S_3T_Braxton
        a.DispelSpell(_FME_S_3T_Braxton)
    endIf
    if _FME_S_3T_Colostrum
        a.DispelSpell(_FME_S_3T_Colostrum)
    endIf
    if _FME_S_3T_Lactation
        a.DispelSpell(_FME_S_3T_Lactation)
    endIf
    if RandEffChooserSpell
        a.DispelSpell(RandEffChooserSpell)
    endIf
    if OverlayUpdater
        a.DispelSpell(OverlayUpdater)
    endIf

    ; Strip the NiOverride node overrides for every overlay slot the patched
    ; _FME_SC_Overlays may have painted (upstream b.2 fix). DispelSpell never
    ; touches these — they persist on the body node until something explicitly
    ; removes them, and the overlay script's own cleanup branch can't run for
    ; an unloaded actor. This was the bug that left stretchmarks on actors
    ; after birth.
    RemoveOverlay(a, "body", "bellystretch")
    RemoveOverlay(a, "body", "breaststretch")
    RemoveOverlay(a, "body", "darkernip")
    if a.Is3DLoaded()
        NiOverride.ApplyNodeOverrides(a)
    endIf

    ; Drop FMR-IE's own delta-tracking faction so a later pregnancy starts
    ; overlay tracking fresh.
    if _fmeLastRank && a.IsInFaction(_fmeLastRank)
        a.SetFactionRank(_fmeLastRank, 0)
        a.RemoveFromFaction(_fmeLastRank)
    endIf
EndFunction

; Same shape as the patched overlay script's remove path: only ever release a
; slot we previously claimed (tracked in StorageUtil), reset its texture to
; the neutral default, then forget the claim.
Function RemoveOverlay(Actor akActor, String bodyPart, String kind)
    String slotKey = "FME.Overlay." + kind + "." + bodyPart
    String nodeName = StorageUtil.GetStringValue(akActor, slotKey, "")
    if nodeName == ""
        return
    endIf
    Bool nodeSex = (akActor.GetLeveledActorBase().GetSex() == 1)
    NiOverride.RemoveAllNodeNameOverrides(akActor, nodeSex, nodeName)
    NiOverride.AddNodeOverrideString(akActor, nodeSex, nodeName, 9, 0, "textures\\Actors\\character\\Overlays\\default.dds", true)
    StorageUtil.UnsetStringValue(akActor, slotKey)
EndFunction

;================================================================================
; Periodic safety poll
;================================================================================
Event OnUpdateGameTime()
    ; Re-arm FIRST: if anything below errors out, the poll chain survives.
    RegisterForSingleUpdateGameTime(TrackedUpdateIntervalHours)
    ; Cheap; keeps the SexLab/OStim flags honest across load-order changes
    ; (no OnPlayerLoadGame is available on a Quest script to do it on load).
    DetectFrameworks()
    Int n = StorageUtil.FormListCount(none, "FW.SavedNPCs")
    Int i = 0
    while i < n
        Actor mother = StorageUtil.FormListGet(none, "FW.SavedNPCs", i) as Actor
        if mother && !mother.IsDead()
            RefreshActor(mother)
        endIf
        i += 1
    endWhile
EndEvent

;================================================================================
; BF NG mod event handlers
;================================================================================
Event OnBeeingFemaleConception(Form akMother, Int aiChildCount, Form akFather0, Form akFather1, Form akFather2)
    Actor m = akMother as Actor
    if m
        RefreshActor(m)
    endIf
EndEvent

Event OnBeeingFemaleLabor(Form akMother, Int aiChildCount, Form akFather0, Form akFather1, Form akFather2)
    Actor m = akMother as Actor
    if m == none
        return
    endIf

    Int childCount = StorageUtil.GetIntValue(m, "FW.NumChilds", 0)
    Float hp       = StorageUtil.GetFloatValue(m, "FW.UnbornHealth", 100.0)
    if childCount <= 0 || hp <= 0.0
        Int hMis = ModEvent.Create("FMR_BabyMiscarriage")
        if hMis
            ModEvent.PushForm(hMis, m)
            ModEvent.PushString(hMis, "BF_Stillbirth")
            ModEvent.Send(hMis)
        endIf
    endIf

    RefreshActor(m)
EndEvent

Event OnBeeingFemaleStateChange(string eventName, string strArg, float numArg, Form sender)
    ; Filter early. BF NG fires "BeeingFemale" for many command verbs
    ; (AddSperm, AddContraception, ChangeState, InfoBox, TestScale, ...);
    ; we only care about the cycle-progress signals.
    if strArg != "Update" && strArg != "CheckAbortus"
        return
    endIf

    ; BF emits these via free-standing SendModEvent from FWController, so
    ; `sender` is the Controller quest, not the actor. The actor's FormID
    ; comes through numArg. Fall back to that when the sender cast fails.
    Actor m = sender as Actor
    if m == none
        Int formId = numArg as Int
        if formId != 0
            m = Game.GetForm(formId) as Actor
        endIf
    endIf
    if m == none
        return
    endIf

    if strArg == "CheckAbortus"
        Float hp = StorageUtil.GetFloatValue(m, "FW.UnbornHealth", 100.0)
        Int hDmg = ModEvent.Create("FMR_BabyDamage")
        if hDmg
            ModEvent.PushForm(hDmg, m)
            ModEvent.PushInt(hDmg, 0)
            ModEvent.PushInt(hDmg, hp as Int)
            ModEvent.Send(hDmg)
        endIf
        if hp <= 0.0
            Int hDeath = ModEvent.Create("FMR_BabyDeath")
            if hDeath
                ModEvent.PushForm(hDeath, m)
                ModEvent.PushString(hDeath, "BF_BabyHealthZero")
                ModEvent.Send(hDeath)
            endIf
        endIf
        return
    endIf

    ; "Update": refresh rank / cleanup based on current cycle state.
    Int stateId = StorageUtil.GetIntValue(m, "FW.CurrentState", -1)

    if stateId == 0 || stateId == 1 || stateId == 2 || stateId == 3
        ; Only tear down when there was something to tear down - "Update"
        ; fires for never-pregnant women too, and CleanupEffects alone is
        ; nine DispelSpell calls.
        if StorageUtil.GetIntValue(m, "FME.Rank", 0) != 0
            CleanupEffects(m)
            StorageUtil.UnsetFloatValue(m, "FME.NextEffectTime")
            StorageUtil.SetIntValue(m, "FME.Rank", 0)
            SendStatusEvent(m, 0)
            ; Trigger an OverlayUpdater pass now so the stretchmark / areola
            ; textures get cleaned up immediately rather than lingering until
            ; the next 1.5h poll catches the rank=0 state.
            if (m.Is3DLoaded() || m == PlayerRef) && OverlayUpdater
                m.AddSpell(OverlayUpdater, false)
            endIf
        endIf
        return
    endIf

    if stateId == 4 || stateId == 5 || stateId == 6 || stateId == 7 || stateId == 8
        RefreshActor(m)
    endIf
EndEvent
