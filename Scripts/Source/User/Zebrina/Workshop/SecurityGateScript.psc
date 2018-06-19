scriptname Zebrina:Workshop:SecurityGateScript extends ObjectReference const

import Math
import Zebrina:WorkshopUtility

group AutoFill
    Keyword property WorkshopObjectHandlePowerState auto const mandatory
    Keyword property WorkshopSecurityGateTerminalMode auto const mandatory
endgroup
group SecurityGate
    FormList property WorkshopSecurityGateList auto const mandatory
endgroup

ObjectReference function GetDoor()
    float r = self.GetAngleZ()
    return Game.FindClosestReferenceOfAnyTypeInList(WorkshopSecurityGateList, x - cos(r) * 128.0, y + sin(r) * 128.0, z, 10.0)
endfunction

function OpenDoor(ObjectReference akDoorRef, bool abOpen)
    if (!self.HasKeyword(WorkshopObjectHandlePowerState) && akDoorRef is Zebrina:Default:TwoStateActivator)
        self.AddKeyword(WorkshopObjectHandlePowerState)
        (akDoorRef as Zebrina:Default:TwoStateActivator).SetOpen(abOpen)
        self.ResetKeyword(WorkshopObjectHandlePowerState)
    endif
endfunction
function LockDoor(ObjectReference akDoorRef, bool abLock, int aiLockLevel)
    if (!self.HasKeyword(WorkshopObjectHandlePowerState) && akDoorRef.GetBaseObject() is Door)
        self.AddKeyword(WorkshopObjectHandlePowerState)
        akDoorRef.SetLockLevel(aiLockLevel)
        ; Lock only if closed.
        if (akDoorRef.GetOpenState() == 3)
            akDoorRef.Lock(abLock)
        endif
        self.ResetKeyword(WorkshopObjectHandlePowerState)
    endif
endfunction

function TerminalOpenDoor(bool abOpen)
    if (self.HasKeyword(WorkshopSecurityGateTerminalMode) && self.IsPowered())
        var[] args = new var[2]
        args[0] = GetDoor()
        args[1] = abOpen
        self.CallFunctionNoWait("OpenDoor", args)
    endif
endfunction
function TerminalLockDoor(bool abLock)
    if (self.HasKeyword(WorkshopSecurityGateTerminalMode) && self.IsPowered())
        var[] args = new var[3]
        args[0] = GetDoor()
        args[1] = abLock
        args[2] = 253
        self.CallFunctionNoWait("LockDoor", args)
    endif
endfunction

function HandlePowerState(bool abPowered)
    if (!self.HasKeyword(WorkshopSecurityGateTerminalMode))
        ObjectReference doorRef = GetDoor()
        OpenDoor(doorRef, abPowered)
        LockDoor(doorRef, abPowered, 253)
    endif
endfunction
event OnPowerOn(ObjectReference akPowerGenerator)
    HandlePowerState(true)
endevent
event OnPowerOff()
    HandlePowerState(false)
endevent
