local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:NewModule("Enhanced_Misc", "AceHook-3.0", "AceEvent-3.0");

E.Enhanced_Misc = M

--WoW API / Variables
local CancelDuel = CancelDuel
local GetSpellName = GetSpellName
local IsInInstance = IsInInstance
local RepopMe = RepopMe

function M:PLAYER_DEAD()
	local inInstance, instanceType = IsInInstance()
	if inInstance then
		local soulstone = GetSpellName(20707, BOOKTYPE_SPELL)
		if E.myclass ~= "SHAMAN" and not (soulstone and UnitBuff("player", soulstone)) then
			RepopMe()
		end
	end
end

function M:AutoRelease()
	if E.db.enhanced.general.pvpAutoRelease then
		self:RegisterEvent("PLAYER_DEAD")
	else
		self:UnregisterEvent("PLAYER_DEAD")
	end
end

function M:DUEL_REQUESTED()
	StaticPopup_Hide("DUEL_REQUESTED")
	CancelDuel()
	E:Print(L["Declined duel request from "]..arg1..".")
end

function M:DeclineDuel()
	if E.db.enhanced.general.declineduel then
		self:RegisterEvent("DUEL_REQUESTED")
	else
		self:UnregisterEvent("DUEL_REQUESTED")
	end
end

function M:HideZone()
	if E.db.enhanced.general.hideZoneText then
		ZoneTextFrame:UnregisterAllEvents()
	else
		ZoneTextFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		ZoneTextFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
		ZoneTextFrame:RegisterEvent("ZONE_CHANGED")
	end
end

function M:Initialize()
	self:AutoRelease()
	self:DeclineDuel()
	self:HideZone()
	self:LoadQuestReward()
	self:WatchedFaction()
	self:LoadMoverTransparancy()
	self:QuestLevelToggle()
	self:BuyStackToggle()
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterModule(M:GetName(), InitializeCallback)