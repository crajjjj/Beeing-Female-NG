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
		Debug.Messagebox("Father race cannot be found...")
	endIf
	Debug.Messagebox("Child Parent Race: " + ParentRace)
	MiscObject b
	if sex==0
		; Male
		b=Manager.GetBabyItem(ParentRace,0)
		if b!=none
			return b
		else
			Debug.Messagebox("BabyItem cannot be found and thus reverting to FallBack_MaleBabyItem...")
			return FallBack_MaleBabyItem
		endif
	else
		; Female
		b=Manager.GetBabyItem(ParentRace,1)
		if b!=none
			return b
		else
			Debug.Messagebox("BabyItem cannot be found and thus reverting to FallBack_FemaleBabyItem...")
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
		Debug.Messagebox("Father race cannot be found...")
	endIf
	Debug.Messagebox("Child Parent Race: " + ParentRace)
	Armor b
	if sex==0
		; Male
		b=Manager.GetBabyArmor(ParentRace,0)
		if b!=none
			return b
		else
			Debug.Messagebox("BabyArmor cannot be found and thus reverting to FallBack_MaleBabyArmor...")
			return FallBack_MaleBabyArmor
		endif
	else
		; Female
		b=Manager.GetBabyArmor(ParentRace,1)
		if b!=none
			return b
		else
			Debug.Messagebox("BabyArmor cannot be found and thus reverting to FallBack_FemaleBabyArmor...")
			return FallBack_FemaleBabyArmor
		endIf
	endIf
endFunction

; my custom edit for Skyrim SE
GlobalVariable Property myBFA_ProbChildRaceDeterminedByFather Auto

ActorBase function getBabyActor(actor Mother, actor Father, int sex)
	if Mother == PlayerRef || Father == PlayerRef
		return getPlayerBabyActor(Mother, Father, sex)
	endif
	
	race MotherRace = Mother.GetLeveledActorBase().GetRace()

	int ProbChildRaceDeterminedByFather = myBFA_ProbChildRaceDeterminedByFather.GetValueInt()
	race ParentRace
	Actor ParentActor
	If(Utility.RandomInt(0, 99) < ProbChildRaceDeterminedByFather)
		ParentActor = Father
		ParentRace = ParentActor.GetLeveledActorBase().GetRace()
	Else
		ParentActor = Mother
		ParentRace = MotherRace
	EndIF
	LastRace = ParentRace
	ActorBase b
	
	if Father == none
		Debug.Messagebox("Father cannot be found...")
	endIf
	; Check Forces Babys
	if ((StorageUtil.GetIntValue(MotherRace, "FW.AddOn.Female_Force_This_Baby")==1) || (ParentRace == none))
		if sex==0
			; Male
			b=Manager.GetBabyActor(MotherRace,0)
			if b
				return b
			else
				Debug.Messagebox("BabyActor cannot be found and thus summoning base NPC of the Mother race...")
				return Mother.GetLeveledActorBase()
			endif
		else
			; Female
			b=Manager.GetBabyActor(MotherRace,1)
			if b
				return b
			else
				Debug.Messagebox("BabyActor cannot be found and thus summoning base NPC of the Mother race...")
				return Mother.GetLeveledActorBase()
			endIf
		endIf
	endif
	
	; No forced Baby found - Use default methode to get the babys race
	Debug.Trace("Child Parent Race: " + ParentRace)

	if sex==0
		; Male
		b=Manager.GetBabyActor(ParentRace,0)
		if b
			return b
		else
			Debug.Messagebox("BabyActor cannot be found and thus summoning base NPC of the Parent race...")
			return ParentActor.GetLeveledActorBase()
		endif
	else
		; Female
		b=Manager.GetBabyActor(ParentRace,1)
		if b
			return b
		else
			Debug.Messagebox("BabyActor cannot be found and thus summoning base NPC of the Parent race...")
			return ParentActor.GetLeveledActorBase()
		endIf
	endIf
endFunction

ActorBase function getPlayerBabyActor(actor Mother, actor Father, int sex)
	race MotherRace = Mother.GetLeveledActorBase().GetRace()

	int ProbChildRaceDeterminedByFather = myBFA_ProbChildRaceDeterminedByFather.GetValueInt()
	race ParentRace
	Actor ParentActor
	If(Utility.RandomInt(0, 99) < ProbChildRaceDeterminedByFather)
		ParentActor = Father
		ParentRace = ParentActor.GetLeveledActorBase().GetRace()
	Else
		ParentActor = Mother
		ParentRace = MotherRace
	EndIF
	LastRace = ParentRace
	ActorBase b
	
	if Father == none
		Debug.Messagebox("Father cannot be found...")
	endIf
	; Check Forces Babys
	if ((StorageUtil.GetIntValue(MotherRace, "FW.AddOn.Female_Force_This_Baby")==1) || (ParentRace == none))
		if sex==0
			; Male
			b=Manager.GetPlayerBabyActor(MotherRace,0)
			if b
				return b
			else
				Debug.Messagebox("PlayerBabyActor cannot be found and thus summoning base NPC of the Mother race...")
				return Mother.GetLeveledActorBase()
			endif
		else
			; Female
			b=Manager.GetPlayerBabyActor(MotherRace,1)
			if b
				return b
			else
				Debug.Messagebox("PlayerBabyActor cannot be found and thus summoning base NPC of the Mother race...")
				return Mother.GetLeveledActorBase()
			endIf
		endIf
	endif
	
	; No forced Baby found - Use default methode to get the babys race
	Debug.Trace("Child Parent Race: " + ParentRace)

	if sex==0
		; Male
		b=Manager.GetPlayerBabyActor(ParentRace,0)
		if b
			return b
		else
			Debug.Messagebox("PlayerBabyActor cannot be found and thus summoning base NPC of the Parent race...")
			return ParentActor.GetLeveledActorBase()
		endif
	else
		; Female
		b=Manager.GetPlayerBabyActor(ParentRace,1)
		if b
			return b
		else
			Debug.Messagebox("PlayerBabyActor cannot be found and thus summoning base NPC of the Parent race...")
			return ParentActor.GetLeveledActorBase()
		endIf
	endIf
endFunction








ActorBase function getBabyActorByRace(race RaceID, int sex)
	ActorBase b
	if sex==0
		; Male
		b=Manager.GetBabyActor(RaceID,0)
		if b!=none
			return b
		else
			Debug.Messagebox("BabyActor cannot be found and thus reverting to FallBack_MaleBabyActor...")
			return FallBack_MaleBabyActor
		endif
	else
		; Female
		b=Manager.GetBabyActor(RaceID,1)
		if b!=none
			return b
		else
			Debug.Messagebox("BabyActor cannot be found and thus reverting to FallBack_FemaleBabyActor...")
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
			Debug.Messagebox("PlayerBabyActor cannot be found and thus reverting to FallBack_MalePlayerBabyActor...")
			return FallBack_MalePlayerBabyActor
		endif
	else
		; Female
		b=Manager.GetPlayerBabyActor(RaceID,1)
		if b!=none
			return b
		else
			Debug.Messagebox("PlayerBabyActor cannot be found and thus reverting to FallBack_FemalePlayerBabyActor...")
			return FallBack_FemalePlayerBabyActor
		endIf
	endIf
endFunction