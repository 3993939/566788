--== [ SOFT HUB V8 - PREMIUM UI, SMOOTH AIM & DRAGGABLE ] ==--
-- ВІДКРИТТЯ / ЗГОРТАННЯ: ПРАВИЙ SHIFT

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
local fastAimEnabled = true

local targetAuraRings = {}
local currentTarget = nil
local TRAIL_LENGTH = 12

-- Очищення старого UI
local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SoftHub")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoftHub"
screenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(screenGui) end
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- === СУЧАСНИЙ ГОЛОВНИЙ ФРЕЙМ ===
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 280) -- Більш компактний
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(60, 60, 60)
stroke.Parent = mainFrame

-- Заголовок
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 8)
topCorner.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "SOFT HUB V8"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Контейнер для перемикачів
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -40, 1, -60)
contentFrame.Position = UDim2.new(0, 20, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 15)
layout.Parent = contentFrame

-- === ФУНКЦІЯ ПЕРЕТЯГУВАННЯ GUI (DRAG) ===
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- === ФУНКЦІЯ СТВОРЕННЯ СВІТЧІВ ===
local function createToggle(name, defaultState, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 35)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = contentFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local switchBtn = Instance.new("TextButton")
    switchBtn.Size = UDim2.new(0, 44, 0, 24)
    switchBtn.Position = UDim2.new(1, -44, 0.5, -12)
    switchBtn.BackgroundColor3 = defaultState and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(60, 60, 60)
    switchBtn.Text = ""
    switchBtn.Parent = toggleFrame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchBtn
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = defaultState and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = switchBtn
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    
    local state = defaultState
    switchBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(switchBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(46, 204, 113)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -22, 0.5, -10)}):Play()
        else
            TweenService:Create(switchBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -10)}):Play()
        end
        callback(state)
    end)
end

-- === СТВОРЕННЯ ЕЛЕМЕНТІВ UI ===
createToggle("Smart Aimbot", aimbotEnabled, function(val) aimbotEnabled = val end)
createToggle("ESP Highlight", espEnabled, function(val) 
    espEnabled = val
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("SoftHubESP") then
            p.Character.SoftHubESP.Enabled = espEnabled
        end
    end
end)
createToggle("Wall Check", wallCheck, function(val) wallCheck = val end)
createToggle("Fast Aim", fastAimEnabled, function(val) fastAimEnabled = val end)

-- Відкриття/Закриття
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- ==================== ESP ====================
local function applyESP(character)
    if not character then return end
    local player = Players:GetPlayerFromCharacter(character)
    if player == LocalPlayer then return end
    
    local hum = character:WaitForChild("Humanoid", 5)
    if not hum then return end
    
    if character:FindFirstChild("SoftHubESP") then character.SoftHubESP:Destroy() end
    
    local hl = Instance.new("Highlight")
    hl.Name = "SoftHubESP"
    hl.FillColor = Color3.fromRGB(255, 110, 180)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.55
    hl.OutlineTransparency = 0.15
    hl.Enabled = espEnabled
    hl.Adornee = character
    hl.Parent = character
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(applyESP)
end)

for _, p in pairs(Players:GetPlayers()) do
    if p.Character then applyESP(p.Character) end
    p.CharacterAdded:Connect(applyESP)
end

-- ==================== ОРБІТАЛЬНІ КУЛІ (ДИНАМІЧНІ) ====================
local function removeTargetAura()
    for _, data in pairs(targetAuraRings) do
        if data.element then data.element:Destroy() end
        if data.trails then
            for _, trailPart in pairs(data.trails) do
                if trailPart then trailPart:Destroy() end
            end
        end
    end
    targetAuraRings = {}
end

local function createTargetAura(targetChar)
    removeTargetAura()
    local root = targetChar:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    for i = 1, 3 do
        local color = i == 1 and Color3.fromRGB(255, 60, 60) or (i == 2 and Color3.fromRGB(160, 40, 255) or Color3.fromRGB(255, 255, 255))
        
        local sphere = Instance.new("SphereHandleAdornment")
        sphere.Radius = 0.65
        sphere.AlwaysOnTop = true
        sphere.ZIndex = 10
        sphere.Transparency = 0.1
        sphere.Color3 = color
        sphere.Adornee = root
        sphere.Parent = screenGui
        
        local trailParts = {}
        for j = 1, TRAIL_LENGTH do
            local tPart = Instance.new("SphereHandleAdornment")
            tPart.Radius = 0.65 * (1 - (j / (TRAIL_LENGTH + 1)))
            tPart.AlwaysOnTop = true
            tPart.ZIndex = 9
            tPart.Transparency = 0.2 + (0.8 * (j / TRAIL_LENGTH))
            tPart.Color3 = color
            tPart.Adornee = root
            tPart.Visible = false
            tPart.Parent = screenGui
            table.insert(trailParts, tPart)
        end
        
        table.insert(targetAuraRings, {
            element = sphere, 
            speed = 3.5 + (i * 0.5), 
            axis = i,
            trails = trailParts,
            history = {}
        })
    end
end

-- ==================== М'ЯКИЙ ТА АКУРАТНИЙ АЇМБОТ ====================
local function isWallBetween(origin, targetPos, targetCharacter)
    if not wallCheck then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    return workspace:Raycast(origin, targetPos - origin, rayParams) ~= nil
end

RunService.RenderStepped:Connect(function(dt)
    local timeTick = tick()
    
    -- Динамічна анімація сфер (Орбіта + Пульсація)
    if currentTarget and #targetAuraRings > 0 then
        for _, data in pairs(targetAuraRings) do
            local sphere = data.element
            if sphere and sphere.Parent then
                local angle = timeTick * data.speed
                local rotCF
                
                if data.axis == 1 then
                    rotCF = CFrame.Angles(math.rad(20), angle, 0)
                elseif data.axis == 2 then
                    rotCF = CFrame.Angles(angle, math.rad(60), 0)
                else
                    rotCF = CFrame.Angles(angle, math.rad(-60), 0)
                end
                
                -- Додано math.sin для красивого ефекту пульсації вверх-вниз
                local bounceOffset = math.sin(timeTick * 4 + data.axis) * 1.2
                local currentCFrame = rotCF * CFrame.new(0, bounceOffset, -4.2)
                
                sphere.CFrame = currentCFrame
                
                table.insert(data.history, 1, currentCFrame)
                if #data.history > TRAIL_LENGTH then
                    table.remove(data.history, #data.history)
                end
                
                for j, trailPart in ipairs(data.trails) do
                    if data.history[j] then
                        trailPart.CFrame = data.history[j]
                        trailPart.Visible = true
                    else
                        trailPart.Visible = false
                    end
                end
            end
        end
    end

    if not aimbotEnabled then 
        removeTargetAura()
        currentTarget = nil
        return 
    end

    local closestDist = 350
    local bestTargetPart = nil
    local bestTargetChar = nil

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                local validPart = nil
                
                if head then
                    local pos, onScreen = Camera:WorldToScreenPoint(head.Position)
                    if onScreen and not isWallBetween(Camera.CFrame.Position, head.Position, player.Character) then
                        validPart = head
                    end
                end
                
                if not validPart and root then
                    local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
                    if onScreen and not isWallBetween(Camera.CFrame.Position, root.Position, player.Character) then
                        validPart = root
                    end
                end
                
                if validPart then
                    local pos = Camera:WorldToScreenPoint(validPart.Position)
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    
                    if dist < closestDist then
                        closestDist = dist
                        bestTargetPart = validPart
                        bestTargetChar = player.Character
                    end
                end
            end
        end
    end

    -- Акуратне наведення (Smooth Aim)
    if bestTargetPart and bestTargetChar then
        if currentTarget ~= bestTargetChar then
            currentTarget = bestTargetChar
            createTargetAura(currentTarget)
        end
        
        -- Змінено коефіцієнти для максимальної акуратності: 
        -- 0.08 - дуже плавно і непомітно, 0.25 - швидше, але без ривків
        local currentSmoothness = fastAimEnabled and 0.25 or 0.08
        local offset = (bestTargetPart.Name == "HumanoidRootPart") and Vector3.new(0, 0.5, 0) or Vector3.new(0, 0, 0)
        local targetPos = bestTargetPart.Position + offset
        
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), currentSmoothness)
    else
        removeTargetAura()
        currentTarget = nil
    end
end)

print("Soft Hub V8 loaded: Premium UI & Ultra Smooth Aim")
