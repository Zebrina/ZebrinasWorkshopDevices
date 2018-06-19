scriptname Zebrina:Workshop:PoweredTwoStateActivator extends Zebrina:Default:TwoStateActivator

import Zebrina:WorkshopUtility

group Configurable
    bool property bOpenWhenPowered = true auto
    { If false, will close when powered. }
endgroup

bool bPowerStateChangeInProgress = false

function HandlePowerStateChange(bool abWasPowered)
    if (!bPowerStateChangeInProgress)
        bPowerStateChangeInProgress = true
        Utility.Wait(0.01) ; Wait to avoid fake OnPowerOn events.
        if (abWasPowered == self.IsPowered())
            while ((self.IsPowered() == (self.GetState() == "IsOpen")) != bOpenWhenPowered)
                self.SetOpen(self.IsPowered() == bOpenWhenPowered)
            endwhile
        endif
        bPowerStateChangeInProgress = false
    endif
endfunction

event OnPowerOn(ObjectReference akPowerGenerator)
    HandlePowerStateChange(true)
endevent
event OnPowerOff()
    HandlePowerStateChange(false)
endevent
