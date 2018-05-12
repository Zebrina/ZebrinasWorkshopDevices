scriptname Zebrina:Workshop:PowerLiftConfigurableObjectScript extends Zebrina:Workshop:ConfigurableObjectScript const

group AutoFill
    GlobalVariable property ConfigTerminalCurrentValue1 auto const mandatory
    GlobalVariable property ConfigTerminalPowerLiftHasBackPanel auto const mandatory
    GlobalVariable property ConfigTerminalPowerLiftHasLeftSidePanel auto const mandatory
    GlobalVariable property ConfigTerminalPowerLiftHasRightSidePanel auto const mandatory
    GlobalVariable property ConfigTerminalPowerLiftHasRamp auto const mandatory
    GlobalVariable property ConfigTerminalPowerLiftBackPanelEnabled auto const mandatory
    GlobalVariable property ConfigTerminalPowerLiftLeftSidePanelEnabled auto const mandatory
    GlobalVariable property ConfigTerminalPowerLiftRightSidePanelEnabled auto const mandatory
    GlobalVariable property ConfigTerminalPowerLiftRampEnabled auto const mandatory
    Message property PowerLiftConfigurationDisallowedMessage auto const mandatory
endgroup

; Zebrina:Workshop:ConfigurableObjectScript override.
function DoConfiguration(ObjectReference akReference)
    if (akReference.GetAnimationVariableFloat("fValue") == 0.0)
        Zebrina:Workshop:PowerLiftMiniCartScript powerLiftRef = akReference as Zebrina:Workshop:PowerLiftMiniCartScript

        ConfigTerminalCurrentValue1.SetValue(powerLiftRef.fLiftSpeedMult)
        ConfigTerminalPowerLiftHasBackPanel.SetValue(powerLiftRef.bHasBackPanel as float)
        ConfigTerminalPowerLiftHasLeftSidePanel.SetValue(powerLiftRef.bHasLeftSidePanel as float)
        ConfigTerminalPowerLiftHasRightSidePanel.SetValue(powerLiftRef.bHasRightSidePanel as float)
        ConfigTerminalPowerLiftHasRamp.SetValue(powerLiftRef.bHasRamp as float)
        ConfigTerminalPowerLiftBackPanelEnabled.SetValue(powerLiftRef.bBackPanelEnabled as float)
        ConfigTerminalPowerLiftLeftSidePanelEnabled.SetValue(powerLiftRef.bLeftSidePanelEnabled as float)
        ConfigTerminalPowerLiftRightSidePanelEnabled.SetValue(powerLiftRef.bRightSidePanelEnabled as float)
        ConfigTerminalPowerLiftRampEnabled.SetValue(powerLiftRef.bRampEnabled as float)

        parent.DoConfiguration(akReference)
    else
        PowerLiftConfigurationDisallowedMessage.Show()
    endif
endfunction
