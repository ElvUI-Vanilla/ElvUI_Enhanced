local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule("Enhanced_Misc");

--Cache global variables
--Lua functions
local match = string.match
--WoW API / Variables
local BuyMerchantItem = BuyMerchantItem
local GetAuctionItemClasses = GetAuctionItemClasses
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetMerchantItemLink = GetMerchantItemLink
local GetMerchantItemMaxStack = GetMerchantItemMaxStack
local GetMerchantNumItems = GetMerchantNumItems
local ENCHSLOT_WEAPON, ARMOR = GetAuctionItemClasses()

function M:MerchantItemButton_OnClick()
	local id = this:GetID()
	if IsAltKeyDown() then
		local _, _, _, _, _, _, maxStack = GetItemInfo(match(GetMerchantItemLink(id), "item:(%d+)"))
		if maxStack and maxStack > 1 then
			BuyMerchantItem(id, GetMerchantItemMaxStack(id))
		end
	end
end

function M:BuyStackToggle()
	if E.db.enhanced.general.altBuyMaxStack then
		if not self:IsHooked("MerchantItemButton_OnClick") then
			self:SecureHook("MerchantItemButton_OnClick")
		end
	else
		if self:IsHooked("MerchantItemButton_OnClick") then
			self:Unhook("MerchantItemButton_OnClick")
		end
	end
end

local function MerchantItemlevel()
	local numMerchantItems = GetMerchantNumItems()
	local index, button, itemLink, buybackName
	local _, quality, itemlevel, itemType, itemLink
	local r, g, b

	for i = 1, BUYBACK_ITEMS_PER_PAGE do
		index = ((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i
		button = _G["MerchantItem"..i.."ItemButton"]

		if not button.text then
			button.text = button:CreateFontString(nil, "OVERLAY")
			E:FontTemplate(button.text, E.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline)
			button.text:SetPoint("BOTTOMRIGHT", 0, 3)
		end
		button.text:SetText("")

		if index <= numMerchantItems then
			itemLink = GetMerchantItemLink(index)
			if itemLink then
				_, _, quality, itemlevel, _, itemType = GetItemInfo(match(itemLink, "item:(%d+)"))
				r, g, b = GetItemQualityColor(quality)

				if (itemlevel and itemlevel > 1) and (quality and quality > 1) and (itemType == ENCHSLOT_WEAPON or itemType == ARMOR) then
					if E.db.enhanced.general.merchantItemLevel then
						button.text:SetText(itemlevel)
						button.text:SetTextColor(r, g, b)
					else
						button.text:SetText("")
					end
				end
			end
		end

		if not MerchantBuyBackItemItemButton.text then
			MerchantBuyBackItemItemButton.text = MerchantBuyBackItemItemButton:CreateFontString(nil, "OVERLAY")
			E:FontTemplate(MerchantBuyBackItemItemButton.text, E.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline)
			MerchantBuyBackItemItemButton.text:SetPoint("BOTTOMRIGHT", 0, 3)
		end
		MerchantBuyBackItemItemButton.text:SetText("")

		buybackName = GetBuybackItemInfo(GetNumBuybackItems())
		if buybackName then
			_, itemLink = GetItemInfoByName(buybackName)
			if itemLink then
				_, _, quality, itemlevel, itemType = GetItemInfo(match(itemLink, "item:(%d+)"))
				r, g, b = GetItemQualityColor(quality)

				if (itemlevel and itemlevel > 1) and (quality and quality > 1) and (itemType == ENCHSLOT_WEAPON or itemType == ARMOR) then
					if E.db.enhanced.general.merchantItemLevel then
						MerchantBuyBackItemItemButton.text:SetText(itemlevel)
						MerchantBuyBackItemItemButton.text:SetTextColor(r, g, b)
					else
						MerchantBuyBackItemItemButton.text:SetText("")
					end
				end
			end
		end
	end
end
hooksecurefunc("MerchantFrame_UpdateMerchantInfo", MerchantItemlevel)

local function MerchantBuybackItemlevel()
	local numBuybackItems = GetNumBuybackItems()
	local button, buybackName
	local _, quality, itemlevel, itemType, itemLink
	local r, g, b

	for i = 1, BUYBACK_ITEMS_PER_PAGE do
		button = _G["MerchantItem"..i.."ItemButton"]

		if not button.text then
			button.text = button:CreateFontString(nil, "OVERLAY")
			E:FontTemplate(button.text, E.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline)
			button.text:SetPoint("BOTTOMRIGHT", 0, 3)
		end
		button.text:SetText("")

		if i <= numBuybackItems then
			buybackName = GetBuybackItemInfo(i)
			if buybackName then
				_, itemLink = GetItemInfoByName(buybackName)
				if itemLink then
					_, _, quality, itemlevel, itemType = GetItemInfo(match(itemLink, "item:(%d+)"))
					r, g, b = GetItemQualityColor(quality)

					if (itemlevel and itemlevel > 1) and (quality and quality > 1) and (itemType == ENCHSLOT_WEAPON or itemType == ARMOR) then
						if E.db.enhanced.general.merchantItemLevel then
							button.text:SetText(itemlevel)
							button.text:SetTextColor(r, g, b)
						else
							button.text:SetText("")
						end
					end
				end
			end
		end
	end
end
hooksecurefunc("MerchantFrame_UpdateBuybackInfo", MerchantBuybackItemlevel)
