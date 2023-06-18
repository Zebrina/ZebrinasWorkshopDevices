scriptname Zebrina:Workshop:QuarryElevatorScript extends Zebrina:Workshop:PowerLiftMiniCartScript
{ Specialized power lift script for the quarry elevator. }

import Zebrina:WorkshopUtility

group AutoFill
    Activator property WorkshopQuarryElevatorMachineWheel01 auto const mandatory
    Activator property WorkshopQuarryElevatorCounterweight01 auto const mandatory
    Static property WorkshopDummyRefMarker auto const mandatory
    Sound property OBJElevatorGenericMovementLPM auto const mandatory
    { Sound for platform. }
    Sound property OBJElevatorMotorLPM auto const mandatory
    { Sound for motor. }
    Sound property OBJElevatorCounterweightLPM auto const mandatory
    { Sound for counterweight. }
endgroup

float liftBottomLevel

ObjectReference kMachineWheel = none
ObjectReference property MachineWheel hidden
	ObjectReference function get()
		return kMachineWheel
	endfunction
	function set(ObjectReference akMachineWheelRef)
		if (kMachineWheel)
			;kMachineWheel.DisableNoWait()
			kMachineWheel.Delete()
		endif
		kMachineWheel = akMachineWheelRef
	endfunction
endproperty
ObjectReference kElevatorCounterweight = none
ObjectReference property ElevatorCounterweight hidden
	ObjectReference function get()
		return kElevatorCounterweight
	endfunction
	function set(ObjectReference akElevatorCounterweightRef)
		if (kElevatorCounterweight)
			kElevatorCounterweight.Delete()
		endif
		kElevatorCounterweight = akElevatorCounterweightRef
	endfunction
endproperty
ObjectReference kElevatorPlatformSoundMarker = none
ObjectReference property ElevatorPlatformSoundMarker hidden
	ObjectReference function get()
		return kElevatorPlatformSoundMarker
	endfunction
	function set(ObjectReference akElevatorPlatformSoundMarkerRef)
		if (kElevatorPlatformSoundMarker)
            kElevatorPlatformSoundMarker.GetLinkedRef().Delete()
			kElevatorPlatformSoundMarker.Delete()
		endif
		kElevatorPlatformSoundMarker = akElevatorPlatformSoundMarkerRef
	endfunction
endproperty

; Zebrina:Workshop:PowerLiftMiniCartScript override.
ObjectReference[] function GetCallButtonArray()
	ObjectReference[] refs = parent.GetCallButtonArray()
    if (refs.Length > 0)
        ; Save bottom level for later.
        liftBottomLevel = self.GetLiftPositionPercentage(refs[0].z)
    endif
	return refs
endfunction

; Zebrina:Workshop:PowerLiftMiniCartScript override.
function MoveCartInternal(ObjectReference akTargetLift, float afSpeed, float afValue, bool abWait = true)
    float currentLevel = self.GetLiftLevel(self)
    if (afValue > currentLevel)
        ; Elevator going down.
        MachineWheel.PlayAnimation("LoopA")
    else
        ; Elevator going up.
        MachineWheel.PlayAnimation("LoopB")
    endif

    ; Adjust counterweight.
    parent.MoveCartInternal(ElevatorCounterweight, 0.1, liftBottomLevel - currentLevel)

    int platformSoundInstance = OBJElevatorGenericMovementLPM.Play(ElevatorPlatformSoundMarker)
    int motorSoundInstance = OBJElevatorMotorLPM.Play(MachineWheel)
    int counterweightSoundInstance = OBJElevatorCounterweightLPM.Play(ElevatorCounterweight)

    parent.MoveCartInternal(ElevatorCounterweight, afSpeed, liftBottomLevel - afValue, false)
    parent.MoveCartInternal(self, afSpeed, afValue)

    MachineWheel.PlayAnimation("Stop")

    Sound.StopInstance(platformSoundInstance)
    Sound.StopInstance(motorSoundInstance)
    Sound.StopInstance(counterweightSoundInstance)
endfunction

; Zebrina:Workshop:PowerLiftMiniCartScript override.
function Initialize()
    self.WaitFor3DLoad()
    MachineWheel = self.PlaceAtNode("QryElevatorMachineWheelNode", WorkshopQuarryElevatorMachineWheel01)
    ElevatorCounterweight = self.PlaceAtNode("CounterweightNode", WorkshopQuarryElevatorCounterweight01)
    ElevatorPlatformSoundMarker = self.PlaceAtNode("Cart01", WorkshopDummyRefMarker, abAttach = true)
    ElevatorPlatformSoundMarker.SetLinkedRef(ElevatorCounterweight.PlaceAtNode("REF_ATTACH_NODE", WorkshopDummyRefMarker, abAttach = true))

	parent.Initialize()
endfunction
; Zebrina:Workshop:PowerLiftMiniCartScript override.
event OnWorkshopObjectGrabbed(ObjectReference akWorkshopRef)
	MachineWheel.DisableNoWait()
    ElevatorCounterweight.DisableNoWait()

    parent.OnWorkshopObjectGrabbed(akWorkshopref)
endevent
; Zebrina:Workshop:PowerLiftMiniCartScript override.
event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
	MachineWheel.MoveToNode(self, "QryElevatorMachineWheelNode")
	MachineWheel.EnableNoWait()
    ; Enable counterweight and wait for 3D to load.
    ElevatorCounterweight.Enable()
    ElevatorCounterweight.MoveToNode(self, "CounterweightNode")

    parent.OnWorkshopObjectMoved(akWorkshopref)
endevent
; Zebrina:Workshop:PowerLiftMiniCartScript override.
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
	MachineWheel = none
	ElevatorCounterweight = none
    ElevatorPlatformSoundMarker = none

    parent.OnWorkshopObjectDestroyed(akWorkshopref)
endevent
