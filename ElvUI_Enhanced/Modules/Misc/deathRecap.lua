local E, L, V, P, G, _ = unpack(ElvUI)
local mod = E:NewModule("DeathRecap", "AceHook-3.0", "AceEvent-3.0")

local format, upper = string.format, string.upper
local floor = math.floor
local tsort, twipe = table.sort, table.wipe
local band = bit.band
local tonumber, strsub = tonumber, strsub

local GetReleaseTimeRemaining = GetReleaseTimeRemaining
local RepopMe = RepopMe
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax

local COMBATLOG_FILTER_ME = COMBATLOG_FILTER_ME

local lastDeathEvents
local index = 0
local deathList = {}
local eventList = {}

function mod:AddEvent(timestamp, event, sourceName, spellId, spellName, environmentalType, amount, overkill, school, resisted, blocked, absorbed)
	if (index > 0) and (eventList[index].timestamp + 10 <= timestamp) then
		index = 0
		twipe(eventList)
	end

	if index < 5 then
		index = index + 1
	else
		index = 1
	end

	if not eventList[index] then
		eventList[index] = {}
	else
		twipe(eventList[index])
	end

	eventList[index].timestamp = timestamp
	eventList[index].event = event
	eventList[index].sourceName = sourceName
	eventList[index].spellId = spellId
	eventList[index].spellName = spellName
	eventList[index].environmentalType = environmentalType
	eventList[index].amount = amount
	eventList[index].overkill = overkill
	eventList[index].school = school
	eventList[index].resisted = resisted
	eventList[index].blocked = blocked
	eventList[index].absorbed = absorbed
	eventList[index].currentHP = UnitHealth("player")
	eventList[index].maxHP = UnitHealthMax("player")
end

function mod:EraseEvents()
	if index > 0 then
		index = 0
		twipe(eventList)
	end
end

function mod:AddDeath()
	if getn(eventList) > 0 then
		local _, deathEvents = self:HasEvents()
		local deathIndex = deathEvents + 1
		deathList[deathIndex] = CopyTable(eventList)
		self:EraseEvents()

		DEFAULT_CHAT_FRAME:AddMessage("|cff71d5ff|Hdeath:" .. deathIndex .. "|h[" .. L["You died."] .. "]|h|r")

		return true
	end
end

function mod:GetDeathEvents(recapID)
	if recapID and deathList[recapID] then
		local deathEvents = deathList[recapID]
		tsort(deathEvents, function(a, b) return a.timestamp > b.timestamp end)
		return deathEvents
	end
end

function mod:HasEvents()
	if lastDeathEvents then
		return getn(deathList) > 0, getn(deathList)
	else
		return false, getn(deathList)
	end
end

function mod:PLAYER_DEAD()
	if StaticPopup_FindVisible("DEATH") then
		if self:AddDeath() then
			lastDeathEvents = true
		else
			lastDeathEvents = false
		end

		StaticPopup_Hide("DEATH")
		E:StaticPopup_Show("DEATH", GetReleaseTimeRemaining(), SECONDS)
	end
end

function mod:HidePopup()
	E:StaticPopup_Hide("DEATH")
end

function mod:OpenRecap(recapID)
	local this = DeathRecapFrame
	print(self)

	if this:IsShown() and this.recapID == recapID then
		HideUIPanel(this)
		return
	end

	local deathEvents = mod:GetDeathEvents(recapID)
	if not deathEvents then return end

	this.recapID = recapID
	ShowUIPanel(this)

	if not deathEvents or getn(deathEvents) <= 0 then
		for i = 1, 5 do
			this.DeathRecapEntry[i]:Hide()
		end
		this.Unavailable:Show()
		return
	end
	this.Unavailable:Hide()

	local highestDmgIdx, highestDmgAmount = 1, 0
	this.DeathTimeStamp = nil

	for i = 1, getn(deathEvents) do
		local entry = this.DeathRecapEntry[i]
		local dmgInfo = entry.DamageInfo
		local evtData = deathEvents[i]
		local spellId, spellName, texture = mod:GetTableInfo(evtData)

		entry:Show()
		this.DeathTimeStamp = this.DeathTimeStamp or evtData.timestamp

		if evtData.amount then
			local amountStr = -(evtData.amount)
			dmgInfo.Amount:SetText(amountStr)
			dmgInfo.AmountLarge:SetText(amountStr)
			dmgInfo.amount = evtData.amount

			dmgInfo.dmgExtraStr = ""
			if evtData.overkill and evtData.overkill > 0 then
				dmgInfo.dmgExtraStr = format(L["(%d Overkill)"], evtData.overkill)
				dmgInfo.amount = evtData.amount - evtData.overkill
			end
			if evtData.absorbed and evtData.absorbed > 0 then
				dmgInfo.dmgExtraStr = dmgInfo.dmgExtraStr .. " " .. format(L["(%d Absorbed)"], evtData.absorbed)
				dmgInfo.amount = evtData.amount - evtData.absorbed
			end
			if evtData.resisted and evtData.resisted > 0 then
				dmgInfo.dmgExtraStr = dmgInfo.dmgExtraStr .. " " .. format(L["(%d Resisted)"], evtData.resisted)
				dmgInfo.amount = evtData.amount - evtData.resisted
			end
			if evtData.blocked and evtData.blocked > 0 then
				dmgInfo.dmgExtraStr = dmgInfo.dmgExtraStr .. " " .. format(L["(%d Blocked)"], evtData.blocked)
				dmgInfo.amount = evtData.amount - evtData.blocked
			end

			if evtData.amount > highestDmgAmount then
				highestDmgIdx = i
				highestDmgAmount = evtData.amount
			end

			dmgInfo.Amount:Show()
			dmgInfo.AmountLarge:Hide()
		else
			dmgInfo.Amount:SetText("")
			dmgInfo.AmountLarge:SetText("")
			dmgInfo.amount = nil
			dmgInfo.dmgExtraStr = nil
		end

		dmgInfo.timestamp = evtData.timestamp
		dmgInfo.hpPercent = floor(evtData.currentHP / evtData.maxHP * 100)

		dmgInfo.spellName = spellName

		dmgInfo.caster = evtData.sourceName or COMBATLOG_UNKNOWN_UNIT

		if evtData.school and evtData.school > 1 then
			local colorArray = CombatLog_Color_ColorArrayBySchool(evtData.school)
			entry.SpellInfo.FrameIcom:SetBackdropBorderColor(colorArray.r, colorArray.g, colorArray.b)
		else
			entry.SpellInfo.FrameIcom:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end

		dmgInfo.school = evtData.school

		entry.SpellInfo.Caster:SetText(dmgInfo.caster)

		entry.SpellInfo.Name:SetText(spellName)
		entry.SpellInfo.Icon:SetTexture(texture)

		entry.SpellInfo.spellId = spellId
	end

	for i = getn(deathEvents) + 1, getn(self.DeathRecapEntry) do
		this.DeathRecapEntry[i]:Hide()
	end

	local entry = self.DeathRecapEntry[highestDmgIdx]
	if entry.DamageInfo.amount then
		entry.DamageInfo.Amount:Hide()
		entry.DamageInfo.AmountLarge:Show()
	end

	local deathEntry = self.DeathRecapEntry[1]
	local tombstoneIcon = deathEntry.tombstone
	if entry == deathEntry then
		tombstoneIcon:SetPoint("RIGHT", deathEntry.DamageInfo.AmountLarge, "LEFT", -10, 0)
	end
end

function mod:Spell_OnEnter()
	if this.spellId then
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(GetSpellLink(this.spellId))
		GameTooltip:Show()
	end
end

function mod:Amount_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_LEFT")
	GameTooltip:ClearLines()
	if this.amount then
		local valueStr = this.school and format(TEXT_MODE_A_STRING_VALUE_SCHOOL, this.amount, CombatLog_String_SchoolString(this.school)) or this.amount
		GameTooltip:AddLine(format(L["%s %s"], valueStr, this.dmgExtraStr), 1, 0, 0, false)
	end

	if this.spellName then
		if this.caster then
			GameTooltip:AddLine(format(L["%s by %s"], this.spellName, this.caster), 1, 1, 1, true)
		else
			GameTooltip:AddLine(this.spellName, 1, 1, 1, true)
		end
	end

	local seconds = DeathRecapFrame.DeathTimeStamp - this.timestamp
	if seconds > 0 then
		GameTooltip:AddLine(format(L["%s sec before death at %s%% health."], format("%.1f", seconds), this.hpPercent), 1, 0.824, 0, true)
	else
		GameTooltip:AddLine(format(L["Killing blow at %s%% health."], this.hpPercent), 1, 0.824, 0, true)
	end

	GameTooltip:Show()
end

function mod:GetTableInfo(data)
	local texture
	local nameIsNotSpell = false

	local event = data.event
	local spellId = data.spellId
	local spellName = data.spellName

	if event == "SWING_DAMAGE" then
		spellId = 6603
		spellName = ACTION_SWING

		nameIsNotSpell = true
	elseif event == "RANGE_DAMAGE" then
		nameIsNotSpell = true
--	elseif strsub(event, 1, 5) == "SPELL" then
	elseif event == "ENVIRONMENTAL_DAMAGE" then
		local environmentalType = data.environmentalType
		environmentalType = upper(environmentalType)
		spellName = _G["ACTION_ENVIRONMENTAL_DAMAGE_" .. environmentalType]
		nameIsNotSpell = true
		if environmentalType == "DROWNING" then
			texture = "spell_shadow_demonbreath"
		elseif environmentalType == "FALLING" then
			texture = "ability_rogue_quickrecovery"
		elseif environmentalType == "FIRE" or environmentalType == "LAVA" then
			texture = "spell_fire_fire"
		elseif environmentalType == "SLIME" then
			texture = "inv_misc_slime_01"
		elseif environmentalType == "FATIGUE" then
			texture = "ability_creature_cursed_05"
		else
			texture = "ability_creature_cursed_05"
		end
		texture = "Interface\\Icons\\" .. texture
	end

	local spellNameStr = spellName
	local spellString
	if spellName then
		if nameIsNotSpell then
			spellString = format("|Haction:%s|h%s|h", event, spellNameStr)
		else
			spellString = spellName
		end
	end

	if spellId and not texture then
		texture = select(3, GetSpellInfo(spellId))
	end
	return spellId, spellString, texture
end

function mod:COMBAT_LOG_EVENT_UNFILTERED(_, timestamp, event, _, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	if band(destFlags, COMBATLOG_FILTER_ME) ~= COMBATLOG_FILTER_ME or band(sourceFlags, COMBATLOG_FILTER_ME) == COMBATLOG_FILTER_ME then return end
	if event ~= "ENVIRONMENTAL_DAMAGE"
	and event ~= "RANGE_DAMAGE"
	and event ~= "SPELL_DAMAGE"
	and event ~= "SPELL_EXTRA_ATTACKS"
	and event ~= "SPELL_INSTAKILL"
	and event ~= "SPELL_PERIODIC_DAMAGE"
	and event ~= "SWING_DAMAGE"
	then return end

	local subVal = strsub(event, 1, 5)
	local environmentalType, spellId, spellName, amount, overkill, school, resisted, blocked, absorbed

	if event == "SWING_DAMAGE" then
		amount, overkill, school, resisted, blocked, absorbed = unpack(arg)
	elseif subVal == "SPELL" then
		spellId, spellName, _, amount, overkill, school, resisted, blocked, absorbed = unpack(arg)
	elseif event == "ENVIRONMENTAL_DAMAGE" then
		environmentalType, amount, overkill, school, resisted, blocked, absorbed = unpack(arg)
	end

	if not tonumber(amount) then return end

	self:AddEvent(timestamp, event, sourceName, spellId, spellName, environmentalType, amount, overkill, school, resisted, blocked, absorbed)
end

function mod:SetItemRef(link, ...)
	if strsub(link, 1, 5) == "death" then
		local _, id = strsplit(":", link)
		mod:OpenRecap(tonumber(id))
		return
	else
		self.hooks.SetItemRef(link, unpack(arg))
	end
end

function mod:Initialize()
	local S = E:GetModule("Skins")

	local frame = CreateFrame("Frame", "DeathRecapFrame", UIParent)
	frame:SetWidth(340)
	frame:SetHeight(326)
	frame:SetPoint("CENTER", 0, 0)
	E:SetTemplate(frame, "Transparent")
	frame:SetMovable(true)
	frame:Hide()
	frame:SetScript("OnHide", function() this.recapID = nil end)
	tinsert(UISpecialFrames, frame:GetName())

	frame.Title = frame:CreateFontString("ARTWORK", nil, "GameFontNormal")
	frame.Title:SetPoint("TOPLEFT", 12, -9)
	frame.Title:SetText(L["Death Recap"])

	frame.Unavailable = frame:CreateFontString("ARTWORK", nil, "GameFontNormal")
	frame.Unavailable:SetPoint("CENTER", 0, 0)
	frame.Unavailable:SetText(L["Death Recap unavailable."])

	frame.CloseXButton = CreateFrame("Button", "$parentCloseXButton", frame)
	frame.CloseXButton:SetWidth(32)
	frame.CloseXButton:SetHeight(32)
	frame.CloseXButton:SetPoint("TOPRIGHT", 2, 1)
	frame.CloseXButton:SetScript("OnClick", function() HideUIPanel(this:GetParent()) end)
	S:HandleCloseButton(frame.CloseXButton)

	frame.DragButton = CreateFrame("Button", "$parentDragButton", frame)
	frame.DragButton:SetPoint("TOPLEFT", 0, 0)
	frame.DragButton:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -32)
	frame.DragButton:RegisterForDrag("LeftButton")
	frame.DragButton:SetScript("OnDragStart", function() this:GetParent():StartMoving() end)
	frame.DragButton:SetScript("OnDragStop", function() this:GetParent():StopMovingOrSizing() end)

	frame.DeathRecapEntry = {}
	for i = 1, 5 do
		local button = CreateFrame("Frame", nil, frame)
		button:SetWidth(308)
		button:SetHeight(32)
		frame.DeathRecapEntry[i] = button

		button.DamageInfo = CreateFrame("Button", nil, button)
		button.DamageInfo:SetPoint("TOPLEFT", 0, 0)
		button.DamageInfo:SetPoint("BOTTOMRIGHT", button, "BOTTOMLEFT", 80, 0)
		button.DamageInfo:SetScript("OnEnter", self.Amount_OnEnter)
		button.DamageInfo:SetScript("OnLeave", GameTooltip_Hide)

		button.DamageInfo.Amount = button.DamageInfo:CreateFontString("ARTWORK", nil, "GameFontNormal")
		button.DamageInfo.Amount:SetJustifyH("RIGHT")
		button.DamageInfo.Amount:SetJustifyV("CENTER")
		button.DamageInfo.Amount:SetWidth(0)
		button.DamageInfo.Amount:SetHeight(32)
		button.DamageInfo.Amount:SetPoint("TOPRIGHT", 0, 0)
		button.DamageInfo.Amount:SetTextColor(0.75, 0.05, 0.05, 1)

		button.DamageInfo.AmountLarge = button.DamageInfo:CreateFontString("ARTWORK", nil, "NumberFontNormalLarge")
		button.DamageInfo.AmountLarge:SetJustifyH("RIGHT")
		button.DamageInfo.AmountLarge:SetJustifyV("CENTER")
		button.DamageInfo.AmountLarge:SetWidth(0)
		button.DamageInfo.AmountLarge:SetHeight(32)
		button.DamageInfo.AmountLarge:SetPoint("TOPRIGHT", 0, 0)
		button.DamageInfo.AmountLarge:SetTextColor(1, 0.07, 0.07, 1)

		button.SpellInfo = CreateFrame("Button", nil, button)
		button.SpellInfo:SetPoint("TOPLEFT", button.DamageInfo, "TOPRIGHT", 16, 0)
		button.SpellInfo:SetPoint("BOTTOMRIGHT", 0, 0)
		button.SpellInfo:SetScript("OnEnter", self.Spell_OnEnter)
		button.SpellInfo:SetScript("OnLeave", GameTooltip_Hide)

		button.SpellInfo.FrameIcom = CreateFrame("Button", nil, button.SpellInfo)
		button.SpellInfo.FrameIcom:SetWidth(34)
		button.SpellInfo.FrameIcom:SetHeight(34)
		button.SpellInfo.FrameIcom:SetPoint("LEFT", 0, 0)
		E:SetTemplate(button.SpellInfo.FrameIcom, "Default")

		button.SpellInfo.Icon = button.SpellInfo:CreateTexture("ARTWORK")
		button.SpellInfo.Icon:SetParent(button.SpellInfo.FrameIcom)
		button.SpellInfo.Icon:SetTexCoord(unpack(E.TexCoords))
		E:SetInside(button.SpellInfo.Icon)

		button.SpellInfo.Name = button.SpellInfo:CreateFontString("ARTWORK", nil, "GameFontNormal")
		button.SpellInfo.Name:SetJustifyH("LEFT")
		button.SpellInfo.Name:SetJustifyV("BOTTOM")
		button.SpellInfo.Name:SetPoint("BOTTOMLEFT", button.SpellInfo.Icon, "RIGHT", 8, 1)
		button.SpellInfo.Name:SetPoint("TOPRIGHT", 0, 0)

		button.SpellInfo.Caster = button.SpellInfo:CreateFontString("ARTWORK", nil, "GameFontNormalSmall")
		button.SpellInfo.Caster:SetJustifyH("LEFT")
		button.SpellInfo.Caster:SetJustifyV("TOP")
		button.SpellInfo.Caster:SetPoint("TOPLEFT", button.SpellInfo.Icon, "RIGHT", 8, -2)
		button.SpellInfo.Caster:SetPoint("BOTTOMRIGHT", 0, 0)
		button.SpellInfo.Caster:SetTextColor(0.5, 0.5, 0.5, 1)

		if i == 1 then
			button:SetPoint("BOTTOMLEFT", 16, 64)
			button.tombstone = button:CreateTexture("ARTWORK")
			button.tombstone:SetWidth(15)
			button.tombstone:SetHeight(20)
			button.tombstone:SetPoint("RIGHT", button.DamageInfo.Amount, "LEFT", -10, 0)
			button.tombstone:SetTexCoord(0.658203125, 0.6875, 0.00390625, 0.08203125)
			button.tombstone:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\Media\\Textures\\DeathRecap")
		else
			button:SetPoint("BOTTOM", frame.DeathRecapEntry[i - 1], "TOP", 0, 14)
		end
	end

	frame.CloseButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.CloseButton:SetWidth(144)
	frame.CloseButton:SetHeight(21)
	frame.CloseButton:SetPoint("BOTTOM", 0, 15)
	frame.CloseButton:SetText(CLOSE)
	frame.CloseButton:SetScript("OnClick", function() HideUIPanel(DeathRecapFrame) end)
	S:HandleButton(frame.CloseButton)

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("PLAYER_DEAD")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "HidePopup")
	self:RegisterEvent("RESURRECT_REQUEST", "HidePopup")
	self:RegisterEvent("PLAYER_ALIVE", "HidePopup")

	self:RawHook("SetItemRef", true)

	E.PopupDialogs["DEATH"] = {
		text = DEATH_RELEASE_TIMER,
		button1 = DEATH_RELEASE,
		button2 = USE_SOULSTONE,
		-- button3 = L["Death Recap"],
		OnShow = function()
			this.timeleft = GetReleaseTimeRemaining()
			local text = HasSoulstone()
			if text then
				this.button2:SetText(text)
			end

			if this.timeleft == -1 then
				this.text:SetText(DEATH_RELEASE_NOTIMER)
			end
			-- if mod:HasEvents() then
			-- 	this.button3:Enable()
			-- 	this.button3:SetScript("OnEnter", nil)
			-- 	this.button3:SetScript("OnLeave", nil)
			-- else
			-- 	this.button3:Disable()
			-- 	this.button3:SetScript("OnEnter", function()
			-- 		GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
			-- 		GameTooltip:SetText(L["Death Recap unavailable."])
			-- 		GameTooltip:Show()
			-- 	end)
			-- 	this.button3:SetScript("OnLeave", GameTooltip_Hide)
			-- end
		end,
		OnHide = function()
			-- this.button3:SetScript("OnEnter", nil)
			-- this.button3:SetScript("OnLeave", nil)
			HideUIPanel(DeathRecapFrame)
		end,
		OnAccept = function()
			RepopMe()
		end,
		OnCancel = function(_, _, reason)
			if reason == "override" then
				StaticPopup_Show("RECOVER_CORPSE")
				return
			end
			if reason == "timeout" then
				return
			end
			if reason == "clicked" then
				if(HasSoulstone()) then
					UseSoulstone()
				else
					RepopMe()
				end
			end
		end,
		OnAlt = function()
			local _, recapID = mod:HasEvents()
			mod:OpenRecap(recapID)
		end,
		OnUpdate = function()
			if this.timeleft > 0 then
				local text = _G[this:GetName() .. "Text"]
				local timeleft = this.timeleft
				if timeleft < 60 then
					text:SetText(format(DEATH_RELEASE_TIMER, timeleft, SECONDS))
				else
					text:SetText(format(DEATH_RELEASE_TIMER, ceil(timeleft / 60), MINUTES))
				end
			end

			-- if IsFalling() and not IsOutOfBounds() then
			-- 	this.button1:Disable()
			-- 	this.button2:Disable()
			-- 	return
			-- else
				this.button1:Enable()
			-- end
			if HasSoulstone() then
				this.button2:Enable()
			else
				this.button2:Disable()
			end
		end,
		DisplayButton2 = function()
			return HasSoulstone()
		end,

		timeout = 0,
		whileDead = 1,
		interruptCinematic = 1,
		noCancelOnReuse = 1,
		hideOnEscape = false,
		noCloseOnAlt = true
	}
end

local function InitializeCallback()
	mod:Initialize()
end

E:RegisterModule(mod:GetName(), InitializeCallback)