--//This file is strictly for creating/registering custom vgui elements

--//Immedaitely add a draw function after having said that - Yes, I got this off the garry's mod wiki
function draw.FilledCircle( x, y, radius, seg ) --"seg" is the amount of segments in the circle
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

--//Use to determine if the player has at least the provided point amount left to select
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

local AmmoWang = {}
AmmoWang.type = ""
AmmoWang.cost = 0
AmmoWang.lastval = 0
AmmoWang.totalammo = 0

function AmmoWang:SetAmmo( newType, newCost )
    self.type = newType
    self.cost = newCost

    self:SetMin( 0 )
end

function AmmoWang:OnValueChanged( newVal, skipLogic ) --This is seen as an event call, but doesn't override functionality
    if not skipLogic then --If we want to skip editing the SpentPoints and CurrentLoadout.Ammo
        if newVal > self.lastval then --If we're adding ammo
            GM.SpentPoints = GM.SpentPoints + ( newVal * self.cost ) - ( self.lastval * self.cost )
        elseif newVal < self.lastval then --If we're removing ammo
            GM.SpentPoints = GM.SpentPoints - ( newVal * self.cost ) + ( self.lastval * self.cost )
        end
        
        GM.CurrentLoadout.Ammo[ self.type ] = GM.CurrentLoadout.Ammo[ self.type ] + ( newVal - self.last )
    end
end

function AmmoWang:SetDecimals( num ) --No decimals
    return 0
end

function AmmoWang:Think()
    self:SetMax( self:GetValue() + math.Truncate( ( GM.TotalPoints - GM.SpentPoints ) / self.cost, 0 ) ) --Dynamically alters the max value based on GM.SpentPoints

    if self:GetValue() != GM.CurrentLoadout.Ammo[ self.type ] then --If DNumberWang's value isn't the same as GM.CurrentLoadout.Ammo[ self.type ], make it so
        self:SetValue( GM.CurrentLoadout.Ammo[ self.type ], true )
    end

    --[[if self:GetValue() == self:GetMax() then --If we hit our max amount, remove the arrows
        self:HideWang()
    end -commented out because I think it hides the arrows automatically]]
end

vgui.Create( "AmmoWang", AmmoWang, "DNumberWang" )

--//

local WeaponOptionPanel = {}
WeaponOptionPanel.class = ""
WeaponOptionPanel.name = ""
WeaponOptionPanel.model = ""
WeaponOptionPanel.tablekey = ""
WeaponOptionPanel.ammo = ""
--[[WeaponOptionPanel.damage = 0
WeaponOptionPanel.recoil = 0
WeaponOptionPanel.rof = 0 --rate of fire
WeaponOptionPanel.magazine = 0 --base magazine size]]
WeaponOptionPanel.cost = 0
WeaponOptionPanel.ammowang = vgui.Create( "AmmoWang", WeaponOptionPanel )

function WeaponOptionPanel:SetWeapon( newWeaponClass, weaponCost, weaponType, specialName, specialModel )
    self.class = newWeaponClass
    self.cost = weaponCost

    local wep = weapons.GetStored( self.class )
    self.name = specialName or wep.PrintName
    self.model = specialModel or wep.WorldModel
    self.tablekey = weaponType
    self.ammo = wep.Ammo
    --[[self.damage = wep.Damage
    self.recoil = wep.Recoil
    self.rof = wep.FireDelay
    self.magazine = wep.ClipSize]]
    self.ammowang = vgui.Create( "AmmoWang", self )
    self.ammowang:SetDecimals( 0 )
    self.ammowang:SetAmmo( self.ammo, GM.AmmoTable[ self.ammo ][ LocalPlayer():Team() ] )
    self.ammowang:SetSize( 10, 5 )
    self.ammowang:SetPos( self:GetWide() - self.ammowang:GetWide() - 4, self:GetTall() / 2 - ( self.ammowang:GetTall() / 2 ) )
end

function WeaponOptionPanel:Paint() --Gonna be fuckin' ugly, but it'll do for now
    surface.SetDrawColor( self.MyTheme.PrimaryColor.color ) --Panel background
    surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
    surface.SetDrawColor( self.MyTheme.SecondaryColor.color ) --Panel background highlight
    surface.DrawOutlinedRect( 0, 0, self:GetWide() - 1, self:GetTall() - 1 )
    surface.DrawCircle( 8, self:GetTall() / 2, 4, self.MyTheme.SecondaryColor.color )
    draw.SimpleText( self.name, self.font, 16, self:GetTall() / 2, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

    if self.hover then
        surface.SetDrawColor( self.MyTheme.PrimaryHighlightColor.color )
        draw.FilledCircle( 8, self:GetTall() / 2, 4, 1 )
        surface.SetDrawColor( self.MyTheme.SecondaryHighlightColor.color )
        surface.DrawOutlinedRect( 0, 0, self:GetWide() - 1, self:GetTall() - 1 )
    end

    if self.selected then
        surface.SetDrawColor( self.MyTheme.PrimaryHighlightColor.color )
        draw.FilledCircle( 8, self:GetTall() / 2, 4, 1 )
    end
end

function WeaponOptionPanel:DoClick()
    if self.selected then --If we've selected the weapon and are clicking to remove it
        self.selected = false
        GM.SpentPoints = GM.SpentPoints - self.cost
        GM.CurrentLoadout.Weapons[ self.tablekey ][ self.class ] = false
        surface.PlaySound( "buttons/deselect.wav" )
    elseif self.CanSelect then --If it wasn't selected and we are clicking to add it to our loadout
        self.selected = true
        GM.SpentPoints = GM.SpentPoints + self.cost
        GM.CurrentLoadout.Weapons[ self.tablekey ][ self.class ] = true
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
    if self.CanSelect then
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
    if not GM:CanSelect( self.cost ) then
        self.CanSelect = true
    else
        self.CanSelect = false
    end
end

vgui.Register( "WeaponOptionPanel", WeaponOptionPanel, "DPanel" )

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
    self.ScrollPanelPrimary:SetSize( self:GetWide() - 4, self:GetTall() / 3 - 4 )
    self.ScrollPanelPrimary:SetPos( 0, 0 )
    self.ScrollPanelPrimary.Paint = function()
        surface.SetDrawColor( self.MyTheme.SecondaryHighlightColor.color )
        surface.DrawOutlinedRect( 0, 0, self.ScrollPanelPrimary:GetWide() - 1, self.ScrollPanelPrimary:GetTall() - 1 )
    end

    self.ScrollPanelSecondary = vgui.Create( "DScrollPanel", self )
    self.ScrollPanelSecondary:SetSize( self:GetWide() - 4, self:GetTall() / 3 - 4 )
    self.ScrollPanelSecondary:SetPos( 0, self:GetTall() / 3 )
    self.ScrollPanelSecondary.Paint = function()
        surface.SetDrawColor( self.MyTheme.SecondaryHighlightColor.color )
        surface.DrawOutlinedRect( 0, 0, self.ScrollPanelSecondary:GetWide() - 1, self.ScrollPanelSecondary:GetTall() - 1 )
    end

    self.ScrollPanelTertiary = vgui.Create( "DScrollPanel", self )
    self.ScrollPanelTertiary:SetSize( self:GetWide() - 4, self:GetTall() / 3 - 4 )
    self.ScrollPanelTertiary:SetPos( 0, self:GetTall() / 3 * 2 )
    self.ScrollPanelTertiary.Paint = function()
        surface.SetDrawColor( self.MyTheme.SecondaryHighlightColor.color )
        surface.DrawOutlinedRect( 0, 0, self.ScrollPanelTertiary:GetWide() - 1, self.ScrollPanelTertiary:GetTall() - 1 )
    end

    for k, v in pairs( self.primaryWeapons ) do
        local wepPanel = vgui.Create( "WeaponOptionPanel", self.ScrollPanelPrimary )
        wepPanel:SetSize( self.ScrollPanelPrimary:GetWide(), 40 )
        wepPanel:SetWeapon( k, v[ 1 ], "Primary", v[ 2 ], v[ 3 ] )
        wepPanel:Dock( TOP ) --Isn't this ascending? With the first at the bottom? I want it descending...
    end

    for k, v in pairs( self.secondaryWeapons ) do
        local wepPanel = vgui.Create( "WeaponOptionPanel", self.ScrollPanelSecondary )
        wepPanel:SetSize( self.ScrollPanelSecondary:GetWide(), 40 )
        wepPanel:SetWeapon( k, v[ 1 ], "Secondary", v[ 2 ], v[ 3 ] )
        wepPanel:Dock( TOP )
    end

    for k, v in pairs( self.tertiaryWeapons ) do
        local wepPanel = vgui.Create( "WeaponOptionPanel", self.ScrollPanelTertiary )
        wepPanel:SetSize( self.ScrollPanelTertiary:GetWide(), 40 )
        wepPanel:SetWeapon( k, v[ 1 ], "Tertiary", v[ 2 ], v[ 3 ] )
        wepPanel:Dock( TOP )
    end
end

function WeaponsSidePanel:Paint()
    --I'm assuming we're going to want something to separate the three DScrollPanels, just simple lines, maybe?
    surface.SetDrawColor( self.MyTheme.PrimaryColor.color )
    surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
    --[[surface.SetDrawColor( self.MyTheme.SecondaryHighlightColor.color )
    surface.DrawLine( 4, )]]
end

vgui.Register( "WeaponsSidePanel", WeaponsSidePanel, "DPanel" )

--//

local ArmorOptionPanel = WeaponOptionPanel
ArmorOptionPanel.description = ""

function ArmorOptionPanel:SetArmor( newName, newDesc, newCost )
    self.name = newName
    self.description = newDesc
    self.cost = newCost
end

function ArmorOptionPanel:DoClick()
    if GM.CurrentLoadout.Armor == self.name then return end --If it's already selected, do nothing
    if self.CanSelect then --If it isn't selected and we are clicking to add it to our loadout
        self.selected = true
        GM.SpentPoints = GM.SpentPoints + self.cost - ( GM.CurrentArmorCost or 0 )
        GM.CurrentLoadout.Armor = self.name
        GM.CurrentArmorCost = self.cost
        surface.PlaySound( "buttons/select.wav" )
    else --If it wasn't selected and we are clicking to add it to our loadout, but we don't have enough points
        if LocalPlayer():Team() == 1 then
            surface.PlaySound( "button8.wav" )
        else
            surface.PlaySound( "combine_button_locked.wav" )
        end
    end
end

function ArmorOptionPanel:Think() --Have to do this unique, since we're locking armor to only 1 option
    if not GM:CanSelect( ( self.cost - ( self.CurrentArmorCost or 0 ) ) ) then
        self.CanSelect = true
    else
        self.CanSelect = false
    end
end

function ArmorOptionPanel:Paint()

end

vgui.Register( "ArmorOptionPanel", ArmorOptionPanel, "DPanel")

--//

local PerksPanel = WeaponOptionPanel
PerksPanel.description = ""

function PerksPanel:SetPerk( newName, newDesc, newCost )
    self.name = newName
    self.description = newDesc
    self.cost = newCost
end

function PerksPanel:DoClick()
    if self.selected then --If we've selected the perk and are clicking to remove it
        self.selected = false
        GM.SpentPoints = GM.SpentPoints - self.cost
        GM.CurrentLoadout.Perks[ self.name ] = false
        surface.PlaySound( "buttons/deselect.wav" )
    elseif self.CanSelect then --If it wasn't selected and we are clicking to add it to our loadout
        self.selected = true
        GM.SpentPoints = GM.SpentPoints + self.cost
        GM.CurrentLoadout.Perks[ self.name ] = true
        surface.PlaySound( "buttons/select.wav" )
    else --If it wasn't selected and we are clicking to add it to our loadout, but we don't have enough points
        if LocalPlayer():Team() == 1 then
            surface.PlaySound( "button8.wav" )
        else
            surface.PlaySound( "combine_button_locked.wav" )
        end
    end
end

function PerksPanel:Paint()

end


vgui.Register( "PerksPanel", PerksPanel, "DPanel" )

--//

local LoadoutMenuPanel = {} --We have a panel version of the loadout menu, for when it's initially used after the round intro


vgui.Register( "LoadoutMenuPanel", LoadoutMenuPanel, "DPanel" )

--//

local LoadoutMenuFrame = {} --We have a frame version of the loadout menu, for when the terrorists die and change their loadout


vgui.Register( "LoadoutMenuFrame", LoadoutMenuFrame, "DPanel" )