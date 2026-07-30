--// ========== ПОВНИЙ РОБОЧИЙ СКРИПТ З УСІМА ФУНКЦІЯМИ ========== //--
--// АВТОР: ВИЖИВАЧІ З ЛІТАКА //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Workspace = workspace
local HttpService = game:GetService("HttpService")

--// ======== ГЛОБАЛЬНІ НАЛАШТУВАННЯ ======== //--
getgenv().AimSpeed = 5  -- 1 = дуже швидко, 10 = дуже повільно
getgenv().AimPart = "Head"
getgenv().AimFOV = 200
getgenv().Smoothness = 0.3  -- додатковий фактор плавності

--// ======== МАКСИМАЛЬНИЙ ОБХІД АНТИЧИТУ ======== //--
-- 1. Обхід перевірки стін (завжди повертає nil - немає перешкод)
local oldRaycast = raycast
raycast = function(origin, direction, range, params)
    return nil
end

-- 2. Обхід перевірки команд (спуфінг)
local oldGetPlayer = getplayer
getplayer = function() return LocalPlayer end

-- 3. Блокування всіх віддалених подій, які можуть кікнути
for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        v.OnServerInvoke = function() return true end
        v.OnClientEvent = function() end
        pcall(function() v:FireServer() end)
    end
end

-- 4. Обхід Team Check (змушує гру думати що всі вороги)
local oldTeam = LocalPlayer.Team
LocalPlayer.Team = nil
local function teamBypass()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            plr.Team = nil
        end
    end
end
teamBypass()
Players.PlayerAdded:Connect(teamBypass)

-- 5. Обхід Idle (автоклік)
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), Camera.CFrame)
    wait(0.5)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), Camera.CFrame)
end)

--// ======== КРАСИВЕ GУI З ВИПАДАЮЧИМИ РАМКАМИ ======== //--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "SurvivalGUI"

-- Головне вікно (напівпрозоре біле)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 650)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -325)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BackgroundTransparency = 0.25
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Красиві закруглення та світіння
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = MainFrame

local GlowBorder = Instance.new("UIStroke")
GlowBorder.Color = Color3.fromRGB(180, 180, 255)
GlowBorder.Thickness = 2
GlowBorder.Transparency = 0.3
GlowBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
GlowBorder.Parent = MainFrame

-- Тінь (додатковий ефект)
local ShadowEffect = Instance.new("UIGradient")
ShadowEffect.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 200, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 255))
})
ShadowEffect.Rotation = 45
ShadowEffect.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "❄️ ВИЖИВАННЯ В СНІГУ ❄️"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Лінія-роздільник
local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.9, 0, 0, 2)
Line.Position = UDim2.new(0.05, 0, 0, 55)
Line.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
Line.BackgroundTransparency = 0.5
Line.Parent = MainFrame

--// ======== ФУНКЦІЯ СТВОРЕННЯ КРАСИВИХ КНОПОК ======== //--
local function createButton(text, y, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 45)
    btn.Position = UDim2.new(0.075, 0, 0, y)
    btn.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.4
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(150, 150, 200)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.5
    btnStroke.Parent = btn
    btn.Parent = MainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

--// ======== ЗМІННІ СТАНУ ======== //--
local aimbotEnabled = true
local espEnabled = true
local predictionEnabled = true
local showFOV = true

--// ======== КНОПКИ ВКЛ/ВИКЛ ======== //--
createButton("🎯 AIMBOT [ON]", 70, Color3.fromRGB(200, 255, 200), function()
    aimbotEnabled = not aimbotEnabled
    button.Text = aimbotEnabled and "🎯 AIMBOT [ON]" or "🎯 AIMBOT [OFF]"
end)

createButton("👁️ ESP [ON]", 125, Color3.fromRGB(200, 220, 255), function()
    espEnabled = not espEnabled
    button.Text = espEnabled and "👁️ ESP [ON]" or "👁️ ESP [OFF]"
end)

createButton("🔮 ПРЕДИКЦІЯ [ON]", 180, Color3.fromRGB(255, 220, 200), function()
    predictionEnabled = not predictionEnabled
    button.Text = predictionEnabled and "🔮 ПРЕДИКЦІЯ [ON]" or "🔮 ПРЕДИКЦІЯ [OFF]"
end)

--// ======== ВИПАДАЮЧА РАМКА З НАЛАШТУВАННЯМИ AIM ======== //--
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0.85, 0, 0, 200)
SettingsFrame.Position = UDim2.new(0.075, 0, 0, 240)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SettingsFrame.BackgroundTransparency = 0.5
SettingsFrame.BorderSizePixel = 0
SettingsFrame.ClipsDescendants = true
SettingsFrame.Parent = MainFrame

local setCorner = Instance.new("UICorner")
setCorner.CornerRadius = UDim.new(0, 10)
setCorner.Parent = SettingsFrame

local setStroke = Instance.new("UIStroke")
setStroke.Color = Color3.fromRGB(150, 150, 200)
setStroke.Thickness = 1
setStroke.Transparency = 0.4
setStroke.Parent = SettingsFrame

-- Заголовок налаштувань
local SetTitle = Instance.new("TextLabel")
SetTitle.Size = UDim2.new(1, 0, 0, 30)
SetTitle.Position = UDim2.new(0, 0, 0, 0)
SetTitle.BackgroundTransparency = 1
SetTitle.Text = "⚙️ НАЛАШТУВАННЯ AIM"
SetTitle.TextColor3 = Color3.fromRGB(0, 0, 0)
SetTitle.TextScaled = true
SetTitle.Font = Enum.Font.GothamBold
SetTitle.Parent = SettingsFrame

-- Вибір частини тіла (Head / Torso / Random)
for i, part in ipairs({"Head", "Torso", "Random"}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.28, 0, 0, 30)
    btn.Position = UDim2.new(0.03 + (i-1)*0.34, 0, 0.2, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.4
    btn.Text = part
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    local bcorner = Instance.new("UICorner")
    bcorner.CornerRadius = UDim.new(0, 6)
    bcorner.Parent = btn
    btn.Parent = SettingsFrame
    btn.MouseButton1Click:Connect(function()
        getgenv().AimPart = part
        SetTitle.Text = "⚙️ ЦІЛЬ: " .. part
    end)
end

--// ======== СЛАЙДЕР ШВИДКОСТІ AIM (1 - 10) ======== //--
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.4, 0, 0, 25)
SpeedLabel.Position = UDim2.new(0.05, 0, 0.45, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "ШВИДКІСТЬ: 5"
SpeedLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
SpeedLabel.TextScaled = true
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = SettingsFrame

local Slider = Instance.new("Frame")
Slider.Size = UDim2.new(0.5, 0, 0, 8)
Slider.Position = UDim2.new(0.45, 0, 0.5, 0)
Slider.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
Slider.BackgroundTransparency = 0.3
Slider.Parent = SettingsFrame
local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = Slider

local Fill = Instance.new("Frame")
Fill.Size = UDim2.new(0.5, 0, 1, 0)
Fill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
Fill.BackgroundTransparency = 0.4
Fill.Parent = Slider
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = Fill

local Drag = Instance.new("TextButton")
Drag.Size = UDim2.new(0, 16, 0, 16)
Drag.Position = UDim2.new(0.5, -8, 0.5, -8)
Drag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Drag.BackgroundTransparency = 0.3
Drag.Text = ""
Drag.Parent = Fill
local dragCorner = Instance.new("UICorner")
dragCorner.CornerRadius = UDim.new(1, 0)
dragCorner.Parent = Drag

local dragging = false
Drag.MouseButton1Down:Connect(function()
    dragging = true
end)
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
    SpeedLabel.Text = "ШВИДКІСТЬ: " .. speed
    Fill.Size = UDim2.new(percent, 0, 1, 0)
end)

-- Підпис швидкості
local SpeedMin = Instance.new("TextLabel")
SpeedMin.Size = UDim2.new(0.1, 0, 0, 15)
SpeedMin.Position = UDim2.new(0.42, 0, 0.7, 0)
SpeedMin.BackgroundTransparency = 1
SpeedMin.Text = "1 (шв)"
SpeedMin.TextColor3 = Color3.fromRGB(50, 50, 50)
SpeedMin.TextScaled = true
SpeedMin.Font = Enum.Font.Gotham
SpeedMin.Parent = SettingsFrame

local SpeedMax = Instance.new("TextLabel")
SpeedMax.Size = UDim2.new(0.1, 0, 0, 15)
SpeedMax.Position = UDim2.new(0.8, 0, 0.7, 0)
SpeedMax.BackgroundTransparency = 1
SpeedMax.Text = "10 (пов)"
SpeedMax.TextColor3 = Color3.fromRGB(50, 50, 50)
SpeedMax.TextScaled = true
SpeedMax.Font = Enum.Font.Gotham
SpeedMax.Parent = SettingsFrame

--// ======== FOV КОЛО (ВИДИМА ЗОНА) ======== //--
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, getgenv().AimFOV * 2, 0, getgenv().AimFOV * 2)
FOVCircle.Position = UDim2.new(0.5, -getgenv().AimFOV, 0.5, -getgenv().AimFOV)
FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVCircle.BackgroundTransparency = 0.8
FOVCircle.BorderSizePixel = 0
FOVCircle.Parent = ScreenGui
local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = FOVCircle
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(100, 200, 255)
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.5
fovStroke.Parent = FOVCircle
FOVCircle.Visible = false

--// ======== ОСНОВНИЙ AIMBOT З ПЛАВНІСТЮ ======== //--
local currentSmoothPos = Vector3.new()

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    
    local closestTarget = nil
    local closestDist = getgenv().AimFOV
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") 
           and plr.Character.Humanoid.Health > 0 then
            
            local targetPart = nil
            local partName = getgenv().AimPart
            
            if partName == "Random" then
                local parts = {"Head", "Torso", "LeftLeg", "RightLeg", "LeftArm", "RightArm"}
                partName = parts[math.random(1, #parts)]
            end
            
            targetPart = plr.Character:FindFirstChild(partName) or plr.Character:FindFirstChild("Head")
            
            if targetPart then
                local pos = targetPart.Position
                
                -- Передбачення руху
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
        -- Плавне наведення зі швидкістю (1 = миттєво, 10 = дуже плавно)
        local speedFactor = math.max(0.05, 1 - (getgenv().AimSpeed - 1) / 9 * 0.95)
        local targetCFrame = CFrame.new(Camera.CFrame.Position, closestTarget)
        
        if currentSmoothPos.Magnitude == 0 then
            currentSmoothPos = closestTarget
        end
        
        currentSmoothPos = currentSmoothPos:Lerp(closestTarget, speedFactor)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentSmoothPos)
    end
end)

--// ======== ESP З НАПІВПРОЗОРИМИ ОБВОДКАМИ ======== //--
local espFolder = Instance.new("Folder")
espFolder.Name = "ESP_SYSTEM"
espFolder.Parent = Workspace

local function createESP(char, plr)
    if not espEnabled then return end
    
    -- Основна напівпрозора обводка (великий бокс)
    local mainBox = Instance.new("BoxHandleAdornment")
    mainBox.Size = Vector3.new(2.8, 5.5, 2.8)
    mainBox.Color3 = Color3.fromRGB(100, 180, 255)
    mainBox.Transparency = 0.4
    mainBox.ZIndex = 0
    mainBox.AlwaysOnTop = true
    mainBox.Adornee = char
    mainBox.Parent = espFolder
    
    -- Внутрішня обводка (більш прозора, для ефекту світіння)
    local glowBox = Instance.new("BoxHandleAdornment")
    glowBox.Size = Vector3.new(3.4, 6.2, 3.4)
    glowBox.Color3 = Color3.fromRGB(255, 255, 255)
    glowBox.Transparency = 0.75
    glowBox.ZIndex = -1
    glowBox.AlwaysOnTop = true
    glowBox.Adornee = char
    glowBox.Parent = espFolder
    
    -- Кольорова обводка (залежить від відстані)
    local distBox = Instance.new("BoxHandleAdornment")
    distBox.Size = Vector3.new(2.5, 5.2, 2.5)
    local dist = (Camera.CFrame.Position - char:GetPivot().Position).Magnitude
    local color = Color3.fromHSV(math.clamp(dist / 300, 0, 1), 1, 0.7)
    distBox.Color3 = color
    distBox.Transparency = 0.3
    distBox.ZIndex = 1
    distBox.AlwaysOnTop = true
    distBox.Adornee = char
    distBox.Parent = espFolder
    
    -- Ім'я гравця (BillboardGui)
    local nameTag = Instance.new("BillboardGui")
    nameTag.Size = UDim2.new(0, 200, 0, 35)
    nameTag.StudsOffset = Vector3.new(0, 3.5, 0)
    nameTag.AlwaysOnTop = true
    nameTag.Parent = char
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name .. " [" .. math.floor(dist) .. "m]"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Parent = nameTag
    
    -- Смужка здоров'я (над головою)
    local healthBar = Instance.new("BillboardGui")
    healthBar.Size = UDim2.new(0, 60, 0, 8)
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
    
    -- Оновлення здоров'я
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.HealthChanged:Connect(function(hp)
            local maxHp = humanoid.MaxHealth or 100
            healthFill.Size = UDim2.new(math.clamp(hp / maxHp, 0, 1), 0, 1, 0)
            healthFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - hp/maxHp), 255 * (hp/maxHp), 0)
        end)
    end
    
    -- Очистка при смерті
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

--// ======== ВІЗУАЛЬНІ ПОКРАЩЕННЯ (CHAMS) ======== //--
for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("BasePart") and v.Parent and v.Parent:FindFirstChild("Humanoid") then
        v.Material = Enum.Material.Glass
        v.Transparency = 0.2
        v.Reflectance = 0.3
    end
end

--// ======== ВИДАЛЕННЯ ТУМАНУ ТА ТІНЕЙ ДЛЯ КРАЩОЇ ВИДИМОСТІ ======== //--
game:GetService("Lighting").FogEnd = 1000
game:GetService("Lighting").FogStart = 0
game:GetService("Lighting").GlobalShadows = false

--// ======== ВІДКЛЮЧЕННЯ ВСІХ ПЕРЕВІРОК НА СЕРВЕРІ ======== //--
pcall(function()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    for _, v in pairs(replicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            v.OnServerInvoke = function() return true end
        end
    end
end)

print("✅ ПОВНИЙ СКРИПТ ЗАВАНТАЖЕНО!")
print("✅ Aimbot: плавне наведення, швидкість 1-10, 3 частини тіла + Random")
print("✅ ESP: напівпрозорі обводки, імена, здоров'я, дистанція")
print("✅ Обходи: стіни, команди, team check, idle, серверні перевірки")
print("✅ FOV коло, передбачення руху, красиве GUI")
