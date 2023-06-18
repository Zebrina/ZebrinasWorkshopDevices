scriptname Zebrina:WorkshopSelectionQuest extends Quest

ReferenceAlias property CurrentWorkshop auto const mandatory
ReferenceAlias property SourceReference auto const mandatory
RefCollectionAlias property TargetReferences auto const mandatory
int property TargetReferencesObjectiveIndex = 10 auto const
int property ShutdownStage = 20 auto const
ObjectReference selectedTarget = none

event OnQuestInit()
    self.RegisterForRemoteEvent(CurrentWorkshop.GetReference(), "OnWorkshopMode")
    self.RegisterForRemoteEvent(SourceReference.GetReference(), "OnWorkshopObjectGrabbed")
    self.RegisterForRemoteEvent(SourceReference.GetReference(), "OnWorkshopObjectDestroyed")
    self.RegisterForRemoteEvent(TargetReferences, "OnWorkshopObjectGrabbed")
    self.RegisterForRemoteEvent(TargetReferences, "OnWorkshopObjectDestroyed")
    self.SetObjectiveDisplayed(TargetReferencesObjectiveIndex, true, true)
endevent

ObjectReference function GetSelectedTarget()
    while (self.IsRunning() && selectedTarget == none)
        Utility.Wait(0.1)
    endwhile
    return selectedTarget
endfunction

function CompleteSelection()
    self.SetObjectiveDisplayed(TargetReferencesObjectiveIndex, false, true)
    self.SetStage(ShutdownStage)
    self.Stop()
endfunction

event ObjectReference.OnWorkshopMode(ObjectReference akSender, bool abStart)
    if (!abStart)
        CompleteSelection()
    endif
endevent

event ObjectReference.OnWorkshopObjectGrabbed(ObjectReference akSender, ObjectReference akWorkshopRef)
    CompleteSelection()
endevent
event ObjectReference.OnWorkshopObjectDestroyed(ObjectReference akSender, ObjectReference akWorkshopRef)
    CompleteSelection()
endevent
event RefCollectionAlias.OnWorkshopObjectGrabbed(RefCollectionAlias akAliasSender, ObjectReference akRefSender, ObjectReference akWorkshopRef)
    selectedTarget = akRefSender
endevent
event RefCollectionAlias.OnWorkshopObjectDestroyed(RefCollectionAlias akAliasSender, ObjectReference akRefSender, ObjectReference akWorkshopRef)
    akAliasSender.RemoveRef(akRefSender)
endevent
