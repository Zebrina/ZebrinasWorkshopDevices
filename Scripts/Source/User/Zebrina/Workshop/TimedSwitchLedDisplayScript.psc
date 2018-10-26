scriptname Zebrina:Workshop:TimedSwitchLedDisplayScript extends ObjectReference

Zebrina:Workshop:TimedSwitchScript parentRef
int id
string node

function SetDisplayValue(int aiValue)
    self.PlayAnimation("Force" + aiValue)
endfunction

event Zebrina:Workshop:TimedSwitchScript.LedDisplayUpdate(Zebrina:Workshop:TimedSwitchScript akSender, var[] akArgs)
    if (akArgs[0] as bool)
        self.Enable()
        SetDisplayValue(akArgs[id] as int)
    else
        self.DisableNoWait()
    endif
endevent

function Initialize(Zebrina:Workshop:TimedSwitchScript akParent, int aiID, string asNode)
    self.SetScale(0.05)
    self.MoveToNode(akParent, asNode)

    self.RegisterForRemoteEvent(akParent, "OnWorkshopObjectGrabbed")
    self.RegisterForRemoteEvent(akParent, "OnWorkshopObjectMoved")
    self.RegisterForRemoteEvent(akParent, "OnWorkshopObjectDestroyed")
    self.RegisterForCustomEvent(akParent, "LedDisplayUpdate")

    parentRef = akParent
    id = aiID
    node = asNode
endfunction

event ObjectReference.OnWorkshopObjectGrabbed(ObjectReference akSender, ObjectReference akWorkshopRef)
    self.DisableNoWait()
endevent
event ObjectReference.OnWorkshopObjectMoved(ObjectReference akSender, ObjectReference akWorkshopRef)
    self.MoveToNode(parentRef, node)
    if (parentRef.bSwitchTurnedOn)
        self.EnableNoWait()
    endif
endevent
event ObjectReference.OnWorkshopObjectDestroyed(ObjectReference akSender, ObjectReference akWorkshopRef)
    parentRef = none
    self.UnregisterForAllRemoteEvents()
    self.Delete()
endevent
