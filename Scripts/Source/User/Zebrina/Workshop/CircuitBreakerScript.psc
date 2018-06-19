scriptname Zebrina:Workshop:CircuitBreakerScript extends ObjectReference

group AutoFill
    MovableStatic property Sparks01Large auto const mandatory
endgroup

ObjectReference sparksRef
bool bLidOpen = true

event OnLoad()
    self.RegisterForAnimationEvent(self, "TransitionComplete")
    ;Zebrina:WorkshopUtility.DEBUGTraceSelf(self, "OnLoad", "registered for animation event")
    ; In case we get stuck, do this every onload.
    if (self.GetState() == "WaitForTransitionComplete")
        self.BlockActivation(false, !bLidOpen)
        self.GoToState("WaitForActivation")
    endif
endevent

function SetLidOpen(bool abOpen)
    bLidOpen = abOpen
    self.BlockActivation(!bLidOpen, !bLidOpen)
endfunction

auto state WaitForActivation
    event OnActivate(ObjectReference akActionRef)
        self.GoToState("WaitForTransitionComplete")
        self.BlockActivation(true, !bLidOpen)
    endevent
endstate
state WaitForTransitionComplete
    event OnAnimationEvent(ObjectReference akSource, string asEventName)
        ;Zebrina:WorkshopUtility.DEBUGTraceSelf(self, "OnAnimationEvent", "received '" + asEventName + "'")
        self.BlockActivation(!bLidOpen, !bLidOpen)
        self.GoToState("WaitForActivation")
    endevent

    event OnActivate(ObjectReference akActionRef)
    endevent
endstate
state DestroyedClosedLid
    function SetLidOpen(bool abOpen)
        if (abOpen)
            bLidOpen = true
            self.BlockActivation(false, false)
            Utility.Wait(0.1)
            self.GoToState("Destroyed")
        endif
    endfunction
endstate
state Destroyed
    event OnBeginState(string asOldState)
        sparksRef.EnableNoWait()
        self.PlayAnimation("TurnOff")
    endevent
    event OnEndState(string asNewState)
        sparksRef.DisableNoWait()
    endevent

    function SetLidOpen(bool abOpen)
        bLidOpen = abOpen
        self.BlockActivation(!bLidOpen, !bLidOpen)
        if (bLidOpen)
            sparksRef.EnableNoWait()
        else
            Utility.Wait(0.3)
            sparksRef.DisableNoWait()
        endif
    endfunction

    event OnActivate(ObjectReference akActionRef)
        self.GoToState("WaitForTransitionComplete")
        self.BlockActivation(true, !bLidOpen)
    endevent

    event OnWorkshopObjectGrabbed(ObjectReference akReference)
        sparksRef.DisableNoWait()
    endevent
    event OnWorkshopObjectMoved(ObjectReference akReference)
        sparksRef.MoveToNode(self, "DestroyedEffectNode")
        if (bLidOpen)
            sparksRef.EnableNoWait()
        endif
    endevent
endstate

event OnDestructionStageChanged(int aiOldStage, int aiCurrentStage)
    if (aiCurrentStage == 1)
        self.ClearDestruction()
        if (bLidOpen)
            self.GoToState("Destroyed")
        else
            self.GoToState("DestroyedClosedLid")
        endif
    endif
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    sparksRef = self.PlaceAtNode("DestroyedEffectNode", Sparks01Large, abInitiallyDisabled = true)
    sparksRef.DisableNoWait()
    sparksRef.SetScale(0.4)
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
    sparksRef.Delete()
endevent
