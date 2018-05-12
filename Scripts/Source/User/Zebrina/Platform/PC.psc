scriptname Zebrina:Platform:PC hidden
{ Compile as DEBUG. }

bool function IsPC() global
    return Debug.GetPlatformName()
endfunction
