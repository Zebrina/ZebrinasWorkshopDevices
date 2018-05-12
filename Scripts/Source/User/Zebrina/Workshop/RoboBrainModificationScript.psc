scriptname Zebrina:Workshop:RoboBrainModificationScript extends Zebrina:Workshop:ConfigurableObjectScript

group AutoFill
    Message property RoboBrainModificationTopLevelDialogue auto const mandatory
    Message property RoboBrainModificationHeadArmorDialogue auto const mandatory
    Message property RoboBrainModificationPaintDialogue auto const mandatory
    FormList property RoboBrainModificationHeadArmorList auto const mandatory
    FormList property RoboBrainModificationPaintList auto const mandatory
endgroup

MatSwap paintMatSwap = none

; Zebrina:Workshop:ConfigurableObjectScript override.
function DoConfiguration(ObjectReference akReference)
    InputEnableLayer inputLayer = InputEnableLayer.Create()
    inputLayer.DisablePlayerControls()

    int selection = -1
    while (selection != 0)
        selection = RoboBrainModificationTopLevelDialogue.Show()
        if (selection == 1)
            ObjectMod headArmorMod = RoboBrainModificationHeadArmorList.GetAt(RoboBrainModificationHeadArmorDialogue.Show()) as ObjectMod
            if (headArmorMod)
                akReference.AttachMod(headArmorMod)
            endif
        elseif (selection == 2)
            ; PC ONLY.
            paintMatSwap = RoboBrainModificationPaintList.GetAt(RoboBrainModificationPaintDialogue.Show()) as MatSwap
            akReference.SetMaterialSwap(paintMatSwap)
            akReference.Disable()
            akReference.EnableNoWait()
            if (paintMatSwap)
                self.RegisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
            else
                self.UnregisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
            endif
        endif
    endwhile

    inputLayer.EnablePlayerControls()
endfunction

event Actor.OnPlayerLoadGame(Actor akSender)
    self.SetMaterialSwap(paintMatSwap)
    if (self.Is3DLoaded())
        self.Disable()
        self.EnableNoWait()
    endif
endevent
