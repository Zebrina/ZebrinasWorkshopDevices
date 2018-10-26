;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Terminals:TERM_SecurityGateTerminalSubMenu Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
OpenSecurityGates(akTerminalRef, true)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
OpenSecurityGates(akTerminalRef, false)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
UnlockSecurityGates(akTerminalRef, true)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
UnlockSecurityGates(akTerminalRef, false)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
EnableSecurityGatesTerminalMode(akTerminalRef, true)
NativeTerminalSecurityGateIsEnabled.SetValue(1.0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
EnableSecurityGatesTerminalMode(akTerminalRef, false)
NativeTerminalSecurityGateIsEnabled.SetValue(0.0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

function OpenSecurityGates(ObjectReference akTerminalRef, bool abOpen)
    ObjectReference[] refs = akTerminalRef.GetLinkedRefArray(LinkTerminalSecurityGate)
    int i = 0
    while (i < refs.Length)
    	(refs[i] as Zebrina:Workshop:SecurityGateScript).TerminalOpenDoor(abOpen)
    	i += 1
    endwhile
endfunction
function UnlockSecurityGates(ObjectReference akTerminalRef, bool abUnlock)
    ObjectReference[] refs = akTerminalRef.GetLinkedRefArray(LinkTerminalSecurityGate)
    int i = 0
    while (i < refs.Length)
    	(refs[i] as Zebrina:Workshop:SecurityGateScript).TerminalLockDoor(!abUnlock)
    	i += 1
    endwhile
endfunction
function EnableSecurityGatesTerminalMode(ObjectReference akTerminalRef, bool abEnable)
    ObjectReference[] refs = akTerminalRef.GetLinkedRefArray(LinkTerminalSecurityGate)
    int i = 0
    while (i < refs.Length)
        (refs[i] as Zebrina:Workshop:SecurityGateScript).bTerminalMode = abEnable
    	i += 1
    endwhile
endfunction

Keyword property LinkTerminalSecurityGate auto const mandatory
GlobalVariable property NativeTerminalSecurityGateIsEnabled auto const mandatory
