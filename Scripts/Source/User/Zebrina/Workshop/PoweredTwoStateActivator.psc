scriptname Zebrina:Workshop:PoweredTwoStateActivator extends Zebrina:Default:TwoStateActivator

group AutoFill
    Keyword property WorkshopScriptControlledKeyword auto const mandatory
endgroup
group Configurable
    bool property bOpenWhenPowered = true auto
    { If false, will close when powered. }
endgroup

; Zebrina:Default:TwoStateActivator override.
event OnActivate(ObjectReference akActionRef)
endevent

bool powerStateChangeInProgress = false
function HandlePowerStateChange(bool abWasPowered)
    if (!powerStateChangeInProgress && !self.HasKeyword(WorkshopScriptControlledKeyword))
        powerStateChangeInProgress = true
        Utility.Wait(0.01) ; Wait to avoid fake OnPowerOn events.
        if (abWasPowered == self.IsPowered())
            while ((self.IsPowered() == (self.GetOpenState() == 1)) != bOpenWhenPowered)
                self.SetOpen(self.IsPowered() == bOpenWhenPowered)
            endwhile
        endif
        powerStateChangeInProgress = false
    endif
endfunction

event OnPowerOn(ObjectReference akPowerGenerator)
    HandlePowerStateChange(true)
endevent
event OnPowerOff()
    HandlePowerStateChange(false)
endevent
