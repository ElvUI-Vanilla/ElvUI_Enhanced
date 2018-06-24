local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule("Enhanced_Misc");

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestLogTitle = GetQuestLogTitle

local function ShowLevel()
	local scrollOffset = FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
	local numEntries = GetNumQuestLogEntries()
	local questIndex, questLogTitle, questCheck, title, level, isHeader, _

	for i = 1, QUESTS_DISPLAYED do
		questIndex = i + scrollOffset
		questLogTitle = _G["QuestLogTitle"..i]
		questCheck = _G["QuestLogTitle"..i.."Check"]

		if questIndex <= numEntries then
			title, level, _, isHeader = GetQuestLogTitle(questIndex)

			if not isHeader then
				questLogTitle:SetText("["..level.."] "..title)
				E:Point(questCheck, "LEFT", 5, 0)
			end
		end
	end
end

function M:QuestLevelToggle()
	if E.db.enhanced.general.showQuestLevel then
		self:SecureHook("QuestLog_Update", ShowLevel)
		self:SecureHookScript(QuestLogListScrollFrameScrollBar, "OnValueChanged", ShowLevel)
	else
		self:Unhook("QuestLog_Update")
		self:Unhook(QuestLogListScrollFrameScrollBar, "OnValueChanged")
	end

	QuestLog_Update()
end