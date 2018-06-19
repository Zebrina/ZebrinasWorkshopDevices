scriptname Zebrina:Default:WorkbenchCraftAnimation extends ObjectReference default
{ Plays an animation every time the player crafts something, or randomly if used by an npc. }

string property sAnimation = "Play01" auto const
float property fMinInterval = 6.0 auto const
float property fMaxInterval = 10.0 auto const
FormList property ListOfCraftables = none auto const
{ List of craftables that should trigger animation. Can be None. }

function WorkbenchLeave(Actor akActor)
endfunction

Actor user = none

auto state ReadyForUse
    event OnActivate(ObjectReference akActionRef)
        if (akActionRef is Actor)
            user = akActionRef as Actor
            self.GoToState("InUse")
        endif
    endevent
endstate
state InUse
    event OnBeginState(string asOldState)
        if (user == Game.GetPlayer())
            self.AddInventoryEventFilter(ListOfCraftables)
            self.RegisterForRemoteEvent(user, "OnItemAdded")
        else
            self.StartTimer(Utility.RandomFloat(fMinInterval, fMaxInterval))
        endif
        Zebrina:WorkshopUtility.DEBUGTrace(self + ": " + user + " enter workbench")
    endevent
    event OnEndState(string asNewState)
        if (user == Game.GetPlayer())
            self.UnregisterForRemoteEvent(user, "OnItemAdded")
            self.RemoveAllInventoryEventFilters()
        else
            self.CancelTimer()
        endif
        Zebrina:WorkshopUtility.DEBUGTrace(self + ": " + user + " exit workbench")
        user = none
    endevent

    function WorkbenchLeave(Actor akActor)
        self.GoToState("ReadyForUse")
    endfunction
endstate

event Actor.OnGetUp(Actor akSender, ObjectReference akFurniture)
    self.UnregisterForRemoteEvent(akSender, "OnGetUp")
    WorkbenchLeave(akSender)
endevent

event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    self.PlayAnimation(sAnimation)
endevent

event OnTimer(int aiTimerID)
    self.PlayAnimation(sAnimation)
    self.StartTimer(Utility.RandomFloat(fMinInterval, fMaxInterval))
endevent
