scriptname Zebrina:Default:DisableHavokOnLoad extends ObjectReference const

event OnLoad()
    self.SetMotionType(Motion_Keyframed)
    self.SetAngle(0.0, 0.0, self.GetAngleZ())
endevent
