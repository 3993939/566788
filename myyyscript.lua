--[[
    ULTIMATE ENGINE v8.0 (FULL REWORK)
    - Аімбот (3 режими: Голова / Торс / Рандом)
    - Рандомізація наводки
    - ESP (Обводка гравця + Ім'я + Здоров'я)
    - Баніхоп (Авто-стрибки)
    - Вкладки: Aimbot | ESP | BHop
    - Меню: [RightShift]
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ОЧИСТКА
if CoreGui:FindFirstChild("UltimateEngine_UI") then
    CoreGui.UltimateEngine_UI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateEngine_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ========== НАЛАШТУВАННЯ ==========
local Settings = {
    -- Aimbot
    Aimbot = true,
    AimPart = 1, -- 1=Head, 2=Torso, 3=Random
    AimSpeed = 0.15,
    AimFOV = 150,
    AimRandom = 0.05,
    AimTeamCheck = true,
    -- ESP
    ESP = true,
    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    ESPTeamCheck = true,
    -- BHop
    BHop = false,
    BHopSpeed = 16.2,
}

-- ========== FOV КОЛО ==========
local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, Settings.AimFOV * 2, 0, Settings.AimFOV * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.ZIndex = 0
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 60, 90)
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.3
FOVStroke.Parent = FOVCircle

local function UpdateFOV()
    FOVCircle.Size = UDim2.new(0, Settings.AimFOV * 2, 0, Settings.AimFOV * 2)
end

-- ========== МЕНЮ ==========
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 440, 0, 340)
Main.Position = UDim2.new(0.5, -220, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Main.BackgroundTransparency = 0.2
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 60, 90)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3
MainStroke.Parent = Main

-- TOP BAR
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -15, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ULTIMATE ENGINE v8.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- ВКЛАДКИ (TABS)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 90, 1, -45)
TabBar.Position = UDim2.new(0, 8, 0, 40)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 4)
TabLayout.Parent = TabBar

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -110, 1, -45)
Container.Position = UDim2.new(0, 102, 0, 40)
Container.BackgroundTransparency = 1
Container.Parent = Main

local Tabs = {}
local TabButtons = {}

local function CreateTab(name)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 60, 90)
    scroll.Visible = false
    scroll.Parent = Container

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 155, 170)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = TabBar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for tName, tabObj in pairs(Tabs) do tabObj.Visible = (tName == name) end
        for tName, bObj in pairs(TabButtons) do
            bObj.BackgroundColor3 = (tName == name) and Color3.fromRGB(255, 60, 90) or Color3.fromRGB(22, 24, 32)
            bObj.TextColor3 = (tName == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 155, 170)
        end
    end)

    Tabs[name] = scroll
    TabButtons[name] = btn
    return scroll
end

local AimbotTab = CreateTab("Aimbot")
local ESPTab = CreateTab("ESP")
local BHopTab = CreateTab("BHop")

Tabs["Aimbot"].Visible = true
TabButtons["Aimbot"].BackgroundColor3 = Color3.fromRGB(255, 60, 90)
TabButtons["Aimbot"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ========== UI КОМПОНЕНТИ ==========
local function AddToggle(parent, text, default, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -6, 0, 32)
    card.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    card.BackgroundTransparency = 0.4
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 225, 235)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 34, 0, 16)
    btn.Position = UDim2.new(1, -40, 0.5, -8)
    btn.BackgroundColor3 = default and Color3.fromRGB(255, 60, 90) or Color3.fromRGB(45, 48, 60)
    btn.Text = ""
    btn.Parent = card

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(255, 60, 90) or Color3.fromRGB(45, 48, 60)
        callback(state)
    end)
end

local function AddSlider(parent, text, min, max, default, isFloat, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -6, 0, 40)
    card.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    card.BackgroundTransparency = 0.4
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 16)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. tostring(default)
    lbl.TextColor3 = Color3.fromRGB(220, 225, 235)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -16, 0, 4)
    track.Position = UDim2.new(0, 8, 1, -10)
    track.BackgroundColor3 = Color3.fromRGB(45, 48, 60)
    track.Parent = card

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 60, 90)
    fill.Parent = track

    local dragging = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local rawVal = min + (max - min) * pos
        local val = isFloat and math.floor(rawVal * 100) / 100 or math.floor(rawVal)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        lbl.Text = text .. ": " .. tostring(val)
        callback(val)
    end

    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true Update(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

local function AddSelector(parent, text, options, defaultIndex, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -6, 0, 34)
    card.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    card.BackgroundTransparency = 0.4
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 225, 235)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 20)
    btn.Position = UDim2.new(1, -96, 0.5, -10)
    btn.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
    btn.Text = options[defaultIndex]
    btn.TextColor3 = Color3.fromRGB(255, 60, 90)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.Parent = card

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn

    local currentIndex = defaultIndex
    btn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then currentIndex = 1 end
        btn.Text = options[currentIndex]
        callback(currentIndex)
    end)
end

-- ========== ЗАПОВНЕННЯ ВКЛАДКИ AIMBOT ==========
AddToggle(AimbotTab, "Enable Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
AddSelector(AimbotTab, "Aim Part", {"Head", "Torso", "Random"}, Settings.AimPart, function(idx)
    Settings.AimPart = idx
end)
AddSlider(AimbotTab, "Aim Speed", 0.01, 0.5, Settings.AimSpeed, true, function(v) Settings.AimSpeed = v end)
AddSlider(AimbotTab, "FOV Radius", 30, 400, Settings.AimFOV, false, function(v)
    Settings.AimFOV = v
    UpdateFOV()
end)
AddSlider(AimbotTab, "Randomization", 0, 0.2, Settings.AimRandom, true, function(v) Settings.AimRandom = v end)
AddToggle(AimbotTab, "Team Check", Settings.AimTeamCheck, function(v) Settings.AimTeamCheck = v end)

-- ========== ЗАПОВНЕННЯ ВКЛАДКИ ESP ==========
AddToggle(ESPTab, "Enable ESP", Settings.ESP, function(v) Settings.ESP = v end)
AddToggle(ESPTab, "Box Outline", Settings.ESPBox, function(v) Settings.ESPBox = v end)
AddToggle(ESPTab, "Player Name", Settings.ESPName, function(v) Settings.ESPName = v end)
AddToggle(ESPTab, "Health Bar", Settings.ESPHealth, function(v) Settings.ESPHealth = v end)
AddToggle(ESPTab, "Team Check", Settings.ESPTeamCheck, function(v) Settings.ESPTeamCheck = v end)

-- ========== ЗАПОВНЕННЯ ВКЛАДКИ BHop ==========
AddToggle(BHopTab, "Enable BHop", Settings.BHop, function(v) Settings.BHop = v end)
AddSlider(BHopTab, "Walk Speed", 10, 30, Settings.BHopSpeed, false, function(v)
    Settings.BHopSpeed = v
end)

-- ========== ОСНОВНА ЛОГІКА АІМБОТА ==========
local function GetTargetPart(char)
    if Settings.AimPart == 1 then
        return char:FindFirstChild("Head")
    elseif Settings.AimPart == 2 then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    elseif Settings.AimPart == 3 then
        local parts = {}
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        if head then table.insert(parts, head) end
        if torso then table.insert(parts, torso) end
        return #parts > 0 and parts[math.random(1, #parts)] or nil
    end
    return char:FindFirstChild("Head")
end

local function GetClosestPlayer()
    local bestTarget = nil
    local shortestDist = Settings.AimFOV
    local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.AimTeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team then
                continue
            end

            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local part = GetTargetPart(char)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            bestTarget = part
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

RunService.RenderStepped:Connect(function()
    if not Settings.Aimbot then return end

    local target = GetClosestPlayer()
    if target then
        local targetPos = target.Position

        -- Рандомізація
        if Settings.AimRandom > 0 then
            local r = Settings.AimRandom * 8
            targetPos = targetPos + Vector3.new(
                math.random(-r, r) / 10,
                math.random(-r, r) / 10,
                math.random(-r, r) / 10
            )
        end

        local targetCF = CFrame.new(Camera.CFrame.Position, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, Settings.AimSpeed)
    end
end)

-- ========== ESP (ОБВОДКА ГРАВЦЯ) ==========
local ESPObjects = {}

local function CreateESP(player)
    if ESPObjects[player] then return end

    -- Основа (бокс)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 50, 0, 70)
    box.BackgroundColor3 = Color3.fromRGB(255, 60, 90)
    box.BackgroundTransparency = 0.7
    box.BorderSizePixel = 0
    box.Visible = false
    box.ZIndex = 3
    box.Parent = ScreenGui

    -- 4 кути для обводки
    local corners = {}
    for i = 1, 4 do
        local corner = Instance.new("Frame")
        corner.Size = UDim2.new(0, 8, 0, 8)
        corner.BackgroundColor3 = Color3.fromRGB(255, 60, 90)
        corner.BackgroundTransparency = 0.2
        corner.BorderSizePixel = 0
        corner.Parent = box

        if i == 1 then
            corner.Position = UDim2.new(0, 0, 0, 0)
        elseif i == 2 then
            corner.Position = UDim2.new(1, -8, 0, 0)
        elseif i == 3 then
            corner.Position = UDim2.new(0, 0, 1, -8)
        elseif i == 4 then
            corner.Position = UDim2.new(1, -8, 1, -8)
        end
        corners[i] = corner
    end

    -- Ім'я
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 16)
    nameLabel.Position = UDim2.new(0, 0, 1, 2)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 10
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = box

    -- Здоров'я
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 0, 4)
    healthBar.Position = UDim2.new(0, 0, 1, -4)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.Parent = box

    ESPObjects[player] = {
        Box = box,
        Name = nameLabel,
        Health = healthBar,
        Corners = corners
    }
end

local function UpdateESP()
    for player, data in pairs(ESPObjects) do
        local char = player.Character
        local isTeam = Settings.ESPTeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team

        if Settings.ESP and not isTeam and char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            if root then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    data.Box.Visible = true
                    data.Box.Position = UDim2.new(0, pos.X - 25, 0, pos.Y - 35)

                    -- Оновлення здоров'я
                    if Settings.ESPHealth then
                        local hp = char.Humanoid.Health / char.Humanoid.MaxHealth
                        data.Health.Size = UDim2.new(math.clamp(hp, 0, 1), 0, 0, 4)
                        data.Health.BackgroundColor3 = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
                        data.Health.Visible = true
                    else
                        data.Health.Visible = false
                    end

                    data.Name.Visible = Settings.ESPName
                    for _, corner in ipairs(data.Corners) do
                        corner.Visible = Settings.ESPBox
                    end
                else
                    data.Box.Visible = false
                end
            end
        else
            data.Box.Visible = false
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        CreateESP(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        ESPObjects[player].Box:Destroy()
        ESPObjects[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.ESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not ESPObjects[player] then
                CreateESP(player)
            end
        end
        UpdateESP()
    else
        for _, data in pairs(ESPObjects) do
            data.Box.Visible = false
        end
    end
end)

-- ========== БАНІХОП ==========
local function BHop()
    if not Settings.BHop then return end

    local char = LocalPlayer.Character
    if not char then return end

    local humanoid = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root then return end

    -- Встановлюємо швидкість
    humanoid.WalkSpeed = Settings.BHopSpeed

    -- Авто-стрибки
    if humanoid:GetState() == Enum.HumanoidStateType.Freefall or humanoid:GetState() == Enum.HumanoidStateType.Jumping then
        return
    end

    if root.AssemblyLinearVelocity.Y > 0.1 then
        return
    end

    humanoid.Jump = true
end

RunService.Heartbeat:Connect(function()
    BHop()
end)

-- ========== ВІДКРИТТЯ/ЗАКРИТТЯ МЕНЮ ==========
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
        if not Main.Visible then
            FOVCircle.Visible = false
        else
            FOVCircle.Visible = true
        end
    end
end)

print("✅ ULTIMATE ENGINE v8.0 ЗАВАНТАЖЕНО!")
print("📌 МЕНЮ: ПРАВИЙ SHIFT")
