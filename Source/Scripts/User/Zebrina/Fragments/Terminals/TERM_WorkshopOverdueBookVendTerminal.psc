;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Terminals:TERM_WorkshopOverdueBookVendTerminal Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
(akTerminalRef as Zebrina:Workshop:OverdueBookVendorScript).UpdateTotalItemCountAndAliases()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Zebrina:Workshop:OverdueBookVendorMasterScript property WorkshopOverdueBookVendorMaster auto const mandatory
