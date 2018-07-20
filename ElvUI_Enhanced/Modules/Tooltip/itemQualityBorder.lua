local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local IBC = E:NewModule("Enhanced_ItemBorderColor", "AceHook-3.0");
local TT = E:GetModule("Tooltip");

--Cache global variables
--Lua functions
local tonumber = tonumber
local match = string.match
--WoW API / Variables
local GetItemInfoByName = GetItemInfoByName
local GetItemQualityColor = GetItemQualityColor

function IBC:SetBorderColor(_, tt)
	if GameTooltipTextRight1:IsShown() then return end
	local itemName = GameTooltipTextLeft1:GetText()
	if not itemName then return end

	local _, link, quality = GetItemInfoByName(itemName)
	if not link then return end

	local id = tonumber(match(link, "item:(%d+)"))

	if quality then
		tt:SetBackdropBorderColor(GetItemQualityColor(quality))
	end
end

function IBC:ToggleState()
	if E.db.enhanced.tooltip.itemQualityBorderColor then
		if not self:IsHooked(TT, "SetStyle", "SetBorderColor") then
			self:SecureHook(TT, "SetAction", "SetBorderColor")
			self:SecureHook(TT, "SetAuctionItem", "SetBorderColor")
			self:SecureHook(TT, "SetAuctionSellItem", "SetBorderColor")
			self:SecureHook(TT, "SetBagItem", "SetBorderColor")
			self:SecureHook(TT, "SetCraftItem", "SetBorderColor")
			self:SecureHook(TT, "SetCraftSpell", "SetBorderColor")
			self:SecureHook(TT, "SetHyperlink", "SetBorderColor")
			self:SecureHook(TT, "SetInboxItem", "SetBorderColor")
			self:SecureHook(TT, "SetInventoryItem", "SetBorderColor")
			self:SecureHook(TT, "SetLootItem", "SetBorderColor")
			self:SecureHook(TT, "SetLootRollItem", "SetBorderColor")
			self:SecureHook(TT, "SetMerchantItem", "SetBorderColor")
			self:SecureHook(TT, "SetQuestItem", "SetBorderColor")
			self:SecureHook(TT, "SetQuestLogItem", "SetBorderColor")
			self:SecureHook(TT, "SetSendMailItem", "SetBorderColor")
			self:SecureHook(TT, "SetTradePlayerItem", "SetBorderColor")
			self:SecureHook(TT, "SetTradeSkillItem", "SetBorderColor")
			self:SecureHook(TT, "SetTradeTargetItem", "SetBorderColor")
		end
	else
		self:UnhookAll()
	end
end

function IBC:Initialize()
	if not E.db.enhanced.tooltip.itemQualityBorderColor then return end

	self:ToggleState()
end

local function InitializeCallback()
	IBC:Initialize()
end

E:RegisterModule(IBC:GetName(), InitializeCallback)