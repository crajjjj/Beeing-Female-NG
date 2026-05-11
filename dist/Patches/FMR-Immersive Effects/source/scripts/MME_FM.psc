Scriptname MME_FM extends Quest Hidden

; FMR-IE: Standalone - no FM+ dependencies
; FMR Faction Ranks: 1-100 = pregnancy, 101-115 = recovery, 0 = cleared

Faction Property ImmersiveEffectsFaction Auto

Event OnInit()
	StorageUtil.SetIntValue(none,"MME.PluginsCheck.fm",2)
EndEvent

bool Function IsIntegraged ()
	Return True
EndFunction

bool Function IsPregnant (Actor akActor)
	if !ImmersiveEffectsFaction
		return False
	endIf
	int RoughCurrentTime = akActor.GetFactionRank(ImmersiveEffectsFaction)
	If RoughCurrentTime >= 1 && RoughCurrentTime <= 100
		debug.Trace("MilkModEconomy FMR Pregnancy: " + akActor.GetLeveledActorBase().GetName())
		Return True
	ElseIf RoughCurrentTime >= 101 && RoughCurrentTime <= 115
		debug.Trace("MilkModEconomy FMR Recovery: " + akActor.GetLeveledActorBase().GetName())
		Return True
	Else
		Return False
	endIf
EndFunction