local KL = ...

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


local function death(handle, info)
    local unit = Inspect.Unit.Detail(info.target)
    if unit.tagged == true and KL.rares[unit.type] then
        Command.Console.Display("general", false, "you just killed a rare: " .. unit.name, false)
        KL.killed[unit.type] = {lastKill = Inspect.Time.Server()}
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
        print("last reset: " .. os.date("%c", lastReset))
    end
    return lastReset
end


local function killed()
    local allkilled = true
    local msg = "You still have to kill: \n"
    local lastReset = resetTime()
    for k, v in pairs(KL.rares) do
        local kill = KL.killed[k]
        if not kill or kill.lastKill < lastReset then
            allkilled = false
            msg = msg .. string.format("\t%s\n", v.name)
        end
    end
    if(allkilled) then
        Command.Console.Display("general", false, "All rares have been kill for today", false)
    else
        Command.Console.Display("general", false, msg, true)
    end
end

local function loadSavedVariables(h, addon)
    if addon == "KillList" then
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
        
    end
end

local function saveSavedVariables(h, addon)
    if addon == "KillList" then
        KL_killed = KL.killed
        KL_debug = KL.debug
    end
end

local function killList(h, args)
    if args:find("debug") then
        KL.debug = not KL.debug
        if KL.debug then
            Command.Console.Display("general", false, "debug activated", false)
        else
            Command.Console.Display("general", false, "debug deactivated", false)
        end
    else
        killed()
    end
end


-- Register the slash commands and events
Command.Event.Attach(Event.Addon.SavedVariables.Load.End, loadSavedVariables, "Load variables")
Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin, saveSavedVariables, "Save variables")
Command.Event.Attach(Event.Combat.Death, death, "KillList_death_handler")
Command.Event.Attach(Command.Slash.Register("killlist"), killList, "display VP rares not yet killed today")