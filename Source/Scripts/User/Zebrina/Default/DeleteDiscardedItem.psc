scriptname Zebrina:Default:DeleteDiscardedItem extends ObjectReference const default

event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    if (!akNewContainer)
        ;self.Disable()
        self.Delete()
    endif
endevent
