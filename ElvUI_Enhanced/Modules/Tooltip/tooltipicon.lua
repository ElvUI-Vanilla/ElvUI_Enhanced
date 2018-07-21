local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TI = E:NewModule("Enhanced_TooltipIcon", "AceHook-3.0");
local TT = E:GetModule("Tooltip");

--Cache global variables
--Lua functions
local _G = _G
local tonumber, unpack = tonumber, unpack
local match = string.match
--WoW API / Variables
local CreateFrame = CreateFrame
local GetItemInfoByName = GetItemInfoByName
local GetItemQualityColor = GetItemQualityColor

function TI:SetIcon(_, tt)
	local tooltip = tt:GetName()

	if not _G[tooltip.."TextRight1"]:IsShown() then
		local itemName = _G[tooltip.."TextLeft1"]:GetText()
		if itemName then
			local _, _, quality, _, _, _, _, _, texture = GetItemInfoByName(itemName)
			if texture then
				self.icon.texture:SetTexture(texture)
				self.icon:Show()

				if E.db.enhanced.tooltip.itemQualityBorderColor then
					if quality then
						self.icon:SetBackdropBorderColor(GetItemQualityColor(quality))
					end
				end

				return
			end
		end
	end

	self.icon.texture:SetTexture(nil)
	self.icon:Hide()
end

function TI:ToggleState()
	if E.db.enhanced.tooltip.tooltipIcon.enable then
		if not self.icon then
			self.icon = CreateFrame("Frame", "Enhanced_TooltipIcon", GameTooltip)
			E:Point(self.icon, "TOPRIGHT", GameTooltip, "TOPLEFT", -3, 0)
			E:SetTemplate(self.icon, "Default")
			E:Size(self.icon, 22)
			self.icon:Hide()

			self.icon.texture = self.icon:CreateTexture(nil, "ARTWORK")
			self.icon.texture:SetTexture(nil)
			E:SetInside(self.icon.texture)
			self.icon.texture:SetTexCoord(unpack(E.TexCoords))
		end

		if not self:IsHooked(TT, "SetAction", "SetIcon") then
			self:SecureHook(TT, "SetAction", "SetIcon")
			self:SecureHook(TT, "SetAuctionItem", "SetIcon")
			self:SecureHook(TT, "SetAuctionSellItem", "SetIcon")
			self:SecureHook(TT, "SetBagItem", "SetIcon")
			self:SecureHook(TT, "SetCraftItem", "SetIcon")
			self:SecureHook(TT, "SetCraftSpell", "SetIcon")
			self:SecureHook(TT, "SetHyperlink", "SetIcon")
			self:SecureHook(TT, "SetInboxItem", "SetIcon")
			self:SecureHook(TT, "SetInventoryItem", "SetIcon")
			self:SecureHook(TT, "SetLootItem", "SetIcon")
			self:SecureHook(TT, "SetLootRollItem", "SetIcon")
			self:SecureHook(TT, "SetMerchantItem", "SetIcon")
			self:SecureHook(TT, "SetQuestItem", "SetIcon")
			self:SecureHook(TT, "SetQuestLogItem", "SetIcon")
			self:SecureHook(TT, "SetSendMailItem", "SetIcon")
			self:SecureHook(TT, "SetTradePlayerItem", "SetIcon")
			self:SecureHook(TT, "SetTradeSkillItem", "SetIcon")
			self:SecureHook(TT, "SetTradeTargetItem", "SetIcon")
		end
	else
		self.icon:Hide()
		self:UnhookAll()
	end
end

function TI:Initialize()
	if not E.db.enhanced.tooltip.tooltipIcon.enable then return end

	self:ToggleState()
end

local function InitializeCallback()
	TI:Initialize()
end

E:RegisterModule(TI:GetName(), InitializeCallback)