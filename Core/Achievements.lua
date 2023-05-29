local _, addon = ...
Achievements = {}
addon.Achievements = Achievements

local ACHIEVEMENT_LABEL_FORMAT = "- %s: |cffffffff%d|r / |cff20ff20%d|r"

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

do
    local MOUNTS_BASE_ACHIEVEMENT_ID = 2143 -- Leading the Cavalry

    function Achievements:GetMountAchievementString()
        local achievementName, achievementCurrAmount, achievementReqAmount = FindAchievementInfo(MOUNTS_BASE_ACHIEVEMENT_ID)
        if achievementName then
            return ACHIEVEMENT_LABEL_FORMAT:format(achievementName, achievementCurrAmount, achievementReqAmount)
        end
        return nil
    end
end

do
    local PETS_BASE_ACHIEVEMENT_ID = 1017 -- Can I Keep Him?

    function Achievements:GetPetsAchievementString()
        local achievementName, achievementCurrAmount, achievementReqAmount = FindAchievementInfo(PETS_BASE_ACHIEVEMENT_ID)
        if achievementName then
            return ACHIEVEMENT_LABEL_FORMAT:format(achievementName, achievementCurrAmount, achievementReqAmount)
        end
        return nil
    end
end

do
    local TOYBOX_BASE_ACHIEVEMENT_ID = 9670 -- Toying Around

    function Achievements:GetToysAchievementString()
        local achievementName, achievementCurrAmount, achievementReqAmount = FindAchievementInfo(TOYBOX_BASE_ACHIEVEMENT_ID)
        if achievementName then
            return ACHIEVEMENT_LABEL_FORMAT:format(achievementName, achievementCurrAmount, achievementReqAmount)
        end
        return nil
    end
end
