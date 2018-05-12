scriptname Zebrina:Workshop:RemoteTwoStateActivator extends Zebrina:Default:TwoStateActivator const

import Zebrina:WorkshopUtility

group RemoteActivator
    Activator property RemoteActivatorBase auto const mandatory
    Keyword property LinkKeyword = none auto const
    string property sRefAttachNode = "REF_ATTACH_NODE" auto const
    bool property bAttachToNode = true auto const
endgroup

function ResetRemoteActivatorPosition()
    ObjectReference myRemoteActivator = self.GetLinkedRef(LinkKeyword)
    ;myRemoteActivator.SetAngle(self.GetAngleX(), self.GetAngleY(), self.GetAngleZ())
    myRemoteActivator.MoveToNode(self, sRefAttachNode)
endfunction

event OnLoad()
    if (!bAttachToNode && self.GetLinkedRef(LinkKeyword) != none)
        ResetRemoteActivatorPosition()
    endif

    parent.OnLoad()
endevent

; Default:TwoStateActivator override.
event OnActivate(ObjectReference akActionRef)
    ; Do nothing.
endevent

event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if (IsPlayerActionRef(akActionRef))
        int openState = self.GetOpenState()
        if (openState == 1)
            self.SetOpen(false)
        elseif (openState == 3)
            self.SetOpen(true)
        endif
    endif
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    parent.OnWorkshopObjectPlaced(akWorkshopRef)
    ObjectReference myRemoteActivator = self.PlaceAtNode(sRefAttachNode, RemoteActivatorBase, abAttach = bAttachToNode)
    self.SetLinkedRef(myRemoteActivator, LinkKeyword)
    self.RegisterForRemoteEvent(myRemoteActivator, "OnActivate")
endevent
event OnWorkshopObjectGrabbed(ObjectReference akWorkshopRef)
    if (!bAttachToNode)
        self.GetLinkedRef(LinkKeyword).DisableNoWait()
    endif
endevent
event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
    if (!bAttachToNode)
        ResetRemoteActivatorPosition()
        self.GetLinkedRef(LinkKeyword).EnableNoWait()
    endif
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
    ObjectReference myRemoteActivator = self.GetLinkedRef(LinkKeyword)
    myRemoteActivator.DisableNoWait()
    myRemoteActivator.Delete()
    self.SetLinkedRef(none, LinkKeyword)
endevent
