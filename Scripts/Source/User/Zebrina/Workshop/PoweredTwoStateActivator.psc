scriptname Zebrina:Workshop:PoweredTwoStateActivator extends Zebrina:Default:TwoStateActivator const

group AutoFill
    Keyword property WorkshopObjectHandlePowerState auto const mandatory
    ActorValue property WorkshopObjectReversePowerState_AV auto const mandatory
endgroup

; Zebrina:Default:TwoStateActivator override.
event OnActivate(ObjectReference akActionRef)
    ; Do nothing.
endevent

function HandlePowerStateChange()
    if (!self.HasKeyword(WorkshopObjectHandlePowerState))
        self.AddKeyword(WorkshopObjectHandlePowerState)
        bool reversePowerState = self.GetValue(WorkshopObjectReversePowerState_AV) != 0.0
        while ((self.IsPowered() != self.IsOpen()) != reversePowerState)
            self.SetOpen(self.IsPowered() != reversePowerState)
            ;Utility.Wait(0.1) ; Wait to see if power state still matches open state.
        endwhile
        self.ResetKeyword(WorkshopObjectHandlePowerState)
    endif
endfunction

event OnPowerOn(ObjectReference akPowerGenerator)
    HandlePowerStateChange()
endevent
event OnPowerOff()
    HandlePowerStateChange()
endevent
