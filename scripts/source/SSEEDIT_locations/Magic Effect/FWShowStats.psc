Scriptname FWShowStats extends ActiveMagicEffect  

FWController property Controller auto
int property Magnetude = 100 auto
actor ActorRef;=none
bool bInit;=false

Actor Property PlayerRef Auto
FWSystem property System auto
Spell Property BeeingFemaleSpell Auto
Spell Property BeeingMaleSpell Auto
MagicEffect Property BeingMaleEffect Auto
MagicEffect Property BeeingFemaleEffect Auto
FWSystemConfig property cfg auto
GlobalVariable Property GameDaysPassed Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	 ;Tkc (Loverslab): commented checks because for aimed Show stats spell the script even will not be executed and for added Show Player info spell target will be Player
	;if akTarget;/!=none/; ;Tkc (Loverslab) , checks swapped
		ActorRef = akTarget
		execute()
	;else;if !akTarget; && akCaster.GetAngleX()>85 ;Tkc (Loverslab) : will be player if no npc in target without any angles
		;ActorRef = Game.GetPlayer()
		;execute()
	;endif
endEvent

Event OnInit()
	bInit=true
	execute()
endEvent

function execute()
	;if !ActorRef || bInit==false
	if ActorRef ;Tkc (Loverslab) optimization
	else;if !ActorRef
		return
	endif
	if bInit ;Tkc (Loverslab) optimization
	else;if bInit==false
		return
	endif
	
	;Tkc (Loverslab): do not execute when giving birth to prevent game freeze ; fix for problem when game was freezing in time of attemps to show stats while target was giving birth
	if StorageUtil.FormListFind(none,"FW.GivingBirth", ActorRef) == -1
	else
		;debug.trace("BF: Showstats spell - actor giving birth. Returning.")
		return
	endif
	
	if ActorRef == PlayerRef ;Tkc (Loverslab) : skip spell checking when player because it is reseting player
	else
	;;;;
	spell BFspell = BeeingFemaleSpell ;Tkc (Loverslab): optimization
	If ActorRef.HasSpell(BFspell)
		if ActorRef.HasMagicEffect(BeeingFemaleEffect) ;Tkc (Loverslab) optimization
		else;if !ActorRef.HasMagicEffect(Controller.System.BeeingFemaleSpell.GetNthEffectMagicEffect(0))
			ActorRef.RemoveSpell(BFspell)
		endif
	endif
	spell BMspell = BeeingMaleSpell ;Tkc (Loverslab): optimization
	if ActorRef.HasSpell(BMspell)
		if ActorRef.HasMagicEffect(BeingMaleEffect) ;Tkc (Loverslab) optimization
		else;if !ActorRef.HasMagicEffect(Controller.System.BeeingMaleSpell.GetNthEffectMagicEffect(0))
			ActorRef.RemoveSpell(BMspell)
		endif
	endif
	
	If !ActorRef.HasSpell(BFspell) && System.IsValidateFemaleActor(ActorRef) ;Tkc (Loverslab) optimization. changed IsValidateActor to IsValidateFemaleActor to make check faster
		System.ActorAddSpell(ActorRef, BFspell, false, false, false)
	else;if !ActorRef.HasSpell(Controller.System.BeeingMaleSpell) && Controller.System.IsValidateMaleActor(ActorRef)
		if ActorRef.HasSpell(BMspell) ;Tkc (Loverslab) optimization
		else;if !ActorRef.HasSpell(Controller.System.BeeingMaleSpell)
			if System.IsValidateMaleActor(ActorRef)
				if ActorRef.HasMagicEffect(BeingMaleEffect) ;Tkc (Loverslab) optimization
				else;if !ActorRef.HasMagicEffect(Controller.System.BeeingMaleSpell.GetNthEffectMagicEffect(0))
					ActorRef.RemoveSpell(BMspell)
				endif
				System.ActorAddSpell(ActorRef, BMspell, false, false, false) ;Tkc (Loverslab) fixed incorrect execution order after optimizations. Also fixed error about incorrect number of arguments
			endif
		endif
	endif
	;;;;
	endif
	
	;int Magnetude = GetMagnitude() as int
	Controller.showRankedInfoBox(ActorRef, Magnetude)
	;UI.OpenCustomMenu("beeingfemale/info_spell.swf");
	;if ActorRef.GetLeveledActorBase();/!=none/;
	;	if ActorRef.GetLeveledActorBase().GetSex()==0
	;		return
	;	endif
	;endif
	if cfg.Messages==0
		if ActorRef as FWChildActor ;/!=none/;
			printChildInformations()
		else
			if ActorRef.GetLeveledActorBase();/!=none/;
				if ActorRef.GetLeveledActorBase().GetSex()==0
					printMaleInformations()
				else
					printFemaleInformations()
				endif
			endif
		endif
	endif
endFunction

function PrintLinked()
	int cChain=ActorRef.countLinkedRefChain()
	int i=0
	ObjectReference lnkRef = ActorRef.GetLinkedRef()
	if lnkRef;/!=none/;
		Debug.Trace("Linked References: " + lnkRef.GetName() + " [" + lnkRef.GetFormID() + "]")
	else
		Debug.Trace("Linked References: <NONE>")
	endif
	Debug.Trace("Linked Ref Chains: " + cChain)
	while i<cChain
		ObjectReference lnk = ActorRef.GetNthLinkedRef(i)
		Debug.Trace(i + ": " + lnk.GetName() + " [" + lnk.GetFormID() + "]")
		i+=1
	endWhile
endFunction

function printChildInformations()
	if ActorRef.GetLeveledActorBase();/!=none/;
		Debug.Trace("BeeingChild Saved Data for: "+ActorRef.GetLeveledActorBase().GetName());
	else
		Debug.Trace("BeeingChild Saved Data for: "+ActorRef.GetName());
	endif
	Debug.Trace("Child Name: "+StorageUtil.GetStringValue(ActorRef,"FW.Child.Name",""))
	Debug.Trace("Child last Update: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.LastUpdate",0))
	actor Mother = StorageUtil.GetFormValue(ActorRef,"FW.Child.Mother") as actor
	actor Father = StorageUtil.GetFormValue(ActorRef,"FW.Child.Father") as actor
	if Mother;/!=none/;
		if Mother.GetLeveledActorBase();/!=none/;
			Debug.Trace("Mother: "+Mother.GetLeveledActorBase().GetName())
		else
			Debug.Trace("Mother: #"+Mother.GetName())
		endif
	else
		Debug.Trace("Mother: <NONE>")
	endif
	if Father;/!=none/;
		if Father.GetLeveledActorBase();/!=none/;
			Debug.Trace("Father: "+Father.GetLeveledActorBase().GetName())
		else
			Debug.Trace("Father: #"+Father.GetName())
		endif
	else
		Debug.Trace("Father: <NONE>")
	endif
	Debug.Trace("Level: "+StorageUtil.GetFloatValue(ActorRef, "FW.Child.Level"))
	Debug.Trace("Experience: "+StorageUtil.GetFloatValue(ActorRef, "FW.Child.StatExperience"))
	Debug.Trace("Stats:")
	Debug.Trace("Comprehension: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.StatComprehension"))
	Debug.Trace("Destruction: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.StatDestruction"))
	Debug.Trace("Illusion: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.StatIllusion"))
	Debug.Trace("Conjuration: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.StatConjuration"))
	Debug.Trace("Restoration: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.StatRestoration"))
	Debug.Trace("Alteration: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.StatAlteration"))
	Debug.Trace("Block: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.StatBlock"))
	Debug.Trace("OneHanded: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.StatOneHanded"))
	Debug.Trace("TwoHanded: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.StatTwoHanded"))
	Debug.Trace("Marksman: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.StatMarksman"))
	Debug.Trace("Sneak: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.StatSneak"))
	Debug.Trace("Magicka: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.StatMagicka"))
	Debug.Trace("CarryWeight: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.StatCarryWeight"))
	Debug.Trace("Health: " + StorageUtil.GetFloatValue(ActorRef,"FW.Child.StatHealth"))
	Debug.Trace("Perks:")
	int sc = StorageUtil.FormListCount(ActorRef,"FW.Child.Perks")
	while sc>0
		sc-=1
		spell s = StorageUtil.FormListGet(ActorRef,"FW.Child.Perks",sc) as spell
		if s;/!=none/;
			Debug.Trace(s.GetName())
		else
			Debug.Trace("Unknown Perk")
		endif
	endWhile
	
	PrintLinked()
	
	Debug.Trace("-----------------------------------------------------------------")
endfunction

function printMaleInformations()
	if ActorRef.GetLeveledActorBase();/!=none/;
		Debug.Trace("BeeingMale Saved Data for: "+ActorRef.GetLeveledActorBase().GetName());
	else
		Debug.Trace("BeeingMale Saved Data for: "+ActorRef.GetName());
	endif
	PrintLinked()
	
	Debug.Trace("-----------------------------------------------------------------")
endfunction

function printFemaleInformations()
	int i=0
	int cChildFather=StorageUtil.FormListCount(ActorRef,"FW.ChildFather")
	int cSpermTime=StorageUtil.FloatListCount(ActorRef,"FW.SpermTime")
	int cSpermName=StorageUtil.FormListCount(ActorRef,"FW.SpermName")
	int cSpermAmmount=StorageUtil.FloatListCount(ActorRef,"FW.SpermAmount")
	int cBornChildFather=StorageUtil.FormListCount(ActorRef,"FW.BornChildFather")
	int cBornChildTime=StorageUtil.FloatListCount(ActorRef,"FW.BornChildTime")
	Debug.Trace("-----------------------------------------------------------------")
	if ActorRef.GetLeveledActorBase();/!=none/;
		Debug.Trace("BeeingFemale Saved Data for: "+ActorRef.GetLeveledActorBase().GetName());
	else
		Debug.Trace("BeeingFemale Saved Data for: #"+ActorRef.GetName());
	endif
	Debug.Trace("Current Game Time: "+ GameDaysPassed.GetValue())
	Debug.Trace("-----------------------------------------------------------------")
	Debug.Trace(" FW.LastUpdate :  "+StorageUtil.GetFloatValue(ActorRef,"FW.LastUpdate"))
	Debug.Trace(" FW.StateEnterTime :  "+StorageUtil.GetFloatValue(ActorRef,"FW.StateEnterTime")+" ["+ FWUtility.GetTimeString(GameDaysPassed.GetValue() - StorageUtil.GetFloatValue(ActorRef,"FW.StateEnterTime")) +"]")
	Debug.Trace(" FW.CurrentState :  "+StorageUtil.GetIntValue(ActorRef,"FW.CurrentState"))
	Debug.Trace(" FW.Abortus :  "+StorageUtil.GetIntValue(ActorRef,"FW.Abortus"))
	Debug.Trace(" FW.AbortusTime :  "+StorageUtil.GetFloatValue(ActorRef,"FW.AbortusTime")+" ["+ FWUtility.GetTimeString(GameDaysPassed.GetValue() - StorageUtil.GetFloatValue(ActorRef,"FW.AbortusTime")) +"]")
	Debug.Trace(" FW.UnbornHealth :  "+StorageUtil.GetFloatValue(ActorRef,"FW.UnbornHealth"))
	Debug.Trace(" FW.NumChilds :  "+StorageUtil.GetIntValue(ActorRef,"FW.NumChilds"))
	i=0
	while i<cChildFather
		actor a = StorageUtil.FormListGet(ActorRef,"FW.ChildFather",i) as Actor
		if a;/!=none/;
			if a.GetLeveledActorBase();/!=none/;
				Debug.Trace(" FW.ChildFather["+i+"] :  "+a.GetLeveledActorBase().GetName())
			else
				Debug.Trace(" FW.ChildFather["+i+"] :  #"+a.GetName())
			endif
		endif
		i+=1
	endwhile
	i=0
	while i<cSpermTime
		Debug.Trace(" FW.SpermTime["+i+"] :  "+StorageUtil.FloatListGet(ActorRef,"FW.SpermTime",i)+" ["+ FWUtility.GetTimeString(GameDaysPassed.GetValue() - StorageUtil.FloatListGet(ActorRef,"FW.SpermTime",i)) +"]")
		i+=1
	endwhile
	i=0
	while i<cSpermName
		actor a = StorageUtil.FormListGet(ActorRef,"FW.SpermName",i) as Actor
		if a;/!=none/;
			if a.GetLeveledActorBase();/!=none/;
				Debug.Trace(" FW.SpermName["+i+"] :  "+a.GetLeveledActorBase().GetName())
			else
				Debug.Trace(" FW.SpermName["+i+"] :  #"+a.GetName())
			endif
		endif
		i+=1
	endwhile
	i=0
	while i<cSpermAmmount
		Debug.Trace(" FW.SpermAmount["+i+"] :  "+StorageUtil.FloatListGet(ActorRef,"FW.SpermAmount",i))
		i+=1
	endwhile
	Debug.Trace(" FW.Flags :  "+StorageUtil.GetIntValue(ActorRef,"FW.Flags"))
	Debug.Trace(" FW.PainLevel :  "+StorageUtil.GetFloatValue(ActorRef,"FW.PainLevel"))
	Debug.Trace(" FW.Contraception :  "+StorageUtil.GetFloatValue(ActorRef,"FW.Contraception"))
	Debug.Trace(" FW.ContraceptionTime :  "+StorageUtil.GetFloatValue(ActorRef,"FW.ContraceptionTime")+" ["+ FWUtility.GetTimeString(GameDaysPassed.GetValue() - StorageUtil.GetFloatValue(ActorRef,"FW.ContraceptionTime")) +"]")
	Debug.Trace(" FW.NumBirth :  "+StorageUtil.GetIntValue(ActorRef,"FW.NumBirth"))
	Debug.Trace(" FW.NumBabys :  "+StorageUtil.GetIntValue(ActorRef,"FW.NumBabys"))
	Debug.Trace(" FW.PauseTime :  "+StorageUtil.GetFloatValue(ActorRef,"FW.PauseTime")+" ["+ FWUtility.GetTimeString(GameDaysPassed.GetValue() - StorageUtil.GetFloatValue(ActorRef,"FW.PauseTime")) +"]")
	Debug.Trace(" FW.LastBornChildTime :  "+StorageUtil.GetFloatValue(ActorRef,"FW.LastBornChildTime")+" ["+ FWUtility.GetTimeString(GameDaysPassed.GetValue() - StorageUtil.GetFloatValue(ActorRef,"FW.LastBornChildTime")) +"]")
	i=0
	while i<cBornChildFather
		actor a = StorageUtil.FormListGet(ActorRef,"FW.BornChildFather",i) as Actor
		if a;/!=none/;
			if a.GetLeveledActorBase();/!=none/;
				Debug.Trace(" FW.BornChildFather["+i+"] :  "+a.GetLeveledActorBase().GetName())
			else
				Debug.Trace(" FW.BornChildFather["+i+"] :  #"+a.GetName())
			endif
		endif
		i+=1
	endwhile
	i=0
	while i<cBornChildTime
		Debug.Trace(" FW.BornChildTime["+i+"] :  "+StorageUtil.FloatListGet(ActorRef,"FW.BornChildTime",i)+" ["+ FWUtility.GetTimeString(GameDaysPassed.GetValue() - StorageUtil.FloatListGet(ActorRef,"FW.BornChildTime",i)) +"]")
		i+=1
	endwhile
	
	PrintLinked()
	
	Debug.Trace("-----------------------------------------------------------------")
endFunction

; 04.06.2019 ;Tkc (Loverslab) optimizations here because quite slow in game. Other changes marked with "Tkc (Loverslab)" comment
;	Also added same spell but only for Player because by BF autor was planned to use Show All Stats spell to show Player stats
;	when no target on spell but aimed spell will not execute effect with script if was no hit with any targed and script working only for npcs: 
;	CK Magic effect Wiki: Aimed: Effect is attached to a Projectile which is then fired at the crosshairs. If it makes contact with a valid target, the effect is applied.
;	Added Show Player Info spell of Self type will be working on player and will show Player info.
;	found problem when game was freezing on blured screen wich this spell making before show stats, when playing animation of giving birth, 
;	need to add in esp condition wich will prevent start of effects and this script when player woman giving birth. 
;	For fix this freeze was added FW.GivingBirth Formlist and additional condition here to check if mother is giving birth(added in the formlist) then return
