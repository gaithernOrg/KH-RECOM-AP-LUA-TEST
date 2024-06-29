LUAGUI_NAME = "recomAP Tutorial Skip"
LUAGUI_AUTH = "KSX with slight edits from Gicu"
LUAGUI_DESC = "Tutorial Skip"

IsEpicGLVersion = 0x4E6C80
IsSteamGLVersion = 0x4E7040
IsSteamJPVersion = 0x4E6DC0


-------------------------------------------------------------------------
function _OnInit()
	if ENGINE_TYPE == "BACKEND" then
	end
	
	if ReadByte(IsEpicGLVersion) == 0xFF then
		epicgames = 1
		ConsolePrint("Tutorial Skip (EPIC GL) - installed")
	end
	
	if ReadByte(IsSteamGLVersion) == 0xFF then
		stmgames = 1
		ConsolePrint("Tutorial Skip (Steam GL) - installed")
	end
	
	if ReadByte(IsSteamJPVersion) == 0xFF then
		stmjpgames = 1
		ConsolePrint("Tutorial Skip (Steam JP) - installed")
	end

end
-------------------------------------------------------------------------
function _OnFrame()

---------- Epic Games Version
if epicgames == 1 then 
TutorialFlag = ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(0x87A9B0)+0x5C0, true)+0x58, true)+0x60, true)+0x8, true)+0xA0, true)+0x80, true)+0x0, true
EventCheck = ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(0x87A9B0)+0x5C0, true)+0x58, true)+0x60, true)+0x8, true)+0xA0, true)+0x80, true)+0x10, true
EventCheck2 = ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(0x87A9B0)+0x5C0, true)+0x58, true)+0x60, true)+0x8, true)+0xA0, true)+0x80, true)+0x20, true
TraversTownTutorial = ReadLong(ReadLong(0x87A9E0)+0x8,true)+0x304, true
SavePointTutorial = ReadLong(ReadLong(0x87A9E0)+0x8,true)+0x308, true
Blizzara = ReadLong(0x87C508)+0x3, true
Blizzaga = ReadLong(0x87C508)+0x5, true

	--- Cards Tutorial
	if ReadByte(TutorialFlag, true) == 0x0A and ReadInt(EventCheck, true) == 0x6E657645 then
		WriteArray(TutorialFlag, {0x5A, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x0C}, true)
	end
	
	--- Traverse Town Tutorial
	if ReadByte(TraversTownTutorial, true) == 0 then
		WriteByte(TraversTownTutorial, 0x01, true)
	end
	
	--- Lot of Tutorial Flags like Save Points, Using Doors
	if ReadByte(SavePointTutorial, true) == 0 then
		WriteByte(SavePointTutorial, 0x71, true)
	end
	
	--- Leon Tutorial
	if ReadByte(TutorialFlag, true) == 0x0A and ReadInt(EventCheck2, true) == 0x5F463130 then
		WriteArray(TutorialFlag, {0x28, 0x00, 0x00, 0x00, 0x07}, true)
	end
end

---------- Steam Version
if stmgames == 1 then
TutorialFlag = ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(0x87B0B0)+0x5C0, true)+0x58, true)+0x60, true)+0x8, true)+0xA0, true)+0x80, true)+0x0, true
EventCheck = ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(0x87B0B0)+0x5C0, true)+0x58, true)+0x60, true)+0x8, true)+0xA0, true)+0x80, true)+0x10, true
EventCheck2 = ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(0x87B0B0)+0x5C0, true)+0x58, true)+0x60, true)+0x8, true)+0xA0, true)+0x80, true)+0x20, true
TraversTownTutorial = ReadLong(ReadLong(0x87B0E0)+0x8,true)+0x304, true
SavePointTutorial = ReadLong(ReadLong(0x87B0E0)+0x8,true)+0x308, true
Blizzara = ReadLong(0x87CC08)+0x3, true
Blizzaga = ReadLong(0x87CC08)+0x5, true

	--- Cards Tutorial
	if ReadByte(TutorialFlag, true) == 0x0A and ReadInt(EventCheck, true) == 0x6E657645 then
		WriteArray(TutorialFlag, {0x5A, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x0C}, true)
	end
	
	--- Traverse Town Tutorial
	if ReadByte(TraversTownTutorial, true) == 0 then
		WriteByte(TraversTownTutorial, 0x01, true)
	end
	
	--- Lot of Tutorial Flags like Save Points, Using Doors
	if ReadByte(SavePointTutorial, true) == 0 then
		WriteByte(SavePointTutorial, 0x71, true)
	end
	
	--- Leon Tutorial
	if ReadByte(TutorialFlag, true) == 0x0A and ReadInt(EventCheck2, true) == 0x5F463130 then
		WriteArray(TutorialFlag, {0x28, 0x00, 0x00, 0x00, 0x07}, true)
	end
end

---------- Steam JP Version
if stmjpgames == 1 then
TutorialFlag = ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(0x87B0B0)+0x5C0, true)+0x58, true)+0x60, true)+0x8, true)+0xA0, true)+0x80, true)+0x0, true
EventCheck = ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(0x87B0B0)+0x5C0, true)+0x58, true)+0x60, true)+0x8, true)+0xA0, true)+0x80, true)+0x10, true
EventCheck2 = ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(ReadLong(0x87B0B0)+0x5C0, true)+0x58, true)+0x60, true)+0x8, true)+0xA0, true)+0x80, true)+0x20, true
TraversTownTutorial = ReadLong(ReadLong(0x87B0E0)+0x8,true)+0x304, true
SavePointTutorial = ReadLong(ReadLong(0x87B0E0)+0x8,true)+0x308, true
Blizzara = ReadLong(0x87CC08)+0x3, true
Blizzaga = ReadLong(0x87CC08)+0x5, true

	--- Cards Tutorial
	if ReadByte(TutorialFlag, true) == 0x0A and ReadInt(EventCheck, true) == 0x6E657645 then
		WriteArray(TutorialFlag, {0x5A, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x0C}, true)
	end
	
	--- Traverse Town Tutorial
	if ReadByte(TraversTownTutorial, true) == 0 then
		WriteByte(TraversTownTutorial, 0x01, true)
	end
	
	--- Lot of Tutorial Flags like Save Points, Using Doors
	if ReadByte(SavePointTutorial, true) == 0 then
		WriteByte(SavePointTutorial, 0x71, true)
	end
	
	--- Leon Tutorial
	if ReadByte(TutorialFlag, true) == 0x0A and ReadInt(EventCheck2, true) == 0x5F463130 then
		WriteArray(TutorialFlag, {0x28, 0x00, 0x00, 0x00, 0x07}, true)
	end
end

end