GM.PlayerPoints = {
    {},
    {},
    {},
    BaseTerroristPoints = GM.StartingTerroristPoints
}
GM.TerroristDeathCounter = {}

--//Function called at round start, assigns all player's starting points based on their team
--//Can also be called individually if a valid param is provided
function GM:AssignStartingPoints( ply )
    if ply then
        if ply:Team() == 1 then
            self.PlayerPoints[ 1 ][ ply:SteamID() ] = self.StartingTerroristPoints
        elseif ply:Team() == 2 then
            self.PlayerPoints[ 2 ][ ply:SteamID() ] = self.StartingBodyguardPoints
        elseif ply:Team() == 3 then
            self.PlayerPoints[ 3 ][ ply:SteamID() ] = self.StartingPresidentPoints
        end
    else
        for k, v in pairs( player.GetAll() ) do
            if v:Team() == 1 then
                self.PlayerPoints[ 1 ][ v:SteamID() ] = self.StartingTerroristPoints
            elseif v:Team() == 2 then
                self.PlayerPoints[ 2 ][ v:SteamID() ] = self.StartingBodyguardPoints
            elseif v:Team() == 3 then
                self.PlayerPoints[ 3 ][ v:SteamID() ] = self.StartingPresidentPoints
            end
        end
    end
end

function GM:AddPoints( ply, pointValue )
    if ply:Team() != 1 then return end --This should only be used for terrorists
    self.PlayerPoints[ ply:Team() ][ ply:SteamID() ] = self.PlayerPoints[ ply:Team() ][ ply:SteamID() ] + pointValue
end

function GM:SetPoints( ply, pointValue )
    if ply:Team() != 1 then return end --This should only be used for terrorists
    self.PlayerPoints[ ply:Team() ][ ply:SteamID() ] = pointValue
end

function GM:AddToAllTerroristPoints( pointValue )
    for k, v in pairs( team.GetPlayers( 1 ) ) do
        self.PlayerPoints[ 1 ][ v:SteamID() ] = self.PlayerPoints[ 1 ][ v:SteamID() ] + pointValue
    end
    self.PlayerPoints.BaseTerroristPoints = self.PlayerPoints.BaseTerroristPoints + pointValue
end

function GM:SetAllTerroristPoints( pointValue )
    for k, v in pairs( team.GetPlayers( 1 ) ) do
        self.PlayerPoints[ 1 ][ v:SteamID() ] = pointValue
    end
    self.PlayerPoints.BaseTerroristPoints = pointValue
end

function GM:SetNewJoinPoints( ply )
    self.PlayerPoints[ 1 ][ ply:SteamID() ] = self.PlayerPoints.BaseTerroristPoints
end

hook.Add( "PlayerDeath", "Distribute Points", function( victim, inflictor, attacker )
    if not IsPlayer( attacker ) then return end
    if victim:Team() == 1 and ( attacker:Team() == 2 or attacker:Team() == 3 ) then
        GM.TerroristDeathCounter[ victim:SteamID() ] = GM.TerroristDeathCounter[ victim:SteamID() ] or 0
        GM.TerroristDeathCounter[ victim:SteamID() ] = GM.TerroristDeathCounter[ victim:SteamID() ] + 1

        if GM.TerroristDeathCounter[ victim:SteamID() ] % GM.TerroristDeathRequirement == 0 then
            GM:AddPoints( victim, GM.TerroristDeathBonus )
        end
    elseif victim:Team() == 2 and attacker:Team() == 1 then
        GM:AddPoints( attacker, GM.TerroristKillbonus )
    end
end )