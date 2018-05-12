scriptname Zebrina:System:PC hidden
{ Must be compiled with DEBUG settings. }

bool function IsPC() global
    return Debug.GetPlatformName()
endfunction
