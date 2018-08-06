local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local ECF = E:NewModule("Enhanced_CharacterFrame", "AceHook-3.0", "AceEvent-3.0");
local S = E:GetModule("Skins");

--Cache global variables
--Lua functions
local _G = _G
local next, pairs, tonumber, assert, getmetatable = next, pairs, tonumber, assert, getmetatable
local find, format, sub, gsub, gmatch, lower, trim = string.find, string.format, string.sub, string.gsub, string.gmatch, string.lower, string.trim
local abs, floor, max, min, mod = math.abs, math.floor, math.max, math.min, math.mod
local wipe, sort, getn, tinsert, tremove = table.wipe, table.sort, table.getn, table.insert, table.remove

--WoW API / Variables
local CharacterRangedDamageFrame_OnEnter = CharacterRangedDamageFrame_OnEnter
local CreateFrame = CreateFrame
local GetAttackPowerForStat = GetAttackPowerForStat
local GetBlockChance = GetBlockChance
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots
local GetCritChance = GetCritChance
-- local GetCritChanceFromAgility = GetCritChanceFromAgility
local GetCursorPosition = GetCursorPosition
local GetDodgeChance = GetDodgeChance
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventorySlotInfo = GetInventorySlotInfo
local GetItemInfo = GetItemInfo
local GetParryChance = GetParryChance
local GetShieldBlock = GetShieldBlock
local GetSpellCritChanceFromIntellect = GetSpellCritChanceFromIntellect
local GetUnitHealthModifier = GetUnitHealthModifier
local GetUnitHealthRegenRateFromSpirit = GetUnitHealthRegenRateFromSpirit
local GetUnitManaRegenRateFromSpirit = GetUnitManaRegenRateFromSpirit
local GetUnitMaxHealthModifier = GetUnitMaxHealthModifier
local GetUnitPowerModifier = GetUnitPowerModifier
local PaperDollFrame_SetDefense = PaperDollFrame_SetDefense
local PaperDollFrame_SetRangedAttackPower = PaperDollFrame_SetRangedAttackPower
local PaperDollFrame_SetRangedAttackSpeed = PaperDollFrame_SetRangedAttackSpeed
local PaperDollFrame_SetRangedCritChance = PaperDollFrame_SetRangedCritChance
local PaperDollFrame_SetRangedDamage = PaperDollFrame_SetRangedDamage
local PaperDollFrame_SetRating = PaperDollFrame_SetRating
local PaperDollFrame_SetSpellBonusDamage = PaperDollFrame_SetSpellBonusDamage
local PaperDollFrame_SetSpellBonusHealing = PaperDollFrame_SetSpellBonusHealing
local PaperDollFrame_SetSpellCritChance = PaperDollFrame_SetSpellCritChance
local PaperDollFrame_SetSpellHaste = PaperDollFrame_SetSpellHaste
local PlaySound = PlaySound
local SetPortraitTexture = SetPortraitTexture
local UnitAttackSpeed = UnitAttackSpeed
local UnitClass = UnitClass
local UnitDamage = UnitDamage
local UnitLevel = UnitLevel
local UnitRace = UnitRace
local UnitResistance = UnitResistance
local UnitStat = UnitStat

local ARMOR_PER_AGILITY = ARMOR_PER_AGILITY
local CR_CRIT_TAKEN_MELEE = CR_CRIT_TAKEN_MELEE
local CR_CRIT_TAKEN_RANGED = CR_CRIT_TAKEN_RANGED
local CR_CRIT_TAKEN_SPELL = CR_CRIT_TAKEN_SPELL
local HEALTH_PER_STAMINA = HEALTH_PER_STAMINA

local slotName = {
	"Head","Neck","Shoulder","Back","Chest",
	"Shirt","Tabard","Wrist","Waist","Legs","Feet",
	"Finger0","Finger1","Trinket0","Trinket1",
	"MainHand", "SecondaryHand", "Ranged", "Ammo"
}

local CHARACTERFRAME_COLLAPSED_WIDTH = 348 + 37
local CHARACTERFRAME_EXPANDED_WIDTH = 540 + 42
local STATCATEGORY_MOVING_INDENT = 4

MOVING_STAT_CATEGORY = nil

PAPERDOLL_STATINFO = {
	["ITEM_LEVEL"] = {
		updateFunc = function(statFrame, unit) ECF:ItemLevel(statFrame, unit) end
	},
	["STRENGTH"] = {
		updateFunc = function(statFrame, unit) ECF:SetStat(statFrame, unit, 1) end
	},
	["AGILITY"] = {
		updateFunc = function(statFrame, unit) ECF:SetStat(statFrame, unit, 2) end
	},
	["STAMINA"] = {
		updateFunc = function(statFrame, unit) ECF:SetStat(statFrame, unit, 3) end
	},
	["INTELLECT"] = {
		updateFunc = function(statFrame, unit) ECF:SetStat(statFrame, unit, 4) end
	},
	["SPIRIT"] = {
		updateFunc = function(statFrame, unit) ECF:SetStat(statFrame, unit, 5) end
	},

	["MELEE_AP"] = {
		updateFunc = function(statFrame, unit) ECF:SetAttackPower(statFrame, unit) end
	},
	["MELEE_DAMAGE"] = {
		updateFunc = function(statFrame, unit) ECF:SetDamage(statFrame, unit) end,
		--updateFunc2 = function(statFrame) CharacterDamageFrame_OnEnter(statFrame) end
	},
	["MELEE_ATTACKSPEED"] = {
		updateFunc = function(statFrame, unit) ECF:SetAttackSpeed(statFrame, unit) end
	},
	["MELEE_DPS"] = {
		updateFunc = function(statFrame, unit) ECF:SetMeleeDPS(statFrame, unit) end
	},

	-- ["RANGED_COMBAT1"] = {
	-- 	updateFunc = function(statFrame, unit) PaperDollFrame_SetRangedDamage(statFrame, unit) end,
	-- 	updateFunc2 = function(statFrame) CharacterRangedDamageFrame_OnEnter(statFrame) end
	-- },
	-- ["RANGED_COMBAT2"] = {
	-- 	updateFunc = function(statFrame, unit) PaperDollFrame_SetRangedAttackSpeed(statFrame, unit) end
	-- },
	-- ["RANGED_COMBAT3"] = {
	-- 	updateFunc = function(statFrame, unit) PaperDollFrame_SetRangedAttackPower(statFrame, unit) end
	-- },
	-- ["RANGED_COMBAT4"] = {
	-- 	updateFunc = function(statFrame) PaperDollFrame_SetRating(statFrame, CR_HIT_RANGED) end
	-- },
	-- ["RANGED_COMBAT5"] = {
	-- 	updateFunc = function(statFrame, unit) PaperDollFrame_SetRangedCritChance(statFrame, unit) end
	-- },

	-- ["SPELL_COMBAT1"] = {
	-- 	updateFunc = function(statFrame, unit) PaperDollFrame_SetSpellBonusDamage(statFrame, unit) end,
	-- 	updateFunc2 = function(statFrame) CharacterSpellBonusDamage_OnEnter(statFrame) end
	-- },
	-- ["SPELL_COMBAT2"] = {
	-- 	updateFunc = function(statFrame, unit) PaperDollFrame_SetSpellBonusHealing(statFrame, unit) end
	-- },
	-- ["SPELL_COMBAT3"] = {
	-- 	updateFunc = function(statFrame, unit) PaperDollFrame_SetRating(statFrame, CR_HIT_SPELL) end
	-- },
	-- ["SPELL_COMBAT4"] = {
	-- 	updateFunc = function(statFrame, unit) PaperDollFrame_SetSpellCritChance(statFrame, unit) end,
	-- 	updateFunc2 = function(statFrame) CharacterSpellCritChance_OnEnter(statFrame) end
	-- },
	-- ["SPELL_COMBAT5"] = {
	-- 	updateFunc = function(statFrame, unit) PaperDollFrame_SetSpellHaste(statFrame, unit) end
	-- },
	-- ["SPELL_COMBAT6"] = {
	-- 	updateFunc = function(statFrame, unit) PaperDollFrame_SetManaRegen(statFrame, unit) end
	-- },

	["ARMOR"] = {
		updateFunc = function(statFrame, unit) ECF:SetArmor(statFrame, unit) end
	},
	["DODGE"] = {
		updateFunc = function(statFrame, unit) ECF:SetDodge(statFrame, unit) end
	},
	["BLOCK"] = {
		updateFunc = function(statFrame, unit) ECF:SetBlock(statFrame, unit) end
	},

	-- ["ARCANE"] = {
	-- 	updateFunc = function(statFrame, unit) ECF:SetResistance(statFrame, unit, 6) end
	-- },
	-- ["FIRE"] = {
	-- 	updateFunc = function(statFrame, unit) ECF:SetResistance(statFrame, unit, 2) end
	-- },
	-- ["FROST"] = {
	-- 	updateFunc = function(statFrame, unit) ECF:SetResistance(statFrame, unit, 4) end
	-- },
	-- ["NATURE"] = {
	-- 	updateFunc = function(statFrame, unit) ECF:SetResistance(statFrame, unit, 3) end
	-- },
	-- ["SHADOW"] = {
	-- 	updateFunc = function(statFrame, unit) ECF:SetResistance(statFrame, unit, 5) end
	-- },
}

PAPERDOLL_STATCATEGORIES = {
	["ITEM_LEVEL"] = {
		id = 1,
		stats = {
			"ITEM_LEVEL"
		}
	},
	["BASE_STATS"] = {
		id = 2,
		stats = {
			"STRENGTH",
			"AGILITY",
			"STAMINA",
			"INTELLECT",
			"SPIRIT"
		}
	},
	["MELEE_COMBAT"] = {
		id = 3,
		stats = {
			"MELEE_AP",
			"MELEE_DAMAGE",
			"MELEE_DPS",
			"MELEE_ATTACKSPEED"
		}
	},
	--[[
	["RANGED_COMBAT"] = {
		id = 4,
		stats = {
			"RANGED_COMBAT1",
			"RANGED_COMBAT2",
			"RANGED_COMBAT3",
			"RANGED_COMBAT4",
			"RANGED_COMBAT5",
		}
	},
	["SPELL_COMBAT"] = {
		id = 5,
		stats = {
			"SPELL_COMBAT1",
			"SPELL_COMBAT2",
			"SPELL_COMBAT3",
			"SPELL_COMBAT4",
			"SPELL_COMBAT5",
			"SPELL_COMBAT6"
		}
	},]]
	["DEFENSES"] = {
		id = 6,
		stats = {
			"ARMOR",
			"DODGE",
			"BLOCK"
		}
	},
--[[	["RESISTANCE"] = {
		id = 7,
		stats = {
			"ARCANE",
			"FIRE",
			"FROST",
			"NATURE",
			"SHADOW",
		}
	},]]
}

PAPERDOLL_STATCATEGORY_DEFAULTORDER = {
	"ITEM_LEVEL",
	"BASE_STATS",
	"MELEE_COMBAT",
--	"RANGED_COMBAT",
--	"SPELL_COMBAT",
	"DEFENSES",
--	"RESISTANCE",
}

PETPAPERDOLL_STATCATEGORY_DEFAULTORDER = {
	"BASE_STATS",
	"MELEE_COMBAT",
--	"RANGED_COMBAT",
--	"SPELL_COMBAT",
--	"DEFENSES",
--	"RESISTANCE",
}

local locale = GetLocale()
local classTextFormat =
locale == "deDE" and "Stufe %s %s%s %s" or
locale == "ruRU" and "%2$s%4$s (%3$s)|r %1$s-го уровня" or
locale == "frFR" and "%2$s%4$s %3$s|r de niveau %1$s" or
locale == "koKR" and "%s 레벨 %s%s %s|r" or
locale == "zhCN" and "等级%s %s%s %s|r" or
locale == "zhTW" and "等級%s%s%s%s|r" or
locale == "esES" and "%2$s%4$s %3$s|r de nivel %1$s" or
locale == "ptBR" and "%2$s%4$s (%3$s)|r Nível %1$s" or
"Level %s %s%s %s|r"

function ECF:PaperDollFrame_SetLevel()
	local _, specName = E:GetTalentSpecInfo()
	local classDisplayName, class = UnitClass("player")
	local classColor = RAID_CLASS_COLORS[class]
	local classColorString = format("|cFF%02x%02x%02x", classColor.r*255, classColor.g*255, classColor.b*255)

	if specName == "None" then
		CharacterLevelText:SetText(format(PLAYER_LEVEL, UnitLevel("player"), classColorString, classDisplayName))
	else
		CharacterLevelText:SetText(format(classTextFormat, UnitLevel("player"), classColorString, specName, classDisplayName))
	end

	if CharacterLevelText:GetWidth() > 210 then
		CharacterLevelText:SetPoint("TOP", CharacterNameText, "BOTTOM", 10, -6)
	else
		CharacterLevelText:SetPoint("TOP", CharacterNameText, "BOTTOM", 0, -6)
	end
end

function ECF:CharacterFrame_Collapse()
	E:Width(CharacterFrame, CHARACTERFRAME_COLLAPSED_WIDTH)
	CharacterFrame.Expanded = false

	S:SquareButton_SetIcon(CharacterFrameExpandButton, "RIGHT")

	CharacterStatsPane:Hide()

	-- if not InCombatLockdown() then
	-- 	CharacterFrame:SetAttribute("UIPanelLayout-width", E:Scale(CHARACTERFRAME_COLLAPSED_WIDTH))
	-- 	UpdateUIPanelPositions(CharacterFrame)
	-- end
end

function ECF:CharacterFrame_Expand()
	E:Width(CharacterFrame, CHARACTERFRAME_EXPANDED_WIDTH)
	CharacterFrame.Expanded = true

	S:SquareButton_SetIcon(CharacterFrameExpandButton, "LEFT")

	CharacterStatsPane:Show()

	-- if not InCombatLockdown() then
	-- 	CharacterFrame:SetAttribute("UIPanelLayout-width", E:Scale(CHARACTERFRAME_EXPANDED_WIDTH))
	-- 	UpdateUIPanelPositions(CharacterFrame)
	-- end
end

local StatCategoryFrames = {}

function ECF:ItemLevel(statFrame, unit)
	local label = _G[statFrame:GetName().."Label"]
	if PersonalGearScore then
		local myGearScore = GearScore_GetScore(UnitName("player"), "player")
		label:SetText(myGearScore)
		local r, b, g = GearScore_GetQuality(myGearScore)
		label:SetTextColor(r, g, b)
	else
		local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
		if avgItemLevelEquipped == avgItemLevel then
			label:SetText(format("%.2f", avgItemLevelEquipped))
		else
			label:SetText(format("%.2f / %.2f", avgItemLevelEquipped, avgItemLevel))
		end
		label:SetTextColor(GetItemLevelColor())
	end
end

function ECF:SetStat(statFrame, unit, statIndex)
	local label = _G[statFrame:GetName().."Label"]
	local text = _G[statFrame:GetName().."StatText"]
	local stat, effectiveStat, posBuff, negBuff = UnitStat(unit, statIndex)
	local statName = _G["SPELL_STAT"..(statIndex-1).."_NAME"]

	label:SetText(format("%s:", statName))

	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..format("%s", statName).." "
	if (posBuff == 0) and (negBuff == 0) then
		text:SetText(effectiveStat)
		statFrame.tooltip = tooltipText..effectiveStat..FONT_COLOR_CODE_CLOSE
	else
		tooltipText = tooltipText..effectiveStat
		if posBuff > 0 or negBuff < 0 then
			tooltipText = tooltipText.." ("..(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE
		end
		if posBuff > 0 then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE
		end
		if negBuff < 0 then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE
		end
		if posBuff > 0 or negBuff < 0 then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE
		end
		statFrame.tooltip = tooltipText

		if negBuff < 0 then
			text:SetText(RED_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE)
		else
			text:SetText(GREEN_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE)
		end
	end

	if unit == "player" then
		local _, unitClass = UnitClass("player")
		local classStatText
		if statIndex == 1 then
			statFrame.tooltip2 = _G[unitClass.."_STRENGTH_TOOLTIP"] or _G["DEFAULT_STRENGTH_TOOLTIP"]
		elseif statIndex == 3 then
			statFrame.tooltip2 = _G[unitClass.."_AGILITY_TOOLTIP"] or _G["DEFAULT_AGILITY_TOOLTIP"]
		elseif statIndex == 2 then
			statFrame.tooltip2 = _G[unitClass.."_STAMINA_TOOLTIP"] or _G["DEFAULT_STAMINA_TOOLTIP"]
		elseif statIndex == 4 then
			statFrame.tooltip2 = _G[unitClass.."_INTELLECT_TOOLTIP"] or _G["DEFAULT_INTELLECT_TOOLTIP"]
		elseif statIndex == 5 then
			statFrame.tooltip2 = _G[unitClass.."_SPIRIT_TOOLTIP"] or _G["DEFAULT_SPIRIT_TOOLTIP"]
		end
	end
	statFrame:Show()
end

function ECF:SetResistance(statFrame, unit, resistanceIndex)
	local base, resistance, positive, negative = UnitResistance(unit, resistanceIndex)
	local petBonus = ComputePetBonus("PET_BONUS_RES", resistance)
	local resistanceNameShort = _G["SPELL_SCHOOL"..resistanceIndex.."_CAP"]
	local resistanceName = _G["RESISTANCE"..resistanceIndex.."_NAME"]
	local resistanceIconCode = "|TInterface\\PaperDollInfoFrame\\SpellSchoolIcon"..(resistanceIndex + 1)..":18:18:0:0|t"
	_G[statFrame:GetName().."Label"]:SetText(resistanceIconCode.." "..format("%s:", resistanceNameShort))
	local text = _G[statFrame:GetName().."StatText"]
	PaperDollFormatStat(resistanceName, base, positive, negative, statFrame, text)
	statFrame.tooltip = resistanceIconCode.." "..HIGHLIGHT_FONT_COLOR_CODE..format("%s", resistanceName).." "..resistance..FONT_COLOR_CODE_CLOSE

	if positive ~= 0 or negative ~= 0 then
		statFrame.tooltip = statFrame.tooltip.." ( "..HIGHLIGHT_FONT_COLOR_CODE..base
		if positive > 0 then
			statFrame.tooltip = statFrame.tooltip..GREEN_FONT_COLOR_CODE.." +"..positive
		end
		if negative < 0 then
			statFrame.tooltip = statFrame.tooltip.." "..RED_FONT_COLOR_CODE..negative
		end
		statFrame.tooltip = statFrame.tooltip..FONT_COLOR_CODE_CLOSE.." )"
	end

	local resistanceLevel
	local unitLevel = UnitLevel(unit)
	unitLevel = max(unitLevel, 20)
	local magicResistanceNumber = resistance / unitLevel
	if magicResistanceNumber > 5 then
		resistanceLevel = RESISTANCE_EXCELLENT
	elseif magicResistanceNumber > 3.75 then
		resistanceLevel = RESISTANCE_VERYGOOD
	elseif magicResistanceNumber > 2.5 then
		resistanceLevel = RESISTANCE_GOOD
	elseif magicResistanceNumber > 1.25 then
		resistanceLevel = RESISTANCE_FAIR
	elseif magicResistanceNumber > 0 then
		resistanceLevel = RESISTANCE_POOR
	else
		resistanceLevel = RESISTANCE_NONE
	end
	statFrame.tooltip2 = format(RESISTANCE_TOOLTIP_SUBTEXT, _G["RESISTANCE_TYPE"..resistanceIndex], unitLevel, resistanceLevel)

	if petBonus > 0 then
		statFrame.tooltip2 = statFrame.tooltip2.."\n"..format(PET_BONUS_TOOLTIP_RESISTANCE, petBonus)
	end
end

function ECF:SetArmor(statFrame, unit)
	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor(unit)
	local totalBufs = posBuff + negBuff

	local label = _G[statFrame:GetName().."Label"]
	local text = _G[statFrame:GetName().."StatText"]
	label:SetText(ARMOR_COLON)

	PaperDollFormatStat(ARMOR, base, posBuff, negBuff, statFrame, text)
	local playerLevel = UnitLevel(unit)
	local armorReduction = effectiveArmor/((85 * playerLevel) + 400)
	armorReduction = 100 * (armorReduction/(armorReduction + 1))

	statFrame.tooltip2 = format(ARMOR_TOOLTIP, playerLevel, armorReduction)
end

function ECF:SetDefense(statFrame, unit)
	local base, modifier = UnitDefense(unit)

	local label = _G[statFrame:GetName().."Label"]
	local text = _G[statFrame:GetName().."StatText"]
	label:SetText(DEFENSE_COLON)

	local posBuff = 0
	local negBuff = 0
	if modifier > 0 then
		posBuff = modifier
	elseif modifier < 0 then
		negBuff = modifier
	end
	PaperDollFormatStat(DEFENSE_COLON, base, posBuff, negBuff, statFrame, text)
end

function ECF:SetDamage(statFrame, unit)
	local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage(unit)

	local label = _G[statFrame:GetName().."Label"]
	local text = _G[statFrame:GetName().."StatText"]

	label:SetText(DAMAGE_COLON)

	local displayMin = max(floor(minDamage),1)
	local displayMax = max(ceil(maxDamage),1)

	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg

	local baseDamage = (minDamage + maxDamage) * 0.5
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent
	local totalBonus = (fullDamage - baseDamage)

	local colorPos = "|cff20ff20"
	local colorNeg = "|cffff2020"
	if totalBonus == 0 then
		if displayMin < 100 and displayMax < 100 then
			text:SetText(displayMin.." - "..displayMax)
		else
			text:SetText(displayMin.."-"..displayMax)
		end
	else
		local color
		if totalBonus > 0 then
			color = colorPos
		else
			color = colorNeg
		end
		if displayMin < 100 and displayMax < 100 then
			text:SetText(color..displayMin.." - "..displayMax.."|r")
		else
			text:SetText(color..displayMin.."-"..displayMax.."|r")
		end
	end
end

function ECF:SetMeleeDPS(statFrame, unit)
	local speed, offhandSpeed = UnitAttackSpeed(unit)
	local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage(unit)

	local label = _G[statFrame:GetName().."Label"]
	local text = _G[statFrame:GetName().."StatText"]
	label:SetText(L["Damage Per Second"]..":")

	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg

	local baseDamage = (minDamage + maxDamage) * 0.5
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent
	local totalBonus = (fullDamage - baseDamage)
	local damagePerSecond = (max(fullDamage,1) / speed)

	local colorPos = "|cff20ff20"
	local colorNeg = "|cffff2020"
	local text

	if totalBonus < 0.1 and totalBonus > -0.1 then
		totalBonus = 0.0
	end

	if totalBonus == 0 then
		text = format("%.1f", damagePerSecond)
	else
		local color
		if totalBonus > 0 then
			color = colorPos
		else
			color = colorNeg
		end
		text = color..format("%.1f", damagePerSecond).."|r"
	end

	if offhandSpeed then
		minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg
		maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg

		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent
		local offhandDamagePerSecond = (max(offhandFullDamage, 1) / offhandSpeed)
		local offhandTotalBonus = (offhandFullDamage - offhandBaseDamage)

		if offhandTotalBonus < 0.1 and offhandTotalBonus > -0.1 then
			offhandTotalBonus = 0.0
		end
		local separator = " / "
		if damagePerSecond > 1000 and offhandDamagePerSecond > 1000 then
			separator = "/"
		end
		if offhandTotalBonus == 0 then
			text = text..separator..format("%.1f", offhandDamagePerSecond)
		else
			local color
			if offhandTotalBonus > 0 then
				color = colorPos
			else
				color = colorNeg
			end
			text = text..separator..color..format("%.1f", offhandDamagePerSecond).."|r"
		end
	end

	_G[statFrame:GetName().."StatText"]:SetText(text)
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..DAMAGE_PER_SECOND..FONT_COLOR_CODE_CLOSE
	statFrame:Show()
end

function ECF:SetAttackSpeed(statFrame, unit)
	local speed, offhandSpeed = UnitAttackSpeed(unit)
	speed = format("%.2f", speed)
	if offhandSpeed then
		offhandSpeed = format("%.2f", offhandSpeed)
	end
	local text;
	if offhandSpeed then
		text = speed.." / "..offhandSpeed
	else
		text = speed
	end

	_G[statFrame:GetName().."Label"]:SetText(SPEED..":")
	_G[statFrame:GetName().."StatText"]:SetText(text)

	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..ATTACK_SPEED_COLON.." "..text..FONT_COLOR_CODE_CLOSE;
	-- statFrame.tooltip2 = format(CR_HASTE_RATING_TOOLTIP, GetCombatRating(CR_HASTE_MELEE), GetCombatRatingBonus(CR_HASTE_MELEE));
	statFrame:Show()
end

function ECF:SetAttackPower(statFrame, unit)
	local base, posBuff, negBuff = UnitAttackPower(unit)

	local label = _G[statFrame:GetName().."Label"]
	local text = _G[statFrame:GetName().."StatText"]

	label:SetText(ATTACK_POWER_COLON)

	PaperDollFormatStat(MELEE_ATTACK_POWER, base, posBuff, negBuff, statFrame, text)
	statFrame.tooltip2 = format(MELEE_ATTACK_POWER_TOOLTIP, max((base+posBuff+negBuff), 0)/ATTACK_POWER_MAGIC_NUMBER)
end

function ECF:SetDodge(statFrame, unit)
	local label = _G[statFrame:GetName().."Label"]
	local text = _G[statFrame:GetName().."StatText"]
	label:SetText(DODGE)

	local chance = GetDodgeChance()
	-- PaperDollFormatStat(CHANCE_TO_DODGE, nil, nil, nil, statFrame, text)
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..DODGE.." "..format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE
	-- statFrame.tooltip2 = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE))
	statFrame:Show()
end

function ECF:SetBlock(statFrame, unit)
	local label = _G[statFrame:GetName().."Label"]
	local text = _G[statFrame:GetName().."StatText"]
	label:SetText(BLOCK)

	local chance = GetBlockChance()
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..BLOCK.." "..format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE
	-- statFrame.tooltip2 = format(CR_BLOCK_TOOLTIP, GetCombatRating(CR_BLOCK), GetCombatRatingBonus(CR_BLOCK), GetShieldBlock())
	statFrame:Show()
end
--[[

function ECF:SetParry(statFrame, unit)
	if unit ~= "player" then statFrame:Hide() return end

	local chance = GetParryChance()
	PaperDollFrame_SetLabelAndText(statFrame, STAT_PARRY, chance, 1)
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format("%s", PARRY_CHANCE).." "..format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE
	statFrame.tooltip2 = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY))
	statFrame:Show()
end
]]

local function OnEnter()
	if not this.tooltip then return end

	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	GameTooltip:SetText(this.tooltip)
	if this.tooltip2 then
		GameTooltip:AddLine(this.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
	end
	GameTooltip:Show()
end

function PaperDollFrame_CollapseStatCategory(categoryFrame)
	if not categoryFrame.collapsed then
		categoryFrame.collapsed = true
		E:SetTemplate(_G[categoryFrame:GetName().."Toolbar"], "NoBackdrop")
		local index = 1
		while _G[categoryFrame:GetName().."Stat"..index] do
			_G[categoryFrame:GetName().."Stat"..index]:Hide()
			index = index + 1
		end
		categoryFrame:SetHeight(18)
		ECF:PaperDollFrame_UpdateStatScrollChildHeight()
	end
end

function PaperDollFrame_ExpandStatCategory(categoryFrame)
	if categoryFrame.collapsed then
		categoryFrame.collapsed = false
		E:SetTemplate(_G[categoryFrame:GetName().."Toolbar"], "Default", true)
		ECF:PaperDollFrame_UpdateStatCategory(categoryFrame)
		ECF:PaperDollFrame_UpdateStatScrollChildHeight()
	end
end

function ECF:PaperDollFrame_UpdateStatCategory(categoryFrame)
	if not categoryFrame.Category then categoryFrame:Hide() return end

	local categoryInfo = PAPERDOLL_STATCATEGORIES[categoryFrame.Category]
	if categoryInfo == PAPERDOLL_STATCATEGORIES["RESISTANCE"] then
		categoryFrame.NameText:SetText(L["Resistance"])
	elseif categoryInfo == PAPERDOLL_STATCATEGORIES["ITEM_LEVEL"] then
		if PersonalGearScore then
			categoryFrame.NameText:SetText("Gear Score")
		else
			categoryFrame.NameText:SetText(L["Item Level"])
		end
	elseif categoryInfo == PAPERDOLL_STATCATEGORIES["BASE_STATS"] then
		categoryFrame.NameText:SetText(L["Base Stats"])
	elseif categoryInfo == PAPERDOLL_STATCATEGORIES["MELEE_COMBAT"] then
		categoryFrame.NameText:SetText(L["Melee"])
	elseif categoryInfo == PAPERDOLL_STATCATEGORIES["DEFENSES"] then
		categoryFrame.NameText:SetText(L["Defenses"])
	elseif categoryInfo == PAPERDOLL_STATCATEGORIES["RANGED_COMBAT"] then
		categoryFrame.NameText:SetText(INVTYPE_RANGED)
	else
		categoryFrame.NameText:SetText(L[categoryFrame.Category])
	end

	if categoryFrame.collapsed then return end

	local totalHeight = categoryFrame.NameText:GetHeight() + 10
	local numVisible = 0
	if categoryInfo then
		local prevStatFrame = nil
		for index, stat in next, categoryInfo.stats do
			local statInfo = PAPERDOLL_STATINFO[stat]
			if statInfo then
				local statFrame = _G[categoryFrame:GetName().."Stat"..numVisible + 1]
				if not statFrame then
					statFrame = CreateFrame("FRAME", categoryFrame:GetName().."Stat"..numVisible + 1, categoryFrame, "CharacterStatFrameTemplate")
					if prevStatFrame then
						statFrame:SetPoint("TOPLEFT", prevStatFrame, "BOTTOMLEFT", 0, 0)
						statFrame:SetPoint("TOPRIGHT", prevStatFrame, "BOTTOMRIGHT", 0, 0)
					end
				end
				statFrame:Show()

				if stat == "ITEM_LEVEL" then
					E:Height(statFrame, 30)
					local label = _G[statFrame:GetName().."Label"]
					label:ClearAllPoints()
					label:SetPoint("CENTER", 0, 0)
					E:Size(label, 187, 30)
					E:FontTemplate(label, nil, 20)
					label:SetJustifyH("CENTER")
					_G[statFrame:GetName().."StatText"]:SetText("")

					if statFrame.leftGrad then
						statFrame.leftGrad:Show()
						statFrame.rightGrad:Show()
					end
				else
					if statFrame:GetHeight() == 30 then
						E:Height(statFrame, 15)
						local label = _G[statFrame:GetName().."Label"]
						label:ClearAllPoints()
						label:SetPoint("LEFT", 7, 0)
						E:Size(label, 122, 15)
						E:FontTemplate(label)
						label:SetJustifyH("LEFT")
						label:SetTextColor(1, 0.82, 0)

						if statFrame.leftGrad then
							statFrame.leftGrad:Hide()
							statFrame.rightGrad:Hide()
						end
					end
				end

				if statInfo.updateFunc2 then
					statFrame:SetScript("OnEnter", OnEnter)
					statFrame:SetScript("OnEnter", statInfo.updateFunc2)
				else
					statFrame:SetScript("OnEnter", OnEnter)
				end
				statFrame.tooltip = nil
				statFrame.tooltip2 = nil
				statFrame.UpdateTooltip = nil
				statFrame:SetScript("OnUpdate", nil)
				statInfo.updateFunc(statFrame, CharacterStatsPane.unit)
				if statFrame:IsShown() then
					numVisible = numVisible + 1
					totalHeight = totalHeight + statFrame:GetHeight()
					prevStatFrame = statFrame

					if GameTooltip:GetParent() == statFrame then
						statFrame:GetScript("OnEnter")(statFrame)
					end
				end
			end
		end
	end

	for index = 1, numVisible do
		if mod(index, 2) == 0 or categoryInfo == PAPERDOLL_STATCATEGORIES["ITEM_LEVEL"] then
			local statFrame = _G[categoryFrame:GetName().."Stat"..index]
			if not statFrame.leftGrad then
				statFrame.leftGrad = statFrame:CreateTexture(nil, "BACKGROUND")
				statFrame.leftGrad:SetWidth(80)
				statFrame.leftGrad:SetHeight(statFrame:GetHeight())
				statFrame.leftGrad:SetPoint("LEFT", statFrame, "CENTER")
				statFrame.leftGrad:SetTexture(E.media.blankTex)
				statFrame.leftGrad:SetGradientAlpha("Horizontal", 0.8,0.8,0.8,0.35, 0.8,0.8,0.8,0)

				statFrame.rightGrad = statFrame:CreateTexture(nil, "BACKGROUND")
				statFrame.rightGrad:SetWidth(80)
				statFrame.rightGrad:SetHeight(statFrame:GetHeight())
				statFrame.rightGrad:SetPoint("RIGHT", statFrame, "CENTER")
				statFrame.rightGrad:SetTexture(E.media.blankTex)
				statFrame.rightGrad:SetGradientAlpha("Horizontal", 0.8,0.8,0.8,0, 0.8,0.8,0.8,0.35)
  			end
		end
	end

	local index = numVisible + 1
	while _G[categoryFrame:GetName().."Stat"..index] do
		_G[categoryFrame:GetName().."Stat"..index]:Hide()
		index = index + 1
	end

	categoryFrame:SetHeight(totalHeight)
end

function ECF:PaperDollFrame_UpdateStats()
	local index = 1
	while _G["CharacterStatsPaneCategory"..index] do
		self:PaperDollFrame_UpdateStatCategory(_G["CharacterStatsPaneCategory"..index])
		index = index + 1
	end
	self:PaperDollFrame_UpdateStatScrollChildHeight()
end

function ECF:PaperDollFrame_UpdateStatScrollChildHeight()
	local index = 1
	local totalHeight = 0
	while _G["CharacterStatsPaneCategory"..index] do
		if _G["CharacterStatsPaneCategory"..index]:IsShown() then
			totalHeight = totalHeight + _G["CharacterStatsPaneCategory"..index]:GetHeight() + 6
		end
		index = index + 1
	end
	CharacterStatsPaneScrollChild:SetHeight(totalHeight + 10 -(CharacterStatsPane.initialOffsetY or 0))
end

function ECF:PaperDoll_FindCategoryById(id)
	for categoryName, category in pairs(PAPERDOLL_STATCATEGORIES) do
		if category.id == id then
			return categoryName
		end
	end
	return nil
end

function ECF:PaperDoll_InitStatCategories(defaultOrder, orderData, collapsedData, unit)
	local order = defaultOrder

	local orderString = orderData
	local savedOrder = {}
	if orderString and orderString ~= "" then
		for i in gmatch(orderString, "%d+,?") do
			i = gsub(i, ",", "")
			i = tonumber(i)
			if i then
				local categoryName = self:PaperDoll_FindCategoryById(i)
				if categoryName then
					tinsert(savedOrder, categoryName)
				end
			end
		end

		local valid = true
		if getn(savedOrder) == getn(defaultOrder) then
			for i, category1 in next, defaultOrder do
				local found = false
				for j, category2 in next, savedOrder do
					if category1 == category2 then
						found = true
						break
					end
				end
				if not found then
					valid = false
					break
				end
			end
		else
			valid = false
		end

		if valid then
			order = savedOrder
		else
			orderData = ""
		end
	end

	wipe(StatCategoryFrames)
	for index = 1, getn(order) do
		local frame = _G["CharacterStatsPaneCategory"..index]
		assert(frame)
		tinsert(StatCategoryFrames, frame)
		frame.Category = order[index]
		frame:Show()

		local categoryInfo = PAPERDOLL_STATCATEGORIES[frame.Category]
		if categoryInfo and collapsedData[frame.Category] then
			PaperDollFrame_CollapseStatCategory(frame)
		else
			PaperDollFrame_ExpandStatCategory(frame)
		end
	end

	local index = getn(order) + 1
	while _G["CharacterStatsPaneCategory"..index] do
		_G["CharacterStatsPaneCategory"..index]:Hide()
		_G["CharacterStatsPaneCategory"..index].Category = nil
		index = index + 1
	end

	CharacterStatsPane.defaultOrder = defaultOrder
	CharacterStatsPane.orderData = orderData
	CharacterStatsPane.collapsedData = collapsedData
	CharacterStatsPane.unit = unit

	self:PaperDoll_UpdateCategoryPositions()
	self:PaperDollFrame_UpdateStats()
end

function PaperDoll_SaveStatCategoryOrder()
	if CharacterStatsPane.defaultOrder and getn(CharacterStatsPane.defaultOrder) == getn(StatCategoryFrames) then
		local same = true
		for index = 1, getn(StatCategoryFrames) do
			if StatCategoryFrames[index].Category ~= CharacterStatsPane.defaultOrder[index] then
				same = false
				break
			end
		end
		if same then
			E.db.enhanced.character[CharacterStatsPane.unit].orderName = ""
			return
		end
	end

	local string = ""
	for index = 1, getn(StatCategoryFrames) do
		if index ~= getn(StatCategoryFrames) then
			string = string..PAPERDOLL_STATCATEGORIES[StatCategoryFrames[index].Category].id..","
		else
			string = string..PAPERDOLL_STATCATEGORIES[StatCategoryFrames[index].Category].id
		end
	end
	E.db.enhanced.character[CharacterStatsPane.unit].orderName = string
end

function ECF:PaperDoll_UpdateCategoryPositions()
	local prevFrame = nil
	for index = 1, getn(StatCategoryFrames) do
		local frame = StatCategoryFrames[index]
		frame:ClearAllPoints()
	end

	for index = 1, getn(StatCategoryFrames) do
		local frame = StatCategoryFrames[index]

		local xOffset = 0
		if frame == MOVING_STAT_CATEGORY then
			xOffset = STATCATEGORY_MOVING_INDENT
		elseif prevFrame and prevFrame == MOVING_STAT_CATEGORY then
			xOffset = -STATCATEGORY_MOVING_INDENT
		end

		if prevFrame then
			frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT", 0 + xOffset, -6)
		else
			frame:SetPoint("TOPLEFT", 1 + xOffset, -6 + (CharacterStatsPane.initialOffsetY or 0))
		end
		prevFrame = frame
	end
end

function PaperDoll_MoveCategoryUp(self)
	for index = 2, getn(StatCategoryFrames) do
		if StatCategoryFrames[index] == self then
			tremove(StatCategoryFrames, index)
			tinsert(StatCategoryFrames, index-1, self)
			break
		end
	end

	ECF:PaperDoll_UpdateCategoryPositions()
	PaperDoll_SaveStatCategoryOrder()
end

function PaperDoll_MoveCategoryDown(self)
	for index = 1, getn(StatCategoryFrames) - 1 do
		if StatCategoryFrames[index] == self then
			tremove(StatCategoryFrames, index)
			tinsert(StatCategoryFrames, index + 1, self)
			break
		end
	end
	ECF:PaperDoll_UpdateCategoryPositions()
	PaperDoll_SaveStatCategoryOrder()
end

function PaperDollStatCategory_OnDragUpdate(self)
	local _, cursorY = GetCursorPosition()
	cursorY = cursorY * GetScreenHeightScale()

	local myIndex = nil
	local insertIndex = nil
	local closestPos

	for index = 1, getn(StatCategoryFrames) + 1 do
		if StatCategoryFrames[index] == this then
			myIndex = index
		end

		local frameY
		if index <= getn(StatCategoryFrames) then
			frameY = StatCategoryFrames[index]:GetTop()
		else
			frameY = StatCategoryFrames[getn(StatCategoryFrames)]:GetBottom()
		end
		frameY = frameY - 8
		if myIndex and index > myIndex then
			frameY = frameY + this:GetHeight()
		end
		if not closestPos or abs(cursorY - frameY)<closestPos then
			insertIndex = index
			closestPos = abs(cursorY-frameY)
		end
	end

	if insertIndex > myIndex then
		insertIndex = insertIndex - 1
	end

	if myIndex ~= insertIndex then
		tremove(StatCategoryFrames, myIndex)
		tinsert(StatCategoryFrames, insertIndex, this)
		ECF:PaperDoll_UpdateCategoryPositions()
	end
end

function PaperDollStatCategory_OnDragStart(self)
	MOVING_STAT_CATEGORY = self
	ECF:PaperDoll_UpdateCategoryPositions()
	GameTooltip:Hide()
	self:SetScript("OnUpdate", PaperDollStatCategory_OnDragUpdate)

	for i, frame in next, StatCategoryFrames do
		if frame ~= self then
			UIFrameFadeIn(frame, 0.2, 1, 0.6)
		end
	end
end

function PaperDollStatCategory_OnDragStop(self)
	MOVING_STAT_CATEGORY = nil
	ECF:PaperDoll_UpdateCategoryPositions()
	self:SetScript("OnUpdate", nil)

	for i, frame in next, StatCategoryFrames do
		if frame ~= self then
			UIFrameFadeOut(frame, 0.2, 0.6, 1)
		end
	end
	PaperDoll_SaveStatCategoryOrder()
end

function ECF:UpdateCharacterModelFrame()
	if E.db.enhanced.character.background then
		CharacterModelFrame.backdrop:Show()

		local _, fileName = UnitRace("player")

		CharacterModelFrame.textureTopLeft:Show()
		CharacterModelFrame.textureTopLeft:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\Media\\Textures\\backgrounds\\"..lower(fileName).."_1.blp")
		CharacterModelFrame.textureTopLeft:SetDesaturated(true)
		CharacterModelFrame.textureTopRight:Show()
		CharacterModelFrame.textureTopRight:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\Media\\Textures\\backgrounds\\"..lower(fileName).."_2.blp")
		CharacterModelFrame.textureTopRight:SetDesaturated(true)
		CharacterModelFrame.textureBotLeft:Show()
		CharacterModelFrame.textureBotLeft:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\Media\\Textures\\backgrounds\\"..lower(fileName).."_3.blp")
		CharacterModelFrame.textureBotLeft:SetDesaturated(true)
		CharacterModelFrame.textureBotRight:Show()
		CharacterModelFrame.textureBotRight:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\Media\\Textures\\backgrounds\\"..lower(fileName).."_4.blp")
		CharacterModelFrame.textureBotRight:SetDesaturated(true)

		CharacterModelFrame.backgroundOverlay:Show()
		CharacterModelFrame.backgroundOverlay:SetTexture(0, 0, 0)

		if strupper(fileName) == "SCOURGE" then
			CharacterModelFrame.backgroundOverlay:SetAlpha(0.1)
		elseif strupper(fileName) == "BLOODELF" or strupper(fileName) == "NIGHTELF" then
			CharacterModelFrame.backgroundOverlay:SetAlpha(0.3)
		elseif strupper(fileName) == "TROLL" or strupper(fileName) == "ORC" then
			CharacterModelFrame.backgroundOverlay:SetAlpha(0.4)
		else
			CharacterModelFrame.backgroundOverlay:SetAlpha(0.5)
		end
	else
		CharacterModelFrame.backdrop:Hide()
		CharacterModelFrame.textureTopLeft:Hide()
		CharacterModelFrame.textureTopRight:Hide()
		CharacterModelFrame.textureBotLeft:Hide()
		CharacterModelFrame.textureBotRight:Hide()
		CharacterModelFrame.backgroundOverlay:Hide()
	end
end

function ECF:UpdateInspectModelFrame()
	if E.db.enhanced.character.inspectBackground then
		InspectModelFrame.backdrop:Show()

		local _, fileName = UnitRace(InspectFrame.unit)

		InspectModelFrame.textureTopLeft:Show()
		InspectModelFrame.textureTopLeft:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\Media\\Textures\\backgrounds\\"..lower(fileName).."_1.blp")
		InspectModelFrame.textureTopLeft:SetDesaturated(true)
		InspectModelFrame.textureTopRight:Show()
		InspectModelFrame.textureTopRight:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\Media\\Textures\\backgrounds\\"..lower(fileName).."_2.blp")
		InspectModelFrame.textureTopRight:SetDesaturated(true)
		InspectModelFrame.textureBotLeft:Show()
		InspectModelFrame.textureBotLeft:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\Media\\Textures\\backgrounds\\"..lower(fileName).."_3.blp")
		InspectModelFrame.textureBotLeft:SetDesaturated(true)
		InspectModelFrame.textureBotRight:Show()
		InspectModelFrame.textureBotRight:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\Media\\Textures\\backgrounds\\"..lower(fileName).."_4.blp")
		InspectModelFrame.textureBotRight:SetDesaturated(true)

		InspectModelFrame.backgroundOverlay:Show()
		InspectModelFrame.backgroundOverlay:SetTexture(0, 0, 0)

		if strupper(fileName) == "SCOURGE" then
			InspectModelFrame.backgroundOverlay:SetAlpha(0.1)
		elseif strupper(fileName) == "BLOODELF" or strupper(fileName) == "NIGHTELF" then
			InspectModelFrame.backgroundOverlay:SetAlpha(0.3)
		elseif strupper(fileName) == "TROLL" or strupper(fileName) == "ORC" then
			InspectModelFrame.backgroundOverlay:SetAlpha(0.4)
		else
			InspectModelFrame.backgroundOverlay:SetAlpha(0.5)
		end
	else
		InspectModelFrame.backdrop:Hide()
		InspectModelFrame.textureTopLeft:Hide()
		InspectModelFrame.textureTopRight:Hide()
		InspectModelFrame.textureBotLeft:Hide()
		InspectModelFrame.textureBotRight:Hide()
		InspectModelFrame.backgroundOverlay:Hide()
	end
end

function ECF:UpdatePetModelFrame()
	if E.db.enhanced.character.petBackground then
		PetModelFrame.backdrop:Show()

		local _, playerClass = UnitClass("player")

		PetModelFrame.petPaperDollPetModelBg:Show()
		if playerClass == "HUNTER" then
			PetModelFrame.petPaperDollPetModelBg:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\Media\\Textures\\backgrounds\\petHunter.blp")
			PetModelFrame.backgroundOverlay:SetAlpha(0.3)
		elseif playerClass == "WARLOCK" then
			PetModelFrame.petPaperDollPetModelBg:SetTexture("Interface\\AddOns\\ElvUI_Enhanced\\Media\\Textures\\backgrounds\\petWarlock.blp")
			PetModelFrame.backgroundOverlay:SetAlpha(0.1)
		else
			PetModelFrame.petPaperDollPetModelBg:Hide()
		end
		PetModelFrame.petPaperDollPetModelBg:SetDesaturated(true)

		PetModelFrame.backgroundOverlay:Show()
		PetModelFrame.backgroundOverlay:SetTexture(0, 0, 0)
	else
		PetModelFrame.backdrop:Hide()
		PetModelFrame.petPaperDollPetModelBg:Hide()
		PetModelFrame.backgroundOverlay:Hide()
	end
end

function ECF:ADDON_LOADED()
	if arg1 ~= "Blizzard_InspectUI" then return end
	self:UnregisterEvent("ADDON_LOADED")

	E:CreateBackdrop(InspectModelFrame, "Default")
	E:Size(InspectModelFrame, 231, 320)
	E:Point(InspectModelFrame, "TOPLEFT", InspectPaperDollFrame, "TOPLEFT", 66, -78)

	local inspectSlots = {"Head", "Neck", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist", "Waist", "Legs", "Feet", "Finger0", "Finger1", "Trinket0", "Trinket1", "MainHand", "SecondaryHand", "Ranged"}
	for _, name in ipairs(inspectSlots) do
		_G[format("Inspect%sSlot", name)]:SetFrameLevel(InspectModelFrame:GetFrameLevel() + 3)
	end

	InspectModelFrame.textureTopLeft = InspectModelFrame:CreateTexture("$parentTextureTopLeft", "BACKGROUND")
	E:Point(InspectModelFrame.textureTopLeft, "TOPLEFT")
	E:Size(InspectModelFrame.textureTopLeft, 212, 244)
	InspectModelFrame.textureTopLeft:SetTexCoord(0.171875, 1, 0.0392156862745098, 1)

	InspectModelFrame.textureTopRight = InspectModelFrame:CreateTexture("$parentTextureTopRight", "BACKGROUND")
	E:Point(InspectModelFrame.textureTopRight, "TOPLEFT", InspectModelFrame.textureTopLeft, "TOPRIGHT")
	E:Size(InspectModelFrame.textureTopRight, 19, 244)
	InspectModelFrame.textureTopRight:SetTexCoord(0, 0.296875, 0.0392156862745098, 1)

	InspectModelFrame.textureBotLeft = InspectModelFrame:CreateTexture("$parentTextureBotLeft", "BACKGROUND")
	E:Point(InspectModelFrame.textureBotLeft, "TOPLEFT", InspectModelFrame.textureTopLeft, "BOTTOMLEFT")
	E:Size(InspectModelFrame.textureBotLeft, 212, 128)
	InspectModelFrame.textureBotLeft:SetTexCoord(0.171875, 1, 0, 1)

	InspectModelFrame.textureBotRight = InspectModelFrame:CreateTexture("$parentTextureBotRight", "BACKGROUND")
	E:Point(InspectModelFrame.textureBotRight, "TOPLEFT", InspectModelFrame.textureTopLeft, "BOTTOMRIGHT")
	E:Size(InspectModelFrame.textureBotRight, 19, 128)
	InspectModelFrame.textureBotRight:SetTexCoord(0, 0.296875, 0, 1)

	InspectModelFrame.backgroundOverlay = InspectModelFrame:CreateTexture("$parentBackgroundOverlay", "BORDER")
	E:Point(InspectModelFrame.backgroundOverlay, "TOPLEFT", InspectModelFrame.textureTopLeft)
	E:Point(InspectModelFrame.backgroundOverlay, "BOTTOMRIGHT", InspectModelFrame.textureBotRight, 0, 52)

	self:SecureHook("InspectPaperDollFrame_OnShow", "UpdateInspectModelFrame")
end

local slots = {
	["HeadSlot"] = "INVTYPE_HEAD",
	["NeckSlot"] = "INVTYPE_NECK",
	["ShoulderSlot"] = "INVTYPE_SHOULDER",
	["BackSlot"] = "INVTYPE_CLOAK",
	["ChestSlot"] = "INVTYPE_ROBE",
	["WristSlot"] = "INVTYPE_WRIST",
	["HandsSlot"] = "INVTYPE_HAND",
	["WaistSlot"] = "INVTYPE_WAIST",
	["LegsSlot"] = "INVTYPE_LEGS",
	["FeetSlot"] = "INVTYPE_FEET",
	["Finger0Slot"] = "INVTYPE_FINGER",
	["Finger1Slot"] = "INVTYPE_FINGER",
	["Trinket0Slot"] = "INVTYPE_TRINKET",
	["Trinket1Slot"] = "INVTYPE_TRINKET",
	["MainHandSlot"] = "INVTYPE_WEAPONMAINHAND",
	["SecondaryHandSlot"] = "INVTYPE_HOLDABLE",
	["RangedSlot"] = "INVTYPE_RANGEDRIGHT",
}

local bagsTable = {}
function GetAverageItemLevel()
	local itemLink, itemLevel, itemEquipLoc
	local total, totalBag, item, bagItem, isBagItemLevel = 0, 0, 0, 0

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			itemLink = GetContainerItemLink(bag, slot)
			if itemLink then
				_, _, _, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(tonumber(string.match(itemLink, "item:(%d+)")))
				if itemEquipLoc and itemEquipLoc ~= "" then
					if not bagsTable[itemEquipLoc] then
						bagsTable[itemEquipLoc] = itemLevel
					else
						if itemLevel > bagsTable[itemEquipLoc] then
							bagsTable[itemEquipLoc] = itemLevel
						end
					end
				end
			end
		end
	end

	for slotName, itemLoc in pairs(slots) do
		itemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotName))
		if itemLink then
			_, _, _, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(tonumber(string.match(itemLink, "item:(%d+)")))
			if itemLevel and itemLevel > 0 then
				item = item + 1
				bagItem = bagItem + 1

				isBagItemLevel = bagsTable[itemEquipLoc]
				if isBagItemLevel and isBagItemLevel > itemLevel then
					totalBag = totalBag + isBagItemLevel
				else
					totalBag = totalBag + itemLevel
				end

				total = total + itemLevel
			end
		else
			isBagItemLevel = bagsTable[itemLoc]
			if isBagItemLevel then
				bagItem = bagItem + 1
				totalBag = totalBag + isBagItemLevel
			end
		end
	end

	wipe(bagsTable)

	if total < 1 then
		return 0, 0
	end

	return (totalBag / bagItem), (total / item)
end

function GetItemLevelColor(unit)
	if not unit then unit = "player" end

	local i = 0
	local sumR, sumG, sumB = 0, 0, 0
	for slotName, _ in pairs(slots) do
		local slotID = GetInventorySlotInfo(slotName)
		if GetInventoryItemTexture(unit, slotID) then
			local itemLink = GetInventoryItemLink(unit, slotID)
			if itemLink then
				local _, _, quality = GetItemInfo(tonumber(string.match(itemLink, "item:(%d+)")))
				if quality then
					i = i + 1
					local r, g, b = GetItemQualityColor(quality)
					sumR = sumR + r
					sumG = sumG + g
					sumB = sumB + b
				end
			end
		end
	end

	if i > 0 then
		return (sumR / i), (sumG / i), (sumB / i)
	else
		return 1, 1, 1
	end
end

function ECF:Initialize()
	if not E.private.enhanced.character.enable then return end

	UIPanelWindows["CharacterFrame"] = { area = "doublewide",	pushable = 0 , whileDead = 1}

	if PersonalGearScore then
		PersonalGearScore:Hide()
	end
	if GearScore2 then
		GearScore2:Hide()
	end

	E:Kill(CharacterAttributesFrame)
	E:Kill(CharacterResistanceFrame)

	CharacterNameFrame:ClearAllPoints()
	CharacterNameFrame:SetPoint("TOP", CharacterFrame, -10, -25)

	local expandButton = CreateFrame("Button", "CharacterFrameExpandButton", CharacterFrame)
	E:Size(expandButton, 25)
	expandButton:SetPoint("BOTTOMLEFT", CharacterFrame, 315, 84)
	expandButton:SetFrameLevel(CharacterFrame:GetFrameLevel() + 5)
	S:HandleNextPrevButton(CharacterFrameExpandButton)

	expandButton:SetScript("OnClick", function()
		if CharacterFrame.Expanded then
			E.db.enhanced.character.collapsed = true
			ECF:CharacterFrame_Collapse()
			PlaySound("igCharacterInfoClose")
		else
			E.db.enhanced.character.collapsed = false
			ECF:CharacterFrame_Expand()
			PlaySound("igCharacterInfoOpen")
		end

		if GameTooltip:GetParent() == this then
			this:GetScript("OnEnter")(this)
		end
	end)

	expandButton:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		if CharacterFrame.Expanded then
			GameTooltip:SetText(this.collapseTooltip)
		else
			GameTooltip:SetText(this.expandTooltip)
		end
	end)

	expandButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	local statsPane = CreateFrame("ScrollFrame", "CharacterStatsPane", CharacterFrame, "UIPanelScrollFrameTemplate")
	statsPane:Show()
	E:Height(statsPane, 354)
	statsPane.buttons = {}

	CharacterStatsPaneScrollBar:ClearAllPoints()
	CharacterStatsPaneScrollBar:SetPoint("TOPLEFT", statsPane, "TOPRIGHT", 3, -16)
	CharacterStatsPaneScrollBar:SetPoint("BOTTOMLEFT", statsPane, "BOTTOMRIGHT", 3, 16)
	S:HandleScrollBar(CharacterStatsPaneScrollBar)

	CharacterStatsPaneScrollBar.scrollStep = 50
	statsPane.scrollBarHideable = 1
	statsPane.offset = 0

	local statsPaneScrollChild = CreateFrame("Frame", "CharacterStatsPaneScrollChild", statsPane)
	E:Size(statsPaneScrollChild, 170, 0)
	statsPaneScrollChild:SetPoint("TOPLEFT", 0, 0)

	for i = 1, 8 do
		local button = CreateFrame("Frame", "CharacterStatsPaneCategory"..i, statsPaneScrollChild, "StatGroupTemplate")
		E:SetTemplate(button.Toolbar, "Default", true)
		button.NameText:SetParent(button.Toolbar)
		button.NameText:ClearAllPoints()
		button.NameText:SetPoint("CENTER", button.Toolbar)
		statsPane.buttons[i] = button
	end

	statsPane:SetScrollChild(statsPaneScrollChild)

	local oldScrollBarShow = CharacterStatsPaneScrollBar.Show
	CharacterStatsPaneScrollBar.Show = function(self)
		E:Width(statsPane, 177)
		E:Point(statsPane, "TOPRIGHT", -57, -75)
		for _, button in next, statsPane.buttons do
			E:Width(button, 177)
			E:Width(button.Toolbar, 150 - 18)
		end
		oldScrollBarShow(self)
	end

	local oldScrollBarHide = CharacterStatsPaneScrollBar.Hide
	CharacterStatsPaneScrollBar.Hide = function(self)
		E:Width(statsPane, 177 + 18)
		E:Point(statsPane, "TOPRIGHT", -39, -75)
		for _, button in next, statsPane.buttons do
			E:Width(button, 177 + 18)
			E:Width(button.Toolbar, 150)
		end
		oldScrollBarHide(self)
	end

	E:Width(statsPane, 177)
	E:Point(statsPane, "TOPRIGHT", -39, -75)
	for _, button in next, statsPane.buttons do
		E:Width(button, 177)
		E:Width(button.Toolbar, 150 - 18)
	end

	E:CreateBackdrop(CharacterModelFrame, "Default")
	E:Size(CharacterModelFrame, 231, 320)
	E:Point(CharacterModelFrame, "TOPLEFT", PaperDollFrame, "TOPLEFT", 66, -78)

	for _, name in ipairs(slotName) do
		_G[format("Character%sSlot", name)]:SetFrameLevel(CharacterModelFrame:GetFrameLevel() + 3)
	end

	CharacterModelFrame.textureTopLeft = CharacterModelFrame:CreateTexture("$parentTextureTopLeft", "BACKGROUND")
	E:Size(CharacterModelFrame.textureTopLeft, 212, 244)
	E:Point(CharacterModelFrame.textureTopLeft, "TOPLEFT")
	CharacterModelFrame.textureTopLeft:SetTexCoord(0.171875, 1, 0.0392156862745098, 1)

	CharacterModelFrame.textureTopRight = CharacterModelFrame:CreateTexture("$parentTextureTopRight", "BACKGROUND")
	E:Size(CharacterModelFrame.textureTopRight, 19, 244)
	E:Point(CharacterModelFrame.textureTopRight, "TOPLEFT", CharacterModelFrame.textureTopLeft, "TOPRIGHT")
	CharacterModelFrame.textureTopRight:SetTexCoord(0, 0.296875, 0.0392156862745098, 1)

	CharacterModelFrame.textureBotLeft = CharacterModelFrame:CreateTexture("$parentTextureBotLeft", "BACKGROUND")
	E:Size(CharacterModelFrame.textureBotLeft, 212, 128)
	E:Point(CharacterModelFrame.textureBotLeft, "TOPLEFT", CharacterModelFrame.textureTopLeft, "BOTTOMLEFT")
	CharacterModelFrame.textureBotLeft:SetTexCoord(0.171875, 1, 0, 1)

	CharacterModelFrame.textureBotRight = CharacterModelFrame:CreateTexture("$parentTextureBotRight", "BACKGROUND")
	E:Size(CharacterModelFrame.textureBotRight, 19, 128)
	E:Point(CharacterModelFrame.textureBotRight, "TOPLEFT", CharacterModelFrame.textureTopLeft, "BOTTOMRIGHT")
	CharacterModelFrame.textureBotRight:SetTexCoord(0, 0.296875, 0, 1)

	CharacterModelFrame.backgroundOverlay = CharacterModelFrame:CreateTexture("$parentBackgroundOverlay", "BORDER")
	E:Point(CharacterModelFrame.backgroundOverlay, "TOPLEFT", CharacterModelFrame.textureTopLeft)
	E:Point(CharacterModelFrame.backgroundOverlay, "BOTTOMRIGHT", CharacterModelFrame.textureBotRight, 0, 52)

	self:UpdateCharacterModelFrame()

	self:PaperDoll_InitStatCategories(PAPERDOLL_STATCATEGORY_DEFAULTORDER, E.db.enhanced.character.player.orderName, E.db.enhanced.character.player.collapsedName, "player")

	PaperDollFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
	HookScript(PaperDollFrame, "OnEvent", function()
		if not this:IsVisible() then return end

		if arg1 and arg1 == "player" then
			if event == "UNIT_LEVEL" then
				ECF:PaperDollFrame_SetLevel()
			elseif event == "UNIT_DAMAGE" or event == "PLAYER_DAMAGE_DONE_MODS" or event == "UNIT_ATTACK_SPEED" or event == "UNIT_RANGEDDAMAGE" or event == "UNIT_ATTACK"
				or event == "UNIT_RESISTANCES" or event == "UNIT_STATS" or event == "UNIT_ATTACK_POWER" or event == "UNIT_RANGED_ATTACK_POWER" then
				ECF:PaperDollFrame_UpdateStats()
			end
		end

		if event == "PLAYER_TALENT_UPDATE" then
			ECF:PaperDollFrame_SetLevel()
		end
	end)

	HookScript(PaperDollFrame, "OnShow", function()
		if E.db.enhanced.character.collapsed then
			ECF:CharacterFrame_Collapse()
		else
			ECF:CharacterFrame_Expand()
		end

		ECF:PaperDoll_InitStatCategories(PAPERDOLL_STATCATEGORY_DEFAULTORDER, E.db.enhanced.character.player.orderName, E.db.enhanced.character.player.collapsedName, "player")
		CharacterFrameExpandButton:Show()
		CharacterFrameExpandButton.collapseTooltip = L["Hide Character Information"]
		CharacterFrameExpandButton.expandTooltip = L["Show Character Information"]
		ECF:PaperDollFrame_SetLevel()
	end)

	HookScript(PaperDollFrame, "OnHide", function()
		if not this:IsShown() then
			ECF:CharacterFrame_Collapse()
		end
		CharacterFrameExpandButton:Hide()
	end)

	if E.db.enhanced.character.collapsed then
		self:CharacterFrame_Collapse()
	else
		self:CharacterFrame_Expand()
	end

	PetNameText:SetPoint("CENTER", CharacterFrame, 0, 200)
	PetLevelText:SetPoint("TOP", CharacterFrame, 0, -20)
	PetPaperDollPetInfo:SetPoint("TOPLEFT", 25, -78)

	PetTrainingPointText:ClearAllPoints()
	PetTrainingPointText:SetPoint("BOTTOMRIGHT", PetModelFrame, "BOTTOMRIGHT", -31, -26)
	PetTrainingPointLabel:SetPoint("RIGHT", PetTrainingPointText, "LEFT", -5, 1)

	E:Kill(PetPaperDollCloseButton)
	E:Kill(PetAttributesFrame)
	E:Kill(PetResistanceFrame)

	E:CreateBackdrop(PetModelFrame, "Default")
	E:Size(PetModelFrame, 310, 320)

	PetModelFrame.petPaperDollPetModelBg = PetModelFrame:CreateTexture("$parentPetPaperDollPetModelBg", "BACKGROUND")
	E:Size(PetModelFrame.petPaperDollPetModelBg, 494, 461)
	E:Point(PetModelFrame.petPaperDollPetModelBg, "TOPLEFT")

	PetModelFrame.backgroundOverlay = PetModelFrame:CreateTexture("$parentBackgroundOverlay", "BORDER")
	PetModelFrame.backgroundOverlay:SetAllPoints()

	self:UpdatePetModelFrame()

	HookScript(PetPaperDollFrame, "OnShow", function()
		if E.db.enhanced.character.collapsed then
			ECF:CharacterFrame_Collapse()
		else
			ECF:CharacterFrame_Expand()
		end

		ECF:PaperDoll_InitStatCategories(PETPAPERDOLL_STATCATEGORY_DEFAULTORDER, E.db.enhanced.character.pet.orderName, E.db.enhanced.character.pet.collapsedName, "pet")

		CharacterFrameExpandButton:Show()
		CharacterFrameExpandButton.collapseTooltip = L["Hide Pet Information"]
		CharacterFrameExpandButton.expandTooltip = L["Show Pet Information"]

		ECF:PaperDollFrame_UpdateStats()
	end)

	HookScript(PetPaperDollFrame, "OnHide", function()
		if PaperDollFrame:IsShown() then return end
		ECF:CharacterFrame_Collapse()

		CharacterFrameExpandButton:Hide()
	end)

	self:PaperDoll_InitStatCategories(PETPAPERDOLL_STATCATEGORY_DEFAULTORDER, E.db.enhanced.character.pet.orderName, E.db.enhanced.character.pet.collapsedName, "pet")

	self:RegisterEvent("ADDON_LOADED")
end

local function InitializeCallback()
	ECF:Initialize()
end

E:RegisterModule(ECF:GetName(), InitializeCallback)