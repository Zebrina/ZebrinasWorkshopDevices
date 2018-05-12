scriptname Zebrina:Workshop:LidScript extends ObjectReference const
{ Can be used on it's own or as a base script. }

group Lid
    Door property LidObject auto const mandatory
    Keyword property LinkKeyword = none auto const
    bool property bAttachToNode = true auto const
    string property sAttachNode = "REF_ATTACH_NODE" auto const
    bool property bBlockActivation = true auto const
    bool property bHideActivationText = true auto const
endgroup

bool function IsLidOpen()
    return self.GetLinkedRef(LinkKeyword).GetOpenState() <= 2
endfunction

function InitializeLid(ObjectReference akLidRef)
    ; Can be overriden.
endfunction

function HandleLidState(ObjectReference akLidRef, bool abOpen, bool abWasActivated)
    if (bBlockActivation)
        self.BlockActivation(!abOpen, bHideActivationText && !abOpen)
    endif
endfunction

event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    HandleLidState(akSender, akSender.GetOpenState() <= 2, true)
endevent
event ObjectReference.OnOpen(ObjectReference akSender, ObjectReference akActionRef)
    HandleLidState(akSender, true, false)
endevent
event ObjectReference.OnClose(ObjectReference akSender, ObjectReference akActionRef)
    HandleLidState(akSender, false, false)
endevent

event OnActivate(ObjectReference akActionRef)
    if (!bHideActivationText && !IsLidOpen())
        self.GetLinkedRef(LinkKeyword).Activate(akActionRef)
    endif
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    ObjectReference lidRef = self.PlaceAtNode(sAttachNode, LidObject, abAttach = bAttachToNode)
    self.SetLinkedRef(lidRef, LinkKeyword)
    self.RegisterForRemoteEvent(lidRef, "OnActivate")
    self.RegisterForRemoteEvent(lidRef, "OnOpen")
    self.RegisterForRemoteEvent(lidRef, "OnClose")
    HandleLidState(lidRef, false, false)
    InitializeLid(lidRef)
endevent
event OnWorkshopObjectGrabbed(ObjectReference akReference)
    if (!bAttachToNode)
        self.GetLinkedRef(LinkKeyword).DisableNoWait()
    endif
endevent
event OnWorkshopObjectMoved(ObjectReference akReference)
    if (!bAttachToNode)
        ObjectReference lidRef = self.GetLinkedRef(LinkKeyword)
        lidRef.MoveToNode(self, sAttachNode)
        lidRef.EnableNoWait()
    endif
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
    self.UnregisterForAllRemoteEvents()
    ObjectReference lidRef = self.GetLinkedRef(LinkKeyword)
    lidRef.DisableNoWait()
    lidRef.Delete()
    self.SetLinkedRef(none, LinkKeyword)
endevent
