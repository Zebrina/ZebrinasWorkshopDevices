scriptname Zebrina:Workshop:CircuitBreakerLidScript extends ObjectReference

group AutoFill
    Keyword property WorkshopStackedItemParentKeyword auto const mandatory
endgroup

Zebrina:Workshop:CircuitBreakerScript parentRef = none

Zebrina:Workshop:CircuitBreakerScript function GetParent()
    return self.GetLinkedRef(WorkshopStackedItemParentKeyword) as Zebrina:Workshop:CircuitBreakerScript
endfunction
function InitializeParent()
    parentRef = self.GetLinkedRef(WorkshopStackedItemParentKeyword) as Zebrina:Workshop:CircuitBreakerScript
    if (parentRef)
        parentRef.SetLidOpen(self.GetOpenState() <= 2)
    endif
endfunction
function ClearParent()
    if (parentRef)
        parentRef.SetLidOpen(true)
    endif
    parentRef = none
endfunction

event OnActivate(ObjectReference akActionRef)
    Zebrina:Workshop:CircuitBreakerScript ref = GetParent()
    if (ref)
        ref.SetLidOpen(self.GetOpenState() <= 2)
    endif
endevent

event OnWorkshopObjectGrabbed(ObjectReference akWorkshopRef)
    ClearParent()
endevent
event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
    InitializeParent()
endevent
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    InitializeParent()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
    ClearParent()
endevent
