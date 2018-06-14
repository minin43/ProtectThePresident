hook.Add( "DoPlayerDeath", "TerroristDeath", function( victim, attacker, dmginfo )
    if not self.GameInProgress or not self.RoundInProgress then return end
    if not victim or not IsValid( victim ) or not attacker or not IsValid( attacker ) then return end
    if victim:Team() != 1 then return end

    net.Start( "DoFadeout" )
        net.WriteInt( 2, 3 ) --2 second fade to black
        net.WriteInt( 3, 3 ) --Hold it for 3 seconds
    net.Send( victim )

    timer.Simple( 5, function()
        net.Start( "StartLoadout" ) --Tell client to open loadout customization
        net.Send( victim )
    end )
    timer.Simple( GAMEMODE.TerroristSpawnTimer, function() --After however long it is we want the terrorists to wait before respawning
        net.Start( "CanRespawn" ) --Notify's client it can now respawn
        net.Send( victim )
    end )
end )