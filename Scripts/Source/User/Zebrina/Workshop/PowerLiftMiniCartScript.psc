scriptname Zebrina:Workshop:PowerLiftMiniCartScript extends ObjectReference conditional

import Zebrina:WorkshopUtility

struct PowerLiftPanel
	ObjectReference ref = none hidden
	string attachNode = "REF_ATTACH_NODE"
	Form baseObject
endstruct

group AutoFill
	Zebrina:Workshop:PowerLiftMasterScript property WorkshopPowerLiftMaster auto const mandatory
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
		if (akPrimaryCallButtonRef)
			akPrimaryCallButtonRef.SetLinkedRef(self, WorkshopLinkObjectConfiguration)
			self.RegisterForRemoteEvent(akPrimaryCallButtonRef, "OnActivate")
		endif
		if (kPrimaryCallButton)
			self.UnregisterForRemoteEvent(kPrimaryCallButton, "OnActivate")
			kPrimaryCallButton.DisableNoWait()
			kPrimaryCallButton.Delete()
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
		if (akMoveButtonRef)
			akMoveButtonRef.SetLinkedRef(self, WorkshopLinkObjectConfiguration)
			self.RegisterForRemoteEvent(akMoveButtonRef, "OnActivate")
		endif
		if (kMoveButton)
			self.UnregisterForRemoteEvent(kMoveButton, "OnActivate")
			kMoveButton.DisableNoWait()
			kMoveButton.Delete()
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
		data.ref.DisableNoWait()
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
function SortCallButtonArray(ObjectReference[] aaCallButtons, int aiStart, int aiEnd)
	if (aiStart < aiEnd)
		int partition = SortCallButtonArrayPartition(aaCallButtons, aiStart, aiEnd)
		SortCallButtonArray(aaCallButtons, aiStart, partition)
		SortCallButtonArray(aaCallButtons, partition + 1, aiEnd)
	endif
endfunction
int function SortCallButtonArrayPartition(ObjectReference[] aaCallButtons, int aiStart, int aiEnd)
	ObjectReference pivot = aaCallButtons[aiStart]
	int i = aiStart - 1
	int j = aiEnd + 1
	while (true)
		i += 1
		while (aaCallButtons[i].z < pivot.z)
			i += 1
		endwhile

		j -= 1
		while (aaCallButtons[j].z > pivot.z)
			j -= 1
		endwhile

		if (i >= j)
			return j
		endif

		ObjectReference temp = aaCallButtons[i]
		aaCallButtons[i] = aaCallButtons[j]
		aaCallButtons[j] = temp
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
	self.WaitFor3DLoad()
	PrimaryCallButton = self.PlaceAtNode(sPrimaryCallButtonAttachNode, PrimaryCallButtonBaseObject)
	MoveButton = self.PlaceAtNode(sMoveButtonAttachNode, MoveButtonBaseObject, abAttach = true)

	BackPanelEnabled = bHasBackPanel
	LeftSidePanelEnabled = bHasLeftSidePanel
	RightSidePanelEnabled = bHasRightSidePanel
	RampEnabled = bHasRamp

	WorkshopPowerLiftMaster.SendPowerLiftManipulatedEvent(self)
endfunction
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
	Initialize()
endevent
event OnReset()
	Debug.MessageBox("Zebrina:Workshop:PowerLiftMiniCartScript:OnReset")
	Initialize()
endevent
event OnWorkshopObjectGrabbed(ObjectReference akWorkshopRef)
	PrimaryCallButton.DisableNoWait()
endevent
event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
	PrimaryCallButton.MoveToNode(self, sPrimaryCallButtonAttachNode)
	PrimaryCallButton.EnableNoWait()

	WorkshopPowerLiftMaster.SendPowerLiftManipulatedEvent(self)
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
	PrimaryCallButton = none
	MoveButton = none

	BackPanelEnabled = false
	LeftSidePanelEnabled = false
	RightSidePanelEnabled = false
	RampEnabled = false

	WorkshopPowerLiftMaster.SendPowerLiftManipulatedEvent(self)
endevent