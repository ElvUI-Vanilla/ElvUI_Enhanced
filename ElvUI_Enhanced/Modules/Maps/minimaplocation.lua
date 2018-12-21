local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ML = E:NewModule("Enhanced_MinimapLocation", "AceHook-3.0");
local M = E:GetModule("Minimap");

--Cache global variables
--Lua functions
local _G = _G
local format = string.format
--WoW API / Variables
local GetPlayerMapPosition = GetPlayerMapPosition
local UnitAffectingCombat = UnitAffectingCombat
local UIFrameFadeIn = UIFrameFadeIn

local init = false
local cluster, panel, location, xMap, yMap

local digits = {
	[0] = {.5, "%.0f"},
	[1] = {.2, "%.1f"},
	[2] = {.1, "%.2f"}
}

local function UpdateLocation()
	location.elapsed = (location.elapsed or 0) + arg1
	if location.elapsed < digits[E.db.enhanced.minimap.locationdigits][1] then return end

	xMap.pos, yMap.pos = GetPlayerMapPosition("player")
	xMap.text:SetText(format(digits[E.db.enhanced.minimap.locationdigits][2], xMap.pos * 100))
	yMap.text:SetText(format(digits[E.db.enhanced.minimap.locationdigits][2], yMap.pos * 100))

	location.elapsed = 0
end

local function CreateEnhancedMaplocation()
	cluster = _G["MinimapCluster"]

	panel = CreateFrame("Frame", "EnhancedLocationPanel", _G["MinimapCluster"])
	panel:SetFrameStrata("BACKGROUND")
	E:Point(panel, "CENTER", E.UIParent, "CENTER", 0, 0)
	E:Size(panel, 206, 22)

	xMap = CreateFrame("Frame", "MapCoordinatesX", panel)
	E:SetTemplate(xMap, "Transparent")
	E:Point(xMap, "LEFT", panel, "LEFT", 0, 0)
	E:Size(xMap, 40, 22)

	xMap.text = xMap:CreateFontString(nil, "OVERLAY")
	E:FontTemplate(xMap.text)
	xMap.text:SetAllPoints(xMap)

	yMap = CreateFrame("Frame", "MapCoordinatesY", panel)
	E:SetTemplate(yMap, "Transparent")
	E:Point(yMap, "RIGHT", panel, "RIGHT", 0, 0)
	E:Size(yMap, 40, 22)

	yMap.text = yMap:CreateFontString(nil, "OVERLAY")
	E:FontTemplate(yMap.text)
	yMap.text:SetAllPoints(yMap)

	location = CreateFrame("Frame", "EnhancedLocationText", panel)
	E:SetTemplate(location, "Transparent")
	E:Size(location, 40, 22)
	E:Point(location, "LEFT", xMap, "RIGHT", E.PixelMode and -1 or 1, 0)
	E:Point(location, "RIGHT", yMap, "LEFT", E.PixelMode and 1 or -1, 0)

	location.text = location:CreateFontString(nil, "OVERLAY")
	E:FontTemplate(location.text)
	location.text:SetAllPoints(location)
end

local function ShowMinimap()
	if not UnitAffectingCombat("player") then
		if E.db.enhanced.minimap.fadeindelay == 0 then
			cluster:Show()
			Minimap.backdrop:Show()
		else
			UIFrameFadeIn(cluster, E.db.enhanced.minimap.fadeindelay)
			UIFrameFadeIn(Minimap.backdrop, E.db.enhanced.minimap.fadeindelay)
		end
	end
end

local function HideMinimap()
	cluster:Hide()
	Minimap.backdrop:Hide()
end

local function Update_ZoneText()
	E:FontTemplate(xMap.text, E.LSM:Fetch("font", E.db.general.minimap.locationFont), E.db.general.minimap.locationFontSize, E.db.general.minimap.locationFontOutline)
	E:FontTemplate(yMap.text, E.LSM:Fetch("font", E.db.general.minimap.locationFont), E.db.general.minimap.locationFontSize, E.db.general.minimap.locationFontOutline)

	E:FontTemplate(location.text, E.LSM:Fetch("font", E.db.general.minimap.locationFont), E.db.general.minimap.locationFontSize, E.db.general.minimap.locationFontOutline)
	location.text:SetTextColor(M:GetLocTextColor())
	location.text:SetText(strsub(GetMinimapZoneText(), 1, 25))
end

local function UpdateSettings()
	if not E.private.general.minimap.enable then return end

	if not init then
		init = true
		CreateEnhancedMaplocation()
	end

	if E.db.enhanced.minimap.hideincombat then
		M:RegisterEvent("PLAYER_REGEN_DISABLED", HideMinimap)
		M:RegisterEvent("PLAYER_REGEN_ENABLED", ShowMinimap)
	else
		M:UnregisterEvent("PLAYER_REGEN_DISABLED")
		M:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	local holder = MMHolder
	E:Point(panel, "BOTTOMLEFT", holder, "TOPLEFT", 0, -(E.PixelMode and 1 or -1))
	E:Size(panel, E:Scale(holder:GetWidth()) + (E.PixelMode and 1 or -1), 22)

	local point, relativeTo, relativePoint = holder:GetPoint()
	if E.db.general.minimap.locationText == "ABOVE" then
		E:Point(holder, point, relativeTo, relativePoint, 0, -21)
		E:Height(holder, holder:GetHeight() + 22)
		panel:SetScript("OnUpdate", UpdateLocation)
		panel:Show()
	else
		E:Point(holder, point, relativeTo, relativePoint, 0, 0)
		panel:SetScript("OnUpdate", nil)
		panel:Hide()
	end

	if MinimapMover then
		E:Size(MinimapMover, holder:GetWidth(), holder:GetHeight())
	end
end

function ML:UpdateSettings()
	if E.db.enhanced.minimap.location then
		if not self:IsHooked(M, "Update_ZoneText") then
			self:SecureHook(M, "Update_ZoneText", Update_ZoneText)
		end
		if not self:IsHooked(M, "UpdateSettings") then
			self:SecureHook(M, "UpdateSettings", UpdateSettings)
		end

		M:UpdateSettings()
		M:Update_ZoneText()
	else
		self:UnhookAll()

		local mmholder = MMHolder
		local point, relativeTo, relativePoint = MMHolder:GetPoint()
		E:Point(mmholder, point, relativeTo, relativePoint, 0, 0)

		if E.db.datatexts.minimapPanels then
			E:Height(mmholder, Minimap:GetHeight() + (LeftMiniPanel and (LeftMiniPanel:GetHeight() + E.Border) or 24) + E.Spacing * 3)
		else
			E:Height(mmholder, Minimap:GetHeight() + E.Border + E.Spacing * 3)
		end

		if MinimapMover then
			E:Size(MinimapMover, mmholder:GetWidth(), mmholder:GetHeight())
		end

		panel:Hide()
	end
end

function ML:Initialize()
	if not E.db.enhanced.minimap.location then return end

	self:SecureHook(M, "Update_ZoneText", Update_ZoneText)
	self:SecureHook(M, "UpdateSettings", UpdateSettings)
end

local function InitializeCallback()
	ML:Initialize()
end

E:RegisterModule(ML:GetName(), InitializeCallback)