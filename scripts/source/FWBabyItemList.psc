Scriptname FWBabyItemList extends Quest  
FWAddOnManager property Manager auto

MiscObject property FallBack_MaleBabyItem Auto hidden
MiscObject property FallBack_FemaleBabyItem Auto hidden

Armor property FallBack_MaleBabyArmor Auto
Armor property FallBack_FemaleBabyArmor Auto

ActorBase property FallBack_MaleBabyActor Auto
ActorBase property FallBack_FemaleBabyActor Auto

ActorBase property FallBack_MalePlayerBabyActor Auto
ActorBase property FallBack_FemalePlayerBabyActor Auto

string[] property Female_Names auto
string[] property Male_Names auto

race property LastRace auto hidden

Actor Property PlayerRef Auto
FWSystemConfig property cfg auto

MiscObject function getBabyItem(actor Mother, actor Father, int sex)
	race ParentRace = Father.GetLeveledActorBase().GetRace()
	
	race MotherRace = Mother.GetLeveledActorBase().GetRace()
	LastRace = ParentRace
	
	; Check Forces Babys
	if StorageUtil.GetIntValue(MotherRace, "FW.AddOn.Female_Force_This_Baby")==1
		int mCount=StorageUtil.FormListCount(MotherRace,"FW.AddOn.BabyMesh_Male")
		int fCount=StorageUtil.FormListCount(MotherRace,"FW.AddOn.BabyMesh_Female")
		if mCount>0 && sex==0
			; First, check Random child from list
			MiscObject force_mo_m=StorageUtil.FormListGet(MotherRace,"FW.AddOn.BabyMesh_Male", Utility.RandomInt(0,mCount - 1)) as MiscObject
			if force_mo_m!=none
				return force_mo_m
			endif
			; Random Child was none, go through list
			int i=0
			while i<mCount
				i+=1
				force_mo_m=StorageUtil.FormListGet(MotherRace,"FW.AddOn.BabyMesh_Male", i) as MiscObject
				if force_mo_m!=none
					return force_mo_m
				endif
			endwhile
		elseif fCount>0 && sex==1
			; First, check Random child from list
			MiscObject force_mo_f=StorageUtil.FormListGet(MotherRace,"FW.AddOn.BabyMesh_Female", Utility.RandomInt(0,fCount - 1)) as MiscObject
			if force_mo_f!=none
				return force_mo_f
			endif
			; Random Child was none, go through list
			int i=0
			while i<mCount
				i+=1
				force_mo_f=StorageUtil.FormListGet(MotherRace,"FW.AddOn.BabyMesh_Female", i) as MiscObject
				if force_mo_f!=none
					return force_mo_f
				endif
			endwhile
		endif
	endif
	
	; No forced Baby found - Use default methode to get the babys race
	if Father == none
		Debug.Trace("BeeingFemale - FWBabyItemList - getBabyItem - Father race cannot be found...")
		if cfg.ShowDebugMessage
			Debug.Messagebox("Father race cannot be found...")
		endIf
	endIf
	
	Debug.Trace("BeeingFemale - FWBabyItemList - getBabyItem - Child Parent Race: " + ParentRace)
	if cfg.ShowDebugMessage
		Debug.Messagebox("Child Parent Race: " + ParentRace)
	endIf
	
	MiscObject b
	if sex==0
		; Male
		b=Manager.GetBabyItem(ParentRace,0)
		if b!=none
			return b
		else
			Debug.Trace("BeeingFemale - FWBabyItemList - getBabyItem - BabyItem cannot be found and thus reverting to FallBack_MaleBabyItem...")
			if cfg.ShowDebugMessage
				Debug.Messagebox("BabyItem cannot be found and thus reverting to FallBack_MaleBabyItem...")
			endIf
			return FallBack_MaleBabyItem
		endif
	else
		; Female
		b=Manager.GetBabyItem(ParentRace,1)
		if b!=none
			return b
		else
			Debug.Trace("BeeingFemale - FWBabyItemList - getBabyItem - BabyItem cannot be found and thus reverting to FallBack_FemaleBabyItem...")
			if cfg.ShowDebugMessage
				Debug.Messagebox("BabyItem cannot be found and thus reverting to FallBack_FemaleBabyItem...")
			endIf
			return FallBack_FemaleBabyItem
		endIf
	endIf
endFunction

Armor function getBabyArmor(actor Mother, actor Father, int sex)
	race ParentRace = Father.GetLeveledActorBase().GetRace()
	
	race MotherRace = Mother.GetLeveledActorBase().GetRace()
	LastRace = ParentRace
	
	; Check Forces Babys
	if StorageUtil.GetIntValue(MotherRace, "FW.AddOn.Female_Force_This_Baby")==1
		int mCount=StorageUtil.FormListCount(MotherRace,"FW.AddOn.BabyArmor_Male")
		int fCount=StorageUtil.FormListCount(MotherRace,"FW.AddOn.BabyArmor_Female")
		if mCount>0 && sex==0
			; First, check Random child from list
			Armor force_mo_m=StorageUtil.FormListGet(MotherRace,"FW.AddOn.BabyArmor_Male", Utility.RandomInt(0,mCount - 1)) as Armor
			if force_mo_m!=none
				return force_mo_m
			endif
			; Random Child was none, go through list
			int i=0
			while i<mCount
				i+=1
				force_mo_m=StorageUtil.FormListGet(MotherRace,"FW.AddOn.BabyArmor_Male", i) as Armor
				if force_mo_m!=none
					return force_mo_m
				endif
			endwhile
		elseif fCount>0 && sex==1
			; First, check Random child from list
			Armor force_mo_f=StorageUtil.FormListGet(MotherRace,"FW.AddOn.BabyArmor_Female", Utility.RandomInt(0,fCount - 1)) as Armor
			if force_mo_f!=none
				return force_mo_f
			endif
			; Random Child was none, go through list
			int i=0
			while i<mCount
				i+=1
				force_mo_f=StorageUtil.FormListGet(MotherRace,"FW.AddOn.BabyArmor_Female", i) as Armor
				if force_mo_f!=none
					return force_mo_f
				endif
			endwhile
		endif
	endif
	
	; No forced Baby found - Use default methode to get the babys race
	if Father == none
		Debug.Trace("BeeingFemale - FWBabyItemList - getBabyArmor - Father race cannot be found...")
		if cfg.ShowDebugMessage
			Debug.Messagebox("Father race cannot be found...")
		endIf
	endIf

	Debug.Trace("BeeingFemale - FWBabyItemList - getBabyArmor - Child Parent Race: " + ParentRace)
	if cfg.ShowDebugMessage
		Debug.Messagebox("Child Parent Race: " + ParentRace)
	endIf
	
	Armor b
	if sex==0
		; Male
		b=Manager.GetBabyArmor(ParentRace,0)
		if b!=none
			return b
		else
			Debug.Trace("BeeingFemale - FWBabyItemList - getBabyArmor - BabyArmor cannot be found and thus reverting to FallBack_MaleBabyArmor...")
			if cfg.ShowDebugMessage
				Debug.Messagebox("BabyArmor cannot be found and thus reverting to FallBack_MaleBabyArmor...")
			endIf
			return FallBack_MaleBabyArmor
		endif
	else
		; Female
		b=Manager.GetBabyArmor(ParentRace,1)
		if b!=none
			return b
		else
			Debug.Trace("BeeingFemale - FWBabyItemList - getBabyArmor - BabyArmor cannot be found and thus reverting to FallBack_FemaleBabyArmor...")
			if cfg.ShowDebugMessage
				Debug.Messagebox("BabyArmor cannot be found and thus reverting to FallBack_FemaleBabyArmor...")
			endIf
			return FallBack_FemaleBabyArmor
		endIf
	endIf
endFunction

; my custom edit for Skyrim SE
ActorBase function getBabyActor(actor Mother, actor Father, int sex)
	if Mother == PlayerRef || Father == PlayerRef
		return getPlayerBabyActor(Mother, Father, sex)
	endif
	
	race MotherRace = Mother.GetLeveledActorBase().GetRace()

	race ParentRace
	Actor ParentActor

	int myProbRandom = Utility.RandomInt(0, 99)
	int myChildRaceDeterminedByFather = Manager.ActorChildRaceDeterminedByFather(Father)
	Debug.Trace("BeeingFemaleSE_Opt - FWBabyItemList - getBabyActor: ChildRaceDeterminedByFather = " + myChildRaceDeterminedByFather)
	
	If(myProbRandom < myChildRaceDeterminedByFather)
		Debug.Trace("BeeingFemaleSE_Opt - FWBabyItemList - getBabyActor: myProbRandom = " + myProbRandom + ", which is less than the ChildRaceDeterminedByFather. Child will follow father's race.")

		ParentActor = Father
		ParentRace = ParentActor.GetLeveledActorBase().GetRace()
	Else
		Debug.Trace("BeeingFemaleSE_Opt - FWBabyItemList - getBabyActor: myProbRandom = " + myProbRandom + ", which is not less than the ChildRaceDeterminedByFather. Child will follow mother's race.")

		ParentActor = Mother
		ParentRace = MotherRace
	EndIF
	LastRace = ParentRace
	ActorBase b
	
	if Father == none
		Debug.Trace("BeeingFemale - FWBabyItemList - getBabyActor - Father cannot be found...")
		if cfg.ShowDebugMessage
			Debug.Messagebox("Father cannot be found...")
		endIf
	endIf
	; Check Forces Babys
	if ((StorageUtil.GetIntValue(MotherRace, "FW.AddOn.Female_Force_This_Baby")==1) || (ParentRace == none))
		if sex==0
			; Male
			b=Manager.GetBabyActor(MotherRace,0)
			if b
				return b
			else
				Debug.Trace("BeeingFemale - FWBabyItemList - getBabyActor - BabyActor cannot be found and thus summoning base NPC of the Mother race...")
				if cfg.ShowDebugMessage
					Debug.Messagebox("BabyActor cannot be found and thus summoning base NPC of the Mother race...")
				endIf
				return Mother.GetLeveledActorBase()
			endif
		else
			; Female
			b=Manager.GetBabyActor(MotherRace,1)
			if b
				return b
			else
				Debug.Trace("BeeingFemale - FWBabyItemList - getBabyActor - BabyActor cannot be found and thus summoning base NPC of the Mother race...")
				if cfg.ShowDebugMessage
					Debug.Messagebox("BabyActor cannot be found and thus summoning base NPC of the Mother race...")
				endIf
				return Mother.GetLeveledActorBase()
			endIf
		endIf
	endif
	
	; No forced Baby found - Use default methode to get the babys race
	Debug.Trace("BeeingFemale - FWBabyItemList - getBabyActor - Child Parent Race: " + ParentRace)
	if cfg.ShowDebugMessage
		Debug.Messagebox("Child Parent Race: " + ParentRace)
	endIf

	int myProbChildActor = Manager.RaceProbChildActorBorn(ParentRace)
	if(myProbChildActor > 0)
		Debug.Trace("BeeingFemale - FWBabyItemList - getBabyActor - MixWithCopyActorBase is turned on!")
		
		int myProbChildActorRandom = Utility.RandomInt(0, 99)
		if(myProbChildActorRandom < myProbChildActor)
			Debug.Trace("BeeingFemale - FWBabyItemList - getBabyActor - Fall in to the ProbChildActorBorn in the AddOn!")

			if sex==0
				; Male
				b=Manager.GetBabyActor(ParentRace,0)
				if b
				else
					Debug.Trace("BeeingFemale - FWBabyItemList - getBabyActor - BabyActor cannot be found and thus summoning base NPC of the Parent race...")
					if cfg.ShowDebugMessage
						Debug.Messagebox("BabyActor cannot be found and thus summoning base NPC of the Parent race...")
					endIf

					b = ParentActor.GetLeveledActorBase()
				endif
			else
				; Female
				b=Manager.GetBabyActor(ParentRace,1)
				if b
				else
					Debug.Trace("BeeingFemale - FWBabyItemList - getBabyActor - BabyActor cannot be found and thus summoning base NPC of the Parent race...")
					if cfg.ShowDebugMessage
						Debug.Messagebox("BabyActor cannot be found and thus summoning base NPC of the Parent race...")
					endIf

					b = ParentActor.GetLeveledActorBase()
				endIf
			endIf
		else
			Debug.Trace("BeeingFemale - FWBabyItemList - getBabyActor - Summoning base NPC of the Parent race due to the AddOn settings...")

			b = ParentActor.GetLeveledActorBase()
		endIf
	else
		if sex==0
			; Male
			b=Manager.GetBabyActor(ParentRace,0)
			if b
			else
				Debug.Trace("BeeingFemale - FWBabyItemList - getBabyActor - BabyActor cannot be found and thus summoning base NPC of the Parent race...")
				if cfg.ShowDebugMessage
					Debug.Messagebox("BabyActor cannot be found and thus summoning base NPC of the Parent race...")
				endIf

				b = ParentActor.GetLeveledActorBase()
			endif
		else
			; Female
			b=Manager.GetBabyActor(ParentRace,1)
			if b
			else
				Debug.Trace("BeeingFemale - FWBabyItemList - getBabyActor - BabyActor cannot be found and thus summoning base NPC of the Parent race...")
				if cfg.ShowDebugMessage
					Debug.Messagebox("BabyActor cannot be found and thus summoning base NPC of the Parent race...")
				endIf

				b = ParentActor.GetLeveledActorBase()
			endIf
		endIf
	endIf

	if(StorageUtil.SetIntValue(ParentRace, "FW.AddOn.ProtectedChildActor", 0) == 1)
		b.SetProtected()
	else
		if(StorageUtil.SetIntValue(none, "FW.AddOn.Global_ProtectedChildActor", 0) == 1)
			b.SetProtected()
		endIf
	endIf

	return b
endFunction

ActorBase function getPlayerBabyActor(actor Mother, actor Father, int sex)
	race MotherRace = Mother.GetLeveledActorBase().GetRace()

	race ParentRace
	Actor ParentActor
	
	int myProbRandom = Utility.RandomInt(0, 99)
	int myChildRaceDeterminedByFather = Manager.ActorChildRaceDeterminedByFather(Father)
	Debug.Trace("BeeingFemaleSE_Opt - FWBabyItemList - getPlayerBabyActor: ChildRaceDeterminedByFather = " + myChildRaceDeterminedByFather)
	
	If(myProbRandom < myChildRaceDeterminedByFather)
		Debug.Trace("BeeingFemaleSE_Opt - FWBabyItemList - getPlayerBabyActor: myProbRandom = " + myProbRandom + ", which is less than the ChildRaceDeterminedByFather. Child will follow father's race.")

		ParentActor = Father
		ParentRace = ParentActor.GetLeveledActorBase().GetRace()
	Else
		Debug.Trace("BeeingFemaleSE_Opt - FWBabyItemList - getPlayerBabyActor: myProbRandom = " + myProbRandom + ", which is not less than the ChildRaceDeterminedByFather. Child will follow mother's race.")

		ParentActor = Mother
		ParentRace = MotherRace
	EndIF
	LastRace = ParentRace
	ActorBase b
	
	if Father == none
		Debug.Trace("BeeingFemale - FWBabyItemList - getPlayerBabyActor - Father cannot be found...")
		if cfg.ShowDebugMessage
			Debug.Messagebox("Father cannot be found...")
		endIf
	endIf
	; Check Forces Babys
	if ((StorageUtil.GetIntValue(MotherRace, "FW.AddOn.Female_Force_This_Baby")==1) || (ParentRace == none))
		if sex==0
			; Male
			b=Manager.GetPlayerBabyActor(MotherRace,0)
			if b
				return b
			else
				Debug.Trace("BeeingFemale - FWBabyItemList - getPlayerBabyActor - PlayerBabyActor cannot be found and thus summoning base NPC of the Mother race...")
				if cfg.ShowDebugMessage
					Debug.Messagebox("PlayerBabyActor cannot be found and thus summoning base NPC of the Mother race...")
				endIf
				return Mother.GetLeveledActorBase()
			endif
		else
			; Female
			b=Manager.GetPlayerBabyActor(MotherRace,1)
			if b
				return b
			else
				Debug.Trace("BeeingFemale - FWBabyItemList - getPlayerBabyActor - PlayerBabyActor cannot be found and thus summoning base NPC of the Mother race...")
				if cfg.ShowDebugMessage
					Debug.Messagebox("PlayerBabyActor cannot be found and thus summoning base NPC of the Mother race...")
				endIf
				return Mother.GetLeveledActorBase()
			endIf
		endIf
	endif
	
	; No forced Baby found - Use default methode to get the babys race
	Debug.Trace("BeeingFemale - FWBabyItemList - getPlayerBabyActor - Child Parent Race: " + ParentRace)
	if cfg.ShowDebugMessage
		Debug.Messagebox("Child Parent Race: " + ParentRace)
	endIf

	int myProbChildActor = Manager.RaceProbChildActorBorn(ParentRace)
	if(myProbChildActor > 0)
		Debug.Trace("BeeingFemale - FWBabyItemList - getPlayerBabyActor - MixWithCopyActorBase is turned on!")
		
		int myProbChildActorRandom = Utility.RandomInt(0, 99)
		if(myProbChildActorRandom < myProbChildActor)
			Debug.Trace("BeeingFemale - FWBabyItemList - getPlayerBabyActor - Fall in to the ProbChildActorBorn in the AddOn!")

			if sex==0
				; Male
				b=Manager.GetPlayerBabyActor(ParentRace,0)
				if b
				else
					Debug.Trace("BeeingFemale - FWBabyItemList - getPlayerBabyActor - PlayerBabyActor cannot be found and thus summoning base NPC of the Parent race...")
					if cfg.ShowDebugMessage
						Debug.Messagebox("PlayerBabyActor cannot be found and thus summoning base NPC of the Parent race...")
					endIf
					
					b = ParentActor.GetLeveledActorBase()
				endif
			else
				; Female
				b=Manager.GetPlayerBabyActor(ParentRace,1)
				if b
				else
					Debug.Trace("BeeingFemale - FWBabyItemList - getPlayerBabyActor - PlayerBabyActor cannot be found and thus summoning base NPC of the Parent race...")
					if cfg.ShowDebugMessage
						Debug.Messagebox("PlayerBabyActor cannot be found and thus summoning base NPC of the Parent race...")
					endIf

					b = ParentActor.GetLeveledActorBase()
				endIf
			endIf
		else
			Debug.Trace("BeeingFemale - FWBabyItemList - getPlayerBabyActor - Summoning base NPC of the Parent race due to the AddOn settings...")
			b = ParentActor.GetLeveledActorBase()
		endIf
	else
		if sex==0
			; Male
			b=Manager.GetPlayerBabyActor(ParentRace,0)
			if b
			else
				Debug.Trace("BeeingFemale - FWBabyItemList - getPlayerBabyActor - PlayerBabyActor cannot be found and thus summoning base NPC of the Parent race...")
				if cfg.ShowDebugMessage
					Debug.Messagebox("PlayerBabyActor cannot be found and thus summoning base NPC of the Parent race...")
				endIf

				b = ParentActor.GetLeveledActorBase()
			endif
		else
			; Female
			b=Manager.GetPlayerBabyActor(ParentRace,1)
			if b
			else
				Debug.Trace("BeeingFemale - FWBabyItemList - getPlayerBabyActor - PlayerBabyActor cannot be found and thus summoning base NPC of the Parent race...")
				if cfg.ShowDebugMessage
					Debug.Messagebox("PlayerBabyActor cannot be found and thus summoning base NPC of the Parent race...")
				endIf

				b = ParentActor.GetLeveledActorBase()
			endIf
		endIf
	endIf

	if(StorageUtil.SetIntValue(ParentRace, "FW.AddOn.ProtectedChildActor", 0) == 1)
		b.SetProtected()
	else
		if(StorageUtil.SetIntValue(none, "FW.AddOn.Global_ProtectedChildActor", 0) == 1)
			b.SetProtected()
		endIf
	endIf

	return b
endFunction








ActorBase function getBabyActorByRace(race RaceID, int sex)
	ActorBase b
	if sex==0
		; Male
		b=Manager.GetBabyActor(RaceID,0)
		if b!=none
			return b
		else
			Debug.Trace("BeeingFemale - FWBabyItemList - getBabyActorByRace - BabyActor cannot be found and thus reverting to FallBack_MaleBabyActor...")
			if cfg.ShowDebugMessage
				Debug.Messagebox("BabyActor cannot be found and thus reverting to FallBack_MaleBabyActor...")
			endIf
			return FallBack_MaleBabyActor
		endif
	else
		; Female
		b=Manager.GetBabyActor(RaceID,1)
		if b!=none
			return b
		else
			Debug.Trace("BeeingFemale - FWBabyItemList - getBabyActorByRace - BabyActor cannot be found and thus reverting to FallBack_FemaleBabyActor...")
			if cfg.ShowDebugMessage
				Debug.Messagebox("BabyActor cannot be found and thus reverting to FallBack_FemaleBabyActor...")
			endIf
			return FallBack_FemaleBabyActor
		endIf
	endIf
endFunction

ActorBase function getPlayerBabyActorByRace(race RaceID, int sex)
	ActorBase b
	if sex==0
		; Male
		b=Manager.GetPlayerBabyActor(RaceID,0)
		if b!=none
			return b
		else
			Debug.Trace("BeeingFemale - FWBabyItemList - getPlayerBabyActorByRace - PlayerBabyActor cannot be found and thus reverting to FallBack_MalePlayerBabyActor...")
			if cfg.ShowDebugMessage
				Debug.Messagebox("PlayerBabyActor cannot be found and thus reverting to FallBack_MalePlayerBabyActor...")
			endIf
			return FallBack_MalePlayerBabyActor
		endif
	else
		; Female
		b=Manager.GetPlayerBabyActor(RaceID,1)
		if b!=none
			return b
		else
			Debug.Trace("BeeingFemale - FWBabyItemList - getPlayerBabyActorByRace - PlayerBabyActor cannot be found and thus reverting to FallBack_FemalePlayerBabyActor...")
			if cfg.ShowDebugMessage
				Debug.Messagebox("PlayerBabyActor cannot be found and thus reverting to FallBack_FemalePlayerBabyActor...")
			endIf
			return FallBack_FemalePlayerBabyActor
		endIf
	endIf
endFunction