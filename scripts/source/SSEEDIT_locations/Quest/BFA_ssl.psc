Scriptname BFA_ssl extends FWAddOn_Misc

SexLabFramework Property SexLab Auto
sslThreadLibrary Lib
bool bSexLab
FWSystem property System auto

int TryRegisterCount=0

FWSystemConfig property cfg auto
Spell Property BeeingFemaleSpell Auto
FWController property Controller auto
FWAddOnManager property Manager auto
FWTextContents property Content auto
Actor Property PlayerRef Auto

function OnGameLoad()
	if System ;Tkc (Loverslab): optimization
	else;if System==none
		System=GetSystem()
	endif
	bSexLab= false
	SexLab = none
	Lib = none
	UnregisterForAllModEvents()
	TryRegisterCount=0
	RegisterForSingleUpdate(5)
endFunction

event OnUpdate()
	;/int idx = Game.GetModCount()
	string modName = ""
	while idx > 0
		idx -= 1
		modName = Game.GetModName(idx)
		if modName == "SexLab.esm"
			SexLab = Game.GetFormFromFile(0x00000D62, modName) as SexLabFramework
			Lib = Game.GetFormFromFile(0x00000D62, modName) as sslThreadLibrary
			bSexLab = true
			RegisterForModEvent("OrgasmStart", "OnSexLabOrgasm")
			RegisterForModEvent("SexLabOrgasmSeparate", "OnSexLabOrgasmSeparate")
			;Debug.Trace("BFA_ssl::OnGameLoad() = true")
			;UnregisterForUpdate()
			TryRegisterCount=0
			return
		endif
	endwhile/;
	;;;;; ;Tkc (Loverslab): standart detection
	if Game.IsPluginInstalled("SexLab.esm")
		SexLab = Game.GetFormFromFile(0x00000D62, "SexLab.esm") as SexLabFramework
		Lib = Game.GetFormFromFile(0x00000D62, "SexLab.esm") as sslThreadLibrary
		bSexLab = true
		RegisterForModEvent("OrgasmStart", "OnSexLabOrgasm")
		RegisterForModEvent("SexLabOrgasmSeparate", "OnSexLabOrgasmSeparate")
		;Trace("BFA_ssl::OnGameLoad() = true");temporary uncommented for tests
		;UnregisterForUpdate()
		TryRegisterCount=0
		return	
	endif
	;;;;;
	
	if (TryRegisterCount>10) ;Tkc (Loverslab): optimization
	else;if !(TryRegisterCount>10)
		;UnregisterForUpdate()
		RegisterForSingleUpdate(5)
		TryRegisterCount-=1
	endif
endEvent

function Refresh(string strArg, FWAddOnManager sender)
	;parent.Refresh(strArg, sender)
	OnGameLoad()
endFunction

bool function IsSSLActive() ;Edit by BAne
	return bSexLab
endFunction

bool function IsActive()
	return bSexLab
endFunction


function OnGiveBirthStart(actor Mother)
	if bSexLab;/==true/;
		Mother.SetFactionRank(SexLab.AnimatingFaction, 1)
	endif
endfunction

function OnGiveBirthEnd(actor Mother)
	if bSexLab;/==true/;
		Mother.RemoveFromFaction(SexLab.AnimatingFaction)
	endif
endfunction

bool function OnPainSound(actor Mother)
endfunction

bool function OnAllowFFCum(Actor WomanToAdd, Actor denor)
	if bSexLab ;Tkc (Loverslab): optimization
	else;if bSexLab==false
		return false
	endif
	return SexLab.Config.AllowFFCum
endFunction


bool function FixSexLab()
	if bSexLab ;Tkc (Loverslab): optimization
	else;if bSexLab==false
		return false
	endif
	if SexLab ;Tkc (Loverslab): optimization
	else;if SexLab==none
		SexLab = Game.GetFormFromFile(0x00000D62, "SexLab.esm") as SexLabFramework
		if SexLab ;Tkc (Loverslab): optimization
		else;if SexLab == none
			return false
		endif
	endif
	return true
endFunction

function Trace(string s)
	;System.Trace(s)
	Debug.Trace(s)
endFunction

Event OnSexLabOrgasm(string hookName, string argString, float argNum, form sender)
	;Trace("BFA_ssl::onSexLabOrgasm("+hookName+", "+argString+", "+argNum+", "+sender.GetName()+")")
	;Trace("[SexLabOrgasmEvent]")
	;Trace("0. Precheck")
	if SexLab ;Tkc (Loverslab): optimization
	else;if(SexLab==none)
		;Trace("   SexlLab is not defined - try to fix")
		if FixSexLab() ;Tkc (Loverslab): optimization
		else;if(FixSexLab()==false)
			;Trace("   Unable to fix SexLab")
			;Trace("[/SexLabOrgasmEvent]")
			return
		endif
	endif
	;Trace("1. Check for ThreadController")
	sslThreadController ssl_controller = SexLab.GetController(argString as int)
	if ssl_controller ;Tkc (Loverslab): optimization
	else;if ssl_controller==none
		;Trace("   Error: No sslThreadController found")
		;Trace("[SexLabOrgasmEvent]")
		return
	endif
	;Trace("2. Check for BaseAnimation")
	sslBaseAnimation animation = ssl_controller.Animation
	if animation ;Tkc (Loverslab): optimization
	else;if animation==none
		;Trace("   Error: No sslBaseAnimation found")
		;Trace("[SexLabOrgasmEvent]")
		return
	endif
	if (animation.PositionCount > 1)
		Orgasm(ssl_controller, animation)
	endIf
EndEvent

Event OnSexLabOrgasmSeparate(Form ActorRef, Int thread)
	;Trace("BFA_ssl::OnSexLabOrgasmSeparate("+ActorRef+", "+thread+")")
	;Trace("[SexLabOrgasmEvent]")
	;Trace("0. Precheck")
	if SexLab ;Tkc (Loverslab): optimization
	else;if(SexLab==none)
		;Trace("   SexlLab is not defined - try to fix")
		if FixSexLab() ;Tkc (Loverslab): optimization
		else;if(FixSexLab()==false)
			;Trace("   Unable to fix SexLab")
			;Trace("[/SexLabOrgasmEvent]")
			return
		endif
	endif
	;Trace("1. Check for ThreadController")
	sslThreadController ssl_controller = SexLab.GetController(thread)
	if ssl_controller ;Tkc (Loverslab): optimization
	else;if ssl_controller==none
		;Trace("   Error: No sslThreadController found")
		;Trace("[SexLabOrgasmEvent]")
		return
	endif
	;Trace("2. Check for BaseAnimation")
	sslBaseAnimation animation = ssl_controller.Animation
	if animation ;Tkc (Loverslab): optimization
	else;if animation==none
		;Trace("   Error: No sslBaseAnimation found")
		;Trace("[SexLabOrgasmEvent]")
		return
	endif
	Actor akActor = ActorRef as actor
	if (akActor)
		if (animation.PositionCount > 1 && ssl_controller.Positions.Find(akActor) > 0)
			Orgasm(ssl_controller, animation)
		endIf
	endIf
EndEvent

Function Orgasm(sslThreadController ssl_controller, sslBaseAnimation animation)
	;Trace("4. Check for Relevant animation")
	Bool relevantAnimation = false
	if(animation.HasTag("Vaginal"))
		relevantAnimation = true
		;Trace("   Animation was vaginal")
	endif
	if animation.HasTag("Anal")
		;Trace("   Animation was anal")
		if Utility.RandomInt(1,100)<=cfg.NoVaginalCumChance
			;Trace("   Continue using anal sperm")
			relevantAnimation=true
		endif
	endif
	;If cfg.CreatureSperm && (! relevantAnimation)
	If cfg.CreatureSperm ;Tkc (Loverslab): optimization
	 if relevantAnimation ;Tkc (Loverslab): optimization
	 else;if (! relevantAnimation)
		;Trace("   Check for Tags")
		if(animation.HasTag("Creature") && animation.HasTag("Bestiality") && (! animation.HasTag("Oral")) && (animation.HasTag("Missionary") || animation.HasTag("Doggystyle") || animation.HasTag("Holding") || animation.HasTag("MMMMF") || animation.HasTag("MMMF") || animation.HasTag("MMF")))
			;Trace("   Tags are allowed")
			relevantAnimation=true
		else
			;Trace("   Tags were forbidden")
			relevantAnimation=false
		endif
	 EndIf
	EndIf
	
	If relevantAnimation
		;Trace("5. Animation is relevant")
		float amount = 1.0
		int c= animation.PositionCount
		Actor Female = none
		actor Male = none
		actor tmpActor
		int i = 0
		
		;Trace("   "+c+" actors are involved")
		while i<c
			;tmpActor = ssl_controller.GetActor(i)
			tmpActor = ssl_controller.Positions[i]
			;/original
			if !Female && tmpActor!=none && tmpActor.GetLeveledActorBase().GetSex() == 1
				Female = tmpActor
			elseif !Male && tmpActor!=none && tmpActor.GetLeveledActorBase().GetSex() == 0
				Male = tmpActor
			endIf
			/;
			; ;Tkc (Loverslab): optimization
			if tmpActor
				int tmpSex = tmpActor.GetLeveledActorBase().GetSex()
				if tmpSex == 1
					if Female
					else;if !Female
						Female = tmpActor
					endif
				elseif tmpSex == 0 ;Tkc: if tmpSex == 0 could be commented for optimization but GetSex() have 3 values: 1,0 and -1(for none) and dont know if here is will be none
					if male
					else;if !male							
						Male = tmpActor	
					endif
				endif			
			endif			
			
			if Female;/!=none/; && Male;/!=none/;
				i=c
			else
				i+=1
			endIf
		endWhile
		
		; Check for female sperm
		;if (! Male && SexLab.Config.AllowFFCum;/==true/;)
		if Male ;Tkc (Loverslab): optimization
		else;if ! Male
		 if SexLab.Config.AllowFFCum
			;Trace("   Male was none - Check FF sperm")
			i = 0
			while i<c
				;tmpActor = ssl_controller.GetActor(i)
				tmpActor = ssl_controller.Positions[i]
				;if Male==none && tmpActor;/!=none/; && tmpActor!=Female && tmpActor.GetLeveledActorBase().GetSex() == 1
				if Male ;Tkc (Loverslab): optimization
				else;if Male==none
					if tmpActor
						if tmpActor==Female
						else;if tmpActor!=Female
							if tmpActor.GetLeveledActorBase().GetSex() == 1
								Male = tmpActor
							endIf
						endIf
					endIf
				endIf
				if Male;/!=none/;
					i=c
				else
					i+=1
				endIf
			endwhile
		 endIf
		endIf
		
		if Male ;Tkc (Loverslab): optimization
		else;if (! Male)
			;Trace("   Male is none - Exit")
			;Trace("[/SexLabOrgasmEvent]")
			return
		endif
		If Female ;Tkc (Loverslab): optimization
		else;If (! Female)
			;Trace("   Female was none - Try get victim")
			Female = ssl_controller.GetVictim()
		EndIf
		
		bool bCondom = System.CheckForCondome(Female, Male)
		
		;If Female && Male && bCondom==false
		If Female ;Tkc (Loverslab): optimization
		If Male
		If bCondom
		else;if bCondom==false
			;Trace("6. Male and Female are relevant for now")
			
			if Male.getLeveledActorBase().GetSex()==0
				if System.IsValidateMaleActor(Male)<0
					;Trace("   Male is not a validate Male Actor: "+System.IsValidateMaleActor(Male))
					;Trace("[/SexLabOrgasmEvent]")
					return
				endif
			else
				if System.IsValidateFemaleActor(Male)<0
					;Trace("   Male is not a validate Female Actor: "+System.IsValidateFemaleActor(Male))
					;Trace("[/SexLabOrgasmEvent]")
					return
				endif
			endif
			if Female.getLeveledActorBase().GetSex()==0
				if System.IsValidateMaleActor(Female)<0
					;Trace("   Female is not a validate Male Actor: "+System.IsValidateMaleActor(Female))
					;Trace("[/SexLabOrgasmEvent]")
					return
				endif
			else
				if System.IsValidateFemaleActor(Female)<0
					;Trace("   Female is not a validate Female Actor: "+System.IsValidateFemaleActor(Female))
					;Trace("[/SexLabOrgasmEvent]")
					return
				endif
			endif
			
			if System.DeviceActive;/==true/;
				;Trace("7. Check for Device")
				if Female.WornHasKeyword(System.zad_DeviousBelt); Female.IsEquipped(System.DeviceBelt);/==true/;  Bane --> Fixed to cover all Chastity Belts
					;Trace("   A Device-Belt was detected")
					;Trace("[/SexLabOrgasmEvent]")
					return
				;else
					;Trace("   No device was detected")
				endif
			endif
			
			;Trace("8. Add sperm")
			
			;Trace("   Raise AddOn Event 'OnCameInside'")
			;Manager.OnCameInside(Female,Male)
			
			;If Female.HasSpell(BeeingFemaleSpell)==false && System.IsValidateFemaleActor(Female)>0
			If Female.HasSpell(BeeingFemaleSpell) ;Tkc (Loverslab): optimization
			else;If Female.HasSpell(BeeingFemaleSpell)==false
			 if System.IsValidateFemaleActor(Female)>0
				;Trace("   Female doesn't had BF Spell - apply spell")
				System.ActorAddSpell(Female,BeeingFemaleSpell)
			 endif
			endif
			
			float virility = Controller.GetVirility(Male)
			amount = Utility.RandomFloat(virility * 0.75, virility*1.1)
			if amount>1.0
				amount=1.0
			endif
			;If cfg.MaleVirilityRecovery > 0.0
			;	float virility = FWUtility.ClampFloat(Controller.GetDaysSinceLastSex(Male) / cfg.MaleVirilityRecovery, 0.02, 1.0)
			;	amount = Utility.RandomFloat(virility * 0.75, virility*1.1)
			;	if amount>1.0
			;		amount=1.0
			;	endif
			;	System.Trace("   Base Sperm-Amount is " + amount)
			;EndIf
			
			amount = Manager.getSpermAmount(Female,Male,amount)
			;Trace("   Calculated Sperm-Amount is " + amount)
			
			if Female.HasSpell(BeeingFemaleSpell) ;Tkc (Loverslab): optimization
			else;if Female.HasSpell(BeeingFemaleSpell)==false
				;Trace("   Female still don't got the BF Spell - ignore and continue")
				System.Message( FWUtility.StringReplace( Content.NoBeeingFemaleSpell , "{0}",Female.GetLeveledActorBase().GetName()), System.MSG_Immersive)
			endif
			actor p = PlayerRef
			If Male == p
				;self.Message("You came inside " + Female.GetLeveledActorBase().GetName() + ".", self.MSG_Immersive)
				System.Message( FWUtility.StringReplace( Content.YouCameInsideNPC , "{0}",Female.GetLeveledActorBase().GetName()), System.MSG_Immersive)
			ElseIf Female == p
				;self.Message(Male.GetLeveledActorBase().GetName() + " came inside you.", self.MSG_Immersive)
				System.Message( FWUtility.StringReplace( Content.NPCCameInsideYou , "{0}",Male.GetLeveledActorBase().GetName()), System.MSG_Immersive)
			Else
				;self.Message(Male.GetLeveledActorBase().GetName() + " came inside " + Female.GetLeveledActorBase().GetName() + ".", self.Msg_High)
				string[] astring = new string[2]
				astring[0] = Male.GetLeveledActorBase().GetName()
				astring[1] = Female.GetLeveledActorBase().GetName()
				System.Message( FWUtility.ArrayReplace(Content.NPCCameInsideNPC,astring), System.Msg_High)
			EndIf
			
			if amount>0.0
				;Trace("   Finaly add " + amount + " sperm from "+Male.GetLeveledActorBase().GetName() + " to " +Female.GetLeveledActorBase().GetName())
				Controller.AddSperm(Female,Male, amount)				
			endif
		EndIf
		EndIf
		EndIf
	;else
		;Trace("5. Animation is NOT relevant")
	EndIf
	;Trace("[/SexLabOrgasmEvent]")
endFunction

bool function OnPlayPainSound(actor ActorRef, float Strength)
	if bSexLab ;Tkc (Loverslab): optimization
		;Trace("BF: OnPlayPainSound > bSexLab=true")
	else;if bSexLab==false
		;Trace("BF: OnPlayPainSound > bSexLab=false")
		return false
	endif
	sslBaseVoice voice = SexLab.PickVoice(ActorRef)
	;Trace("BF: OnPlayPainSound > voice="+voice as string)
	if voice
		voice.Moan(ActorRef, Strength as int, true);it is not working
		return true
	endif
endFunction

;/sslBaseVoice property SSLVoice auto hidden ;Tkc (Loverslab): sexlab sslBaseVoice module
bool property SexlabPainSounds auto ;Tkc (Loverslab): to be possible to disable it
function PlayPainSound(Actor A,float Strength=30.0)
	if bSexLab
		if SexlabPainSounds
			if SSLVoice
				;sslBaseVoice: PlayMoan(Actor ActorRef, int Strength = 30, bool IsVictim = false, bool UseLipSync = false)
				SSLVoice.PlayMoan(A, Strength as int, true, true) ; Tkc: tested in game and when Sexlab is active will be using pain sound from saved voices from Sexlab
			endif
		endif
	endif
endFunction/;

ObjectReference function OnGetBedRef(Actor ActorRef)
	if bSexLab ;Tkc (Loverslab): optimization
	else;if bSexLab==false
		return none
	endif
	Game.FindClosestReferenceOfAnyTypeInListFromRef(SexLab.Config.BedsList, ActorRef, 600.0)
endFunction

function OnMimik(actor ActorRef, string ExpressionName = "", int Strength = 50, bool bClear = true)
	if bSexLab ;Tkc (Loverslab): optimization
	else;if bSexLab==false
		return
	endif
	if bClear
		SexLab.ClearMFG(ActorRef)
	endif
	if ExpressionName;/!=""/; ;Tkc (Loverslab): optimization
		if SexLab.GetExpressionByName(ExpressionName);/!=none/;
			SexLab.GetExpressionByName(ExpressionName).Apply(ActorRef, Strength,1)
		endif
	endif
endFunction

Form[] function OnStripActor(Actor ActorRef)
	if bSexLab;/==true/;
		return SexLab.StripActor(ActorRef)
	endif
endFunction

; 02.06.2019 Tkc (Loverslab) optimizations: Changes marked with "Tkc (Loverslab)" comment. Added Sexlab pain sound when Sexlab is active(for example for giving birth)