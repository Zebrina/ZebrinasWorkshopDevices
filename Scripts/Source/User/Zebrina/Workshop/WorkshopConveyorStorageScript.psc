scriptname Zebrina:Workshop:WorkshopConveyorStorageScript extends ObjectReference

ObjectReference workshopRef

event OnTriggerEnter(ObjectReference akActionRef)
    if (!(akActionRef is Actor) && !akActionRef.IsDisabled() && !(akActionRef.GetBaseObject() is Container))
        workshopRef.AddItem(akActionRef)
    endif
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    workshopRef = akWorkshopRef
endevent
