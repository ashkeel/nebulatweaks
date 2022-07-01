-- JUICEBOX TWEAKS

-- Juicebox gates are harmful in a bunch of tracks, mostly where precise handling
-- is required and getting an random boost in some location is just guaranteed
-- death unless you know how to brake correctly.
-- Since gates are meant to be an help rather than hindrance, and
-- especially considering we strayed enough from god for Musshrom Villadge to
-- exist, this tries to remove gates where they are a problem.
-- Also it makes Sloppy sludge fair to both sides, and that's my favorite map!

local gateblacklist = {
	"MAPHD", -- Rainbow road classic (precise handling required)
	"MAPHJ", -- Septic quarry (precise handling required)
	"MAPNH", -- Wario's challenge (precise handling on the last stretch)
	"MAPNQ", -- Wario deluxe (precise handling on the last stretch)
	"MAPTD", -- Monkey Island (precise handling required)
	"MAPVF", -- Sloppy sludge (two-sided track)
	"MAPWL", -- Simulation grounds (too much RNG)
	"MAPMR", -- Musshrom Villadge (EXTREME precise handling required)
	"MAPZL" -- Flesh eden (it's a coop boss fight!)
}

local currentmap = ""
local gatesenabled = true
addHook("ThinkFrame", function()
	-- Run at first frame so we don't have query this every time a ring spawns
	if leveltime == 1 and currentmap != G_BuildMapName(gamemap) then
		currentmap = G_BuildMapName(gamemap)
		gatesenabled = true
		for _i,v in ipairs(gateblacklist)
			if currentmap == v then
				gatesenabled = false
				for p in players.iterate
					CONS_Printf(p, "HEY, LISTEN! Gates are disabled on this map!")
				end
				break
			end
		end
	end
end)

-- Gets rid of gates in maps where they become a hazard
-- Note: MobjSpawn would be the better hook, but then it starts throwing warnings.
addHook("MobjThinker", function(mo)
	if gatesenabled then return end
	P_RemoveMobj(mo)
end, MT_MANTARING)