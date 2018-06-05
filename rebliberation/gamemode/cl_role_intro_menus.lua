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
    if self.Main and self.Main:IsValid() then return end --If the menu is already opened, and for some reason it gets called to open another time, ignore it

    --if not self.GameInProgress then return end --If a game isn't being played, no reason to run the function - CAN'T RUN THIS, GAMEINPROGRESS NOT SHARED WITH CLIENTS

    --If the player isn't on a valid team
    if LocalPlayer():Team() != 1 and LocalPlayer():Team() != 2 and LocalPlayer():Team() != 3 then error( "Player not on a valid team - check with gamemode developer!", 2 ) end 

    LocalPlayer():ScreenFade( SCREENFADE.OUT, Color( 0, 0, 0, 255 ), 1, 3 )

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
    end )
end

net.Receive( "RunRoleIntroductionNetMessage", GAMEMODE:StandardRoleIntro )