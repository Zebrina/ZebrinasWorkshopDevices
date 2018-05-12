;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Terminals:TERM_PowerLiftTopLevel Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
ConfigTerminalCurrentValue1.SetValue(GetPowerLift().fLiftSpeedMult)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
GetPowerLift().BackPanelEnabled = false
ConfigTerminalPowerLiftBackPanelEnabled.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
GetPowerLift().BackPanelEnabled = true
ConfigTerminalPowerLiftBackPanelEnabled.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
GetPowerLift().LeftSidePanelEnabled = false
ConfigTerminalPowerLiftLeftSidePanelEnabled.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
GetPowerLift().LeftSidePanelEnabled = true
ConfigTerminalPowerLiftLeftSidePanelEnabled.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
GetPowerLift().RightSidePanelEnabled = false
ConfigTerminalPowerLiftRightSidePanelEnabled.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_07
Function Fragment_Terminal_07(ObjectReference akTerminalRef)
;BEGIN CODE
GetPowerLift().RightSidePanelEnabled = true
ConfigTerminalPowerLiftRightSidePanelEnabled.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_08
Function Fragment_Terminal_08(ObjectReference akTerminalRef)
;BEGIN CODE
GetPowerLift().RampEnabled = false
ConfigTerminalPowerLiftRampEnabled.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_09
Function Fragment_Terminal_09(ObjectReference akTerminalRef)
;BEGIN CODE
GetPowerLift().RampEnabled = true
ConfigTerminalPowerLiftRampEnabled.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Zebrina:Workshop:PowerLiftMiniCartScript function GetPowerLift()
    return Game.GetPlayer().GetLinkedRef(WorkshopLinkObjectConfiguration) as Zebrina:Workshop:PowerLiftMiniCartScript
endfunction

Keyword property WorkshopLinkObjectConfiguration auto const mandatory
GlobalVariable property ConfigTerminalCurrentValue1 auto const mandatory
GlobalVariable property ConfigTerminalPowerLiftHasBackPanel auto const mandatory
GlobalVariable property ConfigTerminalPowerLiftHasLeftSidePanel auto const mandatory
GlobalVariable property ConfigTerminalPowerLiftHasRightSidePanel auto const mandatory
GlobalVariable property ConfigTerminalPowerLiftHasRamp auto const mandatory
GlobalVariable property ConfigTerminalPowerLiftBackPanelEnabled auto const mandatory
GlobalVariable property ConfigTerminalPowerLiftLeftSidePanelEnabled auto const mandatory
GlobalVariable property ConfigTerminalPowerLiftRightSidePanelEnabled auto const mandatory
GlobalVariable property ConfigTerminalPowerLiftRampEnabled auto const mandatory
