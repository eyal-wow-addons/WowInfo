local _, addon = ...
local Collections = addon:NewObject("Collections")

do
    local function GetNumMounts()
        local numCollectedMounts = 0
        local numMounts = C_MountJournal.GetNumMounts()

        if numMounts >= 1 then
            local hideOnChar, isCollected
            local mountIDs = C_MountJournal.GetMountIDs()
            for _, mountID in ipairs(mountIDs) do
                hideOnChar, isCollected = select(10, C_MountJournal.GetMountInfoByID(mountID))
                if isCollected and hideOnChar ~= true then
                    numCollectedMounts = numCollectedMounts + 1
                end
            end
        end

        return numMounts, numCollectedMounts
    end

    function Collections:GetTotalMounts()
        local _, numCollectedMounts = GetNumMounts()
        if numCollectedMounts > 0 then
            return numCollectedMounts
        end
        return nil
    end
end

function Collections:GetTotalPets()
    local _, numOwnedPets = C_PetJournal.GetNumPets()
    if numOwnedPets > 0 then
        return numOwnedPets
    end
    return nil
end

function Collections:GetTotalToys()
    local numToys, learnedToys = C_ToyBox.GetNumTotalDisplayedToys(), C_ToyBox.GetNumLearnedDisplayedToys()
    if learnedToys > 0 then
        return learnedToys, numToys
    end
    return nil
end