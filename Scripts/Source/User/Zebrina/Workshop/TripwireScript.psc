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

bool function IsArmed()
    if (bPoweredWhenArmed)
        return self.GetOpenState() == 3
    endif
    return self.GetOpenState() == 1
endfunction
function SetArmed(bool abShouldBeArmed = true)
    if (abShouldBeArmed != IsArmed())
        if (abShouldBeArmed)
            self.PlayAnimation(sResetAnim)
        else
            self.PlayAnimation(sTriggerAnim)
        endif
    endif
    self.SetOpen(abShouldBeArmed != bPoweredWhenArmed)
endfunction

bool function ShouldTrigger(ObjectReference akTriggerRef)
    return akTriggerRef is Actor && (!bEnemiesOnly || (akTriggerRef as Actor).IsHostileToActor(Game.GetPlayer()))
endFunction

event OnTriggerEnter(ObjectReference akActionRef)
    if (ShouldTrigger(akActionRef) && IsArmed())
        SetArmed(false)
        if (TriggerSound)
            TriggerSound.Play(self)
        endif
    endif
endevent
event OnActivate(ObjectReference akActionRef)
    if (IsArmed())
        SetArmed(false)
        if (DisarmSound)
            DisarmSound.Play(self)
        endif
    else
        SetArmed(true)
    endif
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    self.BlockActivation()
    SetArmed(bStartArmed)
endevent
