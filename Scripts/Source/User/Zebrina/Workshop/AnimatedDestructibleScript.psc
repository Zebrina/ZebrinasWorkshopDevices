scriptname Zebrina:Workshop:AnimatedDestructibleScript extends ObjectReference const
{ Add to workshop objects that use animations to display destroyed state. }

group AnimatedDestructibleScript
    string property sDestroyEvent = "Destroy" auto const
    string property sResetEvent = "Reset" auto const
endgroup

event OnDestructionStageChanged(int aiOldStage, int aiCurrentStage)
    if (self.IsDestroyed())
        self.PlayAnimation(sDestroyEvent)
    endif
endevent
event OnWorkshopObjectRepaired(ObjectReference akReference)
    self.PlayAnimation(sResetEvent)
endevent
