scriptname Zebrina:Workshop:RobotLiftScript extends DLC01:DLC01_RobotLiftScript

customevent ToggleLights

struct SpawnedRobot
    LeveledActor Robot
    Quest RequiredQuest = none
    { Used by the configuration terminal. }
    int RequiredQuestStage = 0
    { Used by the configuration terminal. }
endstruct

group Autofill_Properties
    Activator property WorkshopRobotLiftLight auto const
    { Clear for no lights. }
    Form property DLC01AMBIntAlarmRobotLift2DLPMmarker auto const mandatory
endgroup

group RobotLift
    SpawnedRobot[] property SpawnedRobots auto const mandatory
endgroup
group Configurable
    int property iSpawnedRobotIndex = 0 auto
endgroup

Actor spawnedRobotRef = none

; DLC01:DLC01_RobotLiftScript override.
event OnActivate(ObjectReference akActionRef)
    ; Do nothing.
    ; FOR TESTING!
    ;PlaceAndRun(SpawnedRobots[iSpawnedRobotIndex].Robot)
endevent

event Actor.OnCombatStateChanged(Actor akSender, Actor akTarget, int aeCombatState)
    if (aeCombatState == 1)
        ;PlaceAndRun(SpawnedRobots[iSpawnedRobotIndex].Robot)
    endif
endevent

function EnableLights(bool abEnable = true)
endfunction

event OnAnimationEvent(ObjectReference akSource, string asEventName)
    if (asEventName == "Open")
        if (spawnedRobotRef)
            spawnedRobotRef.SetUnconscious(false)
        endif
    elseif (asEventName == "Stop01")
        EnableLights(false)
    elseif (asEventName == "Done")
        self.GoToState("Ready")
        ;/
        if (myQueue.Length > 0)
            OnAnimationEvent(akSource, "Open")
            DoPlaceObject(myQueue[0])
            myQueue.Remove(0)
            Self.SetAnimationVariableFloat("fspeed", Speed)
            Self.PlayAnimation("Play01")
            myLightsActive = True
            StartTimer(0, CONST_LightsTimer)
        Else
            GoToState("Ready")
        EndIf
        /;
    endif
endevent

event OnLoad()
    self.WaitFor3DLoad()
    self.RegisterForAnimationEvent(self, "Open")    ; Trapdoor is starting to open.
	self.RegisterForAnimationEvent(self, "Stop01")  ; Trapdoor has finished closing.
    self.RegisterForAnimationEvent(self, "Done")    ; Platform has reset and is ready to go again.
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    ;self.BlockActivation(true, false)

    ; Sound marker.
    ObjectReference soundMarkerRef = self.PlaceAtNode("SOUND_NODE", DLC01AMBIntAlarmRobotLift2DLPMmarker, abInitiallyDisabled = true, abAttach = true)
    soundMarkerRef.DisableNoWait()
    self.SetLinkedRef(soundMarkerRef, DLC01RobotLiftSoundLink)

    self.RegisterForRemoteEvent(Game.GetPlayer(), "OnCombatStateChanged")

    ; Do the default initialization.
    ;self.OnCellLoad()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
    ; Sound marker.
    self.GetLinkedRef(DLC01RobotLiftSoundLink).Delete()
    ; Spawn marker.
    ;mySpawnMarker.Delete()
endevent

function DoPlaceObject(Form objectToPlace, int actorLevelMod = 1)
    spawnedRobotRef = DLC01_LiftSpawnPoint.PlaceAtMe(objectToPlace) as Actor
    if (spawnedRobotRef)
        Debug.MessageBox(spawnedRobotRef)
        spawnedRobotRef.SetUnconscious()
        spawnedRobotRef.MoveToNode(self, "RobotPlacementNode")
        spawnedRobotRef.SetAngle(0.0, 0.0, self.GetAngleZ())
    	spawnedRobotRef.WaitFor3DLoad()
    endif
endfunction
