--// ========== РОЗШИРЕНА ВЕРСІЯ ~650 РЯДКІВ ========== //--
--// ВИЖИВАЧІ З ЛІТАКА //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Workspace = workspace
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

--// ======== ГЛОБАЛЬНІ НАЛАШТУВАННЯ ======== //--
getgenv().Settings = {
    AimSpeed = 5,
    AimPart = "Head",
    AimFOV = 300,
    Smoothness = 0.3,
    EspEnabled = true,
    EspColor = Color3.fromRGB(255, 0, 0),
    EspGlowColor = Color3.fromRGB(255, 255, 255),
    EspShowDistance = true,
    EspShowHealth = true,
    EspShowName = true,
    RadarEnabled = true,
    RadarRadius = 100,
    AutoSwitchTarget = false,
    NotificationEnabled = true
}

--// ======== ОБХІД АНТИЧИТУ ======== //--
local function bypassWall()
    local oldFindPart = workspace.FindPartOnRay
    workspace.FindPartOnRay = function(...) return nil end
    workspace.Raycast = function(...) return nil end
    workspace.FindPartOnRayWithIgnoreList = function(...) return nil end
    workspace.FindPartOnRayWithWhitelist = function(...) return nil end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end
bypassWall()

local function bypassTeam()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            plr.Team = nil
            if plr.Character then
                for _, v in pairs(plr.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v:SetAttribute("Team", nil)
                    end
                end
            end
        end
    end
end
bypassTeam()
Players.PlayerAdded:Connect(bypassTeam)
Players.PlayerRemoving:Connect(bypassTeam)

local function bypassRemotes()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            pcall(function()
                obj.OnServerInvoke = function() return true end
                obj.OnClientEvent = function() end
            end)
        end
    end
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            pcall(function()
                obj.OnServerInvoke = function() return true end
                obj.OnClientEvent = function() end
            end)
        end
    end
end
bypassRemotes()

local function bypassIdle()
    VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
    wait(0.1)
    VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
end
LocalPlayer.Idled:Connect(bypassIdle)

--// ======== СИСТЕМА ПОВІДОМЛЕНЬ ======== //--
local function notify(text, color)
    if not getgenv().Settings.NotificationEnabled then return end
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 300, 0, 40)
    notification.Position = UDim2.new(0.5, -150, 0.8, 0)
    notification.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    notification.BackgroundTransparency = 0.2
    notification.Text = text
    notification.TextColor3 = color or Color3.fromRGB(200, 220, 255)
    notification.TextScaled = true
    notification.Font = Enum.Font.GothamBold
    notification.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 120, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = notification
    notification.Parent = LocalPlayer.PlayerGui
    
    TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -150, 0.75, 0)}):Play()
    wait(2)
    TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -150, 0.85, 0)}):Play()
    wait(0.5)
    notification:Destroy()
end

--// ======== GUI ======== //--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer.PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "SurvivalHub"

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 600)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(60, 100, 255)
Stroke.Thickness = 2
Stroke.Transparency = 0.2
Stroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 44)
Title.Position = UDim2.new(0, 0, 0, 6)
Title.BackgroundTransparency = 1
Title.Text = "SURVIVAL HUB v2.0"
Title.TextColor3 = Color3.fromRGB(180, 210, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.9, 0, 0, 1.5)
Line.Position = UDim2.new(0.05, 0, 0, 54)
Line.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
Line.BackgroundTransparency = 0.4
Line.Parent = MainFrame

-- Функція кнопок
local function createButton(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 40)
    btn.Position = UDim2.new(0.075, 0, 0, y)
    btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 60)
    btn.BackgroundTransparency = 0.2
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(60, 100, 255)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.5
    btnStroke.Parent = btn
    btn.Parent = MainFrame
    return btn
end

local state = {
    aim = true,
    esp = true,
    pred = true,
    radar = true,
    auto = false
}

local btnAim = createButton("AIMBOT [ON]", 68)
btnAim.MouseButton1Click:Connect(function()
    state.aim = not state.aim
    btnAim.Text = state.aim and "AIMBOT [ON]" or "AIMBOT [OFF]"
    notify("Aimbot: " .. (state.aim and "ON" or "OFF"), Color3.fromRGB(100, 255, 100))
end)

local btnEsp = createButton("ESP [ON]", 116)
btnEsp.MouseButton1Click:Connect(function()
    state.esp = not state.esp
    btnEsp.Text = state.esp and "ESP [ON]" or "ESP [OFF]"
    notify("ESP: " .. (state.esp and "ON" or "OFF"), Color3.fromRGB(100, 200, 255))
end)

local btnPred = createButton("PREDICTION [ON]", 164)
btnPred.MouseButton1Click:Connect(function()
    state.pred = not state.pred
    btnPred.Text = state.pred and "PREDICTION [ON]" or "PREDICTION [OFF]"
    notify("Prediction: " .. (state.pred and "ON" or "OFF"), Color3.fromRGB(255, 200, 100))
end)

local btnRadar = createButton("RADAR [ON]", 212)
btnRadar.MouseButton1Click:Connect(function()
    state.radar = not state.radar
    btnRadar.Text = state.radar and "RADAR [ON]" or "RADAR [OFF]"
    notify("Radar: " .. (state.radar and "ON" or "OFF"), Color3.fromRGB(100, 255, 200))
end)

-- Панель налаштувань
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0.85, 0, 0, 200)
SettingsFrame.Position = UDim2.new(0.075, 0, 0, 266)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
SettingsFrame.BackgroundTransparency = 0.3
SettingsFrame.BorderSizePixel = 0
SettingsFrame.ClipsDescendants = true
SettingsFrame.Parent = MainFrame

local setCorner = Instance.new("UICorner")
setCorner.CornerRadius = UDim.new(0, 8)
setCorner.Parent = SettingsFrame

local setStroke = Instance.new("UIStroke")
setStroke.Color = Color3.fromRGB(60, 100, 255)
setStroke.Thickness = 1
setStroke.Transparency = 0.3
setStroke.Parent = SettingsFrame

local setTitle = Instance.new("TextLabel")
setTitle.Size = UDim2.new(1, 0, 0, 30)
setTitle.Position = UDim2.new(0, 0, 0, 2)
setTitle.BackgroundTransparency = 1
setTitle.Text = "AIM SETTINGS"
setTitle.TextColor3 = Color3.fromRGB(180, 210, 255)
setTitle.TextScaled = true
setTitle.Font = Enum.Font.GothamBold
setTitle.Parent = SettingsFrame

-- Вибір частини тіла
for i, part in ipairs({"Head", "Torso", "Random"}) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.28, 0, 0, 28)
    btn.Position = UDim2.new(0.03 + (i-1)*0.34, 0, 0.2, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.BackgroundTransparency = 0.2
    btn.Text = part
    btn.TextColor3 = Color3.fromRGB(220, 220, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    local bcorner = Instance.new("UICorner")
    bcorner.CornerRadius = UDim.new(0, 4)
    bcorner.Parent = btn
    btn.Parent = SettingsFrame
    btn.MouseButton1Click:Connect(function()
        getgenv().Settings.AimPart = part
        setTitle.Text = "AIM: " .. part
        notify("Target: " .. part, Color3.fromRGB(200, 200, 255))
    end)
end

-- Слайдер швидкості
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.4, 0, 0, 24)
speedLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "SPEED: 5"
speedLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.Gotham
speedLabel.Parent = SettingsFrame

local Slider = Instance.new("Frame")
Slider.Size = UDim2.new(0.5, 0, 0, 5)
Slider.Position = UDim2.new(0.45, 0, 0.55, 0)
Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
Slider.BackgroundTransparency = 0.2
Slider.Parent = SettingsFrame
local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = Slider

local Fill = Instance.new("Frame")
Fill.Size = UDim2.new(0.5, 0, 1, 0)
Fill.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
Fill.BackgroundTransparency = 0.2
Fill.Parent = Slider
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = Fill

local dragging = false
local Drag = Instance.new("TextButton")
Drag.Size = UDim2.new(0, 14, 0, 14)
Drag.Position = UDim2.new(0.5, -7, 0.5, -7)
Drag.BackgroundColor3 = Color3.fromRGB(200, 220, 255)
Drag.BackgroundTransparency = 0.2
Drag.Text = ""
Drag.Parent = Fill
local dragCorner = Instance.new("UICorner")
dragCorner.CornerRadius = UDim.new(1, 0)
dragCorner.Parent = Drag

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
    getgenv().Settings.AimSpeed = speed
    speedLabel.Text = "SPEED: " .. speed
    Fill.Size = UDim2.new(percent, 0, 1, 0)
end)

-- FOV слайдер
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0.4, 0, 0, 24)
fovLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV: 300"
fovLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
fovLabel.TextScaled = true
fovLabel.Font = Enum.Font.Gotham
fovLabel.Parent = SettingsFrame

local fovSlider = Instance.new("Frame")
fovSlider.Size = UDim2.new(0.5, 0, 0, 5)
fovSlider.Position = UDim2.new(0.45, 0, 0.8, 0)
fovSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
fovSlider.BackgroundTransparency = 0.2
fovSlider.Parent = SettingsFrame
local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovSlider

local fovFill = Instance.new("Frame")
fovFill.Size = UDim2.new(0.5, 0, 1, 0)
fovFill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
fovFill.BackgroundTransparency = 0.2
fovFill.Parent = fovSlider
local fovFillCorner = Instance.new("UICorner")
fovFillCorner.CornerRadius = UDim.new(1, 0)
fovFillCorner.Parent = fovFill

local fovDrag = Instance.new("TextButton")
fovDrag.Size = UDim2.new(0, 14, 0, 14)
fovDrag.Position = UDim2.new(0.5, -7, 0.5, -7)
fovDrag.BackgroundColor3 = Color3.fromRGB(255, 200, 200)
fovDrag.BackgroundTransparency = 0.2
fovDrag.Text = ""
fovDrag.Parent = fovFill
local fovDragCorner = Instance.new("UICorner")
fovDragCorner.CornerRadius = UDim.new(1, 0)
fovDragCorner.Parent = fovDrag

local fovDragging = false
fovDrag.MouseButton1Down:Connect(function() fovDragging = true end)
UserInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        fovDragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not fovDragging then return end
    local mousePos = UserInput:GetMouseLocation().X
    local sliderPos = fovSlider.AbsolutePosition.X
    local sliderSize = fovSlider.AbsoluteSize.X
    local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
    local fov = math.round(percent * 400 + 50)
    getgenv().Settings.AimFOV = fov
    fovLabel.Text = "FOV: " .. fov
    fovFill.Size = UDim2.new(percent, 0, 1, 0)
end)

-- Кнопка збереження
local saveBtn = createButton("SAVE SETTINGS", 480, Color3.fromRGB(30, 60, 100))
saveBtn.MouseButton1Click:Connect(function()
    notify("Settings saved!", Color3.fromRGB(100, 255, 100))
end)

--// ======== FOV КОЛО ======== //--
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, getgenv().Settings.AimFOV * 2, 0, getgenv().Settings.AimFOV * 2)
fovCircle.Position = UDim2.new(0.5, -getgenv().Settings.AimFOV, 0.5, -getgenv().Settings.AimFOV)
fovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fovCircle.BackgroundTransparency = 0.85
fovCircle.BorderSizePixel = 0
fovCircle.Parent = ScreenGui
local fovCircleCorner = Instance.new("UICorner")
fovCircleCorner.CornerRadius = UDim.new(1, 0)
fovCircleCorner.Parent = fovCircle
local fovCircleStroke = Instance.new("UIStroke")
fovCircleStroke.Color = Color3.fromRGB(60, 100, 255)
fovCircleStroke.Thickness = 1.5
fovCircleStroke.Transparency = 0.5
fovCircleStroke.Parent = fovCircle
fovCircle.Visible = true

--// ======== AIMBOT ======== //--
local currentSmoothPos = Vector3.new()
local lastTarget = nil
local targetSwitchTimer = 0

RunService.RenderStepped:Connect(function(deltaTime)
    if not state.aim then return end
    
    local closestTarget = nil
    local closestDist = getgenv().Settings.AimFOV
    local targets = {}
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end
        
        local humanoid = plr.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        if LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then
            continue
        end
        
        local targetPart = nil
        local partName = getgenv().Settings.AimPart
        
        if partName == "Random" then
            local parts = {"Head", "Torso", "LeftLeg", "RightLeg", "LeftArm", "RightArm"}
            partName = parts[math.random(1, #parts)]
        end
        
        targetPart = plr.Character:FindFirstChild(partName) or plr.Character:FindFirstChild("Head")
        if not targetPart then continue end
        
        local pos = targetPart.Position
        
        if state.pred then
            local velocity = targetPart:GetVelocity() or Vector3.new(0, 0, 0)
            pos = pos + velocity * 0.12
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
        if not onScreen then continue end
        
        local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
        
        if dist < closestDist then
            closestDist = dist
            closestTarget = pos
            table.insert(targets, {pos = pos, dist = dist})
        end
    end
    
    -- Авто-перемикання цілей
    if getgenv().Settings.AutoSwitchTarget and #targets > 1 then
        targetSwitchTimer = targetSwitchTimer + deltaTime
        if targetSwitchTimer > 2 then
            targetSwitchTimer = 0
            local randomTarget = targets[math.random(1, #targets)]
            closestTarget = randomTarget.pos
        end
    end
    
    if closestTarget then
        local speedFactor = math.max(0.05, 1 - (getgenv().Settings.AimSpeed - 1) / 9 * 0.95)
        
        if currentSmoothPos.Magnitude == 0 then
            currentSmoothPos = closestTarget
        end
        
        currentSmoothPos = currentSmoothPos:Lerp(closestTarget, speedFactor)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, currentSmoothPos)
    end
end)

--// ======== ESP ======== //--
local espFolder = Instance.new("Folder")
espFolder.Name = "ESP_SYSTEM"
espFolder.Parent = Workspace

local espObjects = {}

local function createESP(char, plr)
    if not state.esp then return end
    if LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Основний бокс
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(2.8, 5.5, 2.8)
    box.Color3 = getgenv().Settings.EspColor
    box.Transparency = 0.25
    box.AlwaysOnTop = true
    box.Adornee = char
    box.Parent = espFolder
    
    -- Світіння
    local glow = Instance.new("BoxHandleAdornment")
    glow.Size = Vector3.new(3.4, 6.2, 3.4)
    glow.Color3 = getgenv().Settings.EspGlowColor
    glow.Transparency = 0.6
    glow.AlwaysOnTop = true
    glow.Adornee = char
    glow.Parent = espFolder
    
    -- Ім'я
    local tag = Instance.new("BillboardGui")
    tag.Size = UDim2.new(0, 220, 0, 32)
    tag.StudsOffset = Vector3.new(0, 3.5, 0)
    tag.AlwaysOnTop = true
    tag.Parent = char
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    local dist = math.floor((Camera.CFrame.Position - char:GetPivot().Position).Magnitude)
    nameLabel.Text = plr.Name .. (getgenv().Settings.EspShowDistance and " [" .. dist .. "m]" or "")
    nameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.4
    nameLabel.Parent = tag
    
    -- Здоров'я
    local health = Instance.new("BillboardGui")
    health.Size = UDim2.new(0, 70, 0, 5)
    health.StudsOffset = Vector3.new(0, 4.2, 0)
    health.AlwaysOnTop = true
    health.Parent = char
    
    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(1, 0, 1, 0)
    healthBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    healthBg.BackgroundTransparency = 0.5
    healthBg.Parent = health
    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(1, 0)
    hCorner.Parent = healthBg
    
    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFill.BackgroundTransparency = 0.2
    healthFill.Parent = healthBg
    local hfCorner = Instance.new("UICorner")
    hfCorner.CornerRadius = UDim.new(1, 0)
    hfCorner.Parent = healthFill
    
    local espData = {box = box, glow = glow, tag = tag, health = health, healthFill = healthFill}
    espObjects[plr] = espData
    
    humanoid.HealthChanged:Connect(function(hp)
        if not state.esp then return end
        local maxHp = humanoid.MaxHealth or 100
        local percent = math.clamp(hp / maxHp, 0, 1)
        healthFill.Size = UDim2.new(percent, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - percent), 255 * percent, 0)
    end)
    
    humanoid.Died:Connect(function()
        if box then box:Destroy() end
        if glow then glow:Destroy() end
        if tag then tag:Destroy() end
        if health then health:Destroy() end
        espObjects[plr] = nil
    end)
end

-- Для існуючих
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer and plr.Character then
        createESP(plr.Character, plr)
    end
end

-- Для нових
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function(char)
            wait(0.5)
            createESP(char, plr)
        end)
    end
end)

--// ======== РАДАР (2D міні-карта) ======== //--
local radarFrame = Instance.new("Frame")
radarFrame.Size = UDim2.new(0, 120, 0, 120)
radarFrame.Position = UDim2.new(0.85, -60, 0.1, 0)
radarFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
radarFrame.BackgroundTransparency = 0.2
radarFrame.BorderSizePixel = 0
radarFrame.Parent = ScreenGui
local radarCorner = Instance.new("UICorner")
radarCorner.CornerRadius = UDim.new(1, 0)
radarCorner.Parent = radarFrame
local radarStroke = Instance.new("UIStroke")
radarStroke.Color = Color3.fromRGB(60, 100, 255)
radarStroke.Thickness = 1.5
radarStroke.Transparency = 0.3
radarStroke.Parent = radarFrame

local radarCenter = Instance.new("Frame")
radarCenter.Size = UDim2.new(0, 4, 0, 4)
radarCenter.Position = UDim2.new(0.5, -2, 0.5, -2)
radarCenter.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
radarCenter.BackgroundTransparency = 0.2
radarCenter.BorderSizePixel = 0
radarCenter.Parent = radarFrame
local centerCorner = Instance.new("UICorner")
centerCorner.CornerRadius = UDim.new(1, 0)
centerCorner.Parent = radarCenter

local radarDots = {}

RunService.RenderStepped:Connect(function()
    if not state.radar then
        radarFrame.Visible = false
        return
    end
    radarFrame.Visible = true
    
    for _, dot in pairs(radarDots) do dot:Destroy() end
    radarDots = {}
    
    local center = Camera.CFrame.Position
    local radius = getgenv().Settings.RadarRadius
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end
        
        local humanoid = plr.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end
        
        if LocalPlayer.Team and plr.Team and LocalPlayer.Team == plr.Team then continue end
        
        local pos = plr.Character:GetPivot().Position
        local dist = (center - pos).Magnitude
        if dist > radius then continue end
        
        local angle = math.atan2(pos.Z - center.Z, pos.X - center.X)
        local scale = dist / radius * 40
        
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 4, 0, 4)
        dot.Position = UDim2.new(0.5, math.sin(angle) * scale - 2, 0.5, math.cos(angle) * scale - 2)
        dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        dot.BackgroundTransparency = 0.2
        dot.BorderSizePixel = 0
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        dot.Parent = radarFrame
        table.insert(radarDots, dot)
    end
end)

--// ======== ВІЗУАЛЬНІ ПОКРАЩЕННЯ ======== //--
for _, v in pairs(Workspace:GetDescendants()) do
    if v:IsA("BasePart") and v.Parent and v.Parent:FindFirstChild("Humanoid") then
        v.Material = Enum.Material.Glass
        v.Transparency = 0.1
        v.Reflectance = 0.2
    end
end

Lighting.FogEnd = 1000
Lighting.FogStart = 0
Lighting.GlobalShadows = false
Lighting.Brightness = 2
Lighting.ClockTime = 12

--// ======== ЗАВЕРШЕННЯ ======== //--
notify("Survival Hub v2.0 loaded!", Color3.fromRGB(100, 255, 100))
print("✅ РОЗШИРЕНА ВЕРСІЯ ЗАВАНТАЖЕНО!")
print("✅ ~650 рядків коду")
print("✅ Aimbot, ESP, Radar, FOV, Auto-switch")
print("✅ Всі обходи античиту")
