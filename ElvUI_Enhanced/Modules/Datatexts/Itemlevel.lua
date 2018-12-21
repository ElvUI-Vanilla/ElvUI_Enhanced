local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts");

--Cache global variables
--Lua functions
local floor = math.floor
local format, join, match = string.format, string.join, string.match
local getn = table.getn
--WoW API / Variables
local GetAverageItemLevel = GetAverageItemLevel
local GetInventoryItemLink = GetInventoryItemLink
local GetInventorySlotInfo = GetInventorySlotInfo
local GetItemInfo = GetItemInfo

local displayNumberString = ""
local lastPanel

local function ColorizeSettingName(settingName)
	return format("|cffff8000%s|r", settingName)
end

local slots = {
	{"HeadSlot", HEADSLOT},
	{"NeckSlot", NECKSLOT},
	{"ShoulderSlot", SHOULDERSLOT},
	{"BackSlot", BACKSLOT},
	{"ChestSlot", CHESTSLOT},
	{"WristSlot", WRISTSLOT},
	{"HandsSlot", HANDSSLOT},
	{"WaistSlot", WAISTSLOT},
	{"LegsSlot", LEGSSLOT},
	{"FeetSlot", FEETSLOT},
	{"Finger0Slot", FINGER0SLOT},
	{"Finger1Slot", FINGER1SLOT},
	{"Trinket0Slot", TRINKET0SLOT},
	{"Trinket1Slot", TRINKET1SLOT},
	{"MainHandSlot", MAINHANDSLOT},
	{"SecondaryHandSlot", SECONDARYHANDSLOT},
	{"RangedSlot", RANGEDSLOT},
}

local levelColors = {
	[0] = {1, 0, 0},
	[1] = {0, 1, 0},
	[2] = {1, 1, .5}
}

local function OnEvent(self)
	local total, equipped = GetAverageItemLevel()

	self.text:SetText(format(displayNumberString, L["iLvL"], floor(equipped), floor(total)))
end

local function OnEnter(self)
	local total, equipped = GetAverageItemLevel()
	local color

	DT:SetupTooltip(self)
	DT.tooltip:AddDoubleLine(L["Equipped"], floor(equipped), 1, 1, 1, 1, 1, 0)
	DT.tooltip:AddDoubleLine(L["Total"], floor(total), 1, 1, 1, 1, 1, 0)
	DT.tooltip:AddLine(" ")

	for i = 1, getn(slots) do
		local itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slots[i][1]))
		if itemLink then
			local _, _, quality, iLevel = GetItemInfo(match(itemLink, "item:(%d+)"))
			local r, g, b = GetItemQualityColor(quality)

			color = levelColors[(iLevel < equipped - 5 and 0 or (iLevel > equipped + 5 and 1 or 2))]
			DT.tooltip:AddDoubleLine(slots[i][2], iLevel, r, g, b, color[1], color[2], color[3])
		end
	end

	DT.tooltip:Show()
end

local function OnClick(self)
	if arg1 == "LeftButton" then
		ToggleCharacter("PaperDollFrame")
	else
		OnEvent(self)
	end
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s: ", hex, "%d/%d|r")

	if(lastPanel ~= nil) then
		OnEvent(lastPanel)
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true

DT:RegisterDatatext("Item Level", {"PLAYER_ENTERING_WORLD", "UNIT_INVENTORY_CHANGED"}, OnEvent, nil, OnClick, OnEnter, nil, ColorizeSettingName(L["Item Level"]))
