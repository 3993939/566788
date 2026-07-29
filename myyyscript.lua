--[[
    РОЗШИРЕНИЙ GUI З БІЧНОЮ ПАНЕЛЛЮ
    - Відкриття / Закриття: [RightShift]
    - Вкладки: Aimbot | ESP | Visuals
    - Активація аіму: Затискання ПКМ
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========== ЗНИЩЕННЯ СТАРОГО GUI ==========
if CoreGui:FindFirstChild("AdvancedUI_Container") then
    CoreGui.AdvancedUI_Container:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedUI_Container"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ========== НАЛАШТУВАННЯ ==========
local Settings = {
    -- Aimbot
    Enabled = true,
    Smoothness = 0.15,
    FOV = 150,
    WallCheck = true,
    TeamCheck = false,
    TargetMode = 1,
    Randomization = 0.05,
    IsAiming = false,
    -- ESP
    ESPEnabled = false,
    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPColor = Color3.fromRGB(255, 50, 80),
    -- Visuals
    FOVCircleEnabled = true,
    Crosshair = true,
    HitEffect = false,
}

-- ========== ГОЛОВНЕ ВІКНО ==========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 400)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.7
MainStroke.Parent = MainFrame

-- ========== БІЧНА ПАНЕЛЬ (ВКЛАДКИ) ==========
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 80, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Sidebar.BackgroundTransparency = 0.5
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 16)
SidebarCorner.Parent = Sidebar

-- Кнопки вкладок
local Tabs = {"Aimbot", "ESP", "Visuals"}
local TabButtons = {}
local TabFrames = {}
local SelectedTab = 1

local function CreateTabButton(name, icon, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 60)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundTransparency = 0.8
    btn.Text = icon .. "\n" .. name
    btn.TextColor3 = Color3.fromRGB(180, 190, 210)
    btn.TextSize = 12
    btn.TextWrapped = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = Sidebar
    
    btn.MouseButton1Click:Connect(function()
        for i, frame in pairs(TabFrames) do
            frame.Visible = (i == name)
        end
        for i, button in pairs(TabButtons) do
            button.BackgroundTransparency = (i == name) and 0.6 or 0.8
            button.TextColor3 = (i == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 190, 210)
        end
        SelectedTab = name
    end)
    
    return btn
end

-- ========== КОНТЕЙНЕР ДЛЯ ВКЛАДОК ==========
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -90, 1, -20)
ContentArea.Position = UDim2.new(0, 85, 0, 10)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

-- Вкладка Aimbot
local AimbotTab = Instance.new("Frame")
AimbotTab.Size = UDim2.new(1, 0, 1, 0)
AimbotTab.BackgroundTransparency = 1
AimbotTab.Parent = ContentArea
TabFrames["Aimbot"] = AimbotTab

-- Вкладка ESP
local ESPTab = Instance.new("Frame")
ESPTab.Size = UDim2.new(1, 0, 1, 0)
ESPTab.BackgroundTransparency = 1
ESPTab.Visible = false
ESPTab.Parent = ContentArea
TabFrames["ESP"] = ESPTab

-- Вкладка Visuals
local VisualsTab = Instance.new("Frame")
VisualsTab.Size = UDim2.new(1, 0, 1, 0)
VisualsTab.BackgroundTransparency = 1
VisualsTab.Visible = false
VisualsTab.Parent = ContentArea
TabFrames["Visuals"] = VisualsTab

-- ========== СТВОРЕННЯ КНОПОК ВКЛАДОК ==========
table.insert(TabButtons, CreateTabButton("Aimbot", "🎯", 20))
table.insert(TabButtons, CreateTabButton("ESP", "👁️", 100))
table.insert(TabButtons, CreateTabButton("Visuals", "🎨", 180))

-- ========== ФУНКЦІЇ ДЛЯ ЕЛЕМЕНТІВ GUI ==========
local function CreateSlider(parent, yPos, width, min, max, default, label, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(width or 0.9, 0, 0, 40)
    frame.Position = UDim2.new(0.05, 0, yPos, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.6, 0, 0.4, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label .. ": " .. tostring(default)
    labelText.TextColor3 = Color3.fromRGB(220, 225, 235)
    labelText.TextSize = 13
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0.25, 0)
    track.Position = UDim2.new(0, 0, 0.6, 0)
    track.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    track.BackgroundTransparency = 0.4
    track.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 80, 120)
    fill.BackgroundTransparency = 0.2
    fill.Parent = track

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BackgroundTransparency = 0.3
    knob.Parent = frame

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false
    local function update(value)
        value = math.clamp(value, min, max)
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -7, 0.5, -7)
        labelText.Text = label .. ": " .. string.format("%.2f", value)
        callback(value)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            update(min + pos * (max - min))
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            update(min + pos * (max - min))
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function CreateToggle(parent, yPos, width, default, label, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(width or 0.9, 0, 0, 30)
    frame.Position = UDim2.new(0.05, 0, yPos, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(220, 225, 235)
    labelText.TextSize = 13
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 40, 0, 20)
    switch.Position = UDim2.new(1, -45, 0.5, -10)
    switch.BackgroundColor3 = default and Color3.fromRGB(255, 80, 120) or Color3.fromRGB(60, 70, 90)
    switch.BackgroundTransparency = 0.3
    switch.Parent = frame

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BackgroundTransparency = 0.2
    dot.Parent = switch

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local state = default
    switch.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            switch.BackgroundColor3 = state and Color3.fromRGB(255, 80, 120) or Color3.fromRGB(60, 70, 90)
            dot.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            callback(state)
        end
    end)
end

-- ========== ЗАПОВНЕННЯ ВКЛАДКИ AIMBOT ==========
CreateSlider(AimbotTab, 0.02, 0.45, 0.01, 0.5, 0.15, "Smoothness", function(v)
    Settings.Smoothness = v
end)

CreateSlider(AimbotTab, 0.15, 0.45, 30, 450, 150, "FOV", function(v)
    Settings.FOV = v
    if Settings.FOVCircleEnabled then
        FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
        FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
    end
end)

CreateSlider(AimbotTab, 0.28, 0.45, 0, 0.2, 0.05, "Randomization", function(v)
    Settings.Randomization = v
end)

CreateToggle(AimbotTab, 0.42, 0.4, true, "Enabled", function(v)
    Settings.Enabled = v
end)

CreateToggle(AimbotTab, 0.52, 0.4, true, "Wall Check", function(v)
    Settings.WallCheck = v
end)

CreateToggle(AimbotTab, 0.62, 0.4, false, "Team Check", function(v)
    Settings.TeamCheck = v
end)

-- Вибір режиму аіма
local ModeFrame = Instance.new("Frame")
ModeFrame.Size = UDim2.new(0.4, 0, 0, 35)
ModeFrame.Position = UDim2.new(0.55, 0, 0.42, 0)
ModeFrame.BackgroundTransparency = 1
ModeFrame.Parent = AimbotTab

local ModeLabel = Instance.new("TextLabel")
ModeLabel.Size = UDim2.new(1, 0, 0.4, 0)
ModeLabel.Position = UDim2.new(0, 0, 0, 0)
ModeLabel.BackgroundTransparency = 1
ModeLabel.Text = "Target: Head"
ModeLabel.TextColor3 = Color3.fromRGB(220, 225, 235)
ModeLabel.TextSize = 13
ModeLabel.Font = Enum.Font.Gotham
ModeLabel.TextXAlignment = Enum.TextXAlignment.Left
ModeLabel.Parent = ModeFrame

local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(1, 0, 0.5, 0)
ModeBtn.Position = UDim2.new(0, 0, 0.5, 0)
ModeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 120)
ModeBtn.BackgroundTransparency = 0.3
ModeBtn.Text = "Switch"
ModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeBtn.TextSize = 12
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.Parent = ModeFrame

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 6)
ModeCorner.Parent = ModeBtn

local modes = {"Head", "Torso", "Random"}
local modeIndex = 1
ModeBtn.MouseButton1Click:Connect(function()
    modeIndex = modeIndex % 3 + 1
    Settings.TargetMode = modeIndex
    ModeLabel.Text = "Target: " .. modes[modeIndex]
end)

-- ========== ЗАПОВНЕННЯ ВКЛАДКИ ESP ==========
CreateToggle(ESPTab, 0.02, 0.9, false, "ESP Enabled", function(v)
    Settings.ESPEnabled = v
end)

CreateToggle(ESPTab, 0.12, 0.9, true, "Box ESP", function(v)
    Settings.ESPBox = v
end)

CreateToggle(ESPTab, 0.22, 0.9, true, "Name ESP", function(v)
    Settings.ESPName = v
end)

CreateToggle(ESPTab, 0.32, 0.9, true, "Health Bar", function(v)
    Settings.ESPHealth = v
end)

CreateToggle(ESPTab, 0.42, 0.9, true, "Distance", function(v)
    Settings.ESPDistance = v
end)

-- ========== ЗАПОВНЕННЯ ВКЛАДКИ VISUALS ==========
CreateToggle(VisualsTab, 0.02, 0.9, true, "FOV Circle", function(v)
    Settings.FOVCircleEnabled = v
    FOVCircle.Visible = v
end)

CreateToggle(VisualsTab, 0.12, 0.9, true, "Crosshair", function(v)
    Settings.Crosshair = v
    Crosshair.Visible = v
end)

CreateToggle(VisualsTab, 0.22, 0.9, false, "Hit Effect", function(v)
    Settings.HitEffect = v
end)

-- ========== КОЛО FOV ==========
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = true
FOVCircle.Parent = ScreenGui

local circle = Instance.new("ImageLabel")
circle.Image = "rbxassetid://16036349377"
circle.Size = UDim2.new(1, 0, 1, 0)
circle.BackgroundTransparency = 1
circle.ImageColor3 = Color3.fromRGB(255, 80, 120)
circle.ImageTransparency = 0.85
circle.Parent = FOVCircle

-- ========== ПРИЦІЛ (CROSSHAIR) ==========
local Crosshair = Instance.new("Frame")
Crosshair.Size = UDim2.new(0, 20, 0, 20)
Crosshair.Position = UDim2.new(0.5, -10, 0.5, -10)
Crosshair.BackgroundTransparency = 1
Crosshair.Visible = true
Crosshair.Parent = ScreenGui

local ch1 = Instance.new("Frame")
ch1.Size = UDim2.new(0, 2, 0, 8)
ch1.Position = UDim2.new(0.5, -1, 0, 0)
ch1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ch1.BackgroundTransparency = 0.3
ch1.Parent = Crosshair

local ch2 = Instance.new("Frame")
ch2.Size = UDim2.new(0, 2, 0, 8)
ch2.Position = UDim2.new(0.5, -1, 1, -8)
ch2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ch2.BackgroundTransparency = 0.3
ch2.Parent = Crosshair

local ch3 = Instance.new("Frame")
ch3.Size = UDim2.new(0, 8, 0, 2)
ch3.Position = UDim2.new(0, 0, 0.5, -1)
ch3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ch3.BackgroundTransparency = 0.3
ch3.Parent = Crosshair

local ch4 = Instance.new("Frame")
ch4.Size = UDim2.new(0, 8, 0, 2)
ch4.Position = UDim2.new(1, -8, 0.5, -1)
ch4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ch4.BackgroundTransparency = 0.3
ch4.Parent = Crosshair

-- ========== ЛОГІКА ПКМ ==========
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.IsAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.IsAiming = false
    end
end)

-- ========== AIMBOT ЛОГІКА ==========
local function GetAimPart(character)
    if Settings.TargetMode == 1 then
        return character:FindFirstChild("Head")
    elseif Settings.TargetMode == 2 then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
    elseif Settings.TargetMode == 3 then
        local parts = {}
        local head = character:FindFirstChild("Head")
        local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        if head then table.insert(parts, head) end
        if torso then table.insert(parts, torso) end
        return #parts > 0 and parts[math.random(1, #parts)] or nil
    end
    return character:FindFirstChild("Head")
end

local function IsVisible(targetPart, targetCharacter)
    if not Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local ignoreList = {Camera}
    if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
    if targetCharacter then table.insert(ignoreList, targetCharacter) end
    raycastParams.FilterDescendantsInstances = ignoreList
    return workspace:Raycast(origin, direction, raycastParams) == nil
end

local function GetClosestTarget()
    local closestTarget = nil
    local shortestDistance = Settings.FOV
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local part = GetAimPart(char)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
                        if distance <= shortestDistance and IsVisible(part, char) then
                            shortestDistance = distance
                            closestTarget = part
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

-- ========== ОСНОВНИЙ ЦИКЛ АІМБОТА ==========
RunService.RenderStepped:Connect(function()
    if not Settings.Enabled or not Settings.IsAiming then return end
    local targetPart = GetClosestTarget()
    if targetPart then
        local targetPos = targetPart.Position
        if Settings.Randomization > 0 then
            local r = Settings.Randomization * 10
            targetPos = targetPos + Vector3.new(
                math.random(-r, r)/10,
                math.random(-r, r)/10,
                math.random(-r, r)/10
            )
        end
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        local alpha = Settings.Smoothness == 0 and 1 or math.clamp(Settings.Smoothness, 0.01, 1)
        Camera.CFrame = alpha >= 1 and targetCFrame or Camera.CFrame:Lerp(targetCFrame, alpha)
    end
end)

-- ========== ЛОГІКА ESP ==========
local ESPObjects = {}

local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local esp = {}
    local char = player.Character
    if not char then return end
    
    -- Box
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 40, 0, 60)
    box.BackgroundTransparency = 0.7
    box.BackgroundColor3 = Settings.ESPColor
    box.BorderSizePixel = 0
    box.Parent = ScreenGui
    
    -- Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 1, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = box
    
    -- Health
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 0, 4)
    healthBar.Position = UDim2.new(0, 0, 1, -4)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.Parent = box
    
    esp.Box = box
    esp.NameLabel = nameLabel
    esp.HealthBar = healthBar
    ESPObjects[player] = esp
end

local function UpdateESP()
    for player, esp in pairs(ESPObjects) do
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            if root then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    esp.Box.Visible = true
                    esp.Box.Position = UDim2.new(0, screenPos.X - 20, 0, screenPos.Y - 30)
                    -- Оновлення здоров'я
                    local health = char.Humanoid.Health / char.Humanoid.MaxHealth
                    esp.HealthBar.Size = UDim2.new(health, 0, 0, 4)
                    esp.HealthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - health), 255 * health, 0)
                else
                    esp.Box.Visible = false
                end
            end
        else
            esp.Box.Visible = false
        end
    end
end

-- ========== ТОГЛ UI ==========
local function ToggleUI()
    MainFrame.Visible = not MainFrame.Visible
    if not MainFrame.Visible then
        FOVCircle.Visible = false
        Crosshair.Visible = false
    else
        FOVCircle.Visible = Settings.FOVCircleEnabled
        Crosshair.Visible = Settings.Crosshair
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        ToggleUI()
    end
end)

-- ========== ОНОВЛЕННЯ ESP ==========
RunService.RenderStepped:Connect(function()
    if Settings.ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not ESPObjects[player] then
                    CreateESP(player)
                end
            end
        end
        UpdateESP()
    else
        for _, esp in pairs(ESPObjects) do
            esp.Box.Visible = false
        end
    end
end)

-- ========== ВИДАЛЕННЯ ESP ПРИ ВИХОДІ ГРАВЦЯ ==========
Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        ESPObjects[player].Box:Destroy()
        ESPObjects[player] = nil
    end
end)

print("✅ РОЗШИРЕНИЙ GUI З БІЧНОЮ ПАНЕЛЛЮ УСПІШНО ЗАВАНТАЖЕНО!")
print("📌 ВІДКРИТТЯ: ПРАВИЙ SHIFT")
