scriptname Zebrina:System hidden
{ Most (not all) system specific code is here to make porting easier. }

bool function IsPC() global
    return true
endfunction

bool function IsItemSortingEnabled() global
    return F4SE.GetPluginVersion("def_ui") != -1 && !MCM.GetModSettingBool("ZebrinasWorkshopDevices", "bDisableAutomaticItemSorting")
endfunction
