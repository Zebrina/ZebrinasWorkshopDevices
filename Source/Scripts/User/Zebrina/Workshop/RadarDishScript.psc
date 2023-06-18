scriptname Zebrina:Workshop:RadarDishScript extends ObjectReference

group Configurable
    float property fDetectionDistance = 2000.0 auto
endgroup

function Update()
    Debug.Notification("Player distance to radar dish: " + self.GetDistance(Game.GetPlayer()))
endfunction
function StartUpdateTimer()
    ; 12 seconds is the time it takes the dish to rotate 360 degrees.
    self.StartTimer(12.0)
endfunction

event OnTimerGameTime(int aiTimerID)
    Update()
    StartUpdateTimer()
endevent

event OnCellAttach()
    StartUpdateTimer()
endevent
event OnCellDetach()
    self.CancelTimer()
endevent

event OnInit()
    StartUpdateTimer()
endevent
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    StartUpdateTimer()
endevent
