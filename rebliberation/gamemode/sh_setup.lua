GM.Name = "Rebel Liberation" --A take on: Protect the President
GM.Author = "Logan Christianson"
GM.Email = "lobsterlogan43@yahoo.com"
GM.Website = ""
GM.Version = "v060318"

GM.MinimumPlayers = 3 --Minimum players needed for the game to start
GM.RoundsToPlay = 10 --Amount of rounds to play before switching maps
GM.BodyguardToTerroristRatio = 0.25 --1 Bodyguard for every 3 Terrorists
GM.AdditionalGameStartWaitTime = 10 --Grace period to allow more players to join after reaching the MinimumPlayer amount
GM.PreRoundSetupLength = 30 --How long you're shown your role information
GM.RoundSetupLength = 180 --How long you can customize your loadout before the game starts
GM.PostRoundLength = 10 --How long after a round is finished before starting the next round
GM.StandardPlayerCount = 9 --Default player amount (1 President, 2 bodyguards, 3 terrorists for each bodyguard (2 * 3 = 6), for a total of 9)
GM.StandardRoundTimer = 60 * 8 --How long the game goes on for, given the standard amount of players are playing (Default: 8 minute rounds)
GM.MissingPlayerPenalty = 30 --If we're under the standard amount of players, add this time to the clock
GM.ExceedingPlayerPenalty = 15 --If we're over the standard amount of players, remove this time from the clock
GM.TerroristSpawnTimer = 20 --Number of seconds after a terrorist player's death before they can respawn

--These tables house the playermodels to play the custom character sounds for, these tables are NOT used for determining a player's player model on spawn
GM.CombinePlayerModels = {
    [ "" ] = true,
    [ "" ] = true
}
GM.RebelPlayerModels = {
    [ "" ] = true,
    [ "" ] = true
}
GM.BreenPlayerModels = {
    [ "" ] = true
}

GM.SupportedMaps = {
    --{Name = "gm_devruins", ID = 748863203}
}

GM.AttackingTeam = {
    Name = "Rebels",
    Number = 1,
    --Players = {},
    MenuTeamColor = {r = 0, g = 0, b = 0},
	MenuTeamColorLightAccent = {r = 0, g = 0, b = 0},
	MenuTeamColorDarkAccent = {r = 0, g = 0, b = 0},
	MenuTeamColorAccent = {r = 0, g = 0, b = 0}
}
GM.DefendingTeam = {
    Name = "Bodyguards",
    Number = 2,
    --Players = {},
    MenuTeamColor = {r = 0, g = 0, b = 0},
	MenuTeamColorLightAccent = {r = 0, g = 0, b = 0},
	MenuTeamColorDarkAccent = {r = 0, g = 0, b = 0},
	MenuTeamColorAccent = {r = 0, g = 0, b = 0}
}
GM.VIPTeam = {
    Name = "Wallace Breen",
    Number = 3,
    --Players = {},
    MenuTeamColor = {r = 0, g = 0, b = 0},
	MenuTeamColorLightAccent = {r = 0, g = 0, b = 0},
	MenuTeamColorDarkAccent = {r = 0, g = 0, b = 0},
	MenuTeamColorAccent = {r = 0, g = 0, b = 0}
}

if SERVER then

    --Are these even necessary any more? I set up my own tables to use.
	team.SetUp( GM.AttackingTeam.Number, GM.AttackingTeam.Name, Color( 255, 0, 0 ) )
	team.SetUp( GM.DefendingTeam.Number, GM.DefendingTeam.Name, Color( 0, 0, 255 ) )
	team.SetUp( GM.VIPTeam.Number, GM.VIPTeam.Name, Color( 0, 255, 0 ) )

	for k, v in pairs( GM.SupportedMaps ) do
		if game.GetMap() == v.Name then
			resource.AddWorkshop( tostring(v.ID) )
		end
	end
    
	resource.AddWorkshop( "" ) --Gamemode Files
end