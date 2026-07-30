-- // ULTIMATE ROBLOX CHEAT v3.0 (NO KEY SYSTEM) \\
-- // Open: Right Shift | Auto-loads GUI \\
-- // FIXED: Aimbot targeting, ESP visibility, Anti-Aim bypass \\

-- // Services \\
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- // Wait for game load \\
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- // Create Main GUI \\
local CheatGUI = Instance.new("ScreenGui")
CheatGUI.Name = "UltimateCheat_" .. tostring(math.random(99999))
CheatGUI.ResetOnSpawn = false
CheatGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- // Protect GUI \\
local function protectGUI(gui)
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        end
        if gethui then
            gui.Parent = gethui()
        else
            gui.Parent = game:GetService("CoreGui")
        end
    end)
end
protectGUI(CheatGUI)

-- // Variables \\
local MenuOpen = true
local ActiveTab = "Aimbot"
local TargetPlayer = nil
local CurrentTarget = nil
local ClientTick = 0

local Settings = {
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        WallCheck = false,
        AimPart = "Head",
        Prediction = false,
        Smoothness = 5,
        FOV = 200,
        AimKey = nil,
        Visible = false,
        AntiAimBypass = true,
        HitChance = 95
    },
    ESP = {
        Enabled = false,
        Boxes = false,
        Tracers = false,
        Names = false,
        Distance = false,
        Health = false,
        TeamCheck = false,
        MaxDistance = 2000,
        VisibleOnly = false
    },
    Visuals = {
        Chams = false,
        ChamsColor = Color3.fromRGB(255, 0, 0),
        ChamsTransparency = 0.5,
        FOV = 70,
        NoRecoil = false,
        NoSpread = false
    },
    Misc = {
        AntiAFK = false,
        AutoFarm = false,
        SpeedHack = false,
        SpeedValue = 16,
        FlyHack = false,
        FlySpeed = 50
    }
}

-- // Create HUD \\
local HUD = Instance.new("Frame")
HUD.Name = "HUD"
HUD.Size = UDim2.new(0, 250, 0, 150)
HUD.Position = UDim2.new(1, -260, 0, 10)
HUD.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
HUD.BackgroundTransparency = 0.4
HUD.BorderSizePixel = 0
HUD.Active = true
HUD.Draggable = true
HUD.Parent = CheatGUI

local HUDCorner = Instance.new("UICorner")
HUDCorner.CornerRadius = UDim.new(0, 12)
HUDCorner.Parent = HUD

-- HUD Title \\
local HUDTitle = Instance.new("TextLabel")
HUDTitle.Size = UDim2.new(1, 0, 0, 30)
HUDTitle.BackgroundTransparency = 1
HUDTitle.Text = "⚡ ULTIMATE CHEAT"
HUDTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HUDTitle.TextSize = 16
HUDTitle.Font = Enum.Font.GothamBold
HUDTitle.Parent = HUD

-- HUD Status Indicators \\
local function createHUDStatus(text, yPos, color)
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(1, -20, 0, 25)
    StatusFrame.Position = UDim2.new(0, 10, 0, yPos)
    StatusFrame.BackgroundTransparency = 1
    StatusFrame.Parent = HUD
    
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 8, 0, 8)
    Dot.Position = UDim2.new(0, 0, 0.5, -4)
    Dot.BackgroundColor3 = color
    Dot.BorderSizePixel = 0
    Dot.Parent = StatusFrame
    
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(1, 0)
    DotCorner.Parent = Dot
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 200, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = StatusFrame
    
    return Dot
end

local AimbotDot = createHUDStatus("Aimbot: OFF", 35, Color3.fromRGB(255, 50, 50))
local ESPDot = createHUDStatus("ESP: OFF", 60, Color3.fromRGB(255, 50, 50))
local VisualsDot = createHUDStatus("Visuals: OFF", 85, Color3.fromRGB(255, 50, 50))

-- FPS Counter \\
local FPSCounter = Instance.new("TextLabel")
FPSCounter.Size = UDim2.new(1, -20, 0, 20)
FPSCounter.Position = UDim2.new(0, 10, 0, 115)
FPSCounter.BackgroundTransparency = 1
FPSCounter.Text = "FPS: 60"
FPSCounter.TextColor3 = Color3.fromRGB(150, 255, 150)
FPSCounter.TextSize = 12
FPSCounter.Font = Enum.Font.Gotham
FPSCounter.TextXAlignment = Enum.TextXAlignment.Left
FPSCounter.Parent = HUD

-- Watermark \\
local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(0, 200, 0, 25)
Watermark.Position = UDim2.new(0, 10, 0, 10)
Watermark.BackgroundTransparency = 1
Watermark.Text = "uc v3.0 | " .. LocalPlayer.Name
Watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
Watermark.TextSize = 13
Watermark.Font = Enum.Font.GothamBold
Watermark.TextXAlignment = Enum.TextXAlignment.Left
Watermark.TextStrokeTransparency = 0.5
Watermark.Parent = CheatGUI

-- // Main Menu \\
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 650, 0, 450)
MainMenu.Position = UDim2.new(0.5, -325, 0.5, -225)
MainMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainMenu.BackgroundTransparency = 0.25
MainMenu.BorderSizePixel = 0
MainMenu.Visible = true
MainMenu.Active = true
MainMenu.Draggable = true
MainMenu.Parent = CheatGUI

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 15)
MenuCorner.Parent = MainMenu

-- Menu Shadow \\
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.5
Shadow.BorderSizePixel = 0
Shadow.ZIndex = -1
Shadow.Parent = MainMenu

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 15)
ShadowCorner.Parent = Shadow

-- Title Bar \\
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BackgroundTransparency = 0.3
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainMenu

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 15)
TitleBarCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 300, 1, 0)
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ULTIMATE CHEAT v3.0"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Close Button \\
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.BackgroundTransparency = 0.3
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MenuOpen = false
    MainMenu.Visible = false
end)

-- Tab System \\
local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(0, 130, 1, -60)
TabButtons.Position = UDim2.new(0, 10, 0, 55)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = MainMenu

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(0, 490, 1, -60)
ContentArea.Position = UDim2.new(0, 150, 0, 55)
ContentArea.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ContentArea.BackgroundTransparency = 0.4
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainMenu

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = ContentArea

-- Tabs Data \\
local Tabs = {}

local function createTab(name, icon, position)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 45)
    TabButton.Position = UDim2.new(0, 0, 0, position)
    TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabButton.BackgroundTransparency = 0.4
    TabButton.Text = icon .. "  " .. name
    TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.BorderSizePixel = 0
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Parent = TabButtons
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton
    
    -- Content frame for this tab \\
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -20, 1, -20)
    Content.Position = UDim2.new(0, 10, 0, 10)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 4
    Content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.Visible = false
    Content.Parent = ContentArea
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Name = "UIListLayout"
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.Parent = Content
    
    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            tab.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        Content.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ActiveTab = name
        Content.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    table.insert(Tabs, {Button = TabButton, Content = Content})
    return Content
end

-- Create all tabs \\
local AimbotContent = createTab("AIMBOT", "🎯", 0)
local ESPContent = createTab("ESP", "👁️", 50)
local VisualsContent = createTab("VISUALS", "🎨", 100)
local MiscContent = createTab("MISC", "⚙️", 150)

-- // UI Elements \\
local function createSection(parent, name)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Size = UDim2.new(1, -10, 0, 35)
    SectionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SectionFrame.BackgroundTransparency = 0.4
    SectionFrame.BorderSizePixel = 0
    SectionFrame.Parent = parent
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 6)
    SectionCorner.Parent = SectionFrame
    
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Size = UDim2.new(1, -20, 1, 0)
    SectionLabel.Position = UDim2.new(0, 10, 0, 0)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = name
    SectionLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    SectionLabel.TextSize = 14
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Parent = SectionFrame
    
    return SectionFrame
end

local function createToggle(parent, text, setting, category)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0, 200, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 13
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 45, 0, 22)
    ToggleButton.Position = UDim2.new(1, -50, 0.5, -11)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleButton.Text = ""
    ToggleButton.BorderSizePixel = 0
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = ToggleFrame
    
    local ToggleButtonCorner = Instance.new("UICorner")
    ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
    ToggleButtonCorner.Parent = ToggleButton
    
    local ToggleDot = Instance.new("Frame")
    ToggleDot.Size = UDim2.new(0, 18, 0, 18)
    ToggleDot.Position = UDim2.new(0, 2, 0.5, -9)
    ToggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleDot.BorderSizePixel = 0
    ToggleDot.Parent = ToggleButton
    
    local ToggleDotCorner = Instance.new("UICorner")
    ToggleDotCorner.CornerRadius = UDim.new(1, 0)
    ToggleDotCorner.Parent = ToggleDot
    
    local toggled = Settings[category][setting]
    
    if toggled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        ToggleDot.Position = UDim2.new(1, -20, 0.5, -9)
    end
    
    local function updateToggle(value)
        toggled = value
        Settings[category][setting] = value
        local goal = {}
        if value then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            goal.Position = UDim2.new(1, -20, 0.5, -9)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            goal.Position = UDim2.new(0, 2, 0.5, -9)
        end
        TweenService:Create(ToggleDot, TweenInfo.new(0.2), goal):Play()
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        updateToggle(not toggled)
    end)
    
    return ToggleFrame
end

local function createDropdown(parent, text, options, setting, category)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, -10, 0, 40)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Parent = parent
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 0, 35)
    DropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    DropdownButton.BackgroundTransparency = 0.3
    DropdownButton.Text = "  " .. text .. ": " .. Settings[category][setting]
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.TextSize = 13
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.BorderSizePixel = 0
    DropdownButton.AutoButtonColor = false
    DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    DropdownButton.Parent = DropdownFrame
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = DropdownButton
    
    local DropList = Instance.new("Frame")
    DropList.Size = UDim2.new(1, 0, 0, 0)
    DropList.Position = UDim2.new(0, 0, 1, 5)
    DropList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropList.BackgroundTransparency = 0.2
    DropList.BorderSizePixel = 0
    DropList.ClipsDescendants = true
    DropList.Visible = false
    DropList.ZIndex = 10
    DropList.Parent = DropdownFrame
    
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 6)
    ListCorner.Parent = DropList
    
    local open = false
    
    for i, option in pairs(options) do
        local OptButton = Instance.new("TextButton")
        OptButton.Size = UDim2.new(1, 0, 0, 30)
        OptButton.Position = UDim2.new(0, 0, 0, (i-1)*30)
        OptButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        OptButton.Text = option
        OptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptButton.TextSize = 13
        OptButton.Font = Enum.Font.Gotham
        OptButton.BorderSizePixel = 0
        OptButton.ZIndex = 10
        OptButton.Parent = DropList
        
        OptButton.MouseButton1Click:Connect(function()
            Settings[category][setting] = option
            DropdownButton.Text = "  " .. text .. ": " .. option
            open = false
            DropList.Visible = false
        end)
    end
    
    DropdownButton.MouseButton1Click:Connect(function()
        open = not open
        DropList.Visible = open
        if open then
            DropList:TweenSize(UDim2.new(1, 0, 0, #options * 30), "Out", "Quad", 0.2, true)
        else
            DropList:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.2, true)
        end
    end)
    
    return DropdownFrame
end

local function createSlider(parent, text, min, max, setting, category)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text .. ": " .. Settings[category][setting]
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextSize = 13
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, 0, 0, 6)
    SliderBg.Position = UDim2.new(0, 0, 0, 30)
    SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderBg.BorderSizePixel = 0
    SliderBg.Parent = SliderFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(1, 0)
    SliderCorner.Parent = SliderBg
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((Settings[category][setting] - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBg
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill
    
    local SliderKnob = Instance.new("TextButton")
    SliderKnob.Size = UDim2.new(0, 16, 0, 16)
    SliderKnob.Position = UDim2.new((Settings[category][setting] - min) / (max - min), -8, 0.5, -8)
    SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderKnob.Text = ""
    SliderKnob.BorderSizePixel = 0
    SliderKnob.AutoButtonColor = false
    SliderKnob.Parent = SliderBg
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = SliderKnob
    
    local dragging = false
    
    SliderKnob.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local barStart = SliderBg.AbsolutePosition.X
            local barWidth = SliderBg.AbsoluteSize.X
            local percent = math.clamp((mousePos.X - barStart) / barWidth, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            SliderKnob.Position = UDim2.new(percent, -8, 0.5, -8)
            SliderLabel.Text = text .. ": " .. value
            Settings[category][setting] = value
        end
    end)
    
    return SliderFrame
end

-- // Populate Tabs \\
-- AIMBOT TAB \\
createSection(AimbotContent, "AIMBOT SETTINGS")
createToggle(AimbotContent, "Enable Aimbot", "Enabled", "Aimbot")
createToggle(AimbotContent, "Team Check", "TeamCheck", "Aimbot")
createToggle(AimbotContent, "Wall Check", "WallCheck", "Aimbot")
createToggle(AimbotContent, "Player Prediction", "Prediction", "Aimbot")
createToggle(AimbotContent, "Anti-Aim Bypass", "AntiAimBypass", "Aimbot")
createDropdown(AimbotContent, "Aim Part", {"Head", "Torso", "HumanoidRootPart"}, "AimPart", "Aimbot")
createSlider(AimbotContent, "Smoothness", 1, 20, "Smoothness", "Aimbot")
createSlider(AimbotContent, "FOV Radius", 50, 500, "FOV", "Aimbot")
createSlider(AimbotContent, "Hit Chance", 1, 100, "HitChance", "Aimbot")

-- ESP TAB \\
createSection(ESPContent, "ESP SETTINGS")
createToggle(ESPContent, "Enable ESP", "Enabled", "ESP")
createToggle(ESPContent, "Team Check", "TeamCheck", "ESP")
createToggle(ESPContent, "ESP Boxes", "Boxes", "ESP")
createToggle(ESPContent, "ESP Names", "Names", "ESP")
createToggle(ESPContent, "ESP Distance", "Distance", "ESP")
createToggle(ESPContent, "ESP Health", "Health", "ESP")
createToggle(ESPContent, "Visible Only", "VisibleOnly", "ESP")
createSlider(ESPContent, "Max Distance", 500, 5000, "MaxDistance", "ESP")

-- VISUALS TAB \\
createSection(VisualsContent, "VISUAL SETTINGS")
createToggle(VisualsContent, "Enable Chams", "Chams", "Visuals")
createSlider(VisualsContent, "FOV Changer", 30, 120, "FOV", "Visuals")
createToggle(VisualsContent, "No Recoil", "NoRecoil", "Visuals")
createToggle(VisualsContent, "No Spread", "NoSpread", "Visuals")

-- MISC TAB \\
createSection(MiscContent, "MISC SETTINGS")
createToggle(MiscContent, "Anti AFK", "AntiAFK", "Misc")
createToggle(MiscContent, "Speed Hack", "SpeedHack", "Misc")
createSlider(MiscContent, "Walk Speed", 16, 200, "SpeedValue", "Misc")
createToggle(MiscContent, "Fly Hack", "FlyHack", "Misc")
createSlider(MiscContent, "Fly Speed", 10, 150, "FlySpeed", "Misc")

-- // Aimbot System - FIXED Targeting \\
local function isPlayerValid(player)
    if not player or player == LocalPlayer then return false end
    if not player.Character then return false end
    if not player.Character:FindFirstChild("HumanoidRootPart") then return false end
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    if Settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then return false end
    
    local root = player.Character.HumanoidRootPart
    local distance = (root.Position - Camera.CFrame.Position).Magnitude
    if distance > 1000 then return false end -- Max aim distance
    
    return true
end

local function getClosestPlayer()
    if not Settings.Aimbot.Enabled then return nil end
    
    local closest = nil
    local closestDist = Settings.Aimbot.FOV
    local mousePos = UserInputService:GetMouseLocation()
    local currentTick = tick()
    
    -- Update target every 5 ticks to prevent flickering
    if currentTick - ClientTick < 0.1 and TargetPlayer then
        if isPlayerValid(TargetPlayer) then
            return TargetPlayer
        end
    end
    ClientTick = currentTick
    
    for _, player in pairs(Players:GetPlayers()) do
        if not isPlayerValid(player) then continue end
        
        local character = player.Character
        local root = character.HumanoidRootPart
        local humanoid = character.Humanoid
        
        -- Get aim part position
        local aimPart = character:FindFirstChild(Settings.Aimbot.AimPart) or root
        
        -- Check if on screen
        local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then continue end
        
        -- Calculate FOV distance
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        
        -- Check wall
        if Settings.Aimbot.WallCheck then
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
            local ray = Workspace:Raycast(Camera.CFrame.Position, (aimPart.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
            if ray and not ray.Instance:IsDescendantOf(character) then
                continue
            end
        end
        
        -- Hit chance check (for anti-aim bypass)
        if Settings.Aimbot.AntiAimBypass then
            local hitChance = Settings.Aimbot.HitChance / 100
            if math.random() > hitChance then
                -- Add slight randomness to avoid detection
                local randomOffset = Vector3.new(
                    math.random(-5, 5),
                    math.random(-5, 5),
                    math.random(-5, 5)
                )
                local newPos = aimPart.Position + randomOffset
                local newScreenPos = Camera:WorldToViewportPoint(newPos)
                local newDist = (Vector2.new(newScreenPos.X, newScreenPos.Y) - mousePos).Magnitude
                if newDist < closestDist then
                    closestDist = newDist
                    closest = player
                end
                continue
            end
        end
        
        if dist < closestDist then
            closestDist = dist
            closest = player
        end
    end
    
    TargetPlayer = closest
    return closest
end

-- Aimbot render step - FIXED smooth aiming \\
RunService:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value + 1, function()
    if not Settings.Aimbot.Enabled then return end
    
    local target = getClosestPlayer()
    if target and target.Character then
        local character = target.Character
        local aimPart = character:FindFirstChild(Settings.Aimbot.AimPart) or character:FindFirstChild("HumanoidRootPart")
        
        if aimPart then
            local targetPos = aimPart.Position
            
            -- Prediction
            if Settings.Aimbot.Prediction and character:FindFirstChild("HumanoidRootPart") then
                local velocity = character.HumanoidRootPart.Velocity
                local distance = (targetPos - Camera.CFrame.Position).Magnitude
                local timeToTarget = distance / 500 -- Average bullet speed
                targetPos = targetPos + (velocity * timeToTarget)
            end
            
            -- Anti-aim bypass: add slight offset randomization
            if Settings.Aimbot.AntiAimBypass then
                local randomOffset = Vector3.new(
                    math.random(-2, 2),
                    math.random(-2, 2),
                    math.random(-2, 2)
                )
                targetPos = targetPos + randomOffset
            end
            
            -- Smooth aiming - fixed to not overshoot
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetPos)
            
            local smoothFactor = math.clamp(1 / math.max(Settings.Aimbot.Smoothness, 1), 0.05, 1)
            
            -- Clamp rotation to prevent weird snapping
            local newCFrame = currentCFrame:Lerp(targetCFrame, smoothFactor)
            Camera.CFrame = newCFrame
        end
    end
end)

-- // ESP System - FIXED Visibility \\
local ESPObjects = {}
local function updateESP()
    if not Settings.ESP.Enabled then
        for _, esp in pairs(ESPObjects) do
            if esp then esp:Destroy() end
        end
        ESPObjects = {}
        return
    end
    
    -- Clean up old ESP objects
    for player, esp in pairs(ESPObjects) do
        if not player or not player.Character or not player.Character.Parent then
            esp:Destroy()
            ESPObjects[player] = nil
        end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character.Parent then
            if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then
                if ESPObjects[player] then
