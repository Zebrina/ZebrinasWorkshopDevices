;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Terminals:TERM_WorkshopHopperSetOutputTimer Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
SetOutputTimer(0.5, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
SetOutputTimer(1.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
SetOutputTimer(2.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
SetOutputTimer(3.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
SetOutputTimer(4.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
SetOutputTimer(5.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_07
Function Fragment_Terminal_07(ObjectReference akTerminalRef)
;BEGIN CODE
SetOutputTimer(10.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_08
Function Fragment_Terminal_08(ObjectReference akTerminalRef)
;BEGIN CODE
SetOutputTimer(15.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_09
Function Fragment_Terminal_09(ObjectReference akTerminalRef)
;BEGIN CODE
SetOutputTimer(20.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_10
Function Fragment_Terminal_10(ObjectReference akTerminalRef)
;BEGIN CODE
SetOutputTimer(30.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

function SetOutputTimer(float afValue, ObjectReference akTerminalRef)
	ObjectReference[] linkedRefs = akTerminalRef.GetLinkedRefArray(LinkTerminalHopperDLC05)
	int i = 0
	while (i < linkedRefs.length)
		ObjectReference hopperRef = linkedRefs[i]
		if (hopperRef is Zebrina:Workshop:WorkshopHopperScript)
			(hopperRef as Zebrina:Workshop:WorkshopHopperScript).fFiringTimer = afValue
		endif
		i += 1
	endWhile
endfunction

Keyword property LinkTerminalHopperDLC05 auto const mandatory
