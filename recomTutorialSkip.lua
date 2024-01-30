LUAGUI_NAME = "recomTutorialSkip"
LUAGUI_AUTH = "KSX"
LUAGUI_DESC = "Tutorial Skip"

local offset = 0x4E4660

function _OnInit()
    if GAME_ID == 0x9E3134F5 and ENGINE_TYPE == "BACKEND" then
        ConsolePrint("Tutorial Skip - installed")
    end
end

function _OnFrame()
    if ReadByte(CardsTutorial, true) == 10 then
        WriteArray(CardsTutorial, {0x5A, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x0C}, true)
    end
end