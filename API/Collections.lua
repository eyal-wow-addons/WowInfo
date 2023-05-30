local _, addon = ...
Collections = {}
addon.Collections = Collections

do
    local MOUNTS_TOTAL_LABEL_FORMAT = "Mounts: |cffffffff%d|r"

    local function GetNumMounts()
        local numCollectedMounts = 0
        local numMounts = C_MountJournal.GetNumMounts()

        if numMounts >= 1 then
            local hideOnChar, isCollected
            local mountIDs = C_MountJournal.GetMountIDs()
            for index, mountID in ipairs(mountIDs) do
                hideOnChar, isCollected = select(10, C_MountJournal.GetMountInfoByID(mountID))
                if isCollected and hideOnChar ~= true then
                    numCollectedMounts = numCollectedMounts + 1
                end
            end
        end

        return numMounts, numCollectedMounts
    end

    function Collections:GetTotalMountsText()
        local _, numCollectedMounts = GetNumMounts()
        if numCollectedMounts > 0 then
            return MOUNTS_TOTAL_LABEL_FORMAT:format(numCollectedMounts)
        end
        return nil
    end
end

do
    local PETS_TOTAL_LABEL_FORMAT = "Pets: |cffffffff%d|r"

    function Collections:GetTotalPetsText()
        local _, numOwnedPets = C_PetJournal.GetNumPets()
        if numOwnedPets > 0 then
            return PETS_TOTAL_LABEL_FORMAT:format(numOwnedPets)
        end
        return nil
    end
end

do
    local TOYBOX_TOTAL_LABEL_FORMAT = "Toys: |cffffffff%d|r / |cff20ff20%d|r"

    function Collections:GetTotalToysText()
        local numToys, learnedToys = C_ToyBox.GetNumTotalDisplayedToys(), C_ToyBox.GetNumLearnedDisplayedToys()
        if learnedToys > 0 then
            return TOYBOX_TOTAL_LABEL_FORMAT:format(learnedToys, numToys)
        end
        return nil
    end
end
