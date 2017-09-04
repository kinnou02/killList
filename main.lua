local toc, KL = ...
local AddonId = toc.identifier
local Lang = Library.Translate

KL.rares = {
    ["U1AD8C1573848F38B"] = {name = "Sleet Stalker"},
    ["U522B0D883A4238D3"] = {name = "Murder Bot 9000"},
    ["U0ED05A240ECE960B"] = {name = "Blackroot"},
    ["U0ED05A251F275918"] = {name = "Duplicant Prime"},
    ["U522B0D850FC18FEC"] = {name = "Icefang"},
    ["U0ED05A27394BC77E"] = {name = "Bloodfeather"},
    ["U1AD8C15C0419AADD"] = {name = "Copy Cat"},
    ["U1AD8C15B7B23E7CC"] = {name = "Skinwalker"},
    ["U0ED05A215C4C6524"] = {name = "Kanteh"},
    ["U1AD8C15F369ADB00"] = {name = "Chomper"},
    ["U1AD8C15A6AF53CFF"] = {name = "Orinash Windborne"},
    ["U1AD8C16402ABF24A"] = {name = "Primus Cataphractarii Lancer"},
    ["U1AD8C1651381B55B"] = {name = "Primus Veles"},
    ["U522B0D86183FB2FD"] = {name = "Oxidizer"},
    ["U1AD8C163727DCF45"] = {name = "Primus Auxilia"},
    ["U1AD8C1674DD422BE"] = {name = "Primus Augur"},
    ["U1AD8C1663CFE7FA8"] = {name = "Primus Hastati"},
    ["U1AD8C16047F09E16"] = {name = "C1A3 Recon Model IIV Mk3.0"},
    ["U1AD8C15D15766D22"] = {name = "C2A1 Battle Model II Mk1"},
    ["U1AD8C16261070474"] = {name = "Tornadax"},
    ["U1AD8C1685E02E58F"] = {name = "Primus Eria"},
    ["U0ED05A1E11C334F0"] = {name = "Trenton Zozula"},
    ["U0ED05A203317A2D6"] = {name = "Ai-Orii-i-iah"},
    ["U0ED05A1F2239FFC1"] = {name = "Experiment Alpha-1"},
    ["U0ED05A26281D1C69"] = {name = "Samova"},
    ["U30697E250F651519"] = {name = "Primus Evocatus"},
    ["U1AD8C159599F79EE"] = {name = "Frigid Claw"},
    ["U522B0D894AB8E321"] = {name = "Teknha"},
    ["U1AD8C15E25AC1033"] = {name = "C2A2 Battle Model III Mk1.1"},
    ["U0ED05A237D90D33A"] = {name = "Eliminatus Prime"},
    ["U1AD8C16150294167"] = {name = "Bloodseraph Riancha"},
    ["U1AD8C15848A6B699"] = {name = "Frost Paw"},
    ["U1AD8C1551E2405B5"] = {name = "Ai-ichak"},
    ["U0ED05A226CBA2835"] = {name = "Walking Death"},
    ["U1AD8C1562F12C8BA"] = {name = "Experiment Alpha-2"},
    ["U522B0D87291475C2"] = {name = "Alsbeth the Discordant"},
}

KL.context = UI.CreateContext("KillList")

local function death(handle, info)
    local unit = Inspect.Unit.Detail(info.target)
    if unit.tagged == true and KL.rares[unit.type] then
        Command.Console.Display("general", false, Lang.JUSTKILLED .. unit.name, false)
        KL.killed[unit.type] = {lastKill = Inspect.Time.Server()}
        KL.rares[unit.type].row[1]:SetTexture("Rift", "raid_icon_ready.png.dds")
    elseif KL.debug and KL.rares[unit.type] then
        dump(KL.rares[unit.type])
    end
end

local function resetTime()
    local offset = os.time() - os.time(os.date("!*t", Inspect.Time.Server()))
    local now = os.date("!*t")
    lastReset = os.time{year=now["year"], month=now["month"], day=now["day"], isdst=now["isdst"], hour=4} + offset
    if lastReset > Inspect.Time.Server() then
        -- reset time is on the futur, so we move it back from a day
        lastReset = lastReset - (60*60*24)
    end
    if KL.debug then
        print(Lang.LASTRESET .. os.date("%c", lastReset))
    end
    return lastReset
end

local function killed()
    local allkilled = true
    local msg = Lang.STILLKILL
    local lastReset = resetTime()
    for k, v in pairs(KL.rares) do
        local kill = KL.killed[k]
        if not kill or kill.lastKill < lastReset then
            allkilled = false
            msg = msg .. string.format("\t%s\n", v.name)
        end
    end
    if(allkilled) then
        Command.Console.Display("general", false, Lang.ALLRAREKILLED, false)
    else
        Command.Console.Display("general", false, msg, true)
    end
end

local function loadSavedVariables(h, addon)
    if addon == AddonId then
        if KL_killed == nil then
            KL.killed = {}
        else
            KL.killed = KL_killed
        end
        if KL_debug == nil then
            KL.debug = false
        else
            KL.debug = KL_debug
        end
        if KL_mouseData == nil then
            KL_mouseData = {
                x = 0,
                y = 0
            }
        end
        if KL_buttonActive == nil then
            KL_buttonActive = true
        else
            KL_buttonActive = KL_buttonActive
        end
    end
end

local function saveSavedVariables(h, addon)
    if addon == AddonId then
        KL_killed       = KL.killed
        KL_debug        = KL.debug
        KL_mouseData    = KL_mouseData
        KL_buttonActive = KL_buttonActive
    end
end

local function init()
    KL.frame = UI.CreateFrame("SimpleWindow", AddonId.."_KLframe", KL.context)
    -- Set the frame to the top center of the game --
    KL.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, 100)
    KL.frame:SetVisible(false)
    KL.frame:SetLayer(1)
    KL.frame:SetAlpha(1)
    KL.frame:SetCloseButtonVisible(true) 

    KL.buttonMovable(KL.frame, KL.context)

    -- Ajout du titre de la fenêtre -- 
    KL.frame:SetTitle(AddonId)  
    
    KL.listScrollView = UI.CreateFrame("SimpleScrollView", AddonId.."_listScrollView", KL.frame)
    KL.listScrollView:SetPoint("TOPLEFT", KL.frame, "TOPLEFT", 20, 55)
    KL.listScrollView:SetWidth(370)
    KL.listScrollView:SetHeight(480)
    
    KL.grid = UI.CreateFrame("SimpleGrid", AddonId.."_MyGrid", KL.listScrollView)
    KL.grid:SetPoint("TOPLEFT", KL.listScrollView, "TOPLEFT")
    KL.grid:SetBackgroundColor(0, 0, 0, 0)
    KL.grid:SetWidth(KL.frame:GetWidth())
    KL.grid:SetHeight(KL.frame:GetHeight())
    KL.grid:SetMargin(1)
    KL.grid:SetCellPadding(1)
    
    local lastReset = resetTime()
    for k, v in pairs(KL.rares) do
        local cellName = UI.CreateFrame("Text", AddonId.."_Cell", KL.grid)
        cellName:SetText(v.name)
        local cellStatus = UI.CreateFrame("Texture", AddonId.."_cellstatus", KL.grid)
        local kill = KL.killed[k]
        if not kill or kill.lastKill < lastReset then
            cellStatus:SetTexture("Rift", "raid_icon_notready.png.dds")
        else
            cellStatus:SetTexture("Rift", "btn_video_done.png.dds")
        end
        v.row = {cellStatus, cellName}
        KL.grid:AddRow(v.row)
    end
    KL.listScrollView:SetContent(KL.grid)

    -- Création du bouton déplaçable --
    KL.buttonMover("KL.Button", KL.context, KL.frame, AddonId, "Textures/ButtonUp.png", AddonId, "Textures/ButtonDown.png", KL_mouseData.x, KL_mouseData.y, KL_buttonActive)
end

local function rowComp(a, b)
    local _, at = a[1]:GetTexture()
    local _, bt = b[1]:GetTexture()
    return at > bt
end

local function show()       
    KL.frame:SetVisible(true)
    local lastReset = resetTime()
    local killed_rows = {}
    for k, v in pairs(KL.rares) do
        local kill = KL.killed[k]
        if not kill or kill.lastKill < lastReset then
            v.row[1]:SetTexture("Rift", "raid_icon_notready.png.dds")
        else
            v.row[1]:SetTexture("Rift", "btn_video_done.png.dds")
        end
    end
    local rows = KL.grid:GetRows()
    table.sort(rows, rowComp)
    KL.grid:SetRows(rows)
end

local function killList(h, args)
    if args:find("debug") then
        KL.debug = not KL.debug
        if KL.debug then
            Command.Console.Display("general", false, Lang.DEBUGON, false)
        else
            Command.Console.Display("general", false, Lang.DEBUGOFF, false)
        end
    elseif args:find("cli") then
        killed()
    else
        show()
    end
end

local function klButton()
    if KL_buttonActive == false then
        KL_buttonActive = true
        Command.Console.Display("general", false, Lang.KLBUTTONACTIVE, false)
        KL.PopUp("KL.context", Lang.NEEDUIRELOAD, 14, "/reloadui")
    else
        KL_buttonActive = false
        Command.Console.Display("general", false, Lang.KLBUTTONNOTACTIVE, false)
        KL.PopUp("KL.context", Lang.NEEDUIRELOAD, 14, "/reloadui")
    end
end


-- Register the slash commands and events
Command.Event.Attach(Event.Addon.SavedVariables.Load.End, loadSavedVariables, "Load variables")
Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin, saveSavedVariables, "Save variables")
Command.Event.Attach(Event.Combat.Death, death, "KillList_death_handler")
Command.Event.Attach(Command.Slash.Register("killlist"), killList, "display VP rares not yet killed today")
Command.Event.Attach(Command.Slash.Register("klbutton"), klButton, "Turn on/off button")
Command.Event.Attach(Event.Addon.Load.End, init, "initialize display")
