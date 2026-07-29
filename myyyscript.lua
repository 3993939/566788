--[[
    ENGINE v8.2 // REWRITTEN FROM SCRATCH
    - Aimbot: Fixed Smooth Aim (Head, Torso, Dynamic Body-Roaming Randomization)
    - ESP: Reliable Highlight Chams + Clean Name Labels
    - Misc: Physics-Based BunnyHop
    - Clean Modular Structure
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Очистка старих інтерфейсів
if CoreGui:FindFirstChild("EngineV8_UI") then
    CoreGui.EngineV8_UI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EngineV8_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ========== НАЛАШТУВАННЯ ==========
local Settings = {
    -- Aimbot
    Aimbot = true,
    AimPartMode = 1, -- 1 = Head, 2 = Torso, 3 = Random Dynamic
    AimSpeed = 0.2,  -- Плавність (0.01 .. 1)
    AimFOV = 120,
    AimTeamCheck = true,
    
    -- ESP
    ESP = true,
    ESPChams = true,
    ESPNames = true,
    ESPTeamCheck = true,
    
    -- Misc
    BHop = true,
    
    -- Visuals
    ShowFOV = true
}

local AimPartsList = {"Head", "Torso", "Random Dynamic"}
local DynamicParts = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm"}

-- ========== FOV CIRCLE ==========
local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.Size = UDim2.new(0, Settings.AimFOV * 2, 0, Settings.AimFOV * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = Settings.ShowFOV
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 60, 90)
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.2
FOVStroke.Parent = FOVCircle

local function UpdateFOVSize()
    FOVCircle.Size = UDim2.new(0, Settings.AimFOV * 2, 0, Settings.AimFOV * 2)
end

-- ========== ГОЛОВНИЙ ІНТЕРФЕЙС ==========
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 480, 0, 340)
Main.Position = UDim2.new(0.5, -240, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
Main.BackgroundTransparency = 0.15
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 60, 90)
MainStroke.Thickness = 1.5
MainStroke.Parent = Main

-- TopBar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -15, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ENGINE v8.2 // REWRITTEN"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- TabBar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 100, 1, -45)
TabBar.Position = UDim2.new(0, 8, 0, 40)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 4)
TabLayout.Parent = TabBar

-- Container
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -122, 1, -45)
Container.Position = UDim2.new(0, 114, 0, 40)
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
    layout.Padding = UDim.new(0, 6)
    layout.Parent = scroll
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
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
local MiscTab = CreateTab("Misc")
local VisualsTab = CreateTab("Visuals")

Tabs["Aimbot"].Visible = true
TabButtons["Aimbot"].BackgroundColor3 = Color3.fromRGB(255, 60, 90)
TabButtons["Aimbot"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- UI HELPERS
local function AddToggle(parent, text, default, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -6, 0, 32)
    card.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 4)
    cardCorner.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
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
    card.Size = UDim2.new(1, -6, 0, 42)
    card.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 4)
    cardCorner.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 16)
    lbl.Position = UDim2.new(0, 8, 0, 4)
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
    card.Size = UDim2.new(1, -6, 0, 32)
    card.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 4)
    cardCorner.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 225, 235)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 20)
    btn.Position = UDim2.new(1, -126, 0.5, -10)
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

-- НАПОВНЕННЯ ВКЛАДОК
AddToggle(AimbotTab, "Enable Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
AddSelector(AimbotTab, "Aim Target Part", AimPartsList, Settings.AimPartMode, function(idx) Settings.AimPartMode = idx end)
AddSlider(AimbotTab, "Aim Smooth Speed", 0.05, 1, Settings.AimSpeed, true, function(v) Settings.AimSpeed = v end)
AddSlider(AimbotTab, "Aim FOV Radius", 30, 400, Settings.AimFOV, false, function(v) 
    Settings.AimFOV = v 
    UpdateFOVSize()
end)
AddToggle(AimbotTab, "Aim Team Check", Settings.AimTeamCheck, function(v) Settings.AimTeamCheck = v end)

AddToggle(ESPTab, "Enable ESP", Settings.ESP, function(v) Settings.ESP = v end)
AddToggle(ESPTab, "Player Chams (Highlight)", Settings.ESPChams, function(v) Settings.ESPChams = v end)
AddToggle(ESPTab, "Player Names", Settings.ESPNames, function(v) Settings.ESPNames = v end)
AddToggle(ESPTab, "ESP Team Check", Settings.ESPTeamCheck, function(v) Settings.ESPTeamCheck = v end)

AddToggle(MiscTab, "Auto BunnyHop", Settings.BHop, function(v) Settings.BHop = v end)

AddToggle(VisualsTab, "Show FOV Circle", Settings.ShowFOV, function(v) 
    Settings.ShowFOV = v 
    FOVCircle.Visible = v 
end)

-- ========== МОДУЛЬ AIMBOT ==========
local lastRandomSwitch = 0
local currentRandomPartName = "Head"

local function GetAimTargetPart(char)
    if not char then return nil end
    
    if Settings.AimPartMode == 1 then
        return char:FindFirstChild("Head")
    elseif Settings.AimPartMode == 2 then
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    elseif Settings.AimPartMode == 3 then
        -- Динамічна рандомізація (кожні 0.15 сек змінює частину тіла для плавного «водіння»)
        if tick() - lastRandomSwitch > 0.15 then
            lastRandomSwitch = tick()
            currentRandomPartName = DynamicParts[math.random(1, #DynamicParts)]
        end
        return char:FindFirstChild(currentRandomPartName) or char:FindFirstChild("Head")
    end
    return char:FindFirstChild("Head")
end

local function GetClosestTargetPart()
    local bestPart = nil
    local shortestDistance = Settings.AimFOV
    local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.AimTeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team then continue end

            local char = player.Character
            if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                local targetPart = GetAimTargetPart(char)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            bestPart = targetPart
                        end
                    end
                end
            end
        end
    end
    return bestPart
end

-- Обробник наведення (RenderStepped забезпечує максимальну плавності прицілу)
RunService.RenderStepped:Connect(function(dt)
    if Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetPart = GetClosestTargetPart()
        if targetPart then
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPart.Position)
            local alpha = math.clamp(Settings.AimSpeed * (dt * 60), 0.01, 1)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, alpha)
        end
    end
end)

-- ========== МОДУЛЬ BUNNYHOP ==========
RunService.Heartbeat:Connect(function()
    if Settings.BHop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- ========== МОДУЛЬ ESP (CHAMS + NAMES) ==========
local ESPHolder = {}

local function RemovePlayerESP(player)
    if ESPHolder[player] then
        if ESPHolder[player].NameLabel then
            ESPHolder[player].NameLabel:Destroy()
        end
        ESPHolder[player] = nil
    end
end

local function CreatePlayerESP(player)
    RemovePlayerESP(player)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.Text = player.Name
    label.Visible = false
    label.Parent = ScreenGui

    ESPHolder[player] = { NameLabel = label }
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not ESPHolder[player] then 
                CreatePlayerESP(player) 
            end

            local data = ESPHolder[player]
            local char = player.Character
            local isTeam = Settings.ESPTeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team
            local isAlive = char and char:FindFirstChild("Head") and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0

            if Settings.ESP and not isTeam and isAlive then
                -- 1. Highlight Chams (Надійне обведення крізь стіни)
                local hl = char:FindFirstChild("EngineV8_Cham")
                if Settings.ESPChams then
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "EngineV8_Cham"
                        hl.Adornee = char
                        hl.FillColor = Color3.fromRGB(255, 60, 90)
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = char
                    end
                    hl.Enabled = true
                elseif hl then
                    hl.Enabled = false
                end

                -- 2. ESP Names
                if Settings.ESPNames then
                    local headPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 1.5, 0))
                    if onScreen then
                        data.NameLabel.Position = UDim2.new(0, headPos.X - 50, 0, headPos.Y)
                        data.NameLabel.Size = UDim2.new(0, 100, 0, 15)
                        data.NameLabel.Visible = true
                    else
                        data.NameLabel.Visible = false
                    end
                else
                    data.NameLabel.Visible = false
                end
            else
                -- Вимкнення, якщо гравець мертвий/в команді/ESP вимкнено
                if char and char:FindFirstChild("EngineV8_Cham") then
                    char.EngineV8_Cham.Enabled = false
                end
                if data and data.NameLabel then
                    data.NameLabel.Visible = false
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(RemovePlayerESP)

-- Перемикання меню [RightShift]
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)
