local PT = CreateFrame("Frame", PT, UIParent);
local anchors = {}

local InArena = function() return (select(2,IsInInstance()) == "arena") end

function PT:HideAll() 
    for _, anchor in ipairs(anchors) do 
        anchor:Hide();
    end
end

function PT:CreateAnchors()
    PT:HideAll() 
	for i=0,GetNumGroupMembers()  do
        if not anchors[i] then 
            local anchor = CreateFrame("Frame","PTAnchor"..i ,UIParent)
            anchor:SetWidth(200);
            anchor:SetHeight(20);
            anchor:SetPoint("Center", UIParent, 0, 0);
            
            anchor.myIndex = i

            anchor.text = anchor:CreateFontString()
            anchor.text:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
            anchor.text:SetText(i)
            anchor.text:SetPoint("CENTER", anchor, "CENTER",0, 0)
            anchor.text:SetWidth(200);
            anchor.text:SetHeight(20);
            anchor:Hide();
            anchors[i] = anchor
        end 
	end
end

function PT:LoadPositions()
	local raidFramesOn = tonumber(GetCVar("useCompactPartyFrames"))
    
	for k,anchor in ipairs(anchors) do
		if (GetNumGroupMembers() >= k)  then
			anchor:ClearAllPoints()
			if (raidFramesOn == 1) or (UnitInRaid("player")) and not InArena() then
                local raidFrame = nil
                if CompactRaidFrameManager_GetSetting("KeepGroupsTogether") then
                    if UnitInRaid("player") then
                        raidFrame = _G["CompactRaidGroup1Member"..anchor.myIndex]
                    else
                        raidFrame = _G["CompactPartyFrameMember"..anchor.myIndex]
                    end
                else
                    
                    raidFrame = _G["CompactRaidFrame"..anchor.myIndex]
                end
                    if not raidFrame.unit then return end
                    PT:UpdateFrame(anchor, raidFrame)
			else
				local partyFrame = _G["PartyMemberFrame"..k]
				if partyFrame and UnitIsUnit(partyFrame.unit,"party"..k) then
                   if not partyFrame.unit then return end
                    PT:UpdateFrame(anchor, partyFrame)
				end
			end
		end
	end
end

function PT:UpdateFrame(anchor, frame) 
    local target = frame.unit.."-target"
    if not SETTINGS.showHealers and UnitGroupRolesAssigned(frame.unit) == "HEALER" then return end 
    anchor.text:SetText(UnitName(target));
    anchor.text:SetJustifyH(SETTINGS.textAlignment);
    anchor:SetPoint(SETTINGS.alignment1, frame, SETTINGS.alignment2)
    _, r = UnitClass(target);
    colour1 = RAID_CLASS_COLORS[r]
    if colour1 then 
        anchor.text:SetVertexColor(colour1.r, colour1.g, colour1.b, 1)
    end
    anchor:Show()
end


hooksecurefunc("CompactRaidFrameContainer_SetFlowSortFunction", function(_,_)
		PT:CreateAnchors()
        PT:LoadPositions()
end)


PT:RegisterEvent("UNIT_TARGET");
PT:RegisterEvent("GROUP_ROSTER_UPDATE")
PT:RegisterEvent("PARTY_MEMBERS_CHANGED")
PT:RegisterEvent("ADDON_LOADED")
PT:RegisterEvent("PLAYER_LOGOUT")

PT:SetScript("OnEvent", function(self, event, arg1)
    
    if event == "UNIT_TARGET" and UnitInParty("player") then
       PT:LoadPositions()

    elseif event == "GROUP_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then 

        PT:CreateAnchors()
        PT:LoadPositions()

    elseif event == "ADDON_LOADED" and arg1 == "PartyTargets" then
        -- Our saved variables, if they exist, have been loaded at this point.
        if SETTINGS == nil then
            SETTINGS = {}
            SETTINGS.alignment1 = "CENTER"
            SETTINGS.alignment2 = "CENTER"
            SETTINGS.textAlignment = "CENTER"
            SETTINGS.showHealers = true
            
        end

    elseif event == "PLAYER_LOGOUT" then
        -- Save the time at which the character logs out
        -- HaveWeMetLastSeen = time()
    end
end)



SLASH_PT1 = '/pt'
function SlashCmdList.PT(msg)
    if msg == "left" then 
        SETTINGS.alignment1 = "RIGHT"
        SETTINGS.alignment2 = "LEFT"
        SETTINGS.textAlignment = "RIGHT"
        print("Party Targets aligning left")
        PT:LoadPositions()
    elseif msg == "right" then 
        SETTINGS.alignment1 = "LEFT"
        SETTINGS.alignment2 = "Right"
        SETTINGS.textAlignment = "LEFT"
        print("Party Targets aligning right")
        PT:LoadPositions()
    elseif msg == "center" then 
        SETTINGS.alignment1 = "CENTER"
        SETTINGS.alignment2 = "CENTER"
        SETTINGS.textAlignment = "CENTER"
        print("Party Targets aligning center")
        PT:LoadPositions()
    elseif msg == "healers" then 
        SETTINGS.showHealers = not SETTINGS.showHealers
        if SETTINGS.showHealers then
            print("Party Targets will show healer targets")
        else
            print("PartyTargets wont show healer targets")
        end
        PT:LoadPositions()
    
    else 
        print("-- Party Targets --")
        print("Command list :")
        print("'pt left' - Align to left")
        print("'pt center' - Align to center")
        print("'pt right' - Align to right")
        print("'pt healer' will toggle displaying healers targets")
    end
    
end