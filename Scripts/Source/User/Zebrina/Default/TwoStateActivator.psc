scriptname Zebrina:Default:TwoStateActivator extends ObjectReference default

customevent DoorOpen
customevent DoorClose

group Animations
    string property sOpenEvent = "Open" auto const
    string property sOpenEndEvent = "Done" auto const
    string property sCloseEvent = "Close" auto const
    string property sCloseEndEvent = "Done" auto const
    string property sStartsOpenEvent = "Opened" auto const
endgroup
group Optional
    Message property DoorOpenActivateOverride = none auto const
    Message property DoorCloseActivateOverride = none auto const
    bool property bStartsOpen = false auto const
    bool property bBlockActivation = true auto const
endgroup

; ObjectReference override.
int function GetOpenState()
    return 0
endfunction

; ObjectReference override.
function SetOpen(bool abOpen = true)
endfunction
function SetOpenNoWait(bool abOpen = true)
    var[] args = new var[1]
    args[0] = abOpen
    self.CallFunctionNoWait("SetOpen", args)
endfunction

bool scriptBlockActivation = false
bool function IsActivationBlocked()
    return bBlockActivation || scriptBlockActivation
endfunction
function BlockActivation(bool abBlocked = true, bool abHideActivateText = false)
    parent.BlockActivation(bBlockActivation || abBlocked)
    scriptBlockActivation = abBlocked
endfunction

function SetActivateTextOverride(Message akText)
    parent.SetActivateTextOverride(akText)
    ; This forces a UI update.
    parent.BlockActivation(IsActivationBlocked())
endfunction

state Closing
    int function GetOpenState()
        return 4
    endfunction

    event OnBeginState(string asOldState)
        self.SendCustomEvent("DoorClose")
        self.SetActivateTextOverride(DoorOpenActivateOverride)
        self.PlayAnimationAndWait(sCloseEvent, sCloseEndEvent)
        self.GoToState("IsClosed")
    endevent
endstate
state IsClosed
    int function GetOpenState()
        return 3
    endfunction

    function SetOpen(bool abOpen = true)
        if (abOpen)
            self.GoToState("Opening")
        endif
    endfunction
endstate
state Opening
    int function GetOpenState()
        return 2
    endfunction

    event OnBeginState(string asOldState)
        self.SendCustomEvent("DoorOpen")
        self.SetActivateTextOverride(DoorCloseActivateOverride)
        self.PlayAnimationAndWait(sOpenEvent, sOpenEndEvent)
        self.GoToState("IsOpen")
    endevent
endstate
state IsOpen
    int function GetOpenState()
        return 1
    endfunction

    function SetOpen(bool abOpen = true)
        if (!abOpen)
            self.GoToState("Closing")
        endif
    endfunction
endstate

event OnActivate(ObjectReference akActionRef)
    if (!scriptBlockActivation)
        self.SetOpen(self.GetOpenState() != 1)
    endif
endevent

; Only one of these initialization events will run.
event OnInit()
    if (bStartsOpen)
        self.SetActivateTextOverride(DoorCloseActivateOverride)
        self.GoToState("IsOpen")
    else
        self.SetActivateTextOverride(DoorOpenActivateOverride)
        self.GoToState("IsClosed")
    endif
endevent
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    self.OnInit()
endevent
