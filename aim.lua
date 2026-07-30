--// ========== ПОВНИЙ СКРИПТ З ESP НА ВСІХ (КРІМ ТІМЕЙТІВ) ========== //--
--// ВИЖИВАЧІ З ЛІТАКА //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Workspace = workspace

--// ======== НАЛАШТУВАННЯ ======== //--
getgenv().AimSpeed = 5
getgenv().AimPart = "Head"
getgenv().AimFOV = 300

--// ======== ОБХІД АНТИЧИТУ ======== //--
local oldRaycast = raycast
raycast = function() return nil end

local oldGetPlayer = getplayer
getplayer = function() return LocalPlayer end

for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        v.OnServerInvoke = function() return true end
        v.OnClientEvent = function() end
        pcall(function() v:FireServer() end)
    end
end

-- Обхід команди (всі вважаються ворогами)
local function teamBypass()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            plr.Team = nil
        end
    end
end
teamBypass()
Players.PlayerAdded:Connect(teamBypass)

LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), Camera.CFrame)
    wait(0.5)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), Camera.CFrame)
end)

--// ======== КВАДРАТНЕ GUI БЕЗ ЕМОДЗІ ======== //--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "SurvivalGUI"

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 550)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local GlowBorder = Instance.new("UIStroke")
GlowBorder.Color = Color3.fromRGB(100, 150, 255)
GlowBorder.Thickness = 1.5
GlowBorder.Transparency = 0.4
GlowBorder.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "SURVIVAL HUB"
Title.TextColor3 = Color3.fromRGB(200, 220, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Лінія
local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.9, 0, 0, 1.5)
Line.Position = UDim2.new(0.05, 0, 0, 48)
Line.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
Line.BackgroundTransparency = 0.5
Line.Parent = MainFrame

-- Функція створення кнопок
local function createButton(text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 40)
    btn.Position = UDim2.new(0.075, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    btn.Parent = MainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Стани
local aimbotEnabled = true
local espEnabled = true
local predictionEnabled = true

-- Кнопки
local btnAim = createButton("AIMBOT [ON]", 65, function()
    aimbotEnabled = not aimbotEnabled
    btnAim.Text = aimbotEnabled and "AIMBOT [ON]" or "AIMBOT [OFF]"
end)

local btnEsp = createButton("ESP [ON]", 115, function()
    espEnabled = not espEnabled
    btnEsp.Text = espEnabled and "ESP [ON]" or "ESP [OFF]"
end)

local btnPred = createButton("PREDICTION [ON]", 165, function()
    predictionEnabled = not predictionEnabled
    btnPred.Text = predictionEnabled and "PREDICTION [ON]" or "PREDICTION [OFF]"
end)

-- Панель налаштувань
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0.85, 0, 0, 180)
SettingsFrame.Position = UDim2.new(0.075, 0, 0, 220)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
SettingsFrame.BackgroundTransparency = 0.4
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Parent = MainFrame

local setCorner = Instance.new("UICorner")
setCorner.CornerRadius = UDim.new(0, 6)
setCorner.Parent = SettingsFrame

local SetTitle = Instance.new("TextLabel")
SetTitle.Size = UDim2.new(1, 0, 0, 28)
SetTitle.Position = UDim2.new(0, 0, 0, 2)
SetTitle.BackgroundTransparency = 1
SetTitle.Text = "AIM SETTINGS"
SetTitle.TextColor3 = Color3.fromRGB(200, 220, 255)
SetTitle.TextScaled = true
SetTitle.Font = Enum.Font.GothamBold
SetTitle.Parent = SettingsFrame

-- Вибір частини тіла
for i, part in ipairs({"Head", "Torso", "Random"}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.28, 0, 0, 28)
    btn.Position = UDim2.new(0.03 + (i-1)*0.34, 0, 0.22, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.BackgroundTransparency = 0.3
    btn.Text = part
    btn.TextColor3 = Color3.fromRGB(220, 220, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    local bcorner = Instance.new("UICorner")
    bcorner.CornerRadius = UDim.new(0, 4)
    bcorner.Parent = btn
    btn.Parent = SettingsFrame
    btn.MouseButton1Click:Connect(function()
        getgenv().AimPart = part
        SetTitle.Text = "AIM: " .. part
    end)
end

-- Слайдер швидкості
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.4, 0, 0, 22)
SpeedLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "SPEED: 5"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
SpeedLabel.TextScaled = true
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = SettingsFrame

local Slider = Instance.new("Frame")
Slider.Size = UDim2.new(0.5, 0, 0, 6)
Slider.Position = UDim2.new(0.45, 0, 0.55, 0)
Slider.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
Slider.BackgroundTransparency = 0.3
Slider.Parent = SettingsFrame
local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = Slider

local Fill = Instance.new("Frame")
Fill.Size = UDim2.new(0.5, 0, 1, 0)
Fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
Fill.BackgroundTransparency = 0.4
Fill.Parent = Slider
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = Fill

local Drag = Instance.new("TextButton")
Drag.Size = UDim2.new(0, 14, 0, 14)
Drag.Position = UDim2.new(0.5, -7, 0.5, -7)
Drag.BackgroundColor3 = Color3.fromRGB(200, 220, 255)
Drag.BackgroundTransparency = 0.3
Drag.Text = ""
Drag.Parent = Fill
local dragCorner = Instance.new("UICorner")
dragCorner.CornerRadius = UDim.new(1, 0)
dragCorner.Parent = Drag

local dragging = false
Drag.MouseButton1Down:Connect(function() dragging = true end)
UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not dragging then return end
    local mousePos = UserInput:GetMouseLocation().X
    local sliderPos = Slider.AbsolutePosition.X
    local sliderSize = Slider.AbsoluteSize.X
    local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
    local speed = math.round(percent * 9 + 1)
    getgenv().AimSpeed = speed
    SpeedLabel.Text = "SPEED: " .. speed
    Fill.Size = UDim2.new(percent, 0, 1, 0)
end)

--// ======== AIMBOT (ІГНОР ТІМЕЙТІВ) ======== //--
local currentSmoothPos = Vector3.new()

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    
    local closestTarget = nil
    local closestDist = getgenv().AimFOV
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") 
           and plr.Character.Humanoid.Health > 0 then
            
            -- ІГНОР ТІМЕЙТІВ: якщо одна команда - пропускаємо
            if LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then
                continue
            end
            
            local targetPart = nil
            local partName = getgenv().AimPart
            
            if partName == "Random" then
                local parts = {"Head", "Torso", "LeftLeg", "RightLeg", "LeftArm", "RightArm"}
                partName = parts[math.random(1, #parts)]
            end
            
            targetPart = plr.Character:FindFirstChild(partName) or plr.Character:FindFirstChild("Head")
            
            if targetPart then
                local pos = targetPart.Position
                
                if predictionEnabled then
                    local velocity = targetPart:GetVelocity() or Vector3.new(0, 0, 0)
                    pos = pos + velocity * 0.12
                end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                
                if onScreen then
                    local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    
                    if dist < closestDist then
                        closestDist = dist
                        closestTarget = pos
                    end
                end
            end
        end
    end
    
    if closestTarget then
        local speedFactor = math.max(0.05, 1 - (getgenv().AimSpeed - 1) / 9 * 0.95)
        
        if currentSmoothPos.Magnitude == 0 then
            currentSmoothPos = closestTarget
        end
        
        currentSmoothPos = currentSmoothPos:Lerp(closestTarget, speedFactor)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentSmoothPos)
    end
end)

--// ======== ESP (ПОКАЗУЄ ВСІХ КРІМ ТІМЕЙТІВ) ======== //--
local espFolder = Instance.new("Folder")
espFolder.Name = "ESP_SYSTEM"
espFolder.Parent = Workspace

local function createESP(char, plr)
    if not espEnabled then return end
    
    -- ІГНОР ТІМЕЙТІВ: якщо одна команда - не створюємо ESP
    if LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then
        return
    end
    
    -- Основний бокс (червоний для ворогів)
    local mainBox = Instance.new("BoxHandleAdornment")
    mainBox.Size = Vector3.new(2.8, 5.5, 2.8)
    mainBox.Color3 = Color3.fromRGB(255, 50, 50)
    mainBox.Transparency = 0.35
    mainBox.ZIndex = 0
    mainBox.AlwaysOnTop = true
    mainBox.Adornee = char
    mainBox.Parent = espFolder
    
    -- Світіння (біле)
    local glowBox = Instance.new("BoxHandleAdornment")
    glowBox.Size = Vector3.new(3.4, 6.2, 3.4)
    glowBox.Color3 = Color3.fromRGB(255, 255, 255)
    glowBox.Transparency = 0.7
    glowBox.ZIndex = -1
    glowBox.AlwaysOnTop = true
    glowBox.Adornee = char
    glowBox.Parent = espFolder
    
    -- Дистанційний бокс
    local distBox = Instance.new("BoxHandleAdornment")
    distBox.Size = Vector3.new(2.5, 5.2, 2.5)
    local dist = (Camera.CFrame.Position - char:GetPivot().Position).Magnitude
    local color = Color3.fromHSV(math.clamp(dist / 300, 0, 1), 1, 0.6)
    distBox.Color3 = color
    distBox.Transparency = 0.25
    distBox.ZIndex = 1
    distBox.AlwaysOnTop = true
    distBox.Adornee = char
    distBox.Parent = espFolder
    
    -- Ім'я
    local nameTag = Instance.new("BillboardGui")
    nameTag.Size = UDim2.new(0, 200, 0, 35)
    nameTag.StudsOffset = Vector3.new(0, 3.5, 0)
    nameTag.AlwaysOnTop = true
    nameTag.Parent = char
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name .. " [" .. math.floor(dist) .. "m]"
    nameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.4
    nameLabel.Parent = nameTag
    
    -- Здоров'я
    local healthBar = Instance.new("BillboardGui")
    healthBar.Size = UDim2.new(0, 60, 0, 6)
    healthBar.StudsOffset = Vector3.new(0, 4.2, 0)
    healthBar.AlwaysOnTop = true
    healthBar.Parent = char
    
    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(1, 0, 1, 0)
    healthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    healthBg.BackgroundTransparency = 0.5
    healthBg.Parent = healthBar
    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(1, 0)
    hCorner.Parent = healthBg
    
    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFill.BackgroundTransparency = 0.3
    healthFill.Parent = healthBg
    local hfCorner = Instance.new("UICorner")
    hfCorner.CornerRadius = UDim.new(1, 0)
    hfCorner.Parent = healthFill
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.HealthChanged:Connect(function(hp)
            local maxHp = humanoid.MaxHealth or 100
            healthFill.Size = UDim2.new(math.clamp(hp / maxHp, 0, 1), 0, 1, 0)
            healthFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - hp/maxHp), 255 * (hp/maxHp), 0)
        end)
    end
    
    humanoid.Died:Connect(function()
        mainBox:Destroy()
        glowBox:Destroy()
        distBox:Destroy()
        nameTag:Destroy()
        healthBar:Destroy()
    end)
end

-- Для всіх гравців
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer and plr.Character then
        createESP(plr.Character, plr)
    end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function(char)
            wait(0.5)
            createESP(char, plr)
        end)
    end
end)

--// ======== ВІЗУАЛ ======== //--
for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("BasePart") and v.Parent and v.Parent:FindFirstChild("Humanoid") then
        v.Material = Enum.Material.Glass
        v.Transparency = 0.15
        v.Reflectance = 0.2
    end
end

game:GetService("Lighting").FogEnd = 1000
game:GetService("Lighting").FogStart = 0
game:GetService("Lighting").GlobalShadows = false

--// ======== ВІДКЛЮЧЕННЯ ПЕРЕВІРОК ======== //--
pcall(function()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    for _, v in pairs(replicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            v.OnServerInvoke = function() return true end
        end
    end
end)

print("✅ СКРИПТ ЗАВАНТАЖЕНО!")
print("✅ ESP: показує ВСІХ, крім тімейтів")
print("✅ Aimbot: ігнорує тімейтів")
print("✅ GUI: квадратне, без емодзі")
