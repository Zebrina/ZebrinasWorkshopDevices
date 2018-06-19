scriptname Zebrina:Workshop:OverdueBookVendorScript extends DN011OverdueBookVendingMachineSCRIPT conditional

group AutoFill
    Zebrina:Workshop:OverdueBookVendorMasterScript property WorkshopOverdueBookVendorMaster auto const mandatory
endgroup
group QuestAliases
    ReferenceAlias property DN011OverdueBooks_BookReturnTerminal01 auto const mandatory
endgroup

float property fLastInventoryReset = -1.0 auto hidden

auto state RunOnLoad
    ; DN011OverdueBookVendingMachineSCRIPT override.
    event OnLoad()
        self.BlockActivation(true)
        self.GoToState("WaitForActivation")
    endevent
endstate

; DN011OverdueBookVendingMachineSCRIPT override.
event OnActivate(ObjectReference akActionRef)
endevent

state WaitForActivation
    event OnActivate(ObjectReference akActionRef)
        self.GoToState("Busy")
        if (akActionRef == Game.GetPlayer())
            ;self.PlayGamebryoAnimation("Open", true)
            DN011OverdueBooks_BookReturnTerminal01.ForceRefTo(self)
            self.UpdateTotalItemCountAndAliases()
            WorkshopOverdueBookVendorMaster.ReduceHackAttempts()
            self.Activate(akActionRef, true)
            ;self.PlayGamebryoAnimation("Close", true)
            ;Utility.Wait(0.4)
        endif
        self.GoToState("WaitForActivation")
    endevent
endstate
state Busy
endstate

; DN011OverdueBookVendingMachineSCRIPT override.
function UpdateTotalItemCountAndAliases()
    WorkshopOverdueBookVendorMaster.AccessTerminal(self)
    parent.UpdateTotalItemCountAndAliases()
endfunction
