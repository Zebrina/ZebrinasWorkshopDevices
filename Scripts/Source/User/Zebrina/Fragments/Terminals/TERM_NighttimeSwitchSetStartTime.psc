;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Terminals:TERM_NighttimeSwitchSetStartTime Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(18.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(19.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(20.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(21.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(22.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(23.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_07
Function Fragment_Terminal_07(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(0.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_08
Function Fragment_Terminal_08(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(1.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_09
Function Fragment_Terminal_09(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(2.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_10
Function Fragment_Terminal_10(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(3.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_11
Function Fragment_Terminal_11(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(4.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_12
Function Fragment_Terminal_12(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(5.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_13
Function Fragment_Terminal_13(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(6.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_14
Function Fragment_Terminal_14(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(7.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_15
Function Fragment_Terminal_15(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(8.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_16
Function Fragment_Terminal_16(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(9.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_17
Function Fragment_Terminal_17(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(10.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_18
Function Fragment_Terminal_18(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(11.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_19
Function Fragment_Terminal_19(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(12.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_20
Function Fragment_Terminal_20(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(13.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_21
Function Fragment_Terminal_21(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(14.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_22
Function Fragment_Terminal_22(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(15.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_23
Function Fragment_Terminal_23(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(16.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_24
Function Fragment_Terminal_24(ObjectReference akTerminalRef)
;BEGIN CODE
SetTimeParam(17.0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

function SetTimeParam(float gameHour, ObjectReference terminalRef)
    if (terminalRef)
        ObjectReference[] linkedRefArray = terminalRef.getLinkedRefArray(LinkTerminalNighttimeSwitch)

    	int i = 0
    	while (i < linkedRefArray.length)
    		Zebrina:Workshop:NighttimeSwitchScript theObject = linkedRefArray[i] as Zebrina:Workshop:NighttimeSwitchScript
    		if (theObject)
    			theObject.fTurnOnAtGameHour = gameHour
                theObject.CalculateAndQueueNextUpdate()
    		endif
    		i += 1
    	endWhile
    else
        Zebrina:Workshop:NighttimeSwitchScript configureObjectRef = Game.GetPlayer().GetLinkedRef(WorkshopLinkObjectConfiguration) as Zebrina:Workshop:NighttimeSwitchScript
        if (configureObjectRef)
            configureObjectRef.fTurnOnAtGameHour = gameHour
            if (configureObjectRef.fTurnOffAtGameHour == gameHour)
                if (gameHour == 23.0)
                    configureObjectRef.fTurnOffAtGameHour = 0.0
                else
                    configureObjectRef.fTurnOffAtGameHour = gameHour + 1.0
                endif
            endif
            configureObjectRef.CalculateAndQueueNextUpdate()
        endif
    endif
endfunction

Keyword property LinkTerminalNighttimeSwitch auto const mandatory
Keyword property WorkshopLinkObjectConfiguration auto const mandatory
