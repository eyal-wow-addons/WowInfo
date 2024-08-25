local _, addon = ...
local MicroMenu = addon:NewObject("MicroMenu")

-- NOTE: 
-- Sometimes the 'AchievementMicroButton' tooltip wouldn't show up because 'tooltipText' is nil, 
--  I'm not sure why or whether this is a Blizzard bug but this aims to fix that.
function MicroMenu:SetButtonTooltip(button, text, action)
    if button:IsEnabled() then
        if not button.tooltipText then
            button.tooltipText = MicroButtonTooltipText(text, action)
            local script = button:GetScript("OnEnter")
            if script then
                script(button)
            end
            return true
        end
    end
    return false
end