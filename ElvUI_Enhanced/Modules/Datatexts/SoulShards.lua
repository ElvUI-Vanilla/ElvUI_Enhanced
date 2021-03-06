local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts");

if E.myclass ~= "WARLOCK" then return end

--Cache global variables
--Lua functions
local select = select
local format, join, match = string.format, string.join, string.match
--WoW API / Variables
local ContainerIDToInventoryID = ContainerIDToInventoryID
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots
local GetInventoryItemLink = GetInventoryItemLink
local GetItemInfo = GetItemInfo

local displayNumberString = ""
local lastPanel

local _, soulBagType = GetAuctionItemSubClasses(3)
local _, shardLink = GetItemInfo(6265)

local function ColorizeSettingName(settingName)
	return format("|cffff8000%s|r", settingName)
end

local function IsShardBag(bag)
	local itemLink = GetInventoryItemLink("player", ContainerIDToInventoryID(bag))
	return itemLink and select(6, GetItemInfo(match(itemLink, "item:(%d+)"))) == soulBagType
end

local function OnEvent(self)
	local soulShards, soulBagSpace, soulBagSize = 0, 0, 0
	local numSlots, itemLink

	for bagID = 0, 4 do
		numSlots = GetContainerNumSlots(bagID)

		if numSlots > 0 then
			if bagID > 0 and IsShardBag(bagID) then
				soulBagSize = soulBagSize + numSlots
				soulBagSpace = soulBagSpace + (numSlots - GetContainerNumFreeSlots(bagID))
			end

			for slotID = 1, GetContainerNumSlots(bagID) do
				itemLink = GetContainerItemLink(bagID, slotID)

				if itemLink and itemLink == shardLink then
					soulShards = soulShards + select(2, GetContainerItemInfo(bagID, slotID))
				end
			end
		end
	end

	self.text:SetText(format(displayNumberString, L["Shards"], soulShards, soulBagSpace, soulBagSize))

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayNumberString = join("", "%s: ", hex, "%d (%d/%d)|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Soul Shards", {"BAG_UPDATE"}, OnEvent, nil, nil, nil, nil, ColorizeSettingName(L["Soul Shards"]))
