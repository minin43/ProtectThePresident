--//When a bodyguard player starts using voice chat, play the on-radio sound
hook.Add( "PlayerStartVoice", "StartRadioSound", function( ply )
    if ply:Team() == 2 and ( LocalPlayer():Team() == 2 or LocalPlayer():Team() == 3 ) then
        surface.PlaySound( "combine/deathradio/on" .. math.random( 2 ) .. ".wav" )
    end
end )

--//When a bodyguard player stops using voice chat, play the off-radio sound
hook.Add( "PlayerEndVoice", "EndRadioSound", function( ply )
    if ply:Team() == 2 and ( LocalPlayer():Team() == 2 or LocalPlayer():Team() == 3 ) then
        surface.PlaySound( "combine/deathradio/off" .. math.random( 3 ) .. ".wav" )
    end
end )