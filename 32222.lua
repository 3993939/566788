--== [ SOFT AIM + ESP + BEAUTIFUL PASTEL GUI ] ==--
-- АКТИВАЦІЯ / ЗГОРТАННЯ: ПРАВИЙ SHIFT

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
local aimSmoothness = 0.15     -- 0.05 = дуже швидко | 0.30 = повільно і безпалевно
local wallCheck = true         -- false = цілиться через стіни

local espBoxes = {}
local currentTarget = nil
local targetHighlight = nil
local rainbowColor = Color3.fromRGB(255, 255, 255)

-- Перевірка на дублювання
local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SoftHub")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoftHub"
screenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(screenGui) end
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 480, 0, 340) -- Трохи збільшив висоту, щоб усе сіло ідеально
mainFrame.Position = UDim2.new(0.5, -240, 0.5, -170)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "⋆⫸ SOFT HUB ⫷⋆"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleStroke = Instance.new("UIStroke")
titleStroke.Thickness = 1.5
titleStroke.Color = Color3.fromRGB(0, 0, 0)
titleStroke.Parent = title

-- === КНОПКИ ===
local function createToggleButton(text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BackgroundTransparency = 0.4
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamMedium
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = btn
    btn.Parent = mainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local aimToggle = createToggleButton("✓ Aimbot (ON)", UDim2.new(0, 30, 0, 70), function()
    aimbotEnabled = not aimbotEnabled
    aimToggle.Text = aimbotEnabled and "✓ Aimbot (ON)" or "✗ Aimbot (OFF)"
    aimToggle.TextColor3 = aimbotEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
end)

local espToggle = createToggleButton("✓ ESP (ON)", UDim2.new(0, 250, 0, 70), function()
    espEnabled = not espEnabled
    espToggle.Text = espEnabled and "✓ ESP (ON)" or "✗ ESP (OFF)"
    espToggle.TextColor3 = espEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
    for _, box in pairs(espBoxes) do
        if box then box.Visible = espEnabled end
    end
end)

local wallToggle = createToggleButton("✓ Wall Check (ON)", UDim2.new(0, 30, 0, 135), function()
    wallCheck = not wallCheck
    wallToggle.Text = wallCheck and "✓ Wall Check (ON)" or "✗ Wall Check (OFF)"
    wallToggle.TextColor3 = wallCheck and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
end)

-- Швидкість аіму
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 420, 0, 30)
speedLabel.Position = UDim2.new(0, 30, 0, 205)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Aim Smoothness: " .. string.format("%.2f", aimSmoothness) .. " (Lower = Faster)"
speedLabel.TextColor3 = Color3.fromRGB(255,255,255)
speedLabel.TextSize = 15
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Font = Enum.Font.GothamMedium
speedLabel.Parent = mainFrame

local speedMinus = createToggleButton("- Повільніше", UDim2.new(0, 30, 0, 250), function()
    aimSmoothness = math.clamp(aimSmoothness + 0.02, 0.05, 0.40)
    speedLabel.Text = "Aim Smoothness: " .. string.format("%.2f", aimSmoothness) .. " (Lower = Faster)"
end)

local speedPlus = createToggleButton("+ Швидше", UDim2.new(0, 250, 0, 250), function()
    aimSmoothness = math.clamp(aimSmoothness - 0.02, 0.05, 0.40)
    speedLabel.Text = "Aim Smoothness: " .. string.format("%.2f", aimSmoothness) .. " (Lower = Faster)"
end)

-- Анімація меню
local function animateGUI(state)
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = state and 0.15 or 1}):Play()
end

-- Відкриття меню
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then animateGUI(true) end
    end
end)

-- Пастельний градієнт та оновлення кольору ESP
local hue = 0
RunService.RenderStepped:Connect(function(dt)
    hue = (hue + 0.04 * dt) % 1
    rainbowColor = Color3.fromHSV(hue, 0.55, 0.75)
    mainFrame.BackgroundColor3 = rainbowColor
    
    -- Плавне оновлення кольору для ESP коробок
    if espEnabled then
        for _, box in pairs(espBoxes) do
            if box and box:IsA("BoxHandleAdornment") then
                box.Color3 = rainbowColor
            end
        end
    end
end)

-- ==================== ESP ====================
local function createESP(player)
    if player == LocalPlayer then return end

    local function applyESP(char)
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if not root then return end

        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(4, 6, 4)
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.5
        box.Adornee = char
        box.Color3 = rainbowColor
        box.Visible = espEnabled
        box.Parent = screenGui

        espBoxes[player] = box
    end

    if player.Character then applyESP(player.Character) end
    player.CharacterAdded:Connect(applyESP)
    
    player.CharacterRemoving:Connect(function()
        if espBoxes[player] then
            espBoxes[player]:Destroy()
            espBoxes[player] = nil
        end
    end)
end

for _, plr in pairs(Players:GetPlayers()) do createESP(plr) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(plr)
    if espBoxes[plr] then 
        espBoxes[plr]:Destroy() 
        espBoxes[plr] = nil
    end
end)

-- ==================== AIMBOT ====================
local function isWallBetween(origin, targetPos, targetCharacter)
    if not wallCheck then return false end
    
    -- Новий безпечний метод променів (Raycast)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    raycastParams.IgnoreWater = true
    
    local direction = targetPos - origin
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    -- Якщо промінь у щось врізався — між нами стіна
    if raycastResult then
        return true
    end
    return false
end

local function removeHighlight()
    if targetHighlight then
        targetHighlight:Destroy()
        targetHighlight = nil
    end
    -- Повертаємо звичайну прозорість для всіх ESP боксів
    for _, box in pairs(espBoxes) do
        if box then box.Transparency = 0.5 end
    end
end

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then 
        if currentTarget then
            removeHighlight()
            currentTarget = nil
        end
        return 
    end

    local closestDist = 220
    local bestTargetPart = nil
    local bestTargetPlayer = nil

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")

            if root and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
                if onScreen then
                    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                    local screenPos = Vector2.new(pos.X, pos.Y)
                    local dist = (screenPos - mousePos).Magnitude

                    if dist < closestDist then
                        if not isWallBetween(Camera.CFrame.Position, root.Position, char) then
                            closestDist = dist
                            bestTargetPart = root
                            bestTargetPlayer = player
                        end
                    end
                end
            end
        end
    end

    -- Логіка підсвічування (Highlight)
    if bestTargetPart then
        local targetChar = bestTargetPart.Parent
        
        if currentTarget ~= targetChar then
            removeHighlight()
            currentTarget = targetChar

            -- Створюємо гарний ніжний Highlight на ворога
            targetHighlight = Instance.new("Highlight")
            targetHighlight.Name = "SoftHubHighlight"
            targetHighlight.FillColor = Color3.fromRGB(255, 120, 255)
            targetHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            targetHighlight.FillTransparency = 0.5
            targetHighlight.OutlineTransparency = 0.1
            targetHighlight.Adornee = targetChar
            targetHighlight.Parent = targetChar
        end
        
        -- Робимо ESP бокс поточної цілі яскравішим
        if bestTargetPlayer and espBoxes[bestTargetPlayer] then
            espBoxes[bestTargetPlayer].Transparency = 0.15
        end

        -- Плавне наведення на Хітбокс
        local targetPos = bestTargetPart.Position + Vector3.new(0, 0.5, 0) -- ідеально в район шиї/голови
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(Camera.CFrame.Position, targetPos), 
            aimSmoothness
        )
    else
        if currentTarget then
            removeHighlight()
            currentTarget = nil
        end
    end
end)

print("Soft Hub loaded successfully! | Right Shift to open")
