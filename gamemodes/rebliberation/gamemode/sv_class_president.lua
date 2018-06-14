--//This function is used for running game-end logic if the president player dies
hook.Add("DoPlayerDeath", "PresidentDeath", function( victim, attacker, dmginfo )
    if not self.GameInProgress or not self.RoundInProgress then return end
    if victim:Team() == 3 then
        self:EndRound( 1 )
    end
end )