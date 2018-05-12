;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Perks:PRKF_WorkshopDevices Extends Perk Hidden Const

;BEGIN FRAGMENT Fragment_Entry_00
Function Fragment_Entry_00(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
(akTargetRef as Zebrina:Workshop:ConfigurableObjectScript).StartConfiguration()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Entry_02
Function Fragment_Entry_02(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
if (ManageDoorDialogue.Show() == 0)
	ManagedDoors.AddRef(akTargetRef)
else
	ManagedDoors.RemoveRef(akTargetRef)
endif
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

function LockDoor(ObjectReference akTargetRef, bool abLock = true)
	if (abLock)
		akTargetRef.SetValue(WorkshopDoorLocked_AV, 1)
		akTargetRef.SetLockLevel(255)
		akTargetRef.Lock()
		UILockpickingUnlock.Play(akTargetRef)
	else
		akTargetRef.Lock(false)
		akTargetRef.SetLockLevel(0)
		akTargetRef.SetValue(WorkshopDoorLocked_AV, 0)
		UILockpickingUnlock.Play(akTargetRef)
	endif
endfunction

ActorValue property WorkshopDoorLocked_AV auto const mandatory
Sound property UILockpickingUnlock auto const mandatory
Message property ManageDoorDialogue auto const mandatory
RefCollectionAlias property ManagedDoors auto const mandatory
