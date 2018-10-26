scriptname Zebrina:System hidden
{ System specific code for easier xbone porting. This file is for PC. }

bool function IsPC() global
    return true
endfunction

function DetectPlacementMod(GlobalVariable akPlacementModGlobal) global
    akPlacementModGlobal.SetValue((F4SE.GetPluginVersion("PlaceEverywhere plugin") != -1) as float)
endfunction

; CRAFTING

function PatchConstructibleWorkbenchKeyword(ConstructibleObject akRecipe, int aiFormID, string asFileName) global
    akRecipe.SetWorkbenchKeyword(Game.GetFormFromFile(aiFormID, asFileName) as Keyword)
endfunction

; ITEM SORTING

struct ItemSortingData
    Form item
    string name
endstruct

bool function IsItemSortingEnabled() global
    return F4SE.GetPluginVersion("def_ui") != -1 && !MCM.GetModSettingBool("ZebrinasWorkshopDevices", "bDisableAutomaticItemSorting")
endfunction

function ApplyItemSortingPatch(ItemSortingData[] arrItemSortingData) global
    int i = 0
    while (i < arrItemSortingData.Length)
        arrItemSortingData[i].item.SetName(arrItemSortingData[i].name)
        i += 1
    endwhile
endfunction
