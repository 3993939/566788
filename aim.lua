--[[
    Arsenal ULTIMATE CHEAT v1 - Colin Edition
    Можливості:
    - Aimbot (автонаведення, натискай RMB або автоматично)
    - Triggerbot (автостріл коли ворог під прицілом)
    - ESP (бокси, лінії, здоров'я, зброя)
    - No Recoil / No Spread / Infinite Ammo
    - Налаштування через GUI
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Налаштування (можна міняти через GUI)
local settings = {
    enabled = true,
    aimbot = true,
    aimbotKey = "RightButton", -- "RightButton" (ПКМ), або "LeftAlt", "None"(автоматично)
    aimbotFOV = 150, -- кут огляду для aimbot (чим менше, тим точніше)
    aimbotSmooth = 5, -- плавність (1 = миттєво, 10 = плавно)
    aimPart = "Head", -- "Head", "HumanoidRootPart", "Torso"
    triggerbot = true,
    triggerDelay = 0.05, -- затримка перед пострілом в секундах
    esp = true,
    espBoxes = true,
    espLines = true,
    espHealth = true,
    espWeapon = true,
    espDistance = 350, -- дальність відображення ESP
    noRecoil = true,
    noSpread = true,
    infiniteAmmo = true,
    showMenu = true
}

-- Створюємо GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArsenalCheat"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Title.Text = "ARSENAL ULTIMATE v1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local function MakeButton(text, ypos, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, ypos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
    Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
    Instance.new("UICorner").Parent = btn
    btn.MouseButton1Click:Connect(onClick)
    return btn
end

local function MakeSlider(text, ypos, minVal, maxVal, onChange)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.9, 0, 0, 25)
    title.Position = UDim2.new(0.05, 0, 0, ypos)
    title.BackgroundTransparency = 1
    title.Text = text .. ": " .. settings[text]
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.Gotham
    title.Parent = MainFrame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.9, 0, 0, 10)
    slider.Position = UDim2.new(0.05, 0, 0, ypos + 25)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    slider.Parent = MainFrame
    Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
    Instance.new("UICorner").Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((settings[text] - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    fill.Parent = slider
    Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
    Instance.new("UICorner").Parent = fill
    
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    slider.MouseMoved:Connect(function()
        if dragging then
            local pos = (Mouse.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
            local value = math.clamp(minVal + pos * (maxVal - minVal), minVal, maxVal)
            value = tonumber(string.format("%.1f", value))
            settings[text] = value
            title.Text = text .. ": " .. value
            fill.Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0)
            if onChange then onChange(value) end
        end
    end)
end

-- Кнопки вмикання/вимикання функцій
local function MakeToggle(text, ypos)
    local state = settings[text]
    local btn = MakeButton(text .. ": ON", ypos, function()
        state = not state
        settings[text] = state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        if text == "showMenu" then MainFrame.Visible = state end
    end)
    btn.Text = text .. ": " .. (state and "ON" or "OFF")
    return btn
end

MakeToggle("enabled", 50)
MakeToggle("aimbot", 95)
MakeToggle("triggerbot", 140)
MakeToggle("esp", 185)
MakeToggle("noRecoil", 230)
MakeToggle("noSpread", 275)
MakeToggle("infiniteAmmo", 320)
MakeToggle("showMenu", 365)

MakeSlider("aimbotFOV", 420, 30, 360, function(v) end)
MakeSlider("aimbotSmooth", 475, 1, 15, function(v) end)

-- Закриття меню
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.1, 0, 0, 25)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    settings.showMenu = false
end)

-- Гаряча клавіша для меню (Insert)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        settings.showMenu = not settings.showMenu
        MainFrame.Visible = settings.showMenu
        if settings.showMenu then
            MakeToggle("showMenu", 365)
        end
    end
end)

-- Функція для отримання найближчого ворога
local function GetClosestEnemy()
    local closest = nil
    local closestDist = settings.aimbotFOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local part = player.Character:FindFirstChild(settings.aimPart) or player.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- Aimbot
RunService.RenderStepped:Connect(function()
    if not settings.enabled or not settings.aimbot then return end
    
    local aimKey = settings.aimbotKey
    local shouldAim = false
    if aimKey == "RightButton" then
        shouldAim = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif aimKey == "LeftAlt" then
        shouldAim = UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
    else
        shouldAim = true -- автоматичний режим
    end
    
    if shouldAim then
        local target = GetClosestEnemy()
        if target and target.Character then
            local part = target.Character:FindFirstChild(settings.aimPart) or target.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local screenPos = Camera:WorldToScreenPoint(part.Position)
                if screenPos.Z > 0 then
                    local targetPos = Vector2.new(screenPos.X, screenPos.Y)
                    local currentPos = Vector2.new(Mouse.X, Mouse.Y)
                    local newPos = currentPos:Lerp(targetPos, 1 / settings.aimbotSmooth)
                    mousemoveabs(newPos.X, newPos.Y)
                end
            end
        end
    end
end)

-- Triggerbot
RunService.RenderStepped:Connect(function()
    if not settings.enabled or not settings.triggerbot then return end
    
    local target = getMouse().Target
    if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
        local player = Players:GetPlayerFromCharacter(target.Parent)
        if player and player ~= LocalPlayer then
            task.wait(settings.triggerDelay)
            Mouse1Click()
        end
    end
end)

-- ESP
local espObjects = {}
local function CreateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not espObjects[player] then
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(3, 5, 2)
                box.Color3 = player.TeamColor and player.TeamColor.Color or Color3.fromRGB(255, 0, 0)
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Adornee = player.Character
                box.Parent = Camera
                
                local line = Instance.new("SelectionBox")
                line.Adornee = player.Character
                line.Color3 = Color3.fromRGB(255, 255, 255)
                line.Transparency = 0.5
                line.Parent = Camera
                
                espObjects[player] = {box, line}
            end
        end
    end
    
    for player, objects in pairs(espObjects) do
        if not player.Character or not player.Parent then
            for _, obj in ipairs(objects) do obj:Destroy() end
            espObjects[player] = nil
        end
    end
end

if settings.esp then
    game:GetService("RunService").Heartbeat:Connect(CreateESP)
end

-- No Recoil / No Spread
if settings.noRecoil or settings.noSpread then
    local oldRecoil = getrawmetatable and getrawmetatable(game).__index or nil
    if oldRecoil then
        setreadonly(oldRecoil, false)
        local recoilSettings = {
            CameraRecoil = 0,
            CameraRecoilRight = 0,
            Recoil = 0,
            RecoilRight = 0
        }
        for k, v in pairs(recoilSettings) do
            oldRecoil[k] = v
        end
        setreadonly(oldRecoil, true)
    end
end

-- Infinite Ammo
if settings.infiniteAmmo then
    LocalPlayer.CharacterAdded:Connect(function(char)
        local backpack = LocalPlayer.Backpack
        backpack.ChildAdded:Connect(function(tool)
            tool:FindFirstChild("Ammo").Value = 999
        end)
    end)
end

print("Arsenal Ultimate v1 loaded - Use Insert to toggle menu")
