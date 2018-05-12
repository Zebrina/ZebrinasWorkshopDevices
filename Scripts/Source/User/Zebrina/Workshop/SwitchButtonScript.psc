scriptname Zebrina:Workshop:SwitchButtonScript extends ObjectReference const

group AutoFill
    Keyword property WorkshopObjectHandleActivation auto const mandatory
endgroup
group Properties
    string property sPressAnimation = "Press" auto const
    string property sPressAnimationEvent = "End" auto const
    float property fPressAnimationDuration = 0.667 auto const
	string property sTurnOnAnimation = "TurnOn01" auto const
    string property sTurnOnAnimationEvent = "End" auto const
    string property sTurnOffAnimation = "TurnOff01" auto const
    string property sTurnOffAnimationEvent = "End" auto const
endgroup

function UpdateButtonState()
    self.WaitFor3DLoad()
    if (self.GetOpenState() == 3 && self.IsPowered())
        ; Play "turn on" animation.
        self.PlayAnimationAndWait(sTurnOnAnimation, sTurnOnAnimationEvent)
    else
        ; Play "turn off" animation.
        self.PlayAnimationAndWait(sTurnOffAnimation, sTurnOffAnimationEvent)
    endif
endfunction

event OnActivate(ObjectReference akActionRef)
    if (self.Is3DLoaded() && !self.HasKeyword(WorkshopObjectHandleActivation))
        self.AddKeyword(WorkshopObjectHandleActivation)
        ; Play "press" animation.
        self.PlayAnimationAndWait(sPressAnimation, sPressAnimationEvent)
        UpdateButtonState()
        self.ResetKeyword(WorkshopObjectHandleActivation)
    endif
endevent

event OnPowerOn(ObjectReference akPowerGenerator)
    UpdateButtonState()
endevent
event OnPowerOff()
    UpdateButtonState()
endevent

event OnLoad()
    UpdateButtonState()
endevent
