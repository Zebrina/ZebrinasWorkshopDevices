;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Terminals:TERM_SecurityGateTerminal Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
bool terminalEnabled = false

ObjectReference[] refs = akTerminalRef.GetLinkedRefArray(LinkTerminalSecurityGate)
int i = 0
while (i < refs.Length)
    terminalEnabled = terminalEnabled || (refs[i] as Zebrina:Workshop:SecurityGateScript).bTerminalMode
    i += 1
endwhile

NativeTerminalSecurityGateIsEnabled.SetValueInt(terminalEnabled as int)
NativeTerminalSecurityGateCount.SetValue(refs.Length)
akTerminalRef.AddTextReplacementData("SecurityGateCount", NativeTerminalSecurityGateCount)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Keyword property LinkTerminalSecurityGate auto const mandatory
GlobalVariable property NativeTerminalSecurityGateIsEnabled auto const mandatory
GlobalVariable property NativeTerminalSecurityGateCount auto const mandatory
