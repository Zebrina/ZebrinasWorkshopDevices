scriptname Zebrina:Default:AliasActivateAlias extends ReferenceAlias const

ReferenceAlias property AliasToActivate auto const mandatory
bool property bDefaultProcessingOnly = false auto const
bool property bPlayerActivationOnly = true auto const

event OnActivate(ObjectReference akActionRef)
    if (!bPlayerActivationOnly || akActionRef == Game.GetPlayer())
        AliasToActivate.GetReference().Activate(akActionRef, bDefaultProcessingOnly)
    endif
endevent
