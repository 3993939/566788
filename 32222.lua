--== [ SOFT AIM + ESP + BEAUTIFUL PASTEL GUI ] ==--
-- АКТИВАЦІЯ / ЗГОРТАННЯ: ПРАВИЙ SHIFT

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Перевірка на наявність UI, щоб не створювати дублікати
local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("SoftHub")
if oldGui then oldGui:Destroy() end

-- Створення GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoftHub"
screenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(screenGui) end
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 200)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -100)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Заокруглення для краси
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

-- Анімація появи/зникнення UI
local function animateGUI(state)
    local goal = {BackgroundTransparency = state and 0.15 or 1}
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tween:Play()
end

-- Заголовок меню
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "⋆⫸ SOFT HUB ⫷⋆"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Налаштування тіні/світіння тексту для стилю
local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(0, 0, 0)
titleStroke.Thickness = 1.5
titleStroke.Parent = title

-- Кнопка керування Аімом
local aimToggle = Instance.new("TextButton")
aimToggle.Size = UDim2.new(0, 170, 0, 45)
aimToggle.Position = UDim2.new(0, 30, 0, 80)
aimToggle.Text = "✓ Aimbot (ON)"
aimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
aimToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
aimToggle.BackgroundTransparency = 0.4
aimToggle.TextSize = 16
aimToggle.Font = Enum.Font.GothamMedium
local cornerBtn1 = Instance.new("UICorner")
cornerBtn1.CornerRadius = UDim.new(0, 10)
cornerBtn1.Parent = aimToggle
aimToggle.Parent = mainFrame

-- Кнопка керування ESP
local espToggle = Instance.new("TextButton")
espToggle.Size = UDim2.new(0, 170, 0, 45)
espToggle.Position = UDim2.new(0, 220, 0, 80)
espToggle.Text = "✓ ESP (ON)"
espToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
espToggle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
espToggle.BackgroundTransparency = 0.4
espToggle.TextSize = 16
espToggle.Font = Enum.Font.GothamMedium
local cornerBtn2 = Instance.new("UICorner")
cornerBtn2.CornerRadius = UDim.new(0, 10)
cornerBtn2.Parent = espToggle
espToggle.Parent = mainFrame

local aimbotEnabled = true
local espEnabled = true
local espBoxes = {}

-- Логіка кнопок
aimToggle.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimToggle.Text = aimbotEnabled and "✓ Aimbot (ON)" or "✗ Aimbot (OFF)"
    aimToggle.TextColor3 = aimbotEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
end)

espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espToggle.Text = espEnabled and "✓ ESP (ON)" or "✗ ESP (OFF)"
    espToggle.TextColor3 = espEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    for _, box in pairs(espBoxes) do
        if box then box.Visible = espEnabled end
    end
end)

-- Відкриття/Закриття меню на Right Shift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
        if mainFrame.Visible then animateGUI(true) end
    end
end)

-- ===== НІЖНЕ ПЕРЕЛИВАННЯ КОЛЬОРІВ (Ніжний пастельний градієнт) =====
local hue = 0
RunService.RenderStepped:Connect(function(deltaTime)
    -- Швидкість зміни кольору (0.05 — дуже плавно і ніжно)
    hue = (hue + (0.05 * deltaTime)) % 1
    -- Насиченість 0.5 та яскравість 0.7 роблять кольори саме пастельними, а не кислотними
    local rainbowColor = Color3.fromHSV(hue, 0.5, 0.7) 
    mainFrame.BackgroundColor3 = rainbowColor
    
    -- Оновлення кольору ESP Box, якщо увімкнено
    if espEnabled then
        for _, box in pairs(espBoxes) do
            if box and box:IsA("BoxHandleAdornment") then
                box.Color3 = rainbowColor
            end
        end
    end
end)

-- ===== ESP СИСТЕМA =====
local function createESP(player)
    if player == LocalPlayer then return end
    
    local function applyESP(character)
        local root = character:WaitForChild("HumanoidRootPart", 5)
        if not root then return end
        
        -- Створюємо Box
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESP_" .. player.Name
        box.Size = Vector3.new(4, 6, 4) -- Оптимальний розмір під хітбокс персонажа
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.6 -- М'яка прозорість, щоб не сліпило
        box.Adornee = character
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

Players.PlayerAdded:Connect(createESP)
for _, player in pairs(Players:GetPlayers()) do createESP(player) end

Players.PlayerRemoving:Connect(function(player)
    if espBoxes[player] then
        espBoxes[player]:Destroy()
        espBoxes[player] = nil
    end
end)

-- ===== AUTOMATIC AIMBOT (Плавний софт-аїм) =====
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    
    local target = nil
    local closestDist = 250 -- Радіус захоплення цілі (FOV)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            -- Перевірка чи гравець живий
            if player.Character.Humanoid.Health > 0 then
                local rootPart = player.Character.HumanoidRootPart
                local pos, onScreen = Camera:WorldToScreenPoint(rootPart.Position)
                
                if onScreen then
                    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                    local screenPos = Vector2.new(pos.X, pos.Y)
                    local dist = (screenPos - mousePos).Magnitude
                    
                    if dist < closestDist then
                        closestDist = dist
                        target = rootPart
                    end
                end
            end
        end
    end
    
    -- Плавне наведення на ціль (без різких сіпань камери)
    if target then
        local targetPos = target.Position + Vector3.new(0, 1, 0) -- Трохи вище за Хітбокс (ближче до голови)
        -- Коефіцієнт плавности (0.15 — софтово, камера м'яко "липне" до гравця)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), 0.15)
    end
end)
