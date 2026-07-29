--[[
    REWRITTEN ULTIMATE SCRIPT v3.0
    - Прозоре меню
    - Покращений Аімбот (Smooth, Target Part, Delta-aim)
    - 3D Bounding Box ESP (обтягує гравця навколо)
    - Повернуто Team Check та розширені налаштування
    - Відкриття / Закриття: [RightShift]
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Очистка попередніх копій
if CoreGui:FindFirstChild("CleanUI_Engine") then
    CoreGui.CleanUI_Engine:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CleanUI_Engine"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ========== НАЛАШТУВАННЯ ==========
local Settings = {
    Aimbot = true,
    AimPart = "Head", -- "Head" або "HumanoidRootPart"
    Smoothness = 0.15,
    FOV = 130,
    WallCheck = true,
    TeamCheck = true,
    RMBTrigger = true, -- Наводитись тільки при затиснутому ПКМ
    
    ESP = true,
    ESP3DBox = true,
    ESPNames = true,
    ESPHealth = true,
    
    FOVCircle = true
}

-- ========== ГОЛОВНЕ ВІКНО (ПРОЗОРЕ) ==========
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 360)
Main.Position = UDim2.new(0.5, -250, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
Main.BackgroundTransparency = 0.25 -- Напівпрозорість
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 60, 100)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2
MainStroke.Parent = Main

-- Шапка
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
TopBar.BackgroundTransparency = 0.3
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ULTIMATE ENGINE // GLASS EDITION"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Навігація (Вкладки)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 120, 1, -50)
TabBar.Position = UDim2.new(0, 8, 0, 44)
TabBar.BackgroundColor3 = Color3.fromRGB(10, 11, 15)
TabBar.BackgroundTransparency = 0.4
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 8)
TabBarCorner.Parent = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 5)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 6)
TabPadding.PaddingLeft = UDim.new(0, 6)
TabPadding.PaddingRight = UDim.new(0, 6)
TabPadding.Parent = TabBar

-- Контейнер вмісту
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -142, 1, -50)
Container.Position = UDim2.new(0, 134, 0, 44)
Container.BackgroundTransparency = 1
Container.Parent = Main

local Tabs = {}
local TabButtons = {}

local function CreateTab(name)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 60, 100)
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
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
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
            bObj.BackgroundColor3 = (tName == name) and Color3.fromRGB(255, 60, 100) or Color3.fromRGB(20, 23, 30)
            bObj.BackgroundTransparency = (tName == name) and 0.2 or 0.5
            bObj.TextColor3 = (tName == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 165, 180)
        end
    end)

    Tabs[name] = scroll
    TabButtons[name] = btn
    return scroll
end

local AimbotTab = CreateTab("Aimbot")
local ESPTab = CreateTab("Visuals & ESP")

Tabs["Aimbot"].Visible = true
TabButtons["Aimbot"].BackgroundColor3 = Color3.fromRGB(255, 60, 100)
TabButtons["Aimbot"].BackgroundTransparency = 0.2
TabButtons["Aimbot"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ========== КОМПОНЕНТИ UI ==========
local function AddToggle(parent, text, default, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -8, 0, 36)
    card.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
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
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -48, 0.5, -10)
    btn.BackgroundColor3 = default and Color3.fromRGB(255, 60, 100) or Color3.fromRGB(40, 45, 55)
    btn.Text = ""
    btn.Parent = card

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = btn

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 14, 0, 14)
    circle.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = btn

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(255, 60, 100) or Color3.fromRGB(40, 45, 55)
        circle.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        callback(state)
    end)
end

local function AddSlider(parent, text, min, max, default, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -8, 0, 46)
    card.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
    card.BackgroundTransparency = 0.4
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. tostring(default)
    lbl.TextColor3 = Color3.fromRGB(220, 225, 235)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 5)
    track.Position = UDim2.new(0, 10, 1, -12)
    track.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
    track.Parent = card

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 60, 100)
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local dragging = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        lbl.Text = text .. ": " .. tostring(val)
        callback(val)
    end

    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            Update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- Додаємо перемикачі в меню
AddToggle(AimbotTab, "Enable Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
AddToggle(AimbotTab, "RMB Hold Only (Затискати ПКМ)", Settings.RMBTrigger, function(v) Settings.RMBTrigger = v end)
AddToggle(AimbotTab, "Team Check (Ігнорувати своїх)", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
AddToggle(AimbotTab, "Wall Check (За перешкодою)", Settings.WallCheck, function(v) Settings.WallCheck = v end)
AddSlider(AimbotTab, "FOV Radius", 30, 400, Settings.FOV, function(v) 
    Settings.FOV = v 
    FOVCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
    FOVCircle.Position = UDim2.new(0.5, -v, 0.5, -v)
end)

AddToggle(ESPTab, "Enable ESP", Settings.ESP, function(v) Settings.ESP = v end)
AddToggle(ESPTab, "3D Box (Обтягувати гравця)", Settings.ESP3DBox, function(v) Settings.ESP3DBox = v end)
AddToggle(ESPTab, "Names", Settings.ESPNames, function(v) Settings.ESPNames = v end)
AddToggle(ESPTab, "Health Bar", Settings.ESPHealth, function(v) Settings.ESPHealth = v end)
AddToggle(ESPTab, "Show FOV Circle", Settings.FOVCircle, function(v) 
    Settings.FOVCircle = v 
    FOVCircle.Visible = v
end)

-- ========== FOV CIRCLE ==========
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = Settings.FOVCircle
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 60, 100)
FOVStroke.Thickness = 1.2
FOVStroke.Transparency = 0.4
FOVStroke.Parent = FOVCircle

-- ========== ОНОВЛЕНИЙ AIMBOT ==========
local isRmbPressed = false
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRmbPressed = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isRmbPressed = false
    end
end)

local function GetTarget()
    local closest, minDistance = nil, Settings.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.TeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team then
                continue
            end

            local char = player.Character
            if char and char:FindFirstChild(Settings.AimPart) and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local part = char[Settings.AimPart]
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)

                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < minDistance then
                        if Settings.WallCheck then
                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
                            local hit = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), rayParams)
                            if not hit then
                                minDistance = dist
                                closest = part
                            end
                        else
                            minDistance = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot then
        if not Settings.RMBTrigger or isRmbPressed then
            local target = GetTarget()
            if target then
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, target.Position)
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, Settings.Smoothness)
            end
        end
    end
end)

-- ========== 3D BOX ESP (ОБТЯГУВАПНЯ МОДЕЛЬКИ) ==========
local ESPHolder = {}

local function CreateESP3D(player)
    local lines = {}
    for i = 1, 12 do
        local line = Instance.new("Frame")
        line.BackgroundColor3 = Color3.fromRGB(255, 60, 100)
        line.BorderSizePixel = 0
        line.Visible = false
        line.Parent = ScreenGui
        table.insert(lines, line)
    end

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 11
    nameLabel.Text = player.Name
    nameLabel.Visible = false
    nameLabel.Parent = ScreenGui

    ESPHolder[player] = {Lines = lines, Name = nameLabel}
end

local function Draw3DBox(player, char)
    local data = ESPHolder[player]
    if not data then return end

    local cframe, size = char:GetBoundingBox()
    local halfSize = size / 2

    -- 8 кутів 3D хитбокса
    local corners = {
        cframe * Vector3.new(-halfSize.X,  halfSize.Y, -halfSize.Z),
        cframe * Vector3.new( halfSize.X,  halfSize.Y, -halfSize.Z),
        cframe * Vector3.new( halfSize.X, -halfSize.Y, -halfSize.Z),
        cframe * Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z),
        cframe * Vector3.new(-halfSize.X,  halfSize.Y,  halfSize.Z),
        cframe * Vector3.new( halfSize.X,  halfSize.Y,  halfSize.Z),
        cframe * Vector3.new( halfSize.X, -halfSize.Y,  halfSize.Z),
        cframe * Vector3.new(-halfSize.X, -halfSize.Y,  halfSize.Z)
    }

    local screenCorners = {}
    local allOnScreen = true

    for i, corner in ipairs(corners) do
        local pos, onScreen = Camera:WorldToViewportPoint(corner)
        if not onScreen then allOnScreen = false end
        screenCorners[i] = Vector2.new(pos.X, pos.Y)
    end

    if not allOnScreen then
        for _, l in ipairs(data.Lines) do l.Visible = false end
        data.Name.Visible = false
        return
    end

    -- 12 ребер куба
    local edges = {
        {1,2}, {2,3}, {3,4}, {4,1},
        {5,6}, {6,7}, {7,8}, {8,5},
        {1,5}, {2,6}, {3,7}, {4,8}
    }

    for i, edge in ipairs(edges) do
        local p1 = screenCorners[edge[1]]
        local p2 = screenCorners[edge[2]]
        local line = data.Lines[i]

        local distance = (p2 - p1).Magnitude
        local center = (p1 + p2) / 2
        local angle = math.atan2(p2.Y - p1.Y, p2.X - p1.X)

        line.Size = UDim2.new(0, distance, 0, 1.5)
        line.Position = UDim2.new(0, center.X - distance/2, 0, center.Y)
        line.Rotation = math.deg(angle)
        line.Visible = Settings.ESP3DBox
    end

    if Settings.ESPNames then
        local headPos = Camera:WorldToViewportPoint(cframe.Position + Vector3.new(0, size.Y/2 + 0.5, 0))
        data.Name.Position = UDim2.new(0, headPos.X - 50, 0, headPos.Y - 15)
        data.Name.Size = UDim2.new(0, 100, 0, 15)
        data.Name.Visible = true
    else
        data.Name.Visible = false
    end
end

RunService.RenderStepped:Connect(function()
    if not Settings.ESP then
        for _, obj in pairs(ESPHolder) do
            for _, l in ipairs(obj.Lines) do l.Visible = false end
            obj.Name.Visible = false
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.TeamCheck and player.Team ~= nil and player.Team == LocalPlayer.Team then
                if ESPHolder[player] then
                    for _, l in ipairs(ESPHolder[player].Lines) do l.Visible = false end
                    ESPHolder[player].Name.Visible = false
                end
                continue
            end

            if not ESPHolder[player] then CreateESP3D(player) end
            local char = player.Character

            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                Draw3DBox(player, char)
            else
                if ESPHolder[player] then
                    for _, l in ipairs(ESPHolder[player].Lines) do l.Visible = false end
                    ESPHolder[player].Name.Visible = false
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if ESPHolder[p] then
        for _, l in ipairs(ESPHolder[p].Lines) do l:Destroy() end
        ESPHolder[p].Name:Destroy()
        ESPHolder[p] = nil
    end
end)

-- Відкриття/закриття меню
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)
