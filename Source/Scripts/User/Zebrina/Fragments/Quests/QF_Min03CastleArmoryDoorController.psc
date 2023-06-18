;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Quests:QF_Min03CastleArmoryDoorController Extends Quest Hidden Const

;BEGIN FRAGMENT Fragment_Stage_0010_Item_00
Function Fragment_Stage_0010_Item_00()
;BEGIN CODE
; Force to ref here to prevent permanent persistance.
ObjectReference primaryButtonRef = Game.GetForm(0x000b47fd) as ObjectReference
ArmoryLock.ForceRefTo(primaryButtonRef)

; Create and move second switch outside.
primaryButtonRef.WaitFor3DLoad()
ObjectReference secondaryButtonRef = primaryButtonRef.PlaceAtMe(primaryButtonRef.GetBaseObject(), abInitiallyDisabled = true)
float r = primaryButtonRef.GetAngleZ() - 180.0
secondaryButtonRef.SetAngle(0.0, 0.0, r)
secondaryButtonRef.MoveTo(primaryButtonRef, fOffsetXY * sin(r), fOffsetXY * cos(r), fOffsetZ, false)
ArmoryLockOutside.ForceRefTo(secondaryButtonRef)
secondaryButtonRef.EnableNoWait(true)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

import Math

float fOffsetXY = -44.0 const
float fOffsetZ = 32.0 const

ReferenceAlias property ArmoryLock auto const mandatory
ReferenceAlias property ArmoryLockOutside auto const mandatory
