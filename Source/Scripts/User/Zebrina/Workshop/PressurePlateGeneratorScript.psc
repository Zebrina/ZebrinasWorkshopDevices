scriptname Zebrina:Workshop:PressurePlateGeneratorScript extends TrapTrigPlate conditional

bool property bEnemiesOnly = true auto conditional
{ Used in conditions. }

bool bForcePowerState = false

function UpdatePowerState()
	self.SetOpen(self.Count == 0 && !bForcePowerState)
endfunction

; TrapTrigPlate override.
function CheckCount()
	parent.CheckCount()
	UpdatePowerState()
endfunction

; TrapTrigPlate override.
event OnWorkshopObjectPlaced(ObjectReference akWorkshop)
	parent.OnWorkshopObjectPlaced(akWorkshop)
	CheckCount()
endevent

; TrapTrigPlate override.
event OnActivate(ObjectReference akActionRef)
	parent.OnActivate(akActionRef)
	bForcePowerState = true
	UpdatePowerState()
	self.StartTimer(1.0)
endevent

event OnTimer(int aiTimerID)
	bForcePowerState = false
	UpdatePowerState()
endevent
