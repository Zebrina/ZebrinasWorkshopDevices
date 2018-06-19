scriptname Zebrina:Workshop:DoorButtonScript extends ObjectReference const

group AutoFill
    Keyword property WorkshopStackedItemParentKeyword auto const mandatory
    Keyword property WorkshopLinkScriptControlled auto const mandatory
    Keyword property WorkshopHideActivateText auto const mandatory
endgroup
group Optional
    string property sAnimationEvent = "Play01" auto const
    float property fActivationDelay = 0.5 auto const
endgroup

event OnActivate(ObjectReference akActionRef)
    ObjectReference ref = self.GetLinkedRef(WorkshopLinkScriptControlled)
    if (ref)
        self.PlayAnimation(sAnimationEvent)
        Utility.Wait(fActivationDelay)
        ref.Activate(akActionRef)
    endif
endevent

event OnWorkshopObjectGrabbed(ObjectReference akWorkshopRef)
    self.SetLinkedRef(none, WorkshopStackedItemParentKeyword)
endevent
event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
    ObjectReference oldRef = self.GetLinkedRef(WorkshopLinkScriptControlled)
    ObjectReference newRef = self.GetLinkedRef(WorkshopStackedItemParentKeyword)
    if (newRef != oldRef)
        self.SetLinkedRef(newRef, WorkshopLinkScriptControlled)
        if (oldRef && oldRef.CountRefsLinkedToMe(WorkshopLinkScriptControlled) == 0)
            oldRef.ResetKeyword(WorkshopHideActivateText)
        endif
        if (newRef)
            newRef.AddKeyword(WorkshopHideActivateText)
        endif
    endif
endevent
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    self.OnWorkshopObjectMoved(akWorkshopRef)
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
    ObjectReference ref = self.GetLinkedRef(WorkshopLinkScriptControlled)
    if (ref && !ref.IsDisabled())
        self.SetLinkedRef(none, WorkshopLinkScriptControlled)
        if (ref.CountRefsLinkedToMe(WorkshopLinkScriptControlled) == 0)
            ref.ResetKeyword(WorkshopHideActivateText)
        endif
    endif
endevent
