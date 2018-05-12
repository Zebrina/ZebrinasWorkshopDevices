Scriptname DLC01:DLC01_MechanistDoorControlScript extends ObjectReference Hidden
{Script for the Mechanist Door Access Port. The player can command DLC01 Robots to interact with it; when used, it opens a series of Mechanist Doors.}
;
;Mechanist Door System Overview:
; - A system of Mechanist Doors consists of two Mechanist Door Controllers (objects with this script, one on each side),
;   and some number of Mechanist Doors (objects with the DLC01:DLC01_MechanistDoorScript).
; - These are linked together using the unnamed linked ref: [Controller 1] -> [Controller 2] -> [Door 1] - ...
; - The two Controllers are always kept in sync. The Primary Controller (the first one in the chain) uses this script to process events and state changes;
;   the Secondary one just forwards and receives events.


;Custom event sent by this script and received by its doors; triggers them to open or close.
;Since we have a couple of latent PlayAnimationAndWait calls that need to run simultaneously, we have to
;fork off events somewhere. This seemed like the cleanest choice.
CustomEvent SetMechanistDoorState


Group Autofill_Properties
	DLC01:DLC01LairQuestScript property DLC01Lair Auto Const Mandatory
	{The DLC01Lair quest script. All Controllers register with the quest, which occasionally needs to send commands to all of them.}

	Keyword property DLC01CanOpenMechanistDoorsKeyword Auto Const Mandatory
	{Only actors with this keyword can use a Controller. Will be applied to the player's robot via a quest-specific mod. For debug, you can throw it on the player.}

	Keyword property LinkCustom01 Auto Const Mandatory
	{LinkCustom01. Optionally, links the Primary Control to a chain of companionTeleportMarkers.}

	ReferenceAlias property Companion Auto Const Mandatory
	{Player's follower.}

	Scene property DLC01_PlayerMechDoorComment_RedOff Auto Const Mandatory
	{Player-voice scene to play when the player interacts with a Controller in the Red Off state. "The power is out."}

	Scene property DLC01_PlayerMechDoorComment_RedOn Auto Const Mandatory
	{Player-voice scene to play when the player interacts with a Controller in the Red On state. "My robot should use this."}

	Sound property DLC01DRSMechanistDoorControlOpen Auto Const Mandatory
	{Control Open Sound.}

	Sound property DLC01DRSMechanistDoorControlClose Auto Const Mandatory
	{Control Close Sound.}

	Sound property DLC01DRSMechanistDoorControlBeepDeny Auto Const Mandatory
	{Control Deny Beep.}

	Sound property DLC01DRSMechanistDoorControlBeepConfirm Auto Const Mandatory
	{Control Confirm Beep.}
EndGroup

Group Quest_Properties
	Quest property myQuest Auto Const
	{Quest to set a stage on when the control changes to GreenOn.}

	int property myStageToSet_GreenOnStart = -1 Auto Const
	{Stage to set when the control changes to GreenOn, before the doors have opened.}

	int property myStageToSet_GreenOnDone = -1 Auto Const
	{Stage to set when the control changes to GreenOn, after the doors have opened.}

	Scene property DLC01MasterQuest_MechanistDoorControlScenePlayerInitiated Auto Const Mandatory
	{On DLC01MasterQuest, a scene in which the player tells their robot to scan and open the door control.}

	Scene property DLC01MasterQuest_MechanistDoorControlSceneRobotInitiated Auto Const Mandatory
	{On DLC01MasterQuest, a scene in which the robot scans and opens the door control.}

	ReferenceAlias property DLC01MasterQuest_TargetMechanistDoorControlAlias Auto Const Mandatory
	{For DLC01MasterQuest's MechanistDoorControlScene, the 'Target' of the scene-- the Primary or Secondary Control the robot is scanning.}

	ReferenceAlias property DLC01MasterQuest_PrimaryMechanistDoorControlAlias Auto Const Mandatory
	{For DLC01MasterQuest's MechanistDoorControlScene, the Primary Control associated with the door system the Robot is interacting with. May be the same as TargetMechanistDoorControlAlias.}
EndGroup


bool property forceBlinking Auto Hidden
{Should we temporarily block the doors from opening? Used in some scripted sequences.}

;Local variables (Primary Controller only)
ObjectReference mySecondary						;The associated Secondary Controller.
DLC01:DLC01_MechanistDoorScript[] myDoors			;The array of Mechanist Doors controlled by this Controller. [The Primary Control's unnamed linked ref chain.]
ObjectReference[] companionTeleportMarkers			;If the player's companion has become stuck, fallen behind, or can't path to the control for some reason, an array of markers we can warp them to
											;for convenience (so the player doesn't have to go back and coax them along). [The Primary Control's LinkCustom01 ref chain.]
bool[] myDoorsDoneAnimating						;Array matching myDoors; has each door finished animating?
bool mySelfDoneAnimating							;Have we finished animating?
String pendingState = "StartRedOn"					;While changing states, the state we want to switch into once the Controller and Doors
											;have finally finished animating.
Actor player 									;Player ref.

; ADDED BY ZEBRINA
WorkshopScript property DLC01LairWorkshop_Workbench
	WorkshopScript function get()
		return Game.GetFormFromFile(0x000e4c, "DLCRobot.esm") as WorkshopScript
	EndFunction
endproperty

;---------------------------
;Load & Unload
;--------------

Event OnCellLoad()
	;Get our links.
	ObjectReference[] myLinks = Self.GetLinkedRefChain()
	if (myLinks.Length == 0)
		Debug.Trace("ERROR: " + Self + " had no linked refs; invalid.", 2)
		return
	ElseIf (myLinks[0].GetBaseObject() == Self.GetBaseObject())
		;If this object is linked to another Controller, it's the Primary Controller, and its first link is the Secondary Controller.
		mySecondary = myLinks[0]

		;We'll handle Activate events for the Secondary Controller.
		Self.RegisterForRemoteEvent(mySecondary, "OnActivate")

		;Remove the Secondary from the array. The remaining elements are our doors.
		myLinks.Remove(0)
		myDoors = myLinks as DLC01:DLC01_MechanistDoorScript[]

		;Initialize them.
		int i = 0
		While (i < myDoors.Length)
			if (myDoors[i] != None)
				myDoors[i].InitializeDoor(Self)
			EndIf
			i = i + 1
		EndWhile

		;Get our CompanionTeleportMarkers, if any.
		companionTeleportMarkers = Self.GetLinkedRefChain(LinkCustom01)

		;Store off the player.
		player = Game.GetPlayer()

		;Register for events from the DLC01Lair quest script.
		Self.RegisterForCustomEvent(DLC01Lair, "SetMechanistDoorControlState")

		;As a safety, if pendingState == None, set it to StartRedOn (to avoid breaking old saves).
		if ((pendingState == "") || (pendingState == "None"))
			pendingState = "StartRedOn"
		EndIf

		;Every time the cell loads, set the Controllers to the state they were last changing to. Most of the time, they'll already
		;be in this state and nothing will happen, but if the player left the cell while the state was changing, this should
		;resend the necessary animation events to finish out the state change.
		ChangeState(pendingState, True, True)
	EndIf
EndEvent


Event OnUnload()
	;On Unload, discard local refs.
	mySecondary = None
	myDoors = None
	myDoorsDoneAnimating = None
	companionTeleportMarkers = None
	player = None

	;Also cancel the RedBlinking state timer, if it was running.
	CancelTimer(1)
EndEvent


;---------------------------
;States
;-------
;These States previously handled their own OnActivate events, but it was cleaner to keep those together in a single function.
;These are set and checked by other functions, and I do need a state flag of some kind, so I've left them in.

Auto State Busy
	;BUSY STATE: The Controller or its doors are animating, so it's unsafe to accept new events.

	;Handle local or remote OnActivate events in this state.
	Function HandleOnActivate(ObjectReference akActivator, ObjectReference source, bool sourceIsPrimaryController)
		if ((akActivator == player) || (akActivator == Companion.GetActorRef()))
			;The door can't open at the moment. Play a negative adknowledgement sound.
			DLC01DRSMechanistDoorControlBeepDeny.Play(source)
		EndIf
	EndFunction
EndState

State RedOn
	;RED-ON STATE: The normal 'waiting for activation' state.

	;Handle local or remote OnActivate events in this state.
	Function HandleOnActivate(ObjectReference akActivator, ObjectReference source, bool sourceIsPrimaryController)
		if (akActivator == player)
			Actor companionActor = Companion.GetActorRef()
			if (akActivator.HasKeyword(DLC01CanOpenMechanistDoorsKeyword)) ;/ EDIT BY ZEBRINA /; || DLC01LairWorkshop_Workbench.OwnedByPlayer == true ;/ END OF EDIT BY ZEBRINA /;
				;For Debug: The player will not normally have this keyword, but if they do (because a debug stage was set),
				;just go ahead and open the door directly (no scene will play and no callback will be received).
				UseDoorControl(sourceIsPrimaryController)
			ElseIf (player.IsInScene())
				;If the player is in a running scene, we can't interrupt it. Just play a sound effect.
				DLC01DRSMechanistDoorControlBeepDeny.Play(source)
			ElseIf ((companionActor != None) && (companionActor.HasKeyword(DLC01CanOpenMechanistDoorsKeyword)))
				;If the player's follower is a robot with the keyword, start the door control scene.
				; - First, check to make sure they're within a reasonable distance of the door control. If not, they may have become stuck or had pathing
				;   problems. For convenience, we try to move them closer to the door if it's safe to do so, to let the player continue on more quickly.
				if (sourceIsPrimaryController && (companionActor.GetDistance(player) > 900) && (!player.HasDetectionLOS(companionActor)) && (companionTeleportMarkers != None))
					int i = 0
					bool movedCompanion = False
					While ((!movedCompanion) && (i < companionTeleportMarkers.Length))
						if (!player.HasDetectionLOS(companionTeleportMarkers[i]))
							companionActor.MoveTo(companionTeleportMarkers[i])
							movedCompanion = True
						EndIf
						i = i + 1
					EndWhile
				EndIf
				; - Then start the scene.
				StartDoorControlScene(True, sourceIsPrimaryController)
			Else
				;Otherwise, play a negative adknowledgement.
				DLC01DRSMechanistDoorControlBeepDeny.Play(source)
				;And play a player-voice scene commenting on the strange device.
				Utility.Wait(0.75)
				DLC01_PlayerMechDoorComment_RedOn.Start()
			EndIf
		ElseIf (akActivator.HasKeyword(DLC01CanOpenMechanistDoorsKeyword))
			;If the control is activated by a robot with the keyword, start the door control scene.
			StartDoorControlScene(False, sourceIsPrimaryController)
		EndIf
	EndFunction

	;Starts the player- or robot-initiated door control scene when called by HandleOnActivate, above.
	Function StartDoorControlScene(bool isPlayerInitiated, bool sourceIsPrimaryController)
		;Push the controls into the scene aliases.
		DLC01MasterQuest_PrimaryMechanistDoorControlAlias.ForceRefTo(Self)
		if (sourceIsPrimaryController)
			DLC01MasterQuest_TargetMechanistDoorControlAlias.ForceRefTo(Self)
		Else
			DLC01MasterQuest_TargetMechanistDoorControlAlias.ForceRefTo(mySecondary)
		EndIf

		;Start the appropriate scene.
		if (isPlayerInitiated)
			DLC01MasterQuest_MechanistDoorControlScenePlayerInitiated.Start()
		Else
			DLC01MasterQuest_MechanistDoorControlSceneRobotInitiated.Start()
		EndIf

		;And wait for the UseDoorControl callback to actually open the door.
	EndFunction


	;HandleOnActivate starts a scanning scene. If the scene completes successfully, it calls back to this function,
	;which uses the control to open the door. (If the scene fails, the player can have the robot activate the control
	;again to restart it.)
	Function UseDoorControl(bool sourceIsPrimaryController)
		ChangeState("GreenOn", sourceIsPrimaryController)
	EndFunction
EndState


State GreenOn
	;GREEN-ON STATE: The normal 'open' state. The Controller was activated, and its doors have opened.

	Event OnBeginState(String asOldState)
		if ((myQuest != None) && (myStageToSet_GreenOnDone >= 0))
			myQuest.SetStage(myStageToSet_GreenOnDone)
		EndIf
	EndEvent

	;Handle local or remote OnActivate events in this state.
	Function HandleOnActivate(ObjectReference akActivator, ObjectReference source, bool sourceIsPrimaryController)
		if ((akActivator == player) || (akActivator == Companion.GetActorRef()))
			;The doors are already open. Just play the positive adknowledgement sound.
			;DLC01DRSMechanistDoorControlBeepConfirm.Play(source)

			; EDIT BY ZEBRINA
			; If Mechanist's Lair workshop is not yet owned - do the old stuff.
			; If it is owned - close the door.
			if (DLC01LairWorkshop_Workbench.OwnedByPlayer == true)
				ChangeState("RedOn", sourceIsPrimaryController)
			else
				DLC01DRSMechanistDoorControlBeepConfirm.Play(source)
			endif
			; END OF EDIT BY ZEBRINA
		EndIf
	EndFunction
EndState


State RedOff
	;RED-OFF STATE: Special state: The power is out.

	;Handle local or remote OnActivate events in this state.
	Function HandleOnActivate(ObjectReference akActivator, ObjectReference source, bool sourceIsPrimaryController)
		if ((akActivator == player) || (akActivator == Companion.GetActorRef()))
			if (!player.IsInScene())
				;The power is out. No sound effects, but play the power out player-voice response scene.
				DLC01_PlayerMechDoorComment_RedOff.Start()
			Else
				;If the player is busy, play a negative adknowledgement sound.
				DLC01DRSMechanistDoorControlBeepDeny.Play(source)
			EndIf
		EndIf
	EndFunction
EndState


State RedBlinking
	;RED BLINKING: Special state: The player activated the Controller, but it isn't safe to open yet.
	;This state runs a timer that periodically calls ChangeState in an attempt to open the door. If the
	;check fails, ChangeState restarts this state, which restarts the timer.

	Event OnBeginState(String asOldState)
		StartTimer(1, 1)
	EndEvent

	Event OnEndState(String asNewState)
		CancelTimer(1)
	EndEvent

	Event OnTimer(int timerID)
		ChangeState("GreenOn")
	EndEvent

	;Handle local or remote OnActivate events in this state.
	Function HandleOnActivate(ObjectReference akActivator, ObjectReference source, bool sourceIsPrimaryController)
		if ((akActivator == player) || (akActivator == Companion.GetActorRef()))
			;The door can't open at the moment. Play a negative adknowledgement sound.
			DLC01DRSMechanistDoorControlBeepDeny.Play(source)
		EndIf
	EndFunction
EndState


;-------------------------------------
;Activation & State Changes
;---------------------------

;The Primary Controller handles its own activation events.
Event OnActivate(ObjectReference akActivator)
	HandleOnActivate(akActivator, Self, True)
EndEvent

;Activation events from the Secondary Controller are handled by the Primary Controller.
Event ObjectReference.OnActivate(ObjectReference source, ObjectReference akActivator)
	HandleOnActivate(akActivator, source, False)
EndEvent

;HandleOnActivate is handled based on the current state, above.
Function HandleOnActivate(ObjectReference akActivator, ObjectReference source, bool sourceIsPrimaryController)
EndFunction

;In state RedOn, starts the door control scene.
Function StartDoorControlScene(bool isPlayerInitiated, bool sourceIsPrimaryController)
	Debug.Trace("ERROR: UseDoorControl called on " + Self + " in state " + GetState(), 2)
EndFunction

;In state RedOn, HandleOnActivate starts a scene where the robot moves to the door control and scans it. The scene
;calls back to this function to 'use' the door control to open the door. (This function should never be called in any other state.)
Function UseDoorControl(bool sourceIsPrimaryController)
	Debug.Trace("ERROR: UseDoorControl called on " + Self + ", but it was not in the RedOn state, so the call is invalid.", 2)
EndFunction

;We may also need to change state in response to events from the quest script.
;args[0] will be the string name of the state to change to.
Event DLC01:DLC01LairQuestScript.SetMechanistDoorControlState(DLC01:DLC01LairQuestScript akSender, Var[] args)
	ChangeState(args[0] as String)
EndEvent

;Change the state of the Controller and its doors.
Function ChangeState(String newState, bool sourceIsPrimaryController = True, bool isInitializing = False)
	;Check for edge cases.
	String oldState = GetState()

	;If we're doing our OnCellLoad initialization, ignore the normal safety checks and call the animation events anyway.
	;We need to do this in case, say, some of the doors are open and some are closed because their 3D unloaded before
	;they received their PlayAnimation events.
	if (!isInitializing)
		if ((oldState == "Busy") && (newState != "StartRedOn"))
			Debug.Trace("ERROR: ChangeState was called on " + Self + " while it was in the busy state. Ignoring.", 2)
			return
		EndIf
	EndIf

	;Shift to the Busy state until the Controllers and their doors have finished animating.
	GoToState("Busy")

	;Record the state we want to end up in once the Controllers and their doors have finished animating.
	pendingState = newState

	;We're about to start animating.
	mySelfDoneAnimating = False

	;The animation graph for this is... complicated.
	if (newState == "StartRedOn")
		;In this case, we want to end up in RedOn, not StartRedOn, when we're done.
		pendingState = "RedOn"
		ChangeDoorState(False, sourceIsPrimaryController)
		mySecondary.PlayAnimation("StartOnRed01")
		Self.PlayAnimation("StartOnRed01")
		mySelfDoneAnimating = True
		CheckForAllAnimationsDone()
	ElseIf (newState == "RedOn")
		ChangeDoorState(False, sourceIsPrimaryController)
		if (oldState == "GreenOn")
			PlayDoorControlSound(DLC01DRSMechanistDoorControlClose, sourceIsPrimaryController)
			mySecondary.PlayAnimation("Play01")
			Self.PlayAnimationAndWait("Play01", "Done")
		Else
			mySecondary.PlayAnimation("StartOnRed01")
			Self.PlayAnimation("StartOnRed01")
		EndIf
		mySelfDoneAnimating = True
		CheckForAllAnimationsDone()
	ElseIf (newState == "GreenOn")
		if (oldState == "GreenOn")
			mySecondary.PlayAnimation("StartOnGreen01")
			Self.PlayAnimation("StartOnGreen01")
			ChangeDoorState(True, sourceIsPrimaryController)
			mySelfDoneAnimating = True
			CheckForAllAnimationsDone()
		ElseIf (forceBlinking || player.IsInCombat() || ((Companion.GetActorRef() != None) && (Companion.GetActorRef().IsInCombat())))
			;Check to see if we can open safely. If not, we go to RedBlinking instead.
			GoToState(oldState)
			ChangeState("RedBlinking")
		Else
			PlayDoorControlSound(DLC01DRSMechanistDoorControlOpen, sourceIsPrimaryController)
			mySecondary.PlayAnimation("Play01")
			Self.PlayAnimationAndWait("Play01", "Done")
			PlayDoorControlSound(DLC01DRSMechanistDoorControlBeepConfirm, sourceIsPrimaryController)
			Utility.Wait(0.75)
			if ((myQuest != None) && (myStageToSet_GreenOnStart >= 0))
				myQuest.SetStage(myStageToSet_GreenOnStart)
			EndIf
			ChangeDoorState(True, sourceIsPrimaryController)
			mySelfDoneAnimating = True
			CheckForAllAnimationsDone()
		EndIf
	ElseIf (newState == "RedOff")
		ChangeDoorState(False, sourceIsPrimaryController)
		if (oldState == "RedOff")
			mySecondary.PlayAnimation("StartOffRed01")
			Self.PlayAnimation("StartOffRed01")
		ElseIf (oldState == "GreenOn")
			PlayDoorControlSound(DLC01DRSMechanistDoorControlClose, sourceIsPrimaryController)
			mySecondary.PlayAnimation("Play01")
			Self.PlayAnimationAndWait("Play01", "Done")
			mySecondary.PlayAnimation("OffRed01")
			Self.PlayAnimation("OffRed01")
		ElseIf (oldState == "RedBlinking")
			mySecondary.PlayAnimation("OnRed01")
			Self.PlayAnimation("OnRed01")
			mySecondary.PlayAnimation("OffRed01")
			Self.PlayAnimation("OffRed01")
		EndIf
		mySelfDoneAnimating = True
		CheckForAllAnimationsDone()
	ElseIf (newState == "RedBlinking")
		ChangeDoorState(False, sourceIsPrimaryController)
		if (oldState == "RedBlinking")
			mySecondary.PlayAnimation("StartBlinkRed01")
			Self.PlayAnimation("StartBlinkRed01")
		ElseIf (oldState == "GreenOn")
			PlayDoorControlSound(DLC01DRSMechanistDoorControlClose, sourceIsPrimaryController)
			mySecondary.PlayAnimation("Play01")
			Self.PlayAnimationAndWait("Play01", "Done")
			mySecondary.PlayAnimation("BlinkRed01")
			Self.PlayAnimation("BlinkRed01")
		ElseIf (oldState == "RedOff")
			PlayDoorControlSound(DLC01DRSMechanistDoorControlBeepConfirm, sourceIsPrimaryController)
			mySecondary.PlayAnimation("OnRed01")
			Self.PlayAnimation("OnRed01")
			mySecondary.PlayAnimation("BlinkRed01")
			Self.PlayAnimation("BlinkRed01")
		EndIf
		mySelfDoneAnimating = True
		CheckForAllAnimationsDone()
	Else
		Debug.Trace("ERROR: ChangeState was called on " + Self + " with unrecognized state " + newState, 2)
		GoToState(oldState)
		return
	EndIf
EndFunction

;Plays the specified sound from the Primary Controller or the Secondary Controller, whichever is the current source.
Function PlayDoorControlSound(Sound mySound, bool sourceIsPrimaryController)
	if (sourceIsPrimaryController)
		mySound.Play(Self)
	Else
		mySound.Play(mySecondary)
	EndIf
EndFunction

;Fires the custom event that opens or closes all of the Mechanist Doors associated with this Controller.
Function ChangeDoorState(bool shouldOpen, bool sourceIsPrimaryController)
	;Set up a new myDoorsDoneAnimating array for use by DoorDone and WaitFor
	myDoorsDoneAnimating = new bool[myDoors.Length]
	Var[] args = new Var[2]
	args[0] = shouldOpen
	args[1] = sourceIsPrimaryController
	SendCustomEvent("SetMechanistDoorState", args)
EndFunction

;When each door finishes its animation, we get a callback so we can record that it's done.
Function DoorDone(DLC01:DLC01_MechanistDoorScript mechDoor)
	int index = myDoors.Find(mechDoor)
	if (index < 0)
		Debug.Trace("ERROR: DoorDone called with " + mechDoor + ", which isn't one of its doors.", 2)
	Else
		myDoorsDoneAnimating[index] = True
	EndIf
	CheckForAllAnimationsDone()
EndFunction

;After the Controllers finish animating, and after each door finishes animating, check to see if we're done.
Function CheckForAllAnimationsDone()
	;If the Controllers have finished animating...
	if (mySelfDoneAnimating)
		;And all of the doors have finished animating...
		bool allDoorsDoneAnimating = True
		int i = 0
		While (allDoorsDoneAnimating && (i < myDoorsDoneAnimating.Length))
			allDoorsDoneAnimating = myDoorsDoneAnimating[i]
			i = i + 1
		EndWhile
		if (allDoorsDoneAnimating)
			;Then we've finished changing state.
			GoToState(pendingState)
		EndIf
	EndIf
EndFunction


;-----------------------
;Other Functions
;----------------

;Set or clear the forceBlinking bool. If set, temporarily blocks the doors from opening, forcing the
;Controller into the Red Blinking state instead.
Function ForceBlinking(bool shouldForceBlinking)
	forceBlinking = shouldForceBlinking
EndFunction
