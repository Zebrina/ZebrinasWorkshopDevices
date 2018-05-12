scriptname Zebrina:Workshop:ButtonScript extends ObjectReference

group AutoFill
    ActorValue property WorkshopObjectTimeoutSeconds_AV auto const mandatory
endgroup
group Button
    bool property bIsGenerator = false auto const
endgroup
group Animations
    string property sPressAnimation = "Press" auto const
    string property sPressAnimationEvent = "End" auto const
	string property sTurnOnAnimation = "TurnOn01" auto const
    string property sTurnOffAnimation = "TurnOff01" auto const
endgroup

float property fTimeoutSeconds hidden
    float function get()
        return self.GetValue(WorkshopObjectTimeoutSeconds_AV)
    endfunction
    function set(float value)
        self.SetValue(WorkshopObjectTimeoutSeconds_AV, value)
    endfunction
endproperty

function TurnOn()
    self.SetOpen(false)
    self.PlayAnimation(sTurnOnAnimation)
endfunction
function TurnOff()
    self.PlayAnimation(sTurnOffAnimation)
    self.SetOpen()
endfunction

event OnActivate(ObjectReference akActionRef)
    if (self.Is3DLoaded() && !self.IsActivationBlocked())
        self.BlockActivation(true)

        ; Play "press" animation.
        self.PlayAnimationAndWait(sPressAnimation, sPressAnimationEvent)
        if (bIsGenerator || self.IsPowered())
            TurnOn()
            self.StartTimer(fTimeoutSeconds)
        endif

        self.BlockActivation(false)
    endif
endevent

event OnTimer(int aiTimerID)
    TurnOff()
endevent

event OnPowerOff()
    if (!bIsGenerator)
        TurnOff()
    endif
endevent
