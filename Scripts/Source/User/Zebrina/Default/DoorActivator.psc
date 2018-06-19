scriptname Zebrina:Default:DoorActivator extends ObjectReference default
{ Script to give activators the proper activate prompts when opened/closed. }

group Optional
    Message property DoorOpenActivateOverride = none auto const
    Message property DoorCloseActivateOverride = none auto const
    bool property bStartsOpen = false auto const
endgroup

state IsClosed
    event OnBeginState(string asOldState)
        self.SetActivateTextOverride(DoorOpenActivateOverride)
        ; This forces a UI update.
        self.BlockActivation(self.IsActivationBlocked())
    endevent

    event OnActivate(ObjectReference akActionRef)
        if (self.GetOpenState() == 2)
            self.GoToState("IsOpen")
        endif
    endevent
endstate
state IsOpen
    event OnBeginState(string asOldState)
        self.SetActivateTextOverride(DoorCloseActivateOverride)
        ; This forces a UI update.
        self.BlockActivation(self.IsActivationBlocked())
    endevent

    event OnActivate(ObjectReference akActionRef)
        if (self.GetOpenState() == 4)
            self.GoToState("IsClosed")
        endif
    endevent
endstate

; Only one of these initialization events will run.
event OnInit()
    if (bStartsOpen)
        self.GoToState("IsOpen")
    else
        self.GoToState("IsClosed")
    endif
endevent
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    self.OnInit()
endevent
