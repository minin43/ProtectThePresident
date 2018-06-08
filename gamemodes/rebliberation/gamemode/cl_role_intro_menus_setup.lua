--//This file is strictly for creating/registering custom vgui elements

local RolePanel = {}
RolePanel.font = "DermaLarge"
RolePanel.colorR = 255
RolePanel.colorG = 0
RolePanel.colorB = 0
RolePanel.colorCombined = RolePanel.colorR .. ", " RolePanel.colorG .. ", " .. RolePanel.colorB
RolePanel.team = 1 --Default to terrorist team
RolePanel.name = markup.Create()
RolePanel.objective = markup.Create()
RolePanel.description = markup.Create()

function RolePanel:SetFont( newFont )
    self.font = newFont
end

function RolePanel:SetTeam( newTeam, IDs ) --We only expect IDs table if team is 2
    self.team = newTeam or self.team

    if self.team == 1 then
        self.name = markup.Parse( "<font=" .. self.font .. ">You are a <colour = " .. self.colorCombined .. ">rebel fighter</colour>.", self:GetWide() - 4 )
        self.objective = markup.Parse( "<font=" .. self.font .. ">Your objective is to <colour = " .. self.colorCombined .. ">eliminate Wallace Breen at all costs</colour>.", self:GetWide() - 4 )
        self.description = markup.Parse( "<font=" .. self.font .. ">You will start off weak, but will earn points as the game progresses, based on several events that happen throughout it. Use these points to upgrade your arsenal, "
        .. "or spend them to remove your handicaps</colour>.", self:GetWide() - 4 )
    elseif self.team == 2 then
        self.name = markup.Parse( "<font=" .. self.font .. ">You are <colour = " .. self.colorCombined .. ">Bodyguard Unit " .. IDs[ 1 ] .. "-" .. IDs[ 2 ] .. "-" .. IDs[ 3 ] .. "</colour>.", self:GetWide() - 4 )
        self.objective = markup.Parse( "<font=" .. self.font .. ">Your objective is to <colour = " .. self.colorCombined .. ">keep Wallace Breen alive until he can be extracted from the area</colour>.", self:GetWide() - 4 )
        self.description = markup.Parse( "<font=" .. self.font .. ">Use the best gear you can. You don't respawn, and your resources are finite. Communication between your fellow bodyguards and Breen is key to being successful</colour>.", self:GetWide() - 4 )
    elseif self.team == 3 then
        self.name = markup.Parse( "<font=" .. self.font .. ">You are <colour = " .. self.colorCombined .. ">Doctor Wallace Breen</colour>.", self:GetWide() - 4 )
        self.objective = markup.Parse( "<font=" .. self.font .. ">Your objective is to <colour = " .. self.colorCombined .. ">stay alive long enough for your extraction to arrive</colour>.", self:GetWide() - 4 )
        self.description = markup.Parse( "<font=" .. self.font .. ">You have no way to defend yourself, no weapons. You must rely on communication with your bodyguards to keep you alive; do not forget this</colour>.", self:GetWide() - 4 )
    end
end

function RolePanel:SetTextHighlightColor( newColorR, newColorG, newColorB )
    self.colorR = newColorR
    self.colorG = newColorG
    self.colorB = newColorB
    self.colorCombined = self.colorR .. ", " self.colorG .. ", " .. self.colorB
end

function RolePanel:Paint()
    self.name:Draw( self:GetWide() / 2, self:GetTall() / 4, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    self.objective:Draw( self:GetWide() / 2, self:GetTall() / 4 * 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    self.description:Draw( self:GetWide() / 2, self:GetTall() / 4 * 3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    return true
end

vgui.Register( "RolePanel", RolePanel, "DPanel" )