LUAGUI_NAME = "recomAP"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "RE: Chain of Memories AP Integration"

game_version = 1 --1 for EGS 2 for Steam

function _OnInit()
    if GAME_ID == 0x9E3134F5 and ENGINE_TYPE == "BACKEND" then
        canExecute = true
        if ReadByte(0x4E6C80) == 15 or ReadByte(0x4E6AC0) == 242 then
            ConsolePrint("Epic Games Version Detected")
            game_version = 1
        elseif ReadByte(0x4E7040) == 15 or ReadByte(0x4E6DC0) == 77 then
            ConsolePrint("Steam Version Detected")
            game_version = 2
        end
    else
        ConsolePrint("RE:CoM not detected, not running script")
    end
end

function _OnFrame()
    if canExecute then
        watched_days_address = {0x87ABDC, 0x0}
        if ReadByte(watched_days_address[game_version]) == 0x0 then
            WriteByte(watched_days_address[game_version], 0x1)
        end
    end
end