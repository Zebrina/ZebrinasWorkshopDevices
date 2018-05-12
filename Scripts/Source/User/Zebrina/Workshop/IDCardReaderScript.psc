scriptname Zebrina:Workshop:IDCardReaderScript extends Zebrina:Workshop:ConfigurableObjectScript

import Zebrina:WorkshopUtility

customevent GreenStateBegin
customevent GreenStateEnd

group AutoFill
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
	Message property WorkshopIDCardReaderDoorActivateOverride auto const mandatory

    MiscObject property WorkshopGenericIDCard auto const mandatory
    Component property c_Plastic auto const mandatory
    GlobalVariable property ConfigTerminalComponentCount1 auto const mandatory
    { Used to check player plastic count in configuration terminal. }

	Keyword property WorkshopLinkAttachedDoor auto const mandatory
	Quest property WorkshopFindClosestDoor auto const mandatory
	Keyword property WorkshopIgnoredDoor auto const mandatory

    Zebrina:Workshop:WorkshopDevicesMasterScript property ZebrinasWorkshopDevices auto const mandatory
endgroup
group WorkshopDevicesMaster
	RefCollectionAlias property WorkshopIDCardsIS auto const mandatory
    RefCollectionAlias property WorkshopIDCards auto const mandatory
endgroup
group Optional
    int property iIDCardPlasticCost = 1 auto const
	float property fAttachToDoorRadius = 256.0 auto const
endgroup

float property fTimeoutSeconds = 10.0 auto hidden

ObjectReference[] linkedIDCards
ThreadLock listLock
bool bHasBeenActivated = false

event OnInit()
    linkedIDCards = new ObjectReference[0]
    listLock = new ThreadLock
endevent

; Zebrina:Workshop:ConfigurableObjectScript override.
function StartConfiguration()
    ConfigTerminalComponentCount1.SetValue(Zebrina:WorkshopUtility.GetPlayerComponentCount(c_Plastic))
    parent.StartConfiguration()
endfunction

function UnattachFromDoor()
	ObjectReference currentDoor = self.GetLinkedRef(WorkshopLinkAttachedDoor)
	if (currentDoor)
		self.UnregisterForRemoteEvent(currentDoor, "OnActivate")
		currentDoor.SetActivateTextOverride(none)
		currentDoor.BlockActivation(false)
		currentDoor.ResetKeyword(WorkshopIgnoredDoor)
		self.SetLinkedRef(none, WorkshopLinkAttachedDoor)
	endif
endfunction
ObjectReference function AttachToClosestDoor()
	ObjectReference currentDoor = ZebrinasWorkshopDevices.FindWorkshopObject(self, WorkshopFindClosestDoor, fAttachToDoorRadius)
	self.SetLinkedRef(currentDoor, WorkshopLinkAttachedDoor)
	if (currentDoor)
		currentDoor.AddKeyword(WorkshopIgnoredDoor)
		currentDoor.BlockActivation(true)
		currentDoor.SetActivateTextOverride(WorkshopIDCardReaderDoorActivateOverride)
		self.RegisterForRemoteEvent(currentDoor, "OnActivate")
	endif
	return currentDoor
endfunction
function ActivateAttachedDoorAndWait(int aiWaitForOpenState)
	ObjectReference currentDoor = self.GetLinkedRef(WorkshopLinkAttachedDoor)
	if (currentDoor)
		while (currentDoor.GetOpenState() != aiWaitForOpenState && currentDoor.GetOpenState() != aiWaitForOpenState + 1)
			currentDoor.Activate(self, true)
			Utility.Wait(0.1)
		endwhile
	endif
endfunction

bool function CreateNewIDCard(Actor akActor)
    ; If akActor is player, also check workshop for components.
    if (akActor == Game.GetPlayer() && Zebrina:WorkshopUtility.GetPlayerComponentCount(c_Plastic) > 0)
        Zebrina:WorkshopUtility.PlayerRemoveComponents(c_Plastic, iIDCardPlasticCost)
    elseif (akActor != Game.GetPlayer() && akActor.GetComponentCount(c_Plastic) > 0)
        akActor.RemoveComponents(c_Plastic, iIDCardPlasticCost)
    else
        return false
    endif

    ObjectReference cardRef = akActor.PlaceAtMe(WorkshopGenericIDCard, abInitiallyDisabled = true)

	if (IsItemSortingEnabled())
    	WorkshopIDCardsIS.AddRef(cardRef)
	else
		WorkshopIDCards.AddRef(cardRef)
	endif

    self.RegisterForRemoteEvent(cardRef, "OnSell")
    self.RegisterForRemoteEvent(cardRef, "OnContainerChanged")

    akActor.AddItem(cardRef)

    LockThread(listLock)

    linkedIDCards.Add(cardRef)

    UnlockThread(listLock)

    return true
endfunction
function InvalidateIDCard(ObjectReference akCardRef)
    LockThread(listLock)

    int index = linkedIDCards.Find(akCardRef)
    if (index != -1)
        linkedIDCards.Remove(index)
        self.UnregisterForRemoteEvent(akCardRef, "OnSell")
        self.UnregisterForRemoteEvent(akCardRef, "OnContainerChanged")
        WorkshopIDCardsIS.RemoveRef(akCardRef)
        WorkshopIDCards.RemoveRef(akCardRef)
    endif

    UnlockThread(listLock)
endfunction

bool function CheckActorIDCards(Actor akActor)
    int i = 0
    while (i < linkedIDCards.Length)
        if (linkedIDCards[i].GetContainer() == akActor)
            return true
        endif
        i += 1
    endwhile
    return false
endfunction

event ObjectReference.OnSell(ObjectReference akSender, Actor akSeller)
    InvalidateIDCard(akSender)
endevent
event ObjectReference.OnContainerChanged(ObjectReference akSender, ObjectReference akNewContainer, ObjectReference akOldContainer)
    if (!akNewContainer)
        InvalidateIDCard(akSender)
    endif
endevent

function HandleActivation(ObjectReference akCallerRef, Actor akActionRef)
endfunction

auto state RedState
	function HandleActivation(ObjectReference akCallerRef, Actor akActionRef)
		if (!bHasBeenActivated && akActionRef)
			bHasBeenActivated = true

			if (akActionRef.GetItemCount(WorkshopGenericIDCard))
				if (self.IsPowered() && CheckActorIDCards(akActionRef))
					akCallerRef.PlayAnimationAndWait("Play01", "End")
					self.GoToState("GreenState")
					var[] args = new var[1]
					args[0] = akCallerRef
					self.SendCustomEvent("GreenStateBegin", args)
					if (akCallerRef != self)
						self.PlayAnimation("StartGreen")
					endif
				else
					akCallerRef.PlayAnimationAndWait("Play02", "End")
					LockdownFailureSound.Play(akCallerRef)
					IDCardReaderMessageLockdown.Show()
				endif
			else
				NeedsCardFailureSound.Play(akCallerRef)
				IDCardReaderMessageNeedsCard.Show()
				Player_IDCardReaderActivation.Start()
			endif

			bHasBeenActivated = false
		endif
	endfunction
endstate
state GreenState
	event OnBeginState(string asOldState)
		self.StartTimer(fTimeoutSeconds)
		ActivateAttachedDoorAndWait(1)
	endevent
	event OnEndState(string asNewState)
		self.SendCustomEvent("GreenStateEnd")
		self.PlayAnimation("Reset")
		ActivateAttachedDoorAndWait(3)
	endevent

	event OnTimer(int aiTimerID)
		self.GoToState("RedState")
	endevent
endstate

event OnActivate(ObjectReference akActionRef)
	if (akActionRef is Actor && akActionRef.HasDirectLOS(self))
		HandleActivation(self, akActionRef as Actor)
	endif
endevent
event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
	if (akActionRef is Actor)
		if (akActionRef.HasDirectLOS(self))
			HandleActivation(self, akActionRef as Actor)
		else
			; Find first visible Secondary ID Card Reader.
			ObjectReference[] refsLinked = self.GetRefsLinkedToMe(WorkshopLinkAttachedDoor)
			int i = 0
			while (i < refsLinked.Length)
				if (akActionRef.HasDirectLOS(refsLinked[i]))
					HandleActivation(refsLinked[i], akActionRef as Actor)
					return
				endif
				i += 1
			endwhile
		endif
	endif
endevent

event OnWorkshopObjectPlaced(ObjectReference akWorkshopRef)
	self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectPlaced")
	self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectMoved")
	self.RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectDestroyed")
	AttachToClosestDoor()
endevent
event OnWorkshopObjectMoved(ObjectReference akWorkshopRef)
	UnattachFromDoor()
	AttachToClosestDoor()
endevent
event OnWorkshopObjectDestroyed(ObjectReference akWorkshopRef)
	UnattachFromDoor()

    LockThread(listLock)

    int i = 0
    while (i < linkedIDCards.Length)
		WorkshopIDCardsIS.RemoveRef(linkedIDCards[i])
        WorkshopIDCards.RemoveRef(linkedIDCards[i])
        i += 1
    endwhile

    UnlockThread(listLock)
endevent

function HandleRemoteWorkshopEvent(ObjectReference akSender, ObjectReference akReference)
	if (akSender is WorkshopScript && akReference != self && akReference.GetBaseObject() is Door)
		UnattachFromDoor()
		AttachToClosestDoor()
	endif
endfunction
event ObjectReference.OnWorkshopObjectPlaced(ObjectReference akSender, ObjectReference akReference)
	HandleRemoteWorkshopEvent(akSender, akReference)
endevent
event ObjectReference.OnWorkshopObjectMoved(ObjectReference akSender, ObjectReference akReference)
	HandleRemoteWorkshopEvent(akSender, akReference)
endevent
event ObjectReference.OnWorkshopObjectDestroyed(ObjectReference akSender, ObjectReference akReference)
	HandleRemoteWorkshopEvent(akSender, akReference)
endevent
