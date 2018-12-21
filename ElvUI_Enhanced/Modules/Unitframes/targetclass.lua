local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TC = E:NewModule("Enhanced_TargetClass", "AceEvent-3.0");

--Cache global variables
--Lua functions
local select = select
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UnitClassification = UnitClassification
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

function TC:TargetChanged()
	self.frame:Hide()

	local class = UnitIsPlayer("target") and select(2, UnitClass("target")) or UnitClassification("target")
	if class then
		local coordinates = CLASS_ICON_TCOORDS[class]
		if coordinates then
			self.frame.Texture:SetTexCoord(coordinates[1], coordinates[2], coordinates[3], coordinates[4])
			self.frame:Show()
		end
	end
end

function TC:ToggleSettings()
	if self.db.enable then
		E:Size(self.frame, self.db.size, self.db.size)
		self.frame:ClearAllPoints()
		E:Point(self.frame, "CENTER", ElvUF_Target, "TOP", self.db.xOffset, self.db.yOffset)

		self:RegisterEvent("PLAYER_TARGET_CHANGED", "TargetChanged")
		self:TargetChanged()
	else
		self:UnregisterEvent("PLAYER_TARGET_CHANGED")
		self.frame:Hide()
	end
end

function TC:Initialize()
	self.db = E.db.enhanced.unitframe.units.target.classicon

	self.frame = CreateFrame("Frame", "TargetClass", E.UIParent)
	self.frame:SetFrameLevel(12)
	self.frame.Texture = self.frame:CreateTexture(nil, "ARTWORK")
	self.frame.Texture:SetAllPoints()
	self.frame.Texture:SetTexture([[Interface\AddOns\ElvUI\Media\Textures\Icons-Classes]])

	self:ToggleSettings()
end

local function InitializeCallback()
	TC:Initialize()
end

E:RegisterModule(TC:GetName(), InitializeCallback)