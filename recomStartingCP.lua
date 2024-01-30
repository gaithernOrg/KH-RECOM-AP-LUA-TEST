LUAGUI_NAME = "recomStartingCP"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "Handles Alternative Starting CP

if os.getenv('LOCALAPPDATA') ~= nil then
    client_communication_path = os.getenv('LOCALAPPDATA') .. "\\KHRECOM\\"
else
    client_communication_path = os.getenv('HOME') .. "/KHRECOM/"
    ok, err, code = os.rename(client_communication_path, client_communication_path)
    if not ok and code ~= 13 then
        os.execute("mkdir " .. path)
    end
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local offset = 0x4E4660
canExecute = false
starting_cp = 275
frame_count = 0

function read_starting_cp()
    if file_exists(client_communication_path .. "startcp.cfg") then
        file = io.open(client_communication_path .. "startcp.cfg", "r")
        io.input(file)
        starting_cp = tonumber(io.read())
        io.close(file)
    else
        starting_cp = 275
    end
end

function main()
    max_cp_pointer_address = 0x8793F8 - offset
    max_cp_pointer_offset = 0xC
    max_cp_pointer = GetPointer(max_cp_pointer_address, max_cp_pointer_offset)
    max_cp = ReadInt(max_cp_pointer, true)
    if max_cp < starting_cp then
        WriteInt(max_cp_pointer, starting_cp, true)
    end
end

function _OnInit()
    if GAME_ID == 0x9E3134F5 and ENGINE_TYPE == "BACKEND" then
        ConsolePrint("RE:CoM detected, running script")
        canExecute = true
    end
end

function _OnFrame()
    if canExecute then
        if frame_count % 120 == 0 then
            read_starting_cp()
            main()
        end
        frame_count = frame_count + 1
    end
end