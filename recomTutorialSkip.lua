LUAGUI_NAME = "recomTutorialSkip"
LUAGUI_AUTH = "KSX and Gicu"
LUAGUI_DESC = "Tutorial Skip"

local offset = 0x4E4660
canExecute = false

function _OnInit()
    if GAME_ID == 0x9E3134F5 and ENGINE_TYPE == "BACKEND" then
        ConsolePrint("RE:CoM detected, running script")
        canExecute = true
    else
        ConsolePrint("RE:CoM not detected, not running script")
    end
end

function _OnFrame()
    if canExecute then
        CardsTutorial = ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(0x8778B0 - offset)+0x5C0, true)+0x58, true)+0x60, true)+0x8, true)+0xA0, true)+0x80, true)+0x0, true
        if ReadByte(CardsTutorial, true) == 10 then
            WriteArray(CardsTutorial, {0x5A, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x0C}, true)
        end
    end
end