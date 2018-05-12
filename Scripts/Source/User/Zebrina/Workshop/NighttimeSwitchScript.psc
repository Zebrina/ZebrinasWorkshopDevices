scriptname Zebrina:Workshop:NighttimeSwitchScript extends ObjectReference const

group AutoFill
    GlobalVariable property GameHour auto const mandatory
    ActorValue property WorkshopObjectTurnOnAtHour_AV auto const mandatory
    ActorValue property WorkshopObjectTurnOffAtHour_AV auto const mandatory
endgroup
group NighttimeSwitch
    bool property bIsGenerator = false auto const
endgroup
group Animations
    bool property bUseAnimations = true auto const
    string property sTurnOnAnimation = "TurnOn01" auto const
    string property sTurnOffAnimation = "TurnOff01" auto const
endgroup

float property fTurnOnAtGameHour hidden
    float function get()
        return self.GetValue(WorkshopObjectTurnOnAtHour_AV)
    endfunction
    function set(float value)
        self.SetValue(WorkshopObjectTurnOnAtHour_AV, value)
    endfunction
endproperty
float property fTurnOffAtGameHour hidden
    float function get()
        return self.GetValue(WorkshopObjectTurnOffAtHour_AV)
    endfunction
    function set(float value)
        self.SetValue(WorkshopObjectTurnOffAtHour_AV, value)
    endfunction
endproperty

float function GetRemainingHours(float afTargetHour)
    float delta = afTargetHour - GameHour.GetValue()
    if (delta < 0)
        return delta + 24.0
    endif
    return delta
endfunction

function UpdateSwitchState()
    self.SetOpen(!(GameHour.GetValue() >= fTurnOnAtGameHour || GameHour.GetValue() < fTurnOffAtGameHour))
    UpdateSwitchAnimation()
endfunction
function UpdateSwitchAnimation()
    if (bUseAnimations)
        if (self.GetOpenState() == 3 && (bIsGenerator || self.IsPowered()))
            self.PlayAnimation(sTurnOnAnimation)
        else
            self.PlayAnimation(sTurnOffAnimation)
        endif
    endif
endfunction

float function CalculateAndQueueNextUpdate()
    if (self.GetOpenState() == 3) ; Active
        self.StartTimerGameTime(GetRemainingHours(fTurnOffAtGameHour))
    else ; Inactive
        self.StartTimerGameTime(GetRemainingHours(fTurnOnAtGameHour))
    endif
endfunction

event OnTimerGameTime(int aiTimerID)
    UpdateSwitchState()
    CalculateAndQueueNextUpdate()
endevent

event OnLoad()
    UpdateSwitchState()
    CalculateAndQueueNextUpdate()
endevent
event OnUnload()
    self.CancelTimerGameTime()
endevent

event OnPowerOn(ObjectReference akPowerGenerator)
    if (!bIsGenerator)
        UpdateSwitchState()
        CalculateAndQueueNextUpdate()
    endif
endevent
event OnPowerOff()
    if (!bIsGenerator)
        self.CancelTimerGameTime()
        UpdateSwitchAnimation()
    endif
endevent

event OnActivate(ObjectReference akActionRef)
    UpdateSwitchState()
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    UpdateSwitchState()
    CalculateAndQueueNextUpdate()
endevent
