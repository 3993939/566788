-- Порожнє меню + Аім (Жорсткий/Плавний) + ESP
-- F4 = Меню
-- Правий клік = Аім

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========== GUI СКРИПТА ==========
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local CloseButton = Instance.new("TextButton")
local TabFrame = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "MyMenu"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game.CoreGui end) 

Frame.Name = "Main"
Frame.Size = UDim2.new(0, 400, 0, 300)
Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TopBar.BorderSizePixel = 0
TopBar.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Text = "   Menu by Colin"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

CloseButton.Text = "×"
CloseButton.Size = UDim2.new(0, 26, 0, 26)
CloseButton.Position = UDim2.new(1, -28, 0, 2)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TopBar

TabFrame.Name = "Tabs"
TabFrame.Size = UDim2.new(0, 100, 1, -30)
TabFrame.Position = UDim2.new(0, 0, 0, 30)
TabFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = Frame

ContentFrame.Name = "Content"
ContentFrame.Size = UDim2.new(1, -100, 1, -30)
ContentFrame.Position = UDim2.new(0, 100, 0, 30)
ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = Frame

local tabCount = 0
function CreateTab(name)
    tabCount = tabCount + 1
    local Btn = Instance.new("TextButton")
    Btn.Text = name
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.Position = UDim2.new(0, 0, 0, (tabCount - 1) * 32)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.BorderSizePixel = 0
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Btn.Parent = TabFrame
    
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.CanvasSize = UDim2.new(0, 0, 0, 400)
    Page.Visible = (tabCount == 1)
    Page.Parent = ContentFrame
    
    Btn.MouseButton1Click:Connect(function()
        for _, p in ipairs(ContentFrame:GetChildren()) do
            if p:IsA("ScrollingFrame") then p.Visible = false end
        end
        Page.Visible = true
    end)
    return Page
end

function CreateToggle(parent, text, y, default, callback)
    local Toggle = Instance.new("TextButton")
    Toggle.Text = text .. ": " .. (default and "ON" or "OFF")
    Toggle.Size = UDim2.new(1, -20, 0, 35)
    Toggle.Position = UDim2.new(0, 10, 0, y)
    Toggle.BackgroundColor3 = default and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(140, 0, 0)
    Toggle.BorderSizePixel = 0
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.Font = Enum.Font.Gotham
    Toggle.TextSize = 13
    Toggle.Parent = parent
    
    local state = default
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Toggle.Text = text .. ": " .. (state and "ON" or "OFF")
        Toggle.BackgroundColor3 = state and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(140, 0, 0)
        callback(state)
    end)
    return Toggle
end

function CreateButton(parent, text, y, callback)
    local Btn = Instance.new("TextButton")
    Btn.Text = text
    Btn.Size = UDim2.new(1, -20, 0, 35)
    Btn.Position = UDim2.new(0, 10, 0, y)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Btn.BorderSizePixel = 0
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Btn.Parent = parent
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- Керування меню
local guiVisible = true
CloseButton.MouseButton1Click:Connect(function()
    guiVisible = false
    Frame.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        guiVisible = not guiVisible
        Frame.Visible = guiVisible
    end
end)

-- ========== НАЛАШТУВАННЯ ==========
local Settings = {
    AimbotEnabled = false,
    ESPEnabled = false,
    TeamCheck = true,
    WallCheck = true,
    HitPart = "Head",
    Smoothness = 0, -- 0 = ЖОРСТКИЙ АІМ (миттєвий), 0.1 = Плавний
    FOV = 300
}

-- FOV Коло
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Radius = Settings.FOV
FOVCircle.Transparency = 1

-- ========== ЛОГІКА ESP (Boxes) ==========
local function CreateESP(plr)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false

    local function Update()
        local Connection
        Connection = RunService.RenderStepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 and Settings.ESPEnabled then
                if Settings.TeamCheck and plr.Team == LocalPlayer.Team then
                    Box.Visible = false
                else
                    local RootPart = plr.Character.HumanoidRootPart
                    local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)

                    if OnScreen then
                        local Size = (Camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, -3.5, 0)).Y)
                        Box.Size = Vector2.new(Size / 1.5, Size)
                        Box.Position = Vector2.new(Pos.X - Box.Size.X / 2, Pos.Y - Box.Size.Y / 2)
                        Box.Visible = true
                    else
                        Box.Visible = false
                    end
                end
            else
                Box.Visible = false
                if not plr.Parent then
                    Box:Remove()
                    Connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Update)()
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then CreateESP(player) end
end
Players.PlayerAdded:Connect(CreateESP)

-- ========== ЛОГІКА AIMBOT (Жорсткий + Плавний режим) ==========
local function IsBehindWall(targetPart)
    if not Settings.WallCheck then return false end
    local char = LocalPlayer.Character
    if not char then return true end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {char, Camera}
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    if raycastResult then
        return not raycastResult.Instance:IsDescendantOf(targetPart.Parent)
    end
    return false
end

local function GetAimTarget()
    local bestDist = Settings.FOV
    local bestTarget = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        local hitPart = char:FindFirstChild(Settings.HitPart)
        if not (hum and hitPart) or hum.Health <= 0 then continue end
        if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
        if onScreen then
            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
            if screenDist < bestDist then
                if not IsBehindWall(hitPart) then
                    bestDist = screenDist
                    bestTarget = hitPart
                end
            end
        end
    end
    return bestTarget
end

RunService.RenderStepped:Connect(function()
    -- Оновлення FOV кола
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.AimbotEnabled

    if Settings.AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetAimTarget()
        if target then
            local targetDirection = (target.Position - Camera.CFrame.Position).Unit
            if Settings.Smoothness <= 0 then
                -- ЖОРСТКИЙ (МИТТЄВИЙ) АІМ
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            else
                -- ПЛАВНИЙ АІМ
                local smoothDir = Camera.CFrame.LookVector:Lerp(targetDirection, Settings.Smoothness)
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + smoothDir)
            end
        end
    end
end)

-- ========== ВКЛАДКИ МЕНЮ ==========
local aimTab = CreateTab("Aimbot")
local visTab = CreateTab("Visuals")

-- Кнопки Аіму
CreateToggle(aimTab, "Aimbot", 10, false, function(state) Settings.AimbotEnabled = state end)
CreateToggle(aimTab, "Team Check", 50, true, function(state) Settings.TeamCheck = state end)
CreateToggle(aimTab, "Wall Check", 90, true, function(state) Settings.WallCheck = state end)
CreateButton(aimTab, "Target: Head", 130, function() Settings.HitPart = "Head" end)
CreateButton(aimTab, "Target: Torso", 170, function() Settings.HitPart = "HumanoidRootPart" end)
-- Тут важливо: Smoothness 0 = жорсткий
CreateButton(aimTab, "Smooth: 0 (Hard)", 210, function() Settings.Smoothness = 0 end)
CreateButton(aimTab, "Smooth: 0.08", 250, function() Settings.Smoothness = 0.08 end)
CreateButton(aimTab, "Smooth: 0.2", 290, function() Settings.Smoothness = 0.2 end)

-- Кнопки ESP
CreateToggle(visTab, "ESP Boxes", 10, false, function(state) Settings.ESPEnabled = state end)

print("Script Loaded! F4 for Menu. Smoothness 0 = Hard Aim.")
