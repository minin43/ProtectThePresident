GM.LoadoutOptions = { --[[  FORMAT
    Points == 0 // The number of points the player can spend on the below weapons & perks
    Weapons = {
        Primary = {} // All the primary weapons the player can use
        Secondary = {} // All the secondary weapons the player can use
        Tertiary = {} // All the tertiary weapons the player can use
    }
    Armor = {} // All armor types
    Ammo = {} //All additional ammo by type
    Perks = {} // All the available perks (and handicap removals) the player can choose
]]}
GM.CurentLoadout = {} --Same format as above, we're just sending it to the server


function GM:PlayIntroSoundSequence()
    if LocalPlayer():Team() == 1 then
        surface.PlaySound( "rebels/roundstart1.wav" )
        timer.Simple( 6, function()
            surface.PlaySound( "rebels/roundstart2.wav" )
            timer.Simple( 5, function()
                surface.PlaySound( "rebels/roundstart3.wav" )
            end )
        end )
    elseif LocalPlayer():Team() == 2 then
        surface.PlaySound( "combine/roundstart.wav" )
    elseif LocalPlayer():Team() == 3 then
        surface.PlaySound( "breen/roundstart.wav" )
    end
end

--//This function is used to play the standard role "introduction" sequence for the player it's asked to run on - works dynamically, regardless of player's team
function GM:StandardRoleIntro()
    local CombineIDInfo
    if LocalPlayer():GetTeam() == 2 then --If we're a bodyguard, we're expecting some information regarding our combine ID
        CombineIDInfo = net.ReadTable()
    end

    if self.Main and self.Main:IsValid() then return end --If the menu is already opened, and for some reason it gets called to open another time, ignore it

    --if not self.GameInProgress then return end --If a game isn't being played, no reason to run the function - CAN'T RUN THIS, GAMEINPROGRESS NOT SHARED WITH CLIENTS

    --If the player isn't on a valid team
    if LocalPlayer():Team() != 1 and LocalPlayer():Team() != 2 and LocalPlayer():Team() != 3 then error( "Player not on a valid team - check with gamemode developer!", 2 ) end 

    for k, v in pairs( player.GetAll() ) do --Force mute all players while the intro is played
        v:Mute( true )
    end
    self.DisableChatbox = true

    LocalPlayer():ScreenFade( SCREENFADE.OUT, Color( 0, 0, 0, 255 ), 1, 3 )
    timer.Simple( 2.95, function()
        LocalPlayer():ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 2, 0 )
    end )

    local IDTable = {}
    if LocalPlayer():Team() == 2 then
        IDTable[ 1 ] = string.upper( string.sub( GAMEMODE.CombineSignatures[ ply:SteamID() ][ 1 ], 1, 1 ) ) .. string.sub( GAMEMODE.CombineSignatures[ ply:SteamID() ][ 1 ], 2 )
        IDTable[ 2 ] = string.upper( string.sub( GAMEMODE.CombineSignatures[ ply:SteamID() ][ 2 ], 1, 1 ) ) .. string.sub( GAMEMODE.CombineSignatures[ ply:SteamID() ][ 2 ], 2 )
        IDTable[ 3 ] = string.upper( string.sub( GAMEMODE.CombineSignatures[ ply:SteamID() ][ 3 ], 1, 1 ) ) .. string.sub( GAMEMODE.CombineSignatures[ ply:SteamID() ][ 3 ], 2 )
    end

    timer.Simple( 2, function()
        --//The main panel, everything is parented to this
        self.Main = vgui.Create( "DFrame" )
        self.Main:SetSize( ScrW(), ScrH() )
        self.Main:SetPos( 0, 0 )
        self.Main:SetTitle( "" )
        self.Main:SetVisible( true )
        self.Main:SetDraggable( false )
        self.Main:ShowCloseButton( false )
        --self.Main:MakePopup() --I think this enables mouse cursor, we don't want it immediately
        --self.Main:Center()
        self.MainX, self.MainY = self.Main:GetPos()
        self.Main.Paint = function()
            surface.SetDrawColor( 0, 0, 0, 255 )
            surface.DrawRect( 0, 0, self.Main:GetWide(), self.Main:GetTall() )
        end
        self:PlayIntroSoundSequence()

        self.MainRoleIntro = vgui.Create( "RolePanel", self.Main )
        self.MainRoleIntro:SetSize( self.Main:GetWide(), self.Main:GetTall() )
        self.MainRoleIntro:SetPos( 0, 0 )
        self.MainRoleIntro:SetTeam( LocalPlayer():Team(), IDTable )

        timer.Simple( self.PreRoundSetupLength, function()
            self.MainRoleIntro:Remove()
            self:StartLoadout( true ) --< Called below

            for k, v in pairs( player.GetAll() ) do --Unmute all players after intro has played
                v:Mute( false )
            end
            self.DisableChatbox = false --Enable chatbox after intro

            timer.Simple( self.RoundSetupLength, function() --After the round setup is finished, force close loadout menu
                self.Main:Remove()
                net.Send( "SetLoadout" )
                    net.WriteTable( self.CurentLoadout )
                net.SendToServer()
            end )
        end )
    end )
end

function GM:StartLoadout( initialLoadout )
    net.Start( "StartedLoadout" )
    net.SendToServer()

    net.Receive( "StartedLoadoutCallback", function()
        self.TotalPoints = net.ReadInt()
        self.SpentPoints = self.SpentPoints or 0

        if initialLoadout then
            self.SecondMain = vgui.Create( "LoadoutMenuPanel", self.Main )
            self.Main:MakePopup()
        else
            self.SecondMain = vgui.Create( "LoadoutMenuFrame" )
        end

    end )
end

--//Disables players from typing during round intro sequence
function GM:StartChat( IsTeamChat )
    if self.DisableChatbox then
        return true
    end
end

net.Receive( "RunRoleIntroductionNetMessage", GM.StandardRoleIntro )