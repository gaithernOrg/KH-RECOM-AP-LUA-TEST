LUAGUI_NAME = "recomTutorialSkip"
LUAGUI_AUTH = "KSX and Gicu"
LUAGUI_DESC = "Tutorial Skip"

local offset = 0x4E4660
canExecute = false

function get_room_byte()
    room_byte_pointer_offset = 0x394D38
    room_byte_value_offset = 0x18
    room_byte_pointer = GetPointer(room_byte_pointer_offset, room_byte_value_offset)
    return ReadByte(room_byte_pointer, true)
end


function _OnInit()
    if GAME_ID == 0x9E3134F5 and ENGINE_TYPE == "BACKEND" then
        ConsolePrint("RE:CoM detected, running script")
        canExecute = true
    else
        ConsolePrint("RE:CoM not detected, not running script")
    end
end

function _OnFrame()
    if canExecute and get_room_byte() == 0 then
        CardsTutorial = ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(0x8778B0 - offset)+0x5C0, true)+0x58, true)+0x60, true)+0x8, true)+0xA0, true)+0x80, true)+0x0, true
        if ReadByte(CardsTutorial, true) == 10 then
            WriteArray(CardsTutorial, {0x5A, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x0C}, true)
        end
    end
end