scriptname Zebrina:Workshop:StackableDoorScript extends ObjectReference

Message property TutorialStackableDoor auto const mandatory
Message property ConfirmStackedPlacementMessage auto const mandatory
Keyword property WorkshopStackedItemParentKeyword auto const mandatory
Static property RefAttachParentObject auto const mandatory

ObjectReference refAttachParentRef

function HandlePlacedWorkshopObject(ObjectReference akReference)
endfunction
function ExitStackingMode()
endfunction

auto state Idle
endstate
state StackWorkshopObjectsToSelf
    function HandlePlacedWorkshopObject(ObjectReference akReference)
        akReference.SetLinkedRef(refAttachParentRef, WorkshopStackedItemParentKeyword)
    endfunction

    function ExitStackingMode()
        self.GoToState("Idle")
    endfunction
endstate

event ObjectReference.OnWorkshopObjectMoved(ObjectReference akSender, ObjectReference akReference)
    HandlePlacedWorkshopObject(akReference)
endevent
event ObjectReference.OnWorkshopObjectPlaced(ObjectReference akSender, ObjectReference akReference)
    HandlePlacedWorkshopObject(akReference)
endevent
event ObjectReference.OnWorkshopMode(ObjectReference akSender, bool abStart)
    ExitStackingMode()
endevent

event OnWorkshopObjectGrabbed(ObjectReference akWorkshopRef)
    ExitStackingMode()
endevent
event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
    if (ConfirmStackedPlacementMessage.Show() == 0)
        self.GoToState("StackWorkshopObjectsToSelf")
    endif
endevent
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    self.PlaceAtNode("REF_ATTACH_NODE", RefAttachParentObject, abAttach = true)
    self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopMode")
    self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectPlaced")
    self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectMoved")
    TutorialStackableDoor.Show()
    self.OnWorkshopObjectMoved(akWorkshopRef)
endevent
