scriptname Zebrina:Workshop:OverdueBookVendorPrizeItem extends ReferenceAlias const

import DN011OverdueBookVendingMachineSCRIPT

int property CountMin = 1 auto const
int property CountMax = 1 auto const
float property CostMult = 1.0 auto const
int property CostOverride = 0 auto const

event OnAliasInit()
    self.GetReference().DisableNoWait()
endevent

int Function GetPrizeValue()
    int cost = CostOverride
    if (CostOverride == 0)
        cost = self.GetReference().GetBaseObject().GetGoldValue()
    endif

    if (cost > 0)
        return cost
    endif
    return 5
EndFunction

ItemAndCount function ConvertToItemAndCount()
    ItemAndCount itemData = new ItemAndCount
    itemData.itemReference = self.GetReference()
    itemData.itemCost = (GetPrizeValue() as float * CostMult) as int
    itemData.itemCount = Utility.RandomInt(CountMin, CountMax)
    return itemData
endfunction
