scriptname Zebrina:Workshop:CircuitBreakerScript extends Zebrina:Workshop:LidScript const

group AutoFill
    Message property CircuitBreakerDeniedMessage auto const
    ActorValue property WorkshopObjectIsAnimating_AV auto const mandatory
    ActorValue property WorkshopObjectOpenState_AV auto const mandatory
endgroup
group CircuitBreaker
	string property sSwitchAnimation = "Play01" auto const
    string property sSwitchEventName = "Done" auto const
    bool property bIsGenerator = false auto const
    float property fLidOpenResetDelay = 0.5 auto const
    float property fPowerOffResetDelay = 0.5 auto const
endgroup

function ToggleSwitchState()
    while (self.GetValue(WorkshopObjectIsAnimating_AV) == 1.0)
        Utility.Wait(0.01)
    endwhile
    self.SetValue(WorkshopObjectIsAnimating_AV, 1.0)
    if ((self.GetOpenState() == 3) != (self.GetValue(WorkshopObjectOpenState_AV) == 1.0))
        self.PlayAnimationAndWait(sSwitchAnimation, sSwitchEventName)
        self.SetValue(WorkshopObjectOpenState_AV, 1.0 - self.GetValue(WorkshopObjectOpenState_AV))
    endif
    self.SetValue(WorkshopObjectIsAnimating_AV, 0.0)
endfunction
function SetSwitchState(bool abShouldBeActivated)
    if (abShouldBeActivated != (self.GetValue(WorkshopObjectOpenState_AV) == 1.0))
        ToggleSwitchState()
    endif
endfunction

; LidScript override.
function HandleLidState(ObjectReference akLidRef, bool abOpen, bool abWasActivated)
    parent.HandleLidState(akLidRef, abOpen, abWasActivated)
    if (abOpen)
        if (!bIsGenerator && !self.IsPowered())
            self.StartTimer(fLidOpenResetDelay)
        endif
    else
        ; Lid was closed before time out.
        self.CancelTimer()
    endif
endfunction

; LidScript override.
event OnActivate(ObjectReference akActionRef)
    ;parent.OnActivate(akActionRef)
    ToggleSwitchState()
    if (!bIsGenerator && !self.IsPowered())
        if (akActionRef == Game.GetPlayer())
            CircuitBreakerDeniedMessage.Show()
        endif
        SetSwitchState(false)
    endif
endevent

event OnPowerOff()
    if (!bIsGenerator && IsLidOpen())
        self.StartTimer(fPowerOffResetDelay)
    endif
endevent
event OnPowerOn(ObjectReference akPowerGenerator)
    ; Power came back before time out.
    self.CancelTimer()
endevent

event OnTimer(int aiTimerID)
    if (IsLidOpen() && !self.IsPowered())
        SetSwitchState(false)
    endif
endevent

; LidScript override.
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    parent.OnWorkshopObjectPlaced(akWorkshopRef)
    self.SetOpen() ; Start off.
endevent
