scriptname Zebrina:Workshop:WorkshopHopperScript extends ObjectReference

struct Vector
	float x = 0.0
	float y = 1.0
	float z = 0.0
endstruct

group AutoFill
	Sound property DLC05OBJWorkshopHopperEject auto const mandatory
    FormList property DLC05HopperLargeItems auto const mandatory
    FormList property AllBaseComponents auto const mandatory
    FormList property AllBaseComponentScrapItems auto const mandatory
    Container property WorkshopDummyContainer auto const mandatory
endgroup
group ProjectileData
	float property fProjectileMagnitude = 0.0 auto const ; 1.0
	{ How hard to shoot inventory - base value }
	float property fCurrentProjectileMagnitude = 0.0 auto ; 1.0
	{ How hard to shoot inventory - current value }

	Vector property BaseVector auto const
	{ Set to how much x/y/z direction you want to the force applied }

	float property fFiringTimer = 1.0 auto
	{ How long between firing while powered }

	float property fMinAcceleration = 2.0 auto const ; 80.0
	float property fMaxAcceleration = 10.0 auto const ; 150.0

	float property fCurrentMinAcceleration = 80.0 auto
	float property fCurrentMaxAcceleration = 150.0 auto

	float property fMinimumMass = 0.05 auto const ; 1.0
endGroup

bool property bFiring = false auto hidden
bool property bFiringTimerRunning = false auto hidden

Component[] contentComponents
Form[] contentOther

ObjectReference workshopRef
ObjectReference containerRef

MiscObject function ComponentToScrapItem(Component akComponent)
	int index = AllBaseComponents.Find(akComponent)
	if (index != -1)
		return AllBaseComponentScrapItems.GetAt(index) as MiscObject
	endif
    return none
endfunction
Component function ScrapItemToComponent(MiscObject akScrapItem)
	int index = AllBaseComponentScrapItems.Find(akScrapItem)
	if (index != -1)
		return AllBaseComponents.GetAt(index) as Component
	endif
    return none
endfunction

function SetOutputForce(float afNewForce)
	if (fProjectileMagnitude > 0)
		if (afNewForce > 0)
			; Use relative scale to set current min/max acceleration.
			fCurrentMinAcceleration = fMinAcceleration * (afNewForce / fProjectileMagnitude)
			fCurrentMaxAcceleration = fMaxAcceleration * (afNewForce / fProjectileMagnitude)
		else
			fCurrentMinAcceleration = 0
			fCurrentMinAcceleration = 0
		endif
		fCurrentProjectileMagnitude = afNewForce
	endif
endfunction

event OnLoad()
	bFiring = false
	bFiringTimerRunning = false
	self.AddInventoryeventFilter(none)
	if (self.IsPowered() && !self.IsDestroyed())
		StartFiringTimer()
	endif
endevent

event OnUnload()
	bFiring = false
	bFiringTimerRunning = false
endevent

event OnPowerOn(ObjectReference akPowerGenerator)
	StartFiringTimer()
endevent

event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    if (self.GetItemCount(akBaseItem) == aiItemCount)
        Component comp = ScrapItemToComponent(akBaseItem as MiscObject)
        if (comp)
            contentComponents.Add(comp)
        else
            contentOther.Add(akBaseItem)
        endif
    endif
    StartFiringTimer()
endevent
event OnItemRemoved(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
    if (self.GetItemCount(akBaseItem) == 0)
        Component comp = ScrapItemToComponent(akBaseItem as MiscObject)
        if (comp)
            contentComponents.Remove(contentComponents.Find(comp))
        else
            contentOther.Remove(contentOther.Find(akBaseItem))
        endif
    endif
endevent
event ObjectReference.OnItemAdded(ObjectReference akSender, Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	self.UnregisterForRemoteEvent(akSender, "OnItemAdded")
	StartFiringTimer()
endevent

event OnTimer(int aiTimerID)
	bFiringTimerRunning = false
	TryToFireProjectile()
endevent

function StartFiringTimer()
	if (self.IsPowered() && !self.IsDestroyed() && self.Is3DLoaded())
		if (!bFiring && !bFiringTimerRunning)
			bFiringTimerRunning = true
			StartTimer(fFiringTimer)
		endif
	endif
endfunction

function TryToFireProjectile()
	if (!bFiring && CheckInventory())
 		if (IsPowered() && IsDestroyed() == false && Is3DLoaded())
			bFiring = true

			ObjectReference refToFire = containerRef.DropFirstObject(true) ; Disabled so not visible.
			string firingNode = "SpawnNode"
			if (refToFire)
				; Check for large item node.
				if (DLC05HopperLargeItems.HasForm(refToFire.GetBaseObject()))
					firingNode = "SpawnNodeLarge"
				endif
                refToFire.MoveToNode(self, firingNode)

				; Calculate havok impulse with current rotation.
			  	Vector realVector = RotateVector(BaseVector)

				FireProjectile(refToFire, realVector, firingNode)
			endif

			bFiring = false
		endif
	endif

	bFiring = false

	; If we still have more inventory, run timer again.
	if (CheckInventory())
		StartFiringTimer()
	else
		self.RegisterForRemoteEvent(workshopRef, "OnItemAdded")
	endif
endfunction

function FireProjectile(ObjectReference refToFire, Vector firingVector, string firingNode)
	if (refToFire)
		DLC05OBJWorkshopHopperEject.Play(self)

		refToFire.MoveToNode(self, firingNode)
		refToFire.Enable() ; just in case
		; force to actually use:
		float force = CalculateForce(refToFire)
		refToFire.ApplyHavokImpulse(firingVector.x, firingVector.y, firingVector.z, force)
	endif
endfunction

; Check container inventory and take from and/or scrap items in workshop if necessary.
bool function CheckInventory()
	if (containerRef.GetItemCount() == 0)
        int i = contentOther.Length
        while (i > 0)
            i -= 1
            Form item = contentOther[i]
            workshopRef.RemoveItem(item, self.GetItemCount(item), akOtherContainer = containerRef)
        endwhile
        i = contentComponents.Length
        while (i > 0)
            i -= 1
            Component comp = contentComponents[i]
            MiscObject scrapItem = ComponentToScrapItem(comp)
            int count = Math.Min(self.GetItemCount(scrapItem), workshopRef.GetComponentCount(comp)) as int
            workshopref.RemoveComponents(comp, count, abSilent = false)
            containerRef.AddItem(scrapItem, count)
        endwhile
	endif
    return containerRef.GetItemCount() > 0
endfunction

; return new X based on z rotation
Vector function RotateVector(Vector startingVector)
	Vector rotatedVector = new Vector
	float zAngle = GetAngleZ()
	float h = Math.pow(startingVector.x, 2) + Math.pow(startingVector.y, 2)

	; new X = cos(z) * h
	rotatedVector.x = math.cos(zAngle) * h * -1 ; unclear why need the -1 here, but it works - possibly the node is rotated by 180 relative to the object orientation?
	; new Y = sin(z) * h
	rotatedVector.y = math.sin(zAngle) * h

	rotatedVector.z = startingVector.z

	debug.trace(self + " RotateVector: zAngle=" + zAngle + ", h=" + h + ", rotated vector=" + rotatedVector)
	return rotatedVector
endfunction

float function CalculateForce(ObjectReference refToFire)
	if (fCurrentProjectileMagnitude == 0)
		return 0
	else
		; get min mass for this ref, if (any)
		float minMass = fMinimumMass
		float mass = refToFire.GetMass()
		debug.trace(self + " CalculateForce: mass of " + refToFire + "=" + mass)
		mass = math.max(mass, minMass)
		float acceleration = fCurrentProjectileMagnitude/mass
		debug.trace(self + " CalculateForce: default acceleration=" + acceleration)
		if (acceleration < fCurrentMinAcceleration)
			acceleration = fCurrentMinAcceleration
		elseif (acceleration > fCurrentMaxAcceleration)
			acceleration = fCurrentMaxAcceleration
		endif

		return mass * acceleration
	endif
endfunction

event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
    containerRef.MoveTo(self)
endevent
Event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
    SetOutputForce(fProjectileMagnitude)
    contentComponents = new Component[0]
    contentOther = new Form[0]
    containerRef = self.PlaceAtMe(WorkshopDummyContainer)
    self.RegisterForRemoteEvent(akWorkshopref, "OnItemAdded")
    workshopRef = akWorkshopRef
EndEvent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
    self.UnregisterForAllRemoteEvents()
	self.RemoveAllItems(akWorkshopRef)
    containerRef.RemoveAllItems(akWorkshopRef, true)
    containerRef.Delete()
endevent
