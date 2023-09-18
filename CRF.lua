local f = CreateFrame("Frame")

local crfm = _G["CompactRaidFrameManager"]
local crfc = _G["CompactRaidFrameContainer"]

local rFresh, gFresh, bFresh = 0.7, 1, 1
local rExpire, gExpire, bExpire = 1, 0, 0.7

function f:ADDON_LOADED(event, addOnName)
    if addOnName == "CRF" then
        if CRFEnabled == nil then
            CRFEnabled = true
        end
        f:UnregisterEvent("ADDON_LOADED")
    end
end

-- NOTES --
-- raid frame manager might not be active in 5 man groups now, need to wait and test

local className, classFilename, classId = UnitClass("player")
if classId == 5 then
    hooksecurefunc("CompactUnitFrame_UpdateAuras", function(frame, unitAuraUpdateInfo)
        if not CRFEnabled then return end
        if frame:IsForbidden() then return end
        --if not crfc:IsShown() then return end
        local name = frame:GetName()
        if not name or not name:match("^Compact") then return end
        if not UnitIsConnected(frame.unit) then return end
        if not frame:IsVisible() then return end

        -- if not UnitExists(frame.displayedUnit) then
        --     print("not UnitExists(frame.displayedUnit)")
        --     print(frame.unit)
        --     return
        -- end

        local i = 1
        local hasAtonement = false
        local timeLeft
        while true do
            local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitAura(frame.unit, i, "HELPFUL")

            if not spellId then
                break
            end

            if spellId == 194384 and unitCaster == "player" then
                hasAtonement = true
                timeLeft = expirationTime - GetTime()
            end

            i = i + 1
        end

        if hasAtonement then
            if timeLeft < 3 then
                frame.healthBar:SetStatusBarColor(rExpire, gExpire, bExpire)
                frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = rExpire, gExpire, bExpire
            else
                frame.healthBar:SetStatusBarColor(rFresh, gFresh, bFresh)
                frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = rFresh, gFresh, bFresh
            end
        else
            --not sure this does anything anymore after 10.0 update.
            --was trying to do some manual setting back to class colors before I found the new UpdateHealthColor call.
            --if this is gone, can then refactor, with one function that both hooks call
            CompactUnitFrame_UpdateHealthColor(frame)
        end
    end)

    --in build 46313 (first 10.0 patch) blizzard added a CompactUnitFrame_UpdateHealthColor call to every CompactUnitFrame_UpdateHealth call.
    --before UpdateHealthColor hardly got called at all, now everytime a health event happens it changes from color.
    hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
        if not CRFEnabled then return end
        if frame:IsForbidden() then return end
        --if not crfc:IsShown() then return end
        local name = frame:GetName()
        if not name or not name:match("^Compact") then return end
        if not UnitIsConnected(frame.unit) then return end
        if not frame:IsVisible() then return end

        local i = 1
        local hasAtonement = false
        local timeLeft
        while true do
            local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = UnitAura(frame.unit, i, "HELPFUL")

            if not spellId then
                break
            end

            if spellId == 194384 and unitCaster == "player" then
                hasAtonement = true
                timeLeft = expirationTime - GetTime()
            end

            i = i + 1
        end

        if hasAtonement then
            if timeLeft < 3 then
                frame.healthBar:SetStatusBarColor(rExpire, gExpire, bExpire)
                frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = rExpire, gExpire, bExpire
            else
                frame.healthBar:SetStatusBarColor(rFresh, gFresh, bFresh)
                frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = rFresh, gFresh, bFresh
            end
        end
    end)
end

SLASH_CRF1 = "/crf"

SlashCmdList.CRF = function(msg)
    if msg == "on" then
        CRFEnabled = true
        print("CRF: Is now on.")
    end
    if msg == "off" then
        CRFEnabled = false
        print("CRF: Is now off.")
    end

    if msg == "show" then
        crfm:Show()
        crfc:Show()
        print("CRF: Raid frames are now shown.")
    end
    if msg == "hide" then
        crfm:Hide()
        crfc:Hide()
        print("CRF: Raid frames are now hidden.")
    end
end

f:RegisterEvent("ADDON_LOADED")
