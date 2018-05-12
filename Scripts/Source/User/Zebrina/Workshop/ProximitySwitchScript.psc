scriptname Zebrina:Workshop:ProximitySwitchScript extends ObjectReference const

group AutoFill
    Keyword property LinkCustom01 auto const mandatory
endgroup
group ProximitySwitch
    Activator property TriggerObject auto const mandatory
    float property fTriggerObjectSize auto const mandatory
    string property sTriggerObjectNode = "REF_ATTACH_NODE" auto const
    bool property bIsGenerator = false auto const
endgroup
group Animations
    bool property bUseAnimations = false auto const
    string property sTurnOnAnimation = "TurnOn01" auto const
    string property sTurnOffAnimation = "TurnOff01" auto const
endgroup

float property TriggerRadius hidden
    float function get()
        return self.GetLinkedRef(LinkCustom01).GetScale() * fTriggerObjectSize
    endfunction
    function set(float afSize)
        ObjectReference triggerRef = self.GetLinkedRef(LinkCustom01)
        triggerRef.Disable()
        triggerRef.SetScale(afSize / fTriggerObjectSize)
        triggerRef.EnableNoWait()
    endfunction
endproperty

function UpdateSwitchState()
    self.SetOpen(self.GetLinkedRef(LinkCustom01).GetTriggerObjectCount() == 0)
    UpdateSwitchAnimation()
endfunction
function UpdateSwitchAnimation()
    if (bUseAnimations)
        if (self.GetOpenState() == 3 && self.IsPowered())
            self.PlayAnimation(sTurnOnAnimation)
        else
            self.PlayAnimation(sTurnOffAnimation)
        endif
    endif
endfunction

event ObjectReference.OnTriggerEnter(ObjectReference akSender, ObjectReference akActionRef)
    Debug.Notification("OnTriggerEnter(" + akSender.GetTriggerObjectCount() + "): " + akActionRef.GetBaseObject().GetName())
    UpdateSwitchState()
endevent
event ObjectReference.OnTriggerLeave(ObjectReference akSender, ObjectReference akActionRef)
    Debug.Notification("OnTriggerLeave(" + akSender.GetTriggerObjectCount() + "): " + akActionRef.GetBaseObject().GetName())
    UpdateSwitchState()
endevent

event OnLoad()
    UpdateSwitchState()
endevent

event OnPowerOn(ObjectReference akPowerGenerator)
    if (!bIsGenerator)
        UpdateSwitchState()
    endif
endevent
event OnPowerOff()
    UpdateSwitchAnimation()
endevent

event OnActivate(ObjectReference akActionRef)
    ; Needed to ignore switch activation.
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    ObjectReference triggerRef = self.PlaceAtNode(sTriggerObjectNode, TriggerObject, abAttach = true)
    self.RegisterForRemoteEvent(triggerRef, "OnTriggerEnter")
    self.RegisterForRemoteEvent(triggerRef, "OnTriggerLeave")
    self.SetLinkedRef(triggerRef, LinkCustom01)
    TriggerRadius = fTriggerObjectSize
    Debug.MessageBox("triggerRef form id: " + triggerRef.GetFormID())
endevent
event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
    self.GetLinkedRef(LinkCustom01).Delete()
endevent
