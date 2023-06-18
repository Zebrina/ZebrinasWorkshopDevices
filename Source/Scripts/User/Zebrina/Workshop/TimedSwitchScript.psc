scriptname Zebrina:Workshop:TimedSwitchScript extends ObjectReference

customevent LedDisplayUpdate

group AutoFill
    GlobalVariable property GameHour auto const mandatory
    Activator property WorkshopTimedSwitchLedDisplay01 auto const mandatory
endgroup

bool property bSwitchTurnedOn = true auto hidden

function SendLedDisplayUpdateEvent(bool abLedDisplayOn)
    var[] args
    if (abLedDisplayOn)
        args = new var[5]
        args[1] = (fTurnOffAtGameHour_ as int) % 10
        args[2] = (fTurnOffAtGameHour_ as int) / 10
        args[3] = (fTurnOnAtGameHour_ as int) % 10
        args[4] = (fTurnOnAtGameHour_ as int) / 10
    else
        args = new var[1]
    endif
    args[0] = abLedDisplayOn
    self.SendCustomEvent("LedDisplayUpdate", args)
endfunction

float fTurnOnAtGameHour_ = 19.0
float property fTurnOnAtGameHour hidden
    float function get()
        return fTurnOnAtGameHour_
    endfunction
    function set(float afValue)
        fTurnOnAtGameHour_ = afValue
        Update()
    endfunction
endproperty
float fTurnOffAtGameHour_ = 7.0
float property fTurnOffAtGameHour hidden
    float function get()
        return fTurnOffAtGameHour_
    endfunction
    function set(float afValue)
        fTurnOffAtGameHour_ = afValue
        Update()
    endfunction
endproperty

bool function ShouldBeActive()
    float fGameHour = GameHour.GetValue()
    if (fTurnOnAtGameHour < fTurnOffAtGameHour)
        return fGameHour >= fTurnOnAtGameHour && fGameHour < fTurnOffAtGameHour
    endif
    return fGameHour < fTurnOffAtGameHour || fGameHour >= fTurnOnAtGameHour
endfunction

bool bUpdateInProgress = false
float function Update()
    if (!bUpdateInProgress)
        bUpdateInProgress = true

        ; Wait for menus to close.
        Utility.Wait(0.001)

        SendLedDisplayUpdateEvent(bSwitchTurnedOn)
        if (bSwitchTurnedOn)
            bool bShouldBeActive = ShouldBeActive()
            if (bShouldBeActive)
                self.PlayAnimationAndWait("TurnOn01", "End")
            else
                self.PlayAnimationAndWait("TurnOff01", "End")
            endif
            self.SetOpen(!bShouldBeActive)

            float nextUpdate = Math.Floor(Utility.GetCurrentGameTime()) * 24.0
            if (bShouldBeActive)
                nextUpdate += fTurnOffAtGameHour
            else
                nextUpdate += fTurnOnAtGameHour
            endif
            self.StartTimerGameTime(nextUpdate - (Utility.GetCurrentGameTime() * 24.0))
        else
            self.PlayAnimationAndWait("TurnOff01", "End")
            self.SetOpen(true)
        endif

        bUpdateInProgress = false
    endif
endfunction

event OnTimerGameTime(int aiTimerID)
    Update()
endevent

bool bActivated = false
event OnActivate(ObjectReference akActionRef)
    if (!bActivated)
        bActivated = true

        self.PlayAnimationAndWait("Press", "End")
        bSwitchTurnedOn = !bSwitchTurnedOn

        Update()

        bActivated = false
    endif
endevent

;/
event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    TimedSwitchValueControllerScript valueControlRef = akSender as TimedSwitchValueControllerScript
    if (valueControlRef.LedDisplayEnabled)
        if (valueControlRef == turnOnValueControllerRef)
            float value = fTurnOnAtGameHour_ + 1.0
            if (value == fTurnOffAtGameHour_)
                value += 1.0
            endif
            if (value >= 24.0)
                value -= 24.0
            endif
            fTurnOnAtGameHour = value
        else
            float value = fTurnOffAtGameHour_ + 1.0
            if (value == fTurnOnAtGameHour_)
                value += 1.0
            endif
            if (value >= 24.0)
                value -= 24.0
            endif
            fTurnOffAtGameHour = value
        endif
    endif
endevent
/;

event OnCellAttach()
    self.WaitFor3DLoad()
    Update()
endevent
event OnCellDetach()
    self.CancelTimerGameTime()
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    self.BlockActivation()

    int id = 1
    int node = 1
    while (id <= 4)
        if (id == 3)
            node += 1
        endif

        TimedSwitchLedDisplayScript ledDisplay = self.PlaceAtMe(WorkshopTimedSwitchLedDisplay01, abInitiallyDisabled = true) as TimedSwitchLedDisplayScript
        ledDisplay.Initialize(self, id, "Digit0" + node)

        id += 1
        node += 1
    endwhile

    Update()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
    self.CancelTimerGameTime()
    self.UnregisterForAllEvents()
endevent
