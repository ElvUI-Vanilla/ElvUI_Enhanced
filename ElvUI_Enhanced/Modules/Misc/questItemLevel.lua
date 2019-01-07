local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule("Enhanced_Misc");

--Cache global variables
--Lua functions
local _G = _G
local match = string.match
--WoW API / Variables
local GetAuctionItemClasses = GetAuctionItemClasses
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
local GetNumQuestChoices = GetNumQuestChoices
local GetNumQuestLogChoices = GetNumQuestLogChoices
local GetNumQuestLogRewards = GetNumQuestLogRewards
local GetNumQuestRewards = GetNumQuestRewards
local GetQuestItemLink = GetQuestItemLink
local GetQuestLogItemLink = GetQuestLogItemLink
local GetQuestLogRewardSpell = GetQuestLogRewardSpell
local GetRewardSpell = GetRewardSpell
local ENCHSLOT_WEAPON, ARMOR = GetAuctionItemClasses()

function M:QuestFrameItems_Update(questState)
	local numQuestRewards, numQuestChoices
	local numQuestSpellRewards = 0

	if questState == "QuestLog" then
		numQuestRewards, numQuestChoices = GetNumQuestLogRewards(), GetNumQuestLogChoices()
		if GetQuestLogRewardSpell() then numQuestSpellRewards = 1 end
	else
		numQuestRewards, numQuestChoices = GetNumQuestRewards(), GetNumQuestChoices()
		if GetRewardSpell() then numQuestSpellRewards = 1 end
	end
	local rewardsCount = numQuestChoices + numQuestRewards + numQuestSpellRewards

	if rewardsCount > 0 then
		local item, icon, link
		local _, quality, itemlevel, itemType

		for i = 1, rewardsCount do
			item = _G[questState.."Item"..i]
			icon = _G[questState.."Item"..i.."IconTexture"]

			if not item.text then
				item.text = item:CreateFontString(nil, "OVERLAY")
				E:FontTemplate(item.text, E.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize, E.db.bags.itemLevelFontOutline)
				E:Point(item.text, "BOTTOMRIGHT", icon, 0, 3)

				if E.private.skins.blizzard.enable and E.private.skins.blizzard.quest then
					item.text:SetParent(item.backdrop)
				end
			end
			item.text:SetText("")

			link = item.type and (questState == "QuestLog" and GetQuestLogItemLink or GetQuestItemLink)(item.type, item:GetID())

			if link then
				_, _, quality, itemlevel, _, itemType = GetItemInfo(match(link, "item:(%d+)"))

				if (itemlevel and itemlevel > 1) and quality and (itemType == ENCHSLOT_WEAPON or itemType == ARMOR) then
					item.text:SetText(itemlevel)
					item.text:SetTextColor(GetItemQualityColor(quality))
				end
			end
		end
	end
end

function M:QuestItemLevel()
	if E.db.enhanced.general.questItemLevel then
		if not self:IsHooked("QuestFrameItems_Update") then
			self:SecureHook("QuestFrameItems_Update")
		end
	end
end