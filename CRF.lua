local f = CreateFrame("Frame")

local crfm = _G["CompactRaidFrameManager"]
local crfc = _G["CompactRaidFrameContainer"]

function f:OnEvent(event, ...)
    self[event](self, event, ...)
end

function f:ADDON_LOADED(event, addOnName)
    if addOnName == "CRF" then
        if CRFEnabled == nil then
            CRFEnabled = true
        end
        f:UnregisterEvent("ADDON_LOADED")
    end
end

local className, classFilename, classId = UnitClass("player")
if classId == 5 then
    hooksecurefunc("CompactUnitFrame_UpdateAuras", function(frame)
        if not frame.unit or string.find(frame.unit, "target") or string.find(frame.unit, "nameplate") or string.find(frame.unit, "pet") or not crfc:IsShown() or not CRFEnabled then
            return
        end
        if not UnitIsConnected(frame.unit) then
            return
        end
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
                --frame.healthBar:SetStatusBarColor(1, 1, 1)
                frame.healthBar:SetStatusBarColor(1, 0, 0.7)
                frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = 1, 0, 0.7
            else
                if frame.healthBar.r == 0.7 and frame.healthBar.g == 1 and frame.healthBar.b == 1 then
                    return
                end
                frame.healthBar:SetStatusBarColor(0.7, 1, 1)
                frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = 0.7, 1, 1
            end
        else
            CompactUnitFrame_UpdateHealthColor(frame)
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
f:SetScript("OnEvent", f.OnEvent)
