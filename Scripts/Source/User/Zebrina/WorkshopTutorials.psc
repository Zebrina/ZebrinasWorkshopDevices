scriptname Zebrina:WorkshopTutorials extends Quest

struct WorkshopTutorial
    bool shown = false hidden
    string id
    Message messageToShow
endstruct

WorkshopTutorial[] property Tutorials auto mandatory

function ShowTutorial(string asTutorialID) global
    int tutorialIndex = Tutorials.FindStruct("id", asTutorialID)
    if (tutorialIndex >= 0 && !Tutorials[tutorialIndex].shown)
        WorkshopTutorial tutorial = Tutorials[tutorialIndex]
        if (!tutorial.shown)
            tutorial.messageToShow.Show()
            tutorial.shown = true
        endif
    endif
endfunction

function ResetTutorials()
    int i = 0
    while (i < )
endfunction
