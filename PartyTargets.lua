local PT = CreateFrame("Frame", PT, UIParent);
local anchors = {}

local InArena = function() return (select(2,IsInInstance()) == "arena") end

function PT:CreateAnchors()
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
    anchor.text:SetText(UnitName(target));
    anchor:SetPoint("CENTER", frame, "CENTER")
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
PT:SetScript("OnEvent", function(self, event, unitid)
    
    if event == "UNIT_TARGET" and UnitInParty("player") then
       PT:LoadPositions()

    elseif event == "GROUP_ROSTER_UPDATE" then 
        PT:CreateAnchors()
        PT:LoadPositions()
    end
end)


