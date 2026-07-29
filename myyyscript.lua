--[[
    CLEAN GLASS UI - MINIMALIST EDITION
    - Toggle: RightShift або Клік на круглу іконку з черепом
    - Style: Полупрозоре скло (Glassmorphism)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ЗНИЩЕННЯ СТАРОГО GUI ЯКЩО ІСНУЄ
if CoreGui:FindFirstChild("GlassUI_Container") then
    CoreGui.GlassUI_Container:Destroy()
end

-- СТВОРЕННЯ ГОЛОВНОГО CONTAINER
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GlassUI_Container"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

---------------------------------------------------------
-- 1. КРУГЛА ІКОНКА З ЧЕРЕПОМ (TOGGLE BUTTON)
---------------------------------------------------------
local SkullButton = Instance.new("ImageButton")
SkullButton.Name = "SkullLogo"
SkullButton.Size = UDim2.new(0, 55, 0, 55)
SkullButton.Position = UDim2.new(0, 20, 0.5, -27)
SkullButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
SkullButton.BackgroundTransparency = 0.25
SkullButton.Image = "rbxassetid://10723380252" -- Червоний/білий череп
SkullButton.ImageColor3 = Color3.fromRGB(255, 50, 50)
SkullButton.Active = true
SkullButton.Draggable = true -- Можна перетягувати по екрану
SkullButton.Parent = ScreenGui

local SkullCorner = Instance.new("UICorner")
SkullCorner.CornerRadius = UDim.new(1, 0) -- Повністю кругла
SkullCorner.Parent = SkullButton

local SkullStroke = Instance.new("UIStroke")
SkullStroke.Color = Color3.fromRGB(255, 30, 60)
SkullStroke.Thickness = 2
SkullStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
SkullStroke.Parent = SkullButton

---------------------------------------------------------
-- 2. ОСНОВНЕ СКЛЯНЕ ВІКНО (GLASS MAIN FRAME)
---------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainGlassFrame"
MainFrame.Size = UDim2.new(0, 380, 0, 220)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BackgroundTransparency = 0.35 -- Ефект полупрозорого скла
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 40, 70)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- ЗАГОЛОВОК
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 40)
Title.Position = UDim2.new(0, 20, 0, 15)
Title.BackgroundTransparency = 1
Title.Text = "☠️ SYSTEM ACTIVE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- ПІДЗАГОЛОВОК / ОПИС
TitleSub = Instance.new("TextLabel")
TitleSub.Size = UDim2.new(1, -30, 0, 20)
TitleSub.Position = UDim2.new(0, 20, 0, 45)
TitleSub.BackgroundTransparency = 1
TitleSub.Text = "Clean Glass Interface Mode"
TitleSub.TextColor3 = Color3.fromRGB(180, 180, 190)
TitleSub.TextSize = 13
TitleSub.Font = Enum.Font.Gotham
TitleSub.TextXAlignment = Enum.TextXAlignment.Left
TitleSub.Parent = MainFrame

-- ДЕКОРАТИВНИЙ РОЗДІЛЮВАЧ (НЕОНОВА ЛІНІЯ)
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -40, 0, 1)
Divider.Position = UDim2.new(0, 20, 0, 75)
Divider.BackgroundColor3 = Color3.fromRGB(255, 40, 70)
Divider.BackgroundTransparency = 0.5
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- ІНФОРМАЦІЙНИЙ БЛОК (СТАТУС)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -40, 0, 80)
StatusLabel.Position = UDim2.new(0, 20, 0, 90)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "• Toggle Menu: [RightShift]\n• Quick Access: Click Skull Logo\n• Status: Ready & Loaded"
StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.Parent = MainFrame

---------------------------------------------------------
-- 3. ЛОГІКА ВІДКРИТТЯ / ЗАКРИТТЯ
---------------------------------------------------------
local IsOpen = true

local function ToggleUI()
    IsOpen = not IsOpen
    MainFrame.Visible = IsOpen
end

-- Перемикання кліком на череп
SkullButton.MouseButton1Click:Connect(function()
    ToggleUI()
end)

-- Перемикання клавішею RightShift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        ToggleUI()
    end
end)

print("✅ Glass UI Успішно завантажено!")
