local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule("Enhanced_Misc");

--Cache global variables
--Lua functions
local match = string.match
--WoW API / Variables
local BuyMerchantItem = BuyMerchantItem
local GetItemInfo = GetItemInfo
local GetMerchantItemLink = GetMerchantItemLink
local GetMerchantItemMaxStack = GetMerchantItemMaxStack

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