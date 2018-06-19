scriptname Zebrina:Default:TwoStateActivator extends ObjectReference default

group AnimationEvents
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
function SetOpen(bool abOpen = true)
endfunction
function SetOpenNoWait(bool abOpen = true)
    var[] args = new var[1]
    args[0] = abOpen
    self.CallFunctionNoWait("SetOpen", args)
endfunction

state Closing
    event OnBeginState(string asOldState)
        self.SetActivateTextOverride(DoorOpenActivateOverride)
        ; This forces a UI update.
        self.BlockActivation(bBlockActivation)
        self.PlayAnimationAndWait(sCloseEvent, sCloseEndEvent)
        self.GoToState("IsClosed")
    endevent
endstate
state IsClosed
    event OnActivate(ObjectReference akActionRef)
        self.GoToState("Opening")
    endevent

    function SetOpen(bool abOpen = true)
        if (abOpen)
            self.GoToState("Opening")
        endif
    endfunction
endstate
state Opening
    event OnBeginState(string asOldState)
        self.SetActivateTextOverride(DoorCloseActivateOverride)
        ; This forces a UI update.
        self.BlockActivation(bBlockActivation)
        self.PlayAnimationAndWait(sOpenEvent, sOpenEndEvent)
        self.GoToState("IsOpen")
    endevent
endstate
state IsOpen
    event OnActivate(ObjectReference akActionRef)
        self.GoToState("Closing")
    endevent

    function SetOpen(bool abOpen = true)
        if (!abOpen)
            self.GoToState("Closing")
        endif
    endfunction
endstate

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

; OLD SCRIPT
;/
scriptname Zebrina:Default:TwoStateActivator extends ObjectReference default const

import Zebrina:WorkshopUtility

group AutoFill
    ActorValue property WorkshopObjectOpenState_AV auto const mandatory
endgroup
group Animations
    string property sOpenAnim = "Open" auto const
    string property sCloseAnim = "Close" auto const
    string property sOpenEvent = "Opening" auto const
    { Used only if iAnimationMode is 0. }
    string property sCloseEvent = "Closing" auto const
    { Used only if iAnimationMode is 0. }
    int property iAnimationMode = 0 auto const
    { 0 => PlayAnimationAndWait
      1 => PlayAnimation
      2 => PlayGamebryoAnimation }
    float property fOpenAnimDelay = 0.0 auto const
    { Used only if iAnimationMode is 1 or 2. }
    float property fCloseAnimDelay = 0.0 auto const
    { Used only if iAnimationMode is 1 or 2. }
endgroup
group Sounds
    Sound property OpenSound = none auto const
    Sound property CloseSound = none auto const
endgroup
group MiscTwoStateActivator
    bool property bViolentlyClosed = false auto const
    bool property bStartOpen = false auto const
    string property sStartOpenAnim = "Opened" auto const
    bool property bScriptedActivationOnly = false auto const
    bool property bPlayerOrFavorActivationOnly = true auto const
endgroup

function PlayAnimationAndWaitInternal(string asAnimation, string asEventName, float afDelay = 0.0)
    if (iAnimationMode == 0)
        self.PlayAnimationAndWait(asAnimation, asEventName)
    else
        if (iAnimationMode == 1)
            self.PlayAnimation(asAnimation)
        else
            self.PlayGamebryoAnimation(asAnimation, true)
        endif
        if (afDelay > 0.0)
            Utility.Wait(afDelay)
        endif
    endif
endfunction

; ObjectReference override.
int function GetOpenState()
    return self.GetValue(WorkshopObjectOpenState_AV) as int
endfunction
bool function IsOpen()
    return self.GetOpenState() == 1
endfunction

function SetOpenState(int aiOpenState)
    self.SetValue(WorkshopObjectOpenState_AV, aiOpenState)
endfunction

function PlaySoundInternal(bool abOpen)
    if (abOpen && OpenSound != none)
        OpenSound.Play(self)
    elseif (!abOpen && CloseSound != none)
        CloseSound.Play(self)
    endif
endfunction

; ObjectReference override.
function SetOpen(bool abOpen = true)
    int openState = self.GetOpenState()
    if (abOpen && (openState == 3 || openState == 4))
        SetOpenState(2)

        PlaySoundInternal(true)

        self.PlayAnimationAndWaitInternal(sOpenAnim, sOpenEvent, fOpenAnimDelay)
        SetOpenState(1)
    elseif (!abOpen && (openState == 1 || openState == 2))
        SetOpenState(4)

        PlaySoundInternal(false)

        self.PlayAnimationAndWaitInternal(sCloseAnim, sCloseEvent, fCloseAnimDelay)
        SetOpenState(3)
    endif
endfunction
function SetOpenNoWait(bool abOpen = true)
    var[] args = new var[1]
    args[0] = abOpen
    self.CallFunctionNoWait("SetOpen", args)
endfunction

event OnActivate(ObjectReference akActionRef)
    if (!bScriptedActivationOnly && IsPlayerActionRef(akActionRef))
        int openState = self.GetOpenState()
        if (openState == 1)
            self.SetOpen(false)
        elseif (openState == 3)
            self.SetOpen(true)
        endif
    endif
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    if (bStartOpen)
        self.PlayAnimation(sStartOpenAnim)
        self.SetValue(WorkshopObjectOpenState_AV, 1.0)
    endif
endevent
/;
