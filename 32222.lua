--== [ SOFT HUB V3 - ANIMATED AURA EDITION ] ==--
-- АКТИВАЦІЯ / ЗГОРТАННЯ: ПРАВИЙ SHIFT

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")
local Mouse = LocalPlayer:GetMouse()

-- === НАЛАШТУВАННЯ ===
local aimbotEnabled = true
local espEnabled = true
local wallCheck = true
local aimSmoothness = 0.25 

local espBoxes = {}
local targetAuraRings = {}
local currentTarget = nil
local rainbowColor = Color3.fromRGB(255, 255, 255)

-- Очищення старого UI
local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SoftHub")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoftHub"
screenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(screenGui) end
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- === ГОЛОВНЕ ВІКНО ===
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 480, 0, 360) 
mainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundTransparency = 1
title.Text = "⋆⫸ SOFT HUB V3 ⫷⋆"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 26
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleStroke = Instance.new("UIStroke")
titleStroke.Thickness = 1.5
titleStroke.Color = Color3.fromRGB(0, 0, 0)
titleStroke.Parent = title

-- === ФУНКЦІЯ СТВОРЕННЯ КНОПОК ===
local function createButton(text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 50)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.BackgroundTransparency = 0.3
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Parent = btn
    
    btn.Parent = mainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn, stroke
end

local function toggleVisual(btn, stroke, state, textOn, textOff)
    if state then
        btn.Text = textOn
        stroke.Color = Color3.fromRGB(46, 204, 113)
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play()
    else
        btn.Text = textOff
        stroke.Color = Color3.fromRGB(231, 76, 60)
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.4}):Play()
    end
end

-- === ІНТЕРФЕЙС ===
local aimToggle, aimStroke = createButton("", UDim2.new(0, 30, 0, 80), function()
    aimbotEnabled = not aimbotEnabled
    toggleVisual(aimToggle, aimStroke, aimbotEnabled, "✓ Aimbot: ON", "✗ Aimbot: OFF")
end)

local espToggle, espStroke = createButton("", UDim2.new(0, 250, 0, 80), function()
    espEnabled = not espEnabled
    toggleVisual(espToggle, espStroke, espEnabled, "✓ Animated ESP: ON", "✗ Animated ESP: OFF")
    for _, ring in pairs(espBoxes) do
        if ring then ring.Visible = espEnabled end
    end
end)

local wallToggle, wallStroke = createButton("", UDim2.new(0, 30, 0, 145), function()
    wallCheck = not wallCheck
    toggleVisual(wallToggle, wallStroke, wallCheck, "✓ Wall Check: ON", "✗ Wall Check: OFF")
end)

toggleVisual(aimToggle, aimStroke, aimbotEnabled, "✓ Aimbot: ON", "✗ Aimbot: OFF")
toggleVisual(espToggle, espStroke, espEnabled, "✓ Animated ESP: ON", "✗ Animated ESP: OFF")
toggleVisual(wallToggle, wallStroke, wallCheck, "✓ Wall Check: ON", "✗ Wall Check: OFF")

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 420, 0, 30)
speedLabel.Position = UDim2.new(0, 35, 0, 215)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Aim Smoothness: " .. string.format("%.2f", aimSmoothness) .. " (Lower = Faster)"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 15
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Font = Enum.Font.GothamMedium
speedLabel.Parent = mainFrame

local speedMinus, _ = createButton("- Повільніше", UDim2.new(0, 30, 0, 255), function()
    aimSmoothness = math.clamp(aimSmoothness + 0.02, 0.05, 0.50)
    speedLabel.Text = "Aim Smoothness: " .. string.format("%.2f", aimSmoothness)
end)

local speedPlus, _ = createButton("+ Швидше", UDim2.new(0, 250, 0, 255), function()
    aimSmoothness = math.clamp(aimSmoothness - 0.02, 0.05, 0.50)
    speedLabel.Text = "Aim Smoothness: " .. string.format("%.2f", aimSmoothness)
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if mainFrame.Visible then
            local t = TweenService:Create(mainFrame, TweenInfo.new(0.15), {BackgroundTransparency = 1})
            t:Play()
            t.Completed:Connect(function() mainFrame.Visible = false end)
        else
            mainFrame.BackgroundTransparency = 1
            mainFrame.Visible = true
            TweenService:Create(mainFrame, TweenInfo.new(0.15), {BackgroundTransparency = 0.25}):Play()
        end
    end
end)

-- ==================== АНІМОВАНЕ ESP (Кільце-сканер) ====================
local function applyESP(player)
    if player == LocalPlayer then return end
    
    local function setupRing(character)
        local root = character:WaitForChild("HumanoidRootPart", 5)
        if not root then return end
        
        if espBoxes[player] then espBoxes[player]:Destroy() end
        
        local ring = Instance.new("CylinderHandleAdornment")
        ring.Radius = 3
        ring.InnerRadius = 2.8
        ring.Height = 0.2
        ring.AlwaysOnTop = true
        ring.ZIndex = 5
        ring.Transparency = 0.4
        ring.Visible = espEnabled
        ring.Adornee = root
        ring.Parent = root
        
        espBoxes[player] = ring
    end
    
    if player.Character then setupRing(player.Character) end
    player.CharacterAdded:Connect(setupRing)
    
    player.CharacterRemoving:Connect(function()
        if espBoxes[player] then
            espBoxes[player]:Destroy()
            espBoxes[player] = nil
        end
    end)
end

Players.PlayerAdded:Connect(applyESP)
for _, p in pairs(Players:GetPlayers()) do applyESP(p) end

Players.PlayerRemoving:Connect(function(player)
    if espBoxes[player] then
        espBoxes[player]:Destroy()
        espBoxes[player] = nil
    end
end)

-- ==================== TARGET ESP (Гіроскопічна аура) ====================
local function removeTargetAura()
    for _, data in pairs(targetAuraRings) do
        if data.element then data.element:Destroy() end
    end
    targetAuraRings = {}
end

local function createTargetAura(targetChar)
    removeTargetAura()
    local root = targetChar:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Створюємо 3 кільця, які будуть крутитися як атомна сфера
    for i = 1, 3 do
        local ring = Instance.new("CylinderHandleAdornment")
        ring.Radius = 3.5 + (i * 0.3)
        ring.InnerRadius = 3.3 + (i * 0.3)
        ring.Height = 0.05
        ring.AlwaysOnTop = true
        ring.ZIndex = 10
        ring.Transparency = 0.1
        -- Епічні кольори аури: Червоний, Пурпуровий та Білий
        ring.Color3 = i == 1 and Color3.fromRGB(255, 40, 40) or (i == 2 and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(255, 255, 255))
        ring.Adornee = root
        ring.Parent = root
        
        table.insert(targetAuraRings, {element = ring, speed = i * 3, axis = i})
    end
end

-- ==================== ОСНОВНИЙ ЦИКЛ (Анімації + Aimbot) ====================
local function isWallBetween(origin, targetPos, targetCharacter)
    if not wallCheck then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    return workspace:Raycast(origin, targetPos - origin, rayParams) ~= nil
end

RunService.RenderStepped:Connect(function(dt)
    local timeTick = tick()
    
    -- 1. Анімація градієнта меню
    rainbowColor = Color3.fromHSV((timeTick * 0.1) % 1, 0.6, 0.8)
    mainFrame.BackgroundColor3 = rainbowColor

    -- 2. Анімація звичайного ESP (Кільце обвиває тіло вгору-вниз)
    if espEnabled then
        for _, ring in pairs(espBoxes) do
            if ring and ring.Parent then
                ring.Color3 = rainbowColor
                local offset = math.sin(timeTick * 3) * 2.5 -- Рух від ніг до голови
                -- Повертаємо кільце горизонтально і рухаємо
                ring.CFrame = CFrame.new(0, offset, 0) * CFrame.Angles(math.rad(90), 0, 0)
            end
        end
    end

    -- 3. Анімація Target ESP (Гіроскопічна сфера)
    if currentTarget and #targetAuraRings > 0 then
        for _, data in pairs(targetAuraRings) do
            local ring = data.element
            if ring and ring.Parent then
                local angle = timeTick * data.speed
                local rotX = data.axis == 1 and angle or (data.axis == 3 and -angle or 0)
                local rotY = data.axis == 2 and angle or (data.axis == 1 and -angle or 0)
                local rotZ = data.axis == 3 and angle or (data.axis == 2 and -angle or 0)
                
                ring.CFrame = CFrame.Angles(rotX, rotY, rotZ) * CFrame.Angles(math.rad(90), 0, 0)
            end
        end
    end

    -- 4. Логіка Aimbot
    if not aimbotEnabled then 
        removeTargetAura()
        currentTarget = nil
        return 
    end

    local closestDist = 300
    local bestTargetPart = nil
    local bestTargetChar = nil

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
                        bestTargetPart = root
                        bestTargetChar = player.Character
                    end
                end
            end
        end
    end

    -- Наведення та зміна цілі
    if bestTargetPart and bestTargetChar then
        if currentTarget ~= bestTargetChar then
            currentTarget = bestTargetChar
            createTargetAura(currentTarget) -- Створюємо епічну ауру на новій цілі
        end
        
        local targetPos = bestTargetPart.Position + Vector3.new(0, 0.4, 0)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), aimSmoothness)
    else
        removeTargetAura()
        currentTarget = nil
    end
end)

print("Soft Hub V3 [Aura Edition] Loaded!")
