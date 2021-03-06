local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local PD = E:NewModule("Enhanced_PaperDoll", "AceHook-3.0", "AceEvent-3.0");

--Cache global variables
--Lua functions
local _G = _G
local format, match = string.format, string.match
local pairs = pairs
--WoW API / Variables
local CanInspect = CanInspect
local GetInventoryItemDurability = GetInventoryItemDurability
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemQuality = GetInventoryItemQuality
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventorySlotInfo = GetInventorySlotInfo
local GetItemQualityColor = GetItemQualityColor
local GetItemInfo = GetItemInfo

local slots = {
	["HeadSlot"] = true,
	["NeckSlot"] = false,
	["ShoulderSlot"] = true,
	["BackSlot"] = false,
	["ChestSlot"] = true,
	["WristSlot"] = true,
	["HandsSlot"] = true,
	["WaistSlot"] = true,
	["LegsSlot"] = true,
	["FeetSlot"] = true,
	["Finger0Slot"] = false,
	["Finger1Slot"] = false,
	["Trinket0Slot"] = false,
	["Trinket1Slot"] = false,
	["MainHandSlot"] = true,
	["SecondaryHandSlot"] = true,
	["RangedSlot"] = true,
}

function PD:UpdatePaperDoll(unit)
	if not self.initialized then return end

	unit = (unit ~= "player" and InspectFrame) and InspectFrame.unit or unit
	if not unit then return end
	if unit and not CanInspect(unit, false) then return end

	local baseName = unit == "player" and "Character" or "Inspect"
	local frame, slotID, hasItem
	local itemLink, itemLevel, rarity
	local current, maximum, r, g, b

	for slotName, durability in pairs(slots) do
		frame = _G[format("%s%s", baseName, slotName)]
		slotID = GetInventorySlotInfo(slotName)
		hasItem = GetInventoryItemTexture(unit, slotID)

		frame.ItemLevel:SetText()
		if E.db.enhanced.equipment.itemlevel.enable and (unit == "player" or (unit ~= "player" and hasItem)) then
			itemLink = GetInventoryItemLink(unit, slotID)

			if itemLink then
				_, _, rarity, itemLevel = GetItemInfo(match(itemLink, "item:(%d+)"))
				if itemLevel then
					frame.ItemLevel:SetText(itemLevel)

					if E.db.enhanced.equipment.itemlevel.qualityColor then
						frame.ItemLevel:SetTextColor()
						if rarity and rarity > 1 then
							frame.ItemLevel:SetTextColor(GetItemQualityColor(rarity))
						else
							frame.ItemLevel:SetTextColor(1, 1, 1)
						end
					else
						frame.ItemLevel:SetTextColor(1, 1, 1)
					end
				end
			end
		end

		if unit == "player" and durability then
			frame.DurabilityInfo:SetText()
			if E.db.enhanced.equipment.durability.enable then
				current, maximum = GetInventoryItemDurability(slotID)
				if current and maximum and (not E.db.enhanced.equipment.durability.onlydamaged or current < maximum) then
					r, g, b = E:ColorGradient((current / maximum), 1, 0, 0, 1, 1, 0, 0, 1, 0)
					frame.DurabilityInfo:SetText(format("%s%.0f%%|r", E:RGBToHex(r, g, b), (current / maximum) * 100))
				end
			end
		end
	end
end

function PD:UpdateInfoText(name)
	local db = E.db.enhanced.equipment
	local frame
	for slotName, durability in pairs(slots) do
		frame = _G[format("%s%s", name, slotName)]

		frame.ItemLevel:ClearAllPoints()
		E:Point(frame.ItemLevel, db.itemlevel.position, frame, db.itemlevel.xOffset, db.itemlevel.yOffset)
		E:FontTemplate(frame.ItemLevel, E.LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)

		if name == "Character" and durability then
			frame.DurabilityInfo:ClearAllPoints()
			E:Point(frame.DurabilityInfo, db.durability.position, frame, db.durability.xOffset, db.durability.yOffset)
			E:FontTemplate(frame.DurabilityInfo, E.LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
		end
	end
end

function PD:BuildInfoText(name)
	local frame
	for slotName, durability in pairs(slots) do
		frame = _G[format("%s%s", name, slotName)]

		frame.ItemLevel = frame:CreateFontString(nil, "OVERLAY")

		if name == "Character" and durability then
			frame.DurabilityInfo = frame:CreateFontString(nil, "OVERLAY")
		end
	end
	self:UpdateInfoText(name)
end

function PD:OnEvent(event)
	if event == "UPDATE_INVENTORY_ALERTS" then
		self:UpdatePaperDoll("player")
	elseif event == "UNIT_INVENTORY_CHANGED" then
		self:UpdatePaperDoll(arg1)
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		self:UpdatePaperDoll(arg1)
	end
end

local function InspectFrameUpdate()
	PD:UpdatePaperDoll(InspectFrame.unit)
end

function PD:InitialUpdatePaperDoll()
	if self.initialized then return end

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	LoadAddOn("Blizzard_InspectUI")

	self:BuildInfoText("Character")
	self:BuildInfoText("Inspect")

	self:SecureHook("InspectFrame_OnUpdate", InspectFrameUpdate)

	self.initialized = true
end

function PD:ToggleState(init)
	if E.db.enhanced.equipment.enable then
		if not self.initialized then
			if init then
				self:RegisterEvent("PLAYER_ENTERING_WORLD", "InitialUpdatePaperDoll")
			else
				self:InitialUpdatePaperDoll()
			end
		end

		self:UpdatePaperDoll("player")

		if self.initialized then
			self:UpdateInfoText("Inspect")
		end

		self:RegisterEvent("UPDATE_INVENTORY_ALERTS", "OnEvent")
		self:RegisterEvent("UNIT_INVENTORY_CHANGED", "OnEvent")
	elseif self.initialized then
		self:UnhookAll()
		self:UnregisterAllEvents()

		for slotName, durability in pairs(slots) do
			_G["Character"..slotName].ItemLevel:SetText()
			_G["Inspect"..slotName].ItemLevel:SetText()

			if durability then
				_G["Character"..slotName].DurabilityInfo:SetText()
			end
		end
	end
end

function PD:Initialize()
	if not E.db.enhanced.equipment.enable then return end

	self:ToggleState(true)
end

local function InitializeCallback()
	PD:Initialize()
end

E:RegisterModule(PD:GetName(), InitializeCallback)
