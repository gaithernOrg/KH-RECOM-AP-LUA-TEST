LUAGUI_NAME = "recomTutorialSkip"
LUAGUI_AUTH = "KSX and Gicu"
LUAGUI_DESC = "Tutorial Skip"

local offset = 0x4E4660
canExecute = false

function _OnInit()
    if GAME_ID == 0x9E3134F5 and ENGINE_TYPE == "BACKEND" then
        ConsolePrint("Tutorial Skip - installed")
        canExecute = true
    end
end

function _OnFrame()
    if canExecute then
        --SKIP BATTLE TUTORIAL--
        CardsTutorial = ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(0x8778B0 - offset)+0x5C0, true)+0x58, true)+0x60, true)+0x8, true)+0xA0, true)+0x80, true)+0x0, true
        if ReadByte(CardsTutorial, true) == 10 then
            WriteArray(CardsTutorial, {0x5A, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x0C}, true)
        end
        --SKIP BATTLE TUTORIAL--
        
        --SKIP FIELD TUTORIALS--
        base_pointer_offset = 0x8778E0 - offset
        base_offset_1 = 0x8
        base_offset_2 = 0x300
        base_pointer_1 = GetPointer(time_played_pointer_offset, time_played_offset_1)
        base_pointer_2 = GetPointer(time_played_pointer_1, time_played_offset_2, true)
        tutorial_bits_offset = 0x80
        WriteByte(base_pointer_2 + tutorial_bits_offset, 0xFF, true)
        --SKIP FIELD TUTORIALS--
        
        --SKIP LEON TUTORIAL--
        rooms_opened_pointer_address = 0x879398 - offset
        rooms_opened_pointer_offset = 0x18
        rooms_opened_pointer = GetPointer(rooms_opened_pointer_address, rooms_opened_pointer_offset)
        WriteByte(rooms_opened_pointer, 01, true)
        --SKIP LEON TUTORIAL--
    end
end