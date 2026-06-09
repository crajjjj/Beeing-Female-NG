Scriptname	FMA_HandlerQuestScript	extends	Quest  
import StorageUtil


;GlobalVariable	Property	PollingInterval					Auto
;GlobalVariable	Property	PregnancyDuration				Auto

Actor			Property	PlayerRef						Auto
Actor[]			Property	QuestStarters					Auto	Hidden
Faction			Property	FMA_AnnouncementBlockerFaction	Auto  
Faction			Property	FMA_GenericPregFaction			Auto  
Faction			Property	FMA_NonPlayerPregFaction		Auto  
Faction			Property	FMA_PlayerPregFaction		Auto  
Faction			Property	FMA_PlayerParentFaction		Auto  
Float[]			Property	NextStagePercentage				Auto	Hidden
int				Property	QuestStartThreshold				Auto
Int[]			Property	StageList						Auto	Hidden
Quest			Property	FMA_GenericDialogueQuest		Auto  
Quest			Property	FMA_PlayerTrackingQuest			Auto  
Quest Property FMA_SpouseQuest  Auto  
Quest[]			Property	Quests							Auto	Hidden	; the CK won't try to autofill hidden properties
Spell			Property	FMA_UpdateSpell					Auto	; subhuman- new spell, when added to player forces your arrays to update
FormList Property FMA_AnnouncementQueueList  Auto  

FWSystem		BeeingFemaleSystem
Float			Property	TrackedUpdateIntervalHours = 3.0	Auto	Hidden



event	GoForInit()

    FMA_PlayerTrackingQuest.SetStage(0)
    FMA_SpouseQuest.SetStage(0)
    FMA_GenericDialogueQuest.Start()
	PlayerLoadedGame()	; everything in there is common to both, so no need to duplicate it.

endEvent

event	PlayerLoadedGame()
	UnregisterForAllModEvents()	;	probably unnecessary, but since we're going to reregister it doesn't hurt to make sure
								;	nothing is accidentally carried over

	RegisterForModEvent("BeeingFemaleLabor", "OnBeeingFemaleLabor")
	RegisterForModEvent("BeeingFemaleConception", "OnBeeingFemaleConception")
	RegisterForModEvent("BeeingFemale", "OnBeeingFemaleStateChange")

	RegisterForSingleUpdateGameTime(TrackedUpdateIntervalHours)
endEvent


;Event OnUpdateGameTime()
;Daily Maintenance
	;Check if there are pregnant women who haven't announced yet
	;If FMA_AnnouncementQueueList.GetSize() >= 1 && FMA_LetterQuest.IsRunning() == 0
		;FMA_LetterQuest.Start()
	;EndIf
	;RegisterForSingleUpdateGameTime(24)
;EndEvent


Event OnUpdateGameTime()
	UpdateTrackedFemaleFactions()
	RegisterForSingleUpdateGameTime(TrackedUpdateIntervalHours)
EndEvent

function UpdateTrackedFemaleFactions()
	int trackedCount = StorageUtil.FormListCount(none, "FW.SavedNPCs")
	int i = 0
	while i < trackedCount
		Actor mother = StorageUtil.FormListGet(none, "FW.SavedNPCs", i) as Actor
		if mother && !mother.IsDead()
			UpdateTrackedFemaleRank(mother)
		endif
		i += 1
	endWhile
endFunction

function UpdateTrackedFemaleRank(Actor mother)
	if mother == none
		return
	endif

	int stateId = StorageUtil.GetIntValue(mother, "FW.CurrentState", -1)
	if stateId == -1
		mother.RemovefromFaction(TrackedFemFaction)
		return
	endif

	; State IDs: 0 pre-ovulation, 1 ovulation, 2 luteal, 3 menstruation,
	; 4/5/6 trimesters, 7 labor pains, 8 recovery, 20 full-term pregnancy.
	; Rank formulas:
	; - Pregnancy (4/5/6/20): ((now - LastConception) / PregnancyDuration) * 100, clamped 1..127
	;   (min 1 so FA's temple test "rank <= 0 = not pregnant" reads correctly right after conception)
	; - Labor (7): rank = 127 (still pregnant until baby is delivered)
	; - Recovery (8): rank = -85 - recoveryProgress, where recoveryProgress is 0..36
	; - Cycle (0/1/2/3): rank = (stateId * -10) - 5
	int rank = 0
	float now = Utility.GetCurrentGameTime()

	if (stateId == 4) || (stateId == 5) || (stateId == 6) || (stateId == 20)
		float lastConception = StorageUtil.GetFloatValue(mother, "FW.LastConception", 0.0)
		float duration = GetBeeingFemalePregnancyDuration(mother)
		if duration <= 0.0
			duration = 1.0
		endif
		int pct = (((now - lastConception) / duration) * 100.0) as int
		if pct < 1
			pct = 1
		endif
		if pct > 127
			pct = 127
		endif
		rank = pct
	elseIf stateId == 7
		rank = 127
	elseIf stateId == 8
		float stateEnter = StorageUtil.GetFloatValue(mother, "FW.StateEnterTime", 0.0)
		float duration = GetBeeingFemaleStateDuration(8, mother)
		if duration <= 0.0
			duration = 1.0
		endif
		int recoveryProgress = (((now - stateEnter) / duration) * 36.0) as int
		if recoveryProgress < 0
			recoveryProgress = 0
		endif
		if recoveryProgress > 36
			recoveryProgress = 36
		endif
		rank = -85 - recoveryProgress
	elseIf (stateId == 0) || (stateId == 1) || (stateId == 2) || (stateId == 3)
		rank = (stateId * -10) - 5
	else
		rank = 0
	endif

	mother.SetFactionRank(TrackedFemFaction, rank)
endFunction

float function GetBeeingFemaleStateDuration(int stateId, Actor mother)
	FWSystem sys = GetBeeingFemaleSystem()
	if sys == none
		return 0.0
	endif
	return sys.getStateDuration(stateId, mother)
endFunction

float function GetBeeingFemalePregnancyDuration(Actor mother)
	return GetBeeingFemaleStateDuration(4, mother) + GetBeeingFemaleStateDuration(5, mother) + GetBeeingFemaleStateDuration(6, mother)
endFunction

FWSystem function GetBeeingFemaleSystem()
	if BeeingFemaleSystem == none
		BeeingFemaleSystem = Game.GetFormFromFile(0x04000D62, "BeeingFemale.esm") as FWSystem
	endif
	return BeeingFemaleSystem
endFunction





event OnBeeingFemaleConception(Form akMother, int aiChildCount, Form akFather0, Form akFather1, Form akFather2)

	; akMother is the woman in question and can be cast to an Actor object
	; akFather0..2 are the fathers (if known)

	If (akFather0 == PlayerRef) || (akFather1 == PlayerRef) || (akFather2 == PlayerRef)
		(akMother as Actor).SetFactionRank(FMA_PlayerPregFaction, 1)
		FMA_AnnouncementQueueList.AddForm(akMother as Actor)
	EndIf

	UpdateTrackedFemaleRank(akMother as Actor)
endEvent  


event OnBeeingFemaleLabor(Form akMother, int aiChildCount, Form akFather0, Form akFather1, Form akFather2)

	; akMother is the woman in question and can be cast to an Actor object

	;Removal of factions used to control pregnancy related dialogue.

	; subhuman- don't even bother checking if they're in faction first, just do it.   Won't throw errors.
	If (akMother as Actor).GetFactionRank(FMA_PlayerPregFaction) == 1
		(akMother as Actor).SetFactionRank(FMA_PlayerParentFaction, 1)
	Endif

	FMA_AnnouncementQueueList.RemoveAddedForm(akMother as Actor)

	(akMother as Actor).RemovefromFaction(FMA_PlayerPregFaction)
	(akMother as Actor).RemovefromFaction(FMA_AnnouncementBlockerFaction)

	UpdateTrackedFemaleRank(akMother as Actor)

endEvent



; BF sends "Update" on the "BeeingFemale" channel after every NPC ChangeState
; (FWController.psc:1870), with numArg = the NPC's FormID. Refresh the rank
; immediately rather than waiting for the 3-hour polling tick.
event OnBeeingFemaleStateChange(string eventName, string strArg, float numArg, Form sender)
	if strArg == "Update"
		Actor target = Game.GetForm(numArg as int) as Actor
		if target
			UpdateTrackedFemaleRank(target)
		endif
	endif
endEvent

Faction Property TrackedFemFaction  Auto  

Quest Property FMA_LetterQuest  Auto  
