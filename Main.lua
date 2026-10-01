--==============================================================
--              UNDERGLOW STUDIO V5
--     Glass UI + True Smooth + Effects + Sliders
--              Créé par Midori
--
-- Remote confirmé :
-- Underglow_FE:FireServer("ToggleUnderglow", enabled, Color3)
--==============================================================

--==============================================================
-- SERVICES
--==============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer


--==============================================================
-- CONFIG / STATE
--==============================================================

local State = {
    Enabled = false,
    Effect = "Rainbow",

    Speed = 35,
    Saturation = 100,
    Brightness = 100,

    -- false = TRUE SMOOTH : jamais de OFF entre les couleurs
    -- true  = OFF / ON volontaire
    Blink = false,

    StaticColor = Color3.fromRGB(190, 70, 255),

    Minimized = false,
    Closed = false
}

--==============================================================
-- HEADLIGHT STATE
--==============================================================

local Headlight = {
    Enabled = false,
    Flashing = false,
    Interval = 0.50,
    MinInterval = 0.05,
    MaxInterval = 2.00
}

local function GetHeadlightRemote()
    local Car = workspace:FindFirstChild("MiidoriiiiisCar")
    if not Car then return nil end

    local Remote = Car:FindFirstChild("Lights_FE")
    if Remote and Remote:IsA("RemoteEvent") then
        return Remote
    end

    return nil
end

local function SendHeadlight(State)
    local Remote = GetHeadlightRemote()
    if not Remote then return false end

    Remote:FireServer("ToggleLight", State)
    return true
end


--==============================================================
-- THEME
--==============================================================

local Theme = {
    Background = Color3.fromRGB(15, 8, 22),
    Card = Color3.fromRGB(38, 15, 45),
    CardHover = Color3.fromRGB(61, 23, 69),

    Text = Color3.fromRGB(245, 246, 250),
    SubText = Color3.fromRGB(145, 150, 170),

    Accent = Color3.fromRGB(236, 67, 255),

    Green = Color3.fromRGB(65, 235, 140),
    Red = Color3.fromRGB(255, 75, 100),

    Slider = Color3.fromRGB(89, 54, 96)
}


--==============================================================
-- VEHICLE / REMOTE
--==============================================================

local function GetCarAndRemote()

    local Character = Player.Character

    if not Character then
        return nil, nil
    end

    local Humanoid =
        Character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return nil, nil
    end

    local Seat = Humanoid.SeatPart

    if not Seat then
        return nil, nil
    end

    local Current = Seat

    -- Remonte depuis le siège jusqu'au modèle
    -- qui contient Underglow_FE.
    for _ = 1, 12 do

        if not Current then
            break
        end

        local Remote =
            Current:FindFirstChild("Underglow_FE")

        if Remote and Remote:IsA("RemoteEvent") then
            return Current, Remote
        end

        if Current == workspace then
            break
        end

        Current = Current.Parent
    end

    return nil, nil
end


--==============================================================
-- UNDERGLOW ENGINE
--==============================================================

local LastColor =
    State.StaticColor


local function SendUnderglow(Enabled, Color)

    local Car, Remote =
        GetCarAndRemote()

    if not Car or not Remote then
        return false
    end

    Color = Color or LastColor
    LastColor = Color

    Remote:FireServer(
        "ToggleUnderglow",
        Enabled,
        Color
    )

    return true
end


--==============================================================
-- TRUE SMOOTH
--
-- IMPORTANT :
-- AUCUN false n'est envoyé ici.
--==============================================================

local function ApplySmooth(Color)

    LastColor = Color

    return SendUnderglow(
        true,
        Color
    )
end


--==============================================================
-- BLINK
--==============================================================

local function ApplyBlink(Color, OffTime)

    local Car, Remote =
        GetCarAndRemote()

    if not Car or not Remote then
        return false
    end

    LastColor = Color

    Remote:FireServer(
        "ToggleUnderglow",
        false,
        Color
    )

    task.wait(OffTime or 0.10)

    Remote:FireServer(
        "ToggleUnderglow",
        true,
        Color
    )

    return true
end


--==============================================================
-- REMOVE OLD UI / LOOP
--==============================================================

_G.UnderglowStudioV5 = false

local Old =
    CoreGui:FindFirstChild("UnderglowStudioV5")

if Old then
    Old:Destroy()
end

task.wait()

_G.UnderglowStudioV5 = true


--==============================================================
-- UI HELPERS
--==============================================================

local function Corner(Object, Radius)

    local C = Instance.new("UICorner")

    C.CornerRadius =
        UDim.new(0, Radius)

    C.Parent = Object

    return C
end


local function Stroke(
    Object,
    Color,
    Thickness,
    Transparency
)

    local S = Instance.new("UIStroke")

    S.Color =
        Color or Theme.Accent

    S.Thickness =
        Thickness or 1

    S.Transparency =
        Transparency or 0

    S.Parent = Object

    return S
end


local function CreateLabel(
    Parent,
    Text,
    Size,
    Color
)

    local Label =
        Instance.new("TextLabel")

    Label.BackgroundTransparency = 1

    Label.Size =
        UDim2.new(1, 0, 0, 22)

    Label.Text = Text

    Label.TextColor3 =
        Color or Theme.Text

    Label.TextSize =
        Size or 13

    Label.Font =
        Enum.Font.Gotham

    Label.TextXAlignment =
        Enum.TextXAlignment.Left

    Label.Parent = Parent

    return Label
end


local function CreateButton(
    Parent,
    Text
)

    local Button =
        Instance.new("TextButton")

    Button.AutoButtonColor = false

    Button.BackgroundColor3 =
        Theme.CardHover

    Button.BackgroundTransparency =
        0.10

    Button.BorderSizePixel = 0

    Button.Text = Text

    Button.TextColor3 =
        Theme.Text

    Button.TextSize = 12

    Button.Font =
        Enum.Font.GothamMedium

    Button.Parent = Parent

    Corner(Button, 9)

    Stroke(
        Button,
        Color3.new(1, 1, 1),
        1,
        0.92
    )

    return Button
end


local function CreateCard(
    Parent,
    Height,
    Order
)

    local Card =
        Instance.new("Frame")

    Card.Size =
        UDim2.new(1, 0, 0, Height)

    Card.BackgroundColor3 =
        Theme.Card

    -- légèrement transparent
    Card.BackgroundTransparency =
        0.14

    Card.BorderSizePixel = 0

    Card.LayoutOrder = Order

    Card.Parent = Parent

    Corner(Card, 12)

    Stroke(
        Card,
        Color3.new(1, 1, 1),
        1,
        0.90
    )

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.CardHover),
        ColorSequenceKeypoint.new(1, Theme.Card)
    })
    Gradient.Rotation = 12
    Gradient.Parent = Card

    return Card
end


--==============================================================
-- SCREEN GUI
--==============================================================

local GUI =
    Instance.new("ScreenGui")

GUI.Name =
    "UnderglowStudioV5"

GUI.ResetOnSpawn = false

GUI.Parent = CoreGui


--==============================================================
-- MAIN WINDOW
--==============================================================

local Main =
    Instance.new("Frame")

Main.Size =
    UDim2.fromOffset(
        560,
        800
    )

Main.Position =
    UDim2.new(
        0.5,
        -280,
        0.5,
        -400
    )

Main.BackgroundColor3 =
    Theme.Background

-- Glass transparency
Main.BackgroundTransparency =
    0.10

Main.BorderSizePixel = 0

Main.ClipsDescendants = true

Main.Parent = GUI

Corner(Main, 22)

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(48, 13, 55)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(25, 10, 33)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(11, 12, 20))
})
MainGradient.Rotation = 35
MainGradient.Parent = Main

local MainStroke =
    Stroke(
        Main,
        Theme.Accent,
        1.5,
        0.20
    )

--==============================================================
-- COMPACT AVATAR ICON
--==============================================================

local AvatarButton =
    Instance.new("ImageButton")

AvatarButton.Name = "MidoriAvatarButton"
AvatarButton.Size =
    UDim2.fromOffset(
        74,
        74
    )

AvatarButton.Position =
    UDim2.new(
        0.5,
        -37,
        0.5,
        -37
    )

AvatarButton.BackgroundColor3 =
    Color3.fromRGB(
        20,
        12,
        27
    )

AvatarButton.BorderSizePixel = 0
AvatarButton.AutoButtonColor = false
AvatarButton.Visible = false
AvatarButton.Parent = GUI

Corner(
    AvatarButton,
    37
)

local _AvatarStroke =
    Stroke(
        AvatarButton,
        Theme.Accent,
        2,
        0.05
    )

local AvatarImage =
    Instance.new("ImageLabel")

AvatarImage.Size =
    UDim2.new(
        1,
        -6,
        1,
        -6
    )

AvatarImage.Position =
    UDim2.fromOffset(
        3,
        3
    )

AvatarImage.BackgroundTransparency = 1
AvatarImage.BorderSizePixel = 0
AvatarImage.Parent = AvatarButton

Corner(
    AvatarImage,
    34
)

--==============================================================
-- CUSTOM AVATAR IMAGE
--==============================================================
-- Remplace "YOUR_IMAGE_ID" par l'ID Roblox de ton image.
-- Exemple : rbxassetid://1234567890
AvatarImage.Image =
    "rbxthumb://type=Asset&id=88499437077991&w=420&h=420"

AvatarImage.ScaleType =
    Enum.ScaleType.Crop

AvatarImage.ImageTransparency = 0

task.spawn(function()
    task.wait(1)

    if AvatarImage.Image == "" then
        AvatarImage.Image =
            "rbxassetid://88499437077991"
    end
end)

local AvatarGlow =
    Instance.new("UIStroke")

AvatarGlow.Color =
    Theme.Accent

AvatarGlow.Thickness = 1
AvatarGlow.Transparency = 0.35
AvatarGlow.Parent = AvatarImage


--==============================================================
-- LIVE TOP BAR
--==============================================================

local TopBar =
    Instance.new("Frame")

TopBar.Size =
    UDim2.new(
        1,
        -30,
        0,
        3
    )

TopBar.Position =
    UDim2.fromOffset(
        15,
        0
    )

TopBar.BackgroundColor3 =
    Theme.Accent

TopBar.BorderSizePixel = 0

TopBar.Parent = Main

Corner(TopBar, 5)


--==============================================================
-- HEADER
--==============================================================

local Header =
    Instance.new("Frame")

Header.Size =
    UDim2.new(
        1,
        0,
        0,
        72
    )

Header.BackgroundTransparency = 1

Header.Parent = Main


local Title =
    CreateLabel(
        Header,
        "UNDERGLOW",
        20,
        Theme.Text
    )

Title.Font =
    Enum.Font.GothamBold

Title.Position =
    UDim2.fromOffset(
        22,
        12
    )

Title.Size =
    UDim2.new(
        1,
        -150,
        0,
        28
    )


local Subtitle =
    CreateLabel(
        Header,
        "LIGHTING STUDIO  •  V5  •  MIDORI EDITION",
        10,
        Theme.SubText
    )

Subtitle.Font =
    Enum.Font.GothamMedium

Subtitle.Position =
    UDim2.fromOffset(
        23,
        41
    )


--==============================================================
-- CREATOR
--==============================================================

local Creator =
    CreateLabel(
        Header,
        "CRÉÉ PAR MIDORI",
        9,
        Theme.Accent
    )

Creator.Font =
    Enum.Font.GothamMedium

Creator.Position =
    UDim2.fromOffset(
        23,
        55
    )

Creator.Size =
    UDim2.new(
        1,
        -130,
        0,
        14
    )


--==============================================================
-- WINDOW CONTROLS
--==============================================================

local Minimize =
    CreateButton(
        Header,
        "—"
    )

Minimize.Size =
    UDim2.fromOffset(
        38,
        32
    )

Minimize.Position =
    UDim2.new(
        1,
        -88,
        0,
        16
    )


local Close =
    CreateButton(
        Header,
        "×"
    )

Close.Size =
    UDim2.fromOffset(
        38,
        32
    )

Close.Position =
    UDim2.new(
        1,
        -44,
        0,
        16
    )

Close.TextSize = 18


--==============================================================
-- CONTENT
--==============================================================

local Content =
    Instance.new("Frame")

Content.Size =
    UDim2.new(
        1,
        -30,
        1,
        -82
    )

Content.Position =
    UDim2.fromOffset(
        18,
        72
    )

Content.BackgroundTransparency = 1

Content.Parent = Main


local ContentLayout =
    Instance.new("UIListLayout")

ContentLayout.Padding =
    UDim.new(0, 9)

ContentLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

ContentLayout.Parent = Content


--==============================================================
-- STATUS CARD
--==============================================================

local StatusCard =
    CreateCard(
        Content,
        68,
        1
    )


local StatusDot =
    Instance.new("Frame")

StatusDot.Size =
    UDim2.fromOffset(
        10,
        10
    )

StatusDot.Position =
    UDim2.fromOffset(
        16,
        17
    )

StatusDot.BackgroundColor3 =
    Theme.Red

StatusDot.BorderSizePixel = 0

StatusDot.Parent =
    StatusCard

Corner(StatusDot, 10)


local StatusTitle =
    CreateLabel(
        StatusCard,
        "Underglow disabled",
        14,
        Theme.Text
    )

StatusTitle.Font =
    Enum.Font.GothamMedium

StatusTitle.Position =
    UDim2.fromOffset(
        35,
        10
    )


local CarStatus =
    CreateLabel(
        StatusCard,
        "Sit in a compatible vehicle",
        10,
        Theme.SubText
    )

CarStatus.Position =
    UDim2.fromOffset(
        35,
        35
    )


local Power =
    CreateButton(
        StatusCard,
        "ENABLE"
    )

Power.Size =
    UDim2.fromOffset(
        92,
        36
    )

Power.Position =
    UDim2.new(
        1,
        -105,
        0,
        16
    )


--==============================================================
-- HEADLIGHTS
--==============================================================

local HeadlightCard =
    CreateCard(
        Content,
        142,
        2
    )

local HeadlightTitle =
    CreateLabel(
        HeadlightCard,
        "HEADLIGHTS",
        10,
        Theme.SubText
    )

HeadlightTitle.Font = Enum.Font.GothamBold
HeadlightTitle.Position = UDim2.fromOffset(14, 9)

local HeadlightStatus =
    CreateLabel(
        HeadlightCard,
        "OFF  •  READY",
        11,
        Theme.SubText
    )

HeadlightStatus.Position = UDim2.fromOffset(14, 30)
HeadlightStatus.Size = UDim2.fromOffset(190, 20)

local HeadlightPower =
    CreateButton(
        HeadlightCard,
        "ENABLE"
    )

HeadlightPower.Size = UDim2.fromOffset(92, 34)
HeadlightPower.Position = UDim2.new(1, -106, 0, 16)

local HeadlightFlash =
    CreateButton(
        HeadlightCard,
        "FLASH: OFF"
    )

HeadlightFlash.Size = UDim2.fromOffset(110, 28)
HeadlightFlash.Position = UDim2.fromOffset(14, 57)

local HeadlightSpeedText =
    CreateLabel(
        HeadlightCard,
        "Speed  0.50 s",
        10,
        Theme.SubText
    )

HeadlightSpeedText.Position = UDim2.fromOffset(140, 60)
HeadlightSpeedText.Size = UDim2.fromOffset(100, 20)

local HeadlightBar = Instance.new("Frame")
HeadlightBar.Size = UDim2.new(1, -268, 0, 6)
HeadlightBar.Position = UDim2.fromOffset(250, 68)
HeadlightBar.BackgroundColor3 = Theme.Slider
HeadlightBar.BorderSizePixel = 0
HeadlightBar.Parent = HeadlightCard
Corner(HeadlightBar, 6)

local HeadlightFill = Instance.new("Frame")
HeadlightFill.Size = UDim2.new(0.75, 0, 1, 0)
HeadlightFill.BackgroundColor3 = Theme.Accent
HeadlightFill.BorderSizePixel = 0
HeadlightFill.Parent = HeadlightBar
Corner(HeadlightFill, 6)

local HeadlightKnob = Instance.new("Frame")
HeadlightKnob.AnchorPoint = Vector2.new(0.5, 0.5)
HeadlightKnob.Position = UDim2.new(0.75, 0, 0.5, 0)
HeadlightKnob.Size = UDim2.fromOffset(15, 15)
HeadlightKnob.BackgroundColor3 = Color3.new(1, 1, 1)
HeadlightKnob.BorderSizePixel = 0
HeadlightKnob.Parent = HeadlightBar
Corner(HeadlightKnob, 15)

local HeadlightDragging = false

local function UpdateHeadlightSpeed(X)
    local Percent = math.clamp(
        (X - HeadlightBar.AbsolutePosition.X)
        / HeadlightBar.AbsoluteSize.X,
        0,
        1
    )

    HeadlightFill.Size = UDim2.new(Percent, 0, 1, 0)
    HeadlightKnob.Position = UDim2.new(Percent, 0, 0.5, 0)

    Headlight.Interval =
        Headlight.MaxInterval
        - ((Headlight.MaxInterval - Headlight.MinInterval) * Percent)

    HeadlightSpeedText.Text =
        string.format("Speed  %.2f s", Headlight.Interval)
end

HeadlightBar.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        HeadlightDragging = true
        UpdateHeadlightSpeed(Input.Position.X)
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if HeadlightDragging
        and Input.UserInputType == Enum.UserInputType.MouseMovement then
        UpdateHeadlightSpeed(Input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        HeadlightDragging = false
    end
end)

HeadlightPower.MouseButton1Click:Connect(function()
    Headlight.Enabled = not Headlight.Enabled

    if Headlight.Enabled then
        local ok = SendHeadlight(true)

        if ok then
            HeadlightPower.Text = "DISABLE"
            HeadlightStatus.Text = "ON  •  CONNECTED"
            HeadlightStatus.TextColor3 = Theme.Green
        else
            Headlight.Enabled = false
            HeadlightStatus.Text = "REMOTE NOT FOUND"
            HeadlightStatus.TextColor3 = Theme.Red
        end
    else
        Headlight.Flashing = false
        SendHeadlight(false)

        HeadlightPower.Text = "ENABLE"
        HeadlightFlash.Text = "FLASH: OFF"
        HeadlightFlash.BackgroundColor3 = Theme.CardHover
        HeadlightStatus.Text = "OFF  •  READY"
        HeadlightStatus.TextColor3 = Theme.SubText
    end
end)

HeadlightFlash.MouseButton1Click:Connect(function()
    if not Headlight.Enabled then
        return
    end

    Headlight.Flashing = not Headlight.Flashing

    if Headlight.Flashing then
        HeadlightFlash.Text = "FLASH: ON"
        HeadlightFlash.BackgroundColor3 = Theme.Accent
    else
        HeadlightFlash.Text = "FLASH: OFF"
        HeadlightFlash.BackgroundColor3 = Theme.CardHover
        SendHeadlight(false)
    end
end)


--==============================================================
-- EFFECTS
--==============================================================

local EffectsCard =
    CreateCard(
        Content,
        108,
        3
    )


local EffectsTitle =
    CreateLabel(
        EffectsCard,
        "EFFECT",
        10,
        Theme.SubText
    )

EffectsTitle.Font =
    Enum.Font.GothamBold

EffectsTitle.Position =
    UDim2.fromOffset(
        14,
        9
    )


local EffectsHolder =
    Instance.new("Frame")

EffectsHolder.Size =
    UDim2.new(
        1,
        -24,
        0,
        62
    )

EffectsHolder.Position =
    UDim2.fromOffset(
        12,
        37
    )

EffectsHolder.BackgroundTransparency = 1

EffectsHolder.Parent =
    EffectsCard


local EffectGrid =
    Instance.new("UIGridLayout")

EffectGrid.CellSize =
    UDim2.new(
        0.25,
        -6,
        0,
        27
    )

EffectGrid.CellPadding =
    UDim2.fromOffset(
        7,
        6
    )

EffectGrid.Parent =
    EffectsHolder


local Effects = {
    "Rainbow",
    "Pulse",
    "Police",
    "Static",

    "Ocean",
    "Sunset",
    "Cyber",
    "White"
}


local EffectButtons = {}


local function UpdateEffects()

    for Name, Button
        in pairs(EffectButtons) do

        if Name == State.Effect then

            Button.BackgroundColor3 =
                Theme.Accent

            Button.TextColor3 =
                Color3.new(1, 1, 1)

        else

            Button.BackgroundColor3 =
                Theme.CardHover

            Button.TextColor3 =
                Theme.SubText
        end
    end
end


for _, Name in ipairs(Effects) do

    local Button =
        CreateButton(
            EffectsHolder,
            Name
        )

    EffectButtons[Name] =
        Button

    Button.MouseButton1Click:Connect(function()

        State.Effect = Name

        UpdateEffects()
    end)
end

UpdateEffects()


--==============================================================
-- SLIDERS
--==============================================================

local Controls =
    CreateCard(
        Content,
        176,
        4
    )


local function CreateSlider(
    Parent,
    Name,
    Y,
    Default
)

    local Value = Default
    local Dragging = false


    local NameLabel =
        CreateLabel(
            Parent,
            Name,
            12,
            Theme.Text
        )

    NameLabel.Position =
        UDim2.fromOffset(
            14,
            Y
        )


    local ValueLabel =
        CreateLabel(
            Parent,
            tostring(Default) .. "%",
            11,
            Theme.SubText
        )

    ValueLabel.Size =
        UDim2.fromOffset(
            60,
            20
        )

    ValueLabel.Position =
        UDim2.new(
            1,
            -75,
            0,
            Y
        )

    ValueLabel.TextXAlignment =
        Enum.TextXAlignment.Right


    local Bar =
        Instance.new("Frame")

    Bar.Size =
        UDim2.new(
            1,
            -28,
            0,
            6
        )

    Bar.Position =
        UDim2.fromOffset(
            14,
            Y + 27
        )

    Bar.BackgroundColor3 =
        Theme.Slider

    Bar.BorderSizePixel = 0

    Bar.Parent = Parent

    Corner(Bar, 6)


    local Fill =
        Instance.new("Frame")

    Fill.Size =
        UDim2.new(
            Default / 100,
            0,
            1,
            0
        )

    Fill.BackgroundColor3 =
        Theme.Accent

    Fill.BorderSizePixel = 0

    Fill.Parent = Bar

    Corner(Fill, 6)


    local Knob =
        Instance.new("Frame")

    Knob.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )

    Knob.Position =
        UDim2.new(
            Default / 100,
            0,
            0.5,
            0
        )

    Knob.Size =
        UDim2.fromOffset(
            15,
            15
        )

    Knob.BackgroundColor3 =
        Color3.new(1, 1, 1)

    Knob.BorderSizePixel = 0

    Knob.Parent = Bar

    Corner(Knob, 15)


    local function Update(X)

        local Percent =
            math.clamp(
                (
                    X -
                    Bar.AbsolutePosition.X
                )
                /
                Bar.AbsoluteSize.X,

                0,
                1
            )

        Value =
            math.floor(
                Percent * 100
            )

        Fill.Size =
            UDim2.new(
                Percent,
                0,
                1,
                0
            )

        Knob.Position =
            UDim2.new(
                Percent,
                0,
                0.5,
                0
            )

        ValueLabel.Text =
            tostring(Value) .. "%"
    end


    Bar.InputBegan:Connect(function(Input)

        if Input.UserInputType
            == Enum.UserInputType.MouseButton1 then

            Dragging = true

            Update(
                Input.Position.X
            )
        end
    end)


    UserInputService.InputChanged:Connect(function(Input)

        if Dragging
            and Input.UserInputType
            == Enum.UserInputType.MouseMovement then

            Update(
                Input.Position.X
            )
        end
    end)


    UserInputService.InputEnded:Connect(function(Input)

        if Input.UserInputType
            == Enum.UserInputType.MouseButton1 then

            Dragging = false
        end
    end)


    return function()
        return Value
    end
end


local GetSpeed =
    CreateSlider(
        Controls,
        "Speed",
        12,
        State.Speed
    )


local GetSaturation =
    CreateSlider(
        Controls,
        "Saturation",
        64,
        State.Saturation
    )


local GetBrightness =
    CreateSlider(
        Controls,
        "Brightness",
        116,
        State.Brightness
    )


--==============================================================
-- TRANSITION
--==============================================================

local TransitionCard =
    CreateCard(
        Content,
        63,
        5
    )


local TransitionTitle =
    CreateLabel(
        TransitionCard,
        "TRANSITION",
        10,
        Theme.SubText
    )

TransitionTitle.Position =
    UDim2.fromOffset(
        14,
        8
    )


local Smooth =
    CreateButton(
        TransitionCard,
        "● SMOOTH"
    )

Smooth.Size =
    UDim2.new(
        0.5,
        -20,
        0,
        27
    )

Smooth.Position =
    UDim2.fromOffset(
        14,
        30
    )


local Blink =
    CreateButton(
        TransitionCard,
        "BLINK"
    )

Blink.Size =
    UDim2.new(
        0.5,
        -20,
        0,
        27
    )

Blink.Position =
    UDim2.new(
        0.5,
        6,
        0,
        30
    )


local function UpdateTransition()

    if State.Blink then

        Blink.Text =
            "● BLINK"

        Smooth.Text =
            "SMOOTH"

        Blink.BackgroundColor3 =
            Theme.Accent

        Smooth.BackgroundColor3 =
            Theme.CardHover

    else

        Smooth.Text =
            "● SMOOTH"

        Blink.Text =
            "BLINK"

        Smooth.BackgroundColor3 =
            Theme.Accent

        Blink.BackgroundColor3 =
            Theme.CardHover
    end
end


Smooth.MouseButton1Click:Connect(function()

    State.Blink = false

    UpdateTransition()
end)


Blink.MouseButton1Click:Connect(function()

    State.Blink = true

    UpdateTransition()
end)


UpdateTransition()


--==============================================================
-- STATIC COLOR PALETTE
--==============================================================

local PaletteCard =
    CreateCard(
        Content,
        73,
        6
    )


local PaletteTitle =
    CreateLabel(
        PaletteCard,
        "STATIC COLOR",
        10,
        Theme.SubText
    )

PaletteTitle.Position =
    UDim2.fromOffset(
        14,
        8
    )


local PaletteColors = {

    Color3.fromRGB(255, 45, 65),
    Color3.fromRGB(255, 140, 25),
    Color3.fromRGB(255, 225, 40),

    Color3.fromRGB(50, 255, 115),
    Color3.fromRGB(30, 225, 255),

    Color3.fromRGB(55, 100, 255),
    Color3.fromRGB(185, 60, 255),
    Color3.fromRGB(255, 45, 200)
}


for Index, Color
    in ipairs(PaletteColors) do

    local ColorButton =
        Instance.new("TextButton")

    ColorButton.Text = ""

    ColorButton.Size =
        UDim2.fromOffset(
            36,
            29
        )

    ColorButton.Position =
        UDim2.fromOffset(
            14 +
            ((Index - 1) * 47),

            35
        )

    ColorButton.BackgroundColor3 =
        Color

    ColorButton.BorderSizePixel = 0

    ColorButton.Parent =
        PaletteCard

    Corner(
        ColorButton,
        8
    )


    ColorButton.MouseButton1Click:Connect(function()

        State.StaticColor =
            Color

        State.Effect =
            "Static"

        UpdateEffects()

        if State.Enabled then

            if State.Blink then

                ApplyBlink(
                    Color,
                    0.10
                )

            else

                -- TRUE SMOOTH
                ApplySmooth(
                    Color
                )
            end
        end
    end)
end


--==============================================================
-- LIVE PREVIEW
--==============================================================

local Preview =
    CreateCard(
        Content,
        36,
        7
    )

Preview.BackgroundColor3 =
    State.StaticColor

Preview.BackgroundTransparency =
    0.05


local PreviewText =
    CreateLabel(
        Preview,
        "LIVE COLOR",
        10,
        Color3.new(1, 1, 1)
    )

PreviewText.Size =
    UDim2.new(
        1,
        0,
        1,
        0
    )

PreviewText.TextXAlignment =
    Enum.TextXAlignment.Center

PreviewText.Font =
    Enum.Font.GothamBold


--==============================================================
-- POWER
--==============================================================

Power.MouseButton1Click:Connect(function()

    State.Enabled =
        not State.Enabled

    if State.Enabled then

        Power.Text =
            "DISABLE"

        StatusTitle.Text =
            "Underglow active"

        StatusDot.BackgroundColor3 =
            Theme.Green

        -- Première activation
        SendUnderglow(
            true,
            LastColor
        )

    else

        Power.Text =
            "ENABLE"

        StatusTitle.Text =
            "Underglow disabled"

        StatusDot.BackgroundColor3 =
            Theme.Red

        SendUnderglow(
            false,
            LastColor
        )
    end
end)


--==============================================================
-- MINIMIZE
--==============================================================

Minimize.MouseButton1Click:Connect(function()

    State.Minimized =
        not State.Minimized

    if State.Minimized then

        -- Compact mode: replace the whole window by the avatar icon.
        Main.Visible = false
        AvatarButton.Visible = true

    else

        -- Restore the complete window.
        AvatarButton.Visible = false
        Main.Visible = true

        Main.Size =
            UDim2.fromOffset(
                560,
                800
            )

        Minimize.Text = "—"
    end
end)

--==============================================================
-- MOVABLE AVATAR ICON
--==============================================================

local AvatarDragging = false
local AvatarDragged = false
local AvatarDragStart
local AvatarStartPosition

AvatarButton.InputBegan:Connect(function(Input)

    if Input.UserInputType
        == Enum.UserInputType.MouseButton1 then

        AvatarDragging = true
        AvatarDragged = false

        AvatarDragStart =
            Input.Position

        AvatarStartPosition =
            AvatarButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(Input)

    if AvatarDragging
        and Input.UserInputType
        == Enum.UserInputType.MouseMovement then

        local Delta =
            Input.Position -
            AvatarDragStart

        if math.abs(Delta.X) > 5
            or math.abs(Delta.Y) > 5 then

            AvatarDragged = true
        end

        local Camera =
            workspace.CurrentCamera

        if Camera then

            local Viewport =
                Camera.ViewportSize

            local Size =
                AvatarButton.AbsoluteSize

            local NewX =
                AvatarStartPosition.X.Offset +
                Delta.X

            local NewY =
                AvatarStartPosition.Y.Offset +
                Delta.Y

            -- Keep the icon inside the screen.
            NewX =
                math.clamp(
                    NewX,
                    0,
                    Viewport.X - Size.X
                )

            NewY =
                math.clamp(
                    NewY,
                    0,
                    Viewport.Y - Size.Y
                )

            AvatarButton.Position =
                UDim2.fromOffset(
                    NewX,
                    NewY
                )
        end
    end
end)

UserInputService.InputEnded:Connect(function(Input)

    if Input.UserInputType
        == Enum.UserInputType.MouseButton1
        and AvatarDragging then

        AvatarDragging = false

        -- If it was a simple click, open the menu.
        if not AvatarDragged then

            State.Minimized = false

            AvatarButton.Visible = false
            Main.Visible = true

            Main.Size =
                UDim2.fromOffset(
                    560,
                    800
                )

            Minimize.Text = "—"
        end
    end
end)


--==============================================================
-- CLOSE
--==============================================================

Close.MouseButton1Click:Connect(function()

    State.Enabled = false
    State.Closed = true
    AvatarButton.Visible = false

    Headlight.Enabled = false
    Headlight.Flashing = false
    SendHeadlight(false)

    _G.UnderglowStudioV5 = false

    SendUnderglow(
        false,
        LastColor
    )

    GUI:Destroy()
end)


--==============================================================
-- DRAG WINDOW
--==============================================================

local Dragging = false
local DragStart
local StartPosition


Header.InputBegan:Connect(function(Input)

    if Input.UserInputType
        == Enum.UserInputType.MouseButton1 then

        Dragging = true

        DragStart =
            Input.Position

        StartPosition =
            Main.Position
    end
end)


UserInputService.InputEnded:Connect(function(Input)

    if Input.UserInputType
        == Enum.UserInputType.MouseButton1 then

        Dragging = false
    end
end)


UserInputService.InputChanged:Connect(function(Input)

    if Dragging
        and Input.UserInputType
        == Enum.UserInputType.MouseMovement then

        local Delta =
            Input.Position -
            DragStart

        Main.Position =
            UDim2.new(

                StartPosition.X.Scale,

                StartPosition.X.Offset +
                Delta.X,

                StartPosition.Y.Scale,

                StartPosition.Y.Offset +
                Delta.Y
            )
    end
end)


--==============================================================
-- HEADLIGHT FLASH ENGINE
--==============================================================

task.spawn(function()
    while
        _G.UnderglowStudioV5
        and not State.Closed
    do
        if Headlight.Enabled and Headlight.Flashing then
            local Remote = GetHeadlightRemote()

            if Remote then
                SendHeadlight(true)
                task.wait(Headlight.Interval)

                -- Do NOT break here.
                -- The loop must stay alive so Flash can be restarted
                -- after Disable -> Enable.
                if Headlight.Enabled and Headlight.Flashing then
                    SendHeadlight(false)
                    task.wait(Headlight.Interval)
                end
            else
                HeadlightStatus.Text = "REMOTE NOT FOUND"
                HeadlightStatus.TextColor3 = Theme.Red
                task.wait(0.25)
            end
        else
            task.wait(0.15)
        end
    end
end)


--==============================================================
-- EFFECT ENGINE
--==============================================================

task.spawn(function()

    local Hue = 0

    local Pulse = 1
    local PulseDirection = -1

    local PoliceState = false


    while
        _G.UnderglowStudioV5
        and not State.Closed
    do

        State.Speed =
            GetSpeed()

        State.Saturation =
            GetSaturation()

        State.Brightness =
            GetBrightness()


        --======================================================
        -- CONNECTION
        --======================================================

        local Car, Remote =
            GetCarAndRemote()

        if Car and Remote then

            CarStatus.Text =
                Car.Name ..
                "  •  CONNECTED"

            CarStatus.TextColor3 =
                Theme.Green

        else

            CarStatus.Text =
                "Sit in a compatible vehicle"

            CarStatus.TextColor3 =
                Theme.SubText
        end


        --======================================================
        -- EFFECT
        --======================================================

        if State.Enabled
            and Remote then

            local SpeedNormalized =
                math.max(
                    State.Speed,
                    1
                ) / 100


            -- 0.40 sec à basse vitesse
            -- ~0.055 sec à haute vitesse

            local Delay =
                0.40 -
                (
                    SpeedNormalized *
                    0.345
                )


            local Sat =
                State.Saturation /
                100


            local Bright =
                math.max(
                    State.Brightness,
                    5
                ) / 100


            local Color


            --==================================================
            -- RAINBOW
            --==================================================

            if State.Effect
                == "Rainbow" then

                Hue =
                    (
                        Hue +
                        0.006 +
                        SpeedNormalized *
                        0.018
                    )
                    % 1

                Color =
                    Color3.fromHSV(
                        Hue,
                        Sat,
                        Bright
                    )


            --==================================================
            -- PULSE
            --==================================================

            elseif State.Effect
                == "Pulse" then

                Pulse =
                    Pulse +
                    (
                        0.01 +
                        SpeedNormalized *
                        0.045
                    )
                    *
                    PulseDirection

                if Pulse >= 1 then

                    Pulse = 1

                    PulseDirection = -1

                elseif Pulse <= 0.15 then

                    Pulse = 0.15

                    PulseDirection = 1
                end

                Hue =
                    (
                        Hue +
                        0.004
                    )
                    % 1

                Color =
                    Color3.fromHSV(
                        Hue,
                        Sat,
                        Pulse *
                        Bright
                    )


            --==================================================
            -- POLICE
            --==================================================

            elseif State.Effect
                == "Police" then

                PoliceState =
                    not PoliceState

                if PoliceState then

                    Color =
                        Color3.fromRGB(
                            255,
                            20,
                            35
                        )

                else

                    Color =
                        Color3.fromRGB(
                            25,
                            70,
                            255
                        )
                end


            --==================================================
            -- OCEAN
            --==================================================

            elseif State.Effect
                == "Ocean" then

                Hue =
                    (
                        Hue +
                        0.004 +
                        SpeedNormalized *
                        0.010
                    )
                    % 1

                local OceanHue =
                    0.50 +
                    math.sin(
                        Hue *
                        math.pi *
                        2
                    ) *
                    0.10

                Color =
                    Color3.fromHSV(
                        OceanHue,
                        Sat,
                        Bright
                    )


            --==================================================
            -- SUNSET
            --==================================================

            elseif State.Effect
                == "Sunset" then

                Hue =
                    (
                        Hue +
                        0.004 +
                        SpeedNormalized *
                        0.010
                    )
                    % 1

                local SunsetHue =
                    0.015 +
                    (
                        (
                            math.sin(
                                Hue *
                                math.pi *
                                2
                            )
                            + 1
                        )
                        / 2
                    )
                    * 0.12

                Color =
                    Color3.fromHSV(
                        SunsetHue,
                        Sat,
                        Bright
                    )


            --==================================================
            -- CYBER
            --==================================================

            elseif State.Effect
                == "Cyber" then

                Hue =
                    (
                        Hue +
                        0.007 +
                        SpeedNormalized *
                        0.016
                    )
                    % 1

                if math.sin(
                    Hue *
                    math.pi *
                    2
                ) > 0 then

                    Color =
                        Color3.fromRGB(
                            255,
                            0,
                            220
                        )

                else

                    Color =
                        Color3.fromRGB(
                            0,
                            225,
                            255
                        )
                end


            --==================================================
            -- WHITE
            --==================================================

            elseif State.Effect
                == "White" then

                Color =
                    Color3.new(
                        Bright,
                        Bright,
                        Bright
                    )


            --==================================================
            -- STATIC
            --==================================================

            else

                Color =
                    State.StaticColor
            end


            --==================================================
            -- LIVE UI
            --==================================================

            Preview.BackgroundColor3 =
                Color

            TopBar.BackgroundColor3 =
                Color

            MainStroke.Color =
                Color


            --==================================================
            -- SEND
            --==================================================

            if State.Blink then

                -- OFF / ON volontaire
                ApplyBlink(
                    Color,
                    math.max(
                        0.07,
                        Delay * 0.35
                    )
                )

            else

                --==============================================
                -- TRUE SMOOTH
                --
                -- AUCUN :
                -- FireServer(... false ...)
                --
                -- entre deux couleurs.
                --==============================================

                ApplySmooth(
                    Color
                )
            end


            task.wait(
                Delay
            )

        else

            task.wait(
                0.15
            )
        end
    end
end)


print("------------------------------------")
print(" UNDERGLOW STUDIO V5")
print(" TRUE SMOOTH ENGINE LOADED")
print("------------------------------------")
