GM.SetupTimeLeft = 0
GM.CurrentLoadout = {
    Weapons = {
        Primary = {},
        Secondary = {},
        Tertiary = {}
    },
    Ammo = {},
    Perks = {},
    Armor = ""
}

function GM:PlayIntroSoundSequence()
    print( "Received function PlayIntroSoundSequence, player team: ", LocalPlayer():Team() )
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
--//NOTE: For testing, you can't just set to team 2, that requires running with a sent table
function GM:StandardRoleIntro()
    local CombineIDInfo = {}
    if LocalPlayer():Team() == 2 then --If we're a bodyguard, we're expecting some information regarding our combine ID
        CombineIDInfo = net.ReadTable()
        print( "Detected LocalPlayer being on team 2" )
        PrintTable( CombineIDInfo )
    end

    if GAMEMODE.Main and GAMEMODE.Main:IsValid() then return end --If the menu is already opened, and for some reason it gets called to open another time, ignore it

    --if not self.GameInProgress then return end --If a game isn't being played, no reason to run the function - CAN'T RUN THIS, GAMEINPROGRESS NOT SHARED WITH CLIENTS

    --If the player isn't on a valid team
    if LocalPlayer():Team() != 1 and LocalPlayer():Team() != 2 and LocalPlayer():Team() != 3 then error( "Player not on a valid team - check with gamemode developer!", 2 ) end 

    for k, v in pairs( player.GetAll() ) do --Force mute all players while the intro is played
        v:SetMuted( true )
    end
    GAMEMODE.DisableChatbox = true

    LocalPlayer():ScreenFade( SCREENFADE.OUT, Color( 0, 0, 0, 255 ), 3, 1 )

    local IDTable = {}
    if LocalPlayer():Team() == 2 then
        IDTable[ 1 ] = string.upper( string.sub( CombineIDInfo[ 1 ], 1, 1 ) ) .. string.sub( CombineIDInfo[ 1 ], 2 )
        IDTable[ 2 ] = string.upper( string.sub( CombineIDInfo[ 2 ], 1, 1 ) ) .. string.sub( CombineIDInfo[ 2 ], 2 )
        IDTable[ 3 ] = string.upper( string.sub( CombineIDInfo[ 3 ], 1, 1 ) ) .. string.sub( CombineIDInfo[ 3 ], 2 )
    end

    timer.Simple( 3.1, function()
        --//The main panel, everything is parented to this
        GAMEMODE.Main = vgui.Create( "DFrame" )
        GAMEMODE.Main:SetSize( ScrW(), ScrH() )
        GAMEMODE.Main:SetPos( 0, 0 )
        GAMEMODE.Main:SetTitle( "" )
        GAMEMODE.Main:SetVisible( true )
        GAMEMODE.Main:SetDraggable( false )
        GAMEMODE.Main:ShowCloseButton( false )
        --GAMEMODE.Main:MakePopup() --I think this enables mouse cursor, we don't want it immediately
        --GAMEMODE.Main:Center()
        GAMEMODE.MainX, GAMEMODE.MainY = GAMEMODE.Main:GetPos()
        GAMEMODE.Main.Paint = function()
            surface.SetDrawColor( 0, 0, 0, 255 )
            surface.DrawRect( 0, 0, GAMEMODE.Main:GetWide(), GAMEMODE.Main:GetTall() )
        end
        GAMEMODE:PlayIntroSoundSequence()

        timer.Simple( 0.75, function()
            GAMEMODE.MainRoleIntro = vgui.Create( "RolePanel", GAMEMODE.Main )
            GAMEMODE.MainRoleIntro:SetSize( GAMEMODE.Main:GetWide(), GAMEMODE.Main:GetTall() )
            GAMEMODE.MainRoleIntro:SetPos( 0, 0 )
            GAMEMODE.MainRoleIntro:SetTeam( LocalPlayer():Team(), IDTable )
        end )

        timer.Simple( GAMEMODE.PreRoundSetupLength - 3.1, function()
            GAMEMODE.SetupTimeLeft = GAMEMODE.RoundSetupLength - 2
            timer.Create( "Menu Countdown Timer", 1, 0, function()
                if GAMEMODE.SetupTimeLeft == 0 then timer.Remove( "Menu Countdown Timer" ) end
                GAMEMODE.SetupTimeLeft = GAMEMODE.SetupTimeLeft - 1
            end )

            GAMEMODE.MainRoleIntro:Remove()
            GAMEMODE:StartLoadout( true ) --< Called below

            for k, v in pairs( player.GetAll() ) do --Unmute all players after intro has played
                v:SetMuted( false )
            end
            GAMEMODE.DisableChatbox = false --Enable chatbox after intro

            timer.Simple( GAMEMODE.RoundSetupLength - 2, function() --After the round setup is finished, force close loadout menu
                GAMEMODE.Main:Remove()
                net.Send( "SetLoadout" )
                    net.WriteTable( GAMEMODE.CurrentLoadout )
                net.SendToServer()
            end )
        end )
    end )
end

function GM:StartLoadout( initialLoadout )
    --//We want to choose a color theme for the menu
    print( "StartLoadout Called" )
    if LocalPlayer():Team() == 1 then
        self.MyTheme = self.RebelThemes[ math.random( #self.RebelThemes ) ]
    elseif LocalPlayer():Team() == 2 then
        self.MyTheme = self.CombineThemes[ math.random( #self.CombineThemes ) ]
    else
        self.MyTheme = self.BreenThemes[ math.random( #self.BreenThemes ) ]
    end
    print( "Player team - ", LocalPlayer():Team(), self.MyTheme )

    net.Start( "StartedLoadout" )
    net.SendToServer()

    net.Receive( "StartedLoadoutCallback", function()
        print( "CLIENT received StartedLoadoutCallback" )
        self.TotalPoints = net.ReadInt( 8 )
        self.SpentPoints = self.SpentPoints or 0
        print( "Total Points available: ", self.TotalPoints )
        print( "Spent points: ", self.SpentPoints )

        if initialLoadout then --If we're opening the loadout during round prep
            self.SecondMain = vgui.Create( "DPanel", self.Main )
            self.Main:MakePopup()
            self.SecondMain:SetPos( self.Main:GetWide() / 8, self.Main:GetTall() / 8 )
            self.SecondMain:SetSize( self.Main:GetWide() / 4 * 3, self.Main:GetTall() / 4 * 3 )
            self.SecondMain.Paint = function()
                draw.SimpleText( LocalPlayer():Nick(), "DermaDefault", 52, 52 / 2, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                draw.SimpleText( "Time left: " .. self.SetupTimeLeft .. " second(s)", "DermaDefault", self.SecondMain:GetWide() / 2, 52 / 2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) --To finish
                draw.SimpleText( "Points Remaining: " .. ( self.TotalPoints - self.SpentPoints ), "DermaDefault", self.SecondMain:GetWide() - 4, 52 / 2, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
            end
        else --If it's in the middle of the round, it's gonna need to be a standalone frame
            self.SecondMain = vgui.Create( "DFrame" )
            self.SecondMain:SetTitle( "" )
            self.SecondMain:SetVisible( true )
            self.SecondMain:SetDraggable( false )
            self.SecondMain:ShowCloseButton( false )
            self.SecondMain:MakePopup()
            self.SecondMain:Center()
            self.SecondMain:SetSize( Scrw() / 4 * 3, ScrH() / 4 * 3 )
            self.SecondMain.Paint = function()
                draw.SimpleText( LocalPlayer():Nick(), "DermaDefault", 52, 52 / 2, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                draw.SimpleText( "Points Remaining: " .. ( self.TotalPoints - self.SpentPoints ), "DermaDefault", self.SecondMain:GetWide() - 4, 52 / 2, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
            end

            self.SecondMainButton = vgui.Create( "DButton", self.SecondMain )
            self.SecondMainButton:SetPos()
            self.SecondMainButton:SetSize()
            self.SecondMainButton.DoClick = function()
                net.Send( "SetLoadout" )
                    net.WriteTable( self.CurrentLoadout )
                net.SendToServer()
                self.SecondMainButton:Close()
            end
            self.SecondMainButton.SetText( "Spawn" )
            --[[self.SecondMainButton.Paint = function()

            end]]
        end

        self.SecondMainAvatar = vgui.Create( "AvatarImage", self.SecondMain )
        self.SecondMainAvatar:SetPlayer( LocalPlayer() )
        self.SecondMainAvatar:SetSize( 50 - 4, 50 - 4 )
        self.SecondMainAvatar:SetPos( 2, 2 )

        self.SecondMainRight = vgui.Create( "PerksSidePanel", self.SecondMain )

        if LocalPlayer():Team() != 3 then
            self.SecondMainRight:SetSize( self.SecondMain:GetWide() / 2, self.SecondMain:GetTall() - 50 )
            self.SecondMainRight:SetPos( self.SecondMain:GetWide() / 2, 50 )

            self.SecondMainLeft = vgui.Create( "WeaponsSidePanel", self.SecondMain )
            self.SecondMainLeft:SetSize( self.SecondMain:GetWide() / 2, self.SecondMain:GetTall() - 50 )
            self.SecondMainLeft:SetPos( 0, 50 )
            self.SecondMainLeft:SetWeaponsLists( self:FilterTableByTeam( self.WeaponsTable.Primary ), self:FilterTableByTeam( self.WeaponsTable.Secondary ), self:FilterTableByTeam( self.WeaponsTable.Tertiary ) )
        else
            self.SecondMainRight:SetSize( self.SecondMain:GetWide(), self.SecondMain:GetTall() - 50 )
            self.SecondMainRight:SetPos( 0, 50 )
        end

        self.SecondMainRight:SetLists( self:FilterTableByTeam( self.ArmorTable ), self:FilterTableByTeam( self.PerksTable ) ) --SetLists needs to be ran AFTER we give SecondMainRight sizes

    end )
end

function GM:FilterTableByTeam( UnfilteredTable )
    print( "Function GAMEMODE:FilterTableByTeam called" )
    local position = LocalPlayer():Team()
    local FilteredTable = {}
    print( "DB1: ", position, FilteredTable )

    for k, v in pairs( UnfilteredTable ) do
        print( "k, v = ", k, v )
        print( "isnumber( v[ position ] ): ", isnumber( v[ position ] ) )
        if isnumber( v[ position ] ) then
            FilteredTable[ k ] = v
            print( "FilteredTable[ k ] = v " )
        end
    end
    PrintTable( FilteredTable )
    return FilteredTable
end

--//Disables players from typing during round intro sequence
function GM:StartChat( IsTeamChat )
    if self.DisableChatbox then
        return true
    end
end

net.Receive( "RunRoleIntroductionNetMessage", GM.StandardRoleIntro )