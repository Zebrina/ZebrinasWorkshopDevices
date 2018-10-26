;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Terminals:TERM_RemoteDoorConnectorTopLevel Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
SetOpenWhenPowered(false, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
SetOpenWhenPowered(true, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

function SetOpenWhenPowered(bool abFlag, ObjectReference akTerminalRef)
    Zebrina:Workshop:RemoteDoorConnectorScript configRef = Game.GetPlayer().GetLinkedRef(WorkshopLinkObjectConfiguration) as Zebrina:Workshop:RemoteDoorConnectorScript
    configRef.bOpenWhenPowered = abFlag
    configRef.UpdatePowerStateNoWait()
    ConfigTerminalValue1.SetValue(abFlag as float)
endfunction

Keyword property WorkshopLinkObjectConfiguration auto const mandatory
GlobalVariable property ConfigTerminalValue1 auto const mandatory
