local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AL = E:NewModule("AddOnList", "AceHook-3.0");

--Cache global variables
--Lua functions
local _G = _G
local floor = math.floor
--WoW API / Variables
local CreateFrame = CreateFrame
local DisableAddOn = DisableAddOn
local EnableAddOn = EnableAddOn
local FauxScrollFrame_Update = FauxScrollFrame_Update
local GetAddOnDependencies = GetAddOnDependencies
local GetAddOnInfo = GetAddOnInfo
local GetNumAddOns = GetNumAddOns
local IsAddOnLoaded = IsAddOnLoaded
local IsShiftKeyDown = IsShiftKeyDown
local LoadAddOn = LoadAddOn

function AL:HasAnyChanged()
	for i = 1, GetNumAddOns() do
		local _, _, _, enabled, _, reason = GetAddOnInfo(i)
		if enabled ~= ElvUI_AddonList.startStatus[i] and reason ~= "DEP_DISABLED" then
			return true
		end
	end

	return false
end

function AL:IsAddOnLoadOnDemand(index)
	local lod = false

	if IsAddOnLoadOnDemand(index) then
		if not IsAddOnLoaded(index) then
			lod = true
		end
	end

	return lod
end

function AL:SetStatus(entry, load, status, reload)
	if entry then
		if load then
			entry.LoadButton:Show()
		else
			entry.LoadButton:Hide()
		end

		if status then
			entry.Status:Show()
		else
			entry.Status:Hide()
		end

		if reload then
			entry.Reload:Show()
		else
			entry.Reload:Hide()
		end
	end
end

function AL:Update()
	local numEntries = GetNumAddOns()
	local addonIndex, entry, checkbox, status

	for i = 1, 20 do
		addonIndex = ElvUI_AddonList.offset + i
		entry = _G["ElvUI_AddonListEntry"..i]

		if addonIndex > numEntries then
			entry:Hide()
		else
			local name, title, _, enabled, loadable, reason = GetAddOnInfo(addonIndex)

			checkbox = _G["ElvUI_AddonListEntry"..i.."Enabled"]
			checkbox:SetChecked(enabled)

			status = _G["ElvUI_AddonListEntry"..i.."Title"]

			if loadable or (enabled and (reason == "DEP_DEMAND_LOADED" or reason == "DEMAND_LOADED")) then
				status:SetTextColor(1.0, 0.78, 0.0)
			elseif enabled and reason ~= "DEP_DISABLED" then
				status:SetTextColor(1.0, 0.1, 0.1)
			else
				status:SetTextColor(0.5, 0.5, 0.5)
			end

			if title then
				status:SetText(title)
			else
				status:SetText(name)
			end

			status = _G["ElvUI_AddonListEntry"..i.."Status"]
			if not loadable and reason then
				status:SetText(_G["ADDON_"..reason])
			else
				status:SetText("")
			end

			if enabled ~= ElvUI_AddonList.startStatus[addonIndex] and reason ~= "DEP_DISABLED" then
				if enabled then
					if self:IsAddOnLoadOnDemand(addonIndex) then
						self:SetStatus(entry, true, false, false)
					else
						self:SetStatus(entry, false, false, true)
					end
				else
					self:SetStatus(entry, false, false, true)
				end
			else
				self:SetStatus(entry, false, true, false)
			end

			entry:SetID(addonIndex)
			entry:Show()
		end
	end

	FauxScrollFrame_Update(ElvUI_AddonListScrollFrame, numEntries, 20, 16)

	if self:HasAnyChanged() then
		ElvUI_AddonListOkayButton:SetText(L["Reload UI"])
		ElvUI_AddonList.shouldReload = true
	else
		ElvUI_AddonListOkayButton:SetText(OKAY)
		ElvUI_AddonList.shouldReload = false
	end
end

function AL:Enable(index, enabled)
	if enabled then
		EnableAddOn(index)
	else
		DisableAddOn(index)
	end

	self:Update()
end

function AL:LoadAddOn(index)
	if not self:IsAddOnLoadOnDemand(index) then return end

	LoadAddOn(index)

	if IsAddOnLoaded(index) then
		ElvUI_AddonList.startStatus[index] = 1
	end

	self:Update()
end

function AL:TooltipBuildDeps(...)
	local deps = ""

	for i = 1, getn(arg) do
		if i == 1 then
			deps = L["Dependencies: "]..select(i, unpack(arg))
		else
			deps = deps..", "..select(i, unpack(arg))
		end
	end

	return deps
end

function AL:TooltipUpdate()
	local id = this:GetID()
	if id == 0 then return end

	local name, title, notes, _, _, security = GetAddOnInfo(id)
	if not name then return end

	GameTooltip:ClearLines()

	if security == "BANNED" then
		GameTooltip:SetText(L["This addon has been disabled. You should install an updated version."])
	else
		if title then
			GameTooltip:AddLine(title)
		else
			GameTooltip:AddLine(name)
		end

		GameTooltip:AddLine(notes, 1.0, 1.0, 1.0)
		GameTooltip:AddLine(self:TooltipBuildDeps(GetAddOnDependencies(id)))
	end

	GameTooltip:Show()
end

function AL:Initialize()
	if IsAddOnLoaded("ACP") then return end

	local S = E:GetModule("Skins")

	local addonList = CreateFrame("Frame", "ElvUI_AddonList", UIParent)
	addonList:SetFrameStrata("HIGH")
	E:Size(addonList, 520, 475)
	E:Point(addonList, "CENTER", 0, 0)
	E:SetTemplate(addonList, "Transparent")
	addonList:Hide()
	tinsert(UISpecialFrames, addonList:GetName())

	addonList.offset = 0
	addonList.shouldReload = false
	addonList.startStatus = {}

	for i = 1, GetNumAddOns() do
		local _, _, _, enabled = GetAddOnInfo(i)
		addonList.startStatus[i] = enabled
	end

	local addonTitle = addonList:CreateFontString("$parentTitle", "BACKGROUND", "GameFontNormal")
	E:Point(addonTitle, "TOP", 0, -12)
	addonTitle:SetText(ADDONS)

	local SPACING = (E.PixelMode and 3 or 5)

	local cancelButton = CreateFrame("Button", "$parentCancelButton", addonList, "UIPanelButtonTemplate")
	E:Size(cancelButton, 80, 22)
	E:Point(cancelButton, "BOTTOMRIGHT", -SPACING, SPACING)
	cancelButton:SetText(CANCEL)
	S:HandleButton(cancelButton)

	local closeButton = CreateFrame("Button", "$parentCloseButton", addonList, "UIPanelCloseButton")
	E:Size(closeButton, 32)
	E:Point(closeButton, "TOPRIGHT", -2, 2)
	S:HandleCloseButton(closeButton)

	local okayButton = CreateFrame("Button", "$parentOkayButton", addonList, "UIPanelButtonTemplate")
	E:Size(okayButton, 80, 22)
	E:Point(okayButton, "TOPRIGHT", cancelButton, "TOPLEFT", -SPACING, 0)
	okayButton:SetText(OKAY)
	S:HandleButton(okayButton)

	local enableAllButton = CreateFrame("Button", "$parentEnableAllButton", addonList, "UIPanelButtonTemplate")
	E:Size(enableAllButton, 120, 22)
	E:Point(enableAllButton, "BOTTOMLEFT", SPACING, SPACING)
	enableAllButton:SetText(L["Enable All"])
	S:HandleButton(enableAllButton)

	local disableAllButton = CreateFrame("Button", "$parentDisableAllButton", addonList, "UIPanelButtonTemplate")
	E:Size(disableAllButton, 120, 22)
	E:Point(disableAllButton, "TOPLEFT", enableAllButton, "TOPRIGHT", SPACING, 0)
	disableAllButton:SetText(L["Disable All"])
	S:HandleButton(disableAllButton)

	addonList:SetScript("OnShow", function()
		self:Update()
		PlaySound("igMainMenuOption")
	end)

	addonList:SetScript("OnHide", function()
		PlaySound("igMainMenuOptionCheckBoxOn")
	end)

	addonList:SetClampedToScreen(true)
	addonList:SetMovable(true)
	addonList:EnableMouse(true)
	addonList:RegisterForDrag("LeftButton")

	addonList:SetScript("OnDragStart", function()
		if IsShiftKeyDown() then
			this:StartMoving()
		end
	end)

	addonList:SetScript("OnDragStop", function()
		this:StopMovingOrSizing()
	end)

	addonList:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT", 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L["Hold Shift + Drag:"], L["Temporary Move"], 1, 1, 1)

		GameTooltip:Show()
	end)
	addonList:SetScript("OnLeave", function() GameTooltip:Hide() end)

	cancelButton:SetScript("OnClick", function()
		ElvUI_AddonList:Hide()
	end)

	closeButton:SetScript("OnClick", function()
		ElvUI_AddonList:Hide()
	end)

	okayButton:SetScript("OnClick", function()
		ElvUI_AddonList:Hide()
		if ElvUI_AddonList.shouldReload then
			ReloadUI()
		end
	end)

	enableAllButton:SetScript("OnClick", function()
		EnableAllAddOns()
		AL:Update()
	end)

	disableAllButton:SetScript("OnClick", function()
		DisableAllAddOns()
		AL:Update()
	end)

	local scrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", addonList, "FauxScrollFrameTemplate")
	E:SetTemplate(scrollFrame, "Transparent")
	E:Point(scrollFrame, "TOPLEFT", addonList, "TOPLEFT", 10, -30)
	E:Point(scrollFrame, "BOTTOMRIGHT", addonList, "BOTTOMRIGHT", -34, 41)
	S:HandleScrollBar(ElvUI_AddonListScrollFrameScrollBar, 5)

	scrollFrame:SetScript("OnVerticalScroll", function()
		local scrollbar = _G[this:GetName().."ScrollBar"]
		scrollbar:SetValue(arg1)
		addonList.offset = floor((arg1 / 16) + 0.5)
		AL:Update()
		if GameTooltip:IsShown() then
			AL:TooltipUpdate(GameTooltip:GetParent())
			GameTooltip:Show()
		end
	end)

	local addonListEntry = {}
	for i = 1, 20 do
		addonListEntry[i] = CreateFrame("Button", "ElvUI_AddonListEntry"..i, addonList)
		E:Size(addonListEntry[i], scrollFrame:GetWidth() - 8, 16)
		addonListEntry[i]:SetID(i)

		if i == 1 then
			E:Point(addonListEntry[i], "TOPLEFT", 4, -30)
		else
			E:Point(addonListEntry[i], "TOP", addonListEntry[i - 1], "BOTTOM", 0, -4)
		end

		local enabled = CreateFrame("CheckButton", "$parentEnabled", addonListEntry[i], "UICheckButtonTemplate")
		E:Size(enabled, 24)
		E:Point(enabled, "LEFT", 5, 0)
		S:HandleCheckBox(enabled)

		local title = addonListEntry[i]:CreateFontString("$parentTitle", "BACKGROUND", "GameFontNormal")
		E:Size(title, 220, 12)
		E:Point(title, "LEFT", 32, 0)
		title:SetJustifyH("LEFT")

		local status = addonListEntry[i]:CreateFontString("$parentStatus", "BACKGROUND", "GameFontNormalSmall")
		E:Size(status, 220, 12)
		E:Point(status, "RIGHT", "$parent", -22, 0)
		status:SetJustifyH("RIGHT")
		addonListEntry[i].Status = status

		local reload = addonListEntry[i]:CreateFontString("$parentReload", "BACKGROUND", "GameFontRed")
		E:Size(reload, 220, 12)
		E:Point(reload, "RIGHT", "$parent", -22, 0)
		reload:SetJustifyH("RIGHT")
		reload:SetText(L["Requires Reload"])
		addonListEntry[i].Reload = reload

		local load = CreateFrame("Button", "$parentLoad", addonListEntry[i], "UIPanelButtonTemplate")
		E:Size(load, 100, 22)
		E:Point(load, "RIGHT", "$parent", -21, 0)
		load:SetText(L["Load AddOn"])
		S:HandleButton(load)
		addonListEntry[i].LoadButton = load

		addonListEntry[i]:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -270, 0)
			AL:TooltipUpdate(this)
		end)

		addonListEntry[i]:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)

		enabled:SetScript("OnClick", function()
			AL:Enable(this:GetParent():GetID(), this:GetChecked())
			PlaySound("igMainMenuOptionCheckBoxOn")
		end)

		enabled:SetScript("OnEnter", function()
			if this.tooltip then
				GameTooltip:SetOwner(this, "ANCHOR_RIGHT", -270, 0)
				AL:TooltipUpdate(this)
				GameTooltip:Show()
			end
		end)

		enabled:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)

		load:SetScript("OnClick", function()
			AL:LoadAddOn(this:GetParent():GetID())
		end)
	end

	local buttonAddons = CreateFrame("Button", "ElvUI_ButtonAddons", GameMenuFrame, "GameMenuButtonTemplate")
	E:Point(buttonAddons, "TOP", GameMenuButtonMacros, "BOTTOM", 0, -1)
	buttonAddons:SetText(L["Addons"])
	S:HandleButton(buttonAddons)

	buttonAddons:SetScript("OnClick", function()
		HideUIPanel(GameMenuFrame)
		ShowUIPanel(ElvUI_AddonList)
	end)

	self:RawHookScript(GameMenuButtonLogout, "OnShow", function()
		E:Point(this, "TOP", ElvUI_ButtonAddons, "BOTTOM", 0, -16)

		if not StaticPopup_Visible("CAMP") and not StaticPopup_Visible("QUIT") then
			this:Enable()
		else
			this:Disable()
		end
	end)

	if GetLocale() == "koKR" then
		if IsMacClient() then
			E:Height(GameMenuFrame, 308)
		else
			E:Height(GameMenuFrame, 282)
		end
	else
		if IsMacClient() then
			E:Height(GameMenuFrame, 292)
		else
			E:Height(GameMenuFrame, 266)
		end
	end
end

local function InitializeCallback()
	AL:Initialize()
end

E:RegisterModule(AL:GetName(), InitializeCallback)