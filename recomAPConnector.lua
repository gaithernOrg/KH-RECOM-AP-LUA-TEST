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

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, tonumber(str))
    end
    return t
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

function slurp(path)
    local f = io.open(path)
    local s = f:read("*a")
    f:close()
    return s
end

world_order = {2,3,4,5,6,7,8,9,10}
attack_power = 10
canExecute = false
offset = 0x4E4660
frame_count = 1
card_set_data = {{0,1,2,3,4,5,6,7,8,9},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}
card_set_data_reset_value = 2
card_set_data_read = false

function get_journal_array()
    journal_byte_pointer_offset = 0x879408 - offset
    journal_byte_value_offset = 0x11B
    journal_byte_pointer = GetPointer(journal_byte_pointer_offset, journal_byte_value_offset)
    return ReadArray(journal_byte_pointer, 108, true)
end

function get_heartless_array()
    journal_heartless_pointer_address = 0x879408 - offset
    journal_heartless_pointer_offset = 0x1F4
    journal_heartless_pointer = GetPointer(journal_heartless_pointer_address, journal_heartless_pointer_offset)
    return ReadArray(journal_heartless_pointer, 62, true)
end

function get_room_array()
    room_byte_pointer_offset = 0x879398 - offset
    room_byte_value_offset = 0x18
    room_byte_pointer = GetPointer(room_byte_pointer_offset, room_byte_value_offset)
    room_array = ReadArray(room_byte_pointer, 39, true)
    return room_array
end

function get_current_floor()
    return ReadByte(0x878044 - offset)
end

function get_time_played()
    time_played_pointer_offset = 0x8778E0 - offset
    time_played_offset_1 = 0x8
    time_played_offset_2 = 0x300
    time_played_pointer_1 = GetPointer(time_played_pointer_offset, time_played_offset_1)
    time_played_pointer_2 = GetPointer(time_played_pointer_1, time_played_offset_2, true)
    time_played = ReadInt(time_played_pointer_2, true)
    return time_played
end

function get_empty_battle_cards_array()
    card_array = {}
    i = 1
    while i <= 870 do
        card_array[i] = 0
        i = i + 1
    end
    return card_array
end

function get_empty_enemy_cards_array()
    enemy_cards_array = {}
    i = 1
    while i <= 57 do
        enemy_cards_array[i] = 0
        i = i + 1
    end
    return enemy_cards_array
end

function get_empty_world_assignment_array()
    world_assignment_array = {1,1,1,1,1,1,1,1,1,1,1,1,1}
    return world_assignment_array
end

function get_empty_friends_array()
    friends_array = {0,0,0,0,0,0,0,0}
    return friends_array
end

function get_empty_gold_map_cards_array()
    gold_map_cards_array = {0,0,0,0}
    return gold_map_cards_array
end

function get_empty_sleights_array()
    sleights_array = {}
    for i=1,84 do
        sleights_array[i] = 0
    end
    return sleights_array
end

function get_calculated_cutscene_array()
    journal_array_pointer_address = 0x879408 - offset
    axel_1_offset    = 0x132 --01F
    larxene_1_offset = 0x134 --06F
    riku_1_offset    = 0x138 --07F
    vexen_1_offset   = 0x84  --10F
    larxene_2_offset = 0x185 --12F

    journal_array_pointer = GetPointer(journal_array_pointer_address)
    
    axel_1_defeated             = ReadByte(journal_array_pointer + axel_1_offset   , true) > 0
    larxene_1_defeated          = ReadByte(journal_array_pointer + larxene_1_offset, true) > 0
    riku_1_defeated             = ReadByte(journal_array_pointer + riku_1_offset   , true) > 0
    vexen_1_defeated            = ReadByte(journal_array_pointer + vexen_1_offset  , true) > 0
    larxene_2_defeated          = ReadByte(journal_array_pointer + larxene_2_offset, true) > 0
    
    if axel_1_defeated and larxene_1_defeated and riku_1_defeated and vexen_1_defeated and larxene_2_defeated then --Clear
        cutscene_array = {0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x04, 0x00, 0x05, 0x00, 0x06, 0x00, 0x07, 0x00, 0x08, 0x00, 0x09, 0x00, 0x0A, 0x00, 0x0B, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0x0E, 0x00, 0x0F, 
                0x00, 0x10, 0x00, 0x11, 0x00, 0x12, 0x00, 0x13, 0x00, 0x14, 0x00, 0x15, 0x00, 0x16, 0x00, 0x17, 0x00, 0x18, 0x00}
    elseif axel_1_defeated and larxene_1_defeated and riku_1_defeated and vexen_1_defeated then--Riku IV and Larxene II
        cutscene_array = {0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x04, 0x00, 0x05, 0x00, 0x06, 0x00, 0x07, 0x00, 0x08, 0x00, 0x09, 0x00, 0x0A, 0x00, 0x0B, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0x0E, 0x00, 0x0F, 
                0x00, 0x10, 0x00, 0x11, 0x00, 0x12, 0x00, 0x13, 0x00, 0x14, 0x00, 0x15, 0x00, 0x16, 0x00, 0x17, 0x00, 0xE8, 0x07}
    elseif axel_1_defeated and larxene_1_defeated and riku_1_defeated then --Vexen I
        cutscene_array = {0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x04, 0x00, 0x05, 0x00, 0x06, 0x00, 0x07, 0x00, 0x08, 0x00, 0x09, 0x00, 0x0A, 0x00, 0x0B, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0x0E, 0x00, 0x0F, 
                0x00, 0x10, 0x00, 0x11, 0x00, 0x12, 0x00, 0x13, 0x00, 0xE4, 0x07, 0x15, 0x00, 0x16, 0x00, 0x17, 0x00, 0x18, 0x00}
    elseif axel_1_defeated and larxene_1_defeated then --Riku I
        cutscene_array = {0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x04, 0x00, 0x05, 0x00, 0x06, 0x00, 0x07, 0x00, 0x08, 0x00, 0x09, 0x00, 0x0A, 0x00, 0x0B, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0xDE, 0x07, 0x0F, 
                0x00, 0x10, 0x00, 0x11, 0x00, 0x12, 0x00, 0x13, 0x00, 0x14, 0x00, 0x15, 0x00, 0x16, 0x00, 0x17, 0x00, 0x18, 0x00}
    elseif axel_1_defeated then --Larxene I
        cutscene_array = {0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x04, 0x00, 0x05, 0x00, 0x06, 0x00, 0x07, 0x00, 0x08, 0x00, 0x09, 0x00, 0x0A, 0x00, 0x0B, 0x00, 0xDC, 0x07, 0x0D, 0x00, 0x0E, 0x00, 0x0F, 
                0x00, 0x10, 0x00, 0x11, 0x00, 0x12, 0x00, 0x13, 0x00, 0x14, 0x00, 0x15, 0x00, 0x16, 0x00, 0x17, 0x00, 0x18, 0x00}
    else --Axel I
        cutscene_array = {0x01, 0x00, 0xD2, 0x07, 0x03, 0x00, 0x04, 0x00, 0x05, 0x00, 0x06, 0x00, 0x07, 0x00, 0x08, 0x00, 0x09, 0x00, 0x0A, 0x00, 0x0B, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0x0E, 0x00, 0x0F, 
                0x00, 0x10, 0x00, 0x11, 0x00, 0x12, 0x00, 0x13, 0x00, 0x14, 0x00, 0x15, 0x00, 0x16, 0x00, 0x17, 0x00, 0x18, 0x00}
    end
    return cutscene_array
end

function get_world_assignments_array()
    world_assignment_array_pointer_address = 0x879398 - offset
    world_assignment_array_pointer_offset = 0x48
    world_assignment_array_pointer = GetPointer(world_assignment_array_pointer_address, world_assignment_array_pointer_offset)
    return ReadArray(world_assignment_array_pointer, 39, true)
end

function get_friend_cards_array()
    friend_byte_pointer_offset = 0x879408 - offset
    friend_byte_value_offset = 0x147
    friend_byte_pointer = GetPointer(friend_byte_pointer_offset, friend_byte_value_offset)
    friends_array = ReadArray(friend_byte_pointer, 8, true)
    return friends_array
end

function get_rewards_bounties_array()
    rewards_bounties_array_pointer_address = 0x8793D0 - offset
    rewards_bounties_array_pointer_offset = 0xE1
    rewards_bounties_array_pointer = GetPointer(rewards_bounties_array_pointer_address, rewards_bounties_array_pointer_offset)
    rewards_bounties_array = ReadArray(rewards_bounties_array_pointer, 46, true)
    return rewards_bounties_array
end

function get_minigames_array()
    minigames_array_pointer_address = 0x879408 - offset
    minigames_array_pointer_offset = 0x1EE
    mingames_array_pointer = GetPointer(minigames_array_pointer_address, minigames_array_pointer_offset)
    mingames_array = ReadArray(mingames_array_pointer, 6, true)
    return minigames_array
end

function get_extra_checks()
    ids = {}
    journal_array = get_journal_array()
    if journal_array[24] > 0 then --Fire
        ids[#ids+1] = 2692010
        ids[#ids+1] = 2692017
    end
    if journal_array[25] > 0 then --Blizzard
        ids[#ids+1] = 2692011
        ids[#ids+1] = 2692018
    end
    if journal_array[26] > 0 then --Thunder
        ids[#ids+1] = 2692012
        ids[#ids+1] = 2692019
    end
    if journal_array[27] > 0 then --Cure
        ids[#ids+1] = 2692013
        ids[#ids+1] = 2692020
    end
    if journal_array[28] > 0 then --Gravity
        ids[#ids+1] = 2692014
        ids[#ids+1] = 2692021
    end
    if journal_array[29] > 0 then --Stop
        ids[#ids+1] = 2692015
        ids[#ids+1] = 2692022
    end
    if journal_array[30] > 0 then --Aero
        ids[#ids+1] = 2692016
        ids[#ids+1] = 2692023
    end
    if journal_array[31] > 0 then --Simba
        ids[#ids+1] = 2692049
        ids[#ids+1] = 2692050
    end
    if journal_array[32] > 0 then --Genie
        ids[#ids+1] = 2692058
        ids[#ids+1] = 2692059
    end
    if journal_array[33] > 0 then --Bambi
        ids[#ids+1] = 2692053
        ids[#ids+1] = 2692054
    end
    if journal_array[34] > 0 then --Dumbo
        ids[#ids+1] = 2692051
        ids[#ids+1] = 2692052
    end
    if journal_array[35] > 0 then --Tinker Bell
        ids[#ids+1] = 2692060
        ids[#ids+1] = 2692061
    end
    if journal_array[36] > 0 then --Mushu
        ids[#ids+1] = 2692056
        ids[#ids+1] = 2692057
    end
    if journal_array[37] > 0 then --Cloud
        ids[#ids+1] = 2692062
        ids[#ids+1] = 2692063
    end
    
    rewards_bounties_array = get_rewards_bounties_array()
    if rewards_bounties_array[2] > 0 then --Warp
        ids[#ids+1] = 2692041
    end
    if rewards_bounties_array[4] > 0 then --Synchro
        ids[#ids+1] = 2692045
    end
    if rewards_bounties_array[5] > 0 then --Aqua Splash
        ids[#ids+1] = 2692034
    end
    if rewards_bounties_array[6] > 0 then --Bind
        ids[#ids+1] = 2692042
    end
    if rewards_bounties_array[7] > 0 then --Quake
        ids[#ids+1] = 2692039
    end
    if rewards_bounties_array[8] > 0 then --Thunder Raid
        ids[#ids+1] = 2692026
    end
    if rewards_bounties_array[11] > 0 then --Stardust Blitz
        ids[#ids+1] = 2692067
    end
    if rewards_bounties_array[36] > 0 then --Blizzard Raid
        ids[#ids+1] = 2692025
    end
    if rewards_bounties_array[38] > 0 then --Fire Raid
        ids[#ids+1] = 2692024
    end
    if rewards_bounties_array[39] > 0 then --Gifted Miracle
        ids[#ids+1] = 2692046
    end
    if rewards_bounties_array[40] > 0 then --Shock Impact
        ids[#ids+1] = 2692037
    end
    if rewards_bounties_array[40] > 1 then --Homing Blizzara
        ids[#ids+1] = 2692033
    end
    if rewards_bounties_array[41] > 0 then --Teleport
        ids[#ids+1] = 2692047
    end
    if rewards_bounties_array[42] > 0 then --Reflect Raid
        ids[#ids+1] = 2692027
    end
    if rewards_bounties_array[44] > 0 then --Warpinator
        ids[#ids+1] = 2692040
    end
    if rewards_bounties_array[45] > 0 then --Judgement
        ids[#ids+1] = 2692028
    end
    if rewards_bounties_array[46] > 0 then --Raging Storm
        ids[#ids+1] = 2692030
    end
    
    friend_array = get_friend_cards_array()
    if friend_array[1] > 0 then --Donald
        ids[#ids+1] = 2692065
        ids[#ids+1] = 2692066
    end
    if friend_array[2] > 0 then --Goofy
        ids[#ids+1] = 2692068
        ids[#ids+1] = 2692069
        ids[#ids+1] = 2692070
        ids[#ids+1] = 2692071
    end
    if friend_array[3] > 0 then --Aladdin
        ids[#ids+1] = 2692072
        ids[#ids+1] = 2692073
    end
    if friend_array[4] > 0 then --Ariel
        ids[#ids+1] = 2692076
        ids[#ids+1] = 2692077
    end
    if friend_array[5] > 0 then --Jack
        ids[#ids+1] = 2692044
        ids[#ids+1] = 2692074
        ids[#ids+1] = 2692075
    end
    if friend_array[6] > 0 then --Peter Pan
        ids[#ids+1] = 2692078
        ids[#ids+1] = 2692079
    end
    if friend_array[7] > 0 then --Beast
        ids[#ids+1] = 2692080
        ids[#ids+1] = 2692081
    end
    if friend_array[8] > 0 then --Pluto
        ids[#ids+1] = 2692082
        ids[#ids+1] = 2692083
    end
    
    minigames_array = get_minigames_array()
    if mingames_array[1] > 0 then --Firaga Burst
        ids[#ids+1] = 2692029
    end
    if mingames_array[4] > 0 then --Idyll Romp
        ids[#ids+1] = 2692055
    end
    if mingames_array[5] > 0 then --Cross-Slash +
        ids[#ids+1] = 2692064
    end
    
    journal_array_pointer_address = 0x879408 - offset
    vexen_1_offset   = 0x84  --10F
    journal_array_pointer = GetPointer(journal_array_pointer_address)
    if ReadByte(journal_array_pointer + vexen_1_offset  , true) > 0 then --Freeze
        ids[#ids+1] = 2692032
    end
    
    soras_level = get_soras_level()
    if soras_level >= 2 then --Sliding Dash
        ids[#ids+1] = 2692001
    end
    if soras_level >= 7 then --Stun Impact
        ids[#ids+1] = 2692003
    end
    if soras_level >= 12 then --Strike Raid
        ids[#ids+1] = 2692005
    end
    if soras_level >= 17 then --Blitz
        ids[#ids+1] = 2692002
    end
    if soras_level >= 22 then --Zantetsuken
        ids[#ids+1] = 2692004
    end
    if soras_level >= 27 then --Sonic Blade
        ids[#ids+1] = 2692006
    end
    if soras_level >= 32 then --Lethal Frame
        ids[#ids+1] = 2692036
    end
    if soras_level >= 37 then --Tornado
        ids[#ids+1] = 2692038
    end
    if soras_level >= 42 then --Ars Arcanum
        ids[#ids+1] = 2692007
    end
    if soras_level >= 47 then --Holy
        ids[#ids+1] = 2692048
    end
    if soras_level >= 52 then --Raganarok
        ids[#ids+1] = 2692008
    end
    if soras_level >= 57 then --Mega Flare
        ids[#ids+1] = 2692031
    end
    
    world_assignment_array = get_world_assignments_array()
    if world_assignment_array[13] > 1 then --Trinity Limit
        ids[#ids+1] = 2692009
    end
    
    if piglet_found() then
        ids[#ids+1] = 2692043
    end
    
    return ids
end

function get_soras_level()
    soras_level_pointer_address = 0x8793F8 - offset
    soras_level_pointer_offset = 0x1C
    soras_level_pointer = GetPointer(soras_level_pointer_address, soras_level_pointer_offset)
    soras_level = ReadInt(soras_level_pointer, true)
    return soras_level
end

function set_gold_map_cards(gold_map_cards_array)
    gold_map_cards_pointer_offset = 0x876FF0 - offset
    gold_map_cards_value_offset = 0x2
    gold_map_cards_pointer = GetPointer(gold_map_cards_pointer_offset, gold_map_cards_value_offset)
    WriteArray(gold_map_cards_pointer, gold_map_cards_array, true)
end

function set_battle_cards(battle_cards_array)
    cards_pointer_offset = 0x8793F8 - offset
    card_value_offset = -0xD74
    cards_pointer = GetPointer(cards_pointer_offset, card_value_offset)
    WriteArray(cards_pointer, battle_cards_array, true)
end

function set_enemy_cards(enemy_cards_array)
    enemy_cards_pointer_offset = 0x8793F8 - offset
    enemy_cards_value_offset = -0x914
    enemy_cards_pointer = GetPointer(enemy_cards_pointer_offset, enemy_cards_value_offset)
    WriteArray(enemy_cards_pointer, enemy_cards_array, true)
end

function set_world_assignment(world_assignment_array)
    world_assignment_pointer_offset = 0x879398 - offset
    world_assignment_value_offset = 0x48
    world_assignment_pointer = GetPointer(world_assignment_pointer_offset, world_assignment_value_offset)
    current_world_assignments = ReadArray(world_assignment_pointer, #world_assignment_array, true)
    current_floor = get_current_floor()
    world_assignment_array[current_floor] = current_world_assignments[current_floor]
    WriteArray(world_assignment_pointer, world_assignment_array, true)
end

function set_map_cards()
    map_cards_pointer_address = 0x8793F8 - offset
    map_cards_pointer_offset = -0xA0E
    map_cards_pointer = GetPointer(map_cards_pointer_address, map_cards_pointer_offset)
    map_cards_array = {}
    i = 1
    while i <= 24*10 do
        if i <= 220 then
            map_cards_array[i] = 9
        else
            map_cards_array[i] = 0
        end
        i = i + 1
    end
    WriteArray(map_cards_pointer, map_cards_array, true)
end

function set_initial_battle_cards(battle_cards_array)
    for k,v in pairs(card_set_data[1]) do
        add_battle_card(battle_cards_array, 1, v)
    end
end

function set_cutscene_array(cutscene_array)
    cutscene_array_pointer_address = 0x8793D0 - offset
    cutscene_array_pointer_offset = 0x272
    cutscene_array_pointer = GetPointer(cutscene_array_pointer_address, cutscene_array_pointer_offset)
    WriteArray(cutscene_array_pointer, cutscene_array, true)
end

function set_initial_deck()
    initial_deck_array = {}
    i = 0
    if not card_set_data_read then
        initial_deck_array[1] = 1
        initial_deck_array[2] = 0
        initial_deck_array[3] = 1
        initial_deck_array[4] = 17
        initial_deck_array[5] = 1
        initial_deck_array[6] = 0
        initial_deck_array[7] = 2
        initial_deck_array[8] = 17
        initial_deck_array[9] = 1
        initial_deck_array[10] = 0
        initial_deck_array[11] = 3
        initial_deck_array[12] = 17
        i = 3
    else
        for k,v in pairs(card_set_data[1]) do
            initial_deck_array[((k-1)*4)+1] = 1
            initial_deck_array[((k-1)*4)+2] = 0
            initial_deck_array[((k-1)*4)+3] = (v%10)
            initial_deck_array[((k-1)*4)+4] = 17
            i = i + 1
        end
    end
    while i < 99 do
        initial_deck_array[(i*4)+1] = 0
        initial_deck_array[(i*4)+2] = 0
        initial_deck_array[(i*4)+3] = 0
        initial_deck_array[(i*4)+4] = 0
        i = i + 1
    end
    deck_pointer_address = 0x8793F8 - offset
    deck_pointer_offset = -0x8D8
    deck_pointer = GetPointer(deck_pointer_address, deck_pointer_offset)
    WriteArray(deck_pointer, initial_deck_array, true)
end

function set_sleights(sleights_array)
    sleights_bytes_array = {}
    i = 1
    while i <= 84 do
        sleights_byte = 0
        if sleights_array[i+0] == 1 then
            sleights_byte = sleights_byte + 2
        end
        if sleights_array[i+1] == 1 then
            sleights_byte = sleights_byte + 8
        end
        if sleights_array[i+2] == 1 then
            sleights_byte = sleights_byte + 32
        end
        if sleights_array[i+3] == 1 then
            sleights_byte = sleights_byte + 128
        end
        sleights_bytes_array[#sleights_bytes_array+1] = sleights_byte
        i = i + 4
    end
    
    sleights_byte_array_pointer_address = 0x879408 - offset
    sleights_byte_pointer_offset = 0x1
    sleights_byte_pointer = GetPointer(sleights_byte_array_pointer_address, sleights_byte_pointer_offset)
    WriteArray(sleights_byte_pointer, sleights_bytes_array, true)
end

function set_level_up_sleights()
    level_up_sleight_table_address = 0x10EBE2 - offset
    WriteByte(level_up_sleight_table_address, 0x65)
    WriteByte(level_up_sleight_table_address+0x02, 0x65)
    WriteByte(level_up_sleight_table_address+0x07, 0x65)
    WriteByte(level_up_sleight_table_address+0x09, 0x65)
    WriteByte(level_up_sleight_table_address+0x0E, 0x65)
    WriteByte(level_up_sleight_table_address+0x10, 0x65)
    WriteByte(level_up_sleight_table_address+0x15, 0x65)
    WriteByte(level_up_sleight_table_address+0x17, 0x65)
    WriteByte(level_up_sleight_table_address+0x1C, 0x65)
    WriteByte(level_up_sleight_table_address+0x1E, 0x65)
    WriteByte(level_up_sleight_table_address+0x23, 0x65)
    WriteByte(level_up_sleight_table_address+0x25, 0x65)
end

function set_attack_power()
    if attack_power ~= 10 then
        attack_power_pointer_address = 0x877B90 - offset
        attack_power_pointer_offset = 0x43C
        attack_power_pointer = GetPointer(attack_power_pointer_address, attack_power_pointer_offset)
        if ReadInt(attack_power_pointer, true) == 10 then
            WriteInt(attack_power_pointer, attack_power, true)
        end
    end
end

function set_friend_cards_on_deck_3(friends_array)
    deck_3_cards_pointer_address = 0x8793F8 - offset
    deck_3_cards_pointer_offset = -0x5C0
    deck_3_cards_pointer = GetPointer(deck_3_cards_pointer_address, deck_3_cards_pointer_offset)
    deck_3_array = {}
    friends_card_values = {49, 50, 51, 52, 55, 54, 53, 57}
    for k,v in pairs(friends_array) do
        deck_3_array[((k-1)*4)+1] = friends_card_values[k]
        deck_3_array[((k-1)*4)+2] = 0
        deck_3_array[((k-1)*4)+3] = 1
        if v > 0 then
            deck_3_array[((k-1)*4)+4] = 68
        else
            deck_3_array[((k-1)*4)+4] = 119
        end
    end
    WriteArray(deck_3_cards_pointer, deck_3_array, true)
end

function add_battle_card(battle_cards_array, battle_card_index, battle_card_value)
    index = ((battle_card_index-1) * 10) + 1
    index = index + battle_card_value % 10
    if battle_card_index > 80 and battle_card_value > 9 then
        battle_card_value = battle_card_value % 10
    end
    premium_offset = 0xF0
    if battle_card_index > 24 then
        premium_offset = 0xA0
    end
    if index <= 870 then
        if battle_card_value >= 0 and battle_card_value < 10 then
            battle_cards_array[index] = battle_cards_array[index] + 1
        elseif battle_card_value >= 10 and battle_card_value < 20  and battle_card_index < 81 then
            battle_cards_array[index + premium_offset] = battle_cards_array[index + premium_offset] + 1
        end
    end
end

function calculate_cards_to_add(battle_cards_array, battle_card_index, sets_received)
    index = ((sets_received - 1)%(card_set_data_reset_value-1))+1
    values = card_set_data[index]
    for index,battle_card_value in pairs(values) do
        add_battle_card(battle_cards_array, battle_card_index, battle_card_value)
    end
end

function read_world_order()
    if file_exists(client_communication_path .. "worldorder.cfg") then
        file = io.open(client_communication_path .. "worldorder.cfg", "r")
        io.input(file)
        world_order = split(io.read(),",")
        io.close(file)
    else
        world_order = {2,3,4,5,6,7,8,9,10}
    end
end

function read_attack_power()
    if file_exists(client_communication_path .. "attackpower.cfg") then
        file = io.open(client_communication_path .. "attackpower.cfg", "r")
        io.input(file)
        attack_power = tonumber(io.read())
        io.close(file)
    else
        attack_power = 10
    end
end

function read_set_data()
    if file_exists(client_communication_path .. "setdata.cfg") and not card_set_data_read then
        card_set_data_string = slurp(client_communication_path .. "setdata.cfg")
        result = {}
        i = 1
        for line in string.gmatch(card_set_data_string .. "\n", "(.-)\n") do
            card_set_data[i] = split(line,",")
            i = i + 1
        end
        for k,v in pairs(card_set_data) do
            for ik,iv in pairs(v) do
                card_set_data[k][ik] = tonumber(iv)
            end
        end
        final_line_number = 21
        while card_set_data[final_line_number-1][1] == nil do
            final_line_number = final_line_number - 1
        end
        card_set_data_reset_value = final_line_number
        card_set_data_read = true
    end
end

function remove_premium_cards()
    deck_pointer_offset = 0x394D98
    deck_1_value_offset = -0x8D8
    deck_2_value_offset = -0x8D8 + (99*4)
    deck_3_value_offset = -0x8D8 + (99*4*2)
    deck_1_pointer = GetPointer(deck_pointer_offset, deck_1_value_offset)
    deck_2_pointer = GetPointer(deck_pointer_offset, deck_2_value_offset)
    deck_3_pointer = GetPointer(deck_pointer_offset, deck_3_value_offset)
    i = 0
    while i < 99 do
        WriteByte(deck_1_pointer+((i*4)+1), 0, true)
        WriteByte(deck_2_pointer+((i*4)+1), 0, true)
        WriteByte(deck_3_pointer+((i*4)+1), 0, true)
        i = i + 1
    end
end

function final_marluxia_slain()
    world_address = 0x878062 - offset
    room_address = 0x878060 - offset
    if ReadByte(world_address) == 0x0D and ReadArray(room_address,2)[1] == 0xD4 and ReadArray(room_address,2)[2] == 0x07 then
        return true
    end
    return false
end

function piglet_found()
    piglet_found_byte_pointer_address = 0x879408 - offset
    piglet_found_byte_pointer_offset = 0xB7
    piglet_found_byte_pointer = GetPointer(piglet_found_byte_pointer_address, piglet_found_byte_pointer_offset)
    if ReadByte(piglet_found_byte_pointer, true) > 0 then 
        return true
    else
        return false
    end
end

function receive_items()
    battle_cards_array = get_empty_battle_cards_array()
    enemy_cards_array = get_empty_enemy_cards_array()
    world_assignment_array = get_empty_world_assignment_array()
    gold_map_cards_array = get_empty_gold_map_cards_array()
    friends_array = get_empty_friends_array()
    sleights_array = get_empty_sleights_array()
    friend_count = 0
    current_floor = get_current_floor()
    victory = false
    card_sets_received = {}
    
    j = 1
    
    card_array = set_initial_battle_cards(card_array)
    set_map_cards()
    while file_exists(client_communication_path .. "AP_" .. tostring(j) .. ".item") do
        file = io.open(client_communication_path .. "AP_" .. tostring(j) .. ".item", "r")
        io.input(file)
        received_item_id = tonumber(io.read())
        io.close(file)
        if received_item_id > 2681000 and received_item_id < 2681200 then
            card_index = received_item_id % 2681000
            if card_sets_received[card_index] == nil then
                card_sets_received[card_index] = 1
            else
                card_sets_received[card_index] = card_sets_received[card_index] + 1
            end
            calculate_cards_to_add(battle_cards_array, card_index, card_sets_received[card_index])
        elseif received_item_id > 2681200 and received_item_id < 2682000 then
            enemy_card_index = received_item_id % 2681200
            enemy_cards_array[enemy_card_index] = enemy_cards_array[enemy_card_index] + 1
        elseif received_item_id > 2682000 and received_item_id < 2683000 then
            sleights_index = received_item_id % 2682000
            sleights_array[sleights_index] = 1
        elseif received_item_id > 2683000 and received_item_id < 2683300 then
            world_id = received_item_id % 2683000
            if world_id > 1 and world_id < 11 then
                world_assignment_array[world_order[world_id-1]] = world_id
            else
                world_assignment_array[world_id] = world_id
            end
        elseif received_item_id > 2683300 and received_item_id < 2684000 then
            world_id = received_item_id % 2683300
            if current_floor == world_id and (current_floor < 2 or current_floor > 10) then
                gold_map_cards_array[4] = 1
            elseif current_floor == world_order[world_id-1] then
                gold_map_cards_array[4] = 1
            end
        elseif received_item_id > 2685000 and received_item_id < 2686000 then
            friend_id = received_item_id % 2685000
            if friends_array[friend_id] ~= 1 then
                friend_count = friend_count + 1
                friends_array[friend_id] = 1
            end
        elseif received_item_id == 2680000 then
            victory = true
        end
        j = j + 1
    end
    
    if friend_count >= 8 then
        world_assignment_array[13] = 0xD
    end
    
    if current_floor == 1 or world_assignment_array[current_floor] ~= 1 then
        gold_map_cards_array[1] = 1
        gold_map_cards_array[2] = 1
        gold_map_cards_array[3] = 1
    end
    
    set_battle_cards(battle_cards_array)
    set_enemy_cards(enemy_cards_array)
    set_sleights(sleights_array)
    set_gold_map_cards(gold_map_cards_array)
    set_world_assignment(world_assignment_array)
    set_friend_cards_on_deck_3(friends_array)
    
    if get_time_played() < 10 then
        set_initial_deck()
    end
    return victory
end

function send_checks(victory)
    if get_time_played() > 0 then
        journal_array = get_journal_array()
        for k,v in pairs(journal_array) do
            if v > 0 then
                location_id = 2690000 + k
                if not file_exists(client_communication_path .. "send" .. tostring(location_id)) then
                    file = io.open(client_communication_path .. "send" .. tostring(location_id), "w")
                    io.output(file)
                    io.write("")
                    io.close(file)
                end
            end
        end
        room_array = get_room_array()
        world_assignment_array = get_world_assignments_array()
        for k,v in pairs(room_array) do
            if v > 0 then
                floor_num = math.floor((k-1)/3)+1
                world_id = world_assignment_array[floor_num]
                room_num = ((k-1)%3)+1
                location_id = 2691000 + (world_id * 10) + room_num
                if not file_exists(client_communication_path .. "send" .. tostring(location_id)) then
                    file = io.open(client_communication_path .. "send" .. tostring(location_id), "w")
                    io.output(file)
                    io.write("")
                    io.close(file)
                end
            end
        end
        heartless_array = get_heartless_array()
        j = 1
        while j < #heartless_array do
            heartless_id = math.floor((j+1)/2)
            num_defeated = heartless_array[j] + (heartless_array[j+1] * 256)
            if num_defeated >= 1 then
                location_id = 2691200 + heartless_id
                if not file_exists(client_communication_path .. "send" .. tostring(location_id)) then
                    file = io.open(client_communication_path .. "send" .. tostring(location_id), "w")
                    io.output(file)
                    io.write("")
                    io.close(file)
                end
            end
            if num_defeated >= 2 then
                location_id = 2691300 + heartless_id
                if not file_exists(client_communication_path .. "send" .. tostring(location_id)) then
                    file = io.open(client_communication_path .. "send" .. tostring(location_id), "w")
                    io.output(file)
                    io.write("")
                    io.close(file)
                end
            end
            if num_defeated >= 3 then
                location_id = 2691400 + heartless_id
                if not file_exists(client_communication_path .. "send" .. tostring(location_id)) then
                    file = io.open(client_communication_path .. "send" .. tostring(location_id), "w")
                    io.output(file)
                    io.write("")
                    io.close(file)
                end
            end
            j = j + 2
        end
        
        extra_checks = get_extra_checks()
        for k,v in pairs(extra_checks) do
            if not file_exists(client_communication_path .. "send" .. tostring(v)) then
                file = io.open(client_communication_path .. "send" .. tostring(v), "w")
                io.output(file)
                io.write("")
                io.close(file)
            end
        end
        
        if final_marluxia_slain() then
            if not file_exists(client_communication_path .. "send2699999") then
                file = io.open(client_communication_path .. "send2699999", "w")
                io.output(file)
                io.write("")
                io.close(file)
            end
        end
        
        if victory then
            if not file_exists(client_communication_path .. "victory") then
                file = io.open(client_communication_path .. "victory", "w")
                io.output(file)
                io.write("")
                io.close(file)
            end
        end
        
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
            set_level_up_sleights()
            read_world_order()
            read_attack_power()
            read_set_data()
            set_attack_power()
            if get_time_played() > 10 then
                set_cutscene_array(get_calculated_cutscene_array())
            end
            victory = receive_items()
            send_checks(victory)
        end
        frame_count = frame_count + 1
    end
end