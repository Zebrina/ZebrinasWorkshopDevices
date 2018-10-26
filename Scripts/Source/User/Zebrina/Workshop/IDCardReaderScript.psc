scriptname Zebrina:Workshop:IDCardReaderScript extends ObjectReference

group AutoFill
	Keyword property WorkshopScriptControlledKeyword auto const mandatory
	Message property IDCardReaderMessageNeedsCard auto const mandatory
	{ Failure message to display if the player doesn't have the card. }
	Sound property NeedsCardFailureSound auto const mandatory
	{ Failure sound to play if the player doesn't have the card. }
	Message property IDCardReaderMessageLockdown auto const mandatory
	{ Failure message to display if the card reader is locked down. }
	Sound property LockdownFailureSound auto const mandatory
	{ Failure sound to play if the card reader is locked down. }
	Scene property Player_IDCardReaderActivation auto const mandatory
	{ Player dialogue to play when the player activates the card reader without the card. }
    MiscObject property WorkshopGenericIDCard auto const mandatory
	Keyword property WorkshopLinkIDCardReaderTarget auto const mandatory
    Zebrina:WorkshopDevicesParent property ZebrinasWorkshopDevices auto const mandatory
	Message property WorkshopSelectIDCardReaderTargetDialogue auto const mandatory
	Zebrina:WorkshopSelectionQuest property WorkshopSelectIDCardReaderTarget auto const mandatory
endgroup
group Configurable
	float property fTimeoutSeconds = 10.0 auto
endgroup

function InitializeTargetRef()
	; Only allowed in RedState.
endfunction
ObjectReference function GetTargetRef()
	return self.GetLinkedRef(WorkshopLinkIDCardReaderTarget)
endfunction
function ClearTargetRef()
	ObjectReference linkTargetRef = self.GetLinkedRef(WorkshopLinkIDCardReaderTarget)
	if (linkTargetRef)
		self.SetLinkedRef(none, WorkshopLinkIDCardReaderTarget)
		self.UnregisterForAllEvents()
		;self.UnregisterForRemoteEvent(linkTargetRef, "OnWorkshopObjectDestroyed")
		if (linkTargetRef is Zebrina:Default:TwoStateActivator)
			Zebrina:Default:TwoStateActivator twoStateActivatorRef = linkTargetRef as Zebrina:Default:TwoStateActivator
			;self.RegisterForRemoteEvent(linkTargetRef, "OnActivate")
			;self.UnregisterForCustomEvent(twoStateActivatorRef, "DoorOpen")
			;self.UnregisterForCustomEvent(twoStateActivatorRef, "DoorClose")
			twoStateActivatorRef.BlockActivation(false)
			linkTargetRef.ResetKeyword(WorkshopScriptControlledKeyword)
		elseif (linkTargetRef.GetBaseObject() is Door || linkTargetRef is Zebrina:Default:DoorActivator)
			;self.RegisterForRemoteEvent(linkTargetRef, "OnActivate")
			;self.UnregisterForRemoteEvent(linkTargetRef, "OnOpen")
			;self.UnregisterForRemoteEvent(linkTargetRef, "OnClose")
			linkTargetRef.BlockActivation(false)
			linkTargetRef.ResetKeyword(WorkshopScriptControlledKeyword)
		endif
	endif
endfunction

ObjectReference[] cardRegistryArr = none
ObjectReference[] function GetCardRegistry()
	Zebrina:Workshop:IDCardReaderScript cardReaderRef = GetTargetRef() as Zebrina:Workshop:IDCardReaderScript
	if (cardReaderRef)
		; Return parent registry.
		return cardReaderRef.GetCardRegistry()
	endif
	; Return local registry, create if needed.
	if (!cardRegistryArr)
		cardRegistryArr = new ObjectReference[0]
	endif
	return cardRegistryArr
endfunction
function ClearCardRegistry(bool abClearParent = false)
	cardRegistryArr = none
	if (abClearParent)
		Zebrina:Workshop:IDCardReaderScript cardReaderRef = GetTargetRef() as Zebrina:Workshop:IDCardReaderScript
		if (cardReaderRef)
			cardReaderRef.ClearCardRegistry(true)
		endif
	endif
endfunction
function RegisterCards(Actor akActor)
	ObjectReference[] cardRegistry = GetCardRegistry()
	int i = cardRegistry.Length
	while (akActor.GetItemCount(WorkshopGenericIDCard) > 0)
		ObjectReference cardRef = akActor.DropObject(WorkshopGenericIDCard)
		if (cardRegistry.Find(cardRef) < 0)
			cardRegistry.Add(cardRef)
		endif
	endwhile
	while (i < cardRegistry.Length)
		akActor.AddItem(cardRegistry[i])
		i += 1
	endwhile
endfunction
bool function CheckActorCards(Actor akActor)
	ObjectReference[] cardRegistry = GetCardRegistry()
    int i = 0
    while (i < cardRegistry.Length)
        if (cardRegistry[i].GetContainer() == akActor)
            return true
        endif
        i += 1
    endwhile
    return false
endfunction

function SetDoorOpen(bool abOpen = true)
	ObjectReference linkTargetRef = GetTargetRef()
	if (linkTargetRef is Zebrina:Workshop:IDCardReaderScript)
		(linkTargetRef as Zebrina:Workshop:IDCardReaderScript).SetDoorOpen(abOpen)
    ;elseif (linkTargetRef is Zebrina:Default:TwoStateActivator)
    ;    (linkTargetRef as Zebrina:Default:TwoStateActivator).SetOpenNoWait(abOpen)
    else
        linkTargetRef.SetOpen(abOpen)
    endif
endfunction

Zebrina:Workshop:IDCardReaderScript function GetClosestVisibleCardReader(ObjectReference akActionRef)
    ObjectReference[] cardReaders = self.GetRefsLinkedToMe(WorkshopLinkIDCardReaderTarget)
	ObjectReference closestCardReader = none
	if (akActionRef.HasDirectLOS(self))
		closestCardReader = self
	endif
    int i = 0
    while (i < cardReaders.Length)
        if (akActionRef.HasDirectLOS(cardReaders[i]) && (!closestCardReader || akActionRef.GetDistance(cardReaders[i]) < akActionRef.GetDistance(closestCardReader)))
			closestCardReader = cardReaders[i]
        endif
        i += 1
    endwhile
    return closestCardReader as Zebrina:Workshop:IDCardReaderScript
endfunction

event OnLoad()
	self.BlockActivation()
endevent

function SwipeCard(ObjectReference akActionRef)
endfunction
function HandleDoorOpen()
endfunction
function HandleDoorClose()
endfunction

state RedSwipeCardState
endstate
auto state RedState
	function InitializeTargetRef()
		if (!WorkshopSelectIDCardReaderTarget.IsRunning() && WorkshopSelectIDCardReaderTargetDialogue.Show() == 1)
			ClearTargetRef()
			ObjectReference newLinkedRef = ZebrinasWorkshopDevices.SelectWorkshopObject(self, WorkshopSelectIDCardReaderTarget)
			if (newLinkedRef)
				self.RegisterForRemoteEvent(newLinkedRef, "OnWorkshopObjectDestroyed")
				if (newLinkedRef is Zebrina:Workshop:IDCardReaderScript)
					; Make sure to get the deepest card reader reference.
					ObjectReference linkedLinkedRef = newLinkedRef.GetLinkedRef(WorkshopLinkIDCardReaderTarget)
					if (linkedLinkedRef is Zebrina:Workshop:IDCardReaderScript)
						newLinkedRef = linkedLinkedRef
					endif
					; This card reader now acts as a proxy, so we clear our registry.
					ClearCardRegistry()
				elseif (newLinkedRef is Zebrina:Default:TwoStateActivator)
					newLinkedRef.AddKeyword(WorkshopScriptControlledKeyword)
					Zebrina:Default:TwoStateActivator twoStateActivatorRef = newLinkedRef as Zebrina:Default:TwoStateActivator
					twoStateActivatorRef.BlockActivation()
					self.RegisterForRemoteEvent(newLinkedRef, "OnActivate")
					self.RegisterForCustomEvent(twoStateActivatorRef, "DoorOpen")
					self.RegisterForCustomEvent(twoStateActivatorRef, "DoorClose")
				else
					newLinkedRef.AddKeyword(WorkshopScriptControlledKeyword)
					newLinkedRef.BlockActivation()
					self.RegisterForRemoteEvent(newLinkedRef, "OnActivate")
					self.RegisterForRemoteEvent(newLinkedRef, "OnOpen")
					self.RegisterForRemoteEvent(newLinkedRef, "OnClose")
				endif
				self.SetLinkedRef(newLinkedRef, WorkshopLinkIDCardReaderTarget)
			endif
		endif
	endfunction

	function SwipeCard(ObjectReference akActionRef)
		self.GoToState("RedSwipeCardState")

		if (akActionRef.GetItemCount(WorkshopGenericIDCard))
			if (CheckActorCards(akActionRef as Actor))
				self.PlayAnimationAndWait("Play01", "End")
				SetDoorOpen()
				self.GoToState("GreenState")
			else
				self.PlayAnimationAndWait("Play02", "End")
				if (akActionRef == Game.GetPlayer())
					LockdownFailureSound.Play(self)
					IDCardReaderMessageLockdown.Show()
				endif
				self.GoToState("RedState")
			endif
		else
			NeedsCardFailureSound.Play(self)
			if (akActionRef == Game.GetPlayer())
				IDCardReaderMessageNeedsCard.Show()
				Player_IDCardReaderActivation.Start()
			endif
			self.GoToState("RedState")
		endif
	endfunction

	function HandleDoorOpen()
		self.GoToState("GreenBypassState")
	endfunction
endstate
state GreenBypassState
	event OnBeginState(string asOldState)
		self.PlayAnimation("StartGreen")
		self.GoToState("GreenState")
	endevent
endstate
state GreenCloseDoorState
	event OnBeginState(string asOldState)
		SetDoorOpen(false)
		self.GoToState("RedState")
	endevent
	event OnEndState(string asNewState)
		self.PlayAnimation("Reset")
	endevent
endstate
state GreenState
	event OnBeginState(string asOldState)
		self.StartTimer(fTimeoutSeconds)
	endevent
	event OnEndState(string asNewState)
		self.CancelTimer()
		if (asNewState != "GreenCloseDoorState")
			self.PlayAnimation("Reset")
		endif
	endevent

	function SwipeCard(ObjectReference akActionRef)
		self.GoToState("GreenCloseDoorState")
	endfunction

	function HandleDoorClose()
		self.GoToState("RedState")
	endfunction

	event OnTimer(int aiTimerID)
		self.GoToState("GreenCloseDoorState")
	endevent
endstate

event OnActivate(ObjectReference akActionRef)
	SwipeCard(akActionRef)
endevent

event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
	Zebrina:Workshop:IDCardReaderScript cardReaderRef = GetClosestVisibleCardReader(akActionRef)
	if (cardReaderRef)
		cardReaderRef.SwipeCard(akActionRef)
	endif
endevent

; Remote events for regular doors.
event ObjectReference.OnOpen(ObjectReference akSender, ObjectReference akActionRef)
	HandleDoorOpen()
endevent
event ObjectReference.OnClose(ObjectReference akSender, ObjectReference akActionRef)
	HandleDoorClose()
endevent

; Remote events for two state activators.
event Zebrina:Default:TwoStateActivator.DoorOpen(Zebrina:Default:TwoStateActivator akSender, var[] akArgs)
	HandleDoorOpen()
endevent
event Zebrina:Default:TwoStateActivator.DoorClose(Zebrina:Default:TwoStateActivator akSender, var[] akArgs)
	HandleDoorClose()
endevent

event ObjectReference.OnWorkshopObjectDestroyed(ObjectReference akSender, ObjectReference akWorkshopRef)
	ClearTargetRef()
endevent

event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
	InitializeTargetRef()
endevent
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
	InitializeTargetRef()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
	ClearTargetRef()
	ClearCardRegistry()
endevent

;/
scriptname Zebrina:Workshop:IDCardReaderScript extends ObjectReference

group AutoFill
	Keyword property WorkshopScriptControlledKeyword auto const mandatory
	Message property IDCardReaderMessageNeedsCard auto const mandatory
	{ Failure message to display if the player doesn't have the card. }
	Sound property NeedsCardFailureSound auto const mandatory
	{ Failure sound to play if the player doesn't have the card. }
	Message property IDCardReaderMessageLockdown auto const mandatory
	{ Failure message to display if the card reader is locked down. }
	Sound property LockdownFailureSound auto const mandatory
	{ Failure sound to play if the card reader is locked down. }
	Scene property Player_IDCardReaderActivation auto const mandatory
	{ Player dialogue to play when the player activates the card reader without the card. }
    MiscObject property WorkshopGenericIDCard auto const mandatory
	Keyword property WorkshopLinkIDCardReaderTarget auto const mandatory
    Zebrina:WorkshopDevicesParent property ZebrinasWorkshopDevices auto const mandatory
	Message property WorkshopSelectIDCardReaderTargetDialogue auto const mandatory
	Zebrina:WorkshopSelectionQuest property WorkshopSelectIDCardReaderTarget auto const mandatory
endgroup

function InitializeTargetRef()
	; Only allowed in RedState.
endfunction
ObjectReference function GetTargetRef()
	return self.GetLinkedRef(WorkshopLinkIDCardReaderTarget)
endfunction
function ClearTargetRef()
	ObjectReference linkTargetRef = self.GetLinkedRef(WorkshopLinkIDCardReaderTarget)
	if (linkTargetRef)
		self.SetLinkedRef(none, WorkshopLinkIDCardReaderTarget)
		self.UnregisterForAllEvents()
		;self.UnregisterForRemoteEvent(linkTargetRef, "OnWorkshopObjectDestroyed")
		if (linkTargetRef is Zebrina:Default:TwoStateActivator)
			Zebrina:Default:TwoStateActivator twoStateActivatorRef = linkTargetRef as Zebrina:Default:TwoStateActivator
			;self.RegisterForRemoteEvent(linkTargetRef, "OnActivate")
			;self.UnregisterForCustomEvent(twoStateActivatorRef, "DoorOpen")
			;self.UnregisterForCustomEvent(twoStateActivatorRef, "DoorClose")
			twoStateActivatorRef.BlockActivation(false)
			linkTargetRef.ResetKeyword(WorkshopScriptControlledKeyword)
		elseif (linkTargetRef.GetBaseObject() is Door)
			;self.RegisterForRemoteEvent(linkTargetRef, "OnActivate")
			;self.UnregisterForRemoteEvent(linkTargetRef, "OnOpen")
			;self.UnregisterForRemoteEvent(linkTargetRef, "OnClose")
			linkTargetRef.BlockActivation(false)
			linkTargetRef.ResetKeyword(WorkshopScriptControlledKeyword)
		endif
	endif
endfunction

ObjectReference[] cardRegistryArr = none
ObjectReference[] function GetCardRegistry()
	Zebrina:Workshop:IDCardReaderScript cardReaderRef = GetTargetRef() as Zebrina:Workshop:IDCardReaderScript
	if (cardReaderRef)
		; Return parent registry.
		return cardReaderRef.GetCardRegistry()
	endif
	; Return local registry, create if needed.
	if (!cardRegistryArr)
		cardRegistryArr = new ObjectReference[0]
	endif
	return cardRegistryArr
endfunction
function ClearCardRegistry(bool abClearParent = false)
	cardRegistryArr = none
	if (abClearParent)
		Zebrina:Workshop:IDCardReaderScript cardReaderRef = GetTargetRef() as Zebrina:Workshop:IDCardReaderScript
		if (cardReaderRef)
			cardReaderRef.ClearCardRegistry(true)
		endif
	endif
endfunction
function RegisterCards(Actor akActor)
	ObjectReference[] cardRegistry = GetCardRegistry()
	int i = cardRegistry.Length
	while (akActor.GetItemCount(WorkshopGenericIDCard) > 0)
		ObjectReference cardRef = akActor.DropObject(WorkshopGenericIDCard)
		if (cardRegistry.Find(cardRef) < 0)
			cardRegistry.Add(cardRef)
		endif
	endwhile
	while (i < cardRegistry.Length)
		akActor.AddItem(cardRegistry[i])
		i += 1
	endwhile
endfunction
bool function CheckActorCards(Actor akActor)
	ObjectReference[] cardRegistry = GetCardRegistry()
    int i = 0
    while (i < cardRegistry.Length)
        if (cardRegistry[i].GetContainer() == akActor)
            return true
        endif
        i += 1
    endwhile
    return false
endfunction

function SetDoorOpen(bool abOpen = true)
	ObjectReference linkTargetRef = GetTargetRef()
	if (linkTargetRef is Zebrina:Workshop:IDCardReaderScript)
		(linkTargetRef as Zebrina:Workshop:IDCardReaderScript).SetDoorOpen(abOpen)
    elseif (linkTargetRef is Zebrina:Default:TwoStateActivator)
        (linkTargetRef as Zebrina:Default:TwoStateActivator).SetOpenNoWait(abOpen)
    else
        linkTargetRef.SetOpen(abOpen)
    endif
endfunction

Zebrina:Workshop:IDCardReaderScript function GetClosestVisibleCardReader(ObjectReference akActionRef)
    ObjectReference[] cardReaders = self.GetRefsLinkedToMe(WorkshopLinkIDCardReaderTarget)
	ObjectReference closestCardReader = none
	if (akActionRef.HasDirectLOS(self))
		closestCardReader = self
	endif
    int i = 0
    while (i < cardReaders.Length)
        if (akActionRef.HasDirectLOS(cardReaders[i]) && (!closestCardReader || akActionRef.GetDistance(cardReaders[i]) < akActionRef.GetDistance(closestCardReader)))
			closestCardReader = cardReaders[i]
        endif
        i += 1
    endwhile
    return closestCardReader as Zebrina:Workshop:IDCardReaderScript
endfunction

event OnLoad()
	self.BlockActivation()
endevent

function SwipeCard(ObjectReference akActionRef)
endfunction
function HandleDoorOpen()
endfunction
function HandleDoorClose()
endfunction

auto state RedState
	function InitializeTargetRef()
		if (!WorkshopSelectIDCardReaderTarget.IsRunning() && WorkshopSelectIDCardReaderTargetDialogue.Show() == 1)
			ClearTargetRef()
			ObjectReference newLinkedRef = ZebrinasWorkshopDevices.SelectWorkshopObject(self, WorkshopSelectIDCardReaderTarget)
			if (newLinkedRef)
				self.RegisterForRemoteEvent(newLinkedRef, "OnWorkshopObjectDestroyed")
				if (newLinkedRef is Zebrina:Workshop:IDCardReaderScript)
					; Make sure to get the deepest card reader reference.
					ObjectReference linkedLinkedRef = newLinkedRef.GetLinkedRef(WorkshopLinkIDCardReaderTarget)
					if (linkedLinkedRef is Zebrina:Workshop:IDCardReaderScript)
						newLinkedRef = linkedLinkedRef
					endif
					; This card reader now acts as a proxy, so we clear our registry.
					ClearCardRegistry()
				elseif (newLinkedRef is Zebrina:Default:TwoStateActivator)
					newLinkedRef.AddKeyword(WorkshopScriptControlledKeyword)
					Zebrina:Default:TwoStateActivator twoStateActivatorRef = newLinkedRef as Zebrina:Default:TwoStateActivator
					twoStateActivatorRef.BlockActivation()
					self.RegisterForRemoteEvent(newLinkedRef, "OnActivate")
					self.RegisterForCustomEvent(twoStateActivatorRef, "DoorOpen")
					self.RegisterForCustomEvent(twoStateActivatorRef, "DoorClose")
				else
					newLinkedRef.AddKeyword(WorkshopScriptControlledKeyword)
					newLinkedRef.BlockActivation()
					self.RegisterForRemoteEvent(newLinkedRef, "OnActivate")
					self.RegisterForRemoteEvent(newLinkedRef, "OnOpen")
					self.RegisterForRemoteEvent(newLinkedRef, "OnClose")
				endif
				self.SetLinkedRef(newLinkedRef, WorkshopLinkIDCardReaderTarget)
			endif
		endif
	endfunction

	function SwipeCard(ObjectReference akActionRef)
		self.GoToState("Busy")

		if (akActionRef.GetItemCount(WorkshopGenericIDCard))
			if (CheckActorCards(akActionRef as Actor))
				self.PlayAnimationAndWait("Play01", "End")
				SetDoorOpen()
				self.GoToState("GreenState")
			else
				self.PlayAnimationAndWait("Play02", "End")
				if (akActionRef == Game.GetPlayer())
					LockdownFailureSound.Play(self)
					IDCardReaderMessageLockdown.Show()
				endif
				self.GoToState("RedState")
			endif
		else
			NeedsCardFailureSound.Play(self)
			if (akActionRef == Game.GetPlayer())
				IDCardReaderMessageNeedsCard.Show()
				Player_IDCardReaderActivation.Start()
			endif
			self.GoToState("RedState")
		endif
	endfunction

	function HandleDoorOpen()
		self.GoToState("GreenBypassState")
	endfunction
endstate
state GreenBypassState
	event OnBeginState(string asOldState)
		self.PlayAnimation("StartGreen")
		self.GoToState("GreenState")
	endevent
endstate
state GreenState
	event OnBeginState(string asOldState)
		self.StartTimer(10.0)
	endevent
	event OnEndState(string asNewState)
		self.CancelTimer()
		self.PlayAnimation("Reset")
	endevent

	function SwipeCard(ObjectReference akActionRef)
		SetDoorOpen(false)
	endfunction

	function HandleDoorClose()
		self.GoToState("RedState")
	endfunction

	event OnTimer(int aiTimerID)
		SetDoorOpen(false)
	endevent
endstate
state Busy
endstate

event OnActivate(ObjectReference akActionRef)
	SwipeCard(akActionRef)
endevent

event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
	Zebrina:Workshop:IDCardReaderScript cardReaderRef = GetClosestVisibleCardReader(akActionRef)
	if (cardReaderRef)
		cardReaderRef.SwipeCard(akActionRef)
	endif
endevent

; Remote events for regular doors.
event ObjectReference.OnOpen(ObjectReference akSender, ObjectReference akActionRef)
	HandleDoorOpen()
endevent
event ObjectReference.OnClose(ObjectReference akSender, ObjectReference akActionRef)
	HandleDoorClose()
endevent

; Remote events for two state activators.
event Zebrina:Default:TwoStateActivator.DoorOpen(Zebrina:Default:TwoStateActivator akSender, var[] akArgs)
	HandleDoorOpen()
endevent
event Zebrina:Default:TwoStateActivator.DoorClose(Zebrina:Default:TwoStateActivator akSender, var[] akArgs)
	HandleDoorClose()
endevent

event ObjectReference.OnWorkshopObjectDestroyed(ObjectReference akSender, ObjectReference akWorkshopRef)
	ClearTargetRef()
endevent

event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
	InitializeTargetRef()
endevent
event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
	InitializeTargetRef()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
	ClearTargetRef()
	ClearCardRegistry()
endevent
/;
