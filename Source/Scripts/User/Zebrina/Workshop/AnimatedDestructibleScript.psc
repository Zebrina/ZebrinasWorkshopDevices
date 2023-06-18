scriptname Zebrina:Workshop:AnimatedDestructibleScript extends ObjectReference const
{ Add to workshop objects that use animations to display destroyed state. }

bool property bUseEvents = true auto const
string property sDestroyEvent = "Destroy" auto const
string property sResetEvent = "Reset" auto const
Form property DestroyedEffectObject = none auto const
string property sDestroyedEffectNode = "DestroyedEffectNode" auto const
float property fDestroyedEffectScale = 1.0 auto const

event OnDestructionStageChanged(int aiOldStage, int aiCurrentStage)
    if (self.IsDestroyed())
        if (bUseEvents)
            self.PlayAnimation(sDestroyEvent)
        endif
        if (DestroyedEffectObject)
            self.GetLinkedRef().EnableNoWait()
        endif
    endif
endevent

event OnWorkshopObjectRepaired(ObjectReference akReference)
    if (bUseEvents)
        self.PlayAnimation(sResetEvent)
    endif
    if (DestroyedEffectObject)
        self.GetLinkedRef().DisableNoWait()
    endif
endevent

event OnWorkshopObjectGrabbed(ObjectReference akReference)
    if (DestroyedEffectObject)
        self.GetLinkedRef().DisableNoWait()
    endif
endevent
event OnWorkshopObjectMoved(ObjectReference akReference)
    if (DestroyedEffectObject && self.IsDestroyed())
        ObjectReference destroyedEffectRef = self.GetLinkedRef()
        destroyedEffectRef.MoveToNode(self, sDestroyedEffectNode)
        destroyedEffectRef.EnableNoWait()
    endif
endevent

event OnWorkshopObjectPlaced(ObjectReference akReference)
    if (DestroyedEffectObject)
        ObjectReference destroyedEffectRef = self.PlaceAtNode(sDestroyedEffectNode, DestroyedEffectObject, abInitiallyDisabled = true)
        destroyedEffectRef.DisableNoWait()
        destroyedEffectRef.SetScale(fDestroyedEffectScale)
        self.SetLinkedRef(destroyedEffectRef)
    endif
endevent
event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
    if (DestroyedEffectObject)
        self.GetLinkedRef().Delete()
    endif
endevent
