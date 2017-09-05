local toc, KL = ...
local AddonId = toc.identifier
local Lang = Library.Translate

KL.rares = {
    ["U1AD8C1573848F38B"] = {name = Lang.SLEETSTALKER},
    ["U522B0D883A4238D3"] = {name = Lang.MURDERBOT},
    ["U0ED05A240ECE960B"] = {name = Lang.BLACKROOT},
    ["U0ED05A251F275918"] = {name = Lang.DUPLICANTPRIME},
    ["U522B0D850FC18FEC"] = {name = Lang.ICEFANG},
    ["U0ED05A27394BC77E"] = {name = Lang.BLOODFEATHER},
    ["U1AD8C15C0419AADD"] = {name = Lang.COPYCAT},
    ["U1AD8C15B7B23E7CC"] = {name = Lang.SKINWALKER},
    ["U0ED05A215C4C6524"] = {name = Lang.KANTEH},
    ["U1AD8C15F369ADB00"] = {name = Lang.CHOMPER},
    ["U1AD8C15A6AF53CFF"] = {name = Lang.ORINASHWINDBORNE},
    ["U1AD8C16402ABF24A"] = {name = Lang.PRIMUSCATAPHRACTARILLANCER},
    ["U1AD8C1651381B55B"] = {name = Lang.PRIMUSVELES},
    ["U522B0D86183FB2FD"] = {name = Lang.OXIDIZER},
    ["U1AD8C163727DCF45"] = {name = Lang.PRIMUSAUXILIA},
    ["U1AD8C1674DD422BE"] = {name = Lang.PRIMUSAUGUR},
    ["U1AD8C1663CFE7FA8"] = {name = Lang.PRIMUSHASTATI},
    ["U1AD8C16047F09E16"] = {name = Lang.C1A3RECONMODEL},
    ["U1AD8C15D15766D22"] = {name = Lang.C2A1BATTLEMODEL},
    ["U1AD8C16261070474"] = {name = Lang.TORNADAX},
    ["U1AD8C1685E02E58F"] = {name = Lang.PRIMUSERIA},
    ["U0ED05A1E11C334F0"] = {name = Lang.TRENTONZOZULA},
    ["U0ED05A203317A2D6"] = {name = Lang.AIORIIIIAH},
    ["U0ED05A1F2239FFC1"] = {name = Lang.EXPERIMENTALPHAONE},
    ["U0ED05A26281D1C69"] = {name = Lang.SAMOVA},
    ["U30697E250F651519"] = {name = Lang.PRIMUSEVOCATUS},
    ["U1AD8C159599F79EE"] = {name = Lang.FRIGIDCLAW},
    ["U522B0D894AB8E321"] = {name = Lang.TEKNHA},
    ["U1AD8C15E25AC1033"] = {name = Lang.C2A2BATTLEMODEL},
    ["U0ED05A237D90D33A"] = {name = Lang.ELIMINATUSPRIME}, -- petit probleme quand on le tue mais que quelqu'un l'avait deja pull. il ne compte pas dans la liste --
    ["U1AD8C16150294167"] = {name = Lang.BLOODSERAPHRIANCHA},
    ["U1AD8C15848A6B699"] = {name = Lang.FROSTPAW},
    ["U1AD8C1551E2405B5"] = {name = Lang.AIICHAK},
    ["U0ED05A226CBA2835"] = {name = Lang.WALKINGDEATH},
    ["U1AD8C1562F12C8BA"] = {name = Lang.EXPERIMENTALPATWO},
    ["U522B0D87291475C2"] = {name = Lang.ALSBETHTHEDISCORDANT},
}

KL.context = UI.CreateContext("KillList")

local function death(handle, info)
    local unit = Inspect.Unit.Detail(info.target)
    if unit.tagged == true and KL.rares[unit.type] then
        Command.Console.Display("general", false, Lang.JUSTKILLED .. unit.name, false)
        KL.killed[unit.type] = {lastKill = Inspect.Time.Server()}
        KL.rares[unit.type].row[1]:SetTexture("Rift", "raid_icon_ready.png.dds")
    elseif KL.debug and KL.rares[unit.type] then
        dump(unit)
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

local function init(h, addon)
    if addon ~= AddonId then
        return
    end
    KL.frame = UI.CreateFrame("SimpleWindow", AddonId.."_KLframe", KL.context)
    -- Set the frame to the top center of the game --
    KL.frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, 100)
    KL.frame:SetVisible(false)
    KL.frame:SetLayer(1)
    KL.frame:SetAlpha(1)
    KL.frame:SetCloseButtonVisible(true)
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
            cellStatus:SetTexture("Rift", "raid_icon_ready.png.dds")
        end
        v.row = {cellStatus, cellName}
        KL.grid:AddRow(v.row)
    end
    KL.listScrollView:SetContent(KL.grid)

    -- Création du bouton déplaçable --
    KL.buttonMover("KL.Button", KL.context, "Rift", "target_portrait_LootPinata.png.dds", "Rift", "target_portrait_LootPinata.png.dds", KL_mouseData.x, KL_mouseData.y, KL_buttonActive)
end

local function rowComp(a, b)
    local _, at = a[1]:GetTexture()
    local _, bt = b[1]:GetTexture()
    return at < bt
end


function KL.show()       
    KL.frame:SetVisible(true)
    local lastReset = resetTime()
    local killed_rows = {}
    for k, v in pairs(KL.rares) do
        local kill = KL.killed[k]
        if not kill or kill.lastKill < lastReset then
            v.row[1]:SetTexture("Rift", "raid_icon_notready.png.dds")
        else
            v.row[1]:SetTexture("Rift", "raid_icon_ready.png.dds")
        end
    end
    local rows = KL.grid:GetRows()
    table.sort(rows, rowComp)
    KL.grid:SetRows(rows)
end

function KL.hide()       
    KL.frame:SetVisible(false)
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
        KL.show()
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
