local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AK = E:NewModule("Enhanced_AlreadyKnown", "AceHook-3.0", "AceEvent-3.0");

--Cache global variables
--Lua functions
local _G = _G
local match = string.match
--WoW API / Variables
local CreateFrame = CreateFrame
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local GetAuctionItemInfo = GetAuctionItemInfo
local GetAuctionItemLink = GetAuctionItemLink
local GetInboxItem = GetInboxItem
local GetItemInfo = GetItemInfo
local GetMerchantNumItems = GetMerchantNumItems
local GetNumAuctionItems = GetNumAuctionItems
local GetNumBuybackItems = GetNumBuybackItems
local IsAddOnLoaded = IsAddOnLoaded
local SetItemButtonTextureVertexColor = SetItemButtonTextureVertexColor
local hooksecurefunc = hooksecurefunc

local BUYBACK_ITEMS_PER_PAGE = BUYBACK_ITEMS_PER_PAGE
local ITEM_SPELL_KNOWN = ITEM_SPELL_KNOWN
local MERCHANT_ITEMS_PER_PAGE = MERCHANT_ITEMS_PER_PAGE

local knownColor = {r = 0.1, g = 1.0, b = 0.2}

local function MerchantFrame_UpdateMerchantInfo()
	local numItems = GetMerchantNumItems()

	for i = 1, BUYBACK_ITEMS_PER_PAGE, 1 do
		local index = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE + i
		if index > numItems then return end

		local button = _G["MerchantItem"..i.."ItemButton"]

		if button and button:IsShown() then
			local _, _, _, _, numAvailable, isUsable = GetMerchantItemInfo(index)

			if isUsable and AK:IsAlreadyKnown(GetMerchantItemLink(index)) then
				local r, g, b = knownColor.r, knownColor.g, knownColor.b

				if numAvailable == 0 then
					r, g, b = r * 0.5, g * 0.5, b * 0.5
				end

				SetItemButtonTextureVertexColor(button, r, g, b)
			end
		end
	end
end

local function MerchantFrame_UpdateBuybackInfo()
	local numItems = GetNumBuybackItems()

	for i = 1, BUYBACK_ITEMS_PER_PAGE do
		if i > numItems then return end

		local button = _G["MerchantItem"..i.."ItemButton"]

		if button and button:IsShown() then
			local name, _, _, _, _, isUsable = GetBuybackItemInfo(i)
			local _, itemLink = GetItemInfoByName(name)

			if isUsable and AK:IsAlreadyKnown(itemLink) then
				SetItemButtonTextureVertexColor(button, knownColor.r, knownColor.g, knownColor.b)
			end
		end
	end
end

local function AuctionFrameBrowse_Update()
	local numItems = GetNumAuctionItems("list")
	local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)

	for i = 1, NUM_BROWSE_TO_DISPLAY do
		local index = offset + i
		if index > numItems then return end

		local texture = _G["BrowseButton"..i.."ItemIconTexture"]

		if texture and texture:IsShown() then
			local _, _, _, _, canUse = GetAuctionItemInfo("list", index)

			if canUse and AK:IsAlreadyKnown(GetAuctionItemLink("list", index)) then
				texture:SetVertexColor(knownColor.r, knownColor.g, knownColor.b)
			end
		end
	end
end

local function AuctionFrameBid_Update()
	local numItems = GetNumAuctionItems("bidder")
	local offset = FauxScrollFrame_GetOffset(BidScrollFrame)

	for i = 1, NUM_BIDS_TO_DISPLAY do
		local index = offset + i
		if index > numItems then return end

		local texture = _G["BidButton"..i.."ItemIconTexture"]

		if texture and texture:IsShown() then
			local _, _, _, _, canUse = GetAuctionItemInfo("bidder", index)

			if canUse and AK:IsAlreadyKnown(GetAuctionItemLink("bidder", index)) then
				texture:SetVertexColor(knownColor.r, knownColor.g, knownColor.b)
			end
		end
	end
end

local function AuctionFrameAuctions_Update()
	local numItems = GetNumAuctionItems("owner")
	local offset = FauxScrollFrame_GetOffset(AuctionsScrollFrame)

	for i = 1, NUM_AUCTIONS_TO_DISPLAY do
		local index = offset + i
		if index > numItems then return end

		local texture = _G["AuctionsButton"..i.."ItemIconTexture"]

		if texture and texture:IsShown() then
			local _, _, _, _, canUse, _, _, _, _, _, _, _, saleStatus = GetAuctionItemInfo("owner", index)

			if canUse and AK:IsAlreadyKnown(GetAuctionItemLink("owner", index)) then
				local r, g, b = knownColor.r, knownColor.g, knownColor.b
				if saleStatus == 1 then
					r, g, b = r * 0.5, g * 0.5, b * 0.5
				end

				texture:SetVertexColor(r, g, b)
			end
		end
	end
end

local function InboxFrame_Update()
	local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + 1
	local button = _G["OpenMailPackageButton"]

	if button then
		local name, _, _, _, canUse = GetInboxItem(index)

		if name then
			local _, itemLink = GetItemInfoByName(name)

			if name and canUse and AK:IsAlreadyKnown(itemLink) then
				SetItemButtonTextureVertexColor(button, knownColor.r, knownColor.g, knownColor.b)
			end
		end
	end
end

local function QuestFrameItems_Update(questState)
	local numQuestRewards = questState == "QuestLog" and GetNumQuestLogRewards() or GetNumQuestRewards()
	local numQuestChoices = questState == "QuestLog" and GetNumQuestLogChoices() or GetNumQuestChoices()
	local numQuestSpellRewards = questState == "QuestLog" and GetQuestLogRewardSpell() or GetRewardSpell()
	local rewardsCount = numQuestChoices + numQuestRewards + (numQuestSpellRewards and 1 or 0)

	if rewardsCount > 0 then

		for i = 1, rewardsCount do
			local item = _G[questState.."Item"..i]
			local link = item.type and (questState == "QuestLog" and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())
			local _, _, _, _, isUsable = (questState == "QuestLog" and GetQuestLogChoiceInfo or GetQuestItemInfo)(questState == "QuestLog" and i or item.type, i)

			if isUsable and AK:IsAlreadyKnown(link) then
				SetItemButtonTextureVertexColor(item, knownColor.r, knownColor.g, knownColor.b)
			end
		end
	end
end

function AK:IsAlreadyKnown(itemLink)
	if not itemLink then return end

	local itemID = match(itemLink, "item:(%d+)")
	if self.knownTable[itemID] then
		return true
	end

	local _, _, _, _, itemType = GetItemInfo(itemID)
	if not self.knowableTypes[itemType] then return end

	self.scantip:ClearLines()
	self.scantip:SetHyperlink(match(itemLink, "item[%-?%d:]+"))

	for i = 2, self.scantip:NumLines() do
		local text = _G["ElvUI_MerchantAlreadyKnownTextLeft"..i]:GetText()

		if text == ITEM_SPELL_KNOWN then
			self.knownTable[itemID] = true
			return true
		end
	end
end

function AK:ADDON_LOADED()
	if arg1 == "Blizzard_AuctionUI" and not self.auctionHooked then
		self:SetHooks()
	end

	if self.auctionHooked then
		self:UnregisterEvent("ADDON_LOADED")
	end
end

function AK:SetHooks()
	if not self:IsHooked("MerchantFrame_UpdateMerchantInfo") then
		self:SecureHook("MerchantFrame_UpdateMerchantInfo", MerchantFrame_UpdateMerchantInfo)
	end
	if not self:IsHooked("MerchantFrame_UpdateBuybackInfo") then
		self:SecureHook("MerchantFrame_UpdateBuybackInfo", MerchantFrame_UpdateBuybackInfo)
	end
	if not self:IsHooked("InboxFrame_Update") then
		self:SecureHook("InboxFrame_Update", InboxFrame_Update)
	end
	if not self:IsHooked("QuestFrameItems_Update") then
		self:SecureHook("QuestFrameItems_Update", QuestFrameItems_Update)
	end

	if not self.auctionHooked and IsAddOnLoaded("Blizzard_AuctionUI") then
		if not self:IsHooked("AuctionFrameBrowse_Update") then
			self:SecureHook("AuctionFrameBrowse_Update", AuctionFrameBrowse_Update)
		end
		if not self:IsHooked("AuctionFrameBid_Update") then
			self:SecureHook("AuctionFrameBid_Update", AuctionFrameBid_Update)
		end
		if not self:IsHooked("AuctionFrameAuctions_Update") then
			self:SecureHook("AuctionFrameAuctions_Update", AuctionFrameAuctions_Update)
		end

		self.auctionHooked = true
	end
end

function AK:IsLoadeble()
	return not (IsAddOnLoaded("RecipeKnown") or IsAddOnLoaded("AlreadyKnown"))
end

function AK:ToggleState()
	if not self:IsLoadeble() then return end

	if not self.initialized then
		self.scantip = CreateFrame("GameTooltip", "ElvUI_MerchantAlreadyKnown", nil, "GameTooltipTemplate")
		self.scantip:SetOwner(UIParent, "ANCHOR_NONE")

		self.knownTable = {}

		local _, _, _, consumable, _, _, _, recipe, _, miscallaneous = GetAuctionItemClasses()
		self.knowableTypes = {
			[consumable] = true,
			[recipe] = true,
			[miscallaneous] = true
		}

		self.initialized = true
	end

	if E.db.enhanced.general.alreadyKnown then
		self:SetHooks()

		if not IsAddOnLoaded("Blizzard_AuctionUI") then
			self:RegisterEvent("ADDON_LOADED")
		end
	else
		self:UnhookAll()

		self.auctionHooked = nil
	end
end

function AK:Initialize()
	if not E.db.enhanced.general.alreadyKnown then return end

	self:ToggleState()
end

local function InitializeCallback()
	AK:Initialize()
end

E:RegisterModule(AK:GetName(), InitializeCallback)
