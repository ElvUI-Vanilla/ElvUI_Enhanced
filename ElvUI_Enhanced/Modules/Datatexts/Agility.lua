local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts");

--Cache global variables
--Lua functions
local select = select
local format, join = string.format, string.join
--WoW API / Variables
local AGILITY_COLON = AGILITY_COLON
local SPELL_STAT1_NAME = SPELL_STAT1_NAME

local displayNumberString = ""
local lastPanel

local function ColorizeSettingName(settingName)
	return format("|cffff8000%s|r", settingName)
end

local function OnEvent(self)
	self.text:SetText(format(displayNumberString, AGILITY_COLON, select(2, UnitStat("player", 2))))
	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s ", hex, "%.f|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true

DT:RegisterDatatext("Agility", {"UNIT_STATS", "UNIT_AURA", "CHARACTER_POINTS_CHANGED"}, OnEvent, nil, nil, nil, nil, ColorizeSettingName(SPELL_STAT1_NAME))
