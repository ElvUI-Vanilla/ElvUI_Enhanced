local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AB = E:GetModule("ActionBars")
local EAB = E:NewModule("Enhanced_ActionBars");

--Cache global variables
--Lua functions
local pairs, unpack = pairs, unpack
--WoW API / Variables
local IsEquippedAction = IsEquippedAction
local hooksecurefunc = hooksecurefunc

function EAB:ActionButton_Update()
	if this.backdrop then
		local color = E.db.enhanced.actionbars.equippedColor
		local action = ActionButton_GetPagedID(this)
		local button = this

		E:Delay(0.05, function()
			if IsEquippedAction(action) then
				button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
			else
				button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end)
	end
end

function EAB:UpdateCallback()
	if E.db.enhanced.actionbars.equipped then
		hooksecurefunc("ActionButton_Update", self.ActionButton_Update)
	else
		for _, bar in pairs(AB.handledBars) do
			for _, button in pairs(bar.buttons) do
				if IsEquippedAction(button:GetID()) then
					button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
		end
	end
end

function EAB:Initialize()
	self:UpdateCallback()
end

local function InitializeCallback()
	EAB:Initialize()
end

E:RegisterModule(EAB:GetName(), InitializeCallback)