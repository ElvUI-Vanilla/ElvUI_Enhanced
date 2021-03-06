local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule("Enhanced_Misc");

--Cache global variables
--Lua functions
local match = string.match
--WoW API / Variables
local BuyMerchantItem = BuyMerchantItem
local GetAuctionItemClasses = GetAuctionItemClasses
local GetBuybackItemInfo = GetBuybackItemInfo
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetNumBuybackItems = GetNumBuybackItems
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

function M:MerchantFrame_UpdateMerchantInfo()
	local index, button, itemLink
	local _, quality, itemlevel, itemType, r, g, b

	for i = 1, BUYBACK_ITEMS_PER_PAGE do
		index = ((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i
		button = _G["MerchantItem"..i.."ItemButton"]

		if not button.text then
			button.text = button:CreateFontString(nil, "OVERLAY")
			E:FontTemplate(button.text, E.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline)
			E:Point(button.text, "BOTTOMRIGHT", 0, 3)
		end

		if index <= GetMerchantNumItems() then
			itemLink = GetMerchantItemLink(index)

			if itemLink then
				_, _, quality, itemlevel, itemType = GetItemInfo(match(itemLink, "item:(%d+)"))
				r, g, b = GetItemQualityColor(quality)

				button.text:SetText("")

				if (itemlevel and itemlevel > 1) and (quality and quality > 1) and (itemType == ENCHSLOT_WEAPON or itemType == ARMOR) then
					button.text:SetText(itemlevel)
					button.text:SetTextColor(r, g, b)
				end
			end
		end

		if not MerchantBuyBackItemItemButton.text then
			MerchantBuyBackItemItemButton.text = MerchantBuyBackItemItemButton:CreateFontString(nil, "OVERLAY")
			E:FontTemplate(MerchantBuyBackItemItemButton.text, E.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline)
			E:Point(MerchantBuyBackItemItemButton.text, "BOTTOMRIGHT", 0, 3)
		end

		if GetBuybackItemInfo(GetNumBuybackItems()) then
			_, _, quality, itemlevel, itemType = GetItemInfo(GetBuybackItemInfo(GetNumBuybackItems()))

			if (itemlevel and itemlevel > 1) and (quality and quality > 1) and (itemType == ENCHSLOT_WEAPON or itemType == ARMOR) then
				r, g, b = GetItemQualityColor(quality)

				MerchantBuyBackItemItemButton.text:SetText(itemlevel)
				MerchantBuyBackItemItemButton.text:SetTextColor(r, g, b)
			else
				MerchantBuyBackItemItemButton.text:SetText("")
			end
		else
			MerchantBuyBackItemItemButton.text:SetText("")
		end
	end
end

function M:MerchantFrame_UpdateBuybackInfo()
	local _, button, quality, itemlevel, itemType, r, g, b

	for i = 1, BUYBACK_ITEMS_PER_PAGE do
		button = _G["MerchantItem"..i.."ItemButton"]

		if not button.text then
			button.text = button:CreateFontString(nil, "OVERLAY")
			E:FontTemplate(button.text, E.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline)
			E:Point(button.text, "BOTTOMRIGHT", 0, 3)
		end

		if i <= GetNumBuybackItems() then
			if GetBuybackItemInfo(i) then
				_, _, quality, itemlevel, itemType = GetItemInfo(GetBuybackItemInfo(i))

				button.text:SetText("")

				if (itemlevel and itemlevel > 1) and (quality and quality > 1) and (itemType == ENCHSLOT_WEAPON or itemType == ARMOR) then
					r, g, b = GetItemQualityColor(quality)

					button.text:SetText(itemlevel)
					button.text:SetTextColor(r, g, b)
				end
			end
		end
	end
end

function M:MerchantItemLevel()
	if E.db.enhanced.general.merchantItemLevel then
		if not self:IsHooked("MerchantFrame_UpdateMerchantInfo") then
			self:SecureHook("MerchantFrame_UpdateMerchantInfo")
		end
		if not self:IsHooked("MerchantFrame_UpdateBuybackInfo") then
			self:SecureHook("MerchantFrame_UpdateBuybackInfo")
		end
	else
		if self:IsHooked("MerchantFrame_UpdateMerchantInfo") then
			self:Unhook("MerchantFrame_UpdateMerchantInfo")
		end
		if self:IsHooked("MerchantFrame_UpdateBuybackInfo") then
			self:Unhook("MerchantFrame_UpdateBuybackInfo")
		end

		for i = 1, BUYBACK_ITEMS_PER_PAGE do
			if _G["MerchantItem"..i.."ItemButton"].text then
				_G["MerchantItem"..i.."ItemButton"].text:SetText("")
			end
		end
		if MerchantBuyBackItemItemButton.text then
			MerchantBuyBackItemItemButton.text:SetText("")
		end
	end
end
