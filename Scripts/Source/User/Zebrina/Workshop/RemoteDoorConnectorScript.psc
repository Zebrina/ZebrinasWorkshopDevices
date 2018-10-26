scriptname Zebrina:Workshop:RemoteDoorConnectorScript extends Zebrina:Workshop:ConfigurableObjectScript

group AutoFill
    Keyword property BlockPlayerActivation auto const mandatory
    Keyword property WorkshopScriptControlledKeyword auto const mandatory
    Zebrina:WorkshopDevicesParent property ZebrinasWorkshopDevices auto const mandatory
	Message property WorkshopSelectRemoteDoorConnectorTargetDialogue auto const mandatory
    Zebrina:WorkshopSelectionQuest property WorkshopSelectDoor auto const mandatory
    GlobalVariable property ConfigTerminalValue1 auto const mandatory
endgroup
group Configurable
    bool property bOpenWhenPowered = true auto
    { If false, will close when powered. }
endgroup

function DoConfiguration(ObjectReference akReference)
    ConfigTerminalValue1.SetValue(bOpenWhenPowered as float)
    parent.DoConfiguration(akReference)
endfunction

ObjectReference doorRef = none
function InitializeDoor()
    if (WorkshopSelectRemoteDoorConnectorTargetDialogue.Show() == 1)
        ClearDoor()
        ObjectReference newDoorRef = ZebrinasWorkshopDevices.SelectWorkshopObject(self, WorkshopSelectDoor)
        if (newDoorRef)
            newDoorRef.BlockActivation()
            newDoorRef.AddKeyword(BlockPlayerActivation)
            newDoorRef.AddKeyword(WorkshopScriptControlledKeyword)
            newDoorRef.SetOpen(self.IsPowered() == bOpenWhenPowered)
            doorRef = newDoorRef
        endif
    endif
endfunction
function ClearDoor()
    if (doorRef)
        doorRef.ResetKeyword(WorkshopScriptControlledKeyword)
        doorRef.ResetKeyword(BlockPlayerActivation)
        doorRef.BlockActivation(false)
        doorRef = none
    endif
endfunction

bool powerStateChangeInProgress = false
function HandlePowerStateChange(bool abWasPowered)
    if (!powerStateChangeInProgress && doorRef)
        powerStateChangeInProgress = true
        Utility.Wait(0.01) ; Wait to avoid fake OnPowerOn events.
        if (abWasPowered == self.IsPowered())
            while ((self.IsPowered() == (doorRef.GetOpenState() == 1)) != bOpenWhenPowered)
                doorRef.SetOpen(self.IsPowered() == bOpenWhenPowered)
            endwhile
        endif
        powerStateChangeInProgress = false
    endif
endfunction
function UpdatePowerState()
    HandlePowerStateChange(self.IsPowered())
endfunction
function UpdatePowerStateNoWait()
    self.CallFunctionNoWait("UpdatePowerState", new var[0])
endfunction

event OnPowerOn(ObjectReference akPowerGenerator)
    HandlePowerStateChange(true)
endevent
event OnPowerOff()
    HandlePowerStateChange(false)
endevent

event OnLoad()
    UpdatePowerState()
endevent

event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
    InitializeDoor()
endevent
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    InitializeDoor()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
    ClearDoor()
endevent
