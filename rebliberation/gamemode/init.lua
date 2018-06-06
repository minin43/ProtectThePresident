AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_role_intro_menus.lua" )
AddCSLuaFile( "cl_role_intro_menus_setup.lua" )
AddCSLuaFile( "sh_setup.lua" )

include( "sv_round.lua" )
include( "sv_combine_sounds.lua" )
include( "sv_all_player_sounds.lua" )
include( "sh_setup.lua" )

--// Constant variables related to game play can be found in sh_setup.lua //--

function GM:PlayerDeathSound()
	return true
end

function GM:Initialize() -- remove hl2:dm weapons & ammo, if people find suitable maps to use which may have these in them
	timer.Simple( 0, function()
		for k, v in pairs( ents.FindByClass( "weapon_*" ) ) do
			SafeRemoveEntity( v )
		end
		for k, v in pairs( ents.FindByClass( "item_*" ) ) do
			if v != "item_healthcharger" then
				SafeRemoveEntity( v )
			end
		end

		for k, v in pairs( ents.FindByClass( "func_breakable" ) ) do
			SafeRemoveEntity( v )
		end
		for k, v in pairs( ents.FindByClass( "prop_dynamic" ) ) do
			SafeRemoveEntity( v )
		end
	end )
end

--//Checks for game validity when a player leaves, in case a team is left without a player
--//Only for Terrorist and President team, game will naturally conclude on its own if all of the bodyguards leave
function GM:CheckGameValidityAfterPlayerLeave()
    if not self.GameInProgress then return end

    local numberAlive = 0
    for k, v in pairs( team.GetPlayers( 1 ) ) do --Terrorist team
        if v:Alive() then
            numberAlive = numberAlive + 1 --Count the amount of players on the Terrorist team, only 1 is truly needed
        end
    end
    if numberAlive == 0 then --If there's no players on the terrorist team
        if #player.GetAll() < self.MinimumPlayers then --If there's not enough players in the game to even play
            for k, ply in pairs( player.GetAll() ) do --Notify players
                ply:ChatPrint( "[RL]: Someone left the game, there are now not enough players to continue playing." )
            end
            self.GameInProgress = false
            return end
        end
        if self.RoundInProgress then --If we're in the middle of running around when the last player leaves
            self:EndRound( 0 ) --End the round with winner as 0
            for k, ply in pairs( player.GetAll() ) do --Notify players
                ply:ChatPrint( "[RL]: No Rebels detected on Rebel team, forcing round over." )
            end
        end
    end

    if #team.GetPlayers( 3 ) == 0 then --President team
        if #player.GetAll() < self.MinimumPlayers then
            for k, ply in pairs( player.GetAll() ) do --Notify players
                ply:ChatPrint( "[RL]: Someone left the game, there are now not enough players to continue playing." )
            end
            self.GameInProgress = false
            return end
        end
        if self.RoundInProgress then
            self:EndRound( 1 )
            for k, ply in pairs( player.GetAll() ) do --Notify players
                ply:ChatPrint( "[RL]: Breen player no longer detected in game, forcing round over." )
            end
        end
    end
end

--//Simple chat and console print out when a player joins the game
function GM:PlayerConnect( ply )
    print( ply:Nick() .. " has begun connecting to the game." )
	for k, v in pairs( player.GetAll() ) do
		v:ChatPrint( "[RL]: " .. ply:Nick() .. " has begun connecting to the game." )
	end
end

--//Chat and console print out when a player leaves the game, and also runs additional functions
function GM:PlayerDisconnected( ply )
    print( ply:Nick() .. " has disconnected from the game (SteamID: " .. ply:SteamID() )
	for k, v in pairs( player.GetAll() ) do
		v:ChatPrint( "[RL]: " .. ply:Nick() .. " has disconnected from the game (SteamID available in server console)" )
    end
    self:CheckGameValidityAfterPlayerLeave()
end

--//Disables player-directed respawning (when clicking or pressing space)
function GM:PlayerDeathThink( ply )
	return false
end