local _, addon = ...

addon.PATTERNS = {
    PROGRESS1 = "%s / %s",
    PROGRESS2 = "%s (%s)"
}

do
	addon.CLASS_NAMES = {
		["Death Knight"]	= "DEATHKNIGHT",
		["Demon Hunter"]	= "DEMONHUNTER",
		["Druid"]		    = "DRUID",
		["Evoker"]		    = "EVOKER",
		["Hunter"]		    = "HUNTER",
		["Mage"]		    = "MAGE",
		["Monk"]		    = "MONK",
		["Paladin"]		    = "PALADIN",
		["Priest"]		    = "PRIEST",
		["Rogue"]		    = "ROGUE",
		["Shaman"]		    = "SHAMAN",
		["Warlock"]		    = "WARLOCK",
		["Warrior"]		    = "WARRIOR",
	}

	for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		if not addon.CLASS_NAMES[v] then
			addon.CLASS_NAMES[v] = k
		end
	end

	for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
		if not addon.CLASS_NAMES[v] then
			addon.CLASS_NAMES[v] = k
		end
	end
end