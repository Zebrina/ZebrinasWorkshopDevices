;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Terminals:TERM_PowerLiftSetSpeed Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
SetElevatorSpeed(0.5)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
SetElevatorSpeed(0.75)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
SetElevatorSpeed(0.9)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
SetElevatorSpeed(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
SetElevatorSpeed(1.1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
SetElevatorSpeed(1.25)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_07
Function Fragment_Terminal_07(ObjectReference akTerminalRef)
;BEGIN CODE
SetElevatorSpeed(1.5)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_08
Function Fragment_Terminal_08(ObjectReference akTerminalRef)
;BEGIN CODE
SetElevatorSpeed(2.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_09
Function Fragment_Terminal_09(ObjectReference akTerminalRef)
;BEGIN CODE
SetElevatorSpeed(3.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_10
Function Fragment_Terminal_10(ObjectReference akTerminalRef)
;BEGIN CODE
SetElevatorSpeed(4.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_11
Function Fragment_Terminal_11(ObjectReference akTerminalRef)
;BEGIN CODE
SetElevatorSpeed(5.0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

function SetElevatorSpeed(float afNewSpeedMult)
    ObjectReference configureObjectRef = Game.GetPlayer().GetLinkedRef(WorkshopLinkObjectConfiguration)
    if (configureObjectRef != none && configureObjectRef is Zebrina:Workshop:PowerLiftMiniCartScript)
        (configureObjectRef as Zebrina:Workshop:PowerLiftMiniCartScript).fLiftSpeedMult = afNewSpeedMult
        ConfigTerminalCurrentValue1.SetValue(afNewSpeedMult)
    endif
endfunction

Keyword property WorkshopLinkObjectConfiguration auto const mandatory
GlobalVariable property ConfigTerminalCurrentValue1 auto const mandatory
