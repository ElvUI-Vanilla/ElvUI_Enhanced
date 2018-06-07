local E, L, V, P, G = unpack(ElvUI)
local M = E:GetModule("Enhanced_Misc")

local match = string.match

local BuyMerchantItem = BuyMerchantItem
local GetItemInfo = GetItemInfo
local GetMerchantItemLink = GetMerchantItemLink
local GetMerchantItemMaxStack = GetMerchantItemMaxStack

function M:MerchantItemButton_OnClick()
	if IsAltKeyDown() then
		local maxStack = select(7, GetItemInfo(match(GetMerchantItemLink(this:GetID()), "item:(%d+)")))

		if maxStack and maxStack > 1 then
			BuyMerchantItem(this:GetID(), GetMerchantItemMaxStack(this:GetID()))
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