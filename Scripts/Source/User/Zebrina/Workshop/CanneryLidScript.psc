Scriptname Zebrina:Workshop:CanneryLidScript extends ObjectReference

group AutoFill
	Activator property WorkshopDN079CanneryHingeBottom01 auto const mandatory
	Activator property WorkshopDN079CanneryHingeSide01 auto const mandatory
	Static property WorkshopDummyRefMarker auto const mandatory
	Sound property OBJCanneryDoorLatchA auto const mandatory
	Sound property OBJCanneryDoorLatchB auto const mandatory
	Sound property OBJCanneryDoorLatchC auto const mandatory
	Sound property OBJCanneryDoorCloseSlam auto const mandatory
	Sound property OBJCanneryDoorMotorLPM auto const mandatory
endgroup

ObjectReference bottomHingeRef
ObjectReference leftHingeRef
ObjectReference rightHingeRef
ObjectReference soundRef
bool isAnimating = false
bool isOpen = false

function SetLidOpen(bool abOpen)
	if (!isAnimating && abOpen != isOpen)
		Debug.Notification("SetLidOpen(" + abOpen + ")")
		isAnimating = true

		;self.SetAnimationVariableFloat("fSpeed", 0.866667)
		bottomHingeRef.SetAnimationVariableFloat("fSpeed", 6.0)
		leftHingeRef.SetAnimationVariableFloat("fSpeed", 20.0)
		rightHingeRef.SetAnimationVariableFloat("fSpeed", 20.0)

		int motorSoundInstance

		if (abOpen)
			bottomHingeRef.PlayAnimation("Play90")
			Utility.Wait(0.3)
			OBJCanneryDoorLatchB.Play(leftHingeRef)
			leftHingeRef.PlayAnimation("Play180")
			OBJCanneryDoorLatchC.Play(rightHingeRef)
			rightHingeRef.PlayAnimation("Play180")
			Utility.Wait(1.2)
			motorSoundInstance = OBJCanneryDoorMotorLPM.Play(soundRef)
			self.PlayAnimationAndWait("Play180", "Done")
		else
			motorSoundInstance = OBJCanneryDoorMotorLPM.Play(soundRef)
			self.PlayAnimationAndWait("Play0", "Done")
			OBJCanneryDoorCloseSlam.Play(self)
			OBJCanneryDoorLatchB.Play(leftHingeRef)
			leftHingeRef.PlayAnimation("Play0")
			OBJCanneryDoorLatchC.Play(rightHingeRef)
			rightHingeRef.PlayAnimation("Play0")
			Utility.Wait(0.6)
			OBJCanneryDoorLatchA.Play(bottomHingeRef)
			bottomHingeRef.PlayAnimationAndWait("Play0", "Done")
		endif

		Sound.StopInstance(motorSoundInstance)

		isOpen = abOpen

		isAnimating = false
	endif
endfunction

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
	isAnimating = true

	self.WaitFor3DLoad()
	bottomHingeRef = self.PlaceAtNode("BottomHingeNode", WorkshopDN079CanneryHingeBottom01)
	leftHingeRef = self.PlaceAtNode("LeftHingeNode", WorkshopDN079CanneryHingeSide01, abAttach = true)
	rightHingeRef = self.PlaceAtNode("RightHingeNode", WorkshopDN079CanneryHingeSide01, abAttach = true)
	soundRef = self.PlaceAtNode("UpperMajorHinge", WorkshopDummyRefMarker)

	;/
	self.PlayAnimation("Play0")
	bottomHingeRef.WaitFor3DLoad()
	bottomHingeRef.PlayAnimation("Play0")
	leftHingeRef.WaitFor3DLoad()
	leftHingeRef.PlayAnimation("Play0")
	rightHingeRef.WaitFor3DLoad()
	rightHingeRef.PlayAnimation("Play0")
	/;

	isAnimating = false

	Debug.Notification("Cannery Lid initialized.")
endevent
event OnWorkshopObjectGrabbed(ObjectReference akWorkshopRef)
	bottomHingeRef.DisableNoWait()
	soundRef.DisableNoWait()
endevent
event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
	bottomHingeRef.MoveToNode(self, "BottomHingeNode")
	bottomHingeRef.EnableNoWait()
	soundRef.MoveToNode(self, "UpperMajorHinge")
	soundRef.EnableNoWait()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
	bottomHingeRef.DisableNoWait()
	bottomHingeRef.Delete()
	bottomHingeRef = none
	leftHingeRef.DisableNoWait()
	leftHingeRef.Delete()
	leftHingeRef = none
	rightHingeRef.DisableNoWait()
	rightHingeRef.Delete()
	rightHingeRef = none
	soundRef.DisableNoWait()
	soundRef.Delete()
	soundRef = none
endevent

event OnActivate(ObjectReference akActionRef)
	self.SetLidOpen(!isOpen)
endevent










;/
Events you can call:
-	Play0
-	Play30
-	Play45
-	Play90
-	Play180

-	Start30
-	Start45
-	Start90
-	Start180

Events to Listen for:
-	Done

Variables you can change:
-	fSpeed – Changes the speed of the animation when going from zero to any of the other rotations and back, but it is a multiplier so something like .5 will cut it’s speed in half, and something like 2 will double its speed etc.

-	fSpeedWild – Changes the speed of the animation when starting from any rotation other than zero to another rotation. This number is in seconds. Defaults at 2 seconds.


/;
