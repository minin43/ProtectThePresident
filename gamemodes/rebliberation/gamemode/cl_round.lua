--//Set up all the hook calls for the server's round events, so clients have some self control
net.Receive( "OnGameStartHook", function()
    hook.Call( "OnGameStart", GAMEMODE )
end )

net.Receive( "OnRoundSetupHook", function()
    hook.Call( "OnRoundSetup", GAMEMODE )
end )

net.Receive( "OnRoundStartHook", function()
    hook.Call( "OnRoundStart", GAMEMODE )
end )

net.Receive( "OnRoundEndHook", function()
    hook.Call( "OnRoundEnd", GAMEMODE )
end )

net.Receive( "OnGameEndHook", function()
    hook.Call( "OnGameEnd", GAMEMODE )
end )

--//When round is being set up, we want a client-side timer counting down the time until the round starts
--//Note that this ISN'T syncronized with the initial menu, despite the menu utilizing selfSetupTimeLeft
hook.Add( "OnRoundSetup", function()
    self.SetupTimeLeft = self.PreRoundSetupLength + self.RoundSetupLength

    timer.Create( "RoundCountdown", 1, 0, function()
        self.SetupTimeLeft = self.SetupTimeLeft - 1
        if self.SetupTimeLeft == 0 then
            timer.Remove( "RoundCountdown" )
        end
    end )
end )