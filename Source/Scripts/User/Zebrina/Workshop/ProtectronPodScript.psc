scriptname Zebrina:Workshop:ProtectronPodScript extends WorkshopObjectScript

import Zebrina:WorkshopUtility

group AutoFill
    ActorValue property ProtectronPodStatus auto const mandatory
    FormList property ProtectronPodAllowedActorKeywords auto const mandatory
endgroup
group QuestAliases
    RefCollectionAlias property ProtectronPodActors auto const mandatory
endgroup

Actor protectronRef = none
bool removedModdableBotKeyword = false

function InitializeProtectron(Actor akProtectronRef)
    if (akProtectronRef != protectronRef)
        if (protectronRef)
            self.UnregisterForRemoteEvent(protectronRef, "OnCombatStateChanged")
            TogglePodStatus(protectronRef, false)
        endif
        if (akProtectronRef)
            self.RegisterForRemoteEvent(akProtectronRef, "OnCombatStateChanged")
            TogglePodStatus(akProtectronRef, akProtectronRef.GetCombatState() == 0)
        endif
        protectronRef = akProtectronRef
    endif
endfunction

function TogglePodStatus(Actor akProtectronRef, bool abEnable)
    if (akProtectronRef)
        if (abEnable)
            Debug.Notification("Protectron going back to pod.")
            akProtectronRef.SetValue(ProtectronPodStatus, 0.0)
            ProtectronPodActors.AddRef(akProtectronRef)
            akProtectronRef.EvaluatePackage()
        else
            Debug.Notification("Protectron exiting pod.")
            akProtectronRef.SetValue(ProtectronPodStatus, 1.0)
            ProtectronPodActors.RemoveRef(akProtectronRef)
            akProtectronRef.EvaluatePackage()
        endif
        ; 'Poke' the protectron to trigger vanilla scripts.
        akProtectronRef.Activate(self)
    endif
endfunction

; WorkshopObjectScript override.
function AssignActor(WorkshopNPCScript newActor = None)
    if (newActor)
        if (newActor.HasKeywordInFormList(ProtectronPodAllowedActorKeywords))
            parent.AssignActor(newActor)
            InitializeProtectron(newActor)
        else
            ; Show 'cannot be assigned' message.
            WorkshopParent.WorkshopResourceNoAssignmentMessage.Show()
        endif
    else
        parent.AssignActor(newActor)
    endif
endfunction
; WorkshopObjectScript override.
function ActivatedByWorkshopActor(WorkshopNPCScript workshopNPC)
    if (workshopNPC)
        if (workshopNPC.HasKeywordInFormList(ProtectronPodAllowedActorKeywords))
            parent.ActivatedByWorkshopActor(workshopNPC)
            InitializeProtectron(workshopNPC)
        else
            ; Show 'cannot be assigned' message.
            WorkshopParent.WorkshopResourceNoAssignmentMessage.Show()
        endif
    else
        parent.ActivatedByWorkshopActor(workshopNPC)
    endif
endFunction

event Actor.OnCombatStateChanged(Actor akSender, Actor akTarget, int aeCombatState)
    TogglePodStatus(akSender, aeCombatState == 0)
endevent
event Actor.OnPlayerModRobot(Actor akSender, Actor akRobot, ObjectMod akModBaseObject)
    if (akRobot == protectronRef)
        if (!akRobot.HasKeywordInFormList(ProtectronPodAllowedActorKeywords))
            ; The player modified the robot so that it no longer has any of the allowed keywords.
            InitializeProtectron(none)
            self.AssignActorOwnership(none)
        endif
        if (akRobot.IsUnconscious())
            akRobot.SetUnconscious(false)
        endif
    endif
endevent

; WorkshopObjectScript override.
event OnLoad()
    parent.OnLoad()
    self.RegisterForRemoteEvent(Game.GetPlayer(), "OnPlayerModRobot")
endevent
; WorkshopObjectScript override.
event OnUnload()
    parent.OnUnload()
    self.UnregisterForRemoteEvent(Game.GetPlayer(), "OnPlayerModRobot")
endevent

event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
    InitializeProtectron(none)
endevent
