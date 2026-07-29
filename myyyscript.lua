--[[
    CLEAN MODERN GLASS UI + AIMBOT
    - Відкриття / Закриття: [RightShift]
    - Активація аіму: Затискання ПКМ
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("PureCleanUI_Container") then
    CoreGui.PureCleanUI_Container:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PureCleanUI_Container"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ========== ОСНОВНЕ ВІКНО ==========
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainGlassFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 340)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
MainFrame.BackgroundTransparency = 0.35
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.6
MainStroke.Parent = MainFrame

-- КОНТЕЙНЕР З АВТО-ВИРІВНЯННЯМ
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -24, 1, -24)
ContentContainer.Position = UDim2.new(0, 12, 0, 12)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 8)
ListLayout.Parent = ContentContainer

-- ========== НАЛАШТУВАННЯ ==========
local Settings = {
    Enabled = true,
    Speed = 5,
    FOV = 150,
    WallCheck = true,
    TeamCheck = false,
    TargetMode = 1, -- 1 = Head, 2 = Torso, 3 = Random
    Randomization = 0.05,
    IsAiming = false
}

-- ========== ЕЛЕМЕНТ: СЛАЙДЕР ==========
local function CreateSlider(order, min, max, default, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 36)
    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    card.BackgroundTransparency = 0.9
    card.LayoutOrder = order
    card.Parent = ContentContainer

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 0.5, -3)
    track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    track.BackgroundTransparency = 0.8
    track.Parent = card

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BackgroundTransparency = 0.3
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = card

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false
    local function update(value)
        value = math.clamp(value, min, max)
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -7, 0.5, -7)
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

-- ========== ЕЛЕМЕНТ: МАКЕТ РЕЖИМІВ (1, 2, 3) ==========
local function CreateModeSelector(order, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 36)
    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    card.BackgroundTransparency = 0.9
    card.LayoutOrder = order
    card.Parent = ContentContainer

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0.3, 0, 0.7, 0)
    indicator.Position = UDim2.new(0.025, 0, 0.15, 0)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    indicator.BackgroundTransparency = 0.4
    indicator.Parent = card

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 6)
    indCorner.Parent = indicator

    local currentMode = 1
    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            currentMode = currentMode + 1
            if currentMode > 3 then currentMode = 1 end
            
            if currentMode == 1 then
                indicator.Position = UDim2.new(0.025, 0, 0.15, 0)
            elseif currentMode == 2 then
                indicator.Position = UDim2.new(0.35, 0, 0.15, 0)
            elseif currentMode == 3 then
                indicator.Position = UDim2.new(0.675, 0, 0.15, 0)
            end
            
            callback(currentMode)
        end
    end)
end

-- ========== ЕЛЕМЕНТ: ТОГЛ (ПЕРЕМИКАЧ) ==========
local function CreateToggle(order, default, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 36)
    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    card.BackgroundTransparency = 0.9
    card.LayoutOrder = order
    card.Parent = ContentContainer

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 44, 0, 22)
    switch.Position = UDim2.new(1, -54, 0.5, -11)
    switch.BackgroundColor3 = default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 100, 100)
    switch.BackgroundTransparency = default and 0.4 or 0.7
    switch.Parent = card

    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switch

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.Parent = switch

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local state = default
    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            switch.BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 100, 100)
            switch.BackgroundTransparency = state and 0.4 or 0.7
            dot.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            callback(state)
        end
    end)
end

-- ========== FOV CIRCLE ==========
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = ScreenGui

local circle = Instance.new("ImageLabel")
circle.Image = "rbxassetid://16036349377"
circle.Size = UDim2.new(1, 0, 1, 0)
circle.BackgroundTransparency = 1
circle.ImageColor3 = Color3.fromRGB(255, 255, 255)
circle.ImageTransparency = 0.85
circle.Parent = FOVCircle

local function UpdateFOVVisual()
    FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
    FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
end

-- ========== СПИСОК ЕЛЕМЕНТІВ В МЕНЮ ==========
CreateSlider(1, 1, 10, 5, function(v) Settings.Speed = math.round(v) end)
CreateSlider(2, 30, 450, 150, function(v) Settings.FOV = v; UpdateFOVVisual() end)
CreateSlider(3, 0, 0.2, 0.05, function(v) Settings.Randomization = v end)
CreateModeSelector(4, function(mode) Settings.TargetMode = mode end)
CreateToggle(5, true, function(v) Settings.Enabled = v end)
CreateToggle(6, true, function(v) Settings.WallCheck = v end)
CreateToggle(7, false, function(v) Settings.TeamCheck = v end)

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

-- ========== AIMBOT LOGIC ==========
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
        local alpha = Settings.Speed == 1 and 1.0 or math.clamp(0.85 - ((Settings.Speed - 2) * 0.1), 0.05, 1.0)
        
        Camera.CFrame = alpha >= 1.0 and targetCFrame or Camera.CFrame:Lerp(targetCFrame, alpha)
    end
end)

-- ========== TOGGLE UI ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        FOVCircle.Visible = MainFrame.Visible
    end
end)
