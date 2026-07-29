--[[
    REWRITTEN ULTIMATE SCRIPT
    - Повністю виправлений аімбот
    - Стабільне меню (не пливе)
    - Точний 2D ESP без зсувів
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
    Smoothness = 0.2,
    FOV = 120,
    WallCheck = false,
    TeamCheck = false,
    
    ESP = true,
    ESPBoxes = true,
    ESPNames = true,
    ESPHealth = true,
    
    FOVCircle = true,
    Crosshair = true
}

-- ========== ГОЛОВНЕ ВІКНО ==========
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 480, 0, 340)
Main.Position = UDim2.new(0.5, -240, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 60, 100)
MainStroke.Thickness = 1.5
MainStroke.Parent = Main

-- Шапка
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 28, 36)
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "CHEAT MENU v2.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Навігація (Вкладки)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(0, 110, 1, -45)
TabBar.Position = UDim2.new(0, 5, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
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
TabPadding.PaddingTop = UDim.new(0, 5)
TabPadding.PaddingLeft = UDim.new(0, 5)
TabPadding.PaddingRight = UDim.new(0, 5)
TabPadding.Parent = TabBar

-- Контейнер для вмісту
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -130, 1, -45)
Container.Position = UDim2.new(0, 120, 0, 40)
Container.BackgroundTransparency = 1
Container.Parent = Main

local Tabs = {}
local TabButtons = {}

local function CreateTab(name)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
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
    btn.BackgroundColor3 = Color3.fromRGB(22, 25, 32)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 155, 170)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = TabBar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for tName, tabObj in pairs(Tabs) do
            tabObj.Visible = (tName == name)
        end
        for tName, bObj in pairs(TabButtons) do
            bObj.BackgroundColor3 = (tName == name) and Color3.fromRGB(255, 60, 100) or Color3.fromRGB(22, 25, 32)
            bObj.TextColor3 = (tName == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 155, 170)
        end
    end)

    Tabs[name] = scroll
    TabButtons[name] = btn
    return scroll
end

local AimbotTab = CreateTab("Aimbot")
local ESPTab = CreateTab("ESP")
local VisualsTab = CreateTab("Visuals")

-- Активація першої вкладки за замовчуванням
Tabs["Aimbot"].Visible = true
TabButtons["Aimbot"].BackgroundColor3 = Color3.fromRGB(255, 60, 100)
TabButtons["Aimbot"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ========== ЕЛЕМЕНТИ УПРАВЛІННЯ (TOGGLES / SLIDERS) ==========
local function AddToggle(parent, text, default, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -6, 0, 35)
    card.BackgroundColor3 = Color3.fromRGB(24, 27, 35)
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
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 42, 0, 20)
    btn.Position = UDim2.new(1, -50, 0.5, -10)
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
    card.Size = UDim2.new(1, -6, 0, 45)
    card.BackgroundColor3 = Color3.fromRGB(24, 27, 35)
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
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Додавання елементів
AddToggle(AimbotTab, "Enable Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
AddSlider(AimbotTab, "FOV Radius", 30, 400, Settings.FOV, function(v) 
    Settings.FOV = v 
    FOVCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
    FOVCircle.Position = UDim2.new(0.5, -v, 0.5, -v)
end)
AddToggle(AimbotTab, "Wall Check", Settings.WallCheck, function(v) Settings.WallCheck = v end)

AddToggle(ESPTab, "Enable ESP", Settings.ESP, function(v) Settings.ESP = v end)
AddToggle(ESPTab, "Boxes", Settings.ESPBoxes, function(v) Settings.ESPBoxes = v end)
AddToggle(ESPTab, "Names", Settings.ESPNames, function(v) Settings.ESPNames = v end)
AddToggle(ESPTab, "Health Bar", Settings.ESPHealth, function(v) Settings.ESPHealth = v end)

AddToggle(VisualsTab, "Show FOV Circle", Settings.FOVCircle, function(v) 
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
FOVStroke.Transparency = 0.3
FOVStroke.Parent = FOVCircle

-- ========== ПРАЦЮЮЧИЙ AIMBOT ==========
local function GetTarget()
    local closest, distance = nil, Settings.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local head = char.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

                if onScreen then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if mag < distance then
                        if Settings.WallCheck then
                            local ray = RaycastParams.new()
                            ray.FilterType = Enum.RaycastFilterType.Exclude
                            ray.FilterDescendantsInstances = {LocalPlayer.Character, char}
                            local hit = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position), ray)
                            if not hit then
                                distance = mag
                                closest = head
                            end
                        else
                            distance = mag
                            closest = head
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
        local target = GetTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.Smoothness)
        end
    end
end)

-- ========== РЕАЛЬНО ТОЧНИЙ ESP ==========
local ESPHolder = {}

local function CreateESPObj(player)
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.Visible = false
    box.Parent = ScreenGui

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 60, 100)
    stroke.Thickness = 1.5
    stroke.Parent = box

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, 0, 0, 14)
    name.Position = UDim2.new(0, 0, 0, -16)
    name.BackgroundTransparency = 1
    name.Text = player.Name
    name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 11
    name.Parent = box

    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(0, 3, 1, 0)
    hpBg.Position = UDim2.new(0, -6, 0, 0)
    hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    hpBg.BorderSizePixel = 0
    hpBg.Parent = box

    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg

    ESPHolder[player] = {Box = box, Stroke = stroke, Name = name, HpBg = hpBg, HpFill = hpFill}
end

RunService.RenderStepped:Connect(function()
    if not Settings.ESP then
        for _, obj in pairs(ESPHolder) do obj.Box.Visible = false end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not ESPHolder[player] then CreateESPObj(player) end
            local data = ESPHolder[player]
            local char = player.Character

            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local root = char.HumanoidRootPart
                local headPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
                local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)

                if onScreen then
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 1.5

                    data.Box.Size = UDim2.new(0, width, 0, height)
                    data.Box.Position = UDim2.new(0, rootPos.X - width/2, 0, rootPos.Y - height/2)
                    data.Box.Visible = true

                    data.Stroke.Enabled = Settings.ESPBoxes
                    data.Name.Visible = Settings.ESPNames
                    data.HpBg.Visible = Settings.ESPHealth

                    local hpPercent = char.Humanoid.Health / char.Humanoid.MaxHealth
                    data.HpFill.Size = UDim2.new(1, 0, hpPercent, 0)
                    data.HpFill.Position = UDim2.new(0, 0, 1 - hpPercent, 0)
                else
                    data.Box.Visible = false
                end
            else
                data.Box.Visible = false
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if ESPHolder[p] then
        ESPHolder[p].Box:Destroy()
        ESPHolder[p] = nil
    end
end)

-- Відкриття/закриття на RightShift
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)
