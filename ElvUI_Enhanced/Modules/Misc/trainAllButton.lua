local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TA = E:NewModule("Enhanced_TrainAll", "AceHook-3.0", "AceEvent-3.0");

--Cache global variables
--Lua functions
local select = select
--WoW API / Variables
local BuyTrainerService = BuyTrainerService
local GetNumTrainerServices = GetNumTrainerServices
local GetTrainerServiceCost = GetTrainerServiceCost
local GetTrainerServiceInfo = GetTrainerServiceInfo

function TA:ButtonCreate()
	self.button = CreateFrame("Button", "ElvUI_TrainAllButton", ClassTrainerFrame, "UIPanelButtonTemplate")
	E:Size(self.button, 80, 22)
	self.button:SetText(TRAIN.." "..ALL)

	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.trainer) then
		E:Point(self.button, "TOPRIGHT", ClassTrainerTrainButton, "TOPLEFT", 0, 0)
	else
		E:GetModule("Skins"):HandleButton(self.button)
		E:Point(self.button, "TOPRIGHT", ClassTrainerTrainButton, "TOPLEFT", -3, 0)
	end

	self.button:SetScript("OnClick", function()
		for i = 1, GetNumTrainerServices() do
			if select(3, GetTrainerServiceInfo(i)) == "available" then
				BuyTrainerService(i)
			end
		end
	end)

	HookScript(self.button, "OnEnter", function()
		local cost = 0
		for i = 1, GetNumTrainerServices() do
			if select(3, GetTrainerServiceInfo(i)) == "available" then
				cost = cost + GetTrainerServiceCost(i)
			end
		end

		GameTooltip:SetOwner(self.button,"ANCHOR_TOPRIGHT", 0, 4)
		GameTooltip:SetText("|cffffffff" .. L["Total cost:"].."|r "..E:FormatMoney(cost, E.db.datatexts.goldFormat))
	end)

	HookScript(self.button, "OnLeave", function()
		GameTooltip:Hide()
	end)
end

function TA:ButtonUpdate()
	for i = 1, GetNumTrainerServices() do
		if ClassTrainerTrainButton:IsEnabled() and select(3, GetTrainerServiceInfo(i)) == "available" then
			self.button:Enable()
			return
		end
	end

	self.button:Disable()
end

function TA:ADDON_LOADED()
	if arg1 ~= "Blizzard_TrainerUI" then return end

	self:ButtonCreate()

	if not self:IsHooked("ClassTrainerFrame_Update") then
		self:SecureHook("ClassTrainerFrame_Update", "ButtonUpdate")
	end

	self:UnregisterEvent("ADDON_LOADED")
end

function TA:ToggleState()
	if E.db.enhanced.general.trainAllButton then
		if not self.button then
			self:RegisterEvent("ADDON_LOADED")
		else
			self.button:Show()
			if not self:IsHooked("ClassTrainerFrame_Update") then
				self:SecureHook("ClassTrainerFrame_Update", "ButtonUpdate")
			end
		end
	else
		if not self.button then
			self:UnregisterEvent("ADDON_LOADED")
		else
			self.button:Hide()
			self:UnhookAll()
		end
	end
end

function TA:Initialize()
	if not E.db.enhanced.general.trainAllButton then return end

	self:ToggleState()
end

local function InitializeCallback()
	TA:Initialize()
end

E:RegisterModule(TA:GetName(), InitializeCallback)