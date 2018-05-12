scriptname Zebrina:Workshop:IDCardReaderDummyScript extends ObjectReference const

import Zebrina:WorkshopUtility

group AutoFill
	Keyword property WorkshopLinkAttachedDoor auto const mandatory
	Quest property WorkshopFindClosestPrimaryIDCardReader auto const mandatory

    Zebrina:Workshop:WorkshopDevicesMasterScript property ZebrinasWorkshopDevices auto const mandatory
endgroup
group Optional
	float property fAttachToDoorRadius = 256.0 auto const
endgroup

ObjectReference function AttachToClosestPrimaryIDCardReader()
	self.UnregisterForAllCustomEvents()
	ObjectReference parentRef = ZebrinasWorkshopDevices.FindWorkshopObject(self, WorkshopFindClosestPrimaryIDCardReader, fAttachToDoorRadius)
	self.SetLinkedRef(parentRef, WorkshopLinkAttachedDoor)
	if (parentRef)
		self.RegisterForCustomEvent(parentRef as Zebrina:Workshop:IDCardReaderScript, "GreenStateBegin")
		self.RegisterForCustomEvent(parentRef as Zebrina:Workshop:IDCardReaderScript, "GreenStateEnd")
	endif
endfunction

event Zebrina:Workshop:IDCardReaderScript.GreenStateBegin(Zebrina:Workshop:IDCardReaderScript akSender, var[] akArgs)
	if ((akArgs[0] as ObjectReference) != self)
		self.PlayAnimation("StartGreen")
	endif
endevent
event Zebrina:Workshop:IDCardReaderScript.GreenStateEnd(Zebrina:Workshop:IDCardReaderScript akSender, var[] akArgs)
	self.PlayAnimation("Reset")
endevent

event OnActivate(ObjectReference akActionRef)
    if (akActionRef is Actor)
        ObjectReference primaryRef = self.GetLinkedRef(WorkshopLinkAttachedDoor)
        if (primaryRef && akActionRef.HasDirectLOS(self))
            (primaryRef as Zebrina:Workshop:IDCardReaderScript).HandleActivation(self, akActionRef as Actor)
        endif
	endif
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
	self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectPlaced")
	self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectMoved")
	self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectDestroyed")
	AttachToClosestPrimaryIDCardReader()
endevent
event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
	AttachToClosestPrimaryIDCardReader()
endevent

function HandleRemoteWorkshopEvent(ObjectReference akSender, ObjectReference akReference)
	if (akSender is WorkshopScript && akReference != self && akReference.GetBaseObject() is IDCardReaderScript)
		AttachToClosestPrimaryIDCardReader()
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
