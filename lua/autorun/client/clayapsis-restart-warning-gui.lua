-- Credit for style of vgui goes to Periapsises(@387057421157400577)

CFC_RESTART_WARNING = CFC_RESTART_WARNING or {}

-- Internal utility Vector2 function.
local function vec2( x, y )
    return { ["x"] = x, ["y"] = y }
end


CFC_RESTART_WARNING.timeLeft = 0
CFC_RESTART_WARNING.initialTime = 0
CFC_RESTART_WARNING.timeFinished = CurTime() + CFC_RESTART_WARNING.timeLeft
CFC_RESTART_WARNING.finishedPosition = vec2( 0, ScrH() / 4 )
CFC_RESTART_WARNING.easeSpeed = 0.15
CFC_RESTART_WARNING.counterColor = Color( 255, 255, 255 )
CFC_RESTART_WARNING.baseColourMaterial = Material( "colour" )
CFC_RESTART_WARNING.canChangeVisibility = true


CFC_RESTART_WARNING.stripeMaterial = CreateMaterial( "cfc_restart_warning_gui_stripes", "UnlitGeneric", {
    ["$basetexture"] = "phoenix_storms/stripes",
    ["$noclamp"] = 1
})


surface.CreateFont( "cfc_restart_warning_text_font", {
    font = "Arial",
    extended = false,
    size = 21,
    blursize = 0,
    scanlines = 0,
    antialias = true
})

surface.CreateFont( "cfc_restart_warning_counter_font", {
    font = "Tahoma",
    extended = false,
    size = 80,
    blursize = 0,
    scanlines = 0,
    antialias = true
})

-- Internal function for formatting time into MM:SS:sss
local function formatTime( time )
    if time == nil then time = -1 end
    local minutes = math.floor( time / 60 ) 
    local seconds = math.floor( time % 60 )
    local milliseconds = math.floor( ( time - math.floor( time ) ) * 1000 )

    return string.format( "%02d:%02d.%03d", minutes, seconds, milliseconds )
end

--- Internal function for easing the restart vgui into view.
local function guiEaseIn()
    CFC_RESTART_WARNING.canChangeVisibility = false
    local panel = CFC_RESTART_WARNING.panel
    local finishedPos = CFC_RESTART_WARNING.finishedPosition
    local SzW, SzH = panel:GetSize()

    panel:SetPos( -SzW, finishedPos.y - (SzH / 2) )
    panel:SetVisible( true )
    panel:MoveTo( finishedPos.x, finishedPos.y - (SzH / 2), 0.4, 0, CFC_RESTART_WARNING.easeSpeed, function()
        CFC_RESTART_WARNING.canChangeVisibility = true
    end )
    panel:NoClipping( true )
end

-- Internal function for easing the restart vgui out of view.
local function guiEaseOut()
    CFC_RESTART_WARNING.canChangeVisibility = false
    local panel = CFC_RESTART_WARNING.panel
    local finishedPos = CFC_RESTART_WARNING.finishedPosition
    local SzW, SzH = panel:GetSize()

    panel:MoveTo( -SzW, finishedPos.y - (SzH / 2), 0.4, 0, CFC_RESTART_WARNING.easeSpeed, function()
        panel:SetVisible( false )
        CFC_RESTART_WARNING.canChangeVisibility = true
    end )
end

-- Creates/Initializes the main vgui of the restart warning.
local function createRestartGUI( time )
    CFC_RESTART_WARNING.panel = vgui.Create( "DFrame" )

    local panel = CFC_RESTART_WARNING.panel
    local finishedPos = CFC_RESTART_WARNING.finishedPosition

    panel:ShowCloseButton( false )
    panel:SetDraggable( false )
    panel:SetTitle( "" )
    panel:SetSize( ScrW() / 5, ScrH() / 8 ); local SzW, SzH = panel:GetSize()
    guiEaseIn()

    panel.Paint = function( self, w, h )
        if CFC_RESTART_WARNING.timeLeft > 0 then
            CFC_RESTART_WARNING.timeLeft = math.Clamp( CFC_RESTART_WARNING.timeFinished - CurTime(), 0, math.huge )

            local colourTime = CFC_RESTART_WARNING.timeLeft <= 10 and ( CFC_RESTART_WARNING.timeLeft / CFC_RESTART_WARNING.initialTime ) * 255 or 255
            CFC_RESTART_WARNING.counterColor = Color( CFC_RESTART_WARNING.counterColor.r, colourTime, colourTime )
        end

        render.SetStencilEnable( true )
        render.ClearStencil()

        render.SetStencilTestMask( 255 )
        render.SetStencilWriteMask( 255 )

        render.SetStencilPassOperation( STENCILOPERATION_KEEP )
        render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

        render.SetStencilReferenceValue( 255 )
        render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

        surface.SetDrawColor( Color( 0, 0, 0 ) )
        surface.SetMaterial( CFC_RESTART_WARNING.baseColourMaterial )
        surface.DrawTexturedRectRotated( w, h / 2, w * 0.2, h * 5, -10 )

        render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NOTEQUAL )

        draw.RoundedBox( 0, 0, 0, w, h, Color( 60, 60, 60, 255 ) )

        draw.SimpleText( "- WARNING - ", "cfc_restart_warning_text_font", w / 2, h * 0.125, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( "Server is restarting in:", "cfc_restart_warning_text_font", w / 2, h * 0.215, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )        
        draw.SimpleTextOutlined( "Press F3 to show/hide this countdown.", "CreditsText", w / 2, h - h * 0.125, Color( 200, 200, 200, 60 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, Color( 0, 0, 0 ) )
        draw.SimpleText( formatTime( CFC_RESTART_WARNING.timeLeft ), "cfc_restart_warning_counter_font",  w / 2, h * 0.5, CFC_RESTART_WARNING.counterColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        surface.SetMaterial( CFC_RESTART_WARNING.stripeMaterial )
        surface.DrawTexturedRectUV( 0, 0, w, h * 0.05, 0, 0, 4, 0.425 )
        surface.DrawTexturedRectUV( 0, h - h * 0.05, w, h * 0.05, 0, 0, 4, 0.425 )

        render.SetStencilEnable( false )
    end
end


-- External function for showing the vgui.
function CFC_RESTART_WARNING.showGUI( time )
    if time == nil or time == -1 then CFC_RESTART_WARNING.timeLeft = -1 end
    CFC_RESTART_WARNING.timeLeft = time
    CFC_RESTART_WARNING.timeFinished = CurTime() + time
    CFC_RESTART_WARNING.initialTime = time

    if IsValid( CFC_RESTART_WARNING.panel ) then
        guiEaseIn()
    else
        createRestartGUI( time )
    end
end

-- External function for hiding the vgui.
function CFC_RESTART_WARNING.hideGUI()
    if IsValid( CFC_RESTART_WARNING.panel ) then
        guiEaseOut()
    end
end


-- Player interface hook for showing/hiding vgui.
hook.Add( "PlayerButtonDown", "cfc_restart_warning_key_input", function( ply, button )
    if ply ~= LocalPlayer() or button ~= KEY_F3 then return false end

    if IsValid( CFC_RESTART_WARNING.panel ) and CFC_RESTART_WARNING.canChangeVisibility then
        if CFC_RESTART_WARNING.panel:IsVisible() then
            guiEaseOut()
        else
            guiEaseIn()
        end
    end
end )

-- Interfaces to allow other scripts/addons to use the restart GUI. (Use these to interact with the gui.)
concommand.Add( "cfc_show_restart_warning_gui", function( _, _, args ) CFC_RESTART_WARNING.showGUI( tonumber( args[1] ) ) end, nil, "Shows the server restart warning gui with the timer set to the provided integer", nil )
concommand.Add( "cfc_hide_restart_warning_gui", CFC_RESTART_WARNING.hideGUI, nil, "Hides the server restart warning gui", nil )

net.Receive( "cfc_restart_warning_gui_show", function()
    local time = net.ReadInt( 16 )
    CFC_RESTART_WARNING.showGUI( time )
end )

net.Receive( "cfc_restart_warning_gui_hide", function()
    CFC_RESTART_WARNING.hideGUI()
end )