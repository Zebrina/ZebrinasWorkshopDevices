scriptname Zebrina:Workshop:CircuitBreakerLidScript extends ObjectReference const

group AutoFill
    Keyword property WorkshopStackedItemParentKeyword auto const mandatory
endgroup

Zebrina:Workshop:CircuitBreakerScript property CircuitBreakerParent hidden
    Zebrina:Workshop:CircuitBreakerScript function get()
        return self.GetLinkedRef() as Zebrina:Workshop:CircuitBreakerScript
    endfunction
    function set(Zebrina:Workshop:CircuitBreakerScript akCircuitBreakerRef)
        Zebrina:Workshop:CircuitBreakerScript oldRef = CircuitBreakerParent
        if (akCircuitBreakerRef != oldRef)
            if (oldRef)
                oldRef.SetLidOpen(true)
            endif
            if (akCircuitBreakerRef)
                akCircuitBreakerRef.SetLidOpen(self.GetOpenState() <= 2)
            endif
            self.SetLinkedRef(akCircuitBreakerRef)
        endif
    endfunction
endproperty

event OnActivate(ObjectReference akActionRef)
    Zebrina:Workshop:CircuitBreakerScript ref = CircuitBreakerParent
    if (ref)
        ref.SetLidOpen(self.GetOpenState() <= 2)
    endif
endevent

event OnWorkshopObjectGrabbed(ObjectReference akWorkshopRef)
    CircuitBreakerParent = none
endevent
event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
    CircuitBreakerParent = self.GetLinkedRef(WorkshopStackedItemParentKeyword) as Zebrina:Workshop:CircuitBreakerScript
endevent
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    CircuitBreakerParent = self.GetLinkedRef(WorkshopStackedItemParentKeyword) as Zebrina:Workshop:CircuitBreakerScript
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
    CircuitBreakerParent = none
endevent
