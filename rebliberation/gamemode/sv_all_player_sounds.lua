GM.SoundLibrary = {}
GM.LastEmittedSounds = {}
GM.BlacklistWepons = {} --Add any weapons that shouldn't be reloaded (and have a sound played for it, by extension) here

hook.Add( "OnRoundEnd", "ResetLastEmittedSoundTable", function()
    GM.LastEmittedSounds = {}
end )

--//This function emits a sound from a player who has taken damage, the sound is ran dynamically, so if the player ever dies, it can be cut off 
hook.Add( "EntityTakeDamage", "DamageGrunts", function( ply, damageinfo )
    if not ply:IsPlayer() then return end
    if timer.Exists( "SoundWait" .. ply:SteamID() ) then return end

    local team, number
    if GAMEMODE.CombinePlayerModels[ ply:GetModel() ] then
        team = "combine"
        number = 7
    elseif GAMEMODE.RebelPlayerModels[ ply:GetModel() ] then
        team = "rebels"
        number = 7
    elseif GAMEMODE.BreenPlayerModels[ ply:GetModel() ] then
        team = "breen"
        number = 10
    end

    local soundToPlay = team .. "/damagegrunt" .. math.random( number ) --This is the sound's file path we're going to play, minues the sound extension (so we can use this below)

    --If we haven't ran this sound before and saved it to my SoundLibrary table, we'll have to set it up for use in Garry's Mod's Sound library
    if not GAMEMODE.SoundLibrary[ soundToPlay ] then 
        GAMEMODE.SoundLibrary[ soundToPlay ] = true
        sound.Add( {
            name = soundToPlay,
            channel = CHAN_VOICE, --may need to set to something different like _AUTO or something else
            volume = 1.0, --Soundlevel in decibels, can be 2 numbers: min and max, respectively
            level = 100, --Distance sound can be heard, 100 = no change
            pitch = 100, --Pitch of the sound, 100 = no change, can be 2 numbers: min and max, respectively
            sound = soundToPlay .. ".wav" --Soundpath
        })
    end

    if GAMEMODE.LastEmittedSounds[ ply:SteamID() ] then --If the player has emitted a sound before
        ply:StopSound( GAMEMODE.LastEmittedSounds[ ply:SteamID() ] ) --Run stop on it, even if it's no longer playing, just to be sure
    end

    ply:EmitSound( soundToPlay ) --Play the sound
    GAMEMODE.LastEmittedSounds[ ply:SteamID() ] = soundToPlay --Save the sound's name for future reference when the player has to play another sound

    timer.Create( "SoundWait" .. ply:SteamID(), 1, 1, function() --I don't want damage grunts being spammed, so there is a 1 second wait period before we can check for another sound
        timer.Remove( "SoundWait" .. ply:SteamID() )
    end)
end )

--//When a player dies, stop his last played sound, if it's still playing, and play his death sound
hook.Add( "PlayerDeath", "DeathGrunts", function( victim, inflictor, attacker )
    local team, number
    if GAMEMODE.CombinePlayerModels[ ply:GetModel() ] then
        team = "combine"
        number = 4
    elseif GAMEMODE.RebelPlayerModels[ ply:GetModel() ] then
        team = "rebels"
        number = 4
    elseif GAMEMODE.BreenPlayerModels[ ply:GetModel() ] then
        team = "breen"
        number = 1
    end

    local soundToPlay = team .. "/deathgrunt" .. math.random( number ) --This is the sound's file path we're going to play, minues the sound extension (so we can use this below)

    --If we haven't ran this sound before and saved it to my SoundLibrary table, we'll have to set it up for use in Garry's Mod's Sound library
    if not GAMEMODE.SoundLibrary[ soundToPlay ] then 
        GAMEMODE.SoundLibrary[ soundToPlay ] = true
        sound.Add( {
            name = soundToPlay,
            channel = CHAN_VOICE, --may need to set to something different like _AUTO or something else
            volume = 1.0, --Soundlevel in decibels, can be 2 numbers: min and max, respectively
            level = 100, --Distance sound can be heard, 100 = no change
            pitch = 100, --Pitch of the sound, 100 = no change, can be 2 numbers: min and max, respectively
            sound = soundToPlay .. ".wav" --Soundpath
        })
    end

    if GAMEMODE.LastEmittedSounds[ ply:SteamID() ] then --If the player has emitted a sound before
        ply:StopSound( GAMEMODE.LastEmittedSounds[ ply:SteamID() ] ) --Run stop on it, even if it's no longer playing, just to be sure
    end

    ply:EmitSound( soundToPlay ) --Play the sound
    GAMEMODE.LastEmittedSounds[ ply:SteamID() ] = soundToPlay --Save the sound's name for future reference when the player has to play another sound
end )

--//There's no supplied "On Reload" hook provided by garry's mod, so we'll make our own
hook.Add( "KeyPress", "MyOnReload", function( ply, key )
    if not key == IN_RELOAD then return end --If the key your pressing is your reload button
    local wep = ply:GetActiveWeapon()
    if GAMEMODE.BlacklistWepons[wep] then return end --If the weapon isn't blacklisted as one that doesn't get the sound played
    local clipsize = wep:GetMaxClip1()
    local currentammo = wep:Ammo1()
    
    hook.Call( "ReloadCall", nil, ply, wep, clipsize, currentammo )
end )

hook.Add( "ReloadCall", "LowAmmoCheck", function( ply, wep, clipsize, ammo )
    if ammo >= clipsize then return end --If the current weapon magazine is full, don't run the sound
    if math.random( 3 ) != 1 then return end --Only every 1 in 3 reloads should play a sound

    local team, number
    if GAMEMODE.CombinePlayerModels[ ply:GetModel() ] then
        team = "combine"
        number = 3
    elseif GAMEMODE.RebelPlayerModels[ ply:GetModel() ] then
        team = "rebels"
        number = 3
    elseif GAMEMODE.BreenPlayerModels[ ply:GetModel() ] then
        return
        --team = "breen"
        --number = 10
    end

    local soundToPlay = team .. "/reload" .. math.random( number ) --This is the sound's file path we're going to play, minues the sound extension (so we can use this below)

    --If we haven't ran this sound before and saved it to my SoundLibrary table, we'll have to set it up for use in Garry's Mod's Sound library
    if not GAMEMODE.SoundLibrary[ soundToPlay ] then 
        GAMEMODE.SoundLibrary[ soundToPlay ] = true
        sound.Add( {
            name = soundToPlay,
            channel = CHAN_VOICE, --may need to set to something different like _AUTO or something else
            volume = 1.0, --Soundlevel in decibels, can be 2 numbers: min and max, respectively
            level = 100, --Distance sound can be heard, 100 = no change
            pitch = 100, --Pitch of the sound, 100 = no change, can be 2 numbers: min and max, respectively
            sound = soundToPlay .. ".wav" --Soundpath
        })
    end

    if GAMEMODE.LastEmittedSounds[ ply:SteamID() ] then --If the player has emitted a sound before
        ply:StopSound( GAMEMODE.LastEmittedSounds[ ply:SteamID() ] ) --Run stop on it, even if it's no longer playing, just to be sure
    end

    ply:EmitSound( soundToPlay ) --Play the sound
    GAMEMODE.LastEmittedSounds[ ply:SteamID() ] = soundToPlay --Save the sound's name for future reference when the player has to play another sound
end )