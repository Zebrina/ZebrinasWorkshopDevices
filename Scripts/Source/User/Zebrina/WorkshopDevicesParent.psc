scriptname Zebrina:WorkshopDevicesParent extends Quest conditional

import Zebrina:WorkshopUtility

group AutoFill
    Keyword property WorkshopItemKeyword auto const mandatory
    GlobalVariable property ZWDPlacementModInstalled auto const mandatory
    GlobalVariable property ZWDSurvivalRecipes auto const mandatory
    Message property ZebrinasWorkshopDevicesUpdateMessage auto const mandatory
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
    ConstructibleObject property co_chem_WorkshopRobotRepairKitWeapon auto const mandatory
endgroup
group ItemSorting
    Zebrina:System:ItemSortingData[] property ItemSortingData auto const mandatory
endgroup

int iMQ102_CompleteCharGenStage = 10 const
int iMin03_CompleteQuestStage = 980 const

int iModVersion = 5 const
int iScriptVersion = 5

bool bWorkshopMenuInstalled conditional
bool bSettlementMenuManager = false conditional

WorkshopDevicesParent function GetInstance() global
    ; 0x00b1e7
    return Game.GetFormFromFile(0x000800, "ZebrinasWorkshopDevices.esp") as WorkshopDevicesParent
endfunction

bool function CheckQuestStage(Quest akQuest, int auiStageID)
    if (!akQuest.GetStageDone(auiStageID))
        self.RegisterForRemoteEvent(akQuest, "OnStageSet")
        return false
    endif
    return true
endfunction

event OnQuestInit()
    Actor player = Game.GetPlayer()

    player.AddPerk(WorkshopDevicesPerk)

    ; Initialize based on current difficulty.
    ZWDSurvivalRecipes.SetValue((Game.GetDifficulty() == 6) as float)

    if (player.GetWorldSpace() != SanctuaryHillsWorld || CheckQuestStage(MQ102, iMQ102_CompleteCharGenStage))
        if (IsWorkshopMenuInstalled())
            UninstallWorkshopMenu()
        endif
        InstallWorkshopMenu(true)
    endif
    if (CheckQuestStage(Min03, iMin03_CompleteQuestStage))
        if (Min03CastleArmoryDoorController.IsRunning())
            Min03CastleArmoryDoorController.Stop()
        endif
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
    Min03CastleArmoryDoorController.Stop()
endevent

bool function IsWorkshopMenuInstalled()
    return WorkshopMenuMain.HasForm(WorkshopMenu01ZebrinasWorkshopDevices)
endfunction
function InstallWorkshopMenu(bool abAddHolotape = false)
    ScriptObject smm = Game.GetFormFromFile(0x00633a, "SettlementMenuManager.esp")
    if (smm)
        smm = smm.CastAs("SettlementMenuManager:MainScript")
    endif

    if (smm)
        var[] args = new var[5]
        ; PluginName
        args[0] = "ZebrinasWorkshopDevices.esp"
        ; TargetMenu
        args[1] = WorkshopMenuMain
        ; ModMenu (explicit cast to form to pass the parameters correct)
        args[2] = WorkshopMenu01ZebrinasWorkshopDevices as Form
        ; ModName
        args[3] = "Zebrina's Workshop Devices"
        ; Author
        args[4] = "Zebrina"

        smm.CallFunctionNoWait("RegisterMenu", args)
        bSettlementMenuManager = true

        Debug.MessageBox("Zebrina's Workshop Devices is now managed by Settlement Menu Manager")
    else
        WorkshopMenuMain.AddForm(WorkshopMenu01ZebrinasWorkshopDevices)
    endif

    bWorkshopMenuInstalled = true

    if (abAddHolotape && Game.GetPlayer().GetItemCount(ZebrinasWorkshopDevicesHolotape) == 0)
        Game.GetPlayer().AddItem(ZebrinasWorkshopDevicesHolotape)
    endif
endfunction
function UninstallWorkshopMenu()
    if (!bSettlementMenuManager)
        WorkshopMenuMain.RemoveAddedForm(WorkshopMenu01ZebrinasWorkshopDevices)
        bWorkshopMenuInstalled = false
    endif
endfunction

function CheckMods()
    Zebrina:System.DetectPlacementMod(ZWDPlacementModInstalled)
endfunction

; UPDATE

function Update()
    ;Debug.StartScriptProfiling("Zebrina:Workshop:WorkshopDevicesParent")
    Debug.OpenUserLog("ZebrinasWorkshopDevices")
    Debug.SetGodMode(true)
    Debug.Notification("God mode enabled.")

    bWorkshopMenuInstalled = IsWorkshopMenuInstalled()
    bSettlementMenuManager = bSettlementMenuManager && Game.IsPluginInstalled("SettlementMenuManager.esp")

    ; PC ONLY
    if (Zebrina:System.IsPC())
        if (Zebrina:System.IsItemSortingEnabled())
            Zebrina:System.ApplyItemSortingPatch(ItemSortingData)
        endif

        if (Game.IsPluginInstalled("ArmorKeywords.esm"))
            ; Make engineering weapon crafted at weaponsmith workbench instead of chem station.
            Zebrina:System.PatchConstructibleWorkbenchKeyword(co_chem_WorkshopPipeWrench, 0x00085d, "ArmorKeywords.esm")
            Zebrina:System.PatchConstructibleWorkbenchKeyword(co_chem_WorkshopRobotRepairKitWeapon, 0x00085d, "ArmorKeywords.esm")
        endif
    endif

    if (iScriptVersion < iModVersion)
        iScriptVersion = iModVersion

        ZebrinasWorkshopDevicesUpdateMessage.Show()
    endif

    CheckMods()
endfunction
event Actor.OnPlayerLoadGame(Actor akSender)
    Update()
endevent

; WORKSHOP UTILITY

bool selectWorkshopObjectInProgress = false
ObjectReference function SelectWorkshopObject(ObjectReference akTargetRef, Zebrina:WorkshopSelectionQuest akLinkQuest, float afRadius = 1024.0)
    ObjectReference linkRef = none
    if (!selectWorkshopObjectInProgress)
        selectWorkshopObjectInProgress = true
        SearchTarget.ForceRefTo(akTargetRef)
        WorkshopSearchTargetRadius.SetValue(afRadius)
        if (akLinkQuest.Start())
            linkRef = akLinkQuest.GetSelectedTarget()
            akLinkQuest.CompleteSelection()
        else
            Debug.MessageBox("Selection quest failed to start: " + akLinkQuest)
        endif
        SearchTarget.Clear()
        selectWorkshopObjectInProgress = false
    endif
    return linkRef
endfunction
