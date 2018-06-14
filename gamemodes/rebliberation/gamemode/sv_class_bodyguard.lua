util.AddNetworkString( "StartMusic" )

--//When the last bodyguard dies, and the president is still alive, play some music for the president
hook.Add("PlayerDeath", "LastBodyguardDeath", function( victim, inflictor, attacker )
    if not self.GameInProgress or not self.RoundInProgress then return end
    if victim:Team() != 2 and not team.GetPlayers( 3 )[ 1 ]:Alive() then return end

    for k, v in pairs( team.GetPlayers( 2 ) ) do
        if v != victim and v:Alive() then --victim is still considered alive when this is called, so don't check for them when we loop
            return --If any of the bodyguards are still left alive, don't do anything further
        end
    end

    net.Start( "StartMusic" )
    net.Send( team.GetPlayers( 3 )[ 1 ] )
end )