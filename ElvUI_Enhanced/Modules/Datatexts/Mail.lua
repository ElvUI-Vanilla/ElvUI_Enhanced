local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts");

--WoW API / Variables
local GetInboxNumItems = GetInboxNumItems
local GetInboxHeaderInfo = GetInboxHeaderInfo
local HasNewMail = HasNewMail
local HAVE_MAIL = HAVE_MAIL
local MAIL_LABEL = MAIL_LABEL

local readMail, unreadMail

local function ColorizeSettingName(settingName)
	return format("|cffff8000%s|r", settingName)
end

local function OnEvent(self, event)
	local newMail = false

	if event == "UPDATE_PENDING_MAIL" or event == "PLAYER_ENTERING_WORLD" or event =="PLAYER_LOGIN" then
		newMail = HasNewMail()

		if unreadMail ~= newMail then
			unreadMail = newMail
		end

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:UnregisterEvent("PLAYER_LOGIN")
	end
	if event == "MAIL_INBOX_UPDATE" or event == "MAIL_SHOW" or event == "MAIL_CLOSED" then
		for i = 1, GetInboxNumItems() do
			local _, _, _, _, _, _, _, _, wasRead = GetInboxHeaderInfo(i)
			if not wasRead then
				newMail = true
				break
			end
		end
	end

	if newMail then
		self.text:SetText(L["New Mail"])
		self.text:SetTextColor(0, 1, 0)
		readMail = false
	else
		self.text:SetText(L["No Mail"])
		self.text:SetTextColor(1, 1, 1)
		readMail = true
	end
end

local function OnUpdate(self)
	OnEvent(self, "UPDATE_PENDING_MAIL")
	self:SetScript("OnUpdate", nil)
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	if not read then
		DT.tooltip:AddLine(HAVE_MAIL)
	end
	DT.tooltip:Show()
end

DT:RegisterDatatext("Mail", {"PLAYER_ENTERING_WORLD", "MAIL_INBOX_UPDATE", "UPDATE_PENDING_MAIL", "MAIL_CLOSED", "PLAYER_LOGIN", "MAIL_SHOW"}, OnEvent, nil, nil, OnEnter, nil, ColorizeSettingName(MAIL_LABEL))
