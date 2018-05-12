;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Quests:QF_Min03CastleArmoryDoorController Extends Quest Hidden Const

;BEGIN FRAGMENT Fragment_Stage_0010_Item_00
Function Fragment_Stage_0010_Item_00()
;BEGIN CODE
ObjectReference ref = ArmoryLockOutside.GetReference()
ref.SetAngle(ref.GetAngleX(), ref.GetAngleY(), ref.GetAngleZ() + 180.0)
ref.SetPosition(ref.GetPositionY() + 48.0 * cos(ref.GetAngleZ()), ref.GetPositionY() + 48.0 * sin(ref.GetAngleZ()), ref.GetPositionZ())
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

import Math

ReferenceAlias property ArmoryLockOutside auto const mandatory
