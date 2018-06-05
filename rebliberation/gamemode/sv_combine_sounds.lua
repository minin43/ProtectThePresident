GM.CombineSignatures = {}

GM.CombineCallsigns = {
    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero",
    "interlock", "jury", "king", "roller", "union", "upi", "vice", "victor", "xray", "yellow"
}

--//Adds unique footsteps to the players with a combine model
function GM:PlayerFootsteps( ply, pos, foot, sound, vol, crf )
    if self.CombinePlayerModels[ ply:GetModel() ] then
        ply:EmitSound( "combine/stepnoise" .. math.random( 1, 12 ) .. ".wav" )
        --return true --Un-comment this to REMOVE the default stepping noise for combine players
    end
end

--//Sets up each bodyguard player's "unqiue signature" to be referenced by in the death radio chatter of the play
hook.Add( "OnRoundStart", "AssignCombineSignatures", function()
    for k, v in pairs( team.GetPlayers( 2 ) ) do
        if k > #GAMEMODE.CombineCallsigns then --If for whatever reason, there's an instance where there's a shitload of bodyguards, just go entirely random
            GAMEMODE.CombineSignatures[ v:SteamID() ] = { GAMEMODE.CombineCallsigns[ math.random( #GAMEMODE.CombineCallsigns ) ], GAMEMODE.CombineCallsigns[ math.random( #GAMEMODE.CombineCallsigns ) ], GAMEMODE.CombineCallsigns[ math.random( #GAMEMODE.CombineCallsigns ) ] }
        else
            GAMEMODE.CombineSignatures[ v:SteamID() ] = { GAMEMODE.CombineCallsigns[ k ], GAMEMODE.CombineCallsigns[ math.random( #GAMEMODE.CombineCallsigns ) ], GAMEMODE.CombineCallsigns[ math.random( #GAMEMODE.CombineCallsigns ) ] }
        end
    end
end )

--//After a combine bodyguard has died and his death sound has played (not done here), play the radio chatter
--MAY BE ABLE TO REWRITE USING SOUND.ADD, INSTEAD OF TIMING IT WITH TIMERS
hook.Add( "PlayerDeath", "CombineRadioChatter", function( victim, inflictor, attacker )
    if GAMEMODE.CombinePlayerModels[ victim:GetModel() ] then
        timer.Simple( 3, function()
            victim:EmitSound( "combine/deathradio/lostbiosignalforunit.wav" )
            timer.Simple( 2, function()
                victim:EmitSound( "combine/deathradio/" .. GAMEMODE.CombineSignatures[ victim:SteamID() ][ 1 ] .. ".wav" )
                timer.Simple( 0.5, function()
                    victim:EmitSound( "combine/deathradio/" .. GAMEMODE.CombineSignatures[ victim:SteamID() ][ 2 ] .. ".wav" )
                    timer.Simple( 0.5, function()
                        victim:EmitSound( "combine/deathradio/" .. GAMEMODE.CombineSignatures[ victim:SteamID() ][ 3 ] .. ".wav" )
                        timer.Simple( 0.5, function()
                            victim:EmitSound( "combine/deathradio/allteamsrespond.wav" )
                            timer.Simple( 1, function()
                                victim:EmitSound( "combine/deathradio/off" .. math.random( 4 ) .. ".wav" )
                            end )
                        end )
                    end )
                end )
            end )
        end )
    end
end )