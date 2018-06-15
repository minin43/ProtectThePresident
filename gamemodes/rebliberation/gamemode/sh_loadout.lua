if CLIENT then

    function GM:SendServerLoadout()
        net.Start( "SendLoadout" )
            net.WriteTable( self.CurrentLoadout )
        net.SendToServer()
    end

end

if SERVER then
    util.AddNetworkString( "SendLoadout" )
    util.AddNetworkString( "StartedLoadout" )
    util.AddNetworkString( "StartedLoadoutCallback" )

    GM.PlayerLoadouts = {}
    GM.VerifiedPlayerLoadouts = {}

    net.Receive( "StartedLoadout", function( len, ply )
        net.Start( "StartedLoadoutCallback" )
            net.WriteInt( 8, GM.PlayerPoints[ ply:Team() ][ ply:SteamID() ] )
        net.Send( ply )
    end )

    net.Receive( "SendLoadout", function( len, ply )
        GM.PlayerLoadouts[ ply:SteamID() ] = net.ReadTable()
        GM:VerifyLoadout( ply )
    end )

    --//Function is used to verify that the client sent us a loadout it's allowed to have
    function GM:VerifyLoadout( ply )
        local runningTotal = 0

        runningTotal = self:VerifyWeapons( ply, runningTotal )
        runningTotal = self:VerifyArmor( ply, runningTotal )
        runningTotal = self:VerifyAmmo( ply, runningTotal )
        runningTotal = self:VerifyPerks( ply, runningTotal )

        if runningTotal <= self.PlayerPoints[ ply:Team() ][ ply:SteamID() ] then
            GM.VerifiedPlayerLoadouts[ ply:SteamID() ] = GM.PlayerLoadouts[ ply:SteamID() ]
        else
            error( "Player attempted loadout with too many point spent! Player " .. ply:Nick() .. " is possible cheater.", 1 )
        end
    end

    function GM:VerifyWeapons( ply, runningTotal )
        --//Check if the weapons are all valid
        for k, v in pairs( self.PlayerLoadouts[ ply:SteamID() ].Weapons ) do
            for k2, v2 in pairs( v ) do
                if isnumber( self.WeaponsTable[ k ][ k2 ][ ply:Team() ] ) then --If the player is allowed to have it
                    runningTotal = runningTotal + self.WeaponsTable[ k ][ k2 ][ ply:Team() ] --Keep track of points spent
                else --If the player is sending a bad table, we need to know
                    v2 = false
                    error( "Player attempted loadout with non-role weapon! Player " .. ply:Nick() .. " is possible cheater.", 1 )
                end
            end
        end
        return runningTotal
    end

    function GM:VerifyArmor( ply, runningTotal )
        --//Check if the armor choice is valid
        if isnumber( self.ArmorTable[ self.PlayerLoadouts[ ply:SteamID() ].Armor ][ ply:Team() ] ) then
            runningTotal = runningTotal + self.ArmorTable[ self.PlayerLoadouts[ ply:SteamID() ].Armor ][ ply:Team() ]
        else
            self.PlayerLoadouts[ ply:SteamID() ].Armor = "Light Armor"
            error( "Player attempted loadout with non-role armor! Player " .. ply:Nick() .. " is possible cheater.", 1 )
        end
        return runningTotal
    end

    function GM:VerifyAmmo( ply, runningTotal )
        --//Check if the ammo choices are valid
        for k, v in pairs( self.PlayerLoadouts[ ply:SteamID() ].Ammo ) do
            if isnumber( self.AmmoTable[ k ][ ply:Team() ] ) then
                runningTotal = runningTotal + ( self.AmmoTable[ k ][ ply:Team() ] * v )
            else
                v = 0
                error( "Player attempted loadout with non-role ammo! Player " .. ply:Nick() .. " is possible cheater.", 1 )
            end
        end
        return runningTotal
    end

    function GM:VerifyPerks( ply, runningTotal )
        for k, v in pairs( self.PlayerLoadouts[ ply:SteamID() ].Perks ) do
            if isnumber( self.PerksTable[ k ][ ply:Team() ] ) then
                runningTotal = runningTotal + self.PerksTable[ k ][ ply:Team() ]
            else
                v = false
                error( "Player attempted loadout with non-role perk! Player " .. ply:Nick() .. " is possible cheater.", 1 )
            end
        end
        return runningTotal
    end
end

GM.WeaponsTable = { --Points required for: team 1, team 2, team 3. 0 = No Cost/Default, nil = Restricted, -# = Extra points given.
    Primary = {
        [ "weapon_smg1" ] = { 1, 1, nil },
        [ "weapon_ar2" ] = { 1, 1, nil },
        [ "weapon_shotgun" ] = { 1, 1, nil }
    },
    Secondary = {
        [ "weapon_pistol" ] = { 0, 0, nil },
        [ "weapon_357" ] = { 1, 1, nil }
    },
    Tertiary = {
        [ "weapon_frag" ] = { 1, 1, nil },
        [ "weapon_slam" ] = { 1, 1, nil },
        [ "" ] = { nil, 1, nil }, --Manhack
        [ "" ] = { nil, 1, nil }, --Ground turret
        [ "" ] = { nil, 1, nil } --Ceiling turret
    }
}

GM.AmmoTable = { --4th value is how much exra ammo you get
    [ "item_ammo_357" ] = { 1, 1, nil, 12 },
    [ "item_ammo_smg1" ] = { 1, 1, nil, 90 },
    [ "item_ammo_ar2" ] = { 1, 1, nil, 60 },
    [ "item_box_buckshot" ] = { 1, 1, nil, 12 },
    [ "item_ammo_smg1_grenade" ] = { nil, 3, nil, 2 },
    [ "item_ammo_ar2_altfire" ] = { nil, 3, nil, 2 }
}

GM.ArmorTable = { --4th value is the armor description
    [ "Light Armor" ] = { 0, -1, 0, "Reduces damage to the chest." },
    [ "Combat Armor" ] = { 1, 0, 1, "Reduces damage to the head and chest." },
    [ "Heavy Armor" ] = { 1, 1, 1, "Moderately reduces damage to head and chest, and lightly to arms and legs." },
    [ "Power Armor" ] = { nil, 1, 1, "Can be charged with suit power to fully absorb some damage taken." },
    [ "Elite Armor" ] = { nil, 1, 1, "Power armor underlayed with Combat armor." },
}

GM.PerksTable = { --4th value is the skill description
    --Terrorist-only Skills
    [ "Remove Sight-Inhibitor Chip" ] = { 2, nil, nil, "Remove the Combine-implanted eye-socket microchip, returning full use of your peripheral vision" }, --Removes FOV modifier
    [ "Remove Stamina-Inhibitor Chip" ] = { 3, nil, nil, "Remove the Combine-implanted brain microchip, allowing full control of your cardiovascular and motor systems." }, --Allow sprinting
    [ "Endocrine Booster" ] = { 3, nil, nil, "Otherwise known as adrenaline, inject to double the amount of damage your system can receive before failing." }, --2x health
    --[ "Goal Sensor" ] = { 1, nil, nil, "" }, --This allows terrorist players to locate the president, but maybe I can just have him emit a sound every 30 seconds or so?
    --[ "" ] = { 1, nil, nil, "" },

    --President-only skills
    [ "Recovery Nano-Machine Injection" ] = { nil, nil, 2, "Inject a small dose of nano-machines into your blood-stream, which slowly mend damage to your body over time." },

    --Bodyguard-only skills
    [ "Discarded Munition Identifier" ] = { nil, 1, nil, "Outfit your suit visor to locate discarded munitions that can be scavenged off terrorist corpses." }, --HUD spots out spare ammo

    --Shared skills
    [ "Stride Enhancement Device" ] = { 1, 1, 1, "Increases the rate at which you normally move." }, --Increases walk speed
    [ "Stride Enhancement Device V.2" ] = { 1, 1, 1, "Increases the speed at which you can sprint." }, --Increase sprint speed
    [ "Respiratory Rejuvenation" ] = { 1, 1, 1, "Your red blood cells can carry more oxygen, increasing your body's stamina regenartion." }, --Decrease the time it takes to regain your stamina
    [ "Biometric 3D Locating" ] = { nil, 1, 1, "Mount a headpiece on yourself that allows you to see a 3D representation of your allies through walls." } --See teammates through walls
}