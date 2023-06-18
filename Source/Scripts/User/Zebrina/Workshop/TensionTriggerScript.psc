scriptname Zebrina:Workshop:TensionTriggerScript extends ObjectReference const

group AutoFill
	Zebrina:WorkshopDevicesParent property ZebrinasWorkshopDevices auto const mandatory
	Message property WorkshopSelectTensionTriggerTargetDialogue auto const mandatory
    Zebrina:WorkshopSelectionQuest property WorkshopSelectDoorIncludeScriptControlled auto const mandatory
endgroup

function InitializeDoor()
    if (WorkshopSelectTensionTriggerTargetDialogue.Show() == 1)
        ClearDoor()
        ObjectReference doorRef = ZebrinasWorkshopDevices.SelectWorkshopObject(self, WorkshopSelectDoorIncludeScriptControlled)
        if (doorRef)
			self.RegisterForRemoteEvent(doorRef, "OnOpen")
			self.RegisterForRemoteEvent(doorRef, "OnClose")
			self.RegisterForRemoteEvent(doorRef, "OnActivate")
			self.SetLinkedRef(doorRef)
			SetTriggered(doorRef.GetOpenState() <= 2)
		else
			SetTriggered(true)
        endif
    endif
endfunction
function ClearDoor()
	self.UnregisterForAllRemoteEvents()
	self.SetLinkedRef(none)
endfunction

bool function IsTriggered()
	return self.GetOpenState() == 3
endfunction
function SetTriggered(bool abShouldBeTriggered = true)
	if (abShouldBeTriggered != IsTriggered())
		if (abShouldBeTriggered)
			self.PlayAnimation("Trip")
		else
			self.PlayAnimation("Reset")
		endif
	endif
	self.SetOpen(!abShouldBeTriggered)
endfunction

bool function ShouldTrigger(ObjectReference akTriggerRef)
    return true;akTriggerRef is Actor && (akTriggerRef as Actor).IsHostileToActor(Game.GetPlayer())
endFunction

event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
	if (akSender.GetOpenState() == 2 && ShouldTrigger(akActionRef))
		SetTriggered(true)
	endif
endevent
event ObjectReference.OnOpen(ObjectReference akSender, ObjectReference akActionRef)
	if (ShouldTrigger(akActionRef))
		SetTriggered(true)
	endif
endevent
event ObjectReference.OnClose(ObjectReference akSender, ObjectReference akActionRef)
	SetTriggered(false)
endevent

event OnLoad()
	self.BlockActivation()
endevent

event OnWorkshopObjectMoved(ObjectReference akReference)
	InitializeDoor()
endevent
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
	InitializeDoor()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	ClearDoor()
endevent
