scriptname Zebrina:Workshop:NukeLaunchScript extends ObjectReference

group AutoFill
    Sound property OBJKeyCardActivateFail auto const mandatory
    MiscObject property WorkshopNukeLaunchKey auto const mandatory
endgroup

auto state Inactive
    event OnActivate(ObjectReference akActionRef)
        self.GoToState("Busy")
        if (akActionRef.GetItemCount(WorkshopNukeLaunchKey) > 0)
            akActionRef.RemoveItem(WorkshopNukeLaunchKey)
            self.PlayAnimationAndWait("Stage2", "Stage3")
            self.GoToState("Active")
        else
            OBJKeyCardActivateFail.PlayAndWait(self)
            self.GoToState("Inactive")
        endif
    endevent
endstate
state Active
    event OnBeginState(string asOldState)
        self.SetOpen(false)
    endevent
    event OnEndState(string asNewState)
        self.SetOpen(true)
    endevent

    event OnActivate(ObjectReference akActionRef)
        self.GoToState("Busy")
        self.PlayAnimationAndWait("Stage4", "Reset")
        akActionRef.AddItem(WorkshopNukeLaunchKey)
        self.GoToState("Inactive")
    endevent

    event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
        Game.GetPlayer().AddItem(WorkshopNukeLaunchKey)
    endevent
endstate
state Busy
endstate

event OnLoad()
    self.BlockActivation()
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    self.SetOpen(true)
endevent
