------------------------------------------------------------------
-- Copyright (c) 2017 Smiteworks USA, LLC						--
-- Author: James G. Holloway									--
-- Purpose: Paste in CSV as a Table in formattedText Fields.	--
------------------------------------------------------------------

-- Global Variables (global to this script)
local cFormattedText = nil; -- The last formattedtext field/control found.


local cLookup = {
    quest = "description",
    vehicle = "notes",
    npc = "notes",
    item = "notes",
    note = "text",
    encounter = "text",
    storytemplate = "text",
}

local cLookup5e = {
    reference_background = "text",
    reference_backgroundfeature = "text",
    reference_class = "text",
    reference_classfeature = "text",
    reference_classability = "text",
    reference_feat = "text",
    reference_race = "text",
    reference_racialtrait = "text",
    reference_subrace = "text",
    reference_subracialtrait = "text",
    reference_skill = "text",
    power = "description",
    npc = "text",
    item = "description",
    ref_ability = "text",
}

local cLookup2e = {
    reference_background = "text",
    reference_backgroundfeature = "text",
    reference_class = "text",
    reference_classfeature = "text",
    reference_race = "text",
    reference_racialtrait = "text",
    reference_racialproficiency = "text",
    reference_subrace = "text",
    reference_subracialtrait = "text",
    reference_skill = "text",
    power = "description",
    npc = "text",
    item = "description",
    ref_proficiency_item = "text",
}

local cLookupPFRPG = {
    npc = "text",
    item = "description",
    referenceclass = "text",
    referenceclassability = "text",
    referencerace = "text",
    referenceracialtrait = "text",
    referenceskill = "text",
    spelldesc = "description",
}

local cLookupPFRPG2 = {
    item = "description",
    reference_background = "text",
    referenceclass = "text",
    referenceclassability = "text",
    referencerace = "text",
    referenceracialtrait = "text",
    referenceskill = "text",
    reference_trait = "details",
}

local cLookupSavageWorlds = {
    npc = "text",
    sw_referencefeat = "benefit",
    powerdesc = "description",
    item = "text",
    sw_referencerace = "text",
    sw_referenceskill = "text",
}

local cAdvlogentry = { "gmlogentry", "logentry" }
local c2Eitem = { "description", "dmonly" }
local cPFRPGreferencefeat = { "benefit", "normal", "special" }
local cPFRPG2referenceaction = { "effectsbenefits", "special" }
local cPFRPG2npc = { "miscellaneous", "text" }
local cPFRPG2referencefeat = { "effectsbenefits", "special" }
local cPFRPG2spelldesc = { "heightened", "effects" }


-- ---------------------------------------------------------------
-- OnInit - Called right after ruleset loaded					--
-- ---------------------------------------------------------------
function onTabletopInit()
    local tButton = {
        sIcon = "csv_button",
        tooltipres = "sidebar_tooltip_csv",
        class = "CSVImport",
    };

    if Session.IsHost then
        DesktopManager.registerSidebarToolButton(tButton, false);
        Interface.onWindowOpened = onWindowOpen;
    end

    if (Session.RulesetName == "5E") then
        for k, v in pairs(cLookup5e) do cLookup[k] = v end
    elseif (Session.RulesetName == "2E") then
        for k, v in pairs(cLookup2e) do cLookup[k] = v end
    elseif (Session.RulesetName == "PFRPG") then
        for k, v in pairs(cLookupPFRPG) do cLookup[k] = v end
    elseif (Session.RulesetName == "PFRPG2") then
        for k, v in pairs(cLookupPFRPG2) do cLookup[k] = v end
    elseif (Session.RulesetName == "SavageWorlds") then
        for k, v in pairs(cLookupSavageWorlds) do cLookup[k] = v end
    end
end

-- multFTNodes - This function checks the window "w" for nodes passed in cTable.
-- If it finds the #table# that is the one we want.  This is to handle entries that have multiple
-- formatted text nodes.
function multFTNodes(w, cTable)
    local wNode = w.getDatabaseNode();
    local zTest = nil;
    for i, j in pairs(cTable) do
        zTest = wNode.getChild(j);
        if zTest ~= nil then
            local s, e = string.find(zTest.getValue(), '<p>#table#</p>');
            if s ~= nil then
                cFormattedText = zTest;
            end
        end
    end
end

function refManPage(w)
    local wNode = w.getDatabaseNode()
    local tChildren = DB.getChildren(wNode, "blocks")
    for _, v in pairs(tChildren) do
        local sBlockType = DB.getValue(v, "blocktype", "")
        if sBlockType == "dualtext" then
            local nText = DB.getChild(v, "text")
            local nText2 = DB.getChild(v, "text2")
            local s, e = string.find(nText.getValue(), '<p>#table#</p>');
            if s ~= nil then
                cFormattedText = nText;
            end
            s, e = string.find(nText2.getValue(), '<p>#table#</p>');
            if s ~= nil then
                cFormattedText = nText2;
            end
        elseif sBlockType == "singletext" or sBlockType == "imageright" or sBlockType == "imageleft" then
            local nText = DB.getChild(v, "text")
            local s, e = string.find(nText.getValue(), '<p>#table#</p>');
            if s ~= nil then
                cFormattedText = nText;
            end
        end
    end
end

-- ---------------------------------------------------------------
-- onWindowOpen - When a window is opened this function fires.	--
-- w - (window) The window that fired the function.				--
-- ---------------------------------------------------------------
function onWindowOpen(w)
    local wClass = w.getClass();
    --if this type is in our lookup table.
    if cLookup[wClass] ~= nil then
        local wNode = w.getDatabaseNode();
        cFormattedText = wNode.getChild(cLookup[wClass]);
        --       cRollTable = nil;
    end
    if wClass == "advlogentry" then
        multFTNodes(w, cAdvlogentry);
    end
    if wClass == "referencemanualpage" then
        refManPage(w)
    end
    if (Session.RulesetName == "2E" and wClass == "item") then
        multFTNodes(w, c2Eitem);
    end
    if (Session.RulesetName == "PFRPG" and wClass == "referencefeat") then
        multFTNodes(w, cPFRPGreferencefeat);
    end
    if Session.RulesetName == "PFRPG2" then
        if wClass == "referenceaction" then
            multFTNodes(w, cPFRPG2referenceaction);
        elseif wClass == "npc" then
            multFTNodes(w, cPFRPG2npc);
        elseif wClass == "referencefeat" then
            multFTNodes(w, cPFRPG2referencefeat);
        elseif wClass == "spelldesc" then
            multFTNodes(w, cPFRPG2spelldesc);
        end
    end
end

function onCSVFileSelection(result, sPath)
    if result ~= "ok" then return; end
    local sContents = File.openTextFile(sPath);
    local tContents = Utility.decodeCSV(sContents);
    local sTable = '<table>';
    for i, v in ipairs(tContents) do
        sTable = sTable .. '<tr>';
        for j, k in ipairs(v) do
            sTable = sTable .. '<td>';
            sTable = sTable .. k;
            sTable = sTable .. '</td>';
        end
        sTable = sTable .. '</tr>';
    end
    sTable = sTable .. '</table>';
    if cFormattedText then
        local sValue = cFormattedText.getValue();
        sValue = string.gsub(sValue, '<p>#table#</p>', sTable, 1);
        cFormattedText.setValue(sValue);
    end
end
