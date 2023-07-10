scriptname Zebrina:Workshop:PowerLiftMiniCartScript extends ObjectReference conditional

import Zebrina:WorkshopUtility

group AutoFill
	Keyword property WorkshopLinkPowerLift auto const mandatory
	GlobalVariable property PowerLiftFloorCount auto const mandatory
	Message property PowerLiftSelectFloorDialogue auto const mandatory
endgroup
group PowerLift
	Activator property PrimaryCallButtonBaseObject auto const mandatory
	string property sPrimaryCallButtonAttachNode = "CallButtonNode" auto const
	Activator property MoveButtonBaseObject auto const mandatory
	string property sMoveButtonAttachNode = "MoveButtonNode" auto const
	float property fCartPositionZOffset = 16.0 auto const
	float property fFullDistanceZ = 4096.0 auto const
	float property fFullAnimationDuration = 53.333 auto const
	float property fCartPushOutDuration = 0.0 auto const
	Activator property PlayerOnElevatorTrigger = none auto const
endgroup
group PowerLiftConfigurable
	float property fLiftSpeedMult = 1.0 auto conditional
endgroup

; Conditionals
bool bCartMoving = false conditional

ObjectReference kPrimaryCallButton
ObjectReference kMoveButton
ObjectReference playerOnElevatorTriggerRef = none

float function GetLiftSpeed(ObjectReference akTargetLift)
	return akTargetLift.GetAnimationVariableFloat("fSpeed")
endfunction
float function SetLiftSpeed(ObjectReference akTargetLift, float afSpeed)
	akTargetLift.SetAnimationVariableFloat("fSpeed", afSpeed)
endfunction
float function GetLiftLevel(ObjectReference akTargetLift)
	return akTargetLift.GetAnimationVariableFloat("fValue")
endfunction
float function SetLiftLevel(ObjectReference akTargetLift, float afValue)
	akTargetLift.SetAnimationVariableFloat("fValue", afValue)
endfunction
float function GetLiftSpeedMult()
	if (fLiftSpeedMult <= 0.0)
		return 1.0
	endif
	return 1.0 / fLiftSpeedMult
endfunction

float function GetCartPositionZMax()
	return self.z + fCartPositionZOffset
endfunction
float function GetCartPositionZMin()
	return GetCartPositionZMax() - fFullDistanceZ
endfunction
float function GetCartPositionZ()
	return GetCartPositionZMax() - (GetLiftLevel(self) * fFullDistanceZ)
endfunction

float function GetLiftPositionPercentage(float afPositionZ)
	float posZMax = GetCartPositionZMax()
	if (afPositionZ > posZMax)
		return 1.0
	elseif (afPositionZ < GetCartPositionZMin())
		return 0.0
	endif
	return (posZMax - afPositionZ) / fFullDistanceZ
endfunction

function MoveCartInternal(ObjectReference akTargetLift, float afSpeed, float afValue, bool abWait = true)
	SetLiftSpeed(akTargetLift, afSpeed)
	SetLiftLevel(akTargetLift, afValue)
	if (abWait)
		akTargetLift.PlayAnimationAndWait("Play01", "Done")
	else
		akTargetLift.PlayAnimation("Play01")
	endif
endfunction
function MoveCartToLevel(float afLevelPercentage)
	float currentHeight = GetLiftLevel(self)
	if (afLevelPercentage != currentHeight)
		MoveCartInternal(self, Math.Abs(currentHeight - afLevelPercentage) * (fFullAnimationDuration - fCartPushOutDuration) * GetLiftSpeedMult(), afLevelPercentage)
	endif
endfunction
function MoveCartToPositionZ(float afPositionZ)
	if (afPositionZ <= GetCartPositionZMax())
		float moveToHeight = GetLiftPositionPercentage(afPositionZ)
		float currentHeight = GetLiftLevel(self)
		if (moveToHeight != currentHeight)
			MoveCartInternal(self, Math.Abs(currentHeight - moveToHeight) * (fFullAnimationDuration - fCartPushOutDuration) * GetLiftSpeedMult(), moveToHeight)
		endif
	endif
endfunction
function MoveCartToReference(ObjectReference akReference)
	MoveCartToPositionZ(akReference.GetPositionZ())
endfunction

ObjectReference[] function GetCallButtonArray()
	ObjectReference[] refs = self.GetRefsLinkedToMe(WorkshopLinkPowerLift)
	if (refs.Length > 1)
		SortCallButtonArray(refs, 0, refs.Length - 1)
	endif
	return refs
endfunction
; Quicksort, Hoare partition scheme.
; Sorts from low to high z position.
function SortCallButtonArray(ObjectReference[] arrCallButtons, int aiStart, int aiEnd)
	if (aiStart < aiEnd)
		int partition = SortCallButtonArrayPartition(arrCallButtons, aiStart, aiEnd)
		SortCallButtonArray(arrCallButtons, aiStart, partition)
		SortCallButtonArray(arrCallButtons, partition + 1, aiEnd)
	endif
endfunction
int function SortCallButtonArrayPartition(ObjectReference[] arrCallButtons, int aiStart, int aiEnd)
	ObjectReference pivot = arrCallButtons[aiStart]
	int i = aiStart - 1
	int j = aiEnd + 1
	while (true)
		i += 1
		while (arrCallButtons[i].z < pivot.z)
			i += 1
		endwhile

		j -= 1
		while (arrCallButtons[j].z > pivot.z)
			j -= 1
		endwhile

		if (i >= j)
			return j
		endif

		ObjectReference temp = arrCallButtons[i]
		arrCallButtons[i] = arrCallButtons[j]
		arrCallButtons[j] = temp
	endwhile
endfunction

function HandleActivation(ObjectReference akSender, ObjectReference akActionRef)
	if (bCartMoving == false && IsPlayerActionRef(akActionRef))
		bCartMoving = true
		if (akSender == kMovebutton)
			ObjectReference[] callButtons = GetCallButtonArray()
			if (callButtons.Length == 1)
				; If just two levels there's no point in showing the floor selection dialogue.
				if (GetLiftLevel(self) == 0.0)
					MoveCartToPositionZ(callButtons[0].z)
				else
					MoveCartToLevel(0.0)
				endif
			elseif (callButtons.Length > 1)
				; Show floor selection dialogue.
				PowerLiftFloorCount.SetValueInt(1 + callButtons.Length)
				int selection = PowerLiftSelectFloorDialogue.Show()
				if (selection != 19)
					MoveCartToPositionZ(callButtons[selection].z)
				else
					MoveCartToLevel(0.0)
				endif
			endif
		elseif (akSender == kPrimaryCallButton)
			MoveCartToLevel(0.0)
		else
			MoveCartToPositionZ(akSender.z)
		endif
		bCartMoving = false
	endif
endfunction
event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
	HandleActivation(akSender, akActionRef)
endevent

function Initialize()
	if (!kPrimaryCallButton)
		kPrimaryCallButton = self.PlaceAtNode(sPrimaryCallButtonAttachNode, PrimaryCallButtonBaseObject)
		self.RegisterForRemoteEvent(kPrimaryCallButton, "OnActivate")
	endif

	if (!kMoveButton)
		kMoveButton = self.PlaceAtNode(sMoveButtonAttachNode, MoveButtonBaseObject, abAttach = true)
		self.RegisterForRemoteEvent(kMoveButton, "OnActivate")
	endif

	if (PlayerOnElevatorTrigger && !playerOnElevatorTriggerRef)
		playerOnElevatorTriggerRef = self.PlaceAtNode("PlayerOnElevatorTriggerNode", PlayerOnElevatorTrigger, abAttach = true)
	endif
endfunction

event OnCellLoad()
	; Fix elevator bug pls?
	if (!self.IsDisabled() && kMoveButton)
		kMoveButton.Disable(false)
		Utility.Wait(0.1)
		kMoveButton.MoveToNode(self, sMoveButtonAttachNode)
		kMoveButton.Enable(false)
	endif
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
	Initialize()
endevent

event OnWorkshopObjectGrabbed(ObjectReference akWorkshopRef)
	kPrimaryCallButton.DisableNoWait(false)
endevent

event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
	kPrimaryCallButton.MoveToNode(self, sPrimaryCallButtonAttachNode)
	kPrimaryCallButton.EnableNoWait(false)
endevent

event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
	self.UnregisterForAllEvents()

	kPrimaryCallButton.Delete()
	kPrimaryCallButton = none

	kMoveButton.Delete()
	kMoveButton = none

	if (playerOnElevatorTriggerRef)
		playerOnElevatorTriggerRef.Delete()
		playerOnElevatorTriggerRef = none
	endif
endevent

;/ OLD SCRIPT

scriptname Zebrina:Workshop:PowerLiftMiniCartScript extends ObjectReference conditional

import Zebrina:WorkshopUtility

struct PowerLiftPanel
	ObjectReference ref = none hidden
	string attachNode = "REF_ATTACH_NODE"
	Form baseObject
endstruct

group AutoFill
	Keyword property WorkshopLinkObjectConfiguration auto const mandatory
	Keyword property WorkshopLinkPowerLift auto const mandatory
	GlobalVariable property PowerLiftFloorCount auto const mandatory
	Message property PowerLiftSelectFloorDialogue auto const mandatory
endgroup
group PowerLift
	Activator property PrimaryCallButtonBaseObject auto const mandatory
	string property sPrimaryCallButtonAttachNode = "CallButtonNode" auto const
	Activator property MoveButtonBaseObject auto const mandatory
	string property sMoveButtonAttachNode = "MoveButtonNode" auto const
	float property fCartPositionZOffset = 16.0 auto const
	float property fFullDistanceZ = 4096.0 auto const
	float property fFullAnimationDuration = 53.333 auto const
	float property fCartSafeRadius = 112.0 auto const
	Activator property PlayerOnElevatorTrigger auto const mandatory
	bool property bCanAdjustSpeed = true auto const conditional
endgroup
group PowerLiftConfigurable
	float property fLiftSpeedMult = 1.0 auto conditional
	PowerLiftPanel property BackPanelData = none auto
	PowerLiftPanel property LeftSidePanelData = none auto
	PowerLiftPanel property RightSidePanelData = none auto
	PowerLiftPanel property RampData = none auto
endgroup

; Conditionals
bool property bHasBackPanel auto conditional hidden
bool property bHasLeftSidePanel auto conditional hidden
bool property bHasRightSidePanel auto conditional hidden
bool property bHasRamp auto conditional hidden
bool property bBackPanelEnabled = false auto conditional hidden
bool property bLeftSidePanelEnabled = false auto conditional hidden
bool property bRightSidePanelEnabled = false auto conditional hidden
bool property bRampEnabled = false auto conditional hidden
bool bCartMoving = false conditional
bool bCartAtTop = true conditional

ObjectReference kPrimaryCallButton = none
ObjectReference property PrimaryCallButton hidden
	ObjectReference function get()
		return kPrimaryCallButton
	endfunction
	function set(ObjectReference akPrimaryCallButtonRef)
		if (kPrimaryCallButton)
			self.UnregisterForRemoteEvent(kPrimaryCallButton, "OnActivate")
			kPrimaryCallButton.Delete()
		endif
		if (akPrimaryCallButtonRef)
			akPrimaryCallButtonRef.SetLinkedRef(self, WorkshopLinkObjectConfiguration)
			self.RegisterForRemoteEvent(akPrimaryCallButtonRef, "OnActivate")
		endif
		kPrimaryCallButton = akPrimaryCallButtonRef
	endfunction
endproperty
ObjectReference kMoveButton = none
ObjectReference property MoveButton hidden
	ObjectReference function get()
		return kMoveButton
	endfunction
	function set(ObjectReference akMoveButtonRef)
		if (kMoveButton)
			self.UnregisterForRemoteEvent(kMoveButton, "OnActivate")
			kMoveButton.Delete()
		endif
		if (akMoveButtonRef)
			akMoveButtonRef.SetLinkedRef(self, WorkshopLinkObjectConfiguration)
			self.RegisterForRemoteEvent(akMoveButtonRef, "OnActivate")
		endif
		kMoveButton = akMoveButtonRef
	endfunction
endproperty
bool property BackPanelEnabled hidden
	bool function get()
		return bBackPanelEnabled
	endfunction
	function set(bool abFlag)
		bBackPanelEnabled = bHasBackPanel && TogglePanel(BackPanelData, abFlag)
	endfunction
endproperty
bool property LeftSidePanelEnabled hidden
	bool function get()
		return bBackPanelEnabled
	endfunction
	function set(bool abFlag)
		bLeftSidePanelEnabled = bHasLeftSidePanel && TogglePanel(LeftSidePanelData, abFlag)
	endfunction
endproperty
bool property RightSidePanelEnabled hidden
	bool function get()
		return bBackPanelEnabled
	endfunction
	function set(bool abFlag)
		bRightSidePanelEnabled = bHasRightSidePanel && TogglePanel(RightSidePanelData, abFlag)
	endfunction
endproperty
bool property RampEnabled hidden
	bool function get()
		return bBackPanelEnabled
	endfunction
	function set(bool abFlag)
		bRampEnabled = bHasRamp && TogglePanel(BackPanelData, abFlag)
	endfunction
endproperty

ObjectReference playerOnElevatorTriggerRef

float function GetLiftSpeed(ObjectReference akTargetLift)
	return akTargetLift.GetAnimationVariableFloat("fSpeed")
endfunction
float function SetLiftSpeed(ObjectReference akTargetLift, float afSpeed)
	akTargetLift.SetAnimationVariableFloat("fSpeed", afSpeed)
endfunction
float function GetLiftLevel(ObjectReference akTargetLift)
	return akTargetLift.GetAnimationVariableFloat("fValue")
endfunction
float function SetLiftLevel(ObjectReference akTargetLift, float afValue)
	akTargetLift.SetAnimationVariableFloat("fValue", afValue)
endfunction
float function GetLiftSpeedMult()
	if (fLiftSpeedMult <= 0.0)
		return 1.0
	endif
	return 1.0 / fLiftSpeedMult
endfunction

event OnInit()
	bHasBackPanel = BackPanelData
	bHasLeftSidePanel = LeftSidePanelData
	bHasRightSidePanel = RightSidePanelData
	bHasRamp = RampData
endevent

bool function TogglePanel(PowerLiftPanel data, bool abEnable)
	if (abEnable && !data.ref)
		self.WaitFor3DLoad()
		data.ref = self.PlaceAtNode(data.attachNode, data.baseObject, abAttach = true)
	elseif (!abEnable && data.ref)
		data.ref.Delete()
		data.ref = none
	endif
	return data.ref
endfunction

float function GetCartPositionZMax()
	return self.z + fCartPositionZOffset
endfunction
float function GetCartPositionZMin()
	return GetCartPositionZMax() - fFullDistanceZ
endfunction
float function GetCartPositionZ()
	return GetCartPositionZMax() - (GetLiftLevel(self) * fFullDistanceZ)
endfunction

float function GetCartSpeedByDistanceZ(float fDistanceZ)
	return (Math.Min(Math.Abs(fDistanceZ), fFullDistanceZ) / fFullDistanceZ) * fFullAnimationDuration * GetLiftSpeedMult()
endfunction

float function GetLiftPositionPercentage(float afPositionZ)
	float posZMax = GetCartPositionZMax()
	if (afPositionZ > posZMax)
		return 1.0
	elseif (afPositionZ < GetCartPositionZMin())
		return 0.0
	endif
	return (posZMax - afPositionZ) / fFullDistanceZ
endfunction

function MoveCartInternal(ObjectReference akTargetLift, float afSpeed, float afValue, bool abWait = true)
	SetLiftSpeed(akTargetLift, afSpeed)
	SetLiftLevel(akTargetLift, afValue)
	if (abWait)
		akTargetLift.PlayAnimationAndWait("Play01", "Done")
	else
		akTargetLift.PlayAnimation("Play01")
	endif
	if (abWait && akTargetLift == self)
		bCartAtTop = GetLiftLevel(self) == 0.0
	endif
endfunction
function MoveCartToLevel(float afLevelPercentage)
	float currentHeight = GetLiftLevel(self)
	if (afLevelPercentage != currentHeight)
		MoveCartInternal(self, Math.Abs(currentHeight - afLevelPercentage) * fFullAnimationDuration * GetLiftSpeedMult(), afLevelPercentage)
	endif
endfunction
function MoveCartToPositionZ(float afPositionZ)
	if (afPositionZ <= GetCartPositionZMax())
		float moveToHeight = GetLiftPositionPercentage(afPositionZ)
		float currentHeight = GetLiftLevel(self)
		if (moveToHeight != currentHeight)
			MoveCartInternal(self, Math.Abs(currentHeight - moveToHeight) * fFullAnimationDuration * GetLiftSpeedMult(), moveToHeight)
		endif
	endif
endfunction
function MoveCartToReference(ObjectReference akReference)
	MoveCartToPositionZ(akReference.GetPositionZ())
endfunction

ObjectReference[] function GetCallButtonArray()
	ObjectReference[] refs = self.GetRefsLinkedToMe(WorkshopLinkPowerLift)
	if (refs.Length > 1)
		SortCallButtonArray(refs, 0, refs.Length - 1)
	endif
	return refs
endfunction
; Quicksort, Hoare partition scheme.
; Sorts from low to high z position.
function SortCallButtonArray(ObjectReference[] arrCallButtons, int aiStart, int aiEnd)
	if (aiStart < aiEnd)
		int partition = SortCallButtonArrayPartition(arrCallButtons, aiStart, aiEnd)
		SortCallButtonArray(arrCallButtons, aiStart, partition)
		SortCallButtonArray(arrCallButtons, partition + 1, aiEnd)
	endif
endfunction
int function SortCallButtonArrayPartition(ObjectReference[] arrCallButtons, int aiStart, int aiEnd)
	ObjectReference pivot = arrCallButtons[aiStart]
	int i = aiStart - 1
	int j = aiEnd + 1
	while (true)
		i += 1
		while (arrCallButtons[i].z < pivot.z)
			i += 1
		endwhile

		j -= 1
		while (arrCallButtons[j].z > pivot.z)
			j -= 1
		endwhile

		if (i >= j)
			return j
		endif

		ObjectReference temp = arrCallButtons[i]
		arrCallButtons[i] = arrCallButtons[j]
		arrCallButtons[j] = temp
	endwhile
endfunction

function HandleActivation(ObjectReference akSender, ObjectReference akActionRef)
	if (bCartMoving == false && IsPlayerActionRef(akActionRef))
		bCartMoving = true
		if (akSender == Movebutton)
			ObjectReference[] callButtons = GetCallButtonArray()
			if (callButtons.Length == 1)
				; If just two levels there's no point in showing the floor selection dialogue.
				if (GetLiftLevel(self) == 0.0)
					MoveCartToPositionZ(callButtons[0].z)
				else
					MoveCartToLevel(0.0)
				endif
			elseif (callButtons.Length > 1)
				; Show floor selection dialogue.
				PowerLiftFloorCount.SetValueInt(1 + callButtons.Length)
				int selection = PowerLiftSelectFloorDialogue.Show()
				if (selection != 19)
					MoveCartToPositionZ(callButtons[selection].z)
				else
					MoveCartToLevel(0.0)
				endif
			endif
		elseif (akSender == PrimaryCallButton)
			MoveCartToLevel(0.0)
		else
			MoveCartToPositionZ(akSender.z)
		endif
		bCartMoving = false
	endif
endfunction
event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
	HandleActivation(akSender, akActionRef)
endevent

function Initialize()
	PrimaryCallButton = self.PlaceAtNode(sPrimaryCallButtonAttachNode, PrimaryCallButtonBaseObject)
	MoveButton = self.PlaceAtNode(sMoveButtonAttachNode, MoveButtonBaseObject, abAttach = true)

	BackPanelEnabled = bHasBackPanel
	LeftSidePanelEnabled = bHasLeftSidePanel
	RightSidePanelEnabled = bHasRightSidePanel
	RampEnabled = bHasRamp

	playerOnElevatorTriggerRef = self.PlaceAtNode("PlayerOnElevatorTriggerNode", PlayerOnElevatorTrigger, abAttach = true)
endfunction
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
	Initialize()
endevent
event OnReset()
	self.WaitFor3DLoad()
	Initialize()
	DEBUGTraceSelf(self, "OnReset", "...")
endevent
event OnWorkshopObjectGrabbed(ObjectReference akWorkshopRef)
	PrimaryCallButton.DisableNoWait()
endevent
event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
	PrimaryCallButton.MoveToNode(self, sPrimaryCallButtonAttachNode)
	PrimaryCallButton.EnableNoWait()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
	self.UnregisterForAllEvents()

	PrimaryCallButton = none
	MoveButton = none

	BackPanelEnabled = false
	LeftSidePanelEnabled = false
	RightSidePanelEnabled = false
	RampEnabled = false

	playerOnElevatorTriggerRef.Delete()
	playerOnElevatorTriggerRef = none
endevent

/;
