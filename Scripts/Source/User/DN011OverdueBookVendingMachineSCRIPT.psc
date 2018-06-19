Scriptname DN011OverdueBookVendingMachineSCRIPT extends ObjectReference Conditional


Group Required_Properties

	ItemAndCount[] Property ItemsInMachine Auto
	{Array of Items/Cost/Count Structs, which are unique to this specific machine.}

EndGroup


Group NoTouchy CollapsedOnRef

	DN011OverdueBooksQuest Property DN011OverdueBooksQuestVAR Auto Const Mandatory

	ReferenceAlias[] Property ItemAliases Auto Const
	{Array of Aliases we'll be forcing the refs into}
	GlobalVariable[] Property ItemCosts Auto Const Mandatory
	{Array of Globals we'll be forcing the costs into}
	GlobalVariable[] Property ItemCounts Auto Const Mandatory
	{Array of Globals we'll be forcing the counts into}

	GlobalVariable Property DN011OverdueBooksPlayerTokenCount Auto Mandatory
	{Global we'll be updating with the players total token count, for text replacement purposes}

	MiscObject Property DN011OverdueBookReturnToken Auto Const Mandatory
	{Token Object}
	MiscObject Property DN011OverdueBook Auto Const Mandatory
	{Book Object}

	Bool Property bSufficientFunds Auto Conditional ; true if the player has enough tokens to buy the current item of desire.
	Bool Property bOutOfStock Auto Conditional ; true if the item is out of stock and the player tries to buy it.

	Quest Property FFGoodneighbor02 Auto Const ;Quest to set the stage on if these are boston public library machines and this quest is running

EndGroup


Struct ItemAndCount
	ObjectReference ItemReference
	Int ItemCost
	Int ItemCount = -1
EndStruct
;Stores the Object Reference of the item, along with the cost, and inital count

Int ItemNumber ; Will hold the array index we are currently working with.
Int TotalItemCount Conditional


auto STATE RunOnLoad
	Event OnLoad()
		GoToState("DontRunOnLoad")
	    int count = 0
	    while (count < ItemsInMachine.Length)
	    	ItemsInMachine[count].ItemReference.DisableNoWait()
	    	count += 1
	    endwhile
	EndEvent
ENDSTATE

STATE DontRunOnLoad
	Event OnLoad()
		; Empty Event
	EndEvent
ENDSTATE

	; Handles the players attempt to buy an item.
Function TryToBuyItem()
	ObjectReference PlayerRef = Game.GetPlayer()
	ItemAndCount CurrentItemAndCount= ItemsInMachine[ItemNumber]

	;debug.Trace(self + "TryToBuyItem(" + ItemNumber + ")")
	;debug.Trace(self + "Player has " + PlayerRef.GetItemCount(DN011OverdueBookReturnToken) + " Tokens and the item " + (CurrentItemAndCount.ItemReference) + " costs " + ItemCosts[ItemNumber].GetValueInt())

		; If this item isn't out of stock
	if (ItemCounts[ItemNumber].GetValueInt() > 0)
			; And the player has enough tokens
		if ((PlayerRef.GetItemCount(DN011OverdueBookReturnToken)) >= ItemCosts[ItemNumber].GetValueInt())
			;debug.Trace(self + "Player has enough to buy this item!")
			; Removes the tokens from the player and gives him the item.
			PlayerRef.RemoveItem(DN011OverdueBookReturnToken, ItemCosts[ItemNumber].GetValueInt())
			PlayerRef.AddItem((CurrentItemAndCount.ItemReference.GetBaseObject()), 1)

			; Removes 1 from the item count
			CurrentItemAndCount.ItemCount = CurrentItemAndCount.ItemCount - 1
			ItemCounts[ItemNumber].SetValueInt(CurrentItemAndCount.ItemCount)

			; Lowers the players Token Count
			DN011OverdueBooksPlayerTokenCount.SetValueInt(PlayerRef.GetItemCount(DN011OverdueBookReturnToken))

			; Updats the globals for the quest
			DN011OverdueBooksQuestVAR.UpdateVendingMachineGlobalsForReplacement(ItemCosts)
			DN011OverdueBooksQuestVAR.UpdateVendingMachineGlobalsForReplacement(ItemCounts)
		endif
	endif
EndFunction

	; Checks if you have the means to buy a specific item, then saves them in variables for the terminal to use as conditions
Function CanBuyItem(int ItemNumberPassedIn)
	ItemNumber = ItemNumberPassedIn - 1
		; If this item isn't out of stock
	if (ItemCounts[ItemNumber].GetValueInt() > 0)
		bOutOfStock = FALSE
			; And the player has enough tokens
		if ((Game.GetPlayer().GetItemCount(DN011OverdueBookReturnToken)) >= ItemCosts[ItemNumber].GetValueInt())
			bSufficientFunds = TRUE
		else
			bSufficientFunds = FALSE
		endif
	else
		bOutOfStock = TRUE
	endif
EndFunction

	; Handles the player returning the books, and giving him 5 tokens per book returned.
Function TryToReturnBooks()
	ObjectReference PlayerRef = Game.GetPlayer()

	int BooksPlayerHas = PlayerRef.GetItemCount(DN011OverdueBook)
	if (BooksPlayerHas > 0)
		PlayerRef.AddItem(DN011OverdueBookReturnToken, BooksPlayerHas * 5)
		PlayerRef.RemoveItem(DN011OverdueBook, BooksPlayerHas)

		; Handle FFGoodneighbor02 if the quest is running and this machine is in BPL
		if FFGoodneighbor02.IsRunning()
			if FFGoodneighbor02.GetStageDone(10) &&!FFGoodneighbor02.GetStageDone(30)
				FFGoodneighbor02.SetStage(30)
			endif
		endif

	endif
EndFunction

	; When this vending machine is activated the attached terminal gets activated as well.
Event OnActivate(ObjectReference akActionRef)

	if (akActionRef == Game.GetPlayer())
		GetLinkedRef().Activate(akActionRef)
	endif
EndEvent

	; Updates the quest with all the correct item info so that they can be used for text replacement.
Function UpdateTotalItemCountAndAliases()

	DN011OverdueBooksPlayerTokenCount.SetValueInt(Game.GetPlayer().GetItemCount(DN011OverdueBookReturnToken))

	TotalItemCount = ItemsInMachine.Length

	int count = 0
	while (count < TotalItemCount)
		ItemAndCount CurrentItemInMachineCount = ItemsInMachine[count]
			; Force the reference into the correct alias
		ItemAliases[count].ForceRefTo(CurrentItemInMachineCount.ItemReference)
			; Set cost in global, and struct array, to the correct token cost based on value
		;ItemCosts[count].SetValueInt((CurrentItemInMachineCount.ItemReference).GetBaseObject().GetGoldValue())
		;CurrentItemInMachineCount.ItemCost = (CurrentItemInMachineCount.ItemReference).GetBaseObject().GetGoldValue()
			; If the cost in the struct is less than 1
		if CurrentItemInMachineCount.ItemCost < 1
			; Base the token value on the actual value of the tiem
			ItemCosts[count].SetValueInt(GetPrizeValue(CurrentItemInMachineCount.ItemReference))
			CurrentItemInMachineCount.ItemCost = GetPrizeValue(CurrentItemInMachineCount.ItemReference)
		else
			; else, base the token value on the value declaired in the struct
			ItemCosts[count].SetValueInt(CurrentItemInMachineCount.ItemCost)
		endif

			; Set count global to the one in the struct array
			; If the current 
		if CurrentItemInMachineCount.ItemCount == -1
			int iRandomInt = Utility.RandomInt(1,5)
			ItemCounts[count].SetValueInt(iRandomInt)
			CurrentItemInMachineCount.ItemCount = iRandomInt
		else 
			ItemCounts[count].SetValueInt(CurrentItemInMachineCount.ItemCount)
		endif
		count += 1
	endwhile
	DN011OverdueBooksQuestVAR.UpdateVendingMachineGlobalsForReplacement(ItemCosts)
	DN011OverdueBooksQuestVAR.UpdateVendingMachineGlobalsForReplacement(ItemCounts)
EndFunction


int Function GetPrizeValue(ObjectReference RefToCheckValueOf)
	if RefToCheckValueOf.GetBaseObject().GetGoldValue() > 0
		return (RefToCheckValueOf.GetBaseObject().GetGoldValue()) * 2
	else
		return 5
	endif
EndFunction