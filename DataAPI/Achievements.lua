local _, addon = ...
local Achievements = addon:NewObject("Achievements")

local ACHIEVEMENTUI_SUMMARYCATEGORIES = {92, 96, 97, 15522, 95, 168, 169, 201, 155, 15117, 15246}
local ACHIEVEMENTUI_GUILDSUMMARYCATEGORIES = {15088, 15077, 15078, 15079, 15080, 15089}

local DATA = {
    ["MOUNTS"] = {},
    ["PETS"] = {},
    ["TOYS"] = {},
    ["SUMMARY"] = {
        categoriesSummaryInfo = {}
    },
    ["GUILDSUMMARY"] = {
        categoriesSummaryInfo = {}
    },
}

-- I've checked Blizzard's code and it seems like GetNextAchievement returns completed as the 2nd return value
-- however, it seems to returns nil for achievements I've completed with one faction but not the other,
-- getting the progress from GetAchievementCriteriaInfo and compare the progress seems to get the correct results.
local function GetNextAchievementInfo(achievementID)
    local nextID = GetNextAchievement(achievementID)
    if nextID and GetAchievementNumCriteria(nextID) > 0 then
        local currAmount, reqAmount = select(4, GetAchievementCriteriaInfo(nextID, 1))
        local completed = currAmount == reqAmount
        local name
        if not completed then
            name = select(2, GetAchievementInfo(nextID))
        end
        return nextID, name, completed, currAmount, reqAmount
    end
    return nextID
end

local function FindAchievementInfo(baseAchievementID)
    local id = baseAchievementID
    local _, name, _, completed = GetAchievementInfo(id)
    local currAmount, reqAmount
    if completed then
        id, name, completed, currAmount, reqAmount = GetNextAchievementInfo(id)
        while id and completed do
            id, name, completed, currAmount, reqAmount = GetNextAchievementInfo(id)
        end
    elseif GetAchievementNumCriteria(id) > 0 then
        currAmount, reqAmount = select(4, GetAchievementCriteriaInfo(id, 1))
    end
    return name, currAmount, reqAmount
end

-- This is similar to AchievementFrame_GetCategoryTotalNumAchievements from Blizzard_AchievementUI
local function GetCategoryTotalNumAchievements(categoryId, guildOnly)
    local categories = guildOnly and GetGuildCategoryList() or GetCategoryList()

	-- Not recursive because we only have one deep and this saves time.
	local totalAchievements, totalCompleted = 0, 0;
	local numAchievements, numCompleted = GetCategoryNumAchievements(categoryId, true);
	totalAchievements = totalAchievements + numAchievements;
	totalCompleted = totalCompleted + numCompleted;

	for _, id in ipairs(categories) do
        local _, parentId = GetCategoryInfo(id);
		if parentId == categoryId then
			numAchievements, numCompleted = GetCategoryNumAchievements(id, true);
			totalAchievements = totalAchievements + numAchievements;
			totalCompleted = totalCompleted + numCompleted;
		end
	end

	return totalAchievements, totalCompleted;
end

local function CacheAchievementInfo(key, id)
    local name, currentAmount, reqAmount = FindAchievementInfo(id)
    if name then
        DATA[key].name = name
        DATA[key].currentAmount = currentAmount
        DATA[key].reqAmount = reqAmount
    else
        DATA[key].name = nil
        DATA[key].currentAmount = 0
        DATA[key].reqAmount = 0
    end
end

local function CacheAchievementsCategoriesSummaryInfo(guildOnly)
    local cacheKey = guildOnly and "GUILDSUMMARY" or "SUMMARY"
    local total, completed = GetNumCompletedAchievements(guildOnly)

    DATA[cacheKey].total = total
    DATA[cacheKey].completed = completed

    local categoriesSummaryInfo = DATA[cacheKey].categoriesSummaryInfo
    local categories = guildOnly and ACHIEVEMENTUI_GUILDSUMMARYCATEGORIES or ACHIEVEMENTUI_SUMMARYCATEGORIES
    local categoryId, categoryName
    
    for i = 1, #categories do
        categoryId = categories[i]
        categoryName = GetCategoryInfo(categoryId)
        total, completed = GetCategoryTotalNumAchievements(categoryId, guildOnly)
        categoriesSummaryInfo[i] = categoriesSummaryInfo[i] or {}
        categoriesSummaryInfo[i].name = categoryName
        categoriesSummaryInfo[i].total = total
        categoriesSummaryInfo[i].completed = completed
    end
end

local MOUNTS_BASE_ACHIEVEMENT_ID = 2143 -- Leading the Cavalry
local PETS_BASE_ACHIEVEMENT_ID = 1017 -- Can I Keep Him?
local TOYBOX_BASE_ACHIEVEMENT_ID = 9670 -- Toying Around

Achievements:RegisterEvents("PLAYER_LOGIN", "ACHIEVEMENT_EARNED", function()
    CacheAchievementInfo("MOUNTS", MOUNTS_BASE_ACHIEVEMENT_ID)
    CacheAchievementInfo("PETS", PETS_BASE_ACHIEVEMENT_ID)
    CacheAchievementInfo("TOYS", TOYBOX_BASE_ACHIEVEMENT_ID)
    CacheAchievementsCategoriesSummaryInfo()
    CacheAchievementsCategoriesSummaryInfo(true)
end)

function Achievements:GetMountAchievementInfo()
    return DATA["MOUNTS"].name, DATA["MOUNTS"].currentAmount, DATA["MOUNTS"].reqAmount
end

function Achievements:GetPetsAchievementInfo()
    return DATA["PETS"].name, DATA["PETS"].currentAmount, DATA["PETS"].reqAmount
end

function Achievements:GetToysAchievementInfo()
    return DATA["TOYS"].name, DATA["TOYS"].currentAmount, DATA["TOYS"].reqAmount
end

function Achievements:GetSummaryProgressInfo(guildOnly)
    local cacheKey = guildOnly and "GUILDSUMMARY" or "SUMMARY"
    return DATA[cacheKey].total, DATA[cacheKey].completed
end

function Achievements:IterableCategoriesSummaryInfo(guildOnly)
    local cacheKey = guildOnly and "GUILDSUMMARY" or "SUMMARY"
    local categoriesSummaryInfo = DATA[cacheKey].categoriesSummaryInfo
    local info
    local i = 0
    local n = #categoriesSummaryInfo
    return function()
        i = i + 1
        if i <= n then
            info = categoriesSummaryInfo[i]
            return info.name, info.total, info.completed
        end
    end
end