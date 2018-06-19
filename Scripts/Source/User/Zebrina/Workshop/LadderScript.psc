scriptname Zebrina:Workshop:LadderScript extends ObjectReference const

group AutoFill
    Keyword property WorkshopStackedItemParentKeyword auto const mandatory
    Keyword property WorkshopLadderKeyword auto const mandatory
    { Keyword to identify stacked ladder. }
    Keyword property WorkshopLinkLadderUp auto const mandatory
    { Keyword to link the ladder that takes me up. }
    Keyword property WorkshopLinkLadderDown auto const mandatory
    { Keyword to link the ladder that takes me down. }
    Message property WorkshopLadderTopActivateOverride auto const mandatory
    { Activation prompt for the bottom ladder. }
endgroup

function ClimbLadder(Actor akActor, Keyword akLinkKeyword, string asDestinationNode)
    ObjectReference ladderRef = self.GetLinkedRef(akLinkKeyword)
    if (ladderRef)
        (ladderRef as LadderScript).ClimbLadder(akActor, akLinkKeyword, asDestinationNode)
    else
        akActor.MoveToNode(self, asDestinationNode)
    endif
endfunction

event OnActivate(ObjectReference akActionRef)
    if (!self.IsActivationBlocked() && Zebrina:WorkshopUtility.IsPlayerActionRef(akActionRef))
        if (!self.GetLinkedRef(WorkshopLinkLadderUp))
            ; I'm the top ladder.
            ClimbLadder(akActionRef as Actor, WorkshopLinkLadderDown, "LadderBottomNode")
        else
            ClimbLadder(akActionRef as Actor, WorkshopLinkLadderUp, "LadderTopNode")
        endif
    endif
endevent

function UpdateStackedLadder(Keyword akLinkKeyword)
    ObjectReference ladderRef = self.GetLinkedRef(akLinkKeyword)
    if (ladderRef)
        self.BlockActivation(true, true)
        (ladderRef as LadderScript).UpdateStackedLadder(akLinkKeyword)
    elseif (akLinkKeyword == WorkshopLinkLadderUp)
        ; No ladder up, which means I'm the top ladder.
        self.SetActivateTextOverride(WorkshopLadderTopActivateOverride)
        self.BlockActivation(false, false)
    else
        ; No ladder down, which means I'm the bottom ladder.
        self.SetActivateTextOverride(none)
        self.BlockActivation(false, false)
    endif
endfunction

function StackLadder()
    ObjectReference parentRef = self.GetLinkedRef(WorkshopStackedItemParentKeyword)
    if (parentRef && parentRef.HasKeyword(WorkshopLadderKeyword))
        if (parentRef.z > self.z)
            ; My stacked ladder parent is above.
            self.SetLinkedRef(parentRef, WorkshopLinkLadderUp)
            ; Update self downwards.
            self.UpdateStackedLadder(WorkshopLinkLadderDown)

            parentRef.SetLinkedRef(self, WorkshopLinkLadderDown)
            ; Update parent upwards.
            (parentRef as LadderScript).UpdateStackedLadder(WorkshopLinkLadderUp)
        else
            ; My stacked parent ladder is below.
            self.SetLinkedRef(parentRef, WorkshopLinkLadderDown)
            ; Update self upwards.
            self.UpdateStackedLadder(WorkshopLinkLadderUp)

            parentRef.SetLinkedRef(self, WorkshopLinkLadderUp)
            ; Update parent downwards.
            (parentRef as LadderScript).UpdateStackedLadder(WorkshopLinkLadderDown)
        endif
    else
        ; I demand stacking!
        self.SetLinkedRef(none, WorkshopLinkLadderUp)
        self.SetLinkedRef(none, WorkshopLinkLadderDown)
    endif
    ; Clear stacked.
    self.SetLinkedRef(none, WorkshopStackedItemParentKeyword)
endfunction

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    StackLadder()
endevent
event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
    StackLadder()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
    LadderScript ladderRef = self.GetLinkedRef(WorkshopLinkLadderUp) as LadderScript
    if (ladderRef)
        self.SetLinkedRef(none, WorkshopLinkLadderUp)
        ladderRef.SetLinkedRef(none, WorkshopLinkLadderDown)
        ladderRef.UpdateStackedLadder(WorkshopLinkLadderDown)
    endif
    ladderRef = self.GetLinkedRef(WorkshopLinkLadderDown) as LadderScript
    if (ladderRef)
        self.SetLinkedRef(none, WorkshopLinkLadderDown)
        ladderRef.SetLinkedRef(none, WorkshopLinkLadderUp)
        ladderRef.UpdateStackedLadder(WorkshopLinkLadderUp)
    endif
endevent
