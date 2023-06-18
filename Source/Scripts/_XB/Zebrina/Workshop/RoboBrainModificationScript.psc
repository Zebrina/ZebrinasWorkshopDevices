scriptname Zebrina:Workshop:RoboBrainModificationScript extends ObjectReference

group AutoFill
    Message property RoboBrainModificationTopLevelDialogue auto const mandatory
    Message property RoboBrainModificationHeadArmorDialogue auto const mandatory
    FormList property RoboBrainModificationHeadArmorList auto const mandatory
    Message property RoboBrainModificationPaintDialogue auto const mandatory
    FormList property RobotModificationPaintList auto const mandatory
endgroup
group Other
    bool property bIsAnimated = false auto const
endgroup

function Customize()
endfunction

auto state Ready
    function Customize()
        self.GoToState("Busy")

        int selection = -1
        while (selection != 2)
            selection = RoboBrainModificationTopLevelDialogue.Show()
            if (selection == 0)
                ObjectMod headArmorMod = RoboBrainModificationHeadArmorList.GetAt(RoboBrainModificationHeadArmorDialogue.Show()) as ObjectMod
                if (headArmorMod)
                    self.AttachMod(headArmorMod)
                endif
            endif
        endwhile

        self.GoToState("Ready")
    endfunction
endstate
state Busy
endstate

event OnActivate(ObjectReference akActionRef)
    if (akActionRef == Game.GetPlayer())
        Customize()
    endif
endevent

event OnPowerOn(ObjectReference akPowerGenerator)
    if (bIsAnimated)
        self.PlayAnimation("StartAnim")
    endif
endevent
event OnPowerOff()
    if (bIsAnimated)
        self.PlayAnimation("StopAnim")
    endif
endevent

event OnLoad()
    self.BlockActivation()
endevent
event OnWorkshopObjectPlaced(ObjectReference akReference)
    if (bIsAnimated && !self.IsPowered())
        self.PlayAnimation("StopAnim")
    endif
endevent
