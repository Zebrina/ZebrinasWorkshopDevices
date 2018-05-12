scriptname Zebrina:Workshop:LadderScript extends ObjectReference const

group AutoFill
    Keyword property WorkshopLinkLadder auto const mandatory
endgroup
group LadderProperties
    bool property bIsBottomLadder = true auto const
endgroup

bool function IsStacked(ObjectReference akCurrentLadderRef, ObjectReference akNextLadderRef)
    if (bIsBottomLadder)
        ; Going from bottom to top.
        return akNextLadderRef.GetPositionZ() > akCurrentLadderRef.GetPositionZ()
    endif
    ; Going from top to bottom.
    return akNextLadderRef.GetPositionZ() < akCurrentLadderRef.GetPositionZ()
endfunction

function ClimbLadder(ObjectReference akTargetRef, ObjectReference akLadderRef)
    ObjectReference linkedRef = akLadderRef.GetLinkedRef(WorkshopLinkLadder)
    if (linkedRef && IsStacked(akLadderRef, linkedRef))
        ClimbLadder(akTargetRef, linkedRef)
    else
        linkedRef = none
        ObjectReference[] refsLinked = akLadderRef.GetRefsLinkedToMe(WorkshopLinkLadder)
        int i = 0
        while (!linkedRef && i < refsLinked.Length)
            if (IsStacked(akLadderRef, refsLinked[i]))
                linkedRef = refsLinked[i]
            endif
            i += 1
        endwhile
        if (linkedRef)
            ClimbLadder(akTargetRef, linkedRef)
        elseif (akLadderRef.HasNode("LADDER_NODE"))
            akTargetRef.MoveToNode(akLadderRef, "LADDER_NODE")
        endif
    endif
endfunction

event OnActivate(ObjectReference akActionRef)
    ClimbLadder(akActionRef, self)
endevent
