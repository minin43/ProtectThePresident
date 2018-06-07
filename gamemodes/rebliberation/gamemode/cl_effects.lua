GM.IsBeingMotionBlurred = false

sound.Add( {
    name = "Ringing",
    volume = 1.0, --Soundlevel in decibels, can be 2 numbers: min and max, respectively
    level = 100, --Distance sound can be heard, 100 = no change
    pitch = 100, --Pitch of the sound, 100 = no change, can be 2 numbers: min and max, respectively
    sound = "fx/ringing.wav" --Soundpath
} )

sound.Add( {
    name = "EndRinging",
    volume = 1.0, --Soundlevel in decibels, can be 2 numbers: min and max, respectively
    level = 100, --Distance sound can be heard, 100 = no change
    pitch = 100, --Pitch of the sound, 100 = no change, can be 2 numbers: min and max, respectively
    sound = "fx/ringingfadeout.wav" --Soundpath
} )

--//If server says we took explosion damage, play some visual and audio effects, the length of which depends on the amount of damage we took
net.Receive( "TookExplosionDamage", function()
    local EffectLength = net.ReadFloat()

    LocalPlayer():SetDSP( 4, false )
    --LocalPlayer():EmitSound( "Ringing" )
    GAMEMODE.IsBeingMotionBlurred = true

    timer.Simple( EffectLength - 0.5, function()
        --LocalPlayer():StopSound( "Ringing" )
        --LocalPlayer():EmitSound( "EndRinging" )
        timer.Simple( 0.5, function()
            LocalPlayer():SetDSP( 0, false )
            GAMEMODE.IsBeingMotionBlurred = false
        end )
    end )
end )

function GM:RenderScreenspaceEffects()
    if self.IsBeingMotionBlurred then
        DrawMotionBlur( 0.20, 0.99, 0.05 )
    end
end