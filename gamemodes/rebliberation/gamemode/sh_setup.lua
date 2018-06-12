GM.Name = "Rebel Liberation" --A take on: Protect the President
GM.Author = "Logan Christianson"
GM.Email = "lobsterlogan43@yahoo.com"
GM.Website = ""
GM.Version = "v061218"

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

GM.StartingTerroristPoints = 1 --Number of points terrorist players start the game off with
GM.StartingBodyguardPoints = 10 --Number of points bodyguard players start the game off with
GM.StartingPresidentPoints = 3 --Number of points president player starts the game off with
GM.TerroristTimeBonus = 5 --Number of points the terrorists receive at every 1/4 time interval
GM.TerroristKillbonus = 3 --Number of points a terrorist receives for killing a bodyguard
GM.TerroristDeathRequirement = 3 --How many times a terrorist needs to die to a bodyguard/president before receing additional points
GM.TerroristDeathBonus = 1 --The additional points the terrorist receives from the aforementioned event

--These tables house the playermodels to play the custom character sounds for, these tables are NOT used for determining a player's player model on spawn
--Feel free to add more if you have them spawn as other models
GM.CombinePlayerModels = {
    [ "models/player/combine_soldier.mdl" ] = true,
    [ "models/player/combine_soldier_prisonguard.mdl" ] = true,
    [ "models/player/combine_super_soldier.mdl" ] = true,
    [ "models/player/police.mdl" ] = true
}
GM.RebelPlayerModels = {
    [ "models/player/group03/male_01.mdl" ] = true,
    [ "models/player/group03/male_02.mdl" ] = true,
    [ "models/player/group03/male_03.mdl" ] = true,
    [ "models/player/group03/male_04.mdl" ] = true,
    [ "models/player/group03/male_05.mdl" ] = true,
    [ "models/player/group03/male_06.mdl" ] = true,
    [ "models/player/group03/male_07.mdl" ] = true,
    [ "models/player/group03/male_08.mdl" ] = true,
    [ "models/player/group03/male_09.mdl" ] = true
}
GM.BreenPlayerModels = {
    [ "models/player/breen.mdl" ] = true
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