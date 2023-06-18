scriptname Zebrina:Default:BlockActivationDuringTransition extends ObjectReference default
{ Prevents jittery animations for some activated objects. }

string property sTransitionCompleteEvent = "TransitionComplete" auto const

event OnLoad()
    self.RegisterForAnimationEvent(self, sTransitionCompleteEvent)
    ;Zebrina:WorkshopUtility.DEBUGTraceSelf(self, "OnLoad", "registered for animation event")
    ; In case we get stuck, do this every onload.
    if (self.GetState() == "WaitForTransitionComplete")
        self.BlockActivation(false)
        self.GoToState("WaitForActivation")
    endif
endevent

state WaitForActivation
    event OnActivate(ObjectReference akActionRef)
        self.GoToState("WaitForTransitionComplete")
        self.BlockActivation()
    endevent
endstate
state WaitForTransitionComplete
    event OnAnimationEvent(ObjectReference akSource, string asEventName)
        ;Zebrina:WorkshopUtility.DEBUGTraceSelf(self, "OnAnimationEvent", "received '" + asEventName + "'")
        self.BlockActivation(false)
        self.GoToState("WaitForActivation")
    endevent
endstate
