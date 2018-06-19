scriptname Zebrina:Workshop:WorkshopDevicesMasterScript extends Quest

import Zebrina:System
import Zebrina:WorkshopUtility

customevent PowerLiftManipulated

struct ItemSortingData
    Form item
    string name
endstruct

group AutoFill
    Keyword property WorkshopItemKeyword auto const mandatory
    GlobalVariable property ZWDPCGlobal auto const mandatory
    Message property ZebrinasWorkshopDevices_UpdateMessage auto const mandatory
    Message property ZebrinasWorkshopDevices_AutoDoorsPatchMessage auto const mandatory
    Perk property WorkshopDevicesPerk auto const mandatory
    WorldSpace property SanctuaryHillsWorld auto const mandatory
    Quest property MQ102 auto const mandatory
    Quest property Min03 auto const mandatory
    Quest property Min03CastleArmoryDoorController auto const mandatory
    FormList property WorkshopMenuMain auto const mandatory
    FormList property WorkshopMenu01ZebrinasWorkshopDevices auto const mandatory
    Holotape property ZebrinasWorkshopDevicesHolotape auto const mandatory
    FormList property ZebrinasWorkshopDevicesStandardDoorList auto const mandatory
    { Used to patch mods that rely on formlists to detect references in the game world. }
    ReferenceAlias property SearchTarget auto const mandatory
    GlobalVariable property WorkshopSearchTargetRadius auto const mandatory
    ConstructibleObject property co_chem_WorkshopPipeWrench auto const mandatory
endgroup
group ItemSorting
    ItemSortingData[] property ItemSortingDataList auto const mandatory
endgroup

int iMQ102_CompleteCharGenStage = 10 const
int iMin03_CompleteQuestStage = 980 const

int iModVersion = 4 const
int iScriptVersion = 4

bool bPatched_AutoDoors = false

ThreadLock findWorkshopObjectLock

WorkshopDevicesMasterScript function GetInstance() global
    return Game.GetFormFromFile(0x00b1e7, "ZebrinasWorkshopDevices.esp") as WorkshopDevicesMasterScript
endfunction

bool function CheckQuestStage(Quest akQuest, int auiStageID)
    if (!akQuest.GetStageDone(auiStageID))
        self.RegisterForRemoteEvent(akQuest, "OnStageSet")
        return false
    endif
    return true
endfunction

event OnQuestInit()
    findWorkshopObjectLock = new ThreadLock

    Actor player = Game.GetPlayer()

    player.AddPerk(WorkshopDevicesPerk)

    if (player.GetWorldSpace() != SanctuaryHillsWorld || CheckQuestStage(MQ102, iMQ102_CompleteCharGenStage))
        InstallWorkshopMenu(true)
    endif
    if (CheckQuestStage(Min03, iMin03_CompleteQuestStage))
        Min03CastleArmoryDoorController.Start()
    endif

    Update()
    self.RegisterForRemoteEvent(player, "OnPlayerLoadGame")
endevent
event Quest.OnStageSet(Quest akSender, int auiStageID, int auiItemID)
    if (akSender == MQ102)
        if (auiStageID == iMQ102_CompleteCharGenStage)
            InstallWorkshopMenu(true)
            self.UnregisterForRemoteEvent(akSender, "OnStageSet")
        endif
    elseif (akSender == Min03)
        if (auiStageID == iMin03_CompleteQuestStage)
            Min03CastleArmoryDoorController.Start()
            DebugTrace("Started Minutemen Castle Armory door controller quest.")
            self.UnregisterForRemoteEvent(akSender, "OnStageSet")
        endif
    endif
endevent
event OnQuestShutdown()
    UninstallWorkshopMenu()
endevent

; PC ONLY
function ApplyItemSortingPatch()
    DebugTraceSelf(self, "ApplyItemSortingPatch", "Started")

    if (IsItemSortingEnabled())
        int i = 0
        while (i < ItemSortingDataList.Length)
            ItemSortingDataList[i].item.SetName(ItemSortingDataList[i].name)
            i += 1
        endwhile
    endif

    DebugTraceSelf(self, "ApplyItemSortingPatch", "Finished")
endfunction
; PC ONLY
function ApplyCraftablesPatch()
    DebugTraceSelf(self, "ApplyCraftablesPatch", "Started")

    if (Game.IsPluginInstalled("ArmorKeywords.esm"))
        ; Make weapon craftable in weaponsmith workbench instead of chem station.
        co_chem_WorkshopPipeWrench.SetWorkbenchKeyword(Game.GetFormFromFile(0x00085d, "ArmorKeywords.esm") as Keyword)
    endif

    DebugTraceSelf(self, "ApplyCraftablesPatch", "Finished")
endfunction

bool function IsWorkshopMenuInstalled()
    return WorkshopMenuMain.HasForm(WorkshopMenu01ZebrinasWorkshopDevices)
endfunction
function InstallWorkshopMenu(bool abAddHolotape = false)
    WorkshopMenuMain.AddForm(WorkshopMenu01ZebrinasWorkshopDevices)
    if (abAddHolotape)
        Game.GetPlayer().AddItem(ZebrinasWorkshopDevicesHolotape)
    endif
endfunction
function UninstallWorkshopMenu()
    WorkshopMenuMain.RemoveAddedForm(WorkshopMenu01ZebrinasWorkshopDevices)
endfunction

function CheckMods()
    if (!bPatched_AutoDoors && Game.IsPluginInstalled("AutoDoors.esp"))
        FormList AutoDoors_AD_SupportedDoorsList = Game.GetFormFromFile(0x000804, "AutoDoors.esp") as FormList
        if (AutoDoors_AD_SupportedDoorsList)
            int i = 0
            while (i < ZebrinasWorkshopDevicesStandardDoorList.GetSize())
                AutoDoors_AD_SupportedDoorsList.AddForm(ZebrinasWorkshopDevicesStandardDoorList.GetAt(i))
                i += 1
            endwhile

            bPatched_AutoDoors = true
            ZebrinasWorkshopDevices_AutoDoorsPatchMessage.Show()
        endif
    endif
endfunction

; POWERLIFT MANAGEMENT

function SendPowerLiftManipulatedEvent(ObjectReference akPowerLiftRef)
    var[] args = new var[1]
    args[0] = akPowerLiftRef
    self.SendCustomEvent("PowerLiftManipulated", args)
endfunction

; UPDATE

function Update()
    ;Debug.StartScriptProfiling("Zebrina:Workshop:WorkshopDevicesMasterScript")
    Debug.OpenUserLog("ZebrinasWorkshopDevices")
    Debug.SetGodMode(true)
    Debug.Notification("God mode enabled.")

    ; PC ONLY
    ApplyItemSortingPatch()
    ; PC ONLY
    ApplyCraftablesPatch()

    if (iScriptVersion < iModVersion)
        if (iScriptVersion < 3)
            ; Needs to re-apply patch.
            bPatched_AutoDoors = false
        endif
        if (iScriptVersion < 4)
            ; Fixed position of outside button.
            if (Min03CastleArmoryDoorController.IsRunning())
                Min03CastleArmoryDoorController.Stop()
                Min03CastleArmoryDoorController.Start()
            endif
        endif

        iScriptVersion = iModVersion

        ZebrinasWorkshopDevices_UpdateMessage.Show()
    endif

    CheckMods()
endfunction
event Actor.OnPlayerLoadGame(Actor akSender)
    Update()
endevent

; WORKSHOP UTILITY

ObjectReference function FindWorkshopObject(ObjectReference akSearchTargetRef, Quest akSearchQuest, float afRadius)
    LockThread(findWorkshopObjectLock)
    SearchTarget.ForceRefTo(akSearchTargetRef)
    WorkshopSearchTargetRadius.SetValue(afRadius)
    ObjectReference foundRef = none
    if (akSearchQuest.Start())
        foundRef = (akSearchQuest.GetAlias(1) as ReferenceAlias).GetReference()
        akSearchQuest.Stop()
    endif
    SearchTarget.Clear()
    UnlockThread(findWorkshopObjectLock)
    return foundRef
endfunction

function RegisterForRemoteWorkshopEvents(ObjectReference akReference)
    ObjectReference workshopRef = akReference.GetLinkedRef(WorkshopItemKeyword)
    akReference.RegisterForRemoteEvent(workshopRef, "OnWorkshopObjectPlaced")
	akReference.RegisterForRemoteEvent(workshopRef, "OnWorkshopObjectMoved")
	akReference.RegisterForRemoteEvent(workshopRef, "OnWorkshopObjectDestroyed")
endfunction
function UnregisterForRemoteWorkshopEvents(ObjectReference akReference)
    ObjectReference workshopRef = akReference.GetLinkedRef(WorkshopItemKeyword)
    akReference.UnregisterForRemoteEvent(workshopRef, "OnWorkshopObjectPlaced")
	akReference.UnregisterForRemoteEvent(workshopRef, "OnWorkshopObjectMoved")
	akReference.UnregisterForRemoteEvent(workshopRef, "OnWorkshopObjectDestroyed")
endfunction
