scriptname Zebrina:Workshop:OverdueBookVendorMasterScript extends Quest conditional

import DN011OverdueBookVendingMachineSCRIPT

group AutoFill
    GlobalVariable property WorkshopOverdueBookVendMachineResetDays auto const mandatory
    GlobalVariable property WorkshopOverdueBookVendMachineLastGlobalReset auto const mandatory
endgroup
group Required
    Zebrina:Workshop:OverdueBookVendorPrizeItem[] property PrizeItemAliases auto const mandatory
    Perk[] property HackerPerks auto const mandatory
endgroup

int iHackAttempts = 1 conditional

event OnInit()
    ; Give one hack attempt per 'Hacker' perk rank.
    Actor player = Game.GetPlayer()
    while (iHackAttempts <= HackerPerks.Length && player.HasPerk(HackerPerks[iHackAttempts - 1]))
        iHackAttempts += 1
    endwhile
endevent

function AccessTerminal(Zebrina:Workshop:OverdueBookVendorScript akBookVendorRef)
    float gameTime = Utility.GetCurrentGameTime()
    if (true || gameTime > (WorkshopOverdueBookVendMachineLastGlobalReset.GetValue() + WorkshopOverdueBookVendMachineResetDays.GetValue()))
        self.Stop()
        self.Start()
        WorkshopOverdueBookVendMachineLastGlobalReset.SetValue(gameTime)
        Zebrina:WorkshopUtility.DEBUGTraceSelf(self, "AccessTerminal", "reset at " + gameTime + " game days")
    endif
    if (akBookVendorRef.fLastInventoryReset < WorkshopOverdueBookVendMachineLastGlobalReset.GetValue())
        akBookVendorRef.ItemsInMachine = new ItemAndCount[0]
        int i = 0
        while (i < self.PrizeItemAliases.Length && akBookVendorRef.ItemsInMachine.Length <= 10)
            if (self.PrizeItemAliases[i].GetReference())
                akBookVendorRef.ItemsInMachine.Add(self.PrizeItemAliases[i].ConvertToItemAndCount())
            endif
            i += 1
        endwhile
        akBookVendorRef.fLastInventoryReset = WorkshopOverdueBookVendMachineLastGlobalReset.GetValue()
    endif
endfunction
function ReduceHackAttempts()
    iHackAttempts -= 1
endfunction
function HackTerminal(Zebrina:Workshop:OverdueBookVendorScript akBookVendorRef)
    ; Reduce all prizes by 50% on the specific terminal until reset.
    int i = 0
    while (i < akBookVendorRef.ItemsInMachine.Length)
        akBookVendorRef.ItemsInMachine[i].ItemCost = 0;Math.Min(1, akBookVendorRef.ItemsInMachine[i].ItemCost / 2) as int
        i += 1
    endwhile
endfunction
