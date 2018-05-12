scriptname Zebrina:Workshop:RelinkStackedObjectScript extends ObjectReference const

group AutoFill
    Keyword property WorkshopStackedItemParentKeyword auto const mandatory
endgroup
group RelinkStackedObject
    Keyword property LinkKeyword = none auto const
    bool property bRemainStacked = true auto const
endgroup

function Relink()
    ObjectReference parentRef = self.GetLinkedRef(WorkshopStackedItemParentKeyword)
    if (parentRef)
        if (!bRemainStacked)
            self.SetLinkedRef(none, WorkshopStackedItemParentKeyword)
        endif
        self.SetLinkedRef(parentRef, LinkKeyword)
    endif
endfunction

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    Relink()
endevent
event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
    Relink()
endevent
