scriptname Zebrina:Workshop:SecurityGateScript extends ObjectReference conditional

import Math
import Zebrina:WorkshopUtility

group AutoFill
    FormList property WorkshopSecurityGateList auto const mandatory
endgroup

bool property bTerminalMode = false auto conditional hidden
bool bBusy = false conditional

ObjectReference function GetDoor()
    float r = self.GetAngleZ()
    return Game.FindClosestReferenceOfAnyTypeInList(WorkshopSecurityGateList, x - cos(r) * 128.0, y + sin(r) * 128.0, z, 10.0)
endfunction

function OpenDoor(ObjectReference akDoorRef, bool abOpen)
    if (!bBusy && akDoorRef is Zebrina:Default:TwoStateActivator)
        bBusy = true
        (akDoorRef as Zebrina:Default:TwoStateActivator).SetOpen(abOpen)
        bBusy = false
    endif
endfunction
function LockDoor(ObjectReference akDoorRef, bool abLock, int aiLockLevel)
    if (!bBusy && akDoorRef.GetBaseObject() is Door)
        bBusy = true
        akDoorRef.SetLockLevel(aiLockLevel)
        ; Lock only if closed.
        if (akDoorRef.GetOpenState() == 3)
            akDoorRef.Lock(abLock)
        endif
        bBusy = false
    endif
endfunction

function TerminalOpenDoor(bool abOpen)
    if (bTerminalMode && self.IsPowered())
        var[] args = new var[2]
        args[0] = GetDoor()
        args[1] = abOpen
        self.CallFunctionNoWait("OpenDoor", args)
    endif
endfunction
function TerminalLockDoor(bool abLock)
    if (bTerminalMode && self.IsPowered())
        var[] args = new var[3]
        args[0] = GetDoor()
        args[1] = abLock
        args[2] = 253
        self.CallFunctionNoWait("LockDoor", args)
    endif
endfunction

function HandlePowerState(bool abPowered)
    if (!bTerminalMode)
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
