Scriptname FWOvulationItem extends FWSpell 

;FWSystem property System auto

actor ActorRef
bool bInit=false

GlobalVariable Property GameDaysPassed Auto

function execute()

	if bInit==false || ActorRef==none
		return
	endif

	if System.Player.currentState < 4
		if(System.Player.currentState - 1)
			Debug.Trace("FWOvulationItem - Changing state of " + ActorRef + " to Ovulation_State.")
			StorageUtil.SetIntValue(ActorRef,"FW.CurrentState", 1)
			StorageUtil.SetFloatValue(ActorRef,"FW.StateEnterTime", GameDaysPassed.GetValue())
			StorageUtil.SetFloatValue(ActorRef,"FW.LastUpdate",GameDaysPassed.GetValue())
			System.Player.InitState()
		endIf
	endIf
endfunction

Event OnWoman(Actor akTarget, Actor akCaster)
	ActorRef = akCaster
	execute()
endEvent

Event OnInit()
	bInit=true
	parent.OnInit()
	execute()
endEvent