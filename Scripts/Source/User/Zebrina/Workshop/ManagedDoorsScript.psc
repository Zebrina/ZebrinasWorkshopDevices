scriptname Zebrina:Workshop:ManagedDoorsScript extends RefCollectionAlias const

group AutoFill
    GlobalVariable property ManagedDoorsAutoCloseTimeOut auto const mandatory
endgroup

event OnOpen(ObjectReference akSender, ObjectReference akActionRef)
    self.StartTimer(ManagedDoorsAutoCloseTimeOut.GetValue(), self.Find(akSender))
endevent

event OnTimer(int aiTimerID)
    self.GetAt(aiTimerID).SetOpen(false)
endevent

event OnWorkshopObjectDestroyed(ObjectReference akSender, ObjectReference akWorkshopRef)
    self.RemoveRef(akSender)
endevent
