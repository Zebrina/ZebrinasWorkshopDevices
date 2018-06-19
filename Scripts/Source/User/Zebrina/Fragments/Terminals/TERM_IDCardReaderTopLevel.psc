;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Terminals:TERM_IDCardReaderTopLevel Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
ConfigTerminalValue1.SetValue(GetConfigRef().fTimeoutSeconds)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
if (ConfigTerminalValue2.GetValue() > 0.0)
	ConfigTerminalValue2.Mod(-1.0)
	GetConfigRef().CreateNewIDCard(Game.GetPlayer())
endif
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
GetConfigRef().bDoorMode = true
ConfigTerminalValue3.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
GetConfigRef().bDoorMode = false
ConfigTerminalValue3.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Zebrina:Workshop:IDCardReaderScript function GetConfigRef()
	return Game.GetPlayer().GetLinkedRef(WorkshopLinkObjectConfiguration) as Zebrina:Workshop:IDCardReaderScript
endfunction

Keyword property WorkshopLinkObjectConfiguration auto const mandatory
GlobalVariable property ConfigTerminalValue1 auto const mandatory
GlobalVariable property ConfigTerminalValue2 auto const mandatory
GlobalVariable property ConfigTerminalValue3 auto const mandatory
