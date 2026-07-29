--[[
    REWRITTEN ENGINE v6.0 (NO RMB NO BS)
    - Аім працює завжди (без затискання ПКМ)
    - 3 режими Аімбота (Camera, Mouse, FOVOriented)
    - Налаштування швидкості та Team Check
    - ESP Silhouette (Highlight) + Ніки
    - Меню: [RightShift]
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("UltimateFix_Engine") then
    CoreGui.UltimateFix_Engine:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateFix_Engine"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ========== НАЛАШТУВАННЯ ==========
local Settings = {
    -- Aim
    Aimbot = true,
    AimMode = 1, -- 1 = Camera, 2 = Mouse, 3 = FOVOriented
    AimSpeed = 0.2,
    AimFOV = 120,
    AimTeamCheck = true,
    
    -- ESP
    ESP = true,
    ESPChams = true,
    ESPNames = true,
    ESPTeamCheck = true,
    
    -- Visuals
    ShowFOV = true
}

local AimModes = {"Camera", "Mouse", "FOVOriented"}

-- ========== ГОЛОВНЕ МЕНЮ ==========
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 480, 0, 320)
Main.Position = UDim2.new(0.5, -240, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
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

-- Заголовок
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
TopBar.BackgroundTransparency = 0.3
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ENGINE v6.0 // NO-RMB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Навігація
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 110, 1, -48)
TabBar.Position = UDim2.new(0, 8, 0, 42)
TabBar.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
TabBar.BackgroundTransparency = 0.4
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 8)
TabBarCorner.Parent = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 4)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 6)
TabPadding.PaddingLeft = UDim.new(0, 6)
TabPadding.PaddingRight = UDim.new(0, 6)
TabPadding.Parent = TabBar

-- Контейнер
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -132, 1, -48)
Container.Position = UDim2.new(0, 124, 0, 42)
Container.BackgroundTransparency = 1
Container.Parent = Main

local Tabs = {}
local TabButtons = {}

local function CreateTab(name)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 60, 90)
    scroll.Visible = false
    scroll.Parent = Container

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    btn.BackgroundTransparency = 0.5
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(160, 165, 180)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = TabBar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for tName, tabObj in pairs(Tabs) do tabObj.Visible = (tName == name) end
        for tName, bObj in pairs(TabButtons) do
            bObj.BackgroundColor3 = (tName == name) and Color3.fromRGB(255, 60, 90) or Color3.fromRGB(24, 26, 34)
            bObj.BackgroundTransparency = (tName == name) and 0.2 or 0.5
            bObj.TextColor3 = (tName == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 165, 180)
        end
    end)

    Tabs[name] = scroll
    TabButtons[name] = btn
    return scroll
end

local AimbotTab = CreateTab("Aimbot")
local ESPTab = CreateTab("ESP")
local VisualsTab = CreateTab("Visuals")

Tabs["Aimbot"].Visible = true
TabButtons["Aimbot"].BackgroundColor3 = Color3.fromRGB(255, 60, 90)
TabButtons["Aimbot"].BackgroundTransparency = 0.2
TabButtons["Aimbot"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- UI КОМПОНЕНТИ
local function AddToggle(parent, text, default, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -6, 0, 34)
    card.BackgroundColor3 = Color3.fromRGB(22, 25, 33)
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
    btn.Size = UDim2.new(0, 36, 0, 18)
    btn.Position = UDim2.new(1, -44, 0.5, -9)
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
    card.Size = UDim2.new(1, -6, 0, 44)
    card.BackgroundColor3 = Color3.fromRGB(22, 25, 33)
    card.BackgroundTransparency = 0.4
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. tostring(default)
    lbl.TextColor3 = Color3.fromRGB(220, 225, 235)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 4)
    track.Position = UDim2.new(0, 10, 1, -12)
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
    card.Size = UDim2.new(1, -6, 0, 36)
    card.BackgroundColor3 = Color3.fromRGB(22, 25, 33)
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
    btn.Size = UDim2.new(0, 110, 0, 22)
    btn.Position = UDim2.new(1, -118, 0.5, -11)
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

-- Вкладка AIMBOT
AddToggle(AimbotTab, "Enable Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
AddSelector(AimbotTab, "Aim Mode", AimModes, Settings.AimMode, function(idx) Settings.AimMode = idx end)
AddSlider(AimbotTab, "Aim Speed (Плавність)", 0.05, 1, Settings.AimSpeed, true, function(v) Settings.AimSpeed = v end)
AddSlider(AimbotTab, "Aim FOV Radius", 30, 400, Settings.AimFOV, false, function(v) 
    Settings.AimFOV = v 
    FOVCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
    FOVCircle.Position = UDim2.new(0.5, -v, 0.5, -v)
end)
AddToggle(AimbotTab, "Aim Team Check", Settings.AimTeamCheck, function(v) Settings.AimTeamCheck = v end)

-- Вкладка ESP
AddToggle(ESPTab, "Enable ESP", Settings.ESP, function(v) Settings.ESP = v end)
AddToggle(ESPTab, "Player Silhouettes (Обтягування)", Settings.ESPChams, function(v) Settings.ESPChams = v end)
AddToggle(ESPTab, "Player Names (Нікнейми)", Settings.ESPNames, function(v) Settings.ESPNames = v end)
AddToggle(ESPTab, "ESP Team Check (Ігнор своїх)", Settings.ESPTeamCheck, function(v) Settings.ESPTeamCheck = v end)

-- Вкладка VISUALS
AddToggle(VisualsTab, "Show FOV Circle", Settings.ShowFOV, function(v) 
    Settings.ShowFOV = v 
    FOVCircle.Visible = v 
end)

-- ========== FOV CIRCLE ==========
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Settings.AimFOV * 2, 0, Settings.AimFOV * 2)
FOVCircle.Position = UDim2.new(0.5, -Settings.AimFOV, 0.5, -Settings.AimFOV)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = Settings.ShowFOV
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 60, 90)
FOVStroke.Thickness = 1
FOVStroke.Transparency = 0.3
FOVStroke.Parent = FOVCircle

-- ========== ЛОГІКА AIMBOT (БЕЗ УМОВ) ==========
local function GetTarget()
    local target = nil
    local minDist = Settings.AimFOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.AimTeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team then continue end

            local char = player.Character
            if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local head = char.Head
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)

                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < minDist then
                        minDist = dist
                        target = head
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot then
        local target = GetTarget()
        if target then
            if Settings.AimMode == 1 then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.AimSpeed)
            elseif Settings.AimMode == 2 then
                local screenPos = Camera:WorldToViewportPoint(target.Position)
                local mousePos = UserInputService:GetMouseLocation()
                local moveX = (screenPos.X - mousePos.X) * Settings.AimSpeed
                local moveY = (screenPos.Y - mousePos.Y) * Settings.AimSpeed
                mousemoverel(moveX, moveY)
            elseif Settings.AimMode == 3 then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
        end
    end
end)

-- ========== ЛОГІКА ESP ==========
local ESPHolder = {}

local function CreateESPForPlayer(player)
    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 11
    nameLabel.Text = player.Name
    nameLabel.Visible = false
    nameLabel.Parent = ScreenGui

    ESPHolder[player] = {Name = nameLabel}
end

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not ESPHolder[player] then CreateESPForPlayer(player) end

            local char = player.Character
            local data = ESPHolder[player]
            local isTeam = Settings.ESPTeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team

            if Settings.ESP and not isTeam and char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local hl = char:FindFirstChild("PureChams")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "PureChams"
                    hl.Adornee = char
                    hl.FillColor = Color3.fromRGB(255, 60, 90)
                    hl.FillTransparency = 0.4
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = char
                end
                hl.Enabled = Settings.ESPChams

                if Settings.ESPNames then
                    local headPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 1.5, 0))
                    if onScreen then
                        data.Name.Position = UDim2.new(0, headPos.X - 50, 0, headPos.Y)
                        data.Name.Size = UDim2.new(0, 100, 0, 15)
                        data.Name.Visible = true
                    else
                        data.Name.Visible = false
                    end
                else
                    data.Name.Visible = false
                end
            else
                if char and char:FindFirstChild("PureChams") then
                    char.PureChams.Enabled = false
                end
                data.Name.Visible = false
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if ESPHolder[p] then
        ESPHolder[p].Name:Destroy()
        ESPHolder[p] = nil
    end
end)

-- RightShift закрити / відкрити
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)
