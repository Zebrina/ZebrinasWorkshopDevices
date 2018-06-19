scriptname Zebrina:Workshop:TensionTriggerScript extends ObjectReference const

import Zebrina:Workshop

group AutoFill
	Quest property WorkshopFindClosestDoor auto const mandatory
	WorkshopDevicesMasterScript property ZebrinasWorkshopDevices auto const mandatory
endgroup
group Animations
	string property sTripAnim = "Trip" auto const
	string property sResetAnim = "Reset" auto const
endgroup
group TensionTrigger
	float property fAttachToDoorRadius = 128.0 auto const
endgroup

ObjectReference property LinkedDoorRef hidden
	ObjectReference function get()
		return self.GetLinkedRef()
	endfunction
	function set(ObjectReference akLinkedDoorRef)
		ObjectReference doorRef = LinkedDoorRef
		if (doorRef)
			self.UnregisterForRemoteEvent(akLinkedDoorRef, "OnOpen")
			self.UnregisterForRemoteEvent(akLinkedDoorRef, "OnClose")
			self.UnregisterForRemoteEvent(akLinkedDoorRef, "OnActivate")
		endif
		if (akLinkedDoorRef)
			self.RegisterForRemoteEvent(akLinkedDoorRef, "OnOpen")
			self.RegisterForRemoteEvent(akLinkedDoorRef, "OnClose")
			self.RegisterForRemoteEvent(akLinkedDoorRef, "OnActivate")
			SetTriggered(akLinkedDoorRef.GetOpenState() <= 2)
		else
			SetTriggered(true)
		endif
		self.SetLinkedRef(akLinkedDoorRef)
	endfunction
endproperty

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

function RegisterForDoorEvents(ObjectReference akTargetRef)
	if (akTargetRef)
		self.RegisterForRemoteEvent(akTargetRef, "OnOpen")
		self.RegisterForRemoteEvent(akTargetRef, "OnClose")
		self.RegisterForRemoteEvent(akTargetRef, "OnActivate")
	endif
endfunction
function UnregisterForDoorEvents(ObjectReference akTargetRef)
	if (akTargetRef)
		self.UnregisterForRemoteEvent(akTargetRef, "OnOpen")
		self.UnregisterForRemoteEvent(akTargetRef, "OnClose")
		self.UnregisterForRemoteEvent(akTargetRef, "OnActivate")
	endif
endfunction

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

function AttachToClosestDoor()
	LinkedDoorRef = ZebrinasWorkshopDevices.FindWorkshopObject(self, WorkshopFindClosestDoor, fAttachToDoorRadius)
endfunction

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
	self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectPlaced")
	self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectMoved")
	self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectDestroyed")
	AttachToClosestDoor()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	self.UnregisterForAllRemoteEvents()
endevent

function HandleRemoteWorkshopEvent(ObjectReference akSender, ObjectReference akReference)
	if (akReference.GetBaseObject() is Door && akReference.GetDistance(self) < LinkedDoorRef.GetDistance(self))
		AttachToClosestDoor()
	endif
endfunction
event ObjectReference.OnWorkshopObjectPlaced(ObjectReference akSender, ObjectReference akReference)
	HandleRemoteWorkshopEvent(akSender, akReference)
endevent
event ObjectReference.OnWorkshopObjectMoved(ObjectReference akSender, ObjectReference akReference)
	if (akReference == self)
		AttachToClosestDoor()
	else
		HandleRemoteWorkshopEvent(akSender, akReference)
	endif
endevent
event ObjectReference.OnWorkshopObjectDestroyed(ObjectReference akSender, ObjectReference akReference)
	if (akReference == LinkedDoorRef)
		AttachToClosestDoor()
	endif
endevent
