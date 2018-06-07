local E, L, V, P, G = unpack(ElvUI)
local LOS = E:NewModule("LoseOfControl", "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local CC      = "CC"
local Silence = "Silence"
local Disarm  = "Disarm"
local Root    = "Root"
local Snare   = "Snare"
local Immune  = "Immune"
local PvE     = "PvE"

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id)
	if not name then
		print("|cff1784d1ElvUI:|r SpellID is not valid: "..id..". Please check for an updated version, if none exists report to ElvUI author.")
		return "Impale"
	else
		return name
	end
end

G.loseofcontrol = {
-- Druid
	["Hibernate"] = CC, -- Hibernate
	["Starfire Stun"] = CC, -- Starfire
	["Entangling Roots"] = Root, -- Entangling Roots
	["Bash"] = CC, -- Bash
	["Pounce Bleed"] = CC, -- Pounce
	["Feral Charge Effect"] = Root, -- Feral Charge
-- Hunter
	["Intimidation"] = CC, -- Intimidation
	["Scare Beast"] = CC, -- Scare Beast
	["Scatter Shot"] = CC, -- Scatter Shot
	["Improved Concussive Shot"] = CC, -- Improved Concussive Shot
	["Concussive Shot"] = Snare, -- Concussive Shot
	["Freezing Trap Effect"] = CC, -- Freezing Trap
	["Freezing Trap"] = CC, -- Freezing Trap
	["Frost Trap Aura"] = Root, -- Freezing Trap
	["Frost Trap"] = Root, -- Frost Trap
	["Entrapment"] = Root, -- Entrapment
	["Wyvern Sting"] = CC, -- Wyvern Sting; requires a hack to be removed later
	["Counterattack"] = Root, -- Counterattack
	["Improved Wing Clip"] = Root, -- Improved Wing Clip
	["Wing Clip"] = Snare, -- Wing Clip
	["Boar Charge"] = Root, -- Boar Charge
	-- Mage
	["Polymorph"] = CC, -- Polymorph: Sheep
	["Polymorph: Turtle"] = CC, -- Polymorph: Turtle
	["Polymorph: Pig"] = CC, -- Polymorph: Pig
	["Polymorph: Cow"] = CC, -- Polymorph: Cow
	["Polymorph: Chicken"] = CC, -- Polymorph: Chicken
	["Counterspell - Silenced"] = Silence, -- Counterspell
	["Impact"] = CC, -- Impact
	["Blast Wave"] = Snare, -- Blast Wave
	["Frostbite"] = Root, -- Frostbite
	["Frost Nova"] = Root, -- Frost Nova
	["Frostbolt"] = Snare, -- Frostbolt
	["Cone of Cold"] = Snare, -- Cone of Cold
	["Chilled"] = Snare, -- Improved Blizzard + Ice armor
-- Paladin
	["Hammer of Justice"] = CC, -- Hammer of Justice
	["Repentance"] = CC, -- Repentance
-- Priest
	["Mind Control"] = CC, -- Mind Control
	["Psychic Scream"] = CC, -- Psychic Scream
	["Blackout"] = CC, -- Blackout
	["Silence"] = Silence, -- Silence
	["Mind Flay"] = Snare, -- Mind Flay
-- Rogue
	["Blind"] = CC, -- Blind
	["Cheap Shot"] = CC, -- Cheap Shot
	["Gouge"] = CC, -- Gouge
	["Kidney Shot"] = CC, -- Kidney shot; the buff is 30621
	["Sap"] = CC, -- Sap
	["Kick - Silenced"] = Silence, -- Kick
	["Crippling Poison"] = Snare, -- Crippling Poison
-- Warlock
	["Death Coil"] = CC, -- Death Coil
	["Fear"] = CC, -- Fear
	["Howl of Terror"] = CC, -- Howl of Terror
	["Curse of Exhaustion"] = Snare, -- Curse of Exhaustion
	["Pyroclasm"] = CC, -- Pyroclasm
	["Aftermath"] = Snare, -- Aftermath
	["Seduction"] = CC, -- Seduction
	["Spell Lock"] = Silence, -- Spell Lock
	["Inferno Effect"] = CC, -- Inferno Effect
	["Inferno"] = CC, -- Inferno
	["Cripple"] = Snare, -- Cripple
-- Warrior
	["Charge Stun"] = CC, -- Charge Stun
	["Intercept Stun"] = CC, -- Intercept Stun
	["Intimidating Shout"] = CC, -- Intimidating Shout
	["Revenge Stun"] = CC, -- Revenge Stun
	["Concussion Blow"] = CC, -- Concussion Blow
	["Piercing Howl"] = Snare, -- Piercing Howl
	["Shield Bash - Silenced"] = Silence, -- Shield Bash - Silenced
--Shaman
	["Frostbrand Weapon"] = Snare, -- Frostbrand Weapon
	["Frost Shock"] = Snare, -- Frost Shock
	["Earthbind"] = Snare, -- Earthbind
	["Earthbind Totem"] = Snare, -- Earthbind Totem
-- other
	["War Stomp"] = CC, -- War Stomp
	["Tidal Charm"] = CC, -- Tidal Charm
	["Mace Stun Effect"] = CC, -- Mace Stun Effect
	["Stun"] = CC, -- Stun
	["Gnomish Mind Control Cap"] = CC, -- Gnomish Mind Control Cap
	["Reckless Charge"] = CC, -- Reckless Charge
	["Sleep"] = CC, -- Sleep
	["Dazed"] = Snare, -- Dazed
	["Freeze"] = Root, -- Freeze
	["Chill"] = Snare, -- Chill
	["Charge"] = CC, -- Charge
}

local abilities = {}

function LOS:OnUpdate(elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.01 then
			local _, _, _, _, _, duration, timeLeft = UnitAura("player", self.index, "HARMFUL")
			if timeLeft and timeLeft > self.timeLeft then
				LOS.Cooldown:SetCooldown(GetTime() + (timeLeft - duration), duration)
			end
			self.timeLeft = timeLeft
			if timeLeft >= 10 then
				self.NumberText:SetFormattedText("%d", timeLeft)
			elseif timeLeft < 9.95 then
				self.NumberText:SetFormattedText("%.1f", timeLeft)
			end
			self.elapsed = 0
		end
	end
end

function LOS:UNIT_AURA(_, unit)
	if unit ~= "player" then return end

	local maxExpirationTime = 0
	local Icon, Duration, Index

	for i = 1, 40 do
		local name, _, icon, _, _, duration, expirationTime = UnitAura("player", i, "HARMFUL")
		if not name then break end

		if E.db.enhanced.loseofcontrol[abilities[name]] and expirationTime > maxExpirationTime then
			maxExpirationTime = expirationTime
			Icon = icon
			Duration = duration
			Index = i

			self.AbilityName:SetText(name)
		end
	end

	if maxExpirationTime == 0 then
		self.maxExpirationTime = 0
		self.frame.timeLeft = nil
		self.frame.index = nil
		self.frame:SetScript("OnUpdate", nil)
		self.frame:Hide()
	elseif maxExpirationTime ~= self.maxExpirationTime then
		self.maxExpirationTime = maxExpirationTime
		self.frame.index = Index

		self.Icon:SetTexture(Icon)

		self.Cooldown:SetCooldown(GetTime() + (maxExpirationTime - Duration), Duration)

		if not self.frame.timeLeft then
			self.frame.timeLeft = maxExpirationTime

			self.frame:SetScript("OnUpdate", self.OnUpdate)
		else
			self.frame.timeLeft = maxExpirationTime
		end

		self.frame:Show()
	end
end

function LOS:Initialize()
	if not E.private.loseofcontrol.enable then return end

	self.frame = CreateFrame("Frame", "ElvUI_LoseOfControlFrame", UIParent)
	self.frame:Point("CENTER", 0, 0)
	self.frame:Size(54)
	self.frame:SetTemplate()
	self.frame:Hide()

	for name, v in pairs(G.loseofcontrol) do
		if name then
			abilities[name] = v
		end
	end

	E:CreateMover(self.frame, "LossControlMover", L["Loss Control Icon"])

	self.Icon = self.frame:CreateTexture(nil, "ARTWORK")
	self.Icon:SetInside()
	self.Icon:SetTexCoord(unpack(E.TexCoords))

	self.AbilityName = self.frame:CreateFontString(nil, "OVERLAY")
	self.AbilityName:FontTemplate(E["media"].normFont, 20, "OUTLINE")
	self.AbilityName:Point("BOTTOM", self.frame, 0, -28)

	self.Cooldown = CreateFrame("Cooldown", self.frame:GetName().."Cooldown", self.frame, "CooldownFrameTemplate")
	self.Cooldown:SetInside()

	self.frame.NumberText = self.frame:CreateFontString(nil, "OVERLAY")
	self.frame.NumberText:FontTemplate(E["media"].normFont, 20, "OUTLINE")
	self.frame.NumberText:Point("BOTTOM", self.frame, 0, -58)

	self.SecondsText = self.frame:CreateFontString(nil, "OVERLAY")
	self.SecondsText:FontTemplate(E["media"].normFont, 20, "OUTLINE")
	self.SecondsText:Point("BOTTOM", self.frame, 0, -80)
	self.SecondsText:SetText(L["seconds"])

	self:RegisterEvent("UNIT_AURA")
end

local function InitializeCallback()
	LOS:Initialize()
end

E:RegisterModule(LOS:GetName(), InitializeCallback)