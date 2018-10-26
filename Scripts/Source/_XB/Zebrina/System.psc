scriptname Zebrina:System hidden
{ System specific code for easier xbone porting. This file is for Xbone. }

bool function IsPC() global
    return false
endfunction

function DetectPlacementMod(GlobalVariable akPlacementModGlobal) global
    akPlacementModGlobal.SetValue(Game.IsPluginInstalled("PlaceAnywhere.esp") as float)
endfunction

; CRAFTING

function PatchConstructibleWorkbenchKeyword(ConstructibleObject akRecipe, int aiFormID, string asFileName) global
endfunction

; ITEM SORTING

struct ItemSortingData
    Form item
    string name
endstruct

bool function IsItemSortingEnabled() global
    return false
endfunction

function ApplyItemSortingPatch(ItemSortingData[] arrItemSortingData) global
endfunction
