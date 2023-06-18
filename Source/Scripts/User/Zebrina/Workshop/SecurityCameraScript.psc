scriptname Zebrina:Workshop:SecurityCameraScript extends Zebrina:Workshop:ConfigurableObjectScript conditional

group AutoFill
    GlobalVariable property ConfigTerminalValue1 auto const mandatory
    GlobalVariable property ConfigTerminalValue2 auto const mandatory
    GlobalVariable property ConfigTerminalValue3 auto const mandatory
endgroup
group Configurable
    bool property bDetectPlayer = true auto conditional hidden
    bool property bDetectHostile = true auto conditional hidden
    bool property bDetectFriendly = true auto conditional hidden
endgroup

int actorsInLineOfSight = 0

; Zebrina:Workshop:ConfigurableObjectScript override.
function DoConfiguration(ObjectReference akReference)
    ConfigTerminalValue1.SetValue(bDetectPlayer as float)
    ConfigTerminalValue2.SetValue(bDetectPlayer as float)
    ConfigTerminalValue3.SetValue(bDetectPlayer as float)
    parent.DoConfiguration(akReference)
endfunction

function UpdateLOSCount(int aiLineOfSightCount)
    actorsInLineOfSight = aiLineOfSightCount
    self.CancelTimer()
    if (actorsInLineOfSight > 0)
        self.SetOpen(false)
    else
        self.StartTimer(3.0)
    endif
    Debug.Notification("Security Camera los count: " + actorsInLineOfSight)
endfunction
event OnTimer(int aiTimerID)
    self.SetOpen()
endevent

event OnTriggerEnter(ObjectReference akActionRef)
    self.RegisterForDirectLOSGain(akActionRef, self, "Head")
endevent
event OnTriggerLeave(ObjectReference akActionRef)
    self.UnregisterForLOS(akActionRef, self)
    if (akActionRef.HasDirectLOS(self))
        UpdateLOSCount(actorsInLineOfSight - 1)
    endif

    ; Safety check.
    if (self.GetTriggerObjectCount() == 0)
        UpdateLOSCount(0)
    endif
endevent

event OnGainLOS(ObjectReference akViewer, ObjectReference akTarget)
    self.RegisterForDirectLOSLost(akViewer, self, "Head")
    UpdateLOSCount(actorsInLineOfSight + 1)
endevent
event OnLostLOS(ObjectReference akViewer, ObjectReference akTarget)
    self.RegisterForDirectLOSGain(akViewer, self, "Head")
    UpdateLOSCount(actorsInLineOfSight - 1)
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    self.BlockActivation()
endevent
