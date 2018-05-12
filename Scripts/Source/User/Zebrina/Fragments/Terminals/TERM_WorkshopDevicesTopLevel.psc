;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Terminals:TERM_WorkshopDevicesTopLevel Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
ConfigTerminalCurrentValue1.SetValueInt(ZebrinasWorkshopDevices.IsWorkshopMenuInstalled() as int)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Zebrina:Workshop:WorkshopDevicesMasterScript property ZebrinasWorkshopDevices auto const mandatory
GlobalVariable property ConfigTerminalCurrentValue1 auto const mandatory
