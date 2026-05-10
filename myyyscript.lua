-- Colin Hub: Toggle Aimbot + Rainbow ESP
-- F4 = меню, V = вкл/викл аім (постійний, без утримання)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==================== НАЛАШТУВАННЯ ====================
local AimbotEnabled = false
local Smoothness = 0.08
local FOV = 200
local TeamCheck = true
local WallCheck = false
local HitPart = "Head"

local ESPEnabled = true
local ESPRainbow = true
local ESPBoxes = true
local ESPTracers = true
local ESPNames = true
local ESPHealth = true

-- ==================== ESP ====================
local ESPCache = {}

-- Кольори веселки
local function GetRainbow(speed)
    local hue = (tick() * (speed or 1)) % 1
    return Color3.fromHSV(hue, 1, 1)
end

local function CreateESP(plr)
    local data = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        HPBg = Drawing.new("Square"),
        HPBar = Drawing.new("Square"),
    }
    
    -- Налаштування об'єктів
    data.Box.Visible = false
    data.Box.Thickness = 2
    data.Box.Transparency = 1
    data.Box.Filled = false
    
    data.Tracer.Visible = false
    data.Tracer.Thickness = 1
    data.Tracer.Transparency = 0.6
    
    data.Name.Visible = false
    data.Name.Size = 13
    data.Name.Center = true
    data.Name.Outline = true
    data.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    data.HPBg.Visible = false
    data.HPBg.Color = Color3.fromRGB(30, 30, 30)
    data.HPBg.Filled = true
    data.HPBg.Transparency = 1
    
    data.HPBar.Visible = false
    data.HPBar.Filled = true
    data.HPBar.Transparency = 1
    
    ESPCache[plr] = data
    
    -- Цикл оновлення
    local connection
    connection = RunService.RenderStepped:Connect(function()
        -- Видалення якщо гравець вийшов
        if not plr.Parent then
            for _, v in pairs(data) do pcall(function() v:Remove() end) end
            ESPCache[plr] = nil
            connection:Disconnect()
            return
        end
        
        -- Перевірки
        local visible = ESPEnabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid")
        if not visible or plr.Character.Humanoid.Health <= 0 then
            for _, v in pairs(data) do v.Visible = false end
            return
        end
        
        if TeamCheck and plr.Team == LocalPlayer.Team then
            for _, v in pairs(data) do v.Visible = false end
            return
        end
        
        local root = plr.Character.HumanoidRootPart
        local hum = plr.Character.Humanoid
        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        
        if not onScreen then
            for _, v in pairs(data) do v.Visible = false end
            return
        end
        
        local topPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
        local botPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, -3.5, 0))
        local boxHeight = math.abs(topPos.Y - botPos.Y)
        local boxWidth = boxHeight / 1.8
        
        -- Бокс
        if ESPBoxes then
            data.Box.Visible = true
            data.Box.Size = Vector2.new(boxWidth, boxHeight)
            data.Box.Position = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2)
            data.Box.Color = ESPRainbow and GetRainbow(0.8) or Color3.fromRGB(255, 50, 50)
        else
            data.Box.Visible = false
        end
        
        -- Трейсер
        if ESPTracers then
            data.Tracer.Visible = true
            data.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            data.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + boxHeight/2)
            data.Tracer.Color = ESPRainbow and GetRainbow(0.5) or Color3.fromRGB(255, 255, 255)
        else
            data.Tracer.Visible = false
        end
        
        -- Ім'я
        if ESPNames then
            local label = plr.Name
            if ESPHealth then label = label .. " [" .. math.floor(hum.Health) .. " HP]" end
            data.Name.Visible = true
            data.Name.Text = label
            data.Name.Position = Vector2.new(rootPos.X, rootPos.Y - boxHeight/2 - 15)
            data.Name.Color = ESPRainbow and GetRainbow(1.2) or Color3.fromRGB(255, 255, 255)
        else
            data.Name.Visible = false
        end
        
        -- HP Бар
        if ESPHealth then
            local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            data.HPBg.Visible = true
            data.HPBg.Size = Vector2.new(boxWidth, 3)
            data.HPBg.Position = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2 - 5)
            
            data.HPBar.Visible = true
            data.HPBar.Size = Vector2.new(boxWidth * hpRatio, 3)
            data.HPBar.Position = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2 - 5)
            data.HPBar.Color = hpRatio > 0.6 and Color3.fromRGB(0, 255, 0) or (hpRatio > 0.3 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0))
        else
            data.HPBg.Visible = false
            data.HPBar.Visible = false
        end
    end)
end

-- Ініціалізація ESP
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end)

-- ==================== АІМБОТ ====================
local function GetClosestTarget()
    local bestTarget = nil
    local bestDist = FOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        local part = char:FindFirstChild(HitPart)
        if not (hum and part) or hum.Health <= 0 then continue end
        if TeamCheck and plr.Team == LocalPlayer.Team then continue end
        
        -- Wall Check
        if WallCheck then
            local origin = Camera.CFrame.Position
            local dir = part.Position - origin
            local ray = RaycastParams.new()
            ray.FilterType = Enum.RaycastFilterType.Blacklist
            ray.FilterDescendantsInstances = {LocalPlayer.Character}
            local hit = workspace:Raycast(origin, dir, ray)
            if hit and not hit.Instance:IsDescendantOf(char) then continue end
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if onScreen then
            local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
            if dist < bestDist then
                bestDist = dist
                bestTarget = part
            end
        end
    end
    return bestTarget
end

-- Основний цикл аіму
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = GetClosestTarget()
        if target then
            local dir = (target.Position - Camera.CFrame.Position).Unit
            local goal = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + dir)
            Camera.CFrame = Camera.CFrame:Lerp(goal, Smoothness)
        end
    end
end)

-- ==================== КНОПКА ТОГЛУ V ====================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.V then
        AimbotEnabled = not AimbotEnabled
    end
end)

-- ==================== GUI МЕНЮ ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ColinHub"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = game.CoreGui end)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 330, 0, 250)
Main.Position = UDim2.new(0.5, -165, 0.5, -125)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

-- Топ бар
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 27)
Top.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
Top.BorderSizePixel = 0
Top.Parent = Main
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 6)

local TopLabel = Instance.new("TextLabel")
TopLabel.Text = "Colin Hub"
TopLabel.Size = UDim2.new(1, -30, 1, 0)
TopLabel.Position = UDim2.new(0, 8, 0, 0)
TopLabel.BackgroundTransparency = 1
TopLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TopLabel.Font = Enum.Font.GothamBold
TopLabel.TextSize = 13
TopLabel.TextXAlignment = Enum.TextXAlignment.Left
TopLabel.Parent = Top

local Close = Instance.new("TextButton")
Close.Text = "X"
Close.Size = UDim2.new(0, 22, 0, 22)
Close.Position = UDim2.new(1, -25, 0, 2)
Close.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 12
Close.BorderSizePixel = 0
Close.Parent = Top

-- Вкладки
local TabBtns = Instance.new("Frame")
TabBtns.Size = UDim2.new(0, 75, 1, -27)
TabBtns.Position = UDim2.new(0, 0, 0, 27)
TabBtns.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabBtns.BorderSizePixel = 0
TabBtns.Parent = Main

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -75, 1, -27)
Content.Position = UDim2.new(0, 75, 0, 27)
Content.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.CanvasSize = UDim2.new(0, 0, 0, 350)
Content.Parent = Main

-- Функція тоглу
local yOffset = 5
local function AddToggle(text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 28)
    Frame.Position = UDim2.new(0, 5, 0, yOffset)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BorderSizePixel = 0
    Frame.Parent = Content
    yOffset = yOffset + 32
    
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 6, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local state = default
    local Btn = Instance.new("TextButton")
    Btn.Text = state and "ON" or "OFF"
    Btn.Size = UDim2.new(0, 38, 0, 18)
    Btn.Position = UDim2.new(1, -42, 0, 5)
    Btn.BackgroundColor3 = state and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
    Btn.BorderSizePixel = 0
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Btn.Parent = Frame
    
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.Text = state and "ON" or "OFF"
        Btn.BackgroundColor3 = state and Color3.fromRGB(0, 160, 0) or Color3.fromRGB(160, 0, 0)
        callback(state)
    end)
end

local function AddButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Text = text
    Btn.Size = UDim2.new(1, -10, 0, 26)
    Btn.Position = UDim2.new(0, 5, 0, yOffset)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.BorderSizePixel = 0
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 11
    Btn.Parent = Content
    Btn.MouseButton1Click:Connect(callback)
    yOffset = yOffset + 29
end

-- ==================== НАПОВНЕННЯ МЕНЮ ====================
-- Аім
AddToggle("Aimbot (V - тогл)", false, function(s) AimbotEnabled = s end)
AddToggle("Team Check", true, function(s) TeamCheck = s end)
AddToggle("Wall Check", false, function(s) WallCheck = s end)
AddButton("Target: Head", function() HitPart = "Head" end)
AddButton("Target: Torso", function() HitPart = "HumanoidRootPart" end)

yOffset = yOffset + 5
local Sep1 = Instance.new("TextLabel")
Sep1.Text = "--- ESP ---"
Sep1.Size = UDim2.new(1, -10, 0, 16)
Sep1.Position = UDim2.new(0, 5, 0, yOffset)
Sep1.BackgroundTransparency = 1
Sep1.TextColor3 = Color3.fromRGB(180, 180, 180)
Sep1.Font = Enum.Font.Gotham
Sep1.TextSize = 10
Sep1.TextXAlignment = Enum.TextXAlignment.Center
Sep1.Parent = Content
yOffset = yOffset + 20

AddToggle("ESP", true, function(s) ESPEnabled = s end)
AddToggle("Rainbow", true, function(s) ESPRainbow = s end)
AddToggle("Boxes", true, function(s) ESPBoxes = s end)
AddToggle("Tracers", true, function(s) ESPTracers = s end)
AddToggle("Names", true, function(s) ESPNames = s end)
AddToggle("HP Bar", true, function(s) ESPHealth = s end)

-- Закриття меню
Close.MouseButton1Click:Connect(function() Main.Visible = false end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        Main.Visible = not Main.Visible
    end
end)

print("Colin Hub Loaded! F4 = Menu | V = Toggle Aimbot")
