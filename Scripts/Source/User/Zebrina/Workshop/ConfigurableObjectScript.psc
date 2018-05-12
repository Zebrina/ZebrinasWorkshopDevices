scriptname Zebrina:Workshop:ConfigurableObjectScript extends ObjectReference const conditional

import Zebrina:WorkshopUtility

group AutoFill
    Idle property IdlePipBoyJackIn auto const mandatory
    Idle property IdlePipBoyJackOut auto const mandatory
    Keyword property WorkshopLinkObjectConfiguration auto const mandatory
endgroup
group ConfigurableObject
    Terminal property TopLevelTerminal auto const mandatory
    bool property bRunOnLinkedRef = false auto const
    { If true, configuration is done to to the ref linked with WorkshopLinkObjectConfiguration keyword instead of itself. }
    bool property bRunOnActivate = false auto const conditional
endgroup

function DoConfiguration(ObjectReference akReference)
    InputEnableLayer inputLayer = InputEnableLayer.Create()
    inputLayer.DisablePlayerControls()

    Game.ForceFirstPerson()
    Game.GetPlayer().PlayIdle(IdlePipBoyJackIn)
    Utility.Wait(0.833)

    inputLayer.EnablePlayerControls()

    TopLevelTerminal.ShowOnPipboy()
endfunction
function StartConfiguration()
    Actor player = Game.GetPlayer()
    if (bRunOnLinkedRef)
        player.SetLinkedRef(self.GetLinkedRef(WorkshopLinkObjectConfiguration), WorkshopLinkObjectConfiguration)
    else
        player.SetLinkedRef(self, WorkshopLinkObjectConfiguration)
    endif
    DoConfiguration(player.GetLinkedRef(WorkshopLinkObjectConfiguration))
endfunction

event OnActivate(ObjectReference akActionRef)
    if (bRunOnActivate && IsPlayerActionRef(akActionRef) && (!self.GetLinkedRef() || self.GetLinkedRef().GetOpenState() == 1))
        StartConfiguration()
    endif
endevent
