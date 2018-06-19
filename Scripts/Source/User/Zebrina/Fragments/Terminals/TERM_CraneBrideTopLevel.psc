;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Zebrina:Fragments:Terminals:TERM_CraneBrideTopLevel Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
ObjectReference craneBridgeRef = Game.GetPlayer().GetLinkedRef(WorkshopLinkObjectConfiguration)
if (craneBridgeRef.GetValue(WorkshopObjectReversePowerState_AV) == 0.0)
    craneBridgeRef.ModValue(WorkshopObjectReversePowerState_AV, 1.0)
else
    craneBridgeRef.ModValue(WorkshopObjectReversePowerState_AV, -1.0)
endif
(craneBridgeRef as Zebrina:Workshop:PoweredTwoStateActivator).HandlePowerStateChange(craneBridgeRef.IsPowered())
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Keyword property WorkshopLinkObjectConfiguration auto const mandatory
ActorValue property WorkshopObjectReversePowerState_AV auto const mandatory
