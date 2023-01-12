-- Bring back votable random hell maps! It's like "rtv" but "hell", only works on voting screen
-- Relies on HOSTMOD (and some snippets from it, thanks!) by Tyron

local function randomHellMap(p)
    -- Cycle through every possible Map ID
    local availableMaps = {}
    for i = 0, 1062 do
        local map = mapheaderinfo[i]
        if map and map.lvlttl then
            -- Must be HELL and same gametype
            local sameGameType = map.typeoflevel == maptol
            local hell = map.menuflags & LF2_HIDEINMENU
            if sameGameType and hell then
                table.insert(availableMaps, G_BuildMapName(i))
            end
        end
    end

    if #availableMaps > 0 then
        local randomMap = availableMaps[P_RandomRange(1, #availableMaps)]
        COM_BufInsertText(server, "map " .. randomMap)
    else
        CONS_Printf(p, "Random hell map failed: no hell maps for this gamemode!")
    end

end

local inrace = false
addHook("ThinkFrame", function()
    inrace = true
end)
addHook("VoteThinker", function()
    inrace = false
end)

local setup = false
addHook("PlayerMsg", function(source, msgtype, target, msg)
    if not setup and server then
        if not server.HMvotable then
            server.HMvotable = {}
        end
        table.insert(server.HMvotable, "randomhell")
        setup = true
    end
    if inrace then
        return
    end
    if msgtype ~= 0 then
        return
    end
    if (msg:lower() ~= "hell") then
        return
    end
    if server.HMvtimer then
        COM_BufAddText(source, "voteyes")
        return true
    else
        COM_BufAddText(source, "vote randomhell")
        return true
    end
end)

COM_AddCommand("randomhell", randomHellMap, 0)
