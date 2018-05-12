scriptname Zebrina:Workshop:DoorChainScript extends ObjectReference

import Zebrina:WorkshopUtility

group AutoFill
    Message property ChainedDoorMSG auto const mandatory
    Message property ChainedDoorOpenMSG auto const mandatory
    Sound property DRSChainGenericLocked auto const mandatory
    Sound property DRSChainGenericUnlock auto const mandatory
    Keyword property PlayerActivateDoorChained auto const mandatory
    Keyword property PlayerActivateDoorChainedSameSide auto const mandatory
    Keyword property WorkshopStackedItemParentKeyword auto const mandatory
    Keyword property WorkshopIgnoredDoor auto const mandatory
endgroup

ObjectReference doorRef = none

function InitializeDoor()
    doorRef.AddKeyword(WorkshopIgnoredDoor)
    doorRef.SetLockLevel(252) ; Chained.
    ; Lock only if in 'Closed' state.
    if (doorRef.GetOpenState() == 3)
        doorRef.Lock()
    endif
endfunction
function RegisterDoorEvents()
    if (doorRef)
        self.RegisterForRemoteEvent(doorRef, "OnActivate")
        self.RegisterForRemoteEvent(doorRef, "OnWorkshopObjectDestroyed")
    endif
endfunction
function UnregisterDoorEvents()
    if (doorRef)
        self.UnregisterForRemoteEvent(doorRef, "OnActivate")
        self.UnregisterForRemoteEvent(doorRef, "OnWorkshopObjectDestroyed")
    endif
endfunction

event OnActivate(ObjectReference akActionRef)
    ; Chain activated.
    if (IsPlayerActionRef(akActionRef))

    endif
endevent
event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    ; Door activated.
    if (IsPlayerActionRef(akActionRef))

    endif
endevent

event OnLoad()
    RegisterDoorEvents()
endevent
event OnUnload()
    UnregisterDoorEvents()
endevent

event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
    ObjectReference newDoorRef = self.GetLinkedRef(WorkshopStackedItemParentKeyword)
    if (newDoorRef != doorRef)
        self.UnregisterForAllRemoteEvents()
        self.RegisterForRemoteEvent(newDoorRef, "OnActivate")
        self.RegisterForRemoteEvent(newDoorRef, "OnWorkshopObjectDestroyed")
    endif
endevent
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    ObjectReference newDoorRef = self.GetLinkedRef(WorkshopStackedItemParentKeyword)
    if (!newDoorRef.HasKeyword(WorkshopIgnoredDoor))
        doorRef = newDoorRef
        InitializeDoor()
    endif
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
    self.UnregisterForAllRemoteEvents()
    doorRef = none
endevent
event ObjectReference.OnWorkshopObjectDestroyed(ObjectReference akSender, ObjectReference akWorkshopRef)

endevent
