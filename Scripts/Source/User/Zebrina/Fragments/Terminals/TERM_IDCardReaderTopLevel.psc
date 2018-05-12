;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Terminals:TERM_IDCardReaderTopLevel Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
ConfigTerminalCurrentValue1.SetValue((Game.GetPlayer().GetLinkedRef(WorkshopLinkObjectConfiguration) as Zebrina:Workshop:IDCardReaderScript).fTimeoutSeconds)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
if (ConfigTerminalComponentCount1.GetValue() > 0.0)
	ConfigTerminalComponentCount1.Mod(-1.0)
	(Game.GetPlayer().GetLinkedRef(WorkshopLinkObjectConfiguration) as Zebrina:Workshop:IDCardReaderScript).CreateNewIDCard(Game.GetPlayer())
endif
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Keyword property WorkshopLinkObjectConfiguration auto const mandatory
GlobalVariable property ConfigTerminalCurrentValue1 auto const mandatory
GlobalVariable property ConfigTerminalComponentCount1 auto const mandatory
