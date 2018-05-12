Scriptname DLC05:DLC05WorkshopElevatorScript extends ObjectReference
{This script manages the various workshop elevators}

Message Property DLC05_ElevatorRequiresPowerMessage Auto Const Mandatory

;All of these should be set except for ButtonRef
;	which will be filled by the script when it places the button
Struct ButtonData
	Activator Button
	String Node
	Keyword LinkKeyword
	bool AttachToTrack
EndStruct

ButtonData[] Property MyButtons Auto
{This array stores all the data for the buttons}

Group AnimNames CollapsedOnRef
	String[] Property FloorAnims Auto Const mandatory
	{This array stores Floors anim strings
		they should be 1 lower in index than the floor number
		EG: Index 0 == Level01}
	String Property Done = "Done" Auto Const Hidden
EndGroup

Struct NavCutData
	String Node
	Keyword LinkKeyword
EndStruct

Group NavCut
	NavCutData[] Property NavCuts Auto Const Mandatory
	Activator Property DLC05ElevatorNavCut Auto Const Mandatory
EndGroup
;The elevators have nodes baked in for where to place the Navcut object
;	The node names should be as follows
;		NavCutterNode01-04

float property fSpeedMult = 1.0 auto hidden

;Here we place our buttons, store pointers to them
;		and tell them that this is their elevator
Event OnCellAttach()
	;RemoveAllButtons()

	Debug.Trace(Self + ": OnCellAttach")
	PlaceButtons()
	BlockActivation(abBlocked = True, abHideActivateText = true)
EndEvent

; Should fix the elevator buttons bug.
event OnLoad()
	if (buttonsPlaced)
		int i = 0
		while (i < MyButtons.Length)
			ObjectReference buttonRef = self.GetLinkedRef(MyButtons[i].LinkKeyword)
			if (buttonRef)
				buttonRef.MoveToNode(self, MyButtons[i].Node)
			endif
			i += 1
		endwhile
	endif
endevent

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	;RemoveAllButtons()

	Debug.Trace(Self + ": OnWorkshopObjectPlaced")
	PlaceButtons()
	PlaceNavCuts()
	BlockActivation(abBlocked = True, abHideActivateText = true)
EndEvent

;/
Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
	RemoveAllButtons()
EndEvent
/;

Event OnWorkshopObjectGrabbed(ObjectReference akReference)
	SetCallButtonsOff(true)
	SetNavCutOff(true)
EndEvent

Event OnWorkshopObjectMoved(ObjectReference akReference)
	SetCallButtonsOff(false)
	SetNavCutOff(false)
EndEvent


int CurrentFloor = 1

Auto State Ready

	Event OnEndState(string asNewState)
		;Debug.TraceStack()
	EndEvent
EndState


State Busy
	;This should return true because the elevator is busy
	bool Function GoToFloor(int floorToGoTo = 1)
		Debug.Trace(self + ": was in state >> Busy")
		return true
	EndFunction
EndState

;This should return false, because we are not in the busy state
bool Function GoToFloor(int floorToGoTo = 1)
	Debug.Trace(self + ": GoToFloor >> " + floorToGoTo)
	GoToState("Busy")
	if IsPowered()
		DoFloorChange(floorToGoTo)
	else
		DLC05_ElevatorRequiresPowerMessage.Show()
	endif
	GoToState("Ready")
	return false
EndFunction

;This does the actual floor change
Function DoFloorChange(int floorToGoTo)
	if floorToGoTo != CurrentFloor
		; Adjust elevator speed based on which floor we are going to and from.
		float deltaFloor = Math.Abs((floorToGoTo - CurrentFloor) as float)
		float currentSpeedAnimVar = self.GetAnimationVariableFloat("fSpeed")
		self.SetAnimationVariableFloat("fSpeed", (currentSpeedAnimVar * (deltaFloor / 3.0)) / fSpeedMult)

		;The floor anim is floor number - 1 because arrays start at 0
		Debug.Trace(self + ": FloorAnim to play == " + FloorAnims[(floorToGoTo - 1)])
		PlayAnimationAndWait(FloorAnims[(floorToGoTo - 1)], Done)
		;SetButtonsFree()
		CurrentFloor = floorToGoTo
		SyncNavCutFloor()

		; Restore elevator speed.
		self.SetAnimationVariableFloat("fSpeed", currentSpeedAnimVar)
	endif
EndFunction

Event OnPowerOn(ObjectReference akPowerGenerator)
	PlayAnimation("LightOn01")
	PowerButtons(true)
EndEvent

Event OnPowerOff()

	PlayAnimation("LightOff01")
	PowerButtons(false)
EndEvent

;If we have these buttons, set their power state
Function PowerButtons(bool shouldBePowered)
	int i = 0
	int Count = MyButtons.Length

	While i < Count
		(GetLinkedRef(MyButtons[i].LinkKeyword) as DLC05:DLC05WorkshopElevatorButtonScript).SetHasPower(shouldBePowered)
		i += 1
	EndWhile
EndFunction


bool buttonsPlaced = false
Function PlaceButtons()
	if !buttonsPlaced
		buttonsPlaced = true
		int i = 0
		int Count = MyButtons.Length
		ObjectReference currentButton
		While i < Count
			;If this button should be attached to the track
			; This does NOT get "attached" so it won't move with the car
			; These have to be disabled and moved when the elevator is moved in workshop
            if MyButtons[i].AttachToTrack
           	 currentButton = PlaceAtNode(MyButtons[i].Node, MyButtons[i].Button, aiCount = 1, abForcePersist = false, abInitiallyDisabled = false, abDeleteWhenAble = true, abAttach = false)
            else        ;If this button should be attached to the Car
       	     currentButton = PlaceAtNode(MyButtons[i].Node, MyButtons[i].Button, aiCount = 1, abForcePersist = false, abInitiallyDisabled = false, abDeleteWhenAble = true, abAttach = true)
            endif
			currentButton.SetLinkedRef(Self)
			SetLinkedRef(CurrentButton, MyButtons[i].LinkKeyword)
			CurrentButton.RegisterForRemoteEvent(self, "OnWorkshopObjectDestroyed")
			i += 1
		EndWhile

		;Set Our buttons to match our power setting
		PowerButtons(IsPowered())

	endif
EndFunction

Function PlaceNavCuts()
	Debug.Trace(self + ": PlaceNavCuts")
	int i = 0
	int count = NavCuts.Length
	ObjectReference CurrentNavCutObject
	while i < Count
		CurrentNavCutObject = PlaceAtNode(NavCuts[i].Node, DLC05ElevatorNavcut, aiCount = 1, abForcePersist = false, abInitiallyDisabled = false, abDeleteWhenAble = true, abAttach = false)
		CurrentNavCutObject.RegisterForRemoteEvent(self, "OnWorkshopObjectDestroyed")
		SetLinkedRef(CurrentNavCutObject, NavCuts[i].LinkKeyword)
		Debug.Trace(self + "::: NavcutObject " + i + " -> " + CurrentNavCutObject)
		i += 1
	EndWhile
	Debug.Trace(self + "::: PlaceNavCuts")
	SyncNavCutFloor()
EndFunction

Function SyncNavCutFloor()
	Debug.Trace(self + ": SyncNavCutFloor")
	int i = 0
	int count = NavCuts.Length
	ObjectReference CurrentNavCutObject
	while i < Count
		CurrentNavCutObject = GetLinkedRef(NavCuts[i].LinkKeyword)
		if (i + 1) == CurrentFloor 		;If this is the current floor
			Debug.Trace(self + ": Disabling -> " + CurrentNavCutObject)
			;Disable the nav cut object so navmesh should be enabled here
			CurrentNavCutObject.Disable()
		else
			Debug.Trace(self + ": Enabling -> " + CurrentNavCutObject)
			;If this is NOT the current floor, enable the navcut object to disable navmesh for this floor
			CurrentNavCutObject.Enable()
		endif
		i += 1
	EndWhile
EndFunction

;The two functions below are to handle the buttons and Navcut objects
; Currently only one Attachref Node is supported
; so objects that are not attached to the elevator car are just placed and moved manually

Function SetCallButtonsOff(bool TurnButtonsOff)
	int i = 0
	int Count = MyButtons.Length
	ObjectReference CurrentButton
	While i < Count
		;This only counts on buttons "attached" to the track, not the car
		if MyButtons[i].AttachToTrack
			CurrentButton = GetLinkedRef(MyButtons[i].LinkKeyword)
			if TurnButtonsOff
				CurrentButton.DisableNoWait(abFadeout = false)
			else
				CurrentButton.MoveToNode(self, MyButtons[i].Node)
				CurrentButton.EnableNoWait(abFadeIn = false)
			endif
			;(CurrentButton as DLC05:DLC05WorkshopElevatorButtonScript).SetButtonFree()
		endif
		i += 1
	EndWhile
EndFunction

Function SetNavCutOff(bool TurnOffNavcuts)
	Debug.Trace(self + ": SetNavCutOff -> " + TurnOffNavcuts)
	;This handles moving the navcut objects to the elevator when you move it
	int i = 0
	int count = NavCuts.Length
	ObjectReference CurrentNavCutObject
	while i < Count
		CurrentNavCutObject = GetLinkedRef(NavCuts[i].LinkKeyword)
		;This is used when the object is grabbed
		if TurnOffNavcuts
			CurrentNavCutObject.Disable()
		else
			;this is used when the object is placed
			CurrentNavCutObject.MoveToNode(self, NavCuts[i].Node)
			if (i + 1) == CurrentFloor
				CurrentNavCutObject.Disable()
			else
				CurrentNavCutObject.Enable()
			endif
		endif
		i += 1
	EndWhile
EndFunction
