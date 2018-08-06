local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule("Enhanced_Misc");
local LIP = LibStub("ItemPrice-1.1");

--Cache global variables
--Lua functions
local _G = _G
local format, match = string.format, string.match
--WoW API / Variables
local GetItemInfo = GetItemInfo
local GetNumQuestChoices = GetNumQuestChoices
local GetQuestItemLink = GetQuestItemLink

local function SelectQuestReward(index)
	local btn = _G[format("QuestRewardItem%d", index)]
	if btn.type == "choice" then
		QuestRewardItemHighlight:ClearAllPoints()
		QuestRewardItemHighlight:SetAllPoints(btn)
		QuestRewardItemHighlight:Show()

		QuestFrameRewardPanel.itemChoice = btn:GetID()
	end
end

function M:QUEST_COMPLETE(msg)
	if not E.private.general.selectQuestReward then return end

	local choice, price = 1, 0
	local num = GetNumQuestChoices()

	if num <= 0 then
		return
	end

	for index = 1, num do
		local link = GetQuestItemLink("choice", index)
		if link then
			local vsp = LIP:GetSellValue(link)
			if vsp and vsp > price then
				price = vsp
				choice = index
			end
		end
	end

	SelectQuestReward(choice)
end

function M:LoadQuestReward()
	self:RegisterEvent("QUEST_COMPLETE")
end