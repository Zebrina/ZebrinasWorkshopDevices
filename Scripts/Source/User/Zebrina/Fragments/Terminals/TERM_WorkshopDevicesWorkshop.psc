;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Terminals:TERM_WorkshopDevicesWorkshop Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
ZebrinasWorkshopDevices_LegacyNightTimeSwitchHidden.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
ZebrinasWorkshopDevices_LegacyNightTimeSwitchHidden.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
ZebrinasWorkshopDevices_RadiatingVariantsHidden.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
ZebrinasWorkshopDevices_RadiatingVariantsHidden.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
ZebrinasWorkshopDevices.InstallWorkshopMenu()
UpdateWorkshopMenuInstallationState()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
ZebrinasWorkshopDevices.UninstallWorkshopMenu()
UpdateWorkshopMenuInstallationState()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_07
Function Fragment_Terminal_07(ObjectReference akTerminalRef)
;BEGIN CODE
ZebrinasWorkshopDevices_DeviceConfigurationRequiresWeapon.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_08
Function Fragment_Terminal_08(ObjectReference akTerminalRef)
;BEGIN CODE
ZebrinasWorkshopDevices_DeviceConfigurationRequiresWeapon.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_09
Function Fragment_Terminal_09(ObjectReference akTerminalRef)
;BEGIN CODE
ZebrinasWorkshopDevices_TeleporterRequiresInstituteQuest.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_10
Function Fragment_Terminal_10(ObjectReference akTerminalRef)
;BEGIN CODE
ZebrinasWorkshopDevices_TeleporterRequiresInstituteQuest.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

function UpdateWorkshopMenuInstallationState()
    ConfigTerminalCurrentValue1.SetValueInt(ZebrinasWorkshopDevices.IsWorkshopMenuInstalled() as int)
endfunction

Zebrina:Workshop:WorkshopDevicesMasterScript property ZebrinasWorkshopDevices auto const mandatory
GlobalVariable property ConfigTerminalCurrentValue1 auto const mandatory
GlobalVariable property ZebrinasWorkshopDevices_DeviceConfigurationRequiresWeapon auto const mandatory
GlobalVariable property ZebrinasWorkshopDevices_TeleporterRequiresInstituteQuest auto const mandatory
GlobalVariable property ZebrinasWorkshopDevices_LegacyNightTimeSwitchHidden auto const mandatory
GlobalVariable property ZebrinasWorkshopDevices_RadiatingVariantsHidden auto const mandatory
