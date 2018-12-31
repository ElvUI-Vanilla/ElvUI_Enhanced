local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local RM = E:NewModule("RaidMarkerBar", "AceEvent-3.0");
local S = E:GetModule("Skins");

--Cache global variables
--Lua functions
local format = string.format
--WoW API / Variables
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local UnitExists = UnitExists
local UnitIsPartyLeader = UnitIsPartyLeader
local UnitInParty = UnitInParty
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers

function RM:CreateButtons()
	for i = 1, 9 do
		local button = CreateFrame("Button", format("RaidMarkerBarButton%d", i), self.frame, "ActionButtonTemplate")
		E:StripTextures(button)
		E:SetTemplate(button, "Default", true)
		E:Size(button, self.db.buttonSize)

		local image = button:CreateTexture(nil, "ARTWORK")
		E:SetInside(image)
		image:SetTexture(i == 9 and "Interface\\BUTTONS\\UI-GroupLoot-Pass-Up" or format("Interface\\AddOns\\ElvUI_Enhanced\\Media\\Textures\\RaidTargetingIcon\\UI-RaidTargetingIcon_%d", i))

		button:SetID(i)

		button:SetScript("OnClick", function()
			SetRaidTargetIcon("target", this:GetID() < 9 and this:GetID() or 0)
		end)

		button:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_BOTTOM")
			GameTooltip:AddLine(this:GetID() == 9 and L["Click to clear the mark."] or L["Click to mark the target."], 1, 1, 1)
			GameTooltip:Show()
		end)

		button:SetScript("OnLeave", function() GameTooltip:Hide() end)
		button:RegisterForClicks("LeftButtonDown" or "RightButtonDown")

		HookScript(button, "OnEnter", S.SetModifiedBackdrop)
		HookScript(button, "OnLeave", S.SetOriginalBackdrop)

		E:StyleButton(button)
		self.frame.buttons[i] = button
	end
end

function RM:UpdateBar(first)
	if first then
		E:Point(self.frame, "CENTER", E.UIParent, "CENTER", 0, 0)
	end

	if self.db.orientation == "VERTICAL" then
		self.frame:SetWidth(self.db.buttonSize + 4)
		self.frame:SetHeight(((self.db.buttonSize * 9) + (self.db.spacing * 8)) + 4)
	else
		self.frame:SetWidth(((self.db.buttonSize * 9) + (self.db.spacing * 8)) + 4)
		self.frame:SetHeight(self.db.buttonSize + 4)
	end

	local head, tail
	for i = 9, 1, -1 do
		local button = self.frame.buttons[i]
		local prev = self.frame.buttons[i + 1]
		button:ClearAllPoints()

		button:SetWidth(self.db.buttonSize)
		button:SetHeight(self.db.buttonSize)

		if self.db.orientation == "VERTICAL" then
			head = self.db.reverse and "BOTTOM" or "TOP"
			tail = self.db.reverse and "TOP" or "BOTTOM"
			if i == 9 then
				button:SetPoint(head, 0, (self.db.reverse and 2 or -2))
			else
				button:SetPoint(head, prev, tail, 0, self.db.spacing*(self.db.reverse and 1 or -1))
			end
		else
			head = self.db.reverse and "RIGHT" or "LEFT"
			tail = self.db.reverse and "LEFT" or "RIGHT"
			if i == 9 then
				button:SetPoint(head, (self.db.reverse and -2 or 2), 0)
			else
				button:SetPoint(head, prev, tail, self.db.spacing*(self.db.reverse and -1 or 1), 0)
			end
		end
	end
end

function RM:VisibilityCheck(visibility)
	local isPartyLeader = UnitIsPartyLeader("player")
	local inParty = UnitInParty("player")
	local numPartyMembers = GetNumPartyMembers()
	local numRaidMembers = GetNumRaidMembers()
	local unitExists = UnitExists("target")

	if visibility == "DEFAULT" then
		self.frame:Hide()

		if inParty and (numPartyMembers > 0 or numRaidMembers > 0) then
			if isPartyLeader then
				self.frame:Show()
			else
				self.frame:Hide()
			end
		else
			if unitExists then
				self.frame:Show()
			else
				self.frame:Hide()
			end
		end
	elseif visibility == "INPARTY" then
		if inParty and isPartyLeader and (numPartyMembers > 0 or numRaidMembers > 0) then
			self.frame:Show()
		else
			self.frame:Hide()
		end
	elseif visibility == "ALWAYS" then
		self.frame:Show()
	end
end

function RM:Visibility()
	if self.db.enable then
		RM:VisibilityCheck(self.db.visibility)
		E:EnableMover(self.frame.mover:GetName())
	else
		self.frame:Hide()
		E:DisableMover(self.frame.mover:GetName())
	end
end

function RM:Backdrop()
	if self.db.backdrop then
		self.frame.backdrop:Show()
	else
		self.frame.backdrop:Hide()
	end

	if self.db.transparentBackdrop then
		E:SetTemplate(self.frame.backdrop, "Transparent")
	else
		E:SetTemplate(self.frame.backdrop, "Default")
	end
end

function RM:ButtonBackdrop()
	for i = 1, 9 do
		local button = self.frame.buttons[i]
		if self.db.transparentButtons then
			E:SetTemplate(button, "Transparent")
		else
			E:SetTemplate(button, "Default", true)
		end
	end
end

function RM:Initialize()
	self.db = E.db.enhanced.raidmarkerbar

	self.frame = CreateFrame("Frame", "RaidMarkerBar", E.UIParent)
	self.frame:SetResizable(false)
	self.frame:SetClampedToScreen(true)
	self.frame:SetFrameStrata("LOW")
	E:CreateBackdrop(self.frame)
	self.frame:ClearAllPoints()
	E:Point(self.frame, "BOTTOMRIGHT", E.UIParent, "BOTTOMRIGHT", -1, 200)
	self.frame.buttons = {}

	self:RegisterEvent("PLAYER_TARGET_CHANGED", "Visibility")
	self:RegisterEvent("PLAYER_FLAGS_CHANGED", "Visibility")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Visibility")

	self.frame.backdrop:SetAllPoints()

	E:CreateMover(self.frame, "RaidMarkerBarAnchor", L["Raid Marker Bar"])

	self:CreateButtons()

	function RM:ForUpdateAll()
		self:Visibility()
		self:Backdrop()
		self:ButtonBackdrop()
		self:UpdateBar(true)
	end

	self:ForUpdateAll()
end

local function InitializeCallback()
	RM:Initialize()
end

E:RegisterModule(RM:GetName(), InitializeCallback)