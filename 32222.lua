--== [ SOFT HUB - FIXED LAYOUT ] ==--
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
local aimSmoothness = 0.17     -- Значення з твого скріншоту
local wallCheck = true

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

-- === ГОЛОВНЕ ВІКНО ===
local mainFrame = Instance.new("Frame")
-- Трохи збільшив вікно, щоб усім кнопкам було просторо
mainFrame.Size = UDim2.new(0, 480, 0, 360) 
mainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false -- Спочатку сховане
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

-- Заголовок
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

-- === УНІВЕРСАЛЬНА ФУНКЦІЯ СТВОРЕННЯ КНОПОК ===
local function createToggleButton(text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 50) -- Гарний розмір, як на фото
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Трохи світліше сірий
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text -- Одразу ставимо правильний текст
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12) -- М'яке заокруглення
    c.Parent = btn
    
    btn.Parent = mainFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- ========================================================
-- === СТВОРЕННЯ ТА РОЗМІЩЕННЯ ЕЛЕМЕНТІВ (FIXED) ===
-- ========================================================

-- РЯДОК 1
local aimToggle = createToggleButton("✓ Aimbot (ON)", UDim2.new(0, 30, 0, 80), function()
    aimbotEnabled = not aimbotEnabled
    aimToggle.Text = aimbotEnabled and "✓ Aimbot (ON)" or "✗ Aimbot (OFF)"
    aimToggle.TextColor3 = aimbotEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
end)

local espToggle = createToggleButton("✓ ESP (ON)", UDim2.new(0, 250, 0, 80), function()
    espEnabled = not espEnabled
    espToggle.Text = espEnabled and "✓ ESP (ON)" or "✗ ESP (OFF)"
    espToggle.TextColor3 = espEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
    for _, box in pairs(espBoxes) do
        if box then box.Visible = espEnabled end
    end
end)

-- РЯДОК 2 (Кнопка Wall Check тепер стоїть рівно під Aimbot)
local wallToggle = createToggleButton("✓ Wall Check (ON)", UDim2.new(0, 30, 0, 145), function()
    wallCheck = not wallCheck
    wallToggle.Text = wallCheck and "✓ Wall Check (ON)" or "✗ Wall Check (OFF)"
    wallToggle.TextColor3 = wallCheck and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,150)
end)

-- ІНФО-ЛАЙБЕЛ (Текст швидкості)
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 420, 0, 30)
speedLabel.Position = UDim2.new(0, 35, 0, 215) -- Чітко над кнопками швидкості
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Aim Smoothness: " .. string.format("%.2f", aimSmoothness) .. " (Lower = Faster)"
speedLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
speedLabel.TextSize = 15
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Font = Enum.Font.GothamMedium
speedLabel.Parent = mainFrame

-- РЯДОК 3 (Кнопки швидкості)
local speedMinus = createToggleButton("- Повільніше", UDim2.new(0, 30, 0, 255), function()
    aimSmoothness = math.clamp(aimSmoothness + 0.02, 0.05, 0.50)
    speedLabel.Text = "Aim Smoothness: " .. string.format("%.2f", aimSmoothness) .. " (Lower = Faster)"
end)

local speedPlus = createToggleButton("+ Швидше", UDim2.new(0, 250, 0, 255), function()
    aimSmoothness = math.clamp(aimSmoothness - 0.02, 0.05, 0.50)
    speedLabel.Text = "Aim Smoothness: " .. string.format("%.2f", aimSmoothness) .. " (Lower = Faster)"
end)

-- ========================================================
-- === ЛОГІКА (ГРАДІЄНТ, ESP, AIMBOT) ===
-- ========================================================

-- Анімація меню
local function animateGUI(state)
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = state and 0.15 or 1}):Play()
end

-- Відкриття меню на Right Shift
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then animateGUI(true) end
    end
end)

-- Пастельний градієнт
local hue = 0
RunService.RenderStepped:Connect(function(dt)
    hue = (hue + 0.04 * dt) % 1
    rainbowColor = Color3.fromHSV(hue, 0.6, 0.8) -- Гарні пастельні кольори
    mainFrame.BackgroundColor3 = rainbowColor
end)

-- --- ESP ---
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
        box.Color3 = Color3.fromRGB(255, 255, 255) -- Білий ESP
        box.Visible = espEnabled
        box.Parent = screenGui
        espBoxes[player] = box
    end
    if player.Character then applyESP(player.Character) end
    player.CharacterAdded:Connect(applyESP)
    player.CharacterRemoving:Connect(function()
        if espBoxes[player] then espBoxes[player]:Destroy(); espBoxes[player] = nil end
    end)
end
for _, plr in pairs(Players:GetPlayers()) do createESP(plr) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(plr)
    if espBoxes[plr] then espBoxes[plr]:Destroy(); espBoxes[plr] = nil end
end)

-- --- AIMBOT & WALLCHECK ---
local function isWallBetween(origin, targetPos, targetCharacter)
    if not wallCheck then return false end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    raycastParams.IgnoreWater = true
    local direction = targetPos - origin
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    return raycastResult ~= nil -- Якщо є результат, значить є перешкода
end

RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    local closestDist = 250
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
                        bestTargetPart = root
                    end
                end
            end
        end
    end
    if bestTargetPart then
        local targetPos = bestTargetPart.Position + Vector3.new(0, 0.5, 0)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), aimSmoothness)
    end
end)

print("Soft Hub Fixed Layout Loaded! | Right Shift")
