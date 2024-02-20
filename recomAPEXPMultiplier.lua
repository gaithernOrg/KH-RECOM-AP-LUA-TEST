LUAGUI_NAME = "recomAP"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "RE: Chain of Memories AP Integration"

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

xp_mult = 1
offset = 0x4E4660
frame_count = 0

function read_exp_multiplier()
    if file_exists(client_communication_path .. "xpmult.cfg") then
        file = io.open(client_communication_path .. "xpmult.cfg", "r")
        io.input(file)
        xp_mult = tonumber(io.read())
        io.close(file)
    else
        xp_mult = 1
    end
end

function write_exp_multiplier()
    exp_gem_calculation_table_address = 0x7BFC78 - offset
    exp_gem_vanilla_values = {1400, 99, 60, 30, 10, 5, 1}
    for i=1,7 do
        WriteInt(exp_gem_calculation_table_address + ((i-1)*8) + 4, math.max(math.floor(exp_gem_vanilla_values[i]/xp_mult),1))
    end
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
    if canExecute then
        if frame_count % 120 == 0 then
            read_exp_multiplier()
            write_exp_multiplier()
        end
        frame_count = frame_count + 1
    end
end