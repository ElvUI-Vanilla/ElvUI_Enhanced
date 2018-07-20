local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local module = E:NewModule("HookModelFrames", "AceHook-3.0", "AceEvent-3.0");
local S = E:GetModule("Skins");

--Cache global variables
--Lua functions
local _G = _G
local min, max = math.min, math.max
--WoW API / Variables
local CreateFrame = CreateFrame
local GetCVar = GetCVar
local GetCursorPosition = GetCursorPosition
local PI = PI
local UIFrameFadeIn = UIFrameFadeIn
local UIFrameFadeOut = UIFrameFadeOut
local UnitRace = UnitRace
local UnitSex = UnitSex

local models = {
	"CharacterModelFrame",
	"DressUpModel",
	"PetModelFrame",
	"PetStableModel"
}

function module:ModelControlButton(model)
	E:Size(model, 18)

	model.icon = model:CreateTexture("$parentIcon", "ARTWORK")
	E:SetInside(model.icon)
	model.icon:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\Media\\Textures\\UI-ModelControlPanel")
	model.icon:SetTexCoord(0.01562500, 0.26562500, 0.00781250, 0.13281250)

	model:SetScript("OnMouseDown", function() module:ModelControlButton_OnMouseDown(this) end)
	model:SetScript("OnMouseUp", function() module:ModelControlButton_OnMouseUp(this) end)
	model:SetScript("OnEnter", function()
		UIFrameFadeIn(this:GetParent(), 0.2, this:GetParent():GetAlpha(), 1)
		if GetCVar("UberTooltips") == "1" then
			GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
			GameTooltip:SetText(this.tooltip, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			if this.tooltipText then
				GameTooltip:AddLine(this.tooltipText, _, _, _, 1, 1)
			end
			GameTooltip:Show()
		end
	end)
	model:SetScript("OnLeave", function()
		UIFrameFadeOut(this:GetParent(), 0.2, this:GetParent():GetAlpha(), 0.5)
		GameTooltip:Hide()
	end)
end

function module:ModelWithControls(model)
	model.controlFrame = CreateFrame("Frame", "$parentControlFrame", model)
	E:Point(model.controlFrame, "TOP", 0, -2)
	model.controlFrame:SetAlpha(0.5)
	model.controlFrame:Hide()

	local zoomInButton = CreateFrame("Button", "$parentZoomInButton", model.controlFrame)
	self:ModelControlButton(zoomInButton)
	E:Point(zoomInButton, "LEFT", 2, 0)
	zoomInButton:RegisterForClicks("AnyUp")
	zoomInButton.icon:SetTexCoord(0.57812500, 0.82812500, 0.14843750, 0.27343750)
	zoomInButton.tooltip = L["Zoom In"]
	zoomInButton.tooltipText = L["Mouse Wheel Up"]
	zoomInButton:SetScript("OnMouseDown", function()
		module:Model_OnMouseWheel(this:GetParent():GetParent(), 1)
	end)

	local zoomOutButton = CreateFrame("Button", "$parentZoomOutButton", model.controlFrame)
	self:ModelControlButton(zoomOutButton)
	E:Point(zoomOutButton, "LEFT", 2, 0)
	zoomOutButton:RegisterForClicks("AnyUp")
	zoomOutButton.icon:SetTexCoord(0.29687500, 0.54687500, 0.00781250, 0.13281250)
	zoomOutButton.tooltip = L["Zoom Out"]
	zoomOutButton.tooltipText = L["Mouse Wheel Down"]
	zoomOutButton:SetScript("OnMouseDown", function()
		module:Model_OnMouseWheel(this:GetParent():GetParent(), -1)
	end)

	local panButton = CreateFrame("Button", "$parentPanButton", model.controlFrame)
	self:ModelControlButton(panButton)
	E:Point(panButton, "LEFT", 2, 0)
	panButton:RegisterForClicks("AnyUp")
	panButton.icon:SetTexCoord(0.29687500, 0.54687500, 0.28906250, 0.41406250)
	panButton.tooltip = L["Drag"]
	panButton.tooltipText = L["Right-click on character and drag to move it within the window."]
	panButton:SetScript("OnMouseDown", function()
		module:ModelControlButton_OnMouseDown(this)
		module:Model_StartPanning(this:GetParent():GetParent(), true)
	end)

	local rotateLeftButton = CreateFrame("Button", "$parentRotateLeftButton", model.controlFrame)
	self:ModelControlButton(rotateLeftButton)
	rotateLeftButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	rotateLeftButton.icon:SetTexCoord(0.01562500, 0.26562500, 0.28906250, 0.41406250)
	rotateLeftButton.tooltip = L["Rotate Left"]
	rotateLeftButton.tooltipText = L["Left-click on character and drag to rotate."]
	rotateLeftButton:SetScript("OnClick", function()
		Model_RotateLeft(this:GetParent():GetParent())
	end)
	model.controlFrame.rotateLeftButton = rotateLeftButton

	local rotateRightButton = CreateFrame("Button", "$parentRotateRightButton", model.controlFrame)
	self:ModelControlButton(rotateRightButton)
	rotateRightButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	rotateRightButton.icon:SetTexCoord(0.57812500, 0.82812500, 0.28906250, 0.41406250)
	rotateRightButton.tooltip = L["Rotate Right"]
	rotateRightButton.tooltipText = L["Left-click on character and drag to rotate."]
	rotateRightButton:SetScript("OnClick", function()
		Model_RotateRight(this:GetParent():GetParent())
	end)
	model.controlFrame.rotateRightButton = rotateRightButton

	local rotateResetButton = CreateFrame("Button", "$parentrotateResetButton", model.controlFrame)
	self:ModelControlButton(rotateResetButton)
	rotateResetButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	rotateResetButton.tooltip = L["Reset Position"]
	rotateResetButton:SetScript("OnClick", function()
		module:Model_Reset(this:GetParent():GetParent())
	end)

	if E.private.skins.blizzard.enable then
		E:Size(model.controlFrame, 122, 18)

		S:HandleButton(zoomInButton)

		S:HandleButton(zoomOutButton)
		E:Point(zoomOutButton, "LEFT", "$parentZoomInButton", "RIGHT", 2, 0)

		S:HandleButton(panButton)
		E:Point(panButton, "LEFT", "$parentZoomOutButton", "RIGHT", 2, 0)

		S:HandleButton(rotateLeftButton)
		E:Point(rotateLeftButton, "LEFT", "$parentPanButton", "RIGHT", 2, 0)

		S:HandleButton(rotateRightButton)
		E:Point(rotateRightButton, "LEFT", "$parentRotateLeftButton", "RIGHT", 2, 0)

		S:HandleButton(rotateResetButton)
		E:Point(rotateResetButton, "LEFT", "$parentRotateRightButton", "RIGHT", 2, 0)
	else
		E:Size(model.controlFrame, 114, 23)
		E:Point(zoomOutButton, "LEFT", "$parentZoomInButton", "RIGHT", 0, 0)
		E:Point(panButton, "LEFT", "$parentZoomOutButton", "RIGHT", 0, 0)
		E:Point(rotateLeftButton, "LEFT", "$parentPanButton", "RIGHT", 0, 0)
		E:Point(rotateRightButton, "LEFT", "$parentRotateLeftButton", "RIGHT", 0, 0)
		E:Point(rotateResetButton, "LEFT", "$parentRotateRightButton", "RIGHT", 0, 0)
	end

	model.controlFrame:SetScript("OnHide", function()
		if this.buttonDown then
			module:ModelControlButton_OnMouseUp(this.buttonDown)
		end
	end)

	self:HookScript(model, "OnUpdate", "Model_OnUpdate")
	model:SetScript("OnMouseWheel", function()
		module:Model_OnMouseWheel(this, arg1)
	end)
	model:SetScript("OnMouseUp", function()
		if arg1 == "RightButton" and this.panning then
			module:Model_StopPanning(this)
		elseif this.mouseDown then
			module:Model_OnMouseUp(this, arg1)
		end
	end)
	model:SetScript("OnMouseDown", function()
		if arg1 == "RightButton" and not this.mouseDown then
			module:Model_StartPanning(this)
		else
			module:Model_OnMouseDown(this, arg1)
		end
	end)
	model:SetScript("OnEnter", function()
		this.controlFrame:Show()
	end)
	model:SetScript("OnLeave", function()
		if not MouseIsOver(this.controlFrame) and not ModelPanningFrame:IsShown() then
			this.controlFrame:Hide()
		end
	end)
	model:SetScript("OnHide", function()
		if this.panning then
			module:Model_StopPanning(this)
		end
		this.mouseDown = false
		this.controlFrame:Hide()
		module:Model_Reset(this)
	end)
end

local ModelSettings = {
	["HumanMale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 1.2, panMaxBottom = -0.3, panValue = 38 },
	["HumanFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 1.2, panMaxBottom = -0.2, panValue = 45 },
	["OrcMale"] = { panMaxLeft = -0.7, panMaxRight = 0.8, panMaxTop = 1.2, panMaxBottom = -0.3, panValue = 30 },
	["OrcFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.3, panMaxTop = 1.2, panMaxBottom = -0.3, panValue = 37 },
	["DwarfMale"] = { panMaxLeft = -0.4, panMaxRight = 0.6, panMaxTop = 0.9, panMaxBottom = -0.2, panValue = 44 },
	["DwarfFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.9, panMaxBottom = -0.2, panValue = 47 },
	["NightElfMale"] = { panMaxLeft = -0.5, panMaxRight = 0.5, panMaxTop = 1.5, panMaxBottom = -0.4, panValue = 30 },
	["NightElfFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 1.4, panMaxBottom = -0.4, panValue = 33 },
	["ScourgeMale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 1.1, panMaxBottom = -0.3, panValue = 35 },
	["ScourgeFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.4, panMaxTop = 1.1, panMaxBottom = -0.3, panValue = 36 },
	["TaurenMale"] = { panMaxLeft = -0.7, panMaxRight = 0.9, panMaxTop = 1.1, panMaxBottom = -0.5, panValue = 31 },
	["TaurenFemale"] = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.3, panMaxBottom = -0.4, panValue = 32 },
	["GnomeMale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.5, panMaxBottom = -0.2, panValue = 52 },
	["GnomeFemale"] = { panMaxLeft = -0.3, panMaxRight = 0.3, panMaxTop = 0.5, panMaxBottom = -0.2, panValue = 60 },
	["TrollMale"] = { panMaxLeft = -0.5, panMaxRight = 0.6, panMaxTop = 1.3, panMaxBottom = -0.4, panValue = 27 },
	["TrollFemale"] = { panMaxLeft = -0.4, panMaxRight = 0.4, panMaxTop = 1.5, panMaxBottom = -0.4, panValue = 31 }
}

local playerRaceSex
do
	local _
	_, playerRaceSex = UnitRace("player")
	if UnitSex("player") == 2 then
		playerRaceSex = playerRaceSex.."Male"
	else
		playerRaceSex = playerRaceSex.."Female"
	end
end

function module:Model_OnMouseWheel(model, delta)
	local maxZoom = 2.8
	local minZoom = 0
	local zoomLevel = model.zoomLevel or minZoom
	zoomLevel = zoomLevel + delta * 0.5
	zoomLevel = min(zoomLevel, maxZoom)
	zoomLevel = max(zoomLevel, minZoom)
	local _, y, z = model:GetPosition()
	model:SetPosition(zoomLevel, y, z)
	model.zoomLevel = zoomLevel
end

function module:Model_OnMouseDown(model, button)
	if not button or button == "LeftButton" then
		model.mouseDown = true
		model.rotationCursorStart = GetCursorPosition()
	end
end

function module:Model_OnMouseUp(model, button)
	if not button or button == "LeftButton" then
		model.mouseDown = false
	end
end

function module:Model_OnUpdate(rotationsPerSecond)
	if not rotationsPerSecond then
		rotationsPerSecond = ROTATIONS_PER_SECOND
	end

	if this.mouseDown then
		if this.rotationCursorStart then
			local x = GetCursorPosition()
			local diff = (x - this.rotationCursorStart) * 0.010

			this.rotationCursorStart = GetCursorPosition()
			this.rotation = this.rotation + diff

			if this.rotation < 0 then
				this.rotation = this.rotation + (2 * PI)
			end

			if this.rotation > (2 * PI) then
				this.rotation = this.rotation - (2 * PI)
			end

			this:SetRotation(this.rotation, false)
		end
	elseif this.panning then
		local modelScale = this:GetModelScale()
		local cursorX, cursorY = GetCursorPosition()
		local scale = UIParent:GetEffectiveScale()
		E:Point(ModelPanningFrame, "BOTTOMLEFT", cursorX / scale - 16, cursorY / scale - 16)	-- half the texture size to center it on the cursor
		-- settings
		local settings = ModelSettings[playerRaceSex]

		local zoom = this.zoomLevel or 0
		zoom = 1 + zoom - 0 -- want 1 at minimum zoom

		-- Panning should require roughly the same mouse movement regardless of zoom level so the model moves at the same rate as the cursor
		-- This formula more or less works for all zoom levels, found via trial and error
		local transformationRatio = settings.panValue * 2 ^ (zoom * 1.25) * scale / modelScale

		local dx = (cursorX - this.cursorX) / transformationRatio
		local dy = (cursorY - this.cursorY) / transformationRatio
		local cameraY = this.cameraY + dx
		local cameraZ = this.cameraZ + dy
		-- bounds
		scale = scale * modelScale
		local maxCameraY = (settings.panMaxRight * zoom) * scale
		cameraY = min(cameraY, maxCameraY)
		local minCameraY = (settings.panMaxLeft * zoom) * scale
		cameraY = max(cameraY, minCameraY)
		local maxCameraZ = (settings.panMaxTop * zoom) * scale
		cameraZ = min(cameraZ, maxCameraZ)
		local minCameraZ = (settings.panMaxBottom * zoom) * scale
		cameraZ = max(cameraZ, minCameraZ)

		this:SetPosition(this.cameraX, cameraY, cameraZ)
	end

	local leftButton, rightButton
	if this.controlFrame then
		leftButton = this.controlFrame.rotateLeftButton
		rightButton = this.controlFrame.rotateRightButton
	else
		leftButton = this:GetName() and _G[this:GetName().."RotateLeftButton"]
		rightButton = this:GetName() and _G[this:GetName().."RotateRightButton"]
	end

	if leftButton and leftButton:GetButtonState() == "PUSHED" then
		this.rotation = this.rotation + (arg1 * 2 * PI * rotationsPerSecond)
		if this.rotation < 0 then
			this.rotation = this.rotation + (2 * PI)
		end
		this:SetRotation(this.rotation)
	elseif rightButton and rightButton:GetButtonState() == "PUSHED" then
		this.rotation = this.rotation - (arg1 * 2 * PI * rotationsPerSecond)
		if this.rotation > (2 * PI) then
			this.rotation = this.rotation - (2 * PI)
		end
		this:SetRotation(this.rotation)
	end
end

function module:Model_Reset(model)
	model.rotation = 0.61
	model:SetRotation(model.rotation)
	model.zoomLevel = 0
	model:SetPosition(0, 0, 0)
end

function module:Model_StartPanning(model, usePanningFrame)
	if usePanningFrame then
		ModelPanningFrame.model = model
		ModelPanningFrame:Show()
	end
	model.panning = true
	local cameraX, cameraY, cameraZ = model:GetPosition()
	model.cameraX = cameraX
	model.cameraY = cameraY
	model.cameraZ = cameraZ
	local cursorX, cursorY = GetCursorPosition()
	model.cursorX = cursorX
	model.cursorY = cursorY
end

function module:Model_StopPanning(model)
	model.panning = false
	ModelPanningFrame:Hide()
end

function module:ModelControlButton_OnMouseDown(model)
	E:Point(model.icon, "CENTER", 1, -1)
	model:GetParent().buttonDown = model
end

function module:ModelControlButton_OnMouseUp(model)
	E:Point(model.icon, "CENTER", 0, 0)
	model:GetParent().buttonDown = nil
end

function module:ADDON_LOADED()
	if arg1 == "Blizzard_InspectUI" then
		InspectModelFrame:EnableMouse(true)
		InspectModelFrame:EnableMouseWheel(true)

		E:Kill(InspectModelRotateLeftButton)
		E:Kill(InspectModelRotateRightButton)

		self:ModelWithControls(InspectModelFrame)
	elseif arg1 == "Blizzard_AuctionUI" then

		AuctionDressUpModel:EnableMouse(true)
		AuctionDressUpModel:EnableMouseWheel(true)

		E:Kill(AuctionDressUpModelRotateLeftButton)
		E:Kill(AuctionDressUpModelRotateRightButton)

		self:ModelWithControls(AuctionDressUpModel)

		E:Point(AuctionDressUpModelControlFrame, "TOP", 0, -10)
	end
end

function module:Initialize()
	if not E.private.enhanced.model.enable then return end

	for i = 1, getn(models) do
		local model = _G[models[i]]

		model:EnableMouse(true)
		model:EnableMouseWheel(true)

		E:Kill(_G[models[i].."RotateLeftButton"])
		E:Kill(_G[models[i].."RotateRightButton"])

		self:ModelWithControls(model)
	end

	if E.myclass == "HUNTER" then
		E:Point(PetPaperDollPetInfo, "TOPLEFT", PetPaperDollFrame, 23, -76)
	end

	local modelPanning = CreateFrame("Frame", "ModelPanningFrame", UIParent)
	modelPanning:SetFrameStrata("DIALOG")
	modelPanning:Hide()
	E:Size(modelPanning, 32)

	modelPanning.texture = modelPanning:CreateTexture(nil, "ARTWORK")
	modelPanning.texture:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\Media\\Textures\\UI-Cursor-Move")
	modelPanning.texture:SetAllPoints()

	modelPanning:SetScript("OnUpdate", function()
		local model = this.model
		local controlFrame = model.controlFrame
		if model.mouseDown then
			module:Model_StopPanning(model)
			if controlFrame.buttonDown then
				module:ModelControlButton_OnMouseUp(controlFrame.buttonDown)
			end
			if not MouseIsOver(controlFrame) then
				controlFrame:Hide()
			end
		end
	end)

	self:RegisterEvent("ADDON_LOADED")
end

local function InitializeCallback()
	module:Initialize()
end

E:RegisterModule(module:GetName(), InitializeCallback)