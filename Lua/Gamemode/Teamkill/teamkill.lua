local teamkill = {}
local teamcolors = {}
local teamnames = {}

teamkill.Func = function()
	for p in players.iterate
		if (p.exiting) return end
		-- If a player doesn't have a team give them one
		if p.bp.neb_tk_team == nil then
			p.bp.savedskincolor = p.skincolor
			p.bp.neb_tk_team = #p
			p.bp.neb_tk_score = 0
			teamnames[#p] = p.name
			teamcolors[#p] = p.skincolor
		end
	end

	-- Game ends when everyone is on the same team (and there's at least one player)
	local winner = teamkill.WinningTeam()
	if winner ~= nil then
		print("Team " .. teamnames[winner] .. " wins!")
		teamkill.CustomEnd()
		return
	end
end

teamkill.WinningTeam = function()
	local current_team = nil
	-- Only true if everyone is on the same team
	for p in players.iterate do
	 	-- Only playing players
		if (p.spectator) then continue end
		-- Get team
		local team = p.bp.neb_tk_team

		-- Set team if unset, or exit if team is different than stored
		if current_team == nil then
			current_team = team
		elseif current_team ~= team then return nil end
	end
	-- No early exit, return winning team
	return current_team
end

teamkill.CustomEnd = function()
	-- Mostly copied from battleplus.EndBattle
	for p in players.iterate
		-- Restore color
		if (p.mo and p.mo.valid)
			p.mo.colorized = false
			p.mo.color = p.bp.savedskincolor
		end
		p.bp.savedskincolor = nil

		-- Set as exiting
		if p.exiting then continue end -- player is already exiting
		p.exiting = 281
		K_KartUpdatePosition(p) -- update the postitions so the correct music plays!
	end
	-- Set win music
	for p in players.iterate
		if not (p and p.mo) or p.spectator then continue end
		if p.exiting then S_ChangeMusic("kbwin", false, p) end
	end
end

teamkill.PlayerDamage = function(p, inflictor, source)
	-- Sanity check player and source
	if not (p and p.mo) then return end
	if not (source and source.player) then return end

	-- Check for friendly fire
	local playerTeam = p.bp.neb_tk_team
	local sourceTeam = source.player.bp.neb_tk_team
	if sourceTeam == playerTeam then
		-- TODO: TEAM DAMAGE sort of effect
	else
		CONS_Printf(p,"Converted to Team " .. teamnames[sourceTeam])
		-- Give 2 points to the attacker
		battleplus.SpawnBattlePoints(source.player, p, 2)
		source.player.bp.neb_tk_score = $+1 -- Only 1 since they're getting the other right away

		-- Give everyone on that team a point, SHARING IS CARING!
		for pother in players.iterate
			if pother.bp.neb_tk_team == sourceTeam then
				pother.bp.neb_tk_score = $+1
				pother.marescore = pother.bp.neb_tk_score
			end
		end
		
		-- Convert player
		p.bp.neb_tk_team = sourceTeam
		p.mo.color = teamcolors[sourceTeam]
		p.mo.colorized = true

		-- TODO: play some effect idk
	end
end

teamkill.FinishHook = function()
end

local teamkill_info = {
	name = "Teamkill",
	objective = "Hit to convert to your team!",
	--icon = "K_TEAMKL",
	icon = "K_RDMIZR", -- Temp icon
	func = teamkill.Func,
	playerspin = teamkill.PlayerDamage,
	playersquish = teamkill.PlayerDamage,
	playerexplode = teamkill.PlayerDamage,
	finishhook = teamkill.FinishHook,
	rules = BP_GMR_REMOVEWANTED|BP_GMR_REMOVEPOINTS,
}

battleplus.DefineGamemodeConstant("BP_GM_TEAMKILL")
battleplus.AddGamemode(BP_GM_TEAMKILL, teamkill_info)