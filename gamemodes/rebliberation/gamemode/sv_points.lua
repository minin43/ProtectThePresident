GM.PlayerPoints = {
    {},
    {},
    {},
    BaseTerroristPoints = GM.StartingTerroristPoints
}
GM.TerroristDeathCounter = {}

--//Function called at round start, assigns all player's starting points based on their team
function GM:AssignStartingPoints()
    for k, v in pairs( player.GetAll() ) do
        if v:GetTeam() == 1 then
            self.PlayerPoints[ 1 ][ v:SteamID() ] = self.StartingTerroristPoints
        elseif v:GetTeam() == 2 then
            self.PlayerPoints[ 2 ][ v:SteamID() ] = self.StartingBodyguardPoints
        elseif v:GetTeam() == 3 then
            self.PlayerPoints[ 3 ][ v:SteamID() ] = self.StartingPresidentPoints
        end
    end
end

function GM:AddPoints( ply, pointValue )
    if ply:GetTeam() != 1 then return end --This should only be used for terrorists
    self.PlayerPoints[ ply:GetTeam() ][ ply:SteamID() ] = self.PlayerPoints[ ply:GetTeam() ][ ply:SteamID() ] + pointValue
end

function GM:SetPoints( ply, pointValue )
    if ply:GetTeam() != 1 then return end --This should only be used for terrorists
    self.PlayerPoints[ ply:GetTeam() ][ ply:SteamID() ] = pointValue
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
    if victim:GetTeam() == 1 and ( attacker:GetTeam() == 2 or attacker:GetTeam() == 3 ) then
        GM.TerroristDeathCounter[ victim:SteamID() ] = GM.TerroristDeathCounter[ victim:SteamID() ] or 0
        GM.TerroristDeathCounter[ victim:SteamID() ] = GM.TerroristDeathCounter[ victim:SteamID() ] + 1

        if GM.TerroristDeathCounter[ victim:SteamID() ] % GM.TerroristDeathRequirement == 0 then
            GM:AddPoints( victim, GM.TerroristDeathBonus )
        end
    elseif victim:GetTeam() == 2 and attacker:GetTeam() == 1 then
        GM:AddPoints( attacker, GM.TerroristKillbonus )
    end
end )