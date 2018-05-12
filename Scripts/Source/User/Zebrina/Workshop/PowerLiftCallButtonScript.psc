scriptname Zebrina:Workshop:PowerLiftCallButtonScript extends Zebrina:Workshop:PowerLiftConfigurableObjectScript

group AutoFill
    Zebrina:Workshop:PowerLiftMasterScript property WorkshopPowerLiftMaster auto const mandatory
    Keyword property WorkshopPowerLiftKeyword auto const mandatory
    Keyword property WorkshopLinkPowerLift auto const mandatory
endgroup
group PowerLiftCallButton
    float property fPowerLiftSearchRadius = 16384.0 auto const
endgroup

bool function IsACloserXYThanB(ObjectReference a, ObjectReference b)
    float deltaX = self.GetPositionX() - a.GetPositionX()
    float deltaY = self.GetPositionY() - a.GetPositionY()

    float comparableDistA = (deltaX * deltaX) + (deltaY * deltaY)

    deltaX = self.GetPositionX() - b.GetPositionX()
    deltaY = self.GetPositionY() - b.GetPositionY()

    float comparableDistB = (deltaX * deltaX) + (deltaY * deltaY)

    return comparableDistA < comparableDistB
endfunction

Zebrina:Workshop:PowerLiftMiniCartScript kPowerLift = none
Zebrina:Workshop:PowerLiftMiniCartScript property PowerLift hidden
    Zebrina:Workshop:PowerLiftMiniCartScript function get()
        return kPowerLift
    endfunction
    function set(Zebrina:Workshop:PowerLiftMiniCartScript akPowerLiftRef)
        self.SetLinkedRef(akPowerLiftRef, WorkshopLinkObjectConfiguration)
        self.SetLinkedRef(akPowerLiftRef, WorkshopLinkPowerLift)
		kPowerLift = akPowerLiftRef
    endfunction
endproperty

; Zebrina:Workshop:PowerLiftConfigurableObjectScript override.
event OnActivate(ObjectReference akActionRef)
    if (PowerLift)
        PowerLift.HandleActivation(self, akActionRef)
    endif
endevent

function FindOrUpdatePowerLift()
    if (self.IsEnabled())
        ObjectReference[] allPowerLifts = self.FindAllReferencesWithKeyword(WorkshopPowerLiftKeyword, fPowerLiftSearchRadius)
        Debug.Notification("PowerLiftCallButtonScript::FindOrUpdatePowerLift: Found " + allPowerLifts.Length + " potential power lift(s).")

        ObjectReference newPowerLift = none
        if (allPowerLifts.Length > 0)
            ; If multiple elevators, find the closest on the xy-axis.
            int i = 0
            while (i < allPowerLifts.Length)
                if (allPowerLifts[i].IsEnabled() && (!newPowerLift || IsACloserXYThanB(allPowerLifts[i], newPowerLift)))
                    newPowerLift = allPowerLifts[i]
                endif
                i += 1
            endwhile
        endif

        PowerLift = newPowerLift as Zebrina:Workshop:PowerLiftMiniCartScript
    endif
endfunction

event Zebrina:Workshop:PowerLiftMasterScript.PowerLiftManipulated(Zebrina:Workshop:PowerLiftMasterScript akSender, var[] akArgs)
    FindOrUpdatePowerLift()
endevent

function Initialize()
    FindOrUpdatePowerLift()
    WorkshopPowerLiftMaster.RegisterForPowerLiftManipulatedEvent(self)
endfunction
event OnWorkshopObjectPlaced(ObjectReference akReference)
    Initialize()
endevent
event OnReset()
    Initialize()
endevent
event OnWorkshopObjectMoved(ObjectReference akReference)
    FindOrUpdatePowerLift()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akReference)
    PowerLift = none
    WorkshopPowerLiftMaster.UnregisterForPowerLiftManipulatedEvent(self)
endevent