--//This file is strictly for creating/registering custom vgui elements

--//Immedaitely add a draw function after having said that - Yes, I got this off the garry's mod wiki
function draw.FilledCircle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

function GM:CanSelect( pointCost )
    if pointCost > self.TotalPoints - self.SpentPoints then
        return false
    else
        return true
    end
end

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

--//

local WeaponOptionPanel = {}
WeaponOptionPanel.class = ""
WeaponOptionPanel.name = ""
WeaponOptionPanel.tablekey = ""
WeaponOptionPanel.model = ""
WeaponOptionPanel.damage = 0
WeaponOptionPanel.recoil = 0
WeaponOptionPanel.rof = 0 --rate of fire
WeaponOptionPanel.magazine = 0 --base magazine size
WeaponOptionPanel.cost = 0

function WeaponOptionPanel:SetWeapon( newWeaponClass, weaponCost, weaponType, specialName, specialModel )
    self.class = newWeaponClass
    self.cost = weaponCost

    local wep = weapons.GetStored( self.class )
    self.name = specialName or wep.PrintName
    self.model = specialModel or wep.WorldModel
    self.tablekey = weaponType
    self.damage = wep.Damage
    self.recoil = wep.Recoil
    self.rof = wep.FireDelay
    self.magazine = wep.ClipSize
end

function WeaponOptionPanel:Paint()
    --To figure out...
end

function WeaponOptionPanel:DoClick()
    if self.selected then --If we've selected the weapon and are clicking to remove it
        self.selected = false
        GM.SpentPoints = GM.SpentPoints - self.cost
        surface.PlaySound( "buttons/deselect.wav" )
    elseif GM.CanSelect( self.cost ) --If it wasn't selected and we are clicking to add it to our loadout
        self.selected = true
        GM.SpentPoints = GM.SpentPoints + self.cost
        GM.
        surface.PlaySound( "buttons/select.wav" )
    else --If it wasn't selected and we are clicking to add it to our loadout, but we don't have enough points
        if LocalPlayer():Team() == 1 then
            surface.PlaySound( "button8.wav" )
        else
            surface.PlaySound( "combine_button_locked.wav" )
        end
    end
end

function WeaponOptionPanel:OnCursorEntered()
    if GM.CanSelect( self.cost )
        surface.PlaySound( "garrysmod/ui_hover.wav" )
        self.hover = true
    end
end

function WeaponOptionPanel:OnCursorExited()
    self.hover = false
end

function WeaponOptionPanel:OnRemove()
    self.hover = false --The highlighting can bug out if the panel is removed with the cursor still inside it
end

function WeaponOptionPanel:Think()
    if not GM.CanSelect( self.cost )
        --set something false here? We can have everything grey out when you run out of points
    end
end

vgui.Register( "WeaponOptionPanel", WeaponOptionPanel, "DButton" ) --Aha! It is actually a button, not a simple panel

--//

local WeaponsSidePanel = {}
WeaponsSidePanel.font = "DermaDefault"
WeaponsSidePanel.primaryWeapons = {}
WeaponsSidePanel.secondaryWeapons = {}
WeaponsSidePanel.tertiaryWeapons = {}

function WeaponsSidePanel:SetWeaponsLists( primWeps, seconWeps, tertWeps )
    self.primaryWeapons = primWeps
    self.secondaryWeapons = seconWeps
    self.tertiaryWeapons = tertWeps

    self.ScrollPanelPrimary = vgui.Create( "DScrollPanel", self )
    self.ScrollPanelPrimary:SetSize( self:GetWide(), self:GetTall() / 3 )
    self.ScrollPanelPrimary:SetPos( 0, 0 )

    self.ScrollPanelSecondary = vgui.Create( "DScrollPanel", self )
    self.ScrollPanelPrimary:SetSize( self:GetWide(), self:GetTall() / 3 )
    self.ScrollPanelPrimary:SetPos( 0, self:GetTall() / 3 )

    self.ScrollPanelTertiary= vgui.Create( "DScrollPanel", self )
    self.ScrollPanelPrimary:SetSize( self:GetWide(), self:GetTall() / 3 )
    self.ScrollPanelPrimary:SetPos( 0, self:GetTall() / 3 * 2 )

    for k, v in pairs( self.primaryWeapons ) do
        local wepPanel = vgui.Create( "WeaponOptionPanel", self.ScrollPanelPrimary )
        wepPanel:SetWeapon( k, v[ 1 ], "primaryWeapons", v[ 2 ], v[ 3 ] )
        wepPanel:Dock( TOP ) --Doesn't this format ascending? With the default at the bottom? I want it descending
    end

    for k, v in pairs( self.secondaryWeapons ) do
        local wepPanel = vgui.Create( "WeaponOptionPanel", self.ScrollPanelPrimary )
        wepPanel:SetWeapon( k, v[ 1 ], "secondaryWeapons", v[ 2 ], v[ 3 ] )
        wepPanel:Dock( TOP ) --Doesn't this format ascending? With the default at the bottom? I want it descending
    end

    for k, v in pairs( self.tertiaryWeapons ) do
        local wepPanel = vgui.Create( "WeaponOptionPanel", self.ScrollPanelPrimary )
        wepPanel:SetWeapon( k, v[ 1 ], "tertiaryWeapons", v[ 2 ], v[ 3 ] )
        wepPanel:Dock( TOP ) --Doesn't this format ascending? With the default at the bottom? I want it descending
    end
end

function WeaponsSidePanel:Paint()
    --I'm assuming we're going to want something to separate the three DScrollPanels, just simple lines, maybe?
end

vgui.Register( "WeaponsSidePanel", WeaponsSidePanel, "DPanel" )

--//

local OtherOptionPanel = WeaponOptionPanel
OtherOptionPanel

--//

local PerksPanel = {}


vgui.Register( "PerksPanel", PerksPanel, "DPanel" )

--//

local LoadoutMenuPanel = {} --We have a panel version of the loadout menu, for when it's initially used after the round intro


vgui.Register( "LoadoutMenuPanel", LoadoutMenuPanel, "DPanel" )

--//

local LoadoutMenuFrame = {} --We have a frame version of the loadout menu, for when the terrorists die and change their loadout


vgui.Register( "LoadoutMenuFrame", LoadoutMenuFrame, "DPanel" )