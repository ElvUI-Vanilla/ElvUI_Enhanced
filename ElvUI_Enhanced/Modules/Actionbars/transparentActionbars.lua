local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule("ActionBars")
local ETAB = E:NewModule("Enhanced_TransparentActionbars");

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS

function ETAB:StyleBackdrops()
	local styleBackdrop = E.db.enhanced.actionbars.transparentActionbars.transparentBackdrops and "Transparent" or "Default"
	local styleButtons = E.db.enhanced.actionbars.transparentActionbars.transparentButtons and "Transparent" or "Default"

	local frame

	for i = 1, 10 do
		frame = _G["ElvUI_Bar"..i]
		if frame then
			if frame.backdrop then
				E:SetTemplate(frame.backdrop, styleBackdrop)
			end

			for _, bar in pairs(AB.handledBars) do
				for _, button in pairs(bar.buttons) do
					if button and button.backdrop then
						E:SetTemplate(button.backdrop, styleButtons, true)
					end
				end
			end
		end
	end

	for _, frame in pairs({ElvUI_BarPet, ElvUI_StanceBar}) do
		if frame.backdrop then
			E:SetTemplate(frame.backdrop, styleBackdrop)
		end
	end

	for i = 1, NUM_PET_ACTION_SLOTS do
		frame = _G["PetActionButton"..i]
		if frame and frame.backdrop then
			E:SetTemplate(frame.backdrop, styleButtons, true)
		end
	end
end

function ETAB:Initialize()
	if not E.private.actionbar.enable or not (E.db.enhanced.actionbars.transparentActionbars.transparentBackdrops or E.db.enhanced.actionbars.transparentActionbars.transparentButtons) then return end

	E:Delay(0.3, ETAB.StyleBackdrops)
end

local function InitializeCallback()
	ETAB:Initialize()
end

E:RegisterModule(ETAB:GetName(), InitializeCallback)