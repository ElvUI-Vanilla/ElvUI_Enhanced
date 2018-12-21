local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule("Enhanced_Misc");
local S = E:GetModule("Skins");

--Cache global variables
--Lua functions
local pairs, select = pairs, select
local getn, tinsert = table.getn, table.insert

local buttons = {
	"UI-Panel-MinimizeButton-Disabled",
	"UI-Panel-MinimizeButton-Up",
	"UI-Panel-SmallerButton-Up",
	"UI-Panel-BiggerButton-Up"
}

local buttonList = {}

local function UpdateSkinType(f)
	if E.db.enhanced.general.originalCloseButton then
		if f.originalType then return end

		f.SetNormalTexture = nil
		f:SetNormalTexture(f.origNormalTexture)

		f.SetPushedTexture = nil
		f:SetPushedTexture(f.origPushedTexture)

		f.SetHighlightTexture = nil
		f:SetHighlightTexture(f.origHighlightTexture)

		if not f.desaturated then
			for i = 1, f:GetNumRegions() do
				local region = select(i, f:GetRegions())
				if region:IsObjectType("Texture") then
					region:SetDesaturated(1)
				end
			end
		end

		if f.backdrop then
			f.backdrop:Hide()
		end
		if f.text then
			f.text:Hide()
		end

		f:SetHitRectInsets(0, 0, 0, 0)

		f.originalType = true
	else
		if not f.originalType then return end

		E:StripTextures(f)

		if f:GetNormalTexture() then
			f:SetNormalTexture("")
			f.SetNormalTexture = E.noop
		end

		if f:GetPushedTexture() then
			f:SetPushedTexture("")
			f.SetPushedTexture = E.noop
		end

		if not f.backdrop then
			E:CreateBackdrop(f, "Default", true)
			E:Point(f.backdrop, "TOPLEFT", 7, -8)
			E:Point(f.backdrop, "BOTTOMRIGHT", -8, 8)
			HookScript(f, "OnEnter", S.SetModifiedBackdrop)
			HookScript(f, "OnLeave", S.SetOriginalBackdrop)
		else
			f.backdrop:Show()
			f:SetHitRectInsets(6, 6, 7, 7)
		end

		if not f.text then
			f.text = f:CreateFontString(nil, "OVERLAY")
			f.text:SetFont([[Interface\AddOns\ElvUI\media\fonts\PT_Sans_Narrow.ttf]], 16, "OUTLINE")
			f.text:SetText(f.textTemp or "x")
			f.text:SetJustifyH("CENTER")
			f.text:SetPoint("CENTER", f, "CENTER", -1, 1)
		else
			f.text:Show()
		end

		f.originalType = nil
	end
end

function M:UpdateCloseButtons()
	for _, button in pairs(buttonList) do
		UpdateSkinType(button)
	end
end

function S:HandleCloseButton(f, point, text)
	if f:GetNormalTexture() then
		f.origNormalTexture = f:GetNormalTexture():GetTexture()
	end
	if f:GetPushedTexture() then
		f.origPushedTexture = f:GetPushedTexture():GetTexture()
	end
	if f:GetHighlightTexture() then
		f.origHighlightTexture = f:GetHighlightTexture():GetTexture()
	end

	if E.db.enhanced.general.originalCloseButton then
		for i = 1, f:GetNumRegions() do
			local region = select(i, f:GetRegions())
			if region:GetObjectType() == "Texture" then
				region:SetDesaturated(1)

				for n = 1, getn(buttons) do
					local texture = buttons[n]
					if region:GetTexture() == "Interface\\Buttons\\"..texture then
						f.originalType = true
					end
				end

				if region:GetTexture() == "Interface\\DialogFrame\\UI-DialogBox-Corner" then
					region:Kill()
				end
			end
		end

		if text then
			f.textTemp = text
		end
	else
		E:StripTextures(f)

		if f:GetNormalTexture() then
			f:SetNormalTexture("")
			f.SetNormalTexture = E.noop
		end

		if f:GetPushedTexture() then
			f:SetPushedTexture("")
			f.SetPushedTexture = E.noop
		end

		if not f.backdrop then
			E:CreateBackdrop(f, "Default", true)
			E:Point(f.backdrop, "TOPLEFT", 7, -8)
			E:Point(f.backdrop, "BOTTOMRIGHT", -8, 8)
			HookScript(f, "OnEnter", S.SetModifiedBackdrop)
			HookScript(f, "OnLeave", S.SetOriginalBackdrop)
			f:SetHitRectInsets(6, 6, 7, 7)
		end

		if not f.text then
			f.text = f:CreateFontString(nil, "OVERLAY")
			f.text:SetFont([[Interface\AddOns\ElvUI\media\fonts\PT_Sans_Narrow.ttf]], 16, "OUTLINE")
			f.text:SetText(text or "x")
			f.text:SetJustifyH("CENTER")
			f.text:SetPoint("CENTER", f, "CENTER", -1, 1)
		end
	end

	if point then
		E:Point(f, "TOPRIGHT", point, "TOPRIGHT", 2, 2)
	end

	tinsert(buttonList, f)
end