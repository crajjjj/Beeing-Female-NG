Scriptname FWSystem extends Quest  
import FWUtility
import FWVersion

;--------------------------------------------------------------------------------
; Quest Objectives / Beeing Female States
;--------------------------------------------------------------------------------
;  0 -  3		Zyklus
;  4 -  8		Normal pregnancy
;  9 - 19		<reserved>
; 20 - 39		Pregnant from other mod
; 40 - 49		<none>
; 50 - 69		<reserved - thought about abortus states>
; 70 - 89		<none>
; 90 - 99		Being female / Being male (/ Being child / Being creature / ...)


FWSaveLoad property Data auto
FWAddOnManager property Manager auto
FWSystemConfig property cfg auto
FWTextContents property Content auto
FWBabyItemList Property BabyItemList Auto
FWController property Controller auto

Globalvariable property ModEnabled auto
Globalvariable property CloakingSpellEnabled auto
Globalvariable property GlobalPlayerState auto
Globalvariable property GlobalPlayerStatePercent auto
GlobalVariable property GlobalMenstruating auto
FWChildSettings property ChildSettings auto
Imagespacemodifier property MenuImageSpace auto

FWStateWidget property StateWidget auto
FWContraceptionWidget property ContraceptionWidget auto
FWBabyHealthWidget property BabyHealthWidget auto
FWWidgetController property WidgetController auto
FWPantyWidget property PantyWidget auto
FWCoupleWidget property CoupleWidget auto
FWProgressWidget property Progress auto
int Property lastStage auto hidden
float EggTravelingDuration_Percentage = 0.7
int PlayerBleedOut

float property Version auto
float _version ;Bane -> Appears to be Unused

; Some Items and store properties
armor property Sanitary_Napkin_Normal auto
armor property Sanitary_Napkin_Bloody auto
armor property Tampon_Normal auto
armor property Tampon_Bloody auto
potion property ContraceptionLow auto
potion property ContraceptionMid auto
Scroll property CallChildren1 auto
Scroll property CallChildren2 auto
float lastStoreUpdate

ImageSpaceModifier property DefaultBlur auto
Activator Property MaraShrineObject Auto ; God of love and marriage
Activator Property ArkayShrineObject Auto ; God of birth and death

Spell Property BeeingFemaleSpell Auto
Spell Property BeeingMaleSpell Auto
FWAbilityBeeingFemale Property Player Auto hidden
FWAbilityBeeingMale Property PlayerMale Auto hidden

ImageSpaceModifier Property AbortusImod  Auto
ImageSpaceModifier Property AbortusFever Auto
Imagespacemodifier property iModPainLow auto
Imagespacemodifier property iModPainMiddle auto
Imagespacemodifier property iModPainHigh auto

Faction property FollowerFaction = none auto
Faction property ChildFollowerFaction auto ; Reserved for Current Follower
Faction property ChildFollowerFaction2 = none auto ; Reserved for Potential Follower
Faction property ChildFollowerFaction3 = none auto ; Reserved for HearthFires Adopting
Faction property ChildFollowerFaction4 = none auto ; Free
Faction property ChildFollowerFaction5 = none auto ; Free
Faction property ParentFaction auto
Faction property PlayerMarriedFaction auto

int property ChildFollowerFactionRank = 0 auto
int property ChildFollowerFactionRank2 = 0 auto
int property ChildFollowerFactionRank3 = 0 auto
int property ChildFollowerFactionRank4 = 0 auto
int property ChildFollowerFactionRank5 = 0 auto

spell[] Property StatCycleID_List Auto
spell Property StatMenstruationCycle Auto
spell Property StatPregnancyCycle Auto

spell property BeeingFemaleInfoSpell auto
spell[] property BeeingFemaleInfoSpellExtra auto
spell property InfectionSpell auto
spell property FeverSpell auto

spell property Effect_Mittelschmerz auto
spell property Effect_MenstruationCramps auto
spell property Effect_Vorwehen auto
spell property Effect_Eroeffnungswehen auto
spell property Effect_Presswehen auto
spell property Effect_Nachwehen auto

spell property Effect_VaginalBloodLow auto
spell property Effect_VaginalBloodHigh auto
spell property Effect_VaginalBloodBig auto
spell property Effect_BreastMilk1 auto
spell property Effect_BreastMilk2 auto
spell property Effect_BreastMilk3 auto

Armor Property AmnioticFluid Auto
Armor Property VaginalBleeding Auto

book[] Property PlayerBooks Auto
Scroll[] property StartUpScrolls auto
FormList Property BadSpellList Auto
MagicEffect[] property BabyHealingMagicEffects auto

spell property ChaurusBreeder = none Auto hidden
bool property EstrusActive = false Auto hidden
Faction property zzEstrusChaurusBreederFaction = none auto hidden
armor property DeviceBelt = none auto hidden
bool property DeviceActive = false auto hidden
bool property HearthFiresActive = true auto hidden ; Skyrim SE has HearthFires

formlist property Pill_Items auto
MagicEffect property Pill_Effect auto
float property MaxContraception = 98.0 AutoReadOnly hidden
float property MaxContraceptionTime = 2.0 AutoReadOnly hidden

formlist property WashOut_List auto
MagicEffect property WashOut_Effect auto

soulgem property BabyGem auto

race[] property MountableRace auto

int lastStage=-1

Int Property MSG_All = 0 AutoReadOnly hidden 		; Only when set to 'All Messages'
Int Property MSG_Debug = 1 AutoReadOnly hidden		; Send a debug message
Int Property MSG_High = 2 AutoReadOnly hidden		; High Information Level
Int Property MSG_Low = 3 AutoReadOnly hidden		; Low Information Level
Int Property MSG_Immersive = 4 AutoReadOnly hidden	; Imersive Messaage
Int Property MSG_Error = 5 AutoReadOnly hidden		; Important error message
Int Property MSG_Always = 99 AutoReadOnly hidden	; This message will be shown always

int property MSG_Note = 0 AutoReadonly hidden		; Debug.Notification
int property MSG_Box = 1 AutoReadonly hidden 		; Debug.MessageBox
int property MSG_Trace = 2 AutoReadonly hidden		; Debug.Trace


int[] property CheatAddFather auto hidden
int property MaxBabyPregnantWith = 6 autoreadonly hidden

FWAbilityBeeingFemale[] property FWCached auto hidden
int FWCacheID=0
int FWCacheMax = 15

Quest property ChildFinder auto
bool bFirstRun=true
bool animationsOK=true
bool bInitDone=false

bool bMessageEnabledAfterNewGameStarted=false
int property LoadState auto hidden
int property UpdateState auto hidden

Keyword Property zad_DeviousBelt Auto

Actor Property PlayerRef Auto ;Tkc (Loverslab): added to make execution faster in some places. Script has no added property with this name

Keyword Property IsBeastRace Auto
GlobalVariable Property GameDaysPassed Auto
Keyword Property ActorTypeCreature Auto
Quest Property MQ101 Auto
Keyword Property ActorTypeGhost Auto
Faction Property BYOHRelationshipAdoptableFaction Auto
Faction Property BYOHRelationshipAdoptionFaction Auto

FormList property ForbiddenFactions auto
FormList property ForbiddenKeywords auto
FormList property ForbiddenRaces auto

Spell Property _BF_DefaultCustomChildSpell Auto

function ActorAddSpellOpt(actor a,Spell s, bool PlayerOnly = false, bool bIsCast = false, bool ShowMsg = true) ;Bane --> Edited to allow Spells to be cast in None Locations (Mostly Widerness)
	;if s;/!=none/; && a;/!=none/;
	if s ;Tkc (Loverslab): optimization
	  if a
		;if ( !PlayerOnly || Game.GetPlayer() == a ) && !a.HasSpell(s)
		if ( !PlayerOnly || PlayerRef == a )
		 if a.HasSpell(s) ;Tkc (Loverslab): optimization
		 else;if !a.HasSpell(s)
			if bIsCast
				if a.Is3DLoaded() ;Tkc (Loverslab): just Is3DLoaded is not enough here
					Cell acell = a.GetParentCell()
					if acell && acell.IsAttached() ;Tkc (Loverslab): offered by dldrzz000. None error for IsAttached(). Possible here is will be enough of if a.Is3DLoaded() check
						s.Cast(a,a)
					endif
				endif
			else
				a.addSpell(s, ShowMsg) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
			endif
		 endIf
		endIf
	  endif
	endif
endFunction

;--------------------------------------------------------------------------------
; Quest Functions
;--------------------------------------------------------------------------------
event OnInit()
	;PlayerRef = Game.GetPlayer() ;Tkc (Loverslab): commented it because added property in esp to the script
	FWCached=new FWAbilityBeeingFemale[15]
	if bInitDone ;Tkc (Loverslab): optimization
	else;if !bInitDone
		bInitDone=true
		RegisterForSingleUpdate(15.0)
	endif
endEvent

; Here the last 15 NPCs are stored
function RegisterFWCache(FWAbilityBeeingFemale FW_MagicEffect)
	if FWCacheMax==0
		FWCached=new FWAbilityBeeingFemale[15]
		FWCacheMax=FWCached.length
	endif
	int i=FWCacheID
	int j=0
	while j<FWCacheMax
		if FWCached[j]==FW_MagicEffect
			return
		endif
		j+=1
	endWhile
	FWCacheID = (FWCacheID + 1) % FWCacheMax
	FWCached[i]=FW_MagicEffect
endfunction

; Here you can gain access to a cached BeeingFemaleSpell
FWAbilityBeeingFemale function getBeeingFemaleSpell(actor woman)
	;return none ***Edit by Bane
	int j=0
	while j<FWCacheMax
		if FWCached[j].ActorRef==woman
			return FWCached[j]
		endif
		j+=1
	endWhile
	return none
endfunction


; Remove SPID-Added items
function RemoveSPIDitems(actor woman)
	int NumTypesPill = Pill_Items.GetSize()
	int NumTypesWashOut = WashOut_List.GetSize()
	
	int index
	Form ithItem
	int ithItemNum
	if(NumTypesPill)
		index = 0
		while(index < NumTypesPill)
			ithItem = Pill_Items.GetAt(index)
			ithItemNum = woman.GetItemCount(ithItem)
			if(ithItemNum)
				Debug.Trace("BeeingFemaleSE_Opt - FWSystem - RemoveSPIDitems : Actor " + woman + " has " + ithItemNum + " " + ithItem + ". Removing...")
				woman.RemoveItem(ithItem, ithItemNum, true)
			endIf
			index += 1
		endWhile
	endIf
	
	if(NumTypesWashOut)
		index = 0
		while(index < NumTypesWashOut)
			ithItem = WashOut_List.GetAt(index)
			ithItemNum = woman.GetItemCount(ithItem)
			if(ithItemNum)
				Debug.Trace("BeeingFemaleSE_Opt - FWSystem - RemoveSPIDitems : Actor " + woman + " has " + ithItemNum + " " + ithItem + ". Removing...")
				woman.RemoveItem(ithItem, ithItemNum, true)
			endIf
			index += 1
		endWhile
	endIf
	
	ithItemNum = woman.GetItemCount(Tampon_Normal)
	if(ithItemNum)
		Debug.Trace("BeeingFemaleSE_Opt - FWSystem - RemoveSPIDitems : Actor " + woman + " has " + ithItemNum + " tampons. Removing...")
		woman.RemoveItem(Tampon_Normal, ithItemNum, true)
	endIf

	ithItemNum = woman.GetItemCount(Sanitary_Napkin_Normal)
	if(ithItemNum)
		Debug.Trace("BeeingFemaleSE_Opt - FWSystem - RemoveSPIDitems : Actor " + woman + " has " + ithItemNum + " panties. Removing...")
		woman.RemoveItem(Sanitary_Napkin_Normal, ithItemNum, true)
	endIf

	ithItemNum = woman.GetItemCount(CallChildren2)
	if(ithItemNum)
		Debug.Trace("BeeingFemaleSE_Opt - FWSystem - RemoveSPIDitems : Actor " + woman + " has " + ithItemNum + " child scrolls. Removing...")
		woman.RemoveItem(CallChildren2, ithItemNum, true)
	endIf
endFunction


; After registration, NPCs may use this potion
function RegisterFluid(potion Fluid)
	int c=Fluid.GetNumEffects()
	while c>0
		c-=1
		;if Fluid.GetNthEffectMagicEffect(c)==Pill_Effect && Pill_Items.HasForm(Fluid)==false
		if Fluid.GetNthEffectMagicEffect(c)==Pill_Effect
			if Pill_Items.HasForm(Fluid) ;Tkc (Loverslab): optimization
			else;if Pill_Items.HasForm(Fluid)==false
				Pill_Items.AddForm(Fluid)
			endif
		endif
		;if Fluid.GetNthEffectMagicEffect(c)==WashOut_Effect && WashOut_List.HasForm(Fluid)==false
		if Fluid.GetNthEffectMagicEffect(c)==WashOut_Effect
			if WashOut_List.HasForm(Fluid) ;Tkc (Loverslab): optimization
			else;if WashOut_List.HasForm(Fluid)==false
				WashOut_List.AddForm(Fluid)
			endif
		endif
	endWhile
endFunction

float function IrregulationChance(actor woman, int state_number)
	return cfg.irregulationChance * Manager.IrregulationChance(woman, state_number)
endFunction

float function IrregulationValue(actor woman, int state_number)
	float max = Manager.IrregulationValue(woman, state_number)
	float min = 1.0
	if max>1.5
		max = 1.5
	endif
	if max < 1
		if max<=0
			return 1.0
		else;if max<1
			min = max
			max = FWUtility.MaxFloat(0.3, 1 / max)
		endIf
	else
		min = FWUtility.MaxFloat(0.3, 1 / max)
	endif
	if min<max
		return Utility.RandomFloat(min,max)
	else
		return Utility.RandomFloat(max,min)
	endif
endFunction

function CheckOtherMods()
	bool bEstrusWasActive = EstrusActive
	bool bDeviceWasActive = DeviceActive
	ChaurusBreeder = none
	zad_DeviousBelt = Keyword.GetKeyword("zad_DeviousBelt") ; Bane --> Use keyword to cover all Chastity Belts
	if zad_DeviousBelt ; modName == "Devious Devices - Assets.esm" Bane --> Fixed to detect mod by keyword
		;DeviceBelt = Game.GetFormFromFile(0x000012D1, modName) as armor
		DeviceActive = true
	Endif
	;DeviceBelt = none
	EstrusActive = false
	DeviceActive = false
	;HearthFiresActive = true
	bool SSL_installed = false
	;/int idx = Game.GetModCount()
	string modName = ""
	while idx > 0
		idx -= 1
		modName = Game.GetModName(idx)
		if modName == "EstrusChaurus.esp"
			ChaurusBreeder = Game.GetFormFromFile(0x00019121, modName) as spell
			zzEstrusChaurusBreederFaction = Game.GetFormFromFile(0x000160A9, modName) as Faction
			EstrusActive = true
			if bEstrusWasActive ;Tkc (Loverslab): optimization
			else;if bEstrusWasActive==false
				Message(Content.EstrusCharusFound,MSG_Debug)
			endif
		elseif modName == "HearthFires.esm"
			HearthFiresActive=true
		elseif modName == "SexLab.esm"
			ForbiddenFaction = Game.GetFormFromFile(0x00009068, modName) as Faction ;Bane --> Added to fix empty Faction
			SSL_installed = true
		endIf
	endWhile/;
	;;;;; ;Tkc (Loverslab): optimization. standart detection
	if FWUtility.ModFile("EstrusChaurus.esp")
		ChaurusBreeder = Game.GetFormFromFile(0x00019121, "EstrusChaurus.esp") as spell
		zzEstrusChaurusBreederFaction = Game.GetFormFromFile(0x000160A9, "EstrusChaurus.esp") as Faction
		EstrusActive = true
		if bEstrusWasActive ;Tkc (Loverslab): optimization
		else;if bEstrusWasActive==false
			Message(Content.EstrusCharusFound,MSG_Debug)
		endif
	endif
	;if FWUtility.ModFile("HearthFires.esm")
		HearthFiresActive=true
	;endif
	if FWUtility.ModFile("SexLab.esm")
		;ForbiddenFaction = Game.GetFormFromFile(0x00049068, "SexLab.esm") as Faction ;Bane --> Added to fix empty Faction ; No, you made a mistake Bane. It is 49068, NOT 09068
		SSL_installed = true
	endif
	;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	if SSL_installed ;Tkc (Loverslab): optimization
	else;if !SSL_installed
		cfg.CreatureSperm=false
	endif
endFunction


function SetImportantItems()
	cfg = Game.GetFormFromFile(0x1828, "BeeingFemale.esm") as FWSystemConfig
	Content = Game.GetFormFromFile(0x3E31, "BeeingFemale.esm") as FWTextContents
	Controller = Game.GetFormFromFile(0x182A, "BeeingFemale.esm") as FWController
	CoupleWidget = Game.GetFormFromFile(0x5E1AD, "BeeingFemale.esm") as FWCoupleWidget
	data = Game.GetFormFromFile(0x1827, "BeeingFemale.esm") as FWSaveLoad
	ChildSettings = Game.GetFormFromFile(0x1B252, "BeeingFemale.esm") as FWChildSettings
	manager = Game.GetFormFromFile(0x1829, "BeeingFemale.esm") as FWAddOnManager
	ModEnabled = Game.GetFormFromFile(0x1260D, "BeeingFemale.esm") as GlobalVariable
	CloakingSpellEnabled = Game.GetFormFromFile(0x1DA6, "BeeingFemale.esm") as GlobalVariable
	Progress = Game.GetFormFromFile(0x6590D, "BeeingFemale.esm") as FWProgressWidget
	StateWidget = Game.GetFormFromFile(0x17C43, "BeeingFemale.esm") as FWStateWidget
	WidgetController = Game.GetFormFromFile(0x2BB48, "BeeingFemale.esm") as FWWidgetController
	BabyHealthWidget = Game.GetFormFromFile(0x1972F, "BeeingFemale.esm") as FWBabyHealthWidget
	PantyWidget = Game.GetFormFromFile(0x5ab70, "BeeingFemale.esm") as FWPantyWidget
	BabyItemList = Game.GetFormFromFile(0x1835, "BeeingFemale.esm") as FWBabyItemList
	CoupleWidget = Game.GetFormFromFile(0x5E1AD, "BeeingFemale.esm") as FWCoupleWidget
	; Reset the important items of the main components
	; Reset less important items
	AbortusFever = Game.GetFormFromFile(0x2312, "BeeingFemale.esm") as ImageSpaceModifier
	AbortusImod = Game.GetFormFromFile(0x2311, "BeeingFemale.esm") as ImageSpaceModifier
	DefaultBlur = Game.GetFormFromFile(0x162, "Skyrim.esm") as ImageSpaceModifier ;Bane --> Corrected
	AmnioticFluid = Game.GetFormFromFile(0x2316, "BeeingFemale.esm") as Armor ;Bane --> Corrected
	ArkayShrineObject = Game.GetFormFromFile(0x71854, "Skyrim.esm") as Activator
	BabyGem = Game.GetFormFromFile(0x7EE5, "BeeingFemale.esm") as SoulGem
	BeeingFemaleInfoSpell = Game.GetFormFromFile(0x287E, "BeeingFemale.esm") as Spell
	BeeingFemaleSpell = Game.GetFormFromFile(0x1DA4, "BeeingFemale.esm") as Spell
	BeeingMaleSpell = Game.GetFormFromFile(0x1DA2, "BeeingFemale.esm") as Spell
	ContraceptionLow = Game.GetFormFromFile(0x38C9, "BeeingFemale.esm") as Potion
	ContraceptionMid = Game.GetFormFromFile(0x38CB, "BeeingFemale.esm") as Potion
endFunction


function OnGameLoad(bool bIsModReset = false) ;***Edit by Bane
	cfg.bForceMenu = false
	LoadState=1
	if bFirstRun;/==true/; ;optimization by Tkc (Loverslab)
		Message(Content.InitBF,MSG_Always)
	;elseif cfg.Messages<=1 ;optimization by Tkc (Loverslab) ; commented because no actions for second anf 3rd else
	;else
	endif
	LoadState=2
	;--------------------------------------------------------------
	; Unregister Events
	UnregisterForAllModEvents()
	UnregisterForUpdateGameTime()
	UnregisterForUpdate()
	UnregisterForMenu("Console")
	LoadState=3
	RegisterForMenu("Console")
	; Reset all important Items
	SetImportantItems()
	; Load contet
	Content.LoadContent()
	;--------------------------------------------------------------
	; First, check if SKSE and PapyrusUtil is installed
	if bFirstRun;/==true/; || cfg.Messages<=1 ;optimization by Tkc (Loverslab)
		Message(Content.Req_BF,MSG_Always)
	endif
	LoadState=4
	if (StringUtil.SubString(Debug.GetVersionNumber(), 0, 3) as float) < 1.5
		ModEnabled.SetValueInt(0)
		CloakingSpellEnabled.SetValueInt(0)
		;if bFirstRun;/==true/; || cfg.Messages<=1 ;Tkc (Loverslab): optimization: Commented condition because Progress.Set was also commented and will be doing nothing
			;Progress.Set("Skyrim version outdated.",100,Progress.ICN_Failed,true)
		;endif
		LoadState=5
		Message(Content.Req_Skyrim, MSG_Always, MSG_Box)
		return
	elseif (SKSE.GetVersionRelease() == 0)
		ModEnabled.SetValueInt(0)
		CloakingSpellEnabled.SetValueInt(0)
		;if bFirstRun;/==true/; || cfg.Messages<=1 ;Tkc (Loverslab): optimization: Commented condition because Progress.Set was also commented and will be doing nothing
			;Progress.Set("SKSE not installed",100,Progress.ICN_Failed,true)
		;endif
		LoadState=6
		Message(Content.Req_SKSE, MSG_Always, MSG_Box)
		return
	elseif SKSE.GetScriptVersionRelease()<48
		ModEnabled.SetValueInt(0)
		CloakingSpellEnabled.SetValueInt(0)
		;if bFirstRun;/==true/; || cfg.Messages<=1 ;Tkc (Loverslab): optimization: Commented condition because Progress.Set was also commented and will be doing nothing
			;Progress.Set("SKSE version outdated",100,Progress.ICN_Failed,true)
		;endif
		LoadState=7
		Message(Content.Req_SKSEScript, MSG_Always, MSG_Box)
		return
	elseif SKSE.GetPluginVersion("papyrusutil plugin")==-1
		; Papyrus Util is not installed
		ModEnabled.SetValueInt(0)
		CloakingSpellEnabled.SetValueInt(0)
		;if bFirstRun;/==true/; || cfg.Messages<=1 ;Tkc (Loverslab): optimization: Commented condition because Progress.Set was also commented and will be doing nothing
			;Progress.Set("PapyrusUtil not installed",100,Progress.ICN_Failed,true)
		;endif
		LoadState=8
		Message(Content.Req_PapyrusUtil, MSG_Always, MSG_Box)
		return
	elseif SKSE.GetPluginVersion("BeeingFemale")==-1
		ModEnabled.SetValueInt(0)
		CloakingSpellEnabled.SetValueInt(0)
		;if bFirstRun;/==true/; || cfg.Messages<=1 ;Tkc (Loverslab): optimization: Commented condition because Progress.Set was also commented and will be doing nothing
			;Progress.Set("PapyrusUtil not installed",100,Progress.ICN_Failed,true)
		;endif
		LoadState=9
		Message(Content.Req_BeeingFemaleNative+" -1/"+FWVersion.GetNativeVersion(), MSG_Always, MSG_Box)
		return
	elseif SKSE.GetPluginVersion("BeeingFemale")<FWVersion.GetNativeVersion()
		ModEnabled.SetValueInt(0)
		CloakingSpellEnabled.SetValueInt(0)
		;if bFirstRun;/==true/; || cfg.Messages<=1 ;Tkc (Loverslab): optimization: Commented condition because Progress.Set was also commented and will be doing nothing
			;Progress.Set("PapyrusUtil not installed",100,Progress.ICN_Failed,true)
		;endif
		LoadState=10
		Message(FWUtility.MultiStringReplace(Content.Req_BeeingFemaleNativeUpdate, SKSE.GetPluginVersion("BeeingFemale"), FWVersion.GetNativeVersion())+" "+SKSE.GetPluginVersion("BeeingFemale")+"/"+FWVersion.GetNativeVersion(), MSG_Always, MSG_Box)
		return
	endif
	LoadState=11
	; Check for animationsOK, those are not required
	if FNIS.VersionCompare(5, 4, 2) < 0
		if animationsOK;/==true/; ;Tkc (Loverslab): optimization
			Debug.Notification(Content.FNISNotInstalled)
		endif
		cfg.PlayAnimations=false
		animationsOK = false
		LoadState=12
	else
		if animationsOK==false || bFirstRun;/==true/; ;Tkc (Loverslab): optimization
			Debug.Notification(Content.FNISUsing)
		endif
		animationsOK=true
		LoadState=14
	endif
	if bFirstRun
		;Progress.Set("First Run Items",30,Progress.ICN_Compatibility)
		LoadState=15
		initArrays()
		LoadState=16
		giveStartupSpells()
		LoadState=17
		giveStartupItems()
		LoadState=18
		initDrinkStor()
	endIf
	LoadState=19
	cfg.LoadWidgetProfile()
	LoadState=20
	;--------------------------------------------------------------
	; Check other mods
	;if bFirstRun;/==true/; || cfg.Messages<=1 ;Tkc (Loverslab): optimization: Commented condition because Progress.Set was also commented and will be doing nothing
		;Progress.Set("Check other mods",40,Progress.ICN_Compatibility)
	;endif
	LoadState=21
	CheckOtherMods()
	LoadState=22
	;--------------------------------------------------------------
	; Handle Widgets
	;if bFirstRun;/==true/; || cfg.Messages<=1 ;Tkc (Loverslab): optimization: Commented condition because Progress.Set was also commented and will be doing nothing
		;Progress.Set("Handle widgets",50,Progress.ICN_Compatibility)
	;endif
	LoadState=23
	CoupleWidget.enabled=false
	
	;--------------------------------------------------------------
	; Register mod Events
	;if bFirstRun;/==true/; || cfg.Messages<=1 ;Tkc (Loverslab): optimization: Commented condition because Progress.Set was also commented and will be doing nothing
		;Progress.Set("Register Events",60,Progress.ICN_Compatibility)
	;endif
	LoadState=24
	;actor PA=PlayerRef ;Tkc (Loveslab): commented, not using here
	LoadState=25
	Utility.WaitMenuMode(2)
	LoadState=26
	RegisterForModEvent("AddActorSperm", "onAddActorSperm")
	RegisterForModEvent("AddSperm", "onAddActorSperm")
	RegisterForModEvent("BeeingFemale", "onBeeingFemaleCommand")
	RegisterForModEvent("consolecommand", "onBeeingFemaleConsole")
	LoadState=27
	RegisterForSingleUpdateGameTime(1)
	LoadState=28
	;--------------------------------------------------------------
	; Make sure, CANS will be deactivated when it's not loaded
	bCheckGiveSpermToNPCs=false
	
	;--------------------------------------------------------------
	; Raise the OnGameLoad Event on other components
	;if bFirstRun;/==true/; || cfg.Messages<=1 ;Tkc (Loverslab): optimization: Commented condition because Progress.Set was also commented and will be doing nothing
		;Progress.Set("Load components",70,Progress.ICN_Compatibility)
	;endif
	LoadState=29
	;Bane --> The following code is redundant - OnPlayerLoadGame runs automatically on the Pleyers FWAbilityBeeingFemale/Male effect except on first Load
	;if Player!=none && PA.GetLeveledActorBase().GetSex()==1 && !bIsModReset ;***Edit by Bane
	;	LoadState=30
	;	Player.OnPlayerLoadGame() 
	;	LoadState=31
	;elseif PlayerMale!=none && PA.GetLeveledActorBase().GetSex()==0 && !bIsModReset ;***Edit by Bane
	;	LoadState=32
	;	PlayerMale.OnPlayerLoadGame()
	;	LoadState=33
	;else
	If bIsModReset
		LoadState=34
		ReNewSpells()
		LoadState=35
	endif
	LoadState=36
	ChildSettings.OnGameLoad()
	LoadState=37
	cfg.OnLoadGame()
	LoadState=38
	Manager.OnGameLoad()
	;LoadState=39
	LoadState=40
	
	
	;--------------------------------------------------------------
	; Register Update Timer - Woman Updater
	;if bFirstRun;/==true/; || cfg.Messages<=1 ;Tkc (Loverslab): optimization: Commented condition because Progress.Set was also commented and will be doing nothing
		;Progress.Set("Init Woman Updater",80,Progress.ICN_Compatibility)
	;endif
	LoadState=41
	if cfg.UpdateInterval<10
		LoadState=42
		cfg.UpdateInterval=10
	endif
	if cfg.UpdateIntervalEnabled;/==true/; ;Tkc (Loverslab): optimization
		LoadState=43
		RegisterForSingleUpdate(cfg.UpdateInterval)
	endif
	LoadState=44
	
	;--------------------------------------------------------------
	; Remove disabled children from Storeage List
	;if bFirstRun;/==true/; || cfg.Messages<=1 ;Tkc (Loverslab): optimization: Commented condition because Progress.Set was also commented and will be doing nothing
		;Progress.Set("Check for overdue",90,Progress.ICN_Compatibility)
	;endif
	LoadState=45
	int childCount = StorageUtil.FormListCount(none, "FW.Babys")
	LoadState=46
	while childCount>0
		childCount-=1
		Form frm = StorageUtil.FormListGet(none, "FW.Babys", childCount)
		;if(frm as FWChildActor == none && frm as FWChildItem == none)
		if frm as FWChildActor ;Tkc (Loverslab): optimization
		else;if frm as FWChildActor == none
			if frm as FWChildItem ;Tkc (Loverslab): optimization
			else;if frm as FWChildItem == none
				if frm as Actor
					Actor myCustomChildActor = frm as Actor
					bool myIsCustomChildActor = (StorageUtil.GetIntValue(myCustomChildActor, "FW.Child.IsCustomChildActor", 0) == 1)
					if(myIsCustomChildActor)
					else
						Debug.Trace("BeeingFemaleSE_Opt - FWSystem: Adding IsCustomChildActor flag to the actor: " + myCustomChildActor)
						StorageUtil.SetIntValue(myCustomChildActor, "FW.Child.IsCustomChildActor", 1)
					endIf			
				else
					StorageUtil.FormListRemoveAt(none, "FW.Babys", childCount)
				endIf
			endif
		endif
	endwhile
	LoadState=47
	
	;--------------------------------------------------------------
	; Enable BeeingFemale again
	ModEnabled.SetValueInt(1)
	CloakingSpellEnabled.SetValueInt(1)
	LoadState=48
	UpdateHotKey()
	LoadState=49
	
	if bFirstRun || bIsModReset
		bFirstRun=false
		;Progress.Set("BeeingFemale installed",100,Progress.ICN_Checked,true)
		Message(Content.InstallComplete,MSG_Always)
		LoadState=50
	elseif cfg.Messages<=1
		;Progress.Set("BeeingFemale loaded",100,Progress.ICN_Checked,true)
		Message(Content.LoadingComplete,MSG_Always)
		LoadState=51
	endif
	
	LoadState=0
endfunction

int curRefreshWoman
event OnUpdate()
	if bFirstRun
		OnGameLoad()
	else
		; Update the next woman in list
		int i=10
		actor female=none
		while i>0 && !female
			i-=1 ; To prevent endless loops
			female = StorageUtil.FormListGet(none,"FW.SavedNPCs",curRefreshWoman) as actor
			curRefreshWoman+=1
			if curRefreshWoman> StorageUtil.FormListCount(none,"FW.SavedNPCs")
				curRefreshWoman=0
			endif
		endWhile
		;if female!=none && female!=PlayerRef
		if female ;Tkc (Loverslab): optimization
		 if female==PlayerRef
		 else;female!=PlayerRef
			float t = Utility.GetCurrentRealTime()
			Data.Update(female)
		 endif
		endif
	endif
	RegisterForSingleUpdate(cfg.UpdateInterval)
endEvent


function Upgrade(int oldVersion, int newVersion)
	UpdateState=0x01
	string BFVersion=FWVersion.GetVersionString() + "." + FWVersion.GetMCMVersion()
	Message( FWUtility.StringReplace( Content.Updated , "{0}", BFVersion), MSG_Always)
	
	;System = Game.GetFormFromFile(0xD63, "BeeingFemale.esm") as FWSystem
	cfg = Game.GetFormFromFile(0x1828, "BeeingFemale.esm") as FWSystemConfig
	content = Game.GetFormFromFile(0x3e31, "BeeingFemale.esm") as FWTextContents
	Data = Game.GetFormFromFile(0x1827, "BeeingFemale.esm") as FWSaveLoad
	Manager = Game.GetFormFromFile(0x1829, "BeeingFemale.esm") as FWAddOnManager
	Controller = Game.GetFormFromFile(0x182A, "BeeingFemale.esm") as FWController
	BabyItemList = Game.GetFormFromFile(0x1835, "BeeingFemale.esm") as FWBabyItemList
	ModEnabled = Game.GetFormFromFile(0x1260D, "BeeingFemale.esm") as Globalvariable
	CloakingSpellEnabled = Game.GetFormFromFile(0x1DA6, "BeeingFemale.esm") as Globalvariable
	GlobalPlayerState = Game.GetFormFromFile(0x60CC3, "BeeingFemale.esm") as Globalvariable
	GlobalPlayerStatePercent = Game.GetFormFromFile(0x60CC4, "BeeingFemale.esm") as Globalvariable
	GlobalMenstruating = Game.GetFormFromFile(0x648BC, "BeeingFemale.esm") as Globalvariable
	ChildSettings = Game.GetFormFromFile(0x1B252, "BeeingFemale.esm") as FWChildSettings
	MenuImageSpace = Game.GetFormFromFile(0x2D67D, "BeeingFemale.esm") as Imagespacemodifier
	
	; Fixup Widgets
	StateWidget = Game.GetFormFromFile(0x17C43, "BeeingFemale.esm") as FWStateWidget
	ContraceptionWidget = Game.GetFormFromFile(0x191CC, "BeeingFemale.esm") as FWContraceptionWidget
	BabyHealthWidget = Game.GetFormFromFile(0x1972F, "BeeingFemale.esm") as FWBabyHealthWidget
	WidgetController = Game.GetFormFromFile(0x2BB48, "BeeingFemale.esm") as FWWidgetController
	PantyWidget = Game.GetFormFromFile(0x5AB70, "BeeingFemale.esm") as FWPantyWidget
	CoupleWidget = Game.GetFormFromFile(0x5E1AD, "BeeingFemale.esm") as FWCoupleWidget
	Progress = Game.GetFormFromFile(0x6590D, "BeeingFemale.esm") as FWProgressWidget

	;Progress.Set("Update to version "+BFVersion,0,Progress.ICN_Update)
	UpdateState=0x10
	Content.Upgrade(oldVersion, newVersion)
	;Progress.Percent = 10
	UpdateState=0x20
	cfg.Upgrade(oldVersion, newVersion)
	;Progress.Percent = 20
	UpdateState=0x30
	giveStartupItems(oldVersion)
	;Progress.Percent = 30
	UpdateState=0x40
	ContraceptionWidget.Upgrade(oldVersion, newVersion)
	;Progress.Percent = 40
	UpdateState=0x50
	BabyHealthWidget.Upgrade(oldVersion, newVersion)
	;Progress.Percent = 50
	UpdateState=0x60
	StateWidget.Upgrade(oldVersion, newVersion)
	;Progress.Percent = 60
	UpdateState=0x70
	ChildSettings.Upgrade(oldVersion, newVersion)
	;Progress.Percent = 70
	UpdateState=0x80
	Manager.Upgrade(oldVersion, newVersion)
	;Progress.Percent = 80
	UpdateState=0x90
	Data.Upgrade(oldVersion, newVersion)
	;Progress.Percent = 90
	
	; Upgrade all Children
	UpdateState=0xA0
	int c = StorageUtil.FormListCount(none,"FW.Babys")
	while c>0
		c-=1
		if StorageUtil.FormListGet(none,"FW.Babys", c) as FWChildActorPlayer; != none ;Tkc (Loverslab): optimization
			(StorageUtil.FormListGet(none,"FW.Babys", c) as FWChildActorPlayer).Upgrade(oldVersion, newVersion)
		elseif StorageUtil.FormListGet(none,"FW.Babys", c) as FWChildActor; != none ;Tkc (Loverslab): optimization
			(StorageUtil.FormListGet(none,"FW.Babys", c) as FWChildActor).Upgrade(oldVersion, newVersion)
		endif
	endWhile
	UpdateState=0
	Message(Content.UpdateComplete,MSG_Always)
endFunction

function initDrinkStor()
endFunction


function ReNewSpells()
	;actor PA = PlayerRef ;Tkc (Loveslab):
	if(PlayerRef.HasSpell(BeeingFemaleSpell))
		PlayerRef.RemoveSpell(BeeingFemaleSpell)
	endif
	if(PlayerRef.HasSpell(BeeingMaleSpell))
		PlayerRef.RemoveSpell(BeeingMaleSpell)
	endif
	giveStartupSpells()
endFunction

function giveStartupSpells()
	;actor PA = PlayerRef ;Tkc (Loverslab)
	; Remove spells if not neccessary
	int PlayerSex = PlayerRef.GetLeveledActorBase().GetSex() ;Tkc (Loverslab): optimization, getbase.getsex used  several times
	if (PlayerSex == 0 || cfg.RelevantPlayer==false) && PlayerRef.HasSpell(BeeingFemaleSpell)==false
		FWUtility.ActorRemoveSpell(PlayerRef,BeeingFemaleSpell)
	elseif (PlayerSex == 1 || cfg.RelevantPlayer==false) && PlayerRef.HasSpell(BeeingMaleSpell)==false
		FWUtility.ActorRemoveSpell(PlayerRef,BeeingMaleSpell)
	endIf
	; Give spells
	;/ original
	if PlayerSex == 0 && PlayerRef.HasSpell(BeeingMaleSpell)==false && cfg.RelevantPlayer==true
		ActorAddSpell(PlayerRef,BeeingMaleSpell)
	elseif PlayerSex == 1 && PlayerRef.HasSpell(BeeingFemaleSpell)==false && cfg.RelevantPlayer==true
		ActorAddSpell(PlayerRef,BeeingFemaleSpell)
	endIf
	/;
	;optimized\rewrited by Tkc (Loverslab)
	if cfg.RelevantPlayer
		if PlayerSex;1-woman
			if PlayerRef.HasSpell(BeeingFemaleSpell)
			else
				ActorAddSpellOpt(PlayerRef,BeeingFemaleSpell, false, false, ShowMsg=cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
			endIf
		else;0-man
			if PlayerRef.HasSpell(BeeingMaleSpell)
			else
				ActorAddSpellOpt(PlayerRef,BeeingMaleSpell, false, false, ShowMsg=cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
			endIf			
		endIf	
	endIf
endFunction

function giveStartupItems(int oldVersion=0)
	;actor PlayerActor = PlayerRef
	if oldVersion <=2
		PlayerRef.AddItem(PlayerBooks[0],1,true)
		PlayerRef.AddItem(PlayerBooks[1],1,true)
		PlayerRef.AddItem(PlayerBooks[2],1,true)
		PlayerRef.AddItem(PlayerBooks[3],1,true)
	endif
	if oldVersion <=9
		PlayerRef.AddItem(StartUpScrolls[0],3,true)
		PlayerRef.AddItem(StartUpScrolls[1],1,true)
	endif
endFunction

function initArrays()
	; Cheat Father
	CheatAddFather = new int[27]
	CheatAddFather[0] =0x13475 	; Alvor Nord
	CheatAddFather[1] =0xAE779 	; Badnir Nord
	CheatAddFather[2] =0x1334C 	; Balimund Nord
	CheatAddFather[3] =0x1338A 	; Borkul Orc
	CheatAddFather[4] =0x20040 	; Deekus Argonian
	CheatAddFather[5] =0x1403E 	; Derkeethus Argonian
	CheatAddFather[6] =0x13284 	; GulumEi Argonian
	CheatAddFather[7] =0x661AD 	; Adeber Breton
	CheatAddFather[8] =0x13B69 	; Ainethach Breton
	CheatAddFather[9] =0x13353 	; Dravin DarkElf
	CheatAddFather[10]=0x13370 	; Indaryn DarkElf
	CheatAddFather[11]=0x85D44 	; Orini Dral DarkElf
	CheatAddFather[12]=0x7D679 	; Linwe HighElf
	CheatAddFather[13]=0x34D99 	; Muril HighElf
	CheatAddFather[14]=0x39250 	; Tandil HighElf
	CheatAddFather[15]=0xD6AD8 	; Aquilius Aeresius Imperial
	CheatAddFather[16]=0x1BB5D 	; Gallus Imperial
	CheatAddFather[17]=0x1995B 	; Olur Orc
	CheatAddFather[18]=0x3BC26 	; Yamarz Orc
	CheatAddFather[19]=0x1B3B5 	; Enis Redgurd
	CheatAddFather[20]=0x1C3AB 	; Nazir Redgurd
	CheatAddFather[21]=0x13B9E 	; Elrindir WoodElf
	CheatAddFather[22]=0x1C19C 	; Enthir WoodElf
	CheatAddFather[23]=0x13480 	; Faendal WoodElf
	CheatAddFather[24]=0x1B1CF 	; Dro'marash Khajiit
	CheatAddFather[25]=0x4D12B 	; J'datharr Khajiit
	CheatAddFather[26]=0x13298 	; Mazaka Khajiit
	
	FWCached=new FWAbilityBeeingFemale[15]
	FWCacheMax=FWCached.length
endFunction


; How to use
; FemaleActor.SendModEvent("BeeingFemale", "AddContraception", 100) ; This adds contraception to the woman
; FemaleActor.SendModEvent("BeeingFemale", "AddSperm", MaleActor.GetFormID()) ; This will add sperm to the woman
; FemaleActor.SendModEvent("BeeingFemale", "WashOutSperm", 100) ; This will wash out 100% sperm
; FemaleActor.SendModEvent("BeeingFemale", "ChangeState", 3) ; This will change the state to 'Menstruation'
; FemaleActor.SendModEvent("BeeingFemale", "InfoBox", 100) ; This will open the info window with all informations
; FemaleActor.SendModEvent("BeeingFemale", "DamageBaby", 30) ; This will make 30 damage to the baby
; FemaleActor.SendModEvent("BeeingFemale", "HealBaby", 60) ; This will heal the baby with 60 Health points
Event onBeeingFemaleCommand(string hookName, string argString, float argNum, form sender)
	if hookName=="BeeingFemale" && (sender as Actor);/!=none/; ;Tkc (Loverslab): optimization
		actor a = (sender as Actor)
		int iNum = argNum as int
		int validateF = IsValidateFemaleActor(a)
		int validateM = IsValidateMaleActor(a)
		if argString=="AddContraception" && argNum>0.0 && validateF>0
			Controller.AddContraception(a, argNum)
		elseif argString=="AddSperm" && argNum>0.0
			form f1 = Game.GetForm(argNum as int)
			if f1
				actor a2 = f1 as Actor
				int validateF2 = IsValidateFemaleActor(a2)
				int validateM2 = IsValidateMaleActor(a2)
				if a2
					if validateF>0 && validateF2>0 ; F/F2 Cum
						Controller.AddSperm(a, a2, 1.0)
					elseif validateM>0 && validateF2>0 ; M/F2 Cum
						float virility = Controller.GetVirility(a)
						float amount = Utility.RandomFloat(virility * 0.75, virility*1.1)
						if amount>1.0
							amount=1.0
						endif
						amount = Manager.getSpermAmount(a2,a,amount)
						Controller.AddSperm(a2, a, amount)
					elseif validateF>0 && validateM2 ; F/M2 Cum
						float virility = Controller.GetVirility(a2)
						float amount = Utility.RandomFloat(virility * 0.75, virility*1.1)
						if amount>1.0
							amount=1.0
						endif
						amount = Manager.getSpermAmount(a,a2,amount)
						Controller.AddSperm(a, a2, amount)
					endif
				endif
			endif
		elseif argString=="WashOutSperm" && argNum>0 && validateF>0
			Controller.WashOutSperm(a,2,argNum)
		elseif argString=="ChangeState" && iNum>=0 && iNum <9 && validateF>0
			Controller.ChangeState(a, iNum)
		elseif argString=="InfoBox"
			Controller.showRankedInfoBox(a,iNum)
		elseif argString=="DamageBaby" && validateF>0
			Controller.DamageBaby(a,argNum)
		elseif argString=="HealBaby" && validateF>0
			Controller.DamageBaby(a,argNum)
		elseif argString=="CanBecomePregnant" && validateF>0
			Controller.setCanBecomePregnant(a, argNum==1)
		elseif argString=="CanBecomePMS" && validateF>0
			Controller.setCanBecomePMS(a, argNum==1)
		endif
	endif
endEvent


; How to use:
; actor denor (= the person who came inside)
; actor woman (= the woman who conceive sperm)
; man.SendModEvent("AddSperm","", woman.GetFormID())
Event onAddSperm(string hookName, string argString, float argNum, form sender)
	actor man
	actor woman
	if (Sender as Actor);/!=none/; ;Tkc (Loverslab): optimization
		; Man
		if (Sender as Actor).GetLeveledActorBase().GetSex()==0 && IsValidateMaleActor(Sender as Actor)>0
			man = sender as Actor
		elseif (Sender as Actor).GetLeveledActorBase().GetSex()==1
			if Manager.OnAllowFFCum(woman, (Sender as Actor));/==true/; && IsValidateFemaleActor(Sender as Actor)>0 ;Tkc (Loverslab): optimization
				man = sender as Actor
			endif
		endif
	elseif argString;/!=""/; ;Tkc (Loverslab): optimization
		int iStr=argString as int
		if iStr>0
			actor aStr = Game.GetForm(iStr) as Actor
			if aStr;/!=none/; ;Tkc (Loverslab): optimization
				if aStr.GetLeveledActorBase().GetSex()==0 && IsValidateMaleActor(aStr)>0
					man = aStr
				elseif aStr.GetLeveledActorBase().GetSex()==1
					if Manager.OnAllowFFCum(woman, aStr);/==true/; && IsValidateFemaleActor(aStr)>0 ;Tkc (Loverslab): optimization
						man = aStr
					endif
				endif
			endif
		endif
	endif
	if (Game.GetForm(argNum as int) as Actor ;/!=none/;) ;Tkc (Loverslab): optimization
		; Woman
		if IsValidateFemaleActor(Game.GetForm(argNum as int) as Actor)>0
			woman = Game.GetForm(argNum as int) as Actor
		endif
	endif
	
	bool bCanAdd=true
	if woman ;Tkc (Loverslab): optimization
	else;if woman==none
		bCanAdd=false
	endif
	if man ;Tkc (Loverslab): optimization
	else;if man==none
		bCanAdd=false
	endif
	if DeviceActive;/==true/; ;Tkc (Loverslab): optimization
		if woman.WornHasKeyword(zad_DeviousBelt); woman.IsEquipped(DeviceBelt)==true  Bane --> Fixed to cover all Chastity Belts
			bCanAdd=false
		endif
	endif
	if bCanAdd;/==true/; ;Tkc (Loverslab): optimization
		Controller.AddSperm(woman,man)
	endif
endEvent

Event onAddActorSperm(string hookName, Actor Woman, Actor Donor)
	actor w
	actor m
	if Donor;/!=none/; ;Tkc (Loverslab): optimization
		; Man
		if Donor.GetLeveledActorBase().GetSex()==0 && IsValidateMaleActor(Donor)>0
			m = Donor
		elseif Donor.GetLeveledActorBase().GetSex()==1
			if Manager.OnAllowFFCum(w,m);/==true/; && IsValidateFemaleActor(Donor)>0 ;Tkc (Loverslab): optimization
				m = Donor
			endif
		endif
	endif
	if (Woman;/!=none/;) ;Tkc (Loverslab): optimization
		; Woman
		if IsValidateFemaleActor(Woman)>0
			w = Woman
		endif
	endif
	bool bCanAdd=true
	if woman ;Tkc (Loverslab): optimization
	else;if woman==none
		bCanAdd=false
	endif
	if m ;Tkc (Loverslab): optimization
	else;if m==none
		bCanAdd=false
	endif
	if DeviceActive;/==true/; ;Tkc (Loverslab): optimization
		if woman.WornHasKeyword(zad_DeviousBelt); woman.IsEquipped(DeviceBelt);/==true/;  Bane --> Fixed to cover all Chastity Belts
			bCanAdd=false
		endif
	endif
	if bCanAdd;/==true/; ;Tkc (Loverslab): optimization
		Controller.AddSperm(w,m)
	endif
endEvent

float fLastUpdateGameTime
event OnUpdateGameTime()
	if cfg.ImpregnateActive
		CheckGiveSpermToNPCs()
	endif
	RegisterForSingleUpdateGameTime(1)
endEvent

bool function CheckIsLoreFriendlyMetting(actor w, actor m)
	if cfg.ImpregnateLoreFriendly;/==true/; ;Tkc (Loverslab): optimization
		if w.GetRace()==m.GetRace() ;Tkc (Loverslab): optimization
		else;if w.GetRace()!=m.GetRace()
			if CheckIsLoreFriendlyRequired(w) || CheckIsLoreFriendlyRequired(m)
				return false
			endif
		endif
	endif
	return true
endFunction

bool function CheckIsLoreFriendlyRequired(actor a)
	return a.GetRace().HasKeyword(IsBeastRace)
endFunction

bool bCheckGiveSpermToNPCs = false
function CheckGiveSpermToNPCs()
{ Check if it's time to randomly add some sperm to some NPCs }
	float startTime = Utility.GetCurrentRealTime()
	;Message("TRY TO RUN CheckGiveSpermToNPCs", MSG_Debug, MSG_Trace)
	if bCheckGiveSpermToNPCs
		return
	endif
	bCheckGiveSpermToNPCs= true
	float cur = GameDaysPassed.GetValue()
	if fLastUpdateGameTime<1
		; Nothing will happen at the first day
		fLastUpdateGameTime = GameDaysPassed.GetValue()
		bCheckGiveSpermToNPCs = false
		return
	endif
	float Dur = (cur - fLastUpdateGameTime)
	float HoursSinceSex = 0.0
	if(Dur>0.01)
		bool bFound = false
		if Dur>1
			; We was waiting / traveling doing something for more then 1 Day - so yes, add sperm
			bFound=true
		else
			float SpanMin = ModuloOne(cur - dur) *24
			if SpanMin<0.0
				SpanMin=0
			endif
			float SpanMax = ModuloOne(cur) * 24
			if SpanMax > SpanMin
				; The Timespan was during the same day
				bFound = (SpanMin < cfg.ImpregnateTime) && (SpanMax >= cfg.ImpregnateTime)
			elseif SpanMin>=SpanMax
				; The time has run into the next day, so 0:00
				bFound = (SpanMin > cfg.ImpregnateTime) && (SpanMax <= cfg.ImpregnateTime)
			endif
		endif
		
		int success=0
		if bFound
			float cur24Time = ModuloOne(cur)
			if cur24Time>=cfg.ImpregnateTime
				HoursSinceSex = cur24Time - cfg.ImpregnateTime
			else
				HoursSinceSex = cur24Time + (24 - cfg.ImpregnateTime)
			endif
			int c = StorageUtil.FormListCount(none,"FW.SavedNPCs")
			int i = cfg.ImpregnateCount
			while i >0
				i-=1
				int rnd = Utility.RandomInt(1,c) - 1
				actor f = StorageUtil.FormListGet(none,"FW.SavedNPCs",rnd) as Actor
				if f;/!=none/; ;Tkc (Loverslab): optimization
					Message("["+(cfg.ImpregnateCount - i)+"/"+cfg.ImpregnateCount+"] "+FWUtility.StringReplace(Content.CheckGiveSperm,"{0}",f.GetLeveledActorBase()),MSG_Debug, MSG_Trace)
					if CheckGiveSpermToNPC(f, (GameDaysPassed.GetValue() - HoursSinceSex) + Utility.RandomFloat(-0.0318,0.0208))
						success+=1
					endif
				endif
			endWhile
		endif
		if(success>0)
			Message(FWUtility.StringReplace(Content.SpermAdded,"{0}",success),MSG_Debug)
		endif
		fLastUpdateGameTime = GameDaysPassed.GetValue()
	endif
	bCheckGiveSpermToNPCs= false
endFunction

bool function CheckGiveSpermToNPC(actor f, float GameTime)
{ Adds sperm to the given woman }
	
	if f ;Tkc (Loverslab): optimization
	else;if(f==none)
		;Message("System::CheckGiveSpermToNPC() failed because f is none",MSG_Debug, MSG_Trace)
		return false
	endif
	
	bool IsCreatureF = f.GetRace().HasKeyword(ActorTypeCreature)
	bool IsSpouseF = f.IsInFaction(PlayerMarriedFaction)
	bool IsFollowerF = f.IsInFaction(FollowerFaction)
	;if IsCreatureF && cfg.CreatureSperm==false
	if IsCreatureF ;Tkc (Loverslab): optimization
	 if cfg.CreatureSperm	
	 else;if cfg.CreatureSperm==false
		return false
	 endif
	endif
	;if IsSpouseF && cfg.ImpregnatePlayerSpouse==false
	if IsSpouseF ;Tkc (Loverslab): optimization
	 if cfg.ImpregnatePlayerSpouse
	 else;if cfg.ImpregnatePlayerSpouse==false
		return false
	 endif
	endif
	if IsFollowerF
		return false
	endif
	
	bool res = false
	Location PlayerLoc = PlayerRef.GetCurrentLocation() ; Both shouldn't be in the Player Location
	
	; The NPC need to rest half a day
	bool bFInPlayerLoc
	if PlayerLoc;/!=none/; ;Tkc (Loverslab): optimization
		bFInPlayerLoc = f.IsInLocation(PlayerLoc)
	else
		bFInPlayerLoc = false
	endif
	if Controller.GetDaysSinceLastSex(f)>0.5
	 if bFInPlayerLoc ;Tkc (Loverslab): optimization
	 else;if bFInPlayerLoc==false
		if f.GetLeveledActorBase().GetSex();==1 ;Tkc (Loverslab): optimization
			if f==PlayerRef ;Tkc (Loverslab): optimization
			else;if f!=PlayerRef
				string JsonFile = "../../../BeeingFemale/Couples/" + FWUtility.GetJsonFile(f)
				
				Actor[] males
				int ca = JsonUtil.FormListCount(JsonFile,"Affairs")
				int cp = JsonUtil.FormListCount(JsonFile,"Partners")
				int cn = StorageUtil.FormListCount(f,"FW.LastSeenNPCs")
				; Ok, lets add some male NPCs
				if cfg.ImpregnateHusband && JsonUtil.HasFormValue(JsonFile,"Husband")
					; Husbands have a high priority, so add 10 to the RandomArray
					males = FWUtility.ActorArrayAppend(males,JsonUtil.GetFormValue(JsonFile,"Husband") as actor,10)
				endif
				if cfg.ImpregnateAffairs && ca>0
					; Affairs have a middle priority, so add 4 of each to the RandomArray
					while ca>0
						ca-=1
						males = FWUtility.ActorArrayAppend(males,JsonUtil.FormListGet(JsonFile,"Affairs",ca) as actor,4)
					endwhile
				endif
				if cfg.ImpregnatePartners && ca>0
					; Partners and friends have a low priority, so add 2 of each to the RandomArray
					while cp>0
						cp-=1
						males = FWUtility.ActorArrayAppend(males,JsonUtil.FormListGet(JsonFile,"Partners",cp) as actor,2)
					endwhile
				endif
				if cfg.ImpregnateLastNPC && cn>0
					; Partners and friends have the lowest priority, so add 1 of each to the RandomArray
					while cn>0
						cn-=1
						males = FWUtility.ActorArrayAppend(males,StorageUtil.FormListGet(f,"FW.LastSeenNPCs",cn) as actor)
					endwhile
				endif
				
				; Get one of the random NPCs, do 3 tries
				if males.length>0
					int try=3
					while try>0
						try-=1
						int rnd = Utility.RandomInt(0,males.length - 1)
						actor m = males[rnd]
						if m;/!=none/; ;Tkc (Loverslab): optimization
							bool bMInPlayerLoc = false
							if PlayerLoc;/!=none/; ;Tkc (Loverslab): optimization
								bMInPlayerLoc = m.IsInLocation(PlayerLoc)
							else
								bMInPlayerLoc = false
							endif
							
							if bMInPlayerLoc ;Tkc (Loverslab): optimization
							else;if !bMInPlayerLoc ; Check if he is not in the players location
								if Controller.GetDaysSinceLastSex(m)>0.3
									if IsValidateMaleActor(m)>0 ; Check if's validate
										if m.GetRelationshipRank(f)>=0 ; They shouldn't be enemys
											bool IsCreatureM = m.GetRace().HasKeyword(ActorTypeCreature)
											bool IsSpouseM = m.IsInFaction(PlayerMarriedFaction)
											bool IsFollowerM = m.IsInFaction(FollowerFaction)
											if IsCreatureM==false || cfg.CreatureSperm;/==true/; ;Tkc (Loverslab): optimization
												if IsSpouseM==false || cfg.ImpregnatePlayerSpouse;/==true/; ;Tkc (Loverslab): optimization
													if IsFollowerM ;Tkc (Loverslab): optimization
													else;if IsFollowerM==false
														Controller.AddSperm(f,m) ; Add Sperm
														try = 0 ; Exit the while
														res = true ; return, that it was successful
														;Message("    - "+m.GetLeveledActorBase().GetName()+" was validated successfuly",MSG_Debug, MSG_Trace)
														;Message("Add sperm to " + f.GetLeveledActorBase().GetName() + " from " + m.GetLeveledActorBase().GetName() + " at "+GameTime,MSG_High)
														Message(FWUtility.MultiStringReplace(Content.SpermAdded,f.GetLeveledActorBase().GetName(),m.GetLeveledActorBase().GetName()),MSG_High)
													endif
												endif
											endif
										endif
									endif
								endif
							endif
						endif
					endWhile
				endif
			endif
		endif
	 endif
	endif
	return res
endFunction

float function ModuloOne(float v)
{ Returns a float of (v % 1) }
	return v - Math.Floor(v)
endfunction

function InfoMenuBlur()
	RegisterForModEvent("InfoMenuClosed","onInfoMenuClosed")
	MenuImageSpace.Apply()
endFunction
Event onInfoMenuClosed(string hookName, string argString, float argNum, form sender)
	MenuImageSpace.Remove()
	UnregisterForModEvent("InfoMenuClosed")
endEvent

function UpdateHotKey()
	StateWidget.updateConfig()
	ContraceptionWidget.updateConfig()
	BabyHealthWidget.updateConfig()
	WidgetController.updateConfig()
endFunction


bool function setObjective(int ID)
endFunction

function refreshObjective()
	
endFunction

;--------------------------------------------------------------------------------
; General Functions
;--------------------------------------------------------------------------------

function Trace(string msg, actor a = none)
	
endFunction

Bool Function Message(string akMessage, int aiPriority = 1, int aiType = 0)
	if bMessageEnabledAfterNewGameStarted ;Tkc (Loverslab): optimization
	else;if bMessageEnabledAfterNewGameStarted==false
		; Check if the Intro is playing - we don't want to spam the intro!
		;Quest q= Game.GetFormFromFile(0x3372B,"Skyrim.esm") as quest
		Quest q = MQ101
		if q.IsCompleted() || q.IsObjectiveCompleted(30) || q.GetCurrentStageID()>=300
			bMessageEnabledAfterNewGameStarted=true
		endif
	endif
	If cfg.Messages <= aiPriority
		If aiType==MSG_Box && (bMessageEnabledAfterNewGameStarted;/==true/;||aiPriority==MSG_ALWAYS) ; Messagebox only when not in cobat ;Tkc (Loverslab): optimization
			;Tkc (Loverslab): optimization
			if PlayerRef.GetCombatState(); !=0
				Debug.Notification(akMessage)
			else;PlayerRef.GetCombatState()==0
				Debug.MessageBox(akMessage)
			endif
		Elseif aiType == MSG_Note && (bMessageEnabledAfterNewGameStarted;/==true/;||aiPriority==MSG_ALWAYS) ;Tkc (Loverslab): optimization
			Debug.Notification(akMessage)
		elseif aiType == MSG_Trace
			Debug.Trace(akMessage)
		else
			if bMessageEnabledAfterNewGameStarted ;Tkc (Loverslab): optimization
			else;bMessageEnabledAfterNewGameStarted==false
				Debug.Trace("BeeingFemale Message: "+akMessage)
			EndIf
		EndIf
		Return True
	EndIf
	Return false
EndFunction

function CheckPlayerSex()
	;actor p=PlayerRef; ;Tkc (Loverslab): optimization
	If PlayerRef.GetLeveledActorBase().GetSex() == 0
		if Player;/!=none/; ;Tkc (Loverslab): optimization
			PlayerRef.RemoveSpell(BeeingFemaleSpell)
			PlayerRef.DispelSpell(BeeingFemaleSpell)
			Player=none
		endif
		if PlayerMale ;Tkc (Loverslab): optimization
		else;if PlayerMale==none
			PlayerRef.AddSpell(BeeingMaleSpell, cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
		endif
	elseIf PlayerRef.GetLeveledActorBase().GetSex() == 1
		if PlayerMale;/!=none/; ;Tkc (Loverslab): optimization
			PlayerRef.RemoveSpell(BeeingMaleSpell)
			PlayerRef.DispelSpell(BeeingMaleSpell)
			PlayerMale=none
		endif
		if Player ;Tkc (Loverslab): optimization
		else;if Player==none
			PlayerRef.AddSpell(BeeingFemaleSpell, cfg.Messages<4) ;Tkc (Loverslab): added ShowMsg parameter to not show messages when Innmersion or None Messages mode
		endif
	endif
endFunction

function raiseModEvent(string EventName, FWAbilityBeeingFemale base)
	SendModEvent("BeeingFemale",EventName, base.ActorRef.GetFormID())
endFunction

function raiseModEventA(string EventName, Actor a)
	SendModEvent("BeeingFemale",EventName, a.GetFormID())
endFunction


; Check if the given Actor is relevant
;  1 = OK Player
;  2 = OK Follower
;  3 = OK NPC
; -1 = actor is summoned
; -2 = actor is dead or ghost
; -3 = actor is not male/female
; -4 = actor is not unique
; -5 = actor deactivated for Player (in settings)
; -6 = actor deactivated for Follower
; -7 = actor deactivated for NPCs
; -8 = actor is child
; -9 = actor is elder (women only)
; -10 = actor or actorbase doesn't exist
; -11 = actor is creature and creatures are disabled in settings
int function IsValidateActor(actor a, bool bIgnoreRelevance = false)
	if a ;Tkc (Loverslab): optimization
	else;if a==none
		return -10
	endif
	Actorbase ab = a.GetLeveledActorBase() ;Tkc (Loverslab): optimization, used several times
	if ab ;Tkc (Loverslab): optimization
	else;if a.GetLeveledActorBase()==none
		return -10
	endif
	if ab.GetSex()==0
		return IsValidateMaleActor(a,bIgnoreRelevance)
	elseif ab.GetSex()==1
		return IsValidateFemaleActor(a,bIgnoreRelevance)
	endif
endFunction

int function IsValidateFemaleActor(actor a, bool bIgnoreRelevance = false)
	if a ;Tkc (Loverslab): optimization
	else;if a==none
		return -10
	endif
	Actorbase ab = a.GetLeveledActorBase() ;Tkc (Loverslab): optimization, used several times
	if ab ;Tkc (Loverslab): optimization
	else;if ab==none
		return -10
	endif
	if ab.GetSex() == 0
		return -3
	endif
	;if ab.IsUnique() ;Tkc (Loverslab): optimization
	;else;if ab.IsUnique()==false
		;return -4
	;endif
	if a.IsDead()
		return -2
	endIf
	if cfg.FemaleSummonedCanBecomePregnant
	else
		if a.IsCommandedActor() ;Tkc (Loverslab): added to exclude summoned
			return -1
		endIf
	endIf
	if cfg.FemaleGhostCanBecomePregnant
	else
		if a.HasKeyword(ActorTypeGhost) ;Tkc (Loverslab): added to exclude ghosts
			return -2
		endif
	endIf
	if(ForbiddenFactions.GetAt(0))
		int ForbiddenFactionsLength = ForbiddenFactions.GetSize()
		int i = 0
		while(i < ForbiddenFactionsLength)
			if a.IsInFaction(ForbiddenFactions.GetAt(i) as Faction) ;|| a.HasKeywordString("SexLabForbid")
				return -1
			endIf
			i += 1
		endWhile
	endIf
	if(ForbiddenKeywords.GetAt(0))
		int ForbiddenKeywordsLength = ForbiddenKeywords.GetSize()
		int i = 0
		while(i < ForbiddenKeywordsLength)
			if a.HasKeyword(ForbiddenKeywords.GetAt(i) as Keyword) ;|| a.HasKeywordString("SexLabForbid")
				return -1
			endIf
			i += 1
		endWhile
	endIf
	;/
	if PlayerRef == a && (cfg.RelevantPlayer==false && bIgnoreRelevance==false)
		return -5
	elseif PlayerRef != a
		if a.IsInFaction(FollowerFaction) && (cfg.RelevantFollower==false && bIgnoreRelevance==false)
			return -6
		endif
		if a.IsInFaction(FollowerFaction)==false && (cfg.RelevantNPC==false && bIgnoreRelevance==false)
			return -7
		endif
	endif
	/;
	;;-- ;Tkc (Loverslab): optimization
	if bIgnoreRelevance;condition repeating for all: player, follower and npc; because moved first; main here it is checking for Relevance and if bIgnoreRelevance enabled then have no sense to continue
	else;bIgnoreRelevance==false
		if a == PlayerRef;is player
			if cfg.RelevantPlayer
			else;cfg.RelevantPlayer==false
				return -5
			endif
		else;if a != PlayerRef
			if a.IsInFaction(FollowerFaction); is follower
				if cfg.RelevantFollower
				else;cfg.RelevantFollower==false
					return -6
				endif
			else;if a.IsInFaction(FollowerFaction)==false ;is NPC
				if cfg.RelevantNPC
				else;cfg.RelevantNPC==false
					return -7
				endif
			endif
		endif
	endif
	;;--
	Race ActorRace = ab.GetRace()
	
	; Check for Creature allowed Sperm
	;if ActorRace.HasKeywordString("ActorTypeCreature") && cfg.CreatureSperm == false
	if cfg.CreatureSperm ;Tkc (Loverslab): optimization
	else;cfg.CreatureSperm == false
		if ActorRace.HasKeyword(ActorTypeCreature) ;Tkc (Loverslab): optimization
			return -11
		endif
	endif

	String RaceName = ActorRace.GetName()+MiscUtil.GetRaceEditorID(ActorRace)
	
;	if ActorRace.IsRaceFlagSet(0x00000004) || StringUtil.Find(RaceName, "Child") != -1 || StringUtil.Find(RaceName, "Little") != -1 || StringUtil.Find(RaceName, "117") != -1 || (StringUtil.Find(RaceName, "Monli") != -1 && a.GetScale() < 0.93) || StringUtil.Find(RaceName, "Elin") != -1 || StringUtil.Find(RaceName, "Enfant") != -1
;		return -8
;	endIf
	if ActorRace.IsRaceFlagSet(0x00000004) ;Tkc (Loverslab): optimization: it is looking like messed up and bigger but in result compilled script became smaller and the code will work faster. but it is still quite heavy
		return -8
	else
		if(ForbiddenRaces.GetAt(0))
			int ForbiddenRacesLength = ForbiddenRaces.GetSize()
			int i = 0
			while(i < ForbiddenRacesLength)
				if a.GetRace() == ForbiddenRaces.GetAt(i) as Race
					return -8
				endIf
				i += 1
			endWhile
		else
		;if StringUtil.Find(RaceName, "Child") == -1
			;if StringUtil.Find(RaceName, "Little") == -1
				;if StringUtil.Find(RaceName, "117") == -1
					;if StringUtil.Find(RaceName, "Elin") == -1
						if StringUtil.Find(RaceName, "Enfant") == -1
							;if StringUtil.Find(RaceName, "Monli") == -1
							;else;if (StringUtil.Find(RaceName, "Monli") != -1						
								;if a.GetScale() < 0.93
									;return -8
								;endIf
							;endIf
						else;if StringUtil.Find(RaceName, "Enfant") != -1
							return -8
						endIf
					;else;if StringUtil.Find(RaceName, "Elin") != -1
						;return -8
					;endIf	
				;else;if StringUtil.Find(RaceName, "117") != -1
					;return -8
				;endIf
			;else;if StringUtil.Find(RaceName, "Little") != -1
				;return -8
			;endIf	
		;else;if StringUtil.Find(RaceName, "Child") != -1
			;return -8
		;endIf
		endIf
	endIf

	if cfg.ElderFemaleCanBecomePregnant
	else
		if StringUtil.Find(RaceName, "Elder") == -1
		else;if StringUtil.Find(RaceName, "Elder") != -1
			return -9
		endIf
	endIf
	
	if PlayerRef == a
		return 1
	elseif a.IsInFaction(FollowerFaction)
		return 2
	else
		return 3
	endif
endFunction

int function IsValidateMaleActor(actor a, bool bIgnoreRelevance = false)
	if a ;Tkc (Loverslab): optimization
	else;if a==none
		return -10
	endif
	Actorbase ab = a.GetLeveledActorBase() ;Tkc (Loverslab): optimization, used several times
	if ab ;Tkc (Loverslab): optimization
	else;if ab==none
		return -10
	endif
	if ab.GetSex(); == 1
		return -3
	endif
	if a.IsDead()
		return -2
	endIf
	if cfg.MaleSummonedCanImpregnate
	else
		if a.IsCommandedActor() ;Tkc (Loverslab): added to exclude summoned
			return -1
		endIf
	endIf
	if cfg.MaleGhostCanImpregnate
	else
		if a.HasKeyword(ActorTypeGhost) ;Tkc (Loverslab): added to exclude ghosts
			return -2
		endif
	endIf
	if(ForbiddenFactions.GetAt(0))
		int ForbiddenFactionsLength = ForbiddenFactions.GetSize()
		int i = 0
		while(i < ForbiddenFactionsLength)
			if a.IsInFaction(ForbiddenFactions.GetAt(i) as Faction) ;|| a.HasKeywordString("SexLabForbid")
				return -1
			endIf
			i += 1
		endWhile
	endIf
	if(ForbiddenKeywords.GetAt(0))
		int ForbiddenKeywordsLength = ForbiddenKeywords.GetSize()
		int i = 0
		while(i < ForbiddenKeywordsLength)
			if a.HasKeyword(ForbiddenKeywords.GetAt(i) as Keyword) ;|| a.HasKeywordString("SexLabForbid")
				return -1
			endIf
			i += 1
		endWhile
	endIf
	Race ActorRace = ab.GetRace()
	
	; Check for Creature allowed Sperm
	;if ActorRace.HasKeywordString("ActorTypeCreature") && cfg.CreatureSperm == false
	if cfg.CreatureSperm ;Tkc (Loverslab): optimization
	else;cfg.CreatureSperm == false
		if ActorRace.HasKeyword(ActorTypeCreature) ;Tkc (Loverslab): optimization
			return -11
		endif
	endif

	String RaceName = ActorRace.GetName()+MiscUtil.GetRaceEditorID(ActorRace)

;	if ActorRace.IsRaceFlagSet(0x00000004) || StringUtil.Find(RaceName, "Child") != -1 || StringUtil.Find(RaceName, "Little") != -1 || StringUtil.Find(RaceName, "117") != -1 || (StringUtil.Find(RaceName, "Monli") != -1 && a.GetScale() < 0.93) || StringUtil.Find(RaceName, "Elin") != -1 || StringUtil.Find(RaceName, "Enfant") != -1
;		return -8
;	endIf
	if ActorRace.IsRaceFlagSet(0x00000004) ;Tkc (Loverslab): optimization: it is looking like messed up and bigger but in result compilled script became smaller and the code will work faster. but it is still quite heavy
		return -8
	else
		if(ForbiddenRaces.GetAt(0))
			int ForbiddenRacesLength = ForbiddenRaces.GetSize()
			int i = 0
			while(i < ForbiddenRacesLength)
				if a.GetRace() == ForbiddenRaces.GetAt(i) as Race
					return -8
				endIf
				i += 1
			endWhile
		else
		;if StringUtil.Find(RaceName, "Child") == -1
			;if StringUtil.Find(RaceName, "Little") == -1
				;if StringUtil.Find(RaceName, "117") == -1
					;if StringUtil.Find(RaceName, "Elin") == -1
						if StringUtil.Find(RaceName, "Enfant") == -1
							;if StringUtil.Find(RaceName, "Monli") == -1
							;else;if (StringUtil.Find(RaceName, "Monli") != -1						
								;if a.GetScale() < 0.93
									;return -8
								;endIf
							;endIf
						else;if StringUtil.Find(RaceName, "Enfant") != -1
							return -8
						endIf
					;else;if StringUtil.Find(RaceName, "Elin") != -1
						;return -8
					;endIf	
				;else;if StringUtil.Find(RaceName, "117") != -1
					;return -8
				;endIf
			;else;if StringUtil.Find(RaceName, "Little") != -1
				;return -8
			;endIf	
		;else;if StringUtil.Find(RaceName, "Child") != -1
			;return -8
		;endIf
		endIf
	endIf
				
	if PlayerRef == a
		return 1
	elseif a.IsInFaction(FollowerFaction)
		return 2
	else
		return 3
	endif
endFunction


function Blur(float Strength = 1.0, ImageSpaceModifier Effect = none)
	DefaultBlur.Remove()
	if Effect ;Tkc (Loverslab): optimization
		Effect.Apply(Strength)
	else;if Effect == none
		DefaultBlur.Apply(Strength)
	endIf
endFunction


bool function CheckForCondome(actor Woman, actor Man)
	return Manager.CheckForCondome(Woman, Man)
endFunction

function PlayPainSound(Actor A,float Strength=30.0)
	if A.Is3DLoaded()
		If Manager.OnPlayPainSound(A, Strength);Tkc (Loverslab): optimization
		else;If Manager.OnPlayPainSound(A, Strength)==false
		;	 TODO: Play a pain sound
		endif
		A.CreateDetectionEvent(A, FWUtility.RangedFloat(Strength, 30, 100) as int)
    endif
endFunction

; Playing a bleed out
function PlayBleedOut(Actor A)
	;if A.GetSitState() == 0 && A.IsOnMount() == false
	if A.GetSitState();Tkc (Loverslab): optimization
	else;A.GetSitState() == 0
	if A.IsOnMount()
	else;A.IsOnMount() == false
		If A.IsWeaponDrawn()
			A.SheatheWeapon()
		EndIf
		if PlayerRef == A
			if PlayerBleedOut ;Tkc (Loverslab): optimization
			else;if(PlayerBleedOut == 0)
				Debug.SendAnimationEvent(A, "IdleForceDefaultState");
				Debug.SendAnimationEvent(A, "BleedOutStart");
			endif
			PlayerBleedOut += 1
		else
			Debug.SendAnimationEvent(A, "IdleForceDefaultState");
			Debug.SendAnimationEvent(A, "BleedOutStart");
		endIf
	endif
	endif
endFunction

; Stop playing bleed-out
function stopBleedOut(Actor A)
	if PlayerRef == A
		PlayerBleedOut -= 1
		if PlayerBleedOut ;Tkc (Loverslab): optimization
		else;if(PlayerBleedOut == 0)
			Debug.SendAnimationEvent(A, "BleedOutStop");
			Debug.SendAnimationEvent(A, "IdleForceDefaultState");
		endIf
	else
		Debug.SendAnimationEvent(A, "BleedOutStop");
		Debug.SendAnimationEvent(A, "IdleForceDefaultState");
	endIf
endFunction

function PlayerTimer(bool Enabled = true)
	if Player ;Tkc (Loverslab): optimization
	else;if Player==none
		return
	endIf
	if Enabled;/==true/; ;Tkc (Loverslab): optimization
		Controller.Pause(PlayerRef, false)
		Player.OnUpdateFunction()
	else
		Controller.Pause(PlayerRef, true)
	endIf
endFunction


function getUp(Actor A)
	Utility.WaitMenuMode(0)
	if A== PlayerRef
		Game.DisablePlayerControls(ablooking = True, abCamSwitch = True)
	endif
	Debug.SendAnimationEvent(A, "GetupBirth");
	Utility.Wait(3.5)
	Debug.SendAnimationEvent(A, "IdleForceDefaultState");
	if A== PlayerRef
		Game.EnablePlayerControls(ablooking = true, abCamSwitch = true)
	endif
endFunction

bool Function LayDown(Actor A)
	; Check for center
	ObjectReference BedRef = Manager.OnGetBedRef(A)
	; Select a bed
	if BedRef; != none ;Tkc (Loverslab): optimization
		if BedRef.IsFurnitureInUse(true) ;Tkc (Loverslab): optimization
		else;if !BedRef.IsFurnitureInUse(true)
			A.MoveTo(BedRef)
			A.SetAngle(BedRef.getAngleX(), BedRef.getAngleY(), BedRef.getAngleZ())
			Utility.Wait(1)
			Debug.SendAnimationEvent(A, "LayDownBirth");
			Utility.Wait(3.6)
			return true
		endif
	endIf
	Debug.SendAnimationEvent(A, "LayDownBirth");
	Utility.Wait(3.6)
	return false
endFunction


;--------------------------------------------------------------------------------
; Female Functions
;--------------------------------------------------------------------------------

; Does NPCs have a Menstruation cycle at all - and can become pregnant
bool function NpcMentruation()
	return true
endFunction

; Get the time the egg needs for traveling
float function getEggTravelingDuration(actor a)
	float x = getStateDuration(1,a) * EggTravelingDuration_Percentage
	if x<1.1 ; Make sure the Egg traveling is more then 1 Day
		return 1.01
	else
		return x
	endif
endFunction

bool function IsActorPregnantByChaurus(actor woman)
	return zzEstrusChaurusBreederFaction && woman.IsInFaction(zzEstrusChaurusBreederFaction)
	;if EstrusActive == true
	;	if ChaurusBreeder != none
	;		return woman.HasSpell(ChaurusBreeder)
	;	endif
	;endif
	;return false
endFunction

; Get the time in days - how long the pill will work
float function GetPillDuration(actor a)
	return 4.0 * Manager.getActorContraceptionDuration(a) ; Every 2 days
endFunction

int function calculateNumChildren(actor Woman)
	int result = 1
	float counter = 1000000.0
;	float Chance = Utility.RandomFloat(0.0,counter)
	float Chance = Utility.RandomFloat(0.0, (counter - 0.1))			; Chance = Utility.RandomFloat(0.0,counter) includes counter!
	int i = 0
;	float MaxBabys = cfg.MaxBabys * Manager.ActorMaxBabse(Woman)
;	Casting a float to int is much faster than using Math.Floor, according to https://ck.uesp.net/wiki/Floor_-_Math
	int MaxBabys = (cfg.MaxBabys * Manager.ActorMaxBabse(Woman)) as int
	float MaxBabyChance = Manager.ActorMaxChance(Woman)
	if MaxBabys <1
		MaxBabys=1
	endIf

	float myMaxBabyChance
	float myOrigMaxBabyChance = (1.0 / (cfg.MultipleThreshold)) * MaxBabyChance
	
	float myMultipleBabySperm = Manager.ActorMultipleBabySperm(Woman)
	if(myMultipleBabySperm > 0.0)
		Debug.Trace("BeeingFemaleSE_Opt - FWSystem - calculateNumChildren: MultipleBabySperm = " + myMultipleBabySperm + " for actor " + Woman)
		float[] relevantSperm = Controller.GetRelevantSpermFloatTimed(Woman, GameDaysPassed.GetValue(), false, false)
		float relevanceTotal = 0.0
		int c = relevantSperm.length
		if(c)
			i = 0
			while(i < c)
				relevanceTotal += relevantSperm[i]
				i += 1
			endWhile
		endIf
			
		float myMultipleBabySpermChance = Manager.ActorMultipleBabyChancePerSperm(Woman)
		if(myMultipleBabySpermChance > 0.0)
			Debug.Trace("BeeingFemaleSE_Opt - FWSystem - calculateNumChildren: MultipleBabyChancePerSperm = " + myMultipleBabySpermChance + " for actor " + Woman)
			Debug.Trace("BeeingFemaleSE_Opt - FWSystem - calculateNumChildren: The amount of sperm in " + Woman + " is " + relevanceTotal)
				
			Debug.Trace("BeeingFemaleSE_Opt - FWSystem - calculateNumChildren: Original multiple baby chance for " + Woman + " was " + myOrigMaxBabyChance)
			float myMaxBabyChanceMultiplier = relevanceTotal * myMultipleBabySpermChance / myMultipleBabySperm
			MaxBabyChance *= myMaxBabyChanceMultiplier
			Debug.Trace("BeeingFemaleSE_Opt - FWSystem - calculateNumChildren: Multiple baby chance for " + Woman + " will be multiplied by " + myMaxBabyChanceMultiplier)
		endIf
	endIf
	myMaxBabyChance = (1.0 / (cfg.MultipleThreshold)) * MaxBabyChance
	if(myMaxBabyChance > 1.0)
		Debug.Trace("BeeingFemaleSE_Opt - FWSystem - calculateNumChildren: Multiple baby chance cannot exceed 100 percent! Changing the probability for " + Woman + " to 100 percent")
		myMaxBabyChance = 1.0
	endIf
	Debug.Trace("BeeingFemaleSE_Opt - FWSystem - calculateNumChildren: Current multiple baby chance for " + Woman + " is " + myMaxBabyChance)
	
	; on a realistic base of 1 / 85 (~1.2%) following results will be
	; 1 Child    - 100.0000000000%
	; 2 Children -   1.1764705882%
	; 3 Children -   0.0138408304%
	; 4 Children -   0.0001628332%
	; 5 Children -   0.0000019156%
	; 6 Children -   0.0000000225%
	i = 0
	while i < 6 ; a Max of 6 children!!!!
;		counter /= cfg.MultipleThreshold * MaxBabyChance ;ChanceMultipleBirth
		counter *= myMaxBabyChance ; Default value of cfg.MultipleThreshold is 85, so the upper commented command is wrong!
		if counter > Chance
			result += 1
		endIf
		i += 1
	endWhile
;	if result > Math.Floor(MaxBabys)
;		result = Math.Floor(MaxBabys)
	if result > MaxBabys
		result = MaxBabys
	endIf
	if result > MaxBabyPregnantWith
		result = MaxBabyPregnantWith
	endIf
	return result
endFunction


; Spawn the childs / adding them to the inventory
function InstantBornChilds(actor a)
	int numChilds = StorageUtil.GetIntValue(a,"FW.NumChilds",numChilds)
	if numChilds==0
		return
	endif
	float BabyHealth = StorageUtil.GetFloatValue(a,"FW.UnbornHealth",100.0)
	while numChilds>0
		numChilds-=1
		float rndHealth=Utility.RandomFloat(1,25)
		if BabyHealth>rndHealth
			SpawnChild(a, StorageUtil.FormListGet(a,"FW.ChildFather",numChilds) As Actor )
		else
			; Totgeburt
		endIf
	endWhile
	StorageUtil.FormListClear(a,"FW.ChildFather")
	StorageUtil.SetIntValue(a,"FW.NumChilds",0)
	StorageUtil.UnsetIntValue(a,"FW.Abortus")
	StorageUtil.UnsetFloatValue(a,"FW.UnbornHealth")
	StorageUtil.UnsetFloatValue(a,"FW.AbortusTime")
endFunction

; in original 2 phases:
; Follicular phase : 12 - 16 Days (contains Menstuation and Follicular)
; Luteal phase : 12 - 16 Days (contains Ovulation and Luteal)
;--------------
; so for 4 Phases:
; Follicular: arround 8 - 12 Days
; Ovulation: 3, 5 - 4  days (it takes 3 Day for egg to arrive, and there is 12 - 24 hours for sperm)
; Luteal: arround 9 - 11 Days
; Menstruation: 3 - 5 days
; 1. Trimester: 90 Days
; 2. Trimester: 90 Days
; 3. Trimester: 90 Days
; Labor-Pains around 5 - 24 hours
; Replanish As long the pregnacy takes
float function getStateDuration(int Step, actor woman)
	if Step >= 0
		if Step < 4
			if Step < 2
				if Step == 0 ; Follicular phase
					return cfg.FollicularDuration * Manager.getActorDurationScale(Step,woman) * StorageUtil.GetFloatValue(woman,"FW.Irregulation",1.0);
				else;if Step == 1 ; Ovulation
					return cfg.OvulationDuration * Manager.getActorDurationScale(Step,woman) * StorageUtil.GetFloatValue(woman,"FW.Irregulation",1.0);
				endIf
			else
				if Step == 2 ; Luteal phase
					return cfg.LutealDuration * Manager.getActorDurationScale(Step,woman) * StorageUtil.GetFloatValue(woman,"FW.Irregulation",1.0);
				else;if Step == 3 ; Menstruation
					return cfg.MenstrualDuration * Manager.getActorDurationScale(Step,woman) * StorageUtil.GetFloatValue(woman,"FW.Irregulation",1.0);
				endIf
			endIf
		else
			if Step < 6
				if Step == 4 ; 1. trimester 
					return cfg.Trimster1Duration * Manager.getActorDurationScale(Step,woman) * StorageUtil.GetFloatValue(woman,"FW.Irregulation",1.0);
				else;if Step == 5 ; 2. trimester 
					return cfg.Trimster2Duration * Manager.getActorDurationScale(Step,woman) * StorageUtil.GetFloatValue(woman,"FW.Irregulation",1.0);
				endIf
			else
				if Step < 8
					if Step == 6 ; 3. trimester 
						return cfg.Trimster3Duration * Manager.getActorDurationScale(Step,woman) * StorageUtil.GetFloatValue(woman,"FW.Irregulation",1.0);
					else;if Step == 7 ; labor pains
						return 1 ; Fix
					endIf
				else
					if Step == 8 ; replenish
						return cfg.ReplanishDuration * Manager.getActorDurationScale(Step,woman) * StorageUtil.GetFloatValue(woman,"FW.Irregulation",1.0);
					else
						return 0
					endIf
				endIf
			endIf
		endIf
	else
		return 0
	endIf
endFunction


; get the Belly breast scaling value
; NodeSet 0 = Belly
; NodeSet 1 = Breasts
; PhaseID 0 = 1st Trimester
; PhaseID 1 = 2nd Trimester
; PhaseID 2 = 3rd Trimester
float Function GetPhaseScale(int NodeSet, int PhaseID)
	; NodeSet 0 = Belly
	; NodeSet 1 = Breasts
	
	if cfg.VisualScalingKind >= 0
		if cfg.VisualScalingKind < 4
			if cfg.VisualScalingKind < 2
				if cfg.VisualScalingKind==0 ; Realistic
					return FWScalingSettings.Realistic(NodeSet, PhaseID)
				else;if cfg.VisualScalingKind==1 ; Linear
					return FWScalingSettings.Linear(NodeSet, PhaseID)
				endIf
			else
				if cfg.VisualScalingKind==2 ; Immediately
					return FWScalingSettings.Immediately(NodeSet, PhaseID)
				else;if cfg.VisualScalingKind==3 ; Breasts
					return FWScalingSettings.Breasts(NodeSet, PhaseID)
				endIf
			endIf
		elseif cfg.VisualScalingKind < 6
			if cfg.VisualScalingKind==4 ; Belly
				return FWScalingSettings.Belly(NodeSet, PhaseID)
			else;if cfg.VisualScalingKind==5 ; Late
				return FWScalingSettings.Late(NodeSet, PhaseID)
			endif
		endIf
	endIf
	Return 0.0
EndFunction


; DamageType Argument:
; 	0 = Mittelschmerz
; 	1 = Menstruation
; 	2 = PMS pains
; 	3 = Labor Pains
; 	4 = Giving Birth
;	5 = Aborts
float function getDamageScale(int DamageType, actor a)
	return Manager.getActorDamageScale(DamageType,a)
endFunction

float function getPainLevel(int stateID)
	if stateID==1
		return Utility.RandomFloat(0.1,2.5)
	elseif stateID==3
		return Utility.RandomFloat(0.1,2.5)
	endif
endFunction

bool function canBecomePMS(actor woman)
	float chance = cfg.PMSChance * Manager.PMSChanceActorScale(woman)
;	if Utility.RandomFloat(0.0,100.0) < chance
	if(Utility.RandomFloat(0.0, 99.9) < chance)
		return true
	else
		return false
	endIf
endFunction

bool function canBecomePregnant(actor woman)
	if(woman)
		Actorbase ab = woman.GetActorBase()
		if(ab)
			if(ab.GetSex() == 1)
				float chance
;				if PlayerRef == woman
				if(woman == PlayerRef)
					chance = cfg.ConceiveChance
				elseIf(woman.IsInFaction(FollowerFaction))
					chance = cfg.ConceiveChanceFollower
				else
					chance = cfg.ConceiveChanceNPC
				endif
				chance *= Manager.PregnancyChanceActorScale(woman)

				Debug.Trace("BeeingFemaleSE_Opt - FWSystem - canBecomePregnant: the actor " + woman + "'s pregnancy chance is " + chance)

				if(Utility.RandomFloat(0.0, 99.9) < chance)
					Debug.Trace("BeeingFemaleSE_Opt - FWSystem - canBecomePregnant: the actor " + woman + " can become pregnant")

					return true
				else
					Debug.Trace("BeeingFemaleSE_Opt - FWSystem - canBecomePregnant: the actor " + woman + " cannot become pregnant yet")
				endIf
			endIf
		endIf
	endIf
	
	return false
endFunction


; Do some damage to the specific actor
; Percentage = the percentage of health, the actor will lose
; DamageType = The type of Damage (See list)
; OptionalArgument (See list)
; -----------------------------------------------------------
; Damage Type:								Optional Argument
;  0	Unknown
;  1	Mittelschmerz / Ovulation pains		strength of the pains
;  2	PMS pains							
;  3	Menstruation cramps					strength of the pains
;  4	Pregnancy 1. sickness
;  5	Pregnancy 2. sickness
;  6	Pregnancy 3. sickness
;  7	premonitory pains
;  8	first stage pains
;  9	Child-Pressing pains
; 10	bearing-down pains
; 11	afterpains
; 12	baby milk drinking pains
; 13	infection pains
; 14	abortus pains
Function doDamage(actor A, float Percentage, int DamageType, float OptionalArgument = 0.0)
	float ScaleDamage = 1.0
	bool IsPlayer = A == PlayerRef
	
	if IsPlayer
		if cfg.Difficulty >= 0
			if cfg.Difficulty < 2
				if cfg.Difficulty == 0 ; Painless
					ScaleDamage = 0
				else;if cfg.Difficulty == 1 ; Easy
					ScaleDamage = 0.7
				endIf
			else
				if cfg.Difficulty == 3 ; Advanced
					ScaleDamage = 1.3
				elseif cfg.Difficulty == 4 ; Heavy
					ScaleDamage = 1.7
				endIf
			endIf
		endIf
	ElseIf cfg.NPCFeelPain
		ScaleDamage = 0.6 ; NPC got a reduced damage
	endif
	
	Percentage *=ScaleDamage
	
	Percentage=Manager.OnDoDamage(A,Percentage,DamageType,OptionalArgument)
	
	If ! IsPlayer && cfg.NPCFeelPain==false
		Percentage = 0
	elseif Percentage<1
		; At least 1% Damage (exclusive ScaleDamage)
		Percentage = 1
	elseif Percentage>50
		; A maximum of 50%
		Percentage = 50
	endif
	float efxDage=Percentage
	;if !IsPlayer && Percentage>2
	if IsPlayer ;Tkc (Loverslab): optimization
	else;if !IsPlayer
	 if Percentage>2
		efxDage = Percentage / 3
	 endif
	endif
	
	Manager.OnDoDamageStart(A,Percentage, DamageType,OptionalArgument)
	
	if IsPlayer || cfg.NPCFeelPain
		int steps
		float DamageLeft = efxDage
		; In how many steps the Damage will be
		if Percentage < 80
			if Percentage < 40
				if Percentage < 20
					if Percentage <10
						steps = 1;
					Else;If Percentage <20
						steps = 2;
					endIf
				Else
					If Percentage <30
						steps = 3;
					Else;If Percentage <40
						steps = 4;
					endIf
				endIf
			Else
				if Percentage < 60
					If Percentage <50
						steps = 5;
					Else;If Percentage <60
						steps = 6;
					endIf
				Else
					If Percentage <70
						steps = 7;
					Else;If Percentage <80
						steps = 8;
					endIf
				endIf
			endIf
		Else
			If Percentage <90
				steps = 9;
			Else
				steps = 10;
			EndIf
		endIf
		
		while steps > 0
			if(DamageLeft > 10)
				A.DamageActorValue("Health", (A.GetBaseActorValue("Health") / 100) * 10)
				DamageLeft -= 10
			Else
				A.DamageActorValue("Health", (A.GetBaseActorValue("Health") / 100) * DamageLeft)
			EndIf
			Utility.Wait( 0.5 )
			steps -= 1
		Endwhile
	else
		Utility.Wait((efxDage / 10) + 1.0)
	endIf
	Utility.Wait( 3.0 )
	Manager.OnDoDamageEnd(A,Percentage, DamageType,OptionalArgument)
EndFunction

float function LutealImpregnationTime(float CurrentStatePercent)
	float res = 120 - (CurrentStatePercent * 1.66667)
	if res<0.0
		return 0.0
	else
		return res
	endif
endfunction




;--------------------------------------------------------------------------------
; Male Functions
;--------------------------------------------------------------------------------

; Returns the time male sperm can survive
float function getMaleSpermDuration(actor a)
	if a ;Tkc (Loverslab): optimization
		float sd = Manager.ActorMaleSpermDurationScale(a)
		if sd<=0
			return cfg.SpermDuration
		else
			return cfg.SpermDuration * sd
		endif
	else;a==none
		return cfg.SpermDuration
	endif
endFunction



;--------------------------------------------------------------------------------
; Male / Female Functions
;--------------------------------------------------------------------------------
float function GetSpermRelevance(actor female, actor male)
	float result = 1.0
	if female;/!=none/; && male;/!=none/; ;Tkc (Loverslab): optimization
		if female.HasFamilyRelationship(male);/==true/; ;Tkc (Loverslab): optimization
			result+=0.1
		endif
		if female.HasParentRelationship(male);/==true/; ;Tkc (Loverslab): optimization
			result-=0.15
		endif
		int relationship = female.GetRelationshipRank(male)
		result *= (relationship + 14) / 13
	endif
	return result
endfunction





;--------------------------------------------------------------------------------
; Baby Functions
;--------------------------------------------------------------------------------

function SpawnChild(Actor Mother, Actor Father)
	int BabysForTheActor = StorageUtil.GetIntValue(Mother,"FW.NumBabys",0)
	StorageUtil.SetIntValue(Mother,"FW.NumBabys",BabysForTheActor + 1)
	;if Mother!=PlayerRef && cfg.NPCBornChild==false
	if Mother==PlayerRef ;Tkc (Loverslab): optimization
	else;if Mother!=PlayerRef
	 if cfg.NPCBornChild
	 else;cfg.NPCBornChild==false
		; NPCs don't spawn babys
		return
	 endif
	endif
	form Baby = none
	
	if Mother == PlayerRef || Father == PlayerRef
		; Player Spawn
		if cfg.BabySpawn >= 0
			if cfg.BabySpawn < 2
				if cfg.BabySpawn == 0
					return;
				else;if cfg.BabySpawn == 1 ; && (Mother == PlayerRef || Father==PlayerRef) ; Only when the player is involved there will spawn actors
					Baby = SpawnChildActor(Mother, Father)
				endIf
			else
				if cfg.BabySpawn == 2
					Baby = SpawnChildItem(Mother, Father)
				elseif cfg.BabySpawn == 3 && BabyGem;/!=none/; ;Tkc (Loverslab): optimization
					Mother.AddItem(BabyGem)
				endif
			endIf
		endIf
	else
		; Npc Spawn
		if cfg.BabySpawnNPC >= 0
			if cfg.BabySpawnNPC < 2
				if cfg.BabySpawnNPC == 0
					return;
				else;if cfg.BabySpawnNPC == 1 ; && (Mother == PlayerRef || Father==PlayerRef) ; Only when the player is involved there will spawn actors
					Baby = SpawnChildActor(Mother, Father)
				endIf
			else
				if cfg.BabySpawnNPC == 2
					Baby = SpawnChildItem(Mother, Father)
				elseif cfg.BabySpawnNPC == 3 && BabyGem;/!=none/; ;Tkc (Loverslab): optimization
					Mother.AddItem(BabyGem)
				endif
			endIf
		endIf
	endif
	
	if Baby;/!=none/; ;Tkc (Loverslab): optimization
		; Here, all babys are stored
		StorageUtil.FormListAdd(none,"FW.Babys", Baby)
	endif
	StorageUtil.SetFloatValue(Mother,"FW.LastBornChildTime", GameDaysPassed.GetValue())
	StorageUtil.SetFloatValue(Father,"FW.LastBornChildTime", GameDaysPassed.GetValue())
	StorageUtil.FormListAdd(Mother,"FW.BornChildFather", Father)
	StorageUtil.FloatListAdd(Mother,"FW.BornChildTime",GameDaysPassed.GetValue())
	Controller.UpdateParentFaction(Mother)
	Controller.UpdateParentFaction(Father)
	Manager.OnBabySpawn(Mother, Father)
endFunction

Armor function SpawnChildItem(Actor Mother, Actor Father)
;	Int gender = Utility.RandomInt(0, 100)
	Int gender = Utility.RandomInt(0, 99)
	if gender < 53
		gender=0
	else
		gender=1
	endif
	Armor mo = BabyItemList.getBabyArmor(Mother, Father, gender)
	if mo ;Tkc (Loverslab): optimization
	else;if mo == none
		Message(Content.NoChildItem, MSG_DEBUG)
		return none
	endif
	SubSpawnChildItem(mo, gender, Mother, Father, BabyItemList.LastRace)
	
	showBornMessage(Mother, Father, gender)	
	return mo
endFunction

ObjectReference function SubSpawnChildItem(Armor mo, int gender, Actor Mother, Actor Father, Race ParentRace=none) global
	If Mother;if obj != none
		ObjectReference obj2 = ChildItemSetup(mo,gender,Mother,Father, ParentRace)
		If obj2 as ObjectReference
			CreateChildEnchantment(obj2, Mother, Father)
			Mother.AddItem(obj2, 1, true);
			Mother.EquipItemEx(obj2.GetBaseObject(), 0, false, false) 
		EndIf
	;else
		;Message(Content.NoChildArmor, MSG_DEBUG)
	endif
endFunction

ObjectReference function ChildItemSetup(Form frm, int gender=-1, Actor Mother=none, Actor Father=none, Race ParentRace=none) global
	ObjectReference obj
	string mName = "none"
	string fName = "none"
	string oName = "none"
	if Mother;/!=none/; ;Tkc (Loverslab): optimization
		obj = Mother.PlaceAtMe(frm as Armor, 1, false, true)
		mName=Mother.GetLeveledActorBase().GetName()
		If ParentRace ;Tkc (Loverslab): optimization
		else;If !ParentRace
			ParentRace = Mother.GetLeveledActorBase().GetRace()
		EndIf
	endif
	if Father;/!=none/;
		fName=Father.GetLeveledActorBase().GetName()
		If ParentRace ;Tkc (Loverslab): optimization
		else;If !ParentRace
			ParentRace =Father.GetLeveledActorBase().GetRace()
		EndIf
	endif
	if obj;/!=none/; && Father ;Tkc (Loverslab): optimization
		oName=Father.GetDisplayName()
	elseif frm;/!=none/; ;Tkc (Loverslab): optimization
		oName = "Form."+frm.GetName()
	endif
	FWChildArmor obj2 = obj as FWChildArmor
	
	if Father;/!=none/; ;Tkc (Loverslab): optimization
		StorageUtil.SetFormValue(obj,"FW.Child.Father",Father)
	endif
	if Mother;/!=none/; ;Tkc (Loverslab): optimization
		StorageUtil.SetFormValue(obj,"FW.Child.Mother",Mother)
	endif
	if gender==-1
		int xflag = StorageUtil.GetIntValue(obj, "FW.Child.Flag", 0)
		if (Math.LogicalAnd(xflag,4) == 4)
			gender=1
		else
			gender=0
		endif
	endif
	string childName = getRandomChildName(gender)
	if obj2;/!=none/; ;Tkc (Loverslab): optimization
		if Mother ;Tkc (Loverslab): optimization
		else;if Mother==none
			Mother = StorageUtil.GetFormValue(obj,"FW.Child.Mother",none) as Actor
		endif
		if Father ;Tkc (Loverslab): optimization
		else;if Father==none
			Father = StorageUtil.GetFormValue(obj,"FW.Child.Father",none) as Actor
		endif
		obj2.Name = childName
		obj2.SetSex(gender)
		obj2.SetVampire(false)
		obj2.SetParent(Mother,Father)
		obj2.ChildRace = ParentRace
		obj2.SetName(childName)
		obj2.SetDisplayName(childName)
		Return obj2
	elseif obj;/!=none/; ;Tkc (Loverslab): optimization
		obj.SetName(childName)
		obj.SetDisplayName(childName)
		return obj
	endif
endFunction

; my custom edit for Skyrim SE
actor function SpawnChildActor(Actor Mother, Actor Father)
	bool bIsPlayerChild = false
	if Mother==PlayerRef || Father==PlayerRef
		bIsPlayerChild = true
	endif
;	Int gender = Utility.RandomInt(0, 99)
;	if gender < 53
	int gender = 0
	
	int myProbRandom = Utility.RandomInt(0, 99)
	int myChildSexDetermMale = Manager.ActorChildSexDetermMale(Father)
	Debug.Trace("BeeingFemaleSE_Opt - FWSystem - SpawnChildActor: ChildSexDetermMale = " + myChildSexDetermMale)

	if(myProbRandom < myChildSexDetermMale)
		Debug.Trace("BeeingFemaleSE_Opt - FWSystem - SpawnChildActor: myProbRandom = " + myProbRandom + ", which is less than the ChildSexDetermMale. Child will be a boy.")
		gender=0
	else
		Debug.Trace("BeeingFemaleSE_Opt - FWSystem - SpawnChildActor: myProbRandom = " + myProbRandom + ", which is not less than the ChildSexDetermMale. Child will be a girl.")
		gender=1
	endif
	actorbase newChildBase = BabyItemList.getBabyActor(Mother, Father,gender)
	if newChildBase ;Tkc (Loverslab): optimization
	else;if newChildBase==none
		return none
	endif
	gender = newChildBase.GetSex()
	
	Actor newChild

	if(Utility.RandomInt(1, 2) == 1 || !Mother) && Father;/!=none/; ;Tkc (Loverslab): optimization
		newChildBase.SetHairColor(Father.GetLeveledActorBase().GetHairColor()) ; Fathers hair - color
	elseif Mother;/!=none/; ;Tkc (Loverslab): optimization
		newChildBase.SetHairColor(Mother.GetLeveledActorBase().GetHairColor()) ; Mothers hair - color
	endIf
	; Face Morphs
	int i = 0
	while i < 20
		if(Utility.RandomInt(1, 2) == 1 || !Mother) && Father;/!=none/; ;Tkc (Loverslab): optimization
			newChildBase.SetFaceMorph(Father.GetLeveledActorBase().GetFaceMorph(i), i) ; Fathers faceMorph
		elseif Mother;/!=none/; ;Tkc (Loverslab): optimization
			newChildBase.SetFaceMorph(Mother.GetLeveledActorBase().GetFaceMorph(i), i) ; Mothers faceMorph
		endIf
		i += 1
	endWhile
	
	; Create new Child
	newChild = Mother.PlaceActorAtMe(newChildBase)
	if newChild;/!=none/; ;Tkc (Loverslab): optimization
		string childName = getRandomChildName(gender)
		
		newChild.MoveTo(Mother, 50, 50, 10)
		newChild.QueueNiNodeUpdate()
		newChild.MakePlayerFriend()
	
		; Set relationship
		if Mother;/!=none/; ;Tkc (Loverslab): optimization
			newChild.SetRelationshipRank(Mother, 2)
			Mother.SetRelationshipRank(newChild, 2)
		endif
		if Father;/!=none/; ;Tkc (Loverslab): optimization
			newChild.SetRelationshipRank(Father, 2)
			Father.SetRelationshipRank(newChild, 2)
		endif
	
		if Mother == PlayerRef ||Father == PlayerRef
			; set Fraktion
			if(ChildFollowerFaction;/!=none/;) ;Tkc (Loverslab): optimization
				newChild.SetFactionRank(ChildFollowerFaction, ChildFollowerFactionRank)
			endif
			if(ChildFollowerFaction2;/!=none/;) ;Tkc (Loverslab): optimization
				newChild.SetFactionRank(ChildFollowerFaction2, ChildFollowerFactionRank2)
			endif
			if(ChildFollowerFaction3;/!=none/;) ;Tkc (Loverslab): optimization
				newChild.SetFactionRank(ChildFollowerFaction3, ChildFollowerFactionRank3)
			endif
			if(ChildFollowerFaction4;/!=none/;) ;Tkc (Loverslab): optimization
				newChild.SetFactionRank(ChildFollowerFaction4, ChildFollowerFactionRank4)
			endif
			if(ChildFollowerFaction5;/!=none/;) ;Tkc (Loverslab): optimization
				newChild.SetFactionRank(ChildFollowerFaction5, ChildFollowerFactionRank5)
			endif
			newChild.SetPlayerTeammate(true, false)
			
			; Now also set a "Other Parent" if empty
			if Mother == PlayerRef
				ChildSettings.SetOtherParentAlias(Father, true)
			else
				ChildSettings.SetOtherParentAlias(Mother, true)
			endif
		else
			newChild.SetRelationshipRank(PlayerRef,2)
		endIf
		
		if bIsPlayerChild;/==true/; ;Tkc (Loverslab): optimization
			;if HearthFiresActive;/==true/; ;Tkc (Loverslab): optimization
				faction f1 = BYOHRelationshipAdoptableFaction
				faction f2 = BYOHRelationshipAdoptionFaction
				newChild.SetFactionRank(f1,25)
				newChild.SetFactionRank(f2,1)
			;endif
		endIf
		
		newChild.EnableAI(true)
		newChild.EvaluatePackage()
		
		Race newChildRace = BabyItemList.LastRace
		
		Debug.Trace("BeeingFemaleSE_Opt - FWSystem - SpawnChildActor: LastRace of the child " + newChild + " is " + BabyItemList.LastRace)
		Manager.RaceExcludeFromSLandBF(newChild, newChildRace)
		
		if(StorageUtil.GetIntValue(newChildRace, "FW.AddOn.AllowPCDialogue", 0) == 1)
			newChild.AllowPCDialogue(true)
			Debug.Trace("BeeingFemaleSE_Opt - FWSystem - SpawnChildActor: Child " + newChild + " can talk to player")
		elseif(StorageUtil.GetIntValue(none, "FW.AddOn.Global_AllowPCDialogue", 0) == 1)
			newChild.AllowPCDialogue(true)
			Debug.Trace("BeeingFemaleSE_Opt - FWSystem - SpawnChildActor: Child " + newChild + " can talk to player, from global AddOn settings")
		endIf
		
		FWChildActor fwchild = newChild as FWChildActor
		if fwchild; != none ;Tkc (Loverslab): optimization
			Debug.Trace("BeeingFemaleSE_Opt - FWSystem - SpawnChildActor: Child " + newChild + " belongs to FWChildActor")
			StorageUtil.SetIntValue(fwchild, "FW.AddOn.StartGrowing", 1)
			
;			fwchild.ChildRace = BabyItemList.LastRace
			fwchild.ChildRace = newChildRace
		
			; First thing for any FWChildren - set ActorValues to Start-up values
			if gender==0
				; Male values
				fwchild.SetAV("Comprehension", 5)
				fwchild.SetAV("Destruction", 10)
				fwchild.SetAV("Illusion", 10)
				fwchild.SetAV("Conjuration", 10)
				fwchild.SetAV("Restoration", 10)
				fwchild.SetAV("Alteration", 10)
				fwchild.SetAV("Block", 10)
				fwchild.SetAV("OneHanded", 10)
				fwchild.SetAV("TwoHanded", 10)
				fwchild.SetAV("Marksman", 5)
				fwchild.SetAV("Sneak", 10)
				fwchild.SetAV("Magicka", 15)
				fwchild.SetAV("CarryWeight", 35)
				fwchild.SetAV("Health", 80)
				
				fwchild.SetAV("SpeedMult", 100)
				fwchild.SetAV("HealRate", 0.6)
				fwchild.SetAV("MagickaRate", 1.4)
				fwchild.SetAV("StaminaRate", 2.8)
			else
				; Female values
				fwchild.SetAV("Comprehension", 10)
				fwchild.SetAV("Destruction", 10)
				fwchild.SetAV("Illusion", 10)
				fwchild.SetAV("Conjuration", 10)
				fwchild.SetAV("Restoration", 10)
				fwchild.SetAV("Alteration", 10)
				fwchild.SetAV("Block", 10)
				fwchild.SetAV("OneHanded", 5)
				fwchild.SetAV("TwoHanded", 5)
				fwchild.SetAV("Marksman", 10)
				fwchild.SetAV("Sneak", 10)
				fwchild.SetAV("Magicka", 35)
				fwchild.SetAV("CarryWeight", 15)
				fwchild.SetAV("Health", 80)
				
				fwchild.SetAV("SpeedMult", 95)
				fwchild.SetAV("HealRate", 0.5)
				fwchild.SetAV("MagickaRate", 1.6)
				fwchild.SetAV("StaminaRate", 2.8)
			endif

			fwchild.Mother = Mother
			fwchild.Father = Father
			fwchild.Name = childName
			fwchild.Sex = gender
			fwchild.IsVampire = false
			fwchild.SetLevel(1)
			fwchild.DayOfBirth = GameDaysPassed.GetValue()
			fwchild.Order_WaitAndPlay()
			if Father;/!=none/; ;Tkc (Loverslab): optimization
				if Father.GetLeveledActorBase().IsUnique()
					if Mother.HasFamilyRelationship(Father);/==true/; || (Mother.GetRelationshipRank(Father)==4 && Utility.RandomInt(0,10)>7) ;Tkc (Loverslab): optimization
						fwchild.UseFathersLastName = true
					else
						fwchild.UseFathersLastName =false
					endif
				else
					fwchild.UseFathersLastName = false
				endIf
			else
				fwchild.UseFathersLastName = false
			endif
			fwchild.InitChild()
		else
			Debug.Trace("BeeingFemaleSE_Opt - FWSystem - SpawnChildActor: Child " + newChild + " does not belong to FWChildActor")
			newChild.StopCombat()
			if Mother
				newChild.SetRelationshipRank(Mother, ChildSettings.ParentRelationShipLevel)
				Mother.SetRelationshipRank(newChild, ChildSettings.ParentRelationShipLevel)
				
				if Mother == PlayerRef
					ChildSettings.AddPlayerChild(newChild)
				endif
			endif
			if Father
				newChild.SetRelationshipRank(Father, ChildSettings.ParentRelationShipLevel)
				Father.SetRelationshipRank(newChild, ChildSettings.ParentRelationShipLevel)
				
				if Father == PlayerRef
					ChildSettings.AddPlayerChild(newChild)
				endif
			endif
			newChild.StopCombat()
			
			if gender==0
				; Male values
				newChild.SetActorValue("Destruction", 10)
				newChild.SetActorValue("Illusion", 10)
				newChild.SetActorValue("Conjuration", 10)
				newChild.SetActorValue("Restoration", 10)
				newChild.SetActorValue("Alteration", 10)
				newChild.SetActorValue("Block", 10)
				newChild.SetActorValue("OneHanded", 10)
				newChild.SetActorValue("TwoHanded", 10)
				newChild.SetActorValue("Marksman", 5)
				newChild.SetActorValue("Sneak", 10)
				newChild.SetActorValue("Magicka", 15)
				newChild.SetActorValue("CarryWeight", 35)
				newChild.SetActorValue("Health", 80)
				
				newChild.SetActorValue("SpeedMult", 100)
				newChild.SetActorValue("HealRate", 0.6)
				newChild.SetActorValue("MagickaRate", 1.4)
				newChild.SetActorValue("StaminaRate", 2.8)
			else
				; Female values
				newChild.SetActorValue("Destruction", 10)
				newChild.SetActorValue("Illusion", 10)
				newChild.SetActorValue("Conjuration", 10)
				newChild.SetActorValue("Restoration", 10)
				newChild.SetActorValue("Alteration", 10)
				newChild.SetActorValue("Block", 10)
				newChild.SetActorValue("OneHanded", 5)
				newChild.SetActorValue("TwoHanded", 5)
				newChild.SetActorValue("Marksman", 10)
				newChild.SetActorValue("Sneak", 10)
				newChild.SetActorValue("Magicka", 35)
				newChild.SetActorValue("CarryWeight", 15)
				newChild.SetActorValue("Health", 80)
				
				newChild.SetActorValue("SpeedMult", 95)
				newChild.SetActorValue("HealRate", 0.5)
				newChild.SetActorValue("MagickaRate", 1.6)
				newChild.SetActorValue("StaminaRate", 2.8)
			endif
			
			StorageUtil.SetFormValue(newChild, "FW.Child.Mother", Mother)
			StorageUtil.SetFormValue(newChild, "FW.Child.Father", Father)
			
			bool newChildUseFathersLastName = false

			if Father
				if Father.GetLeveledActorBase().IsUnique()
					if(Mother.HasFamilyRelationship(Father) || ((Mother.GetRelationshipRank(Father) == 4) && (Utility.RandomInt(0, 10) > 7)))
						newChildUseFathersLastName = true
					endif
				endIf
			endif
			
			newChild.AddSpell(_BF_DefaultCustomChildSpell)
			
			; It's not an fwchild
;			newChild.setDisplayName(childName)
;			newChild.setName(childName)
			
			string LastName = myGetLastName(Mother, Father, newChildUseFathersLastName)
			newChild.SetName(childName)
			newChild.SetDisplayName(childName + LastName, true)
			StorageUtil.SetStringValue(newChild, "FW.Child.Name", childName)

			newChild.EvaluatePackage()
		endif
	endif
	showBornMessage(Mother, Father, newChild.GetLeveledActorBase().GetSex())
	return newChild
endFunction

; Copied from FWChildActor
string Function myGetLastName(Actor Mother, Actor Father, bool newChildUseFathersLastName)
	string LastName = ""

	if((Mother == PlayerRef) || (Father == PlayerRef))
		return " Dovahkiir"
	endif
	
	if(newChildUseFathersLastName)
		LastName = myGetActorsLastName(Father)
	endif
	
	if LastName==""
		LastName = myGetActorsLastName(Mother)
	endif
	return LastName
endFunction


; Copied from FWChildActor
string function myGetActorsLastName(actor a)
	if a == none
		return ""
	endif
	string Name1 = a.GetName()
	string Name2 = a.GetDisplayName()
	ActorBase ab = a.GetLeveledActorBase()
	if(ab != none)
		if(StringUtil.GetLength(ab.GetName()) > StringUtil.GetLength(Name1))
			Name1 = ab.GetName()
		endif
	endif
	int lName1 = StringUtil.GetLength(Name1)
	int lName2 = StringUtil.GetLength(Name2)
	if(lName1 > lName2)
		return StringUtil.Substring(Name1, lName2)
	elseif(lName1 < lName2)
		return StringUtil.Substring(Name2, lName1)
	endif
	return ""
endFunction


function CreateChildEnchantment(ObjectReference fwchild, actor Mother, actor Father) global
	MagicEffect[] effects
	float[] magnitudes
	int[] areas
	int[] durations
	int ParentLvl = 0 ;Tkc (Loverslab)
	float ParentEnchLvl = 0 ;Tkc (Loverslab)
	if Mother ;Tkc (Loverslab)
		ParentLvl = Mother.GetLevel()
		ParentEnchLvl = Mother.GetActorValue("Enchanting")
	endif
	if Father ;Tkc (Loverslab)
		ParentLvl = ( (ParentLvl + Father.GetLevel())/1.5 ) as int
		ParentEnchLvl = ( (ParentEnchLvl + Father.GetActorValue("Enchanting"))/1.5 ) as int
	endif
	;int num = Utility.RandomInt(0,100)
	int num = Utility.RandomInt(0,((ParentEnchLvl+ParentLvl)/1.5) as int) ;Tkc (Loverslab): balancing: for (Player Enchantment lvl 100 + Player lvl 50 ) /1.5 it will be 100. On lvl 50 already dragonbone and daedric armors
	if num>49
		if num>79
			if num>95;90 ;Tkc (Loverslab): balancing
				effects = new MagicEffect[4]
				magnitudes = new float[4]
				areas = new int[4]
				durations = new int[4]
				areas[0]=0
				areas[1]=0
				areas[2]=0
				areas[3]=0
				durations[0]=0
				durations[1]=0
				durations[2]=0
				durations[3]=0
			else;if num>79;90 ;Tkc (Loverslab): balancing
				effects = new MagicEffect[3]
				magnitudes = new float[3]
				areas = new int[3]
				durations = new int[3]
				areas[0]=0
				areas[1]=0
				areas[2]=0
				durations[0]=0
				durations[1]=0
				durations[2]=0
			endIf
		else;if num>49;40 ;Tkc (Loverslab): balancing
			effects = new MagicEffect[2]
			magnitudes = new float[2]
			areas = new int[2]
			durations = new int[2]
			areas[0]=0
			areas[1]=0
			durations[0]=0
			durations[1]=0
		endIf
	else
		effects = new MagicEffect[1]
		magnitudes = new float[1]
		areas = new int[1]
		durations = new int[1]
		areas[0]=0
		durations[0]=0
	endif
	
	int c = effects.length
	int efx_c = FWUtility.GetFileCount("Enchantments","ini")
	int id ;Tkc
	string efx_file ;Tkc
	string efx_ModName ;Tkc
	int fc = c ;Tkc
	while c>0
		c-=1
		;int id = Utility.RandomInt(0,efx_c - 1)
		;string efx_file = FWUtility.GetFileName("Enchantments","ini",id)
		;string efx_ModName = FWUtility.GetIniCString("Enchantments",efx_file,"Enchantments", "modFile")
		while fc ;Tkc
			fc-=1 ; repeat only while files exist
			id = Utility.RandomInt(0,efx_c - 1)
			efx_file = FWUtility.GetFileName("Enchantments","ini",id)
			efx_ModName = FWUtility.GetIniCString("Enchantments",efx_file,"Enchantments", "modFile")
			if ModFile(efx_ModName) ;Tkc (Loverslab): main purpose of it to be possible to add enchantments from other mods which 
				fc = 0
			else
				efx_ModName = ""
			endif
		endwhile ;Tkc
		if efx_ModName ;Tkc
			int efx_FormID = FWUtility.GetIniCInt("Enchantments",efx_file,"Enchantments", "form")
			float efx_Min = FWUtility.GetIniCInt("Enchantments",efx_file,"Enchantments", "power_min")
			float efx_Max = (FWUtility.GetIniCInt("Enchantments",efx_file,"Enchantments", "power_max")) * ( ( (ParentEnchLvl + ParentLvl)/1.5 ) /125) ;Tkc (Loverslab): balancing
			effects[c] = Game.GetFormFromFile(efx_FormID,efx_ModName) as MagicEffect
			efx_Min = efx_Min * ( ( (ParentEnchLvl + ParentLvl) / 1.5 ) / 50) ;Tkc (Loverslab): balancing
			magnitudes[c] = (Utility.RandomFloat(efx_Min, efx_Max))
		else ;Tkc
			c=0 ;Tkc
		endif ;Tkc
	endwhile
	if efx_ModName ;Tkc
		fwchild.CreateEnchantment(1.0, effects, magnitudes, areas, durations)
	endif ;Tkc
endFunction

function showBornMessage(actor Mother, actor Father, int sex)
	if Father==PlayerRef
		if sex==0
			Message( FWUtility.StringReplace( Content.NPCFatherBornHealthyBoy , "{0}",Mother.GetLeveledActorBase().GetName()), MSG_Always,MSG_Box)
		else
			Message( FWUtility.StringReplace( Content.NPCFatherBornHealthyGirl , "{0}",Mother.GetLeveledActorBase().GetName()), MSG_Always,MSG_Box)
		endif
		
	elseif Mother==PlayerRef
		if sex==0
			Message( Content.YouBornHealthyBoy , MSG_All,MSG_Box)
		else
			Message( Content.YouBornHealthyGirl , MSG_All,MSG_Box)
		endif
		
	elseif Mother.IsInFaction(FollowerFaction)
		if sex==0
			Message( FWUtility.StringReplace( Content.NPCBornHealthyBoy , "{0}",Mother.GetLeveledActorBase().GetName()), MSG_Immersive,MSG_Box)
		else
			Message( FWUtility.StringReplace( Content.NPCBornHealthyGirl , "{0}",Mother.GetLeveledActorBase().GetName()), MSG_Always,MSG_Box)
		endif
		
	else
	  if Mother==PlayerRef ;Tkc (Loverslab): optimization
	  else;if Mother!=PlayerRef
		if sex==0
			Message( FWUtility.StringReplace( Content.NPCBornHealthyBoy , "{0}",Mother.GetLeveledActorBase().GetName()), MSG_High)
		else
			Message( FWUtility.StringReplace( Content.NPCBornHealthyGirl , "{0}",Mother.GetLeveledActorBase().GetName()), MSG_Always,MSG_Box)
		endif
	  endif
		
	endif
endFunction

function Mimik(actor a, string ExpressionName = "", int Strength = 50, bool bClear = true)
	if a.Is3DLoaded() ;Tkc (Loverslab): fix when women npc on start of giving birth was moved to other location and log started spam with "ERROR:  (########): Does not have face animation data, and therefore cannot have their expression".
		Manager.OnMimik(a, ExpressionName, Strength, bClear)
	endif
endFunction

string function getRandomChildName(int sex) global
	string s = FWUtility.getRandomName(sex)
	if s;/!=""/; ;Tkc (Loverslab): optimization
		return s
	endif
	FWTextContents xCont = Game.GetFormFromFile(0x3e31, "BeeingFemale.esm") as FWTextContents
	return xCont.BabyBlankName
endfunction



Form function StripSlot(actor ActorRef, int Slot) global
	Form ItemRef = ActorRef.GetWornForm(Slot)
	if ItemRef
		ActorRef.UnequipItem(ItemRef, false, true)
		return ItemRef
	endif
	return none
endFunction
Form[] function StripActor(Actor ActorRef)
	Form[] f = Manager.OnStripActor(ActorRef)
	if f.length>0
		return f
	endif
	; Stripped storage
	Form[] Stripped = new Form[21]
	Form ItemRef
	
	; Weapon
	ItemRef = ActorRef.GetEquippedWeapon(false)
	if ItemRef
		ActorRef.UnequipItemEX(ItemRef, 1, false)
		Stripped[0] = ItemRef
	endIf
	ItemRef = ActorRef.GetEquippedWeapon(true)
	if ItemRef
		ActorRef.UnequipItemEX(ItemRef, 2, false)
		Stripped[1] = ItemRef
	endIf
	Stripped[2] = StripSlot(ActorRef,30)
	Stripped[3] = StripSlot(ActorRef,31)
	Stripped[4] = StripSlot(ActorRef,32)
	Stripped[5] = StripSlot(ActorRef,33)
	Stripped[6] = StripSlot(ActorRef,34)
	Stripped[7] = StripSlot(ActorRef,37)
	Stripped[8] = StripSlot(ActorRef,38)
	Stripped[9] = StripSlot(ActorRef,39)
	Stripped[10] = StripSlot(ActorRef,41)
	Stripped[11] = StripSlot(ActorRef,45)
	Stripped[12] = StripSlot(ActorRef,46)
	Stripped[13] = StripSlot(ActorRef,47)
	Stripped[14] = StripSlot(ActorRef,49)
	Stripped[15] = StripSlot(ActorRef,53)
	Stripped[16] = StripSlot(ActorRef,54)
	Stripped[17] = StripSlot(ActorRef,56)
	Stripped[18] = StripSlot(ActorRef,57)
	Stripped[19] = StripSlot(ActorRef,58)
	Stripped[20] = StripSlot(ActorRef,59)
	return Stripped
endFunction

int function UnstripSlot(actor ActorRef, Form ItemRef, int hand)
	if ItemRef
		int type = ItemRef.GetType()
		if type == 22 || type == 82
			ActorRef.EquipSpell((ItemRef as Spell), hand)
		else
			ActorRef.EquipItem(ItemRef, false, true)
		endIf
		; Move to other hand if weapon, light, spell, or leveledspell
		hand -= ((hand == 1 && (type == 41 || type == 31 || type == 22 || type == 82)) as int)
	endif
	return hand
endFunction
function UnstripActor(Actor ActorRef, Form[] Striped)
	int hand = 1
	int i = Striped.length
	while i>0
		i-=1
		hand = UnstripSlot(ActorRef,Striped[i],hand)
	endwhile
endFunction
 


Event OnMenuOpen(string menuName)
	if menuName=="Console"
		RegisterForKey(28)
		RegisterForKey(156)
	endif
endEvent

Event OnMenuClose(string menuName)
	if menuName=="Console"
		UnregisterForKey(28)
		UnregisterForKey(156)
	endif
endEvent

Event OnKeyDown(int keyCode)
	if keyCode==28 || keyCode==156
		int cmdCount = UI.GetInt("Console", "_global.Console.ConsoleInstance.Commands.length")
		if cmdCount>0
			cmdCount-=1
			string cmdLine = UI.GetString("Console","_global.Console.ConsoleInstance.Commands."+cmdCount)
			string msg=""
			if cmdLine;/!=""/; ;Tkc (Loverslab): optimization
				bool bSuccess=false
				bool bUsedPlayer=false
				actor a = Game.GetCurrentConsoleRef() as actor
				actor target = a ; store a second one for player. console commands
				if a ;Tkc (Loverslab): optimization
				else;if a==none
					a=PlayerRef
					target=a
				endif
				int validate=IsValidateFemaleActor(target)
				string[] cmd=StringUtil.Split(cmdLine," ")
				if StringUtil.GetLength(cmd[0])>7
					if StringUtil.Substring(cmd[0],0,7)=="player."
						bUsedPlayer=true
						cmd[0]=StringUtil.Substring(cmd[0],7)
						a=PlayerRef
					endif
				endif
				if cmd.length
					if cmd[0]=="givetampon" || cmd[0]=="givetampons" || cmd[0]=="addtampon" || cmd[0]=="addtampons" || cmd[0]=="bf:givetampon" || cmd[0]=="bf:givetampons" || cmd[0]=="bf:addtampon" || cmd[0]=="bf:addtampons"
						int c=1
						if cmd.length>1
							c=cmd[1] as int
						endif
						a.AddItem(Tampon_Normal,c,true)
						msg="Gave "+c+"x Tampons to "+a.GetDisplayName()
						bSuccess=true
					elseif cmd[0]=="givecontraception" || cmd[0]=="addcontraception" || cmd[0]=="bf:givecontraception" || cmd[0]=="bf:addcontraception"
						int c=1
						if cmd.length>1
							c=cmd[1] as int
						endif
						a.AddItem(ContraceptionLow,c,true)
						msg="Gave "+c+"x Contraception Fluid to "+a.GetDisplayName()
						bSuccess=true
					elseif cmd[0]=="bf:state"
						if validate>0
							int fstate=Controller.GetFemaleState(a)
							if cmd.length>1
								int tmpState = cmd[1] as int
								if tmpState>=0 && tmpState<9
									if Controller.IsPregnant(a)
										if tmpState < 4
											Controller.unimpregnate(a)
										endif
										Controller.ChangeState(a,tmpState)
										fstate=tmpState
									elseif tmpState>=4
										msg="Cant's switch from none-pregnant to pregnant"
									else
										Controller.ChangeState(a,tmpState)
										fstate=tmpState
									endif
								else
									msg=tmpState+" is not a validate state"
								endif
							endif
							if fstate >= 0
								if fstate < 9
									if fstate < 8
										if fstate < 4
											if fstate < 2
												if fstate==0
													msg=FWUtility.MultiStringReplace(Content.SwitchState,a.GetDisplayname(),Content.StateID0)
												else;if fstate==1
													msg=FWUtility.MultiStringReplace(Content.SwitchState,a.GetDisplayname(),Content.StateID1)
												endIf
											else
												if fstate==2
													msg=FWUtility.MultiStringReplace(Content.SwitchState,a.GetDisplayname(),Content.StateID2)
												else;if fstate==3
													msg=FWUtility.MultiStringReplace(Content.SwitchState,a.GetDisplayname(),Content.StateID3)
												endIf
											endIf
										else
											if fstate < 6
												if fstate==4
													msg=FWUtility.MultiStringReplace(Content.SwitchState,a.GetDisplayname(),Content.StateID4)
												else;if fstate==5
													msg=FWUtility.MultiStringReplace(Content.SwitchState,a.GetDisplayname(),Content.StateID5)
												endIf
											else
												if fstate==6
													msg=FWUtility.MultiStringReplace(Content.SwitchState,a.GetDisplayname(),Content.StateID6)
												else;if fstate==7
													msg=FWUtility.MultiStringReplace(Content.SwitchState,a.GetDisplayname(),Content.StateID7)
												endIf
											endIf
										endIf
									else;if fstate==8
										msg=FWUtility.MultiStringReplace(Content.SwitchState,a.GetDisplayname(),Content.StateID8)
									endIf
								elseif((fstate==20) || (fstate==21))
									if fstate==20
										msg=FWUtility.MultiStringReplace(Content.SwitchState,a.GetDisplayname(),Content.StateID20)
									else;if fstate==21
										msg=FWUtility.MultiStringReplace(Content.SwitchState,a.GetDisplayname(),Content.StateID21)
									endif
								endIf
							endIf
						else
							msg=getValidateMessage(validate)
						endif
						bSuccess=true
					elseif cmd[0]=="bf:contraception" || cmd[0]=="contraception"
						if validate>0
							if cmd.length>1
								int val = cmd[0] as int
								if val<0
									val=0
								elseif val>100
									val=100
								endif
								Controller.SetContraception(a,val)
								msg=FWUtility.MultiStringReplace(Content.ActorHasContraception,a.GetDisplayname(),val)
							else
								msg=FWUtility.MultiStringReplace(Content.ActorHasContraception,a.GetDisplayname(),Controller.GetContraception(a))
							endif
						else
							msg=getValidateMessage(validate)
						endif
						bSuccess=true
					elseif cmd[0]=="bf:addsperm" || cmd[0]=="addsperm"
						if PlayerRef==a ;Tkc (Loverslab): optimization
						else;if PlayerRef!=a
							if IsValidateFemaleActor(PlayerRef)>0 && IsValidateMaleActor(target)>0
								Controller.AddSperm(PlayerRef, a)
								msg=FWUtility.StringReplace(Content.NPCCameInsideYou,target.GetDisplayname(),"{0}")
							elseif IsValidateMaleActor(PlayerRef)>0 && validate>0
								Controller.AddSperm(a,PlayerRef)
								msg=FWUtility.StringReplace(Content.YouCameInsideNPC,target.GetDisplayname(),"{0}")
							elseif IsValidateFemaleActor(PlayerRef) && validate>0
								if bUsedPlayer
									Controller.AddSperm(PlayerRef, target)
									msg=FWUtility.StringReplace(Content.NPCCameInsideYou,target.GetDisplayname(),"{0}")
								else
									Controller.AddSperm(a, PlayerRef)
									msg=FWUtility.StringReplace(Content.YouCameInsideNPC,target.GetDisplayname(),"{0}")
								endif
							endif
							bSuccess=true
						endif
					elseif cmd[0]=="bf:impregnate" || cmd[0]=="impregnate"
						int iCount=1
						if cmd.length>1
							iCount=cmd[1] as int
							if iCount<=0
								iCount=1
							elseif iCount>MaxBabyPregnantWith
								iCount=MaxBabyPregnantWith
							endif
						endif
						if PlayerRef==target ;Tkc (Loverslab): optimization
							msg+="No NpcMentruation selected"
						else;Game.GetPlayer()!=target
							if IsValidateFemaleActor(PlayerRef)>0 && IsValidateMaleActor(target)>0
								Controller.Impregnate(PlayerRef, target,iCount*Manager.ActorMaxBabse(PlayerRef) as int)
								msg=FWUtility.StringReplace(Content.NPCCameInsideYou,target.GetDisplayname(),"{0}") + "\n" + Content.YouArePregnant+"\n"
							elseif IsValidateMaleActor(PlayerRef)>0 && validate>0
								Controller.Impregnate(a,PlayerRef,iCount*Manager.ActorMaxBabse(a) as int)
								msg=FWUtility.StringReplace(Content.YouCameInsideNPC,target.GetDisplayname(),"{0}") + "\n" + FWUtility.StringReplace(Content.NPCIsPregnant,target.GetDisplayname(),"{0}")+"\n"
							elseif IsValidateFemaleActor(PlayerRef) && validate>0
								if bUsedPlayer
									Controller.Impregnate(PlayerRef, target,iCount*Manager.ActorMaxBabse(PlayerRef) as int)
									msg=FWUtility.StringReplace(Content.NPCCameInsideYou,target.GetDisplayname(),"{0}") + "\n" + Content.YouArePregnant+"\n"
								else
									Controller.Impregnate(target, PlayerRef,iCount*Manager.ActorMaxBabse(target) as int)
									msg=FWUtility.StringReplace(Content.YouCameInsideNPC,target.GetDisplayname(),"{0}") + "\n" + FWUtility.StringReplace(Content.NPCIsPregnant,target.GetDisplayname(),"{0}")+"\n"
								endif
							endif
						endif
						bSuccess=true
					elseif cmd[0]=="bf:damagebaby" || cmd[0]=="damagebaby"
						if validate>0
							if cmd.length>1
								int val = cmd[0] as int
								if val<0
									val=0
								elseif val>100
									val=100
								endif
								Controller.DamageBaby(a,val)
								msg=FWUtility.MultiStringReplace(Content.BabyHealth,a.GetDisplayname(),Controller.GetBabyHealth(a))
							endif
						else
							msg=getValidateMessage(validate)
						endif
						bSuccess=true
					elseif cmd[0]=="bf:babyhealth" || cmd[0]=="babyhealth"
						if validate>0
							if cmd.length>1
								int val = cmd[0] as int
								if val<0
									val=0
								elseif val>100
									val=100
								endif
								Controller.SetBabyHealth(a,val)
								msg=FWUtility.MultiStringReplace(Content.BabyHealth,a.GetDisplayname(),val)
							else
								msg=FWUtility.MultiStringReplace(Content.BabyHealth,a.GetDisplayname(),Controller.GetBabyHealth(a))
							endif
						else
							msg=getValidateMessage(validate)
						endif
						bSuccess=true
					elseif cmd[0]=="bf:forcebirth" || cmd[0]=="forcebirth"
						if validate>0
							int tmpState = Controller.GetFemaleState(a)
							if tmpState>=4 && tmpState<7
								Controller.GiveBirth(a)
							else
								msg=FWUtility.StringReplace(Content.ActorNotPregnant,a.GetDisplayname(),"{0}")
							endif
						else
							msg=getValidateMessage(validate)
						endif
						bSuccess=true
					elseif cmd[0]=="bf:code"
						;msg = FWUtility.Hex(LoadState,2) + " " + FWUtility.Hex(UpdateState,2) + " " + FWUtility.Hex(ChildSettings.LoadingState,2) + " " + FWUtility.Hex(Manager.LoadingState,2) + " " + FWUtility.Hex(cfg.GetPageResetJobID(),2) + " " + FWUtility.Hex(manager.LoadingStateRace,1) + FWUtility.Hex(manager.iRaces%16,1) + " " + FWUtility.Hex(manager.LoadingStateCME,1) + FWUtility.Hex(manager.iCME%16,1) + " " + FWUtility.Hex(manager.LoadingStateMisc,1) + FWUtility.Hex(manager.iMisc%16,1)
						msg = FWUtility.Hex(LoadState,2) + " " + FWUtility.Hex(UpdateState,2) + " " + FWUtility.Hex(ChildSettings.LoadingState,2) + " " + FWUtility.Hex(Manager.LoadingState,2) + " " + FWUtility.Hex(cfg.GetPageResetJobID(),2)
						if Manager.SLoadingRace;/!=""/; || Manager.SLoadingCME;/!=""/; || Manager.SLoadingMisc;/!=""/; ;Tkc (Loverslab): optimization
							msg+=" ["+Manager.SLoadingRace+";"+Manager.SLoadingCME+";"+Manager.SLoadingMisc+"]"
						endif
						bSuccess=true
					elseif cmd[0]=="bf:resetnpc" || cmd[0]=="resetnpc"
						if target.HasSpell(BeeingFemaleSpell)
							target.RemoveSpell(BeeingFemaleSpell)
						endif
						if target.HasSpell(BeeingMaleSpell)
							target.RemoveSpell(BeeingMaleSpell)
						endif
						Manager.removeCME(a,-1)
						FWSaveLoad.Delete(target)
						if IsValidateFemaleActor(target) > 0
							target.AddSpell(BeeingFemaleSpell)
						elseif IsValidateMaleActor(target) > 0
							target.AddSpell(BeeingMaleSpell)
						endif
						bSuccess=true
					elseif cmd[0]=="bf:canbecomepregnant" || cmd[0]=="canbecomepregnant"
						if cmd.length>1
							bool bActive=false
							if cmd[1]=="1" || cmd[1]=="true" || cmd[1]=="yes"
								bActive=true
							endif
							Controller.setCanBecomePregnant(a, bActive)
						else
							if Controller.canBecomePregnant(a)
								msg=a.GetLeveledActorBase().GetName()+" can become pregnant\n"
							else
								msg=a.GetLeveledActorBase().GetName()+" can not become pregnant in this cycle\n"
							endif
						endif
						bSuccess=true
					elseif cmd[0]=="bf:canbecomepms" || cmd[0]=="canbecomepms"
						if cmd.length>1
							bool bActive=false
							if cmd[1]=="1" || cmd[1]=="true" || cmd[1]=="yes"
								bActive=true
							endif
							Controller.setCanBecomePMS(a, bActive)
						else
							if Controller.canBecomePMS(a)
								msg=a.GetLeveledActorBase().GetName()+" can become PMS\n"
							else
								msg=a.GetLeveledActorBase().GetName()+" can not become PMS in this cycle\n"
							endif
						endif
						bSuccess=true
					elseif cmd[0]=="bf:unimpregnate" || cmd[0]=="unimpregnate"
						Controller.unimpregnate(a)
						bSuccess=true
					elseif cmd[0]=="bf:cme" || cmd[0]=="cme"
						if cmd.length==1
							msg+=console_PrintCME("all",false)
						elseif cmd.length==2
							if FWUtility.toLower(cmd[1])=="log"
								msg+=console_PrintCME("all",true)
							else
								msg+=console_PrintCME(cmd[1],false)
							endif
						else
							if FWUtility.toLower(cmd[2])=="log"
								msg+=console_PrintCME(cmd[1],true)
							else
								msg+=console_PrintCME(cmd[1],false)
							endif
						endif
						msg+="\n"
						bSuccess=true
					elseif cmd[0]=="bf:race" || cmd[0]=="race"
						bool bLog=false
						if cmd.length>1
							if cmd[1]=="log"
								bLog=true
							endif
						endif
						race r = target.GetLeveledActorBase().GetRace()
						msg="RaceAddOn Informations for "+r.GetName()
						Debug.Trace("RaceAddOn Informations for "+r.GetName())
						msg+=console_PrintRaceBaby(bLog,r, "BabyActor_Female")
						msg+=console_PrintRaceBaby(bLog,r, "BabyActor_Male")
						msg+=console_PrintRaceBaby(bLog,r, "BabyActor_FemalePlayer")
						msg+=console_PrintRaceBaby(bLog,r, "BabyActor_MalePlayer")
						msg+=console_PrintRaceBaby(bLog,r, "BabyArmor_Female")
						msg+=console_PrintRaceBaby(bLog,r, "BabyArmor_Male")
						
						msg+=console_PrintRace(bLog,r, "ChanceToBecomePregnant")
						msg+=console_PrintRace(bLog,r, "ContraceptionDuration")
						msg+=console_PrintRace(bLog,r, "Duration_01_Follicular")
						msg+=console_PrintRace(bLog,r, "Duration_02_Ovulation")
						msg+=console_PrintRace(bLog,r, "Duration_03_Luteal")
						msg+=console_PrintRace(bLog,r, "Duration_04_Menstruation")
						msg+=console_PrintRace(bLog,r, "Duration_05_Trimester1")
						msg+=console_PrintRace(bLog,r, "Duration_06_Trimester2")
						msg+=console_PrintRace(bLog,r, "Duration_07_Trimester3")
						msg+=console_PrintRace(bLog,r, "Duration_08_Recovery")
						msg+=console_PrintRace(bLog,r, "Duration_10_SecondsBetweenLaborPains")
						msg+=console_PrintRace(bLog,r, "Duration_11_SecondsBetweenBabySpawn")
						msg+=console_PrintRace(bLog,r, "Duration_MaleSperm")
						msg+=console_PrintRace(bLog,r, "Irregulation_Chance_Scale")
						msg+=console_PrintRace(bLog,r, "Irregulation_Value_Scale")
						msg+=console_PrintRace(bLog,r, "Max_CME_EffectScale")
						msg+=console_PrintRace(bLog,r, "Multiple_Threshold_Chance")
						msg+=console_PrintRace(bLog,r, "Multiple_Threshold_Max_Babys")
						msg+=console_PrintRace(bLog,r, "Pain_Abortus")
						msg+=console_PrintRace(bLog,r, "Pain_GivingBirth")
						msg+=console_PrintRace(bLog,r, "Pain_LaborPains")
						msg+=console_PrintRace(bLog,r, "Pain_Menstruation")
						msg+=console_PrintRace(bLog,r, "Pain_Mittelschmerz")
						msg+=console_PrintRace(bLog,r, "Pain_Phase_CyclePains")
						msg+=console_PrintRace(bLog,r, "Pain_Phase_PregnantPains")
						msg+=console_PrintRace(bLog,r, "Pain_PMS")
						msg+=console_PrintRace(bLog,r, "PMS_ChanceScale")
						msg+=console_PrintRace(bLog,r, "Sizes_Belly_Max")
						msg+=console_PrintRace(bLog,r, "Sizes_Belly_Max_Multiple")
						msg+=console_PrintRace(bLog,r, "Sizes_Breasts_Max")
						msg+=console_PrintRace(bLog,r, "Sizes_Breasts_Max_Multiple")
						msg+=console_PrintRace(bLog,r, "Sperm_Amount_Scale")
						msg+=console_PrintRace(bLog,r, "Baby_Healing_Scale")
						msg+=console_PrintRace(bLog,r, "Baby_Damage_Scale")
						msg+=console_PrintRace(bLog,r, "Male_Recovery_Scale")
						msg+="\n"
						bSuccess=true
					elseif cmd[0]=="bf:addon"
						if cmd.length>1
							if cmd[1]=="refresh"
								if cmd.length>2
									if cmd[2]=="?"
										msg+="1 = Misc AddOn\n"
										msg+="2 = Race AddOn\n"
										msg+="4 = CME AddOn\n"
										msg+="---------------\n"
										msg+="3 = Misc + Race AddOn\n"
										msg+="5 = Misc + CME AddOn\n"
										msg+="6 = Race + CME AddOn\n"
										msg+="7 = Misc + Race + CME AddOn\n"
									elseif FWUtility.toLower(cmd[2])=="misc"
										Manager.RefreshAddOn(1)
									elseif FWUtility.toLower(cmd[2])=="race"
										Manager.RefreshAddOn(2)
									elseif FWUtility.toLower(cmd[2])=="cme"
										Manager.RefreshAddOn(4)
									else
										Manager.RefreshAddOn(cmd[2] as int)
									endif
								else
									Manager.RefreshAddOn(127)
								endif
							elseif cmd[1]=="clear"
								if cmd.length>2
									if cmd[2]=="?"
										msg+="1 = Misc AddOn\n"
										msg+="2 = Race AddOn\n"
										msg+="4 = CME AddOn\n"
										msg+="---------------\n"
										msg+="3 = Misc + Race AddOn\n"
										msg+="5 = Misc + CME AddOn\n"
										msg+="6 = Race + CME AddOn\n"
										msg+="7 = Misc + Race + CME AddOn\n"
									elseif FWUtility.toLower(cmd[2])=="misc"
										Manager.clear(1)
									elseif FWUtility.toLower(cmd[2])=="race"
										Manager.clear(2)
									elseif FWUtility.toLower(cmd[2])=="cme"
										Manager.clear(4)
									else
										Manager.clear(cmd[2] as int)
									endif
								else
									Manager.clear(127)
								endif
							else
								msg+="AddOn Command not found\n"
							endif
						else
							msg+="AddOn command list:\n"
							msg+=" addon refresh ?\n"
							msg+=" addon refresh [<id>]\n"
							msg+=" addon clear ?\n"
							msg+=" addon clear [<id>]\n"
						endif
						bSuccess=true
					elseif cmd[0]=="bf:test"
						msg+="Language: "+FWUtility.SwitchString( Content.InstallComplete=="","False","True")+"\n"
						if Content.InstallComplete==""
							Content.LoadContent()
							msg+="Language Reload: "+FWUtility.SwitchString( Content.InstallComplete=="","False","True")+"\n"
						endif
						msg+="Language Info: "+ FWTextContents.getLangSize()+" byte; Code: "+FWTextContents.getErrorCode()+"; "+FWTextContents.getFilePath()+"\n"
						actor ar = Game.GetCurrentConsoleRef() as actor
						if !ar
							msg+="Belly: Testing Belly for all loaded Female Actors for 10 sec\n"
							SendModEvent("BeeingFemale","TestScale",1.0)
						elseif ar==PlayerRef && ar.GetLeveledActorBase().GetSex()==1 && Player;/!=none/; ;Tkc (Loverslab): optimization
							msg+="Belly: Testing Belly for Player Actors for 10 sec\n"
							Player.TestScale(1.0)
						else
							msg+="Belly: Testing Belly for '"+ar.GetLeveledActorBase().GetName()+"' for 10 sec\n"
							ar.SendModEvent("BeeingFemale","TestScale",1.0)
						endif
						bSuccess=true
					elseif cmd[0]=="bf:export"
						if cmd.length==1
							msg+="Exporting AddOns from the given mod\n  bf:export <modName> [<export prefix>]\n  bf:export BeeingFemale.esm BF_\n"
						else
							cmd[1]=FWUtility.StringReplace(cmd[1],"%20"," ")
							Debug.Trace("Exporting BeeingFemale AddOns")
							Debug.Trace("- Mod: "+cmd[1])
							int exported=0
							string prefix = ""
							if cmd.length>=3
								prefix=cmd[2]
							endif
							int c=FWUtility.GetQuestObjectCount(cmd[1])
							Debug.Trace("- Number Of Quests: "+c)
							while c>0
								c-=1
								quest q = FWUtility.GetQuestObject(cmd[1],c)
								if q as FWAddOnBase; != none ;Tkc (Loverslab): optimization
									Debug.Trace("- Export: "+q.GetName() +" [0x"+FWUtility.Hex(q.GetFormID() % 0x1000000,6)+"]")
									if FWAddOnManager.Export(q as FWAddOnBase, prefix)
										exported+=1
									endif
								endif
							endWhile
							Debug.Trace("- Export done, "+exported+" AddOns exported")
							msg+=exported+" AddOns exported\n"
						endif
						bSuccess=true
					elseif cmd[0]=="bf:setbabys"
						if cmd.length<2
							msg+="Set the number of babys the woman is pregnant with\nbf:setbabys <num>\n"
						else
							if validate>0
								if Controller.setNumBabys(target,cmd[1] as int)
									msg+="Set number of babys "+target.GetLeveledActorBase().GetName()+" is pregnant with to "+cmd[1]+"\n"
								else
									msg+="Failed to set babys for "+target.GetLeveledActorBase().GetName()+" to "+cmd[1]+"\n"
								endif
							else
								msg+=target.GetLeveledActorBase().GetName()+" is not a validate female\n"
							endif
						endif
						bSuccess=true
					elseif (a as FWChildActor);/ != none/; && cmd.length==3 ;Tkc (Loverslab): optimization
						; Here we don't need to set "bSuccess" to True, because the command realy exists and we just need to apply the value from Actor to FWChildActor
						FWChildActor child = a as FWChildActor
						if cmd[0]=="setav" || cmd[0]=="setactorvalue"
							child.SetActorValue(cmd[1],cmd[2] as float)
						elseif cmd[0]=="modav" || cmd[0]=="modactorvalue"
							child.ModActorValue(cmd[1],cmd[2] as float)
						endif
					endif
				endif	
				if bSuccess;/==true/; ;Tkc (Loverslab): optimization
					; Remove last line (error line)
					Utility.WaitMenuMode(0.1)
					string history = UI.GetString("Console","_global.Console.ConsoleInstance.CommandHistory.text")
					int iHistory = StringUtil.GetLength(history) - 1
					bool bRunning=true
					while iHistory>0 && bRunning;/==true/; ;Tkc (Loverslab): optimization
						if StringUtil.AsOrd(StringUtil.GetNthChar(history,iHistory - 1))==13
							bRunning=false
						else
							iHistory-=1
						endif
					endWhile
					if iHistory<=0
						UI.SetString("Console","_global.Console.ConsoleInstance.CommandHistory.text","")
					else
						UI.SetString("Console","_global.Console.ConsoleInstance.CommandHistory.text",StringUtil.Substring(history,0,iHistory))
					endif
				endif
				if msg;/!=""/; ;Tkc (Loverslab): optimization
					UI.InvokeString("Console","_global.Console.AddHistory", msg)
				endif
			endif
		endif
	endif
endEvent

string function getValidateMessage(int id)
	if id < 0
		if id > -9
			if id > -5
				if id > -3
					if id==-1
						return Content.ForbiddenReason1
					else;if id==-2
						return Content.ForbiddenReason2
					endIf
				else
					if id==-3
						return Content.ForbiddenReason3
					else;if id==-4
						return Content.ForbiddenReason4
					endIf
				endIf
			else
				if id > -7
					if id==-5
						return Content.ForbiddenReason5
					else;if id==-6
						return Content.ForbiddenReason6
					endIf
				else
					if id==-7
						return Content.ForbiddenReason7
					else;if id==-8
						return Content.ForbiddenReason8
					endIf
				endIf
			endIf
		else
			if id > -11
				if id==-9
					return Content.ForbiddenReason9
				else;if id==-10
					return Content.ForbiddenReason10
				endIf
			elseif id==-11
				return Content.ForbiddenReason11
			endif
		endIf
	endIf
endFunction


string function console_PrintCME(string phase, bool bLog)
	string s="== CME Info for "+phase+" =="
	if bLog
		Debug.Trace("== CME Info "+phase+"==")
	endif
	phase = FWUtility.toLower(phase)
	if phase=="0" || phase=="all" || phase=="follicularphase" || phase=="follicular"
		s+=console_PrintCME_h(bLog,"FollicularPhase")
	endif
	if phase=="1" || phase=="all" || phase=="ovulation"
		s+=console_PrintCME_h(bLog,"Ovulation")
	endif
	if phase=="2" || phase=="all" || phase=="lutealphase" || phase=="luteal"
		s+=console_PrintCME_h(bLog,"LutealPhase")
	endif
	if phase=="3" || phase=="all" || phase=="pms"
		s+=console_PrintCME_h(bLog,"PMS")
	endif
	if phase=="4" || phase=="all" || phase=="menstruation"
		s+=console_PrintCME_h(bLog,"Menstruation")
	endif
	if phase=="5" || phase=="all" || phase=="trimester1" || phase=="1st trimester"
		s+=console_PrintCME_h(bLog,"Trimester1")
	endif
	if phase=="6" || phase=="all" || phase=="trimester2" || phase=="2nd trimester"
		s+=console_PrintCME_h(bLog,"Trimester2")
	endif
	if phase=="7" || phase=="all" || phase=="trimester3" || phase=="3rd trimester"
		s+=console_PrintCME_h(bLog,"Trimester3")
	endif
	if phase=="8" || phase=="all" || phase=="laborpains" || phase=="labor"
		s+=console_PrintCME_h(bLog,"LaborPains")
	endif
	if phase=="9" || phase=="all" || phase=="recovery"
		s+=console_PrintCME_h(bLog,"Recovery")
	endif
	return s
endFunction

string function console_PrintCME_h(bool bLog, string Phase)
	string r=""
	int c=StorageUtil.FormListCount(none,"FW.AddOn.Always_"+Phase)
	r+="\n- Always "+phase+" ("+c+")"
	if bLog
		Debug.Trace("- Always "+phase+" ("+c+")")
	endif
	if c>0
		while c>0
			c-=1
			r+="\n- - "+StorageUtil.FormListGet(none,"FW.AddOn.Always_"+Phase,c).GetName()+"\n"
			if bLog
				Debug.Trace("- - "+StorageUtil.FormListGet(none,"FW.AddOn.Always_"+Phase,c).GetName())
			endif
		endWhile
	endif
	c=StorageUtil.FormListCount(none,"FW.AddOn.Sometimes_"+Phase)
	r+="\n- Sometimes "+phase+" ("+c+")"
	if bLog
		Debug.Trace("- Sometimes "+phase+" ("+c+")")
	endif
	if c>0
		while c>0
			c-=1
			r+="\n- - "+StorageUtil.FormListGet(none,"FW.AddOn.Sometimes_"+Phase,c).GetName()
			if bLog
				Debug.Trace("- - "+StorageUtil.FormListGet(none,"FW.AddOn.Sometimes_"+Phase,c).GetName())
			endif
		endWhile
	endif
	return r
endFunction

string function console_PrintRace(bool bLog, race r, string type)
	if StorageUtil.HasFloatValue(r, "FW.AddOn."+type);/==true/; ;Tkc (Loverslab): optimization
		float f = StorageUtil.GetFloatValue(r, "FW.AddOn."+type, 1.0)
		if bLog
			Debug.Trace("- "+type+": "+f)
		endif
		if f!=1.0
			return "\n- "+type+": "+f
		endif
	else
		if bLog
			Debug.Trace("- "+type+": "+1.0)
		endif
	endif
	return ""
endFunction

string function console_PrintRaceBaby(bool bLog, race r, string Baby)
	int c=StorageUtil.FormListCount(r,"FW.AddOn."+Baby)
	if c>0
		string s=Baby+": "
		bool bFirst=true
		while c>0
			c-=1
			if bFirst ;Tkc (Loverslab): optimization
			else;if !bFirst
				s+=", "
			endif
			form f = StorageUtil.FormListGet(r, "FW.AddOn."+Baby,c)
			if f;/!=none/; ;Tkc (Loverslab): optimization
				s+=f.GetName()+" ["+FWUtility.Hex(f.GetFormID(),8)+"]"
				bFirst=false
			endif
		endWhile
		if bFirst
			Debug.Trace("- "+Baby+": none - All are nothing")
			return ""
		else
			Debug.Trace("- "+s)
			return "\n"+s
		endif
	elseif bLog
		Debug.Trace("- "+Baby+": none")
		return ""
	endif
endFunction

; 03.06.2019 Tkc (Loverslab) optimizations: Game.GetPlayer() replaced by PlayerRef. Other changes marked with "Tkc (Loverslab)" comment