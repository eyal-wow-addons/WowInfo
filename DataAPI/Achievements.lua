local _, addon = ...
local Achievements = addon:NewObject("Achievements")

local ACHIEVEMENTUI_SUMMARYCATEGORIES = {92, 96, 97, 95, 168, 169, 201, 155, 15117, 15246}
local ACHIEVEMENTUI_GUILDSUMMARYCATEGORIES = {15088, 15077, 15078, 15079, 15080, 15089}

local COLLECTIONS_LABEL_FORMAT = "- %s: |cffffffff%d|r / |cff20ff20%d|r"
local PROGRESS_FORMAT = "%s / %s"

-- I've checked Blizzard's code and it seems like GetNextAchievement returns completed as the 2nd return value
-- however, it seems to returns nil for achievements I've completed with one faction but not the other,
-- getting the progress from GetAchievementCriteriaInfo and compare the progress seems to get the correct results.
local function GetNextAchievementInfo(achievementID)
    local nextID = GetNextAchievement(achievementID)
    if nextID then
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
    else
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

do
    local MOUNTS_BASE_ACHIEVEMENT_ID = 2143 -- Leading the Cavalry

    function Achievements:GetMountAchievementString()
        local achievementName, achievementCurrAmount, achievementReqAmount = FindAchievementInfo(MOUNTS_BASE_ACHIEVEMENT_ID)
        if achievementName then
            return COLLECTIONS_LABEL_FORMAT:format(achievementName, achievementCurrAmount, achievementReqAmount)
        end
        return nil
    end
end

do
    local PETS_BASE_ACHIEVEMENT_ID = 1017 -- Can I Keep Him?

    function Achievements:GetPetsAchievementString()
        local achievementName, achievementCurrAmount, achievementReqAmount = FindAchievementInfo(PETS_BASE_ACHIEVEMENT_ID)
        if achievementName then
            return COLLECTIONS_LABEL_FORMAT:format(achievementName, achievementCurrAmount, achievementReqAmount)
        end
        return nil
    end
end

do
    local TOYBOX_BASE_ACHIEVEMENT_ID = 9670 -- Toying Around

    function Achievements:GetToysAchievementString()
        local achievementName, achievementCurrAmount, achievementReqAmount = FindAchievementInfo(TOYBOX_BASE_ACHIEVEMENT_ID)
        if achievementName then
            return COLLECTIONS_LABEL_FORMAT:format(achievementName, achievementCurrAmount, achievementReqAmount)
        end
        return nil
    end
end

function Achievements:GetSummaryProgressString(guildOnly)
    local total, completed = GetNumCompletedAchievements(guildOnly)
    return ACHIEVEMENTS_COMPLETED, PROGRESS_FORMAT:format(BreakUpLargeNumbers(completed), BreakUpLargeNumbers(total))
end

function Achievements:IterableCategoriesSummaryInfo(guildOnly)
    local categories = guildOnly and ACHIEVEMENTUI_GUILDSUMMARYCATEGORIES or ACHIEVEMENTUI_SUMMARYCATEGORIES
    local i = 0
    local n = #categories
    return function()
        i = i + 1
        if i <= n then
            local categoryId = categories[i]
            local categoryName = GetCategoryInfo(categoryId)
            local total, completed = GetCategoryTotalNumAchievements(categoryId, guildOnly)
            return categoryName, PROGRESS_FORMAT:format(BreakUpLargeNumbers(completed), BreakUpLargeNumbers(total))
        end
    end
end


