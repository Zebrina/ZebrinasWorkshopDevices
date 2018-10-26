scriptname Zebrina:WorkshopUtility hidden

import Math

struct ThreadLock
    bool locked = false
endstruct

function LockThread(ThreadLock tLock, float afSleep = 0.01) global
    while (tLock.locked)
        Utility.Wait(afSleep)
    endwhile
    tLock.locked = true
endfunction
function UnlockThread(ThreadLock tLock) global
    tLock.locked = false
endfunction

function LockThreadToReference(ObjectReference akLockTarget, Keyword akLockKeyword, float afSleep = 0.01) global
    while (akLockTarget.HasKeyword(akLockKeyword))
        Utility.Wait(afSleep)
    endwhile
    akLockTarget.AddKeyword(akLockKeyword)
endfunction
function UnlockThreadFromReference(ObjectReference akLockTarget, Keyword akLockKeyword) global
    akLockTarget.ResetKeyword(akLockKeyword)
endfunction

float function atan2(float y, float x) global
    if (x > 0.0)
        return Math.atan(y / x)
    elseif (x < 0.0)
        if (y >= 0)
            return atan(y / x) + 180.0
        else
            return atan(y / x) - 180.0
        endif
    elseif (y > 0.0)
        return 90.0
    elseif (y < 0.0)
        return -90.0
    endif

    ; Undefined!
    return 0.0
endfunction

; Mostly for debugging.
string function IntToHexStr(int aiInteger) global
    string prefix = ""
    if (aiInteger >= 16)
        prefix = IntToHexStr(aiInteger / 16)
    endif
    aiInteger = aiInteger % 16
    if (aiInteger == 15)
        return prefix + "f"
    elseif (aiInteger == 14)
        return prefix + "e"
    elseif (aiInteger == 13)
        return prefix + "d"
    elseif (aiInteger == 12)
        return prefix + "c"
    elseif (aiInteger == 11)
        return prefix + "b"
    elseif (aiInteger == 10)
        return prefix + "a"
    endif
    return prefix + (aiInteger as string)
endfunction

bool function IsPlayerActionRef(ObjectReference akActionRef) global
    return akActionRef == Game.GetPlayer() || (akActionRef is Actor && (akActionRef as Actor).IsDoingFavor())
endfunction

WorkshopParentScript function GetWorkshopParent() global
    return Game.GetForm(0x0002058e) as WorkshopParentScript
endfunction
WorkshopScript function GetCurrentWorkshop() global
    WorkshopScript currentWorkshop = (GetWorkshopParent().GetAlias(76) as ReferenceAlias).GetReference() as WorkshopScript
    if (currentWorkshop && Game.GetPlayer().IsInLocation(currentWorkshop.myLocation))
        return currentWorkshop
    endif
    return none
endfunction
ObjectReference function GetObjectWorkshop(ObjectReference akReference) global
    return akReference.GetLinkedRef(Game.GetForm(0x54ba6) as Keyword)
endfunction
int function GetPlayerComponentCount(Component akComponent) global
    int count = Game.GetPlayer().GetComponentCount(akComponent)
    WorkshopScript currentWorkshop = GetCurrentWorkshop()
    if (currentWorkshop)
        count += currentWorkshop.GetComponentCount(akComponent)
    endif
    return count
endfunction
function PlayerRemoveComponents(Component akComponent, int aiNumToRemove = 1) global
    Actor player = Game.GetPlayer()
    int playerCount = player.GetComponentCount(akComponent)
    int removedDelta = playerCount - aiNumToRemove

    if (removedDelta >= 0)
        player.RemoveComponents(akComponent, aiNumToRemove)
    else
        player.RemoveComponents(akComponent, playerCount)

        WorkshopScript currentWorkshop = GetCurrentWorkshop()
        if (currentWorkshop)
            int workshopCount = currentWorkshop.GetComponentCount(akComponent)
            removedDelta = workshopCount + removedDelta ; removedDelta is negative here!
            if (removedDelta >= 0)
                currentWorkshop.RemoveComponents(akComponent, aiNumToRemove - playerCount)
            else
                currentWorkshop.RemoveComponents(akComponent, workshopCount)
            endif
        endif
    endif
endfunction

function RestoreWorkshopMenu() global
    (Game.GetForm(0x00106da2) as FormList).Revert()
endfunction

; DEBUG

bool function GetDebugGlobalValue() global debugonly
    return (Game.GetFormFromFile(0x007f54, "ZebrinasWorkshopDevices.esp") as GlobalVariable).GetValue() != 0.0
endfunction

function DEBUGTrace(string asTextToPrint, int aiSeverity = 0) global debugonly
    Debug.TraceUser("ZebrinasWorkshopDevices", asTextToPrint, aiSeverity)
endfunction
function DEBUGTraceSelf(ScriptObject akCallingScript, string asFunctionName, string asTextToPrint, int aiSeverity = 0) global debugonly
    DEBUGTrace(akCallingScript + "-->" + asFunctionName + "(): " + asTextToPrint, aiSeverity)
endfunction
function DEBUGTraceConditional(string asTextToPrint, bool abShowTrace, int aiSeverity = 0) global debugonly
    if (abShowTrace)
        DEBUGTrace(asTextToPrint, aiSeverity)
    endif
endfunction
function DEBUGTraceSelfConditional(ScriptObject akCallingScript, string asFunctionName, string asTextToPrint, bool abShowTrace, int aiSeverity = 0) global debugonly
    if (abShowTrace)
        DEBUGTraceSelf(akCallingScript, asFunctionName, asTextToPrint, aiSeverity)
    endif
endfunction

function DEBUGRemoveBlockPlayerActivationKeyword(ObjectReference akReference) global debugonly
    akReference.RemoveKeyword(Game.GetForm(0x001cd02b) as Keyword)
endfunction

; cgf "Zebrina:WorkshopUtility.DEBUGEnableAllOfType"
function DEBUGEnableAllOfType(Form akBaseObject) global debugonly
    ObjectReference[] refs = Game.GetPlayer().FindAllReferencesOfType(akBaseObject, 999999.0)
    if (refs.Length > 0)
        int enabledCount = 0
        int i = 0
        while (i < refs.Length)
            if (!refs[i].IsDeleted())
                refs[i].EnableNoWait()
                enabledCount += 1
            endif
            i += 1
        endwhile
        if (enabledCount > 0)
            Debug.MessageBox("Enabled " + refs.Length + " references that were not deleted.")
        endif
    endif
endfunction
