local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts");

--Cache global variables
--Lua functions
local select, pairs = select, pairs
local format, join, match = string.format, string.join, string.match
--WoW API / Variables
local GetItemInfo = GetItemInfo
local GetItemCount = GetItemCount
local GetAuctionItemSubClasses = GetAuctionItemSubClasses
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemCount = GetInventoryItemCount
local GetInventorySlotInfo = GetInventorySlotInfo
local ContainerIDToInventoryID = ContainerIDToInventoryID
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetItemQualityColor = GetItemQualityColor
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local NUM_BAG_FRAMES = NUM_BAG_FRAMES
local AMMOSLOT = AMMOSLOT

local quiver = select(1, GetAuctionItemSubClasses(7))
local pouch = select(2, GetAuctionItemSubClasses(7))
local soulBag = select(2, GetAuctionItemSubClasses(3))

local displayString = ""

local lastPanel

local function ColorizeSettingName(settingName)
	return format("|cffff8000%s|r", settingName)
end

local function OnEvent(self)
	local itemName, itemCount, itemLink
	if E.myclass == "WARLOCK" then
		itemName, itemLink = GetItemInfo(6265)
		itemCount = GetItemCount(itemName)
		if itemLink and (itemCount > 0) then
			self.text:SetText(format(displayString, itemName, itemCount))
		else
			self.text:SetText(format(displayString, itemName, 0))
		end
	else
		itemCount = GetInventoryItemCount("player", GetInventorySlotInfo("AmmoSlot"))
		if itemCount and (itemCount > 0) then
			self.text:SetText(format(displayString, AMMOSLOT, itemCount))
		else
			self.text:SetText(format(displayString, AMMOSLOT, 0))
		end
	end

	lastPanel = self
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	local r, g, b
	local itemLink, itemCount
	local _, itemName, quality, subclass, equipLoc
	local lineAdded, quiverLineAdded, pouchLineAdded, soulBagLineAdded
	local free, total, used
	local spacer = false

	for bagID = 0, NUM_BAG_FRAMES do
		for slotID = 1, GetContainerNumSlots(bagID) do
			itemLink = GetContainerItemLink(bagID, slotID)
			if itemLink then
				itemName, _, quality, _, _, _, _, equipLoc = GetItemInfo(match(itemLink, "item:(%d+)"))

				if equipLoc == "INVTYPE_AMMO" then
					itemCount = GetItemCount(itemName)
					r, g, b = GetItemQualityColor(quality)
					if not lineAdded then
						DT.tooltip:AddLine(AMMOSLOT)
						lineAdded = true
						spacer = true
					end
					DT.tooltip:AddDoubleLine(itemName, itemCount, r, g, b)
				end
			end
		end
	end

	for i = 1, NUM_BAG_SLOTS do
		itemLink = GetInventoryItemLink("player", ContainerIDToInventoryID(i))
		if itemLink then
			itemName, _, quality, _, _, subclass = GetItemInfo(match(itemLink, "item:(%d+)"))

			if subclass == quiver or subclass == pouch or subclass == soulBag then
				r, g, b = GetItemQualityColor(quality)

				free, total, used = 0, 0, 0
				free, total = GetContainerNumFreeSlots(i), GetContainerNumSlots(i)
				used = total - free

				if not lineAdded and spacer == true then
					DT.tooltip:AddLine(" ")
					lineAdded = true
				end

				if subclass == quiver and not quiverLineAdded then
					DT.tooltip:AddLine(subclass)
					quiverLineAdded = true
				elseif subclass == pouch and not pouchLineAdded then
					DT.tooltip:AddLine(subclass)
					pouchLineAdded = true
				elseif subclass == soulBag and not soulBagLineAdded then
					DT.tooltip:AddLine(subclass)
					soulBagLineAdded = true
				end

				DT.tooltip:AddDoubleLine(itemName, format("%d / %d", used, total), r, g, b)
			end
		end
	end

	DT.tooltip:Show()
end

local function OnClick()
	if arg1 == "LeftButton" then
		if not E.bags then
			for i = 1, NUM_BAG_SLOTS do
				local itemLink = GetInventoryItemLink("player", ContainerIDToInventoryID(i))
				if itemLink then
					local subclass = select(7, GetItemInfo(match(itemLink, "item:(%d+)")))
					if subclass == quiver or subclass == pouch or subclass == soulBag then
						ToggleBag(i)
					end
				end
			end
		else
			OpenAllBags()
		end
	end
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E["valueColorUpdateFuncs"][ValueColorUpdate] = true

DT:RegisterDatatext(AMMOSLOT, {"PLAYER_ENTERING_WORLD", "BAG_UPDATE", "UNIT_INVENTORY_CHANGED"}, OnEvent, nil, OnClick, OnEnter, nil, ColorizeSettingName(L["Ammo / Soul Shards"]))