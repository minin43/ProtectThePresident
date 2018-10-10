GM.CombineSignatures = {}

GM.CombineCallsigns = { --Only callsigns we have sounds for
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

--//Sets up each bodyguard player's "unqiue signature", shared over both server and client, when requested
function GM:AssignCombineID( combinePlayers )
    self.CombineSignatures = {} --Refresh the table every time this function gets ran (at the start of a round - when we have a fresh batch of bodyguards)

    for k, v in pairs( combinePlayers ) do
        if k > #GAMEMODE.CombineCallsigns then --If for whatever reason, there's an instance where there's a shitload of bodyguards, just go entirely random
            GAMEMODE.CombineSignatures[ v:SteamID() ] = { GAMEMODE.CombineCallsigns[ math.random( #GAMEMODE.CombineCallsigns ) ], GAMEMODE.CombineCallsigns[ math.random( #GAMEMODE.CombineCallsigns ) ], GAMEMODE.CombineCallsigns[ math.random( #GAMEMODE.CombineCallsigns ) ] }
        else
            GAMEMODE.CombineSignatures[ v:SteamID() ] = { GAMEMODE.CombineCallsigns[ k ], GAMEMODE.CombineCallsigns[ math.random( #GAMEMODE.CombineCallsigns ) ], GAMEMODE.CombineCallsigns[ math.random( #GAMEMODE.CombineCallsigns ) ] }
        end
    end
end

--//Creates the radio chatter to emit on a bodyguard's death
hook.Add( "OnRoundStart", "AssignCombineSignatures", function()
    for k, v in pairs( team.GetPlayers( 2 ) ) do
        local soundName = v:Nick() .. GAMEMODE.CombineSignatures[ v:SteamID() ][ 1 ] .. GAMEMODE.CombineSignatures[ v:SteamID() ][ 2 ] .. GAMEMODE.CombineSignatures[ v:SteamID() ][ 3 ]
        sound.Add( {
            name = soundName,
            volume = 1.0, --Soundlevel in decibels, can be 2 numbers: min and max, respectively
            level = 100, --Distance sound can be heard, 100 = no change
            pitch = 100, --Pitch of the sound, 100 = no change, can be 2 numbers: min and max, respectively
            sound = { --Soundpaths
                "combine/deathradio/lostbiosignalforunit.wav",
                "combine/deathradio/" .. GAMEMODE.CombineSignatures[ v:SteamID() ][ 1 ] .. ".wav",
                "combine/deathradio/_comma.wav",
                "combine/deathradio/" .. GAMEMODE.CombineSignatures[ v:SteamID() ][ 1 ] .. ".wav",
                "combine/deathradio/_comma.wav",
                "combine/deathradio/" .. GAMEMODE.CombineSignatures[ v:SteamID() ][ 1 ] .. ".wav",
                "combine/deathradio/_period.wav",
                "combine/deathradio/allteamsrespond.wav",
                "combine/deathradio/_period.wav",
                "combine/deathradio/off" .. math.random( 4 ) .. ".wav"
            }
        })
    end
end )

--//After a combine bodyguard has died and his death sound has played (the 3 second timer), play the radio chatter
hook.Add( "PlayerDeath", "CombineRadioChatter", function( victim, inflictor, attacker )
    if GAMEMODE.CombinePlayerModels[ victim:GetModel() ] then
        timer.Simple( 3, function()
            victim:EmitSound( victim:Nick() .. GAMEMODE.CombineSignatures[ victim:SteamID() ][ 1 ] .. GAMEMODE.CombineSignatures[ victim:SteamID() ][ 2 ] .. GAMEMODE.CombineSignatures[ victim:SteamID() ][ 3 ] )
        end )
    end
end )
