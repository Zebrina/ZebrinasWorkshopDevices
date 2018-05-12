scriptname Zebrina:Workshop:TensionTriggerScript extends ObjectReference const

import Zebrina:Workshop

group AutoFill
	WorkshopDevicesMasterScript property ZebrinasWorkshopDevices auto const mandatory
	Quest property WorkshopFindClosestDoor auto const mandatory
endgroup
group Animations
	string property sTripAnim = "Trip" auto const
	string property sResetAnim = "Reset" auto const
endgroup
group TensionTrigger
	float property fAttachToDoorRadius = 128.0 auto const
endgroup

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
	if (!akSender.IsLocked() && ShouldTrigger(akActionRef))
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

function UnattachFromDoor()
	self.UnregisterForAllRemoteEvents()
	self.SetLinkedRef(none)
endfunction
ObjectReference function AttachToClosestDoor()
	ObjectReference currentDoorRef = ZebrinasWorkshopDevices.FindWorkshopObject(self, WorkshopFindClosestDoor, fAttachToDoorRadius)
	self.SetLinkedRef(currentDoorRef)
	if (currentDoorRef)
		self.RegisterForRemoteEvent(currentDoorRef, "OnOpen")
		self.RegisterForRemoteEvent(currentDoorRef, "OnClose")
		self.RegisterForRemoteEvent(currentDoorRef, "OnActivate")
	endif

	SetTriggered(currentDoorRef == none || currentDoorRef.GetOpenState() == 1 || currentDoorRef.GetOpenState() == 2)

	return currentDoorRef
endfunction

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
	self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectPlaced")
	self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectMoved")
	self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectDestroyed")

	self.SetOpen() ; Starts OFF.

	AttachToClosestDoor()
endevent
event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
	UnattachFromDoor()
	AttachToClosestDoor()
endevent

function HandleRemoteWorkshopEvent(ObjectReference akSender, ObjectReference akReference)
	if (akSender is WorkshopScript && akReference != self && akReference.GetBaseObject() is Door)
		UnattachFromDoor()
		AttachToClosestDoor()
	endif
endfunction
event ObjectReference.OnWorkshopObjectPlaced(ObjectReference akSender, ObjectReference akReference)
	HandleRemoteWorkshopEvent(akSender, akReference)
endevent
event ObjectReference.OnWorkshopObjectMoved(ObjectReference akSender, ObjectReference akReference)
	HandleRemoteWorkshopEvent(akSender, akReference)
endevent
event ObjectReference.OnWorkshopObjectDestroyed(ObjectReference akSender, ObjectReference akReference)
	HandleRemoteWorkshopEvent(akSender, akReference)
endevent
