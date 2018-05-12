scriptname Zebrina:Default:ComplexTwoStateActivator extends Zebrina:Default:TwoStateActivator

import Zebrina:WorkshopUtility

group AutoFill
    Keyword property TwoStateCollisionKeyword = none auto const mandatory
endgroup
group Collision
    Static property CollisionObject = none auto const mandatory
    string property sCollisionNode = "NavCut" auto const
    bool property bReverseCollision = false auto const
endgroup

bool bInWorkshopMode = true

; Zebrina:Default:TwoStateActivator override.
function SetOpenState(int aiOpenState)
    parent.SetOpenState(aiOpenState)
    UpdateCollision()
endfunction

function UpdateCollision()
    ObjectReference collisionRef = self.GetLinkedRef(TwoStateCollisionKeyword)
    int openState = self.GetOpenState()
    if (!bInWorkshopMode && ((bReverseCollision && openState == 1) || (!bReverseCollision && openState == 3)))
        collisionRef.MoveToNode(self, sCollisionNode)
        collisionRef.EnableNoWait()
    else
        collisionRef.DisableNoWait()
    endif
endfunction

event ObjectReference.OnWorkshopMode(ObjectReference akSender, bool abStart)
    bInWorkshopMode = abStart
    UpdateCollision()
endevent

; Zebrina:Default:TwoStateActivator override.
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    self.SetLinkedRef(self.PlaceAtMe(CollisionObject, abInitiallyDisabled = true), TwoStateCollisionKeyword)
    self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopMode")
    parent.OnWorkshopObjectPlaced(akWorkshopRef)
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
    ObjectReference collisionRef = self.GetLinkedRef(TwoStateCollisionKeyword)
    collisionRef.DisableNoWait()
    collisionRef.Delete()
    self.SetLinkedRef(none, TwoStateCollisionKeyword)
    self.UnregisterForRemoteEvent(akWorkshopRef, "OnWorkshopMode")
endevent
