scriptname Zebrina:Workshop:TeleporterScript extends ObjectReference

group AutoFill
    Keyword property WorkshopIncludeTeleporter auto const mandatory
    { Used to signify that a workshop has a valid teleporter available. }
    FormList property WorkshopIncludeTeleporterList auto const mandatory
    Keyword property WorkshopLinkTeleporterWorkshop auto const mandatory
    { Used to link self to workshop. }
    Keyword property WorkshopWorkObject auto const mandatory
    Keyword property WorkshopTeleporterReflectorPlatformKeyword auto const mandatory
    Keyword property WorkshopTeleporterRelayDishKeyword auto const mandatory
    Keyword property WorkshopTeleporterConsoleKeyword auto const mandatory
    Activator property WorkshopTeleporterActivationTrigger auto const mandatory
    Message property TeleporterBeamEmitterRepairNeededMessage auto const mandatory
    Message property TeleporterBeamEmitterPowerRequiredMessage auto const mandatory
    Message property TeleporterReflectorPlatformMissingInPowerGridMessage auto const mandatory
    Message property TeleporterReflectorPlatformRepairNeededMessage auto const mandatory
    Message property TeleporterReflectorPlatformPowerRequiredMessage auto const mandatory
    Message property TeleporterRelayDishMissingInPowerGridMessage auto const mandatory
    Message property TeleporterRelayDishRepairNeededMessage auto const mandatory
    Message property TeleporterRelayDishPowerRequiredMessage auto const mandatory
    Message property TeleporterConsoleMissingInPowerGridMessage auto const mandatory
    Message property TeleporterConsoleRepairNeededMessage auto const mandatory
    Message property TeleporterConsolePowerRequiredMessage auto const mandatory
    Message property TeleporterConsoleAssignmentRequiredMessage auto const mandatory
    Message property TeleporterDestinationNotRespondingMessage auto const mandatory
    Message property TeleporterDestinationConfirmMessage auto const mandatory
    WorkshopParentScript property WorkshopParent auto const mandatory
    Spell property TeleportPlayerInSpell auto const mandatory
    Spell property TeleportPlayerOutSpell auto const mandatory
endgroup
group Teleporter
    float property fTeleportationTriggerDistance = 50.0 auto const
    float property fTeleporterionPrepareTime = 3.267 auto const
endgroup

ObjectReference workshopRef
ObjectReference activationTriggerRef
ObjectReference reflectorPlatformRef = none
ObjectReference relayDishRef = none
WorkshopObjectScript consoleRef = none

ObjectReference function FindRefWithSharedPowerGrid(Form akSearchKeyword, bool abIgnorePowerGridRequirement = false, float afSearchRadius = 16384.0)
    ObjectReference[] refs = self.FindAllReferencesWithKeyword(akSearchKeyword, afSearchRadius)
    int i = 0
    while (i < refs.Length)
        if (abIgnorePowerGridRequirement || self.HasSharedPowerGrid(refs[i]))
            return refs[i]
        endif
        i += 1
    endwhile
    return none
endfunction

function StartDistanceTracking(bool abEnter)
    if (abEnter)
        self.RegisterForDistanceLessThanEvent(self, Game.GetPlayer(), fTeleportationTriggerDistance)
    else
        self.RegisterForDistanceGreaterThanEvent(self, Game.GetPlayer(), fTeleportationTriggerDistance + 10.0)
    endif
endfunction
function StopDistanceTracking()
    self.UnregisterForDistanceEvents(self, Game.GetPlayer())
endfunction

function HandlePlayerEnterEvent()
endfunction
function HandlePlayerLeaveEvent()
endfunction
function HandleTimerEvent()
endfunction

function LookForTeleporterObjects()
    if (!reflectorPlatformRef)
        reflectorPlatformRef = FindRefWithSharedPowerGrid(WorkshopTeleporterReflectorPlatformKeyword, true, 10.0)
    endif
    if (!relayDishRef || !self.HasSharedPowerGrid(relayDishRef))
        relayDishRef = FindRefWithSharedPowerGrid(WorkshopTeleporterRelayDishKeyword)
    endif
    if (!consoleRef || !self.HasSharedPowerGrid(consoleRef))
        consoleRef = FindRefWithSharedPowerGrid(WorkshopTeleporterConsoleKeyword) as WorkshopObjectScript
    endif
endfunction
bool function CheckTeleporterRequirements(bool abAsDestination)
    bool usable = true

    if (self.IsDestroyed())
        usable = false
        TeleporterBeamEmitterRepairNeededMessage.Show()
    elseif (!self.IsPowered())
        usable = false
        TeleporterBeamEmitterPowerRequiredMessage.Show()
    endif

    if (!reflectorPlatformRef)
        usable = false
        if (!abAsDestination)
            TeleporterReflectorPlatformMissingInPowerGridMessage.Show()
        endif
    elseif (reflectorPlatformRef.IsDestroyed())
        usable = false
        if (!abAsDestination)
            TeleporterReflectorPlatformRepairNeededMessage.Show()
        endif
    endif

    if (!relayDishRef)
        usable = false
        if (!abAsDestination)
            TeleporterRelayDishMissingInPowerGridMessage.Show()
        endif
    elseif (relayDishRef.IsDestroyed())
        usable = false
        if (!abAsDestination)
            TeleporterRelayDishRepairNeededMessage.Show()
        endif
    elseif (!relayDishRef.IsPowered())
        usable = false
        if (!abAsDestination)
            TeleporterRelayDishPowerRequiredMessage.Show()
        endif
    endif

    if (!consoleRef)
        usable = false
        if (!abAsDestination)
            TeleporterConsoleMissingInPowerGridMessage.Show()
        endif
    elseif (consoleRef.IsDestroyed())
        usable = false
        if (!abAsDestination)
            TeleporterConsoleRepairNeededMessage.Show()
        endif
    elseif (!consoleRef.IsPowered())
        usable = false
        if (!abAsDestination)
            TeleporterConsolePowerRequiredMessage.Show()
        endif
    elseif (consoleRef.HasKeyword(WorkshopWorkObject) && !consoleRef.IsActorAssigned())
        usable = false
        if (!abAsDestination)
            TeleporterConsoleAssignmentRequiredMessage.Show()
        endif
    endif

    return usable
endfunction

state PlayerInWorkshopMode
    event OnEndState(string asNewState)
        LookForTeleporterObjects()
    endevent
endstate

state Unloaded
    event OnBeginState(string asOldState)
        StopDistanceTracking()
    endevent

    event OnLoad()
        ;Debug.MessageBox("TeleporterScript:OnLoad")
        self.GoToState("WaitForPlayer")
    endevent
endstate
state WaitForPlayer
    event OnBeginState(string asOldState)
        if (asOldState != "ShutdownTeleporter")
            StartDistanceTracking(true)
        endif
    endevent
    event OnEndState(string asNewState)
        StopDistanceTracking()
    endevent

    function HandlePlayerEnterEvent()
        if (CheckTeleporterRequirements(false))
            self.GoToState("PrepareTeleporter")
        else
            StartDistanceTracking(false)
        endif
    endfunction
    function HandlePlayerLeaveEvent()
        StartDistanceTracking(true)
    endfunction
endstate

state PrepareTeleporter
    event OnBeginState(string asOldState)
        StartDistanceTracking(false)
        self.StartTimer(fTeleporterionPrepareTime)
        if (asOldState != "ShutdownTeleporter")
            self.PlayAnimation("Powered")
        endif
    endevent
    event OnEndState(string asNewState)
        if (asNewState != "ReadyForTeleportation")
            StopDistanceTracking()
        endif
        self.CancelTimer()
    endevent

    function HandlePlayerLeaveEvent()
        self.GoToState("ShutdownTeleporter")
    endfunction
    function HandleTimerEvent()
        self.GoToState("ReadyForTeleportation")
    endfunction
endstate
state ShutdownTeleporter
    event OnBeginState(string asOldState)
        StartDistanceTracking(true)
        self.StartTimer(fTeleporterionPrepareTime)
    endevent
    event OnEndState(string asNewState)
        self.CancelTimer()
        if (asNewState != "PrepareTeleporter")
            self.PlayAnimation("Reset")
        endif
    endevent

    function HandlePlayerEnterEvent()
        self.GoToState("PrepareTeleporter")
    endfunction
    function HandleTimerEvent()
        self.GoToState("WaitForPlayer")
    endfunction
endstate
state ReadyForTeleportation
    event OnBeginState(string asOldState)
        if (asOldState != "PrepareTeleporter")
            StartDistanceTracking(false)
        endif
        activationTriggerRef.MoveTo(self)
        self.RegisterForRemoteEvent(activationTriggerRef, "OnActivate")
        activationTriggerRef.EnableNoWait()
    endevent
    event OnEndState(string asNewState)
        StopDistanceTracking()
        activationTriggerRef.DisableNoWait()
        self.UnregisterForRemoteEvent(activationTriggerRef, "OnActivate")
    endevent

    function HandlePlayerLeaveEvent()
        self.GoToState("ShutdownTeleporter")
    endfunction
endstate
state TeleportationInProgress
    event OnBeginState(string asOldState)
        Actor player = Game.GetPlayer()
        Location destination = player.OpenWorkshopSettlementMenuEx(none, TeleporterDestinationConfirmMessage, workshopRef.GetCurrentLocation(), WorkshopIncludeTeleporterList, abTurnOffHeader = true)
        if (destination && destination != workshopRef.GetCurrentLocation())
            Zebrina:Workshop:TeleporterScript destTeleporterRef = WorkshopParent.GetWorkshopFromLocation(destination).GetLinkedRef(WorkshopLinkTeleporterWorkshop) as Zebrina:Workshop:TeleporterScript
            if (destTeleporterRef && destTeleporterRef.CheckTeleporterRequirements(true))
                InputEnableLayer inputLayer = InputEnableLayer.Create()
                inputLayer.DisablePlayerControls(abCamSwitch = true)

                self.PlayAnimation("Stage3")

                Utility.Wait(1.0)

                self.RampRumble()

                Utility.Wait(1.0)

                self.PlayAnimationAndWait("Stage4", "End")
                self.PlayAnimation("Reset")
                player.AddSpell(TeleportPlayerOutSpell, false)

                Utility.Wait(4.0)

                ; Move player to node at the top of the platform.
                player.MoveTo(destTeleporterRef, afZOffset = 40.0, abMatchRotation = false)

                player.AddSpell(TeleportPlayerInSpell, false)

                Utility.Wait(2.0)

                inputLayer.EnablePlayerControls()
                inputLayer.Delete()
            else
                TeleporterDestinationNotRespondingMessage.Show()
            endif
        endif

        if (self.GetState() == "TeleportationInProgress")
            self.GoToState("ReadyForTeleportation")
        endif
    endevent
endstate

event ObjectReference.OnWorkshopMode(ObjectReference akSender, bool abStart)
    ;Debug.Notification("TeleporterScript:ObjectReference.OnWorkshopMode(" + abStart + ")")
    if (abStart)
        self.GoToState("PlayerInWorkshopMode")
    else
        self.GoToState("WaitForPlayer")
    endif
endevent

event OnDistanceLessThan(ObjectReference akObj1, ObjectReference akObj2, float afDistance)
    ;Debug.Notification("TeleporterScript:OnDistanceLessThan")
    HandlePlayerEnterEvent()
endevent
event OnDistanceGreaterThan(ObjectReference akObj1, ObjectReference akObj2, float afDistance)
    ;Debug.Notification("TeleporterScript:OnDistanceGreaterThan")
    HandlePlayerLeaveEvent()
endevent

event OnTimer(int aiTimerID)
    ;Debug.Notification("TeleporterScript:OnTimer(" + aiTimerID + ")")
    HandleTimerEvent()
endevent

event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
    ;Debug.Notification("TeleporterScript:ObjectReference.OnActivate")
    if (akActionRef == Game.GetPlayer())
        self.GoToState("TeleportationInProgress")
    endif
endevent

event OnPowerOn(ObjectReference akPowerGenerator)
    self.WaitForAnimationEvent("End")
    self.PlayAnimation("Reset")
endevent

event OnDestructionStageChanged(int aiOldStage, int aiCurrentStage)
    ; If we're destroyed the platform is going down with us...
    if (self.IsDestroyed() && reflectorPlatformRef)
        reflectorPlatformRef.DamageObject(300.0)
    endif
endevent

event OnUnload()
    ;Debug.Notification("TeleporterScript:OnUnload")
    self.GoToState("Unloaded")
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    ;Debug.MessageBox("TeleporterScript:OnWorkshopObjectPlaced")
    self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopMode")
    akWorkshopRef.SetLinkedRef(self, WorkshopLinkTeleporterWorkshop)
    akWorkshopRef.AddKeyword(WorkshopIncludeTeleporter)
    workshopRef = akWorkshopRef
    activationTriggerRef = self.PlaceAtMe(WorkshopTeleporterActivationTrigger)
    activationTriggerRef.DisableNoWait()
    self.GoToState("PlayerInWorkshopMode")
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
    StopDistanceTracking()
    self.UnregisterForAllRemoteEvents()

    if (workshopRef.GetLinkedRef(WorkshopLinkTeleporterWorkshop) == self)
        workshopRef.SetLinkedRef(none, WorkshopLinkTeleporterWorkshop)
        workshopRef.ResetKeyword(WorkshopIncludeTeleporter)
    endif
    workshopRef = none
    activationTriggerRef.DisableNoWait()
    activationTriggerRef.Delete()
    activationTriggerRef = none
    reflectorPlatformRef = none
    relayDishRef = none
    consoleRef = none
endevent

; DEBUG

; ScripObject override.
;/
function GoToState(String asState)
    Debug.MessageBox("Teleporter@\"" + self.GetCurrentLocation().GetName() + "\" going from state '" + self.GetState() + "' to '" + asState + "'")
    parent.GoToState(asState)
endfunction
/;
