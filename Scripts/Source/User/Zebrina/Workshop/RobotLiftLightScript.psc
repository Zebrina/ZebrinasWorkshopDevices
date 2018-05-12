scriptname Zebrina:Workshop:RobotLiftLightScript extends ObjectReference const

group AutoFill
	Keyword property WorkshopStackedItemParentKeyword auto const mandatory
endgroup
group Required
	string property sLightOnEvent auto const mandatory
endgroup

event Zebrina:Workshop:RobotLiftScript.ToggleLights(Zebrina:Workshop:RobotLiftScript akSender, Var[] akArgs)
	if (akArgs[0] as bool)
		self.PlayAnimation(sLightOnEvent)
	else
		self.PlayAnimation("Off")
	endif
endevent

event OnLoad()
	Zebrina:Workshop:RobotLiftScript robotLiftParentRef = self.GetLinkedRef(WorkshopStackedItemParentKeyword) as Zebrina:Workshop:RobotLiftScript
    if (robotLiftParentRef)
		self.RegisterForCustomEvent(robotLiftParentRef, "ToggleLights")
		Zebrina:WorkshopUtility.DEBUGTraceSelf(self, "OnLoad", "Attached to " + robotLiftParentRef)
    endif
EndEvent
event OnUnload()
	self.UnregisterForAllEvents()
endevent

event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
	self.UnregisterForAllEvents()
	self.OnLoad()
endevent
