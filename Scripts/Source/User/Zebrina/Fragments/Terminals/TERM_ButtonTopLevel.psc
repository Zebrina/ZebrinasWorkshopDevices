;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Terminals:TERM_ButtonTopLevel Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
ConfigTerminalObjectID.SetValue(0)
ConfigTerminalCurrentValue1.SetValue((Game.GetPlayer().GetLinkedRef(WorkshopLinkObjectConfiguration) as Zebrina:Workshop:ButtonScript).fTimeoutSeconds)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Keyword property WorkshopLinkObjectConfiguration auto const mandatory
GlobalVariable property ConfigTerminalObjectID auto const mandatory
GlobalVariable property ConfigTerminalCurrentValue1 auto const mandatory
