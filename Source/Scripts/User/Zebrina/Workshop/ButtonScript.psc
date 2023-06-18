scriptname Zebrina:Workshop:ButtonScript extends ObjectReference

string property sButtonPressEvent = "Press" auto const
string property sEndEvent = "End" auto const
string property sTurnOnEvent = "TurnOn01" auto const
string property sTurnOffEvent = "TurnOff01" auto const

float property fTimeoutSeconds = 5.0 auto hidden

auto state WaitForActivation
    event OnActivate(ObjectReference akActionRef)
        self.GoToState("Transition")
        self.PlayAnimationAndWait(sButtonPressEvent, sEndEvent)
        self.PlayAnimation(sTurnOnEvent)
        self.SetOpen(false)
        self.GoToState("WaitForTimeout")
    endevent
endstate
state Transition
endstate
state WaitForTimeout
    event OnBeginState(string asOldState)
        self.StartTimer(fTimeoutSeconds)
    endevent

    event OnActivate(ObjectReference akActionRef)
        self.GoToState("Transition")
		self.PlayAnimationAndWait(sButtonPressEvent, sEndEvent)
        self.GoToState("WaitForTimeout")
    endevent

    event OnTimer(int aiTimerID)
        self.SetOpen(true)
        self.PlayAnimation(sTurnOffEvent)
        self.GoToState("WaitForActivation")
    endevent
endstate

event OnLoad()
    self.WaitFor3DLoad()
    self.SetOpen(true)
    self.BlockActivation()
endevent
