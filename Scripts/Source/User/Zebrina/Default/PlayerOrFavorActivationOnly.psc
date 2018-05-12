scriptname Zebrina:Default:PlayerOrFavorActivationOnly extends ObjectReference const

event OnLoad()
    self.BlockActivation()
endevent

event OnActivate(ObjectReference akActionRef)
    if (Zebrina:WorkshopUtility.IsPlayerActionRef(akActionRef))
        self.Activate(akActionRef, true)
    endif
endevent
