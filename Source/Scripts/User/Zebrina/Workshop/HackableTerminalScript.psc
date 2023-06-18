scriptname Zebrina:Workshop:HackableTerminalScript extends ObjectReference

Perk property WorkshopDifficultHackingPerk auto const mandatory

Actor hacker

function HackTerminal(Actor akHacker)
endfunction

auto state WaitForHacking
    function HackTerminal(Actor akHacker)
        hacker = akHacker
        self.Activate(akHacker)
        self.GoToState("HackingInProgress")
    endfunction
endstate
state HackingInProgress
    event OnBeginState(string asOldState)
        hacker.AddPerk(WorkshopDifficultHackingPerk)
        self.SetLockLevel(100)
        self.Lock()
    endevent
    event OnEndState(string asNewState)
        self.Unlock()
        self.SetLockLevel(0)
        hacker.RemovePerk(WorkshopDifficultHackingPerk)
    endevent

    event OnActivate(ObjectReference akActionRef)
        self.GoToState("WaitForHacking")
    endevent
endstate
