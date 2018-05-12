scriptname Zebrina:Workshop:PowerLiftMasterScript extends Quest

customevent PowerLiftManipulated

function RegisterForPowerLiftManipulatedEvent(ObjectReference akCallButtonRef)
    akCallButtonRef.RegisterForCustomEvent(self, "PowerLiftManipulated")
endfunction
function UnregisterForPowerLiftManipulatedEvent(ObjectReference akCallButtonRef)
    akCallButtonRef.UnregisterForCustomEvent(self, "PowerLiftManipulated")
endfunction
function SendPowerLiftManipulatedEvent(ObjectReference akPowerLiftRef)
    var[] args = new var[1]
    args[0] = akPowerLiftRef
    self.SendCustomEvent("PowerLiftManipulated", args)
endfunction

event OnInit()
    self.RegisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
endevent
