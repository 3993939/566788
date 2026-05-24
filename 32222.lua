--== [ SOFT HUB V7 - ORBITAL TRAILS & FIXED UI ] ==--
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
local rainbowColor = Color3.fromRGB(255, 255, 255)
local TRAIL_LENGTH = 10 -- Довжина шлейфу за кулями

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
mainFrame.Size = UDim2.new(0, 480, 0, 230)
mainFrame.Position = UDim2.new(0.5, -240, 0.5, -115)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 55)
title.BackgroundTransparency = 1
title.Text = "⋆⫸ SOFT HUB V7 ⫷⋆"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleStroke = Instance.new("UIStroke")
titleStroke.Thickness = 1.5
titleStroke.Color = Color3.fromRGB(0, 0, 0)
titleStroke.Parent = title

-- === ФУНКЦІЇ КНОПОК (ВИПРАВЛЕНА ІНДИКАЦІЯ) ===
local function createButton(text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 48)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    btn.BackgroundTransparency = 0.3
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border -- Чітке відображення рамки
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Parent = btn
    
    local scale = Instance.new("UIScale")
    scale.Parent = btn
    
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.92}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end)
    
    btn.Parent = mainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn, stroke
end

local function toggleVisual(btn, stroke, state, textOn, textOff)
    -- Тепер міняється не тільки текст і рамка, але й фон кнопки для 100% видимості
    if state then
        btn.Text = textOn
        stroke.Color = Color3.fromRGB(46, 204, 113)
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(20, 70, 30), -- Темно-зелений фон
            BackgroundTransparency = 0.1
        }):Play()
    else
        btn.Text = textOff
        stroke.Color = Color3.fromRGB(231, 76, 60)
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(15, 15, 15), -- Темний фон
            BackgroundTransparency = 0.4
        }):Play()
    end
end

-- === ІНТЕРФЕЙС ===
local aimToggle, aimStroke = createButton("", UDim2.new(0, 30, 0, 70), function()
    aimbotEnabled = not aimbotEnabled
    toggleVisual(aimToggle, aimStroke, aimbotEnabled, "✓ Smart Aim: ON", "✗ Smart Aim: OFF")
end)

local espToggle, espStroke = createButton("", UDim2.new(0, 250, 0, 70), function()
    espEnabled = not espEnabled
    toggleVisual(espToggle, espStroke, espEnabled, "✓ ESP: ON", "✗ ESP: OFF")
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("SoftHubESP") then
            p.Character.SoftHubESP.Enabled = espEnabled
        end
    end
end)

local wallToggle, wallStroke = createButton("", UDim2.new(0, 30, 0, 135), function()
    wallCheck = not wallCheck
    toggleVisual(wallToggle, wallStroke, wallCheck, "✓ Wall Check: ON", "✗ Wall Check: OFF")
end)

local fastAimToggle, fastAimStroke = createButton("", UDim2.new(0, 250, 0, 135), function()
    fastAimEnabled = not fastAimEnabled
    toggleVisual(fastAimToggle, fastAimStroke, fastAimEnabled, "✓ Fast Aim: ON", "✗ Fast Aim: OFF")
end)

toggleVisual(aimToggle, aimStroke, aimbotEnabled, "✓ Smart Aim: ON", "✗ Smart Aim: OFF")
toggleVisual(espToggle, espStroke, espEnabled, "✓ ESP: ON", "✗ ESP: OFF")
toggleVisual(wallToggle, wallStroke, wallCheck, "✓ Wall Check: ON", "✗ Wall Check: OFF")
toggleVisual(fastAimToggle, fastAimStroke, fastAimEnabled, "✓ Fast Aim: ON", "✗ Fast Aim: OFF")

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if mainFrame.Visible then
            local t = TweenService:Create(mainFrame, TweenInfo.new(0.12), {BackgroundTransparency = 1})
            t:Play()
            t.Completed:Connect(function() mainFrame.Visible = false end)
        else
            mainFrame.BackgroundTransparency = 1
            mainFrame.Visible = true
            TweenService:Create(mainFrame, TweenInfo.new(0.12), {BackgroundTransparency = 0.25}):Play()
        end
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

-- ==================== ОРБІТАЛЬНІ КУЛІ + ШЛЕЙФ ====================
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
        
        -- Основна куля
        local sphere = Instance.new("SphereHandleAdornment")
        sphere.Radius = 0.65
        sphere.AlwaysOnTop = true
        sphere.ZIndex = 10
        sphere.Transparency = 0.1
        sphere.Color3 = color
        sphere.Adornee = root
        sphere.Parent = screenGui
        
        -- Створення елементів для шлейфу (диму)
        local trailParts = {}
        for j = 1, TRAIL_LENGTH do
            local tPart = Instance.new("SphereHandleAdornment")
            tPart.Radius = 0.65 * (1 - (j / (TRAIL_LENGTH + 1))) -- Кулі стають меншими
            tPart.AlwaysOnTop = true
            tPart.ZIndex = 9
            tPart.Transparency = 0.2 + (0.8 * (j / TRAIL_LENGTH)) -- Кулі прозорішають
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
            history = {} -- Сюди будемо записувати минулі позиції кулі
        })
    end
end

-- ==================== РОЗУМНИЙ АЇМБОТ (Голова -> Тіло) ====================
local function isWallBetween(origin, targetPos, targetCharacter)
    if not wallCheck then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    return workspace:Raycast(origin, targetPos - origin, rayParams) ~= nil
end

local hue = 0
RunService.RenderStepped:Connect(function(dt)
    local timeTick = tick()
    
    -- Анімація меню
    hue = (hue + 0.03 * dt) % 1
    rainbowColor = Color3.fromHSV(hue, 0.55, 0.75)
    mainFrame.BackgroundColor3 = rainbowColor

    -- Анімація орбітальних куль та шлейфу
    if currentTarget and #targetAuraRings > 0 then
        for _, data in pairs(targetAuraRings) do
            local sphere = data.element
            if sphere and sphere.Parent then
                local angle = timeTick * data.speed
                local rotCF
                
                -- Кожна куля літає по своїй осі
                if data.axis == 1 then
                    rotCF = CFrame.Angles(math.rad(20), angle, 0)
                elseif data.axis == 2 then
                    rotCF = CFrame.Angles(angle, math.rad(60), 0)
                else
                    rotCF = CFrame.Angles(angle, math.rad(-60), 0)
                end
                
                -- Позиція основної кулі
                local currentCFrame = rotCF * CFrame.new(0, 0, -3.8)
                sphere.CFrame = currentCFrame
                
                -- Оновлення історії позицій для шлейфу
                table.insert(data.history, 1, currentCFrame)
                if #data.history > TRAIL_LENGTH then
                    table.remove(data.history, #data.history)
                end
                
                -- Розстановка шлейфу за кулею
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

    -- Наведення камери
    if bestTargetPart and bestTargetChar then
        if currentTarget ~= bestTargetChar then
            currentTarget = bestTargetChar
            createTargetAura(currentTarget)
        end
        
        local currentSmoothness = fastAimEnabled and 0.55 or 0.22
        local offset = (bestTargetPart.Name == "HumanoidRootPart") and Vector3.new(0, 0.5, 0) or Vector3.new(0, 0, 0)
        local targetPos = bestTargetPart.Position + offset
        
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), currentSmoothness)
    else
        removeTargetAura()
        currentTarget = nil
    end
end)

print("Soft Hub V7 loaded: Orbital Trails & Fixed UI Enabled!")
