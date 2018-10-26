scriptname Zebrina:Workshop:TripwireScript extends ObjectReference const

group Animations
    string property sTriggerAnim = "Trip" auto const
    string property sResetAnim = "Reset" auto const
endgroup
group Sounds
    Sound property TriggerSound auto const
    Sound property DisarmSound auto const
endgroup
group Other
    bool property bStartArmed = true auto const
    bool property bPoweredWhenArmed = false auto const
    bool property bEnemiesOnly = true auto const
endgroup

bool property bArmed hidden
    bool function get()
        return (self.GetOpenState() == 3) == bPoweredWhenArmed
    endfunction
    function set(bool abFlag)
        if (abFlag)
            self.PlayAnimation(sResetAnim)
        else
            self.PlayAnimation(sTriggerAnim)
        endif
        self.SetOpen(abFlag != bPoweredWhenArmed)
    endfunction
endproperty

bool function ShouldTrigger(ObjectReference akTriggerRef)
    return DEBUGTriggeredByPlayer(akTriggerRef) || (akTriggerRef is Actor && (!bEnemiesOnly || (akTriggerRef as Actor).IsHostileToActor(Game.GetPlayer())))
endFunction

event OnTriggerEnter(ObjectReference akActionRef)
    if (ShouldTrigger(akActionRef) && bArmed)
        bArmed = false
        if (TriggerSound)
            TriggerSound.Play(self)
        endif
    endif
endevent
event OnActivate(ObjectReference akActionRef)
    if (bArmed)
        bArmed = false
        if (DisarmSound)
            DisarmSound.Play(self)
        endif
    else
        bArmed = true
    endif
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    self.BlockActivation()
    bArmed = bStartArmed
endevent

bool function DEBUGTriggeredByPlayer(ObjectReference akTriggerRef) debugonly
    return akTriggerRef == Game.GetPlayer()
endfunction
