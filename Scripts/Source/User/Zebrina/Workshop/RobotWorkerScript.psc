scriptname Zebrina:Workshop:RobotWorkerScript extends ObjectReference const

group AutoFill
    Keyword property WorkshopLinkRobotWorker auto const mandatory
endgroup
group RobotWorker
    int property iDestructionStage = 1 auto const
    Form property RobotBaseObject auto const mandatory
    int property iRobotDestructionStage = 1 auto const
    string property sRefAttachNode = "REF_ATTACH_NODE" auto const
    bool property bRequiresPower = true auto const
    string property sRobotPowerOnEvent = "StartAnim" auto const
    string property sRobotPowerOffEvent = "StopAnim" auto const
endgroup

ObjectReference property RobotRef
    ObjectReference function get()
        ObjectReference kRobotRef = self.GetLinkedRef(WorkshopLinkRobotWorker)
        if (!kRobotRef)
            self.WaitFor3DLoad()
            kRobotRef = self.PlaceAtNode(sRefAttachNode, RobotBaseObject)
            if (self.IsDestroyed())
                DestroyObject(kRobotRef)
            endif
            self.SetLinkedRef(kRobotRef, WorkshopLinkRobotWorker)
        endif
        return kRobotRef
    endfunction
endproperty

function DestroyObject(ObjectReference akReference)
    akReference.DamageObject(10000.0)
endfunction

event OnDestructionStageChanged(int aiOldStage, int aiCurrentStage)
    ;Debug.MessageBox("OnDestructionStageChanged(" + aiOldStage + ", " + aiCurrentStage + ")")
    if (self.IsDestroyed())
        DestroyObject(RobotRef)
    endif
endevent
event ObjectReference.OnDestructionStageChanged(ObjectReference akSender, int aiOldStage, int aiCurrentStage)
    ;Debug.MessageBox("ObjectReference.OnDestructionStageChanged(" + aiOldStage + ", " + aiCurrentStage + ")")
    if (akSender.IsDestroyed())
        DestroyObject(self)
    endif
endevent

function HandlePowerState()
    if (bRequiresPower && !self.IsDestroyed())
        ObjectReference kRobotRef = RobotRef
        kRobotRef.WaitFor3DLoad()
        if (self.IsPowered())
            kRobotRef.PlayAnimation(sRobotPowerOnEvent)
        else
            kRobotRef.PlayAnimation(sRobotPowerOffEvent)
        endif
    endif
endfunction

event OnWorkshopObjectRepaired(ObjectReference akWorkshopRef)
    ObjectReference kRobotRef = RobotRef
    kRobotRef.RestoreValue(Game.GetHealthAV(), 10000.0)
    kRobotRef.ClearDestruction()
    kRobotRef.MoveToNode(self, sRefAttachNode)
    HandlePowerState()
endevent

event OnPowerOn(ObjectReference akPowerGenerator)
    HandlePowerState()
endevent
event OnPowerOff()
    HandlePowerState()
endevent

event OnLoad()
    self.RegisterForRemoteEvent(RobotRef, "OnDestructionStageChanged")
    HandlePowerState()
endevent
event OnUnload()
    self.UnregisterForRemoteEvent(RobotRef, "OnDestructionStageChanged")
endevent

event OnWorkshopObjectGrabbed(ObjectReference akReference)
    RobotRef.DisableNoWait()
endevent
event OnWorkshopObjectMoved(ObjectReference akReference)
    ObjectReference kRobotRef = RobotRef
    kRobotRef.MoveToNode(self, sRefAttachNode)
    kRobotRef.EnableNoWait()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
    ObjectReference kRobotRef = self.GetLinkedRef(WorkshopLinkRobotWorker)
    if (kRobotRef)
        self.UnregisterForRemoteEvent(kRobotRef, "OnDestructionStageChanged")
        kRobotRef.DisableNoWait()
        kRobotRef.Delete()
        self.SetLinkedRef(none, WorkshopLinkRobotWorker)
    endif
endevent
