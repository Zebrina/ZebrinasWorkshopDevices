scriptName Zebrina:Workshop:PaintMixerScript extends ObjectReference const

group PaintMixer
	Keyword property WorkshopObjectHandleActivation auto const mandatory
	Message property FFDiamondCity01NeedPaintMessage auto const mandatory
	Message property PaintMixerPurpleNeedPaintMessage auto const mandatory
	Message property PaintMixerOrangeNeedPaintMessage auto const mandatory
	Message property WorkshopPaintMixerMessage auto const mandatory
	MiscObject property PaintCanBlue auto const mandatory
	MiscObject property PaintCanYellow auto const mandatory
	MiscObject property PaintCanGreen auto const mandatory
	MiscObject property DLC04PaintCanRed auto const mandatory
	MiscObject property PaintCanPurple auto const mandatory
	MiscObject property PaintCanOrange auto const mandatory
endgroup

function MixPaint(ObjectReference akActionRef, MiscObject akPaint1, MiscObject akPaint2, MiscObject akPaintMixed, Message akNeedPaintMessage)
	if (akActionRef.GetItemCount(akPaint1) == 0 || akActionRef.GetItemCount(akPaint2) == 0)
		self.PlayAnimationAndWait("Play01", "End")
		akActionRef.AddItem(akPaintMixed, 2)
		akActionRef.RemoveItem(akPaint1)
		akActionRef.RemoveItem(akPaint2)
	else
		akNeedPaintMessage.Show()
	endif
endfunction

event OnActivate(ObjectReference akActionRef)
	if (!self.HasKeyword(WorkshopObjectHandleActivation) && Zebrina:WorkshopUtility.IsPlayerActionRef(akActionRef))
		self.AddKeyword(WorkshopObjectHandleActivation)

		int buttonPressed = WorkshopPaintMixerMessage.Show()
		if (buttonPressed == 1)
			MixPaint(akActionRef, PaintCanBlue, PaintCanYellow, PaintCanGreen, FFDiamondCity01NeedPaintMessage)
		elseif (buttonPressed == 2)
			MixPaint(akActionRef, PaintCanBlue, DLC04PaintCanRed, PaintCanPurple, PaintMixerPurpleNeedPaintMessage)
		elseif (buttonPressed == 3)
			MixPaint(akActionRef, DLC04PaintCanRed, PaintCanYellow, PaintCanOrange, PaintMixerOrangeNeedPaintMessage)
		endif

		self.ResetKeyword(WorkshopObjectHandleActivation)
	endif
endevent
