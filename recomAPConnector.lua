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

world_order = {nil,nil,nil,nil,nil,nil,nil,nil,nil}
canExecute = false
offset = 0x4E4660
frame_count = 1

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
    return ReadArray(room_byte_pointer, 39, true)
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
    while i <= 47 * 10 do
        card_array[i] = 0
        i = i + 1
    end
    return card_array
end

function get_empty_enemy_cards_array()
    enemy_cards_array = {}
    i = 1
    while i <= 56 do
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

function get_boss_flag_array()
    boss_flag_array_pointer_address = 0x879408 - offset
    boss_flag_array_pointer_offset = 0x68
    boss_flag_array_pointer = GetPointer(boss_flag_array_pointer_address, boss_flag_array_pointer_offset)
    boss_flag_array = ReadArray(room_byte_pointer, 12, true)
    return boss_flag_array
end

function get_calculated_cutscene_array()
    boss_flag_array = get_boss_flag_array()
    
    axel_1_defeated             = boss_flag_array[1]  > 0
    larxene_1_defeated          = boss_flag_array[3]  > 0
    vexen_1_defeated            = boss_flag_array[4]  > 0
    riku_2_defeated             = boss_flag_array[5]  > 0
    riku_1_defeated             = boss_flag_array[10] > 0
    riku_3_defeated             = boss_flag_array[11] > 0
    riku_4_defeated             = boss_flag_array[12] > 0
    larxene_2_defeated          = false
    
    larxene_2_defeated_pointer_address = 0x879408 - offset
    larxene_2_defeated_pointer_offset = 0x185
    larxene_2_defeated_pointer = GetPointer(larxene_2_defeated_pointer_address, larxene_2_defeated_pointer_offset)
    if ReadByte(larxene_2_defeated_pointer, true) > 0 then
        larxene_2_defeated = true
    end
    
    if axel_1_defeated and larxene_1_defeated and riku_1_defeated and riku_2_defeated and vexen_1_defeated and larxene_2_defeated then --Clear
        cutscene_array = {0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x04, 0x00, 0x05, 0x00, 0x06, 0x00, 0x07, 0x00, 0x08, 0x00, 0x09, 0x00, 0x0A, 0x00, 0x0B, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0x0E, 0x00, 0x0F, 
                0x00, 0x10, 0x00, 0x11, 0x00, 0x12, 0x00, 0x13, 0x00, 0x14, 0x00, 0x15, 0x00, 0x16, 0x00, 0x17, 0x00, 0x18, 0x00}
    elseif axel_1_defeated and larxene_1_defeated and riku_1_defeated and riku_2_defeated and vexen_1_defeated then--Riku IV and Larxene II
        cutscene_array = {0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x04, 0x00, 0x05, 0x00, 0x06, 0x00, 0x07, 0x00, 0x08, 0x00, 0x09, 0x00, 0x0A, 0x00, 0x0B, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0x0E, 0x00, 0x0F, 
                0x00, 0x10, 0x00, 0x11, 0x00, 0x12, 0x00, 0x13, 0x00, 0x14, 0x00, 0x15, 0x00, 0x16, 0x00, 0x17, 0x00, 0xE8, 0x07}
    elseif axel_1_defeated and larxene_1_defeated and riku_1_defeated and riku_2_defeated then --Vexen I
        cutscene_array = {0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x04, 0x00, 0x05, 0x00, 0x06, 0x00, 0x07, 0x00, 0x08, 0x00, 0x09, 0x00, 0x0A, 0x00, 0x0B, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0x0E, 0x00, 0x0F, 
                0x00, 0x10, 0x00, 0x11, 0x00, 0x12, 0x00, 0x13, 0x00, 0xE4, 0x07, 0x15, 0x00, 0x16, 0x00, 0x17, 0x00, 0x18, 0x00}
    elseif axel_1_defeated and larxene_1_defeated and riku_1_defeated then --Riku II
        cutscene_array = {0x01, 0x00, 0x02, 0x00, 0x03, 0x00, 0x04, 0x00, 0x05, 0x00, 0x06, 0x00, 0x07, 0x00, 0x08, 0x00, 0x09, 0x00, 0x0A, 0x00, 0x0B, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0x0E, 0x00, 0x0F, 
                0x00, 0xE0, 0x07, 0x11, 0x00, 0x12, 0x00, 0x13, 0x00, 0x14, 0x00, 0x15, 0x00, 0x16, 0x00, 0x17, 0x00, 0x18, 0x00}
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
    rewards_bounties_array = ReadArray(rewards_bounties_array_pointer_offset, 51, true)
    return rewards_bounties_array
end

function get_minigames_array()
    minigames_array_pointer_address = 0x879408 - offset
    minigames_array_pointer_offset = 0x00
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
    if journal_array[34] > 0 then --Tinker Bell
        ids[#ids+1] = 2692060
        ids[#ids+1] = 2692061
    end
    if journal_array[35] > 0 then --Mushu
        ids[#ids+1] = 2692056
        ids[#ids+1] = 2692057
    end
    if journal_array[36] > 0 then --Cloud
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
        ids[#ids+1] = 2691567
    end
    if rewards_bounties_array[30] > 0 then --Blizzard Raid
        ids[#ids+1] = 2691525
    end
    if rewards_bounties_array[32] > 0 then --Fire Raid
        ids[#ids+1] = 2691524
    end
    if rewards_bounties_array[33] > 0 then --Shock Impact
        ids[#ids+1] = 2691537
    end
    if rewards_bounties_array[33] > 1 then --Homing Blizzara
        ids[#ids+1] = 2691533
    end
    if rewards_bounties_array[34] > 1 then --Teleport
        ids[#ids+1] = 2691547
    end
    if rewards_bounties_array[35] > 1 then --Reflect Raid
        ids[#ids+1] = 2691527
    end
    if rewards_bounties_array[37] > 1 then --Warpinator
        ids[#ids+1] = 2691540
    end
    if rewards_bounties_array[38] > 1 then --Judgement
        ids[#ids+1] = 2691528
    end
    
    friend_array = get_friend_cards_array()
    if friend_array[1] > 0 then --Donald
        ids[#ids+1] = 2691565
        ids[#ids+1] = 2691566
    end
    if friend_array[2] > 0 then --Goofy
        ids[#ids+1] = 2691568
        ids[#ids+1] = 2691569
        ids[#ids+1] = 2691570
        ids[#ids+1] = 2691571
    end
    if friend_array[3] > 0 then --Aladdin
        ids[#ids+1] = 2691572
        ids[#ids+1] = 2691573
    end
    if friend_array[4] > 0 then --Ariel
        ids[#ids+1] = 2691576
        ids[#ids+1] = 2691577
    end
    if friend_array[5] > 0 then --Jack
        ids[#ids+1] = 2691544
        ids[#ids+1] = 2691574
        ids[#ids+1] = 2691575
    end
    if friend_array[6] > 0 then --Peter Pan
        ids[#ids+1] = 2691578
        ids[#ids+1] = 2691579
    end
    if friend_array[7] > 0 then --Beast
        ids[#ids+1] = 2691580
        ids[#ids+1] = 2691581
    end
    if friend_array[8] > 0 then --Pluto
        ids[#ids+1] = 2691582
        ids[#ids+1] = 2691583
    end
    
    minigames_array = get_minigames_array()
    if mingames_array[1] > 0 then --Firaga Burst
        ids[#ids+1] = 2691582
    end
    if mingames_array[3] > 0 then --Idyll Romp
        ids[#ids+1] = 2691555
    end
    if mingames_array[4] > 0 then --Cross-Slash +
        ids[#ids+1] = 2691564
    end
    
    boss_flag_array = get_boss_flag_array()
    if boss_flag_array[4] > 0 then --Freeze
        ids[#ids+1] = 2691532
    end
    if boss_flag_array[5]  > 0 then --Magnet Spiral
        ids[#ids+1] = 2691535
    end
    
    soras_level = get_soras_level()
    if soras_level >= 2 then --Sliding Dash
        ids[#ids+1] = 2691501
    end
    if soras_level >= 7 then --Stun Impact
        ids[#ids+1] = 2691503
    end
    if soras_level >= 12 then --Strike Raid
        ids[#ids+1] = 2691505
    end
    if soras_level >= 17 then --Blitz
        ids[#ids+1] = 2691502
    end
    if soras_level >= 22 then --Zantetsuken
        ids[#ids+1] = 2691504
    end
    if soras_level >= 27 then --Sonic Blade
        ids[#ids+1] = 2691506
    end
    if soras_level >= 32 then --Lethal Frame
        ids[#ids+1] = 2691536
    end
    if soras_level >= 37 then --Tornado
        ids[#ids+1] = 2691538
    end
    if soras_level >= 42 then --Ars Arcanum
        ids[#ids+1] = 2691507
    end
    if soras_level >= 47 then --Holy
        ids[#ids+1] = 2691548
    end
    if soras_level >= 52 then --Raganarok
        ids[#ids+1] = 2691508
    end
    if soras_level >= 57 then --Mega Flare
        ids[#ids+1] = 2691531
    end
    
    world_assignment_array = get_world_assignments_array()
    if world_assignment_array[13] > 1 then
        ids[#ids+1] = 2691509
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
    WriteArray(enemy_cards_pointer, enemy_card_array, true)
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
    for i=1
    while i <= 22*10 do
        map_cards_array[i] = 9
        i = i + 1
    end
    WriteArray(map_cards_pointer, map_cards_array, true)
end

function set_initial_battle_cards(battle_cards_array)
    for i=1,10 do
        add_battle_card(battle_cards_array, 1, i)
    end
end

function set_cutscene_array(cutscene_array)
    cutscene_array_pointer_address = 0x8793D0 - offset
    cutscene_array_pointer_offset = 0x272
    cutscene_array_pointer = GetPointer(cutscene_array_pointer_address, cutscene_array_pointer_offset)
    WriteArray(cutscene_array_pointer, cutscene_array, true)
end

function set_initial_deck()
    initial_deck_array = {1, 0, 9, 17, 1, 0, 8, 17, 1, 0, 7, 17, 1, 0, 6, 17, 1, 0, 5, 17, 1, 0, 4, 17, 1, 0, 3, 17, 1, 0, 2, 17, 1, 0, 1, 17}
    i = 9
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

function add_battle_card(battle_cards_array, battle_card_index, battle_card_value)
    index = ((battle_card_index-1) * 10) + 1
    index = index + battle_card_value
    battle_cards_array[index] = battle_cards_array[index] + 1
end

function read_world_order()
    if file_exists(client_communication_path .. "worldorder.cfg") then
        file = io.open(client_communication_path .. "worldorder.cfg", "r")
        io.input(file)
        world_order = split(io.read(),",")
        io.close(file)
    else
        world_order = {nil,nil,nil,nil,nil,nil,nil,nil,nil}
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
    
    j = 1
    
    card_array = set_initial_battle_cards(card_array)
    card_array = set_initial_map_cards(card_array)
    while file_exists(client_communication_path .. "AP_" .. tostring(i) .. ".item") do
        file = io.open(client_communication_path .. "AP_" .. tostring(i) .. ".item", "r")
        io.input(file)
        received_item_id = tonumber(io.read())
        io.close(file)
        if received_item_id > 2681000 and received_item_id < 2681100 then
            for k=1,10 do
                add_battle_card(battle_cards_array, received_item_id % 2681000, k)
            end
        elseif received_item_id > 2681100 and received_item_id < 2682000 then
            enemy_card_index = received_item_id % 2681100
            enemy_cards_array[enemy_card_index] = enemy_cards_array[enemy_card_index] + 1
        elseif received_item_id > 2682000 and received_item_id < 2683000 then
            sleights_index = received_item_id % 2682000
            sleights_array[sleights_index] = 1
        elseif received_item_id > 2683000 and received_item_id < 2683300 then
            world_id = received_item_id % 2683000
            world_assignment_array[world_order[world_id-1]] = world_id
        elseif received_item_id > 2683300 and received_item_id < 2684000 then
            world_id = received_item_id % 2684000
            if current_floor == world_order[world_id-1] then
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
    end
    
    if friend_count >= 8 then
        world_assignment_array[13] = 0xD
    end
    
    set_battle_cards(battle_cards_array)
    set_enemy_cards(enemy_cards_array)
    set_sleights(sleights_array)
    set_gold_map_cards(gold_map_cards_array)
    
    if get_time_played() < 10 then
        write_initial_deck()
    else
        remove_premium_cards()
    end
    return victory
end

function send_checks(victory)
    room_byte_location_ids = define_room_byte_location_ids()
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
                floor_num = math.floor((k/3)+1)
                world_id = world_assignment_array[floor_num]
                room_num = k%3
                if room_num == 0 then
                    room_num = 3
                end
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
            heartless_id = j+1/2
            num_defeated = heartless_array[j] + (heartless_array[j+1] * 256)
            if v >= 1 then
                location_id = 2691100 + heartless_id
                if not file_exists(client_communication_path .. "send" .. tostring(location_id)) then
                    file = io.open(client_communication_path .. "send" .. tostring(location_id), "w")
                    io.output(file)
                    io.write("")
                    io.close(file)
                end
            end
            if v >= 5 then
                location_id = 2691200 + heartless_id
                if not file_exists(client_communication_path .. "send" .. tostring(location_id)) then
                    file = io.open(client_communication_path .. "send" .. tostring(location_id), "w")
                    io.output(file)
                    io.write("")
                    io.close(file)
                end
            end
            if v >= 9 then
                location_id = 2691300 + heartless_id
                if not file_exists(client_communication_path .. "send" .. tostring(location_id)) then
                    file = io.open(client_communication_path .. "send" .. tostring(location_id), "w")
                    io.output(file)
                    io.write("")
                    io.close(file)
                end
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
            set_cutscene_array(get_calculated_cutscene_array())
            victory = receive_items()
            send_checks(victory)
        end
        frame_count = frame_count + 1
    end
end