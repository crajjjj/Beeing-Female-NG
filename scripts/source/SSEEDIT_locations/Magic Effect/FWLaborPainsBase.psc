Scriptname FWLaborPainsBase extends activemagiceffect  

FWSystem property System auto
float property DamageBase auto
float property UpdateDelay auto
int property KindOfPains auto
bool property Silent = false auto
actor ActorRef


Event OnEffectStart(Actor akTarget, Actor akCaster)
	ActorRef=akTarget
	Utility.Wait(Utility.RandomFloat( (UpdateDelay*0.75) + 2, (UpdateDelay* 1.1) + 2))
	OnUpdateGameTime()
endEvent

function OnUpdateGameTime()
	float rnd=Utility.RandomFloat(-1.0,1.0)
	if Silent ;Tkc (Loverslab): optimization
	else;if Silent==false
		System.PlayPainSound(ActorRef,(DamageBase+rnd) *4)
	endif
	System.DoDamage(ActorRef,(DamageBase+rnd) * System.getDamageScale(3,ActorRef), KindOfPains)
	If self as string == "[FWLaborPainsBase <None>]" ;Tkc (Loverslab): optimization
	else;If self as string != "[FWLaborPainsBase <None>]"
		RegisterForSingleUpdateGameTime( Utility.RandomFloat(UpdateDelay*0.75,UpdateDelay* 1.1))
	EndIf
endFunction

; 02.06.2019 Tkc (Loverslab) optimizations: Changes marked with "Tkc (Loverslab)" comment