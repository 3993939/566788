--== [ SOFT HUB - FULL FIXED ] ==--
-- АКТИВАЦІЯ: ПРАВИЙ SHIFT

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- === НАЛАШТУВАННЯ ===
local aimbotEnabled = true
local espEnabled = true
local aimSmoothness = 0.17
local wallCheck = true

local espBoxes = {}        -- {[player] = box}
local indicatorBillboard = nil
local currentTarget = nil

-- Видалення старого GUI
local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SoftHub")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoftHub"
screenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(screenGui) end
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- === СТВОРЕННЯ ІНДИКАТОРА (ПРАВИЛЬНО: чіпляємо до HumanoidRootPart) ===
local function createTargetIndicator()
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TargetIndicator"
    billboard.Size = UDim2.new(0, 100, 0, 70)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Parent = screenGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard
    
    -- Ромб (трикутник повернутий) через Frame + Rotation
    local diamond = Instance.new("Frame")
    diamond.Size = UDim2.new(0, 30, 0, 30)
    diamond.Position = UDim2.new(0.5, -15, 0, 0)
    diamond.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    diamond.BorderSizePixel = 0
    diamond.Rotation = 45  -- Повертаємо квадрат на 45° = ромб
    diamond.Parent = frame
    
    local diamondCorner = Instance.new("UICorner")
    diamondCorner.CornerRadius = UDim.new(0, 4)
    diamondCorner.Parent = diamond
    
    -- Ім'я гравця
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 35)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = ""
    nameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Parent = frame
    
    -- Пульсація
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    TweenService:Create(diamond, tweenInfo, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
    
    return billboard, nameLabel
end

-- === ГОЛОВНЕ ВІКНО ===
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 480, 0, 360)
mainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "⋆⫸ SOFT HUB ⫷⋆"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 26
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleStroke = Instance.new("UIStroke")
titleStroke.Thickness = 1.5
titleStroke.Color = Color3.fromRGB(0, 0, 0)
titleStroke.Parent = title

-- === ФУНКЦІЯ КНОПКИ З КОЛЬОРОВОЮ ІНДИКАЦІЄЮ ===
local function createToggleButton(text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 50)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(0, 255, 0)  -- Зелений = ввімкнено
    stroke.Transparency = 0  -- видима обводка
    stroke.Parent = btn
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = btn
    
    btn.Parent = mainFrame
    
    btn.MouseButton1Click:Connect(function()
        callback()
        -- Оновлюємо колір обводки після зміни стану
        local isOn = btn.Text:match("ON") ~= nil
        stroke.Color = isOn and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
    
    return btn, stroke
end

-- === СТВОРЕННЯ КНОПОК ===
local aimToggle, aimStroke = createToggleButton("✓ Aimbot (ON)", UDim2.new(0, 30, 0, 80), function()
    aimbotEnabled = not aimbotEnabled
    aimToggle.Text = aimbotEnabled and "✓ Aimbot (ON)" or "✗ Aimbot (OFF)"
end)

local espToggle, espStroke = createToggleButton("✓ ESP (ON)", UDim2.new(0, 250, 0, 80), function()
    espEnabled = not espEnabled
    espToggle.Text = espEnabled and "✓ ESP (ON)" or "✗ ESP (OFF)"
    for _, box in pairs(espBoxes) do
        if box then box.Visible = espEnabled end
    end
end)

local wallToggle, wallStroke = createToggleButton("✓ Wall Check (ON)", UDim2.new(0, 30, 0, 145), function()
    wallCheck = not wallCheck
    wallToggle.Text = wallCheck and "✓ Wall Check (ON)" or "✗ Wall Check (OFF)"
end)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 420, 0, 30)
speedLabel.Position = UDim2.new(0, 35, 0, 215)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Aim Smoothness: " .. string.format("%.2f", aimSmoothness)
speedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
speedLabel.TextSize = 15
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Font = Enum.Font.GothamMedium
speedLabel.Parent = mainFrame

local speedMinus = createToggleButton("-", UDim2.new(0, 30, 0, 255), function()
    aimSmoothness = math.clamp(aimSmoothness + 0.02, 0.05, 0.50)
    speedLabel.Text = "Aim Smoothness: " .. string.format("%.2f", aimSmoothness)
end)
speedMinus.Size = UDim2.new(0, 90, 0, 45)

local speedPlus = createToggleButton("+", UDim2.new(0, 360, 0, 255), function()
    aimSmoothness = math.clamp(aimSmoothness - 0.02, 0.05, 0.50)
    speedLabel.Text = "Aim Smoothness: " .. string.format("%.2f", aimSmoothness)
end)
speedPlus.Size = UDim2.new(0, 90, 0, 45)

-- === АНІМАЦІЯ МЕНЮ ===
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Градієнт фону
local hue = 0
RunService.RenderStepped:Connect(function(dt)
    hue = (hue + 0.04 * dt) % 1
    mainFrame.BackgroundColor3 = Color3.fromHSV(hue, 0.6, 0.8)
end)

-- === ESP (ПРАВИЛЬНЕ ВИДАЛЕННЯ) ===
local function createESP(player)
    if player == LocalPlayer then return end
    
    local function applyESP(char)
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(4, 6, 4)
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.5
        box.Adornee = char
        box.Color3 = Color3.fromRGB(255, 255, 255)
        box.Visible = espEnabled
        box.Parent = screenGui
        espBoxes[player] = box
    end
    
    if player.Character then applyESP(player.Character) end
    
    -- Підписка на події
    player.CharacterAdded:Connect(function(char)
        if espBoxes[player] then espBoxes[player]:Destroy() end
        applyESP(char)
    end)
    
    player.CharacterRemoving:Connect(function()
        if espBoxes[player] then 
            espBoxes[player]:Destroy()
            espBoxes[player] = nil
        end
    end)
end

for _, plr in pairs(Players:GetPlayers()) do 
    task.spawn(function() createESP(plr) end)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(plr)
    if espBoxes[plr] then 
        espBoxes[plr]:Destroy()
        espBoxes[plr] = nil
    end
end)

-- === AIMBOT + ІНДИКАТОР ===
local indicator, indicatorName = createTargetIndicator()

local function isWallBetween(origin, targetPos, targetCharacter)
    if not wallCheck then return false end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    raycastParams.IgnoreWater = true
    local direction = targetPos - origin
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    return raycastResult ~= nil
end

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then
        if indicator.Adornee then indicator.Adornee = nil end
        return
    end
    
    local closestDist = 250
    local bestTarget = nil
    local bestTargetPart = nil
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < closestDist and not isWallBetween(Camera.CFrame.Position, root.Position, player.Character) then
                        closestDist = dist
                        bestTarget = player
                        bestTargetPart = root
                    end
                end
            end
        end
    end
    
    if bestTargetPart and bestTarget then
        -- ✅ ПРАВИЛЬНО: чіпляємо BillboardGui до HumanoidRootPart
        if indicator.Adornee ~= bestTargetPart then
            indicator.Adornee = bestTargetPart
            indicatorName.Text = bestTarget.Name
        end
        -- Наведення камери
        local targetPos = bestTargetPart.Position + Vector3.new(0, 1.5, 0)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), aimSmoothness)
    else
        if indicator.Adornee then indicator.Adornee = nil end
    end
end)

print("✅ SOFT HUB FULL FIXED | Right Shift")
