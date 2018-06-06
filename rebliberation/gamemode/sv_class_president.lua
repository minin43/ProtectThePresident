--//This function is used for running game-end logic if the president player dies
hook.Add("DoPlayerDeath", "PresidentDeath", function( victim, inflictor, attacker )
    if not self.GameInProgress or not self.RoundInProgress then return end
    if victim:GetTeam() == 3 then
        self:EndRound( 1 )
    end
end )