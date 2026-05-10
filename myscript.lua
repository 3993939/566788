-- Порожнє меню + Аім від Colin (ВИПРАВЛЕНО)
-- F4 = сховати/показати меню
-- Правий клік = аім

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========== GUI ==========
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local CloseButton = Instance.new("TextButton")
local TabFrame = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "MyMenu"
ScreenGui.ResetOnSpawn = false
-- Використовуємо pcall, щоб скрипт не впав, якщо доступу до CoreGui немає (залежить від екзекутора)
pcall(function() ScreenGui.Parent = game.CoreGui end) 

Frame.Name = "Main"
Frame.Size = UDim2.new(0, 400, 0, 300)
Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true -- Працює в більшості старих екзекуторів
Frame.Parent = ScreenGui

UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TopBar.BorderSizePixel = 0
TopBar.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Text = "   My Script"
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
    Page.Visible = (tabCount == 1) -- Перша вкладка відразу видима
    Page.Parent = ContentFrame
    
    Btn.MouseButton1Click:Connect(function()
        for _, p in ipairs(ContentFrame:GetChildren()) do
            if p:IsA("ScrollingFrame") then p.Visible = false end
        end
        Page.Visible = true
    end)
    
    return Page
end

-- Інші функції GUI без змін (CreateButton, CreateToggle...)
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

-- Керування видимістю
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

-- ========== НАЛАШТУВАННЯ АІМУ ==========
local Aimbot = {
    Enabled = false,
    Target = nil,
    AimKey = Enum.UserInputType.MouseButton2, -- Виправлено: краще використовувати Enum
    HitPart = "Head",
    Smoothness = 0.2, -- Було занадто мало, камера могла "дьоргатись"
    FOV = 200,
    WallCheck = true,
    TeamCheck = true
}

-- ========== ФУНКЦІЇ АІМУ (ВИПРАВЛЕНО) ==========
local function IsBehindWall(targetPart)
    if not Aimbot.WallCheck then return false end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return true end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude -- Новий стандарт замість Blacklist
    raycastParams.FilterDescendantsInstances = {char, Camera}
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    if raycastResult then
        -- Якщо промінь влучив у щось, що не є частиною гравця — значить там стіна
        return not raycastResult.Instance:IsDescendantOf(targetPart.Parent)
    end
    return false
end

local function GetAimTarget()
    local bestDist = Aimbot.FOV
    local bestTarget = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end
        
        local hum = char:FindFirstChild("Humanoid")
        local hitPart = char:FindFirstChild(Aimbot.HitPart)
        if not (hum and hitPart) or hum.Health <= 0 then continue end
        
        if Aimbot.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
        if onScreen then
            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
            if screenDist < bestDist then
                if not IsBehindWall(hitPart) then
                    bestDist = screenDist
                    bestTarget = {Part = hitPart, Player = plr}
                end
            end
        end
    end
    return bestTarget
end

RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Aimbot.AimKey) then
        if not Aimbot.Target or not Aimbot.Target.Part or not Aimbot.Target.Part.Parent or Aimbot.Target.Player.Character.Humanoid.Health <= 0 then
            Aimbot.Target = GetAimTarget()
        end
        
        if Aimbot.Target and Aimbot.Target.Part then
            local targetPos = Camera:WorldToViewportPoint(Aimbot.Target.Part.Position)
            local mousePos = UserInputService:GetMouseLocation()
            -- Плавне наведення миші (працює краще для легітності)
            local moveX = (targetPos.X - mousePos.X) * Aimbot.Smoothness
            local moveY = (targetPos.Y - mousePos.Y) * Aimbot.Smoothness
            mousemoverel(moveX, moveY) -- Функція більшості екзекуторів
        end
    else
        Aimbot.Target = nil
    end
end)

-- ========== СТВОРЕННЯ ВКЛАДКИ ТА КНОПОК ==========
local mainTab = CreateTab("Aimbot")

CreateToggle(mainTab, "Aimbot", 10, false, function(state)
    Aimbot.Enabled = state
end)

CreateToggle(mainTab, "Team Check", 50, true, function(state)
    Aimbot.TeamCheck = state
end)

CreateToggle(mainTab, "Wall Check", 90, true, function(state)
    Aimbot.WallCheck = state
end)

CreateButton(mainTab, "Target: Head", 130, function()
    Aimbot.HitPart = "Head"
end)

CreateButton(mainTab, "Target: Torso", 170, function()
    Aimbot.HitPart = "HumanoidRootPart"
end)

print("Fixed AimBot Menu loaded! F4 = Toggle")
