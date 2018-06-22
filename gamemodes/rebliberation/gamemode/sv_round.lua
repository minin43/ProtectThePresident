util.AddNetworkString( "RunRoleIntroductionNetMessage" )
util.AddNetworkString( "OnGameStartHook" )
util.AddNetworkString( "OnRoundSetupHook" )
util.AddNetworkString( "OnRoundStartHook" )
util.AddNetworkString( "OnRoundEndHook" )
util.AddNetworkString( "OnGameEndHook" )

GM.LastWinners = {}

hook.Add( "PlayerInitialSpawn", "SetupGamemode", function( ply )
    GAMEMODE.JoiningPlayers = GAMEMODE.JoiningPlayers or {}
    GAMEMODE.JoiningPlayers[ply:SteamID()] = true
end )

hook.Add( "PlayerSpawn", "InitialSpawn", function( ply )
    if not GAMEMODE.GameInProgress then --If there isn't a game currently running
        if GAMEMODE.JoiningPlayers[ply:SteamID()] then --If the player spawning is only just joining
            print( ply:Nick() .. " has fully connected to the game." )
            for k, v in pairs( player.GetAll() ) do
                v:ChatPrint( "[RL]: " .. ply:Nick() .. " has fully connected to the game." )
            end
            --ply:KillSilent() --May need to remove
            GAMEMODE.JoiningPlayers[ply:SteamID()] = false
            if #player.GetAll() >= GAMEMODE.MinimumPlayers then --If the current amount of players exceeds the minimum required to play
                GAMEMODE:StartGame()
            end
        end
    else --If there IS a game in progress
        if GAMEMODE.JoiningPlayers[ply:SteamID()] then --If the player spawning is only just joining
            print( ply:Nick() .. " has fully connected to the game." )
            for k, v in pairs( player.GetAll() ) do
                v:ChatPrint( "[RL]: " .. ply:Nick() .. " has fully connected to the game." )
            end
            GAMEMODE.JoiningPlayers[ply:SteamID()] = false
            ply:SetTeam( 1 ) --A player can't be assigned as president or a bodyguard halfway through the round, so auto-set them to terrorist team
            self:SetNewJoinPoints( ply )
            self:RunRoleIntroduction( ply )
        end
    end
end )

--//Sets up the teams when the round initially starts (for Breen, bodyguards, and terrorists)
function GM:InitiallySetupTeams()
    if not self.GameInProgress then return end
    PlayerTable = player.GetAll()

    --Random player is assigned Breen role - it's a special role, but not enough to warrant forcing aversion in a win
    local randomNum = math.random( #PlayerTable )
    local breenPlayer = PlayerTable[ randomNum ]
    breenPlayer:SetTeam( 3 )
    table.remove( PlayerTable, randomNum )

    --We won't allow players who succeeded as Bodyguards to play as that role twice in a row - make it fair for others
    local numberOfGuards = math.ceil( math.Clamp( #PlayerTable * self.BodyguardToTerroristRatio, 1, 1000 ) )
    local guardsSelected, counter = 0, 0
    while guardsSelected != numberOfGuards do
        randomNum = math.random( #PlayerTable )
        selectedPlayer = PlayerTable[ randomNum ]
        if not self.LastWinners[ selectedPlayer ] then --If the player isn't a part of the "last round winners" table, let them be a guard
            selectedPlayer:SetTeam( 2 )
            guardsSelected = guardsSelected + 1
            table.remove( PlayerTable, randomNum )
        end

        if counter >= 100 then --I cap it at 100 to prevent extreme scenarios where maybe all but previous winners may all have randomly left the game
            selectedPlayer:SetTeam( 2 )
            guardsSelected = guardsSelected + 1
            table.remove( PlayerTable, randomNum )
        end
        counter = counter + 1
    end
    self:AssignCombineID( team.GetPlayers( 2 ) )

    --For all of the players that weren't assigned as Breen of a Bodyguard, set to the attacking terrorits
    for k, v in pairs( PlayerTable ) do
        v:SetTeam( 1 )
    end
end

--//Call this when any single or table of players needs their role indroduction played
function GM:RunRoleIntroduction( ply )
    --if not self.GameInProgress then return end --Prevent this from being sent if game isn't running
    --//^^^TEMPORARILY DISABLED WHILE I TEST IT^^^

    --//We're to assume teams have already been assigned by the time this is run
    net.Start( "RunRoleIntroductionNetMessage" )
        if ply:Team() == 2 then
            net.WriteTable( self.CombineSignatures[ ply:SteamID() ] ) --If the player is a bodyguard, send them their combine ID
        end
    net.Send( ply )

end

--//This function can be ran for any event where the game ought to start; by default, it's used when players spawn in - can be used in other fashions
function GM:StartGame()
    timer.Simple( self.AdditionalGameStartWaitTime, function()
        self.GameInProgress = true --If a game is in progress, used in determining starting/stopping of gamemode
        self.RoundInProgress = false --If a round is currently running, used in determining other logic

        self:SetupRound()
        self.CurrentRound = 0
        SetGlobalInt( "RoundTime", 0 )
    end )
    hook.Call( "OnGameStart", self )
    net.Start( "OnGameStartHook" ) net.Send( player.GetAll() )
end

--//This function does the logic for the "pre-round," where players are put into their teams, notified of their role, and get to choose their loadout
function GM:SetupRound()
    if not self.GameInProgress then return end
    self:InitiallySetupTeams() --MUST be ran before RunRoleIntroduction (found 4 lines below), if the combine radio chatter is to be properly sent to clients

    self.CurrentRound = self.CurrentRound + 1

    self:RunRoleIntroduction( player.GetAll() ) --Quick developer note: function param is set as "ply" not a table, but net.Send can accept tables of players, so this still works
    self:AssignStartingPoints()

    timer.Simple( self.PreRoundSetupLength + self.RoundSetupLength, function()
        self:StartRound()
    end )

    hook.Call( "OnRoundSetup", self )
    net.Start( "OnRoundSetupHook" ) net.Send( player.GetAll() )
end

--//This function starts the round - surprise!
function GM:StartRound()
    if not self.GameInProgress then return end
    self.RoundInProgress = true
    self:CheckGameValidityAfterPlayerLeave() --Running this here, just in case someone important disconnects in the middle of the preround

    --After a certain length of time, the "extraction" arrives and the player who's Breen can enter it to escape and win
    local TimeUntilExtraction = self.StandardRoundTimer + ( self.MissingPlayerPenalty * math.abs( self.StandardPlayerCount - #player.GetAll()  ) ) + ( self.ExceedingPlayerPenalty * math.abs(#player.GetAll() - self.StandardPlayerCount) )
    SetGlobalInt( "RoundTime", TimeUntilExtraction )
    timer.Create( "Time Countdown", 1, 0, function()

        SetGlobalInt( "RoundTime", GetGlobalInt( "RoundTime" ) - 1 ) --Every second, reduce the RoundTime by 1 second

        if GetGlobalInt( "RoundTime" ) == math.Round( TimeUntilExtraction * 3 / 4 ) then --At 1/4 of the time having been passed
            self:AddToAllTerroristPoints( self.TerroristTimeBonus )
            for k, v in pairs( player.GetAll() ) do

            end
        elseif GetGlobalInt( "RoundTime" ) == math.Round( TimeUntilExtraction * 2 / 4 ) then --At 1/2 of the time having been passed
            self:AddToAllTerroristPoints( self.TerroristTimeBonus )
            for k, v in pairs( player.GetAll() ) do

            end
        elseif GetGlobalInt( "RoundTime" ) == math.Round( TimeUntilExtraction * 1 / 4 ) then --At 3/4 of the time having been passed
            self:AddToAllTerroristPoints( self.TerroristTimeBonus )
            for k, v in pairs( player.GetAll() ) do

            end
        elseif GetGlobalInt( "RoundTime" ) == 10 then --At 10 seconds remaining
            for k, v in pairs( player.GetAll() ) do

            end
        elseif GetGlobalInt( "RoundTime" ) == 0 then
            SetGlobalInt( "RoundTime", 0 )
            timer.Remove( "Time Countdown" )
        end
    end )

    hook.Call( "OnRoundStart", self )
    net.Start( "OnRoundStartHook" ) net.Send( player.GetAll() )
end

--//This function is called when a round has completed, and one of the sides is victorious
function GM:EndRound( WinningTeam )
    if not self.GameInProgress then return end
    self.RoundInProgress = false
    timer.Remove( "Time Countdown" )

    if WinningTeam == 1 then --If the Terrorists win    [RL]: 
        for k, v in pairs( player.GetAll() ) do
            v:ChatPrint( "[RL]: Round over. Rebels eliminated Dr. Breen before he could escape. Rebels win!" )
        end
    elseif WinningTeam == 2 or WinningTeam == 3 then --If Breen survives and makes the extraction
        for k, v in pairs( team.GetPlayers( 2 ) ) do
            self.LastWinners[v] = true --Any player that was a bodyguard will not allowed to be one next game
        end
        for k, v in pairs( player.GetAll() ) do
            v:ChatPrint( "[RL]: Round over. Dr. Breen escaped before the rebels could eliminate him. Breen and Bodyguards win!" )
        end
    else --If enough players leave that any team has no players in it
        for k, v in pairs( player.GetAll() ) do
            v:ChatPrint( "[RL]: Round over. Something unexpected occured. No winner." )
        end
    end

    timer.Simple( self.PostRoundLength, function()
        if self.CurrentRound == self.RoundsToPlay then --If we've reached our limit of rounds to play before switching maps
            self:EndGame()
        else
            self:SetupRound() -- Else, start the setup for the next round
        end
    end )

    hook.Call( "OnRoundEnd", self )
    net.Start( "OnRoundEndHook" ) net.Send( player.GetAll() )
end

function GM:EndGame()
    if not self.GameInProgress then return end
    self.GameInProgress = false
    for k, v in pairs( player.GetAll() ) do
        v:ChatPrint( "[RL]: Game's over. Thanks for playing! Vote for a new map if additional supported maps are installed on the server." )
    end

    hook.Call( "OnGameEnd", self )
    net.Start( "OnGameEndHook" ) net.Send( player.GetAll() )
end