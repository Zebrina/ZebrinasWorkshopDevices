scriptname Zebrina:Workshop:BreakableObjectScript extends ObjectReference const

import Zebrina:WorkshopUtility

group AutoFill
    ActorValue property WorkshopObjectHealth_AV auto const mandatory
    Keyword property LinkCustom01 auto const mandatory
    { Link to the broken object reference. }
    Keyword property LinkCustom02 auto const mandatory
    { Link to the trigger volume that breaks this object. }
endgroup
group BreakableObject
    float property fRepairDelay = 1.0 auto const
    Form property BrokenObject auto const mandatory
    Sound property BreakSound const auto
    { Optional. }
    Activator property TriggerObject auto const mandatory
    string property sTriggerObjectNode = "TriggerNode" auto const
endgroup

ObjectReference property BrokenRef hidden
    ObjectReference function get()
        return self.GetLinkedRef(LinkCustom01)
    endfunction
    function set(ObjectReference akNewRef)
        ObjectReference oldRef = self.GetLinkedRef(LinkCustom01)
        if (oldRef)
            oldRef.DisableNoWait()
            oldRef.Delete()
        endif
        self.SetLinkedRef(akNewRef, LinkCustom01)
    endfunction
endproperty

; ObjectReference override.
bool function IsDestroyed()
    return self.GetValue(WorkshopObjectHealth_AV) <= 0.0
endfunction

function Damage(float afDamage)
    if (afDamage > 0.0)
        float health = self.GetValue(WorkshopObjectHealth_AV)
        if (health > 0.0)
            health -= afDamage
            if (health <= 0.0)
                if (BreakSound)
                    BreakSound.Play(self)
                endif
                ObjectReference newBrokenRef = self.PlaceAtMe(BrokenObject, abInitiallyDisabled = true)
                BrokenRef = newBrokenRef
                newBrokenRef.BlockActivation(true, true)
                newBrokenRef.EnableNoWait()
                self.SetLinkedRef(newBrokenRef, LinkCustom01)
                self.DisableNoWait()
                Utility.Wait(fRepairDelay)
                newBrokenRef.BlockActivation(false, false)
                self.RegisterForRemoteEvent(newBrokenRef, "OnActivate")
            endif
            self.SetValue(WorkshopObjectHealth_AV, health)
        endif
    endif
endfunction

event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string apMaterial)
	Damage(Utility.RandomFloat(35.0, 100.0))
    if (!self.IsDestroyed())
        self.RegisterForHitEvent(self)
    endif
endevent

function RepairAndReset()
    if (self.IsDestroyed())
        BrokenRef = none
        self.EnableNoWait()
        self.RegisterForHitEvent(self)
    endif
    self.SetValue(WorkshopObjectHealth_AV, 100.0)
endfunction

event OnActivate(ObjectReference akActionRef)
    if (IsPlayerActionRef(akActionRef))
        Damage(100.0)
    endif
endevent
event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    if (IsPlayerActionRef(akActionRef))
        self.UnregisterForRemoteEvent(akSender, "OnActivate")
        RepairAndReset()
    endif
endevent

event ObjectReference.OnTriggerEnter(ObjectReference akSender, ObjectReference akActionRef)
    Actor triggerActor = akActionRef as Actor
    Actor player = Game.GetPlayer()
    if (triggerActor && (triggerActor.IsHostileToActor(player) || (triggerActor == player && GetDebugGlobalValue())))
        Damage(100.0)
    endif
endevent

event OnLoad()
    RepairAndReset()
endevent

event OnWorkshopObjectPlaced(ObjectReference akReference)
    ObjectReference triggerBoxRef = self.PlaceAtMe(TriggerObject)
    triggerBoxRef.MoveToNode(self, sTriggerObjectNode)
    self.SetLinkedRef(triggerBoxRef, LinkCustom02)
    self.RegisterForRemoteEvent(triggerBoxRef, "OnTriggerEnter")
    self.RegisterForHitEvent(self)
endevent
event OnWorkshopObjectGrabbed(ObjectReference akReference)
    self.GetLinkedRef(LinkCustom02).DisableNoWait()
endevent
event OnWorkshopObjectMoved(ObjectReference akReference)
    ObjectReference triggerBoxRef = self.GetLinkedRef(LinkCustom02)
    triggerBoxRef.MoveToNode(self, sTriggerObjectNode)
    triggerBoxRef.EnableNoWait()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
    BrokenRef = none
    self.GetLinkedRef(LinkCustom02).Delete()
endevent
