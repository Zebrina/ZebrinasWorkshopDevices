scriptname Zebrina:Workshop:ProximitySwitchScript extends ObjectReference conditional

group AutoFill
    Activator property WorkshopProximitySwitchTriggerBox auto const mandatory
endgroup
group Configurable
    float property fTriggerDistance = 200.0 auto hidden
    int property iTriggerCount = 1 auto hidden
    bool property bTriggeredByHostile = true auto conditional hidden
    bool property bTriggeredByFriendly = true auto conditional hidden
    bool property bTriggeredByHuman = true auto conditional hidden
    bool property bTriggeredByGhoul = true auto conditional hidden
    bool property bTriggeredBySynth = true auto conditional hidden
    bool property bTriggeredBySuperMutant = true auto conditional hidden
    bool property bTriggeredByRobot = true auto conditional hidden
    bool property bTriggeredByCreature = true auto conditional hidden
    bool property bTriggeredByAnimal = true auto conditional hidden
endgroup

ObjectReference triggerBoxRef
bool bWorkshopMode = true

function ResetTriggerBoxPosition()
    triggerBoxRef.SetScale(fTriggerDistance / 128.0)
    triggerBoxRef.MoveTo(self)
endfunction

function UpdateState()
    self.SetOpen(!(!bWorkshopMode && triggerBoxRef.GetTriggerObjectCount() >= iTriggerCount))
    Debug.Notification("triggerBoxRef trigger count: " + triggerBoxRef.GetTriggerObjectCount())
endfunction

event ObjectReference.OnTriggerEnter(ObjectReference akSender, ObjectReference akActionRef)
    UpdateState()
endevent
event ObjectReference.OnTriggerLeave(ObjectReference akSender, ObjectReference akActionRef)
    UpdateState()
endevent

event ObjectReference.OnWorkshopMode(ObjectReference akSender, bool abStart)
    bWorkshopMode = abStart
    if (abStart)
        triggerBoxRef.Disable()
    else
        ResetTriggerBoxPosition()
        triggerBoxRef.Enable()
    endif
    UpdateState()
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    self.BlockActivation()

    triggerBoxRef = self.PlaceAtMe(WorkshopProximitySwitchTriggerBox)
    triggerBoxRef.DisableNoWait()
    triggerBoxRef.SetLinkedRef(self)
    self.RegisterForRemoteEvent(triggerBoxRef, "OnTriggerEnter")
    self.RegisterForRemoteEvent(triggerBoxRef, "OnTriggerLeave")

    self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopMode")
endevent

event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
    self.UnregisterForAllEvents()

    triggerBoxRef.Delete()
    triggerBoxRef = none
endevent
