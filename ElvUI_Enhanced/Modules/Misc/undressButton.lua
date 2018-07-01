local E, L, V, P, G = unpack(ElvUI)
local UB = E:NewModule("Enhanced_UndressButtons", "AceEvent-3.0")
local S = E:GetModule("Skins")

function UB:CreateUndressButton(auction)
	if not auction then
		self.dressUpButton = CreateFrame("Button", "DressUpFrame_UndressButton", DressUpFrame, "UIPanelButtonTemplate")
		E:Size(self.dressUpButton, 80, 22)
		self.dressUpButton:SetText(L["Undress"])
		self.dressUpButton:SetScript("OnClick", function()
			this.model:Undress()
			PlaySound("gsTitleOptionOK")
		end)
		self.dressUpButton.model = DressUpModel

		if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.dressingroom) then
			E:Point(self.dressUpButton, "RIGHT", DressUpFrameResetButton, "LEFT", 2, 0)
		else
			S:HandleButton(self.dressUpButton)
			E:Point(self.dressUpButton, "RIGHT", DressUpFrameResetButton, "LEFT", -3, 0)
		end
	else
		self.auctionDressUpButton = CreateFrame("Button", "AuctionDressUpFrame_UndressButton", AuctionDressUpFrame, "UIPanelButtonTemplate")
		E:Size(self.auctionDressUpButton, 80, 22)
		self.auctionDressUpButton:SetFrameStrata("HIGH")
		self.auctionDressUpButton:SetText(L["Undress"])
		self.auctionDressUpButton:SetScript("OnClick", function()
			this.model:Undress()
			PlaySound("gsTitleOptionOK")
		end)
		self.auctionDressUpButton.model = AuctionDressUpModel

		if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.dressingroom) then
			E:Point(self.auctionDressUpButton, "BOTTOM", AuctionDressUpFrameResetButton, "BOTTOM", 0, -25)
		else
			S:HandleButton(self.auctionDressUpButton)
			E:Point(self.auctionDressUpButton, "RIGHT", AuctionDressUpFrameResetButton, "LEFT", -3, 0)
			E:Point(AuctionDressUpFrameResetButton, "BOTTOM", 42, 33)
		end
	end
end

function UB:ADDON_LOADED(_, addon)
	if addon ~= "Blizzard_AuctionUI" then return end

	self:CreateUndressButton(true)

	self:UnregisterEvent("ADDON_LOADED")
end

function UB:ToggleState()
	if E.db.enhanced.general.undressButton then
		if not self.dressUpButton then
			self:CreateUndressButton()
		end
		self.dressUpButton:Show()

		if self.auctionDressUpButton then
			self.auctionDressUpButton:Show()
		else
			self:RegisterEvent("ADDON_LOADED")
		end
	else
		if self.dressUpButton then
			self.dressUpButton:Hide()
		end

		if self.auctionDressUpButton then
			self.auctionDressUpButton:Hide()
		else
			self:UnregisterEvent("ADDON_LOADED")
		end
	end
end

function UB:Initialize()
	if not E.db.enhanced.general.undressButton then return end

	self:ToggleState()
end

local function InitializeCallback()
	UB:Initialize()
end

E:RegisterModule(UB:GetName(), InitializeCallback)