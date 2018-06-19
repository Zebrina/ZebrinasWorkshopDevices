scriptname Zebrina:Workshop:ButtonScript extends ObjectReference

string property sButtonPressEvent = "Press" auto const
string property sEndEvent = "End" auto const
string property sTurnOnEvent = "TurnOn01" auto const
string property sTurnOffEvent = "TurnOff01" auto const

float property fTimeoutSeconds auto hidden

auto state WaitForActivation
    event OnActivate(ObjectReference akActionRef)
        self.GoToState("WaitForTimeout")
        self.PlayAnimationAndWait(sButtonPressEvent, sEndEvent)
        self.PlayAnimation(sTurnOnEvent)
        self.SetOpen(false)
        self.StartTimer(fTimeoutSeconds)
    endevent
endstate
state WaitForTimeout
    event OnActivate(ObjectReference akActionRef)
        self.StartTimer(fTimeoutSeconds)
    endevent

    event OnTimer(int aiTimerID)
        self.SetOpen()
        self.PlayAnimation(sTurnOffEvent)
        self.GoToState("WaitForActivation")
    endevent
endstate

event OnLoad()
    self.BlockActivation(true)
endevent
