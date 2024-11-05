LUAGUI_NAME = "recomAP"
LUAGUI_AUTH = "Gicu"
LUAGUI_DESC = "RE: Chain of Memories AP Integration"

game_version = 1 --1 for EGS 2 for Steam
canExecute = false

last_death_time = 0
last_hp = 100


if os.getenv('LOCALAPPDATA') ~= nil then
    client_communication_path = os.getenv('LOCALAPPDATA') .. "\\KHRECOM\\"
else
    client_communication_path = os.getenv('HOME') .. "/KHRECOM/"
    ok, err, code = os.rename(client_communication_path, client_communication_path)
    if not ok and code ~= 13 then
        os.execute("mkdir " .. path)
    end
end

function decimalToHex(num)
    if num == 0 then
        return '0'
    end
    local neg = false
    if num < 0 then
        neg = true
        num = num * -1
    end
    local hexstr = "0123456789ABCDEF"
    local result = ""
    while num > 0 do
        local n = math.fmod(num, 16)
        result = string.sub(hexstr, n + 1, n + 1) .. result
        num = math.floor(num / 16)
    end
    if neg then
        result = '-' .. result
    end
    return result
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function toBits(num)
    -- returns a table of bits, least significant first.
    local t={} -- will contain the bits
    while num>0 do
        rest=math.fmod(num,2)
        t[#t+1]=rest
        num=(num-rest)/2
    end
    return t
end

function get_current_hp()
    soras_current_hp_pointer_address = {0x87C5F8, 0x87CBF8}
    soras_current_hp_pointer = GetPointer(soras_hp_pointer_address[game_version])
    return ReadInt(soras_current_hp_pointer, true)
end

function kill_player()
    control_pointer_address = {0x0, 0x87B380}
    death_pointer_address = {0x0, 0x87B6B8}
    if ReadInt(control_pointer_address[game_version]) > 0 and  ReadInt(death_pointer_address[game_version]) > 0 then
        control_pointer = GetPointer(control_pointer_address[game_version])
        death_pointer = GetPointer(death_pointer_address[game_version])
        if toBits(ReadInt(death_pointer + 0x88, true))[3] ~= 1 then
            WriteInt(control_pointer + 0x4C, 29, true)
            WriteInt(death_pointer + 0x88, ReadInt(death_pointer + 0x88, true) + 4, true)
            WriteInt(death_pointer + 0x8C, 7, true)
        end
    end
end

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
    if canExecute then
        initialize()
    end
end

function _OnFrame()
    if canExecute then
        if file_exists(client_communication_path .. "dlreceive") then
                file = io.open(client_communication_path .. "dlreceive")
                io.input(file)
                death_time = tonumber(io.read())
                io.close(file)
                if death_time ~= nil and last_death_time ~= nil then
                    if death_time >= last_death_time + 3 then
                        kill_player()
                        last_death_time = death_time
                    end
                end
            end
            current_hp = get_current_hp()
            if current_hp == 0 and last_hp > 0 then
                ConsolePrint("Sending death")
                ConsolePrint("Player's HP: " .. tostring(current_hp))
                ConsolePrint("Player's Last HP: " .. tostring(last_hp))
                death_date = os.date("!%Y%m%d%H%M%S")
                if not file_exists(client_communication_path .. "dlsend" .. tostring(death_date)) then
                    file = io.open(client_communication_path .. "dlsend" .. tostring(death_date), "w")
                    io.output(file)
                    io.write("")
                    io.close(file)
                end
            end
            last_hp = get_current_hp()
        end
    end
end