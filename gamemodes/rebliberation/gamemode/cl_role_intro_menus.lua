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

    local RoleName, RoleObjective, RoleDescription
    if LocalPlayer():Team() == 1 then
        RoleName = "You are a rebel fight."
        RoleObjective = "Your objective is to eliminate Wallace Breen at all costs."
        RoleDescription = ( "You will start off weak, but will earn points as the game progresses, based on several events that happen throughout it. Use these points to upgrade your arsenal, "
            .. "or spend them to remove your handicaps." )
    elseif LocalPlayer():Team() == 2 then
        local tag1, tag2, tag3
        tag1 = string.upper( string.sub( GAMEMODE.CombineSignatures[ ply:SteamID() ][ 1 ], 1, 1 ) ) .. string.sub( GAMEMODE.CombineSignatures[ ply:SteamID() ][ 1 ], 2 )
        tag2 = string.upper( string.sub( GAMEMODE.CombineSignatures[ ply:SteamID() ][ 2 ], 1, 1 ) ) .. string.sub( GAMEMODE.CombineSignatures[ ply:SteamID() ][ 2 ], 2 )
        tag3 = string.upper( string.sub( GAMEMODE.CombineSignatures[ ply:SteamID() ][ 3 ], 1, 1 ) ) .. string.sub( GAMEMODE.CombineSignatures[ ply:SteamID() ][ 3 ], 2 )

        RoleName = "You are Bodyguard Unit " .. tag1 .. "-" .. tag2 .. "-" .. tag3 .. "."
        RoleObjective = "Your objective is to keep Wallace Breen alive until he can be extracted from the area."
        RoleDescription = "Use the best gear you can. You don't respawn, and your resources are finite. Communication between your fellow bodyguards and Breen is key to being successful."
    elseif LocalPlayer():Team() == 3 then
        RoleName = "You are Doctor Wallace Breen."
        RoleObjective = "Your objective is to stay alive long enough for your extraction to arrive."
        RoleDescription = "You have no way to defend yourself, no weapons. You must rely on communication with your bodyguards to keep you alive; do not forget this."
    end

    timer.Simple( 2, function()
        --//The main panel, everything is parented to this
        self.Main = vgui.Create( "DFrame" )
        self.Main:SetSize( ScrW(), ScrH() )
        self.Main:SetTitle( "" )
        self.Main:SetVisible( true )
        self.Main:SetDraggable( false )
        self.Main:ShowCloseButton( false )
        self.Main:MakePopup()
        self.Main:Center()
        self.MainX, self.MainY = self.Main:GetPos()
        self.Main.Paint = function()
            surface.SetDrawColor( 0, 0, 0, 255 )
            surface.DrawRect( 0, 0, self.Main:GetWide(), self.Main:GetTall() )
        end
        self:PlayIntroSoundSequence()

        

        timer.Simple( self.PreRoundSetupLength, function()
            --
        end )
    end )
end

--//Disables players from typing during round intro sequence
function GM:StartChat( IsTeamChat )
    if self.DisableChatbox then
        return false
    end
end

local buh = GM.StandardRoleIntro
net.Receive( "RunRoleIntroductionNetMessage", GM.StandardRoleIntro )