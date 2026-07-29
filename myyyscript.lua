--[[
    ЧИСТИЙ РАЗШИРЕНИЙ GUI З БІЧНОЮ ПАНЕЛЛЮ
    - Відкриття / Закриття: [RightShift]
    - Вкладки: Aimbot | ESP | Visuals
    - Активація аіму: Затискання ПКМ
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========== ЗНИЩЕННЯ СТАРОГО GUI ==========
if CoreGui:FindFirstChild("AdvancedUI_Container") then
    CoreGui.AdvancedUI_Container:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedUI_Container"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ========== НАЛАШТУВАННЯ ==========
local Settings = {
    -- Aimbot
    Enabled = true,
    Smoothness = 0.15,
    FOV = 150,
    WallCheck = true,
    TeamCheck = false,
    TargetMode = 1, -- 1 = Head, 2 = Torso, 3 = Random
    Randomization = 0.05,
    IsAiming = false,
    -- ESP
    ESPEnabled = false,
    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPColor = Color3.fromRGB(255, 50, 80),
    -- Visuals
    FOVCircleEnabled = true,
    Crosshair = true,
    HitEffect = false,
}

-- ========== ГОЛОВНЕ ВІКНО ==========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 400)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.7
MainStroke.Parent = MainFrame

-- ========== БІЧНА ПАНЕЛЬ (ВКЛАДКИ) ==========
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 90, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Sidebar.BackgroundTransparency = 0.5
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 16)
SidebarCorner.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 8)
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 12)
SidebarPadding.Parent = Sidebar

local TabButtons = {}
local TabFrames = {}

local function CreateTabButton(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 55)
    btn.Position = UDim2.new(0, 6, 0, 0)
    btn.BackgroundTransparency = (order == 1) and 0.5 or 0.85
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = icon .. "\n" .. name
    btn.TextColor3 = (order == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 170, 190)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = order
    btn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for tabName, frame in pairs(TabFrames) do
            frame.Visible = (tabName == name)
        end
        for tabName, button in pairs(TabButtons) do
            local isSelected = (tabName == name)
            button.BackgroundTransparency = isSelected and 0.5 or 0.85
            button.TextColor3 = isSelected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 170, 190)
        end
    end)

    TabButtons[name] = btn
    return btn
end

-- ========== КОНТЕЙНЕР ДЛЯ ВКЛАДОК ==========
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -105, 1, -20)
ContentArea.Position = UDim2.new(0, 100, 0, 10)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local function CreateTabContainer(name, visible)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = visible
    frame.Parent = ContentArea

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = frame

    TabFrames[name] = frame
    return frame
end

local AimbotTab = CreateTabContainer("Aimbot", true)
local ESPTab = CreateTabContainer("ESP", false)
local VisualsTab = CreateTabContainer("Visuals", false)

CreateTabButton("Aimbot", "🎯", 1)
CreateTabButton("ESP", "👁️", 2)
CreateTabButton("Visuals", "🎨", 3)

-- ========== ФУНКЦІЇ СТВОРЕННЯ ЕЛЕМЕНТІВ ==========
local function CreateSlider(parent, order, min, max, default, label, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 42)
    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    card.BackgroundTransparency = 0.92
    card.LayoutOrder = order
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -16, 0, 18)
    labelText.Position = UDim2.new(0, 10, 0, 4)
    labelText.BackgroundTransparency = 1
    labelText.Text = label .. ": " .. string.format("%.2f", default)
    labelText.TextColor3 = Color3.fromRGB(220, 225, 235)
    labelText.TextSize = 12
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 1, -12)
    track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    track.BackgroundTransparency = 0.8
    track.Parent = card

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 80, 120)
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false
    local function update(value)
        value = math.clamp(value, min, max)
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -6, 0.5, -6)
        labelText.Text = label .. ": " .. string.format("%.2f", value)
        callback(value)
    end

    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            update(min + pos * (max - min))
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            update(min + pos * (max - min))
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function CreateToggle(parent, order, default, label, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 36)
    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    card.BackgroundTransparency = 0.92
    card.LayoutOrder = order
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.Position = UDim2.new(0, 10, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(220, 225, 235)
    labelText.TextSize = 13
    labelText.Font = Enum.Font.Gotham
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = card

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 40, 0, 20)
    switch.Position = UDim2.new(1, -50, 0.5, -10)
    switch.BackgroundColor3 = default and Color3.fromRGB(255, 80, 120) or Color3.fromRGB(60, 70, 90)
    switch.BackgroundTransparency = 0.2
    switch.Parent = card

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.Parent = switch

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local state = default
    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            switch.BackgroundColor3 = state and Color3.fromRGB(255, 80, 120) or Color3.fromRGB(60, 70, 90)
            dot.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            callback(state)
        end
    end)
end

-- ========== ЕЛЕМЕНТИ ВКЛАДКИ AIMBOT ==========
CreateSlider(AimbotTab, 1, 0.01, 0.5, 0.15, "Smoothness", function(v) Settings.Smoothness = v end)
CreateSlider(AimbotTab, 2, 30, 450, 150, "FOV Size", function(v) 
    Settings.FOV = v 
    FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
    FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
end)
CreateSlider(AimbotTab, 3, 0, 0.2, 0.05, "Randomization", function(v) Settings.Randomization = v end)
CreateToggle(AimbotTab, 4, true, "Enable Aimbot", function(v) Settings.Enabled = v end)
CreateToggle(AimbotTab, 5, true, "Wall Check", function(v) Settings.WallCheck = v end)
CreateToggle(AimbotTab, 6, false, "Team Check", function(v) Settings.TeamCheck = v end)

-- Перемикач точок прицілювання
local ModeCard = Instance.new("Frame")
ModeCard.Size = UDim2.new(1, 0, 0, 36)
ModeCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ModeCard.BackgroundTransparency = 0.92
ModeCard.LayoutOrder = 7
ModeCard.Parent = AimbotTab

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 8)
ModeCorner.Parent = ModeCard

local ModeLabel = Instance.new("TextLabel")
ModeLabel.Size = UDim2.new(0.6, 0, 1, 0)
ModeLabel.Position = UDim2.new(0, 10, 0, 0)
ModeLabel.BackgroundTransparency = 1
ModeLabel.Text = "Target Part: Head"
ModeLabel.TextColor3 = Color3.fromRGB(220, 225, 235)
ModeLabel.TextSize = 13
ModeLabel.Font = Enum.Font.Gotham
ModeLabel.TextXAlignment = Enum.TextXAlignment.Left
ModeLabel.Parent = ModeCard

local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(0, 80, 0, 22)
ModeBtn.Position = UDim2.new(1, -90, 0.5, -11)
ModeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 120)
ModeBtn.BackgroundTransparency = 0.2
ModeBtn.Text = "Switch"
ModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeBtn.TextSize = 11
ModeBtn.Font = Enum.Font.GothamBold
ModeBtn.Parent = ModeCard

local ModeBtnCorner = Instance.new("UICorner")
ModeBtnCorner.CornerRadius = UDim.new(0, 6)
ModeBtnCorner.Parent = ModeBtn

local modes = {"Head", "Torso", "Random"}
local modeIndex = 1
ModeBtn.MouseButton1Click:Connect(function()
    modeIndex = modeIndex % 3 + 1
    Settings.TargetMode = modeIndex
    ModeLabel.Text = "Target Part: " .. modes[modeIndex]
end)

-- ========== ЕЛЕМЕНТИ ВКЛАДКИ ESP ==========
CreateToggle(ESPTab, 1, false, "ESP Enabled", function(v) Settings.ESPEnabled = v end)
CreateToggle(ESPTab, 2, true, "Box ESP", function(v) Settings.ESPBox = v end)
CreateToggle(ESPTab, 3, true, "Name ESP", function(v) Settings.ESPName = v end)
CreateToggle(ESPTab, 4, true, "Health Bar", function(v) Settings.ESPHealth = v end)

-- ========== ЕЛЕМЕНТИ ВКЛАДКИ VISUALS ==========
CreateToggle(VisualsTab, 1, true, "FOV Circle", function(v)
    Settings.FOVCircleEnabled = v
    FOVCircle.Visible = v
end)
CreateToggle(VisualsTab, 2, true, "Crosshair", function(v)
    Settings.Crosshair = v
    Crosshair.Visible = v
end)

-- ========== FOV CIRCLE ==========
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = true
FOVCircle.Parent = ScreenGui

local circle = Instance.new("ImageLabel")
circle.Image = "rbxassetid://16036349377"
circle.Size = UDim2.new(1, 0, 1, 0)
circle.BackgroundTransparency = 1
circle.ImageColor3 = Color3.fromRGB(255, 80, 120)
circle.ImageTransparency = 0.85
circle.Parent = FOVCircle

-- ========== CROSSHAIR ==========
local Crosshair = Instance.new("Frame")
Crosshair.Size = UDim2.new(0, 20, 0, 20)
Crosshair.Position = UDim2.new(0.5, -10, 0.5, -10)
Crosshair.BackgroundTransparency = 1
Crosshair.Visible = true
Crosshair.Parent = ScreenGui

local function CreateCrossLine(size, pos)
    local line = Instance.new("Frame")
    line.Size = size
    line.Position = pos
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BackgroundTransparency = 0.2
    line.BorderSizePixel = 0
    line.Parent = Crosshair
end

CreateCrossLine(UDim2.new(0, 2, 0, 8), UDim2.new(0.5, -1, 0, 0))
CreateCrossLine(UDim2.new(0, 2, 0, 8), UDim2.new(0.5, -1, 1, -8))
CreateCrossLine(UDim2.new(0, 8, 0, 2), UDim2.new(0, 0, 0.5, -1))
CreateCrossLine(UDim2.new(0, 8, 0, 2), UDim2.new(1, -8, 0.5, -1))

-- ========== ЛОГІКА ПКМ ==========
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.IsAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.IsAiming = false
    end
end)

-- ========== AIMBOT ЛОГІКА ==========
local function GetAimPart(character)
    if Settings.TargetMode == 1 then
        return character:FindFirstChild("Head")
    elseif Settings.TargetMode == 2 then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
    elseif Settings.TargetMode == 3 then
        local parts = {}
        local head = character:FindFirstChild("Head")
        local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        if head then table.insert(parts, head) end
        if torso then table.insert(parts, torso) end
        return #parts > 0 and parts[math.random(1, #parts)] or nil
    end
    return character:FindFirstChild("Head")
end

local function IsVisible(targetPart, targetCharacter)
    if not Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local ignoreList = {Camera}
    if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
    if targetCharacter then table.insert(ignoreList, targetCharacter) end
    raycastParams.FilterDescendantsInstances = ignoreList
    return workspace:Raycast(origin, direction, raycastParams) == nil
end

local function GetClosestTarget()
    local closestTarget = nil
    local shortestDistance = Settings.FOV
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local part = GetAimPart(char)
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
                        if distance <= shortestDistance and IsVisible(part, char) then
                            shortestDistance = distance
                            closestTarget = part
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

RunService.RenderStepped:Connect(function()
    if not Settings.Enabled or not Settings.IsAiming then return end
    local targetPart = GetClosestTarget()
    if targetPart then
        local targetPos = targetPart.Position
        if Settings.Randomization > 0 then
            local r = Settings.Randomization * 10
            targetPos = targetPos + Vector3.new(
                math.random(-r, r)/10,
                math.random(-r, r)/10,
                math.random(-r, r)/10
            )
        end
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        local alpha = Settings.Smoothness == 0 and 1 or math.clamp(Settings.Smoothness, 0.01, 1)
        Camera.CFrame = alpha >= 1 and targetCFrame or Camera.CFrame:Lerp(targetCFrame, alpha)
    end
end)

-- ========== TOGGLE UI ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
