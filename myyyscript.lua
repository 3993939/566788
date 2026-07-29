--[[
    PURE CLEAN GLASS UI + AIMBOT (NO TEXT)
    - Відкриття / Закриття: [RightShift]
    - Кольори: Напівпрозорий білий / сірий
    - Жодного тексту чи написів
    - ДОДАНО: Аімбот з налаштуваннями
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ЗНИЩЕННЯ СТАРОГО GUI, ЯКЩО ВОНО ІСНУЄ
if CoreGui:FindFirstChild("PureCleanUI_Container") then
    CoreGui.PureCleanUI_Container:Destroy()
end

-- СТВОРЕННЯ КОНТЕЙНЕРА
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PureCleanUI_Container"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ========== ОСНОВНЕ БІЛО-СІРЕ СКЛЯНЕ ВІКНО ==========
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainGlassFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 220)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(235, 238, 242)
MainFrame.BackgroundTransparency = 0.65
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

-- ВНУТРІШНІЙ СІРИЙ АКТЕНТНИЙ БЛОК
local InnerFrame = Instance.new("Frame")
InnerFrame.Name = "InnerAccent"
InnerFrame.Size = UDim2.new(1, -30, 1, -30)
InnerFrame.Position = UDim2.new(0, 15, 0, 15)
InnerFrame.BackgroundColor3 = Color3.fromRGB(180, 185, 195)
InnerFrame.BackgroundTransparency = 0.8
InnerFrame.Parent = MainFrame

local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, 14)
InnerCorner.Parent = InnerFrame

-- ========== НАЛАШТУВАННЯ АІМБОТА ==========
local Settings = {
    Enabled = true,
    Smoothness = 0.15,
    FOV = 200,
    WallCheck = true,
    TeamCheck = false,
    AimPart = "Head",
    Randomization = 0.05
}

-- ========== СТВОРЕННЯ ПОВЗУНКІВ (БЕЗ ТЕКСТУ, ТІЛЬКИ ВІЗУАЛ) ==========
local function CreateSlider(parent, yPos, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.85, 0, 0.1, 0)
    frame.Position = UDim2.new(0.075, 0, yPos, 0)
    frame.BackgroundTransparency = 0.6
    frame.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
    frame.Parent = parent

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0.35, 0)
    track.Position = UDim2.new(0, 0, 0.35, 0)
    track.BackgroundColor3 = Color3.fromRGB(150, 155, 165)
    track.BackgroundTransparency = 0.5
    track.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 120, 140)
    fill.BackgroundTransparency = 0.3
    fill.Parent = track

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(220, 225, 235)
    knob.BackgroundTransparency = 0.2
    knob.Parent = frame

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false
    local function update(value)
        value = math.clamp(value, min, max)
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -6, 0.5, -6)
        callback(value)
    end

    frame.InputBegan:Connect(function(input)
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

    return update
end

-- ========== СТВОРЕННЯ ПЕРЕМИКАЧІВ ==========
local function CreateToggle(parent, yPos, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.85, 0, 0.09, 0)
    frame.Position = UDim2.new(0.075, 0, yPos, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local toggleBox = Instance.new("Frame")
    toggleBox.Size = UDim2.new(0.08, 0, 0.7, 0)
    toggleBox.Position = UDim2.new(0.85, 0, 0.15, 0)
    toggleBox.BackgroundColor3 = default and Color3.fromRGB(140, 160, 180) or Color3.fromRGB(160, 165, 175)
    toggleBox.BackgroundTransparency = 0.4
    toggleBox.Parent = frame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBox

    local ball = Instance.new("Frame")
    ball.Size = UDim2.new(0.5, 0, 0.9, 0)
    ball.Position = default and UDim2.new(0.45, 0, 0.05, 0) or UDim2.new(0.05, 0, 0.05, 0)
    ball.BackgroundColor3 = Color3.fromRGB(235, 238, 242)
    ball.BackgroundTransparency = 0.3
    ball.Parent = toggleBox

    local ballCorner = Instance.new("UICorner")
    ballCorner.CornerRadius = UDim.new(1, 0)
    ballCorner.Parent = ball

    local state = default
    toggleBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            toggleBox.BackgroundColor3 = state and Color3.fromRGB(140, 160, 180) or Color3.fromRGB(160, 165, 175)
            ball.Position = state and UDim2.new(0.45, 0, 0.05, 0) or UDim2.new(0.05, 0, 0.05, 0)
            callback(state)
        end
    end)

    return function() return state end
end

-- ========== ДОДАВАННЯ ЕЛЕМЕНТІВ КЕРУВАННЯ ==========
CreateSlider(MainFrame, 0.12, 0, 0.5, 0.15, function(v)
    Settings.Smoothness = v
end)

CreateSlider(MainFrame, 0.26, 50, 400, 200, function(v)
    Settings.FOV = v
end)

CreateSlider(MainFrame, 0.40, 0, 0.2, 0.05, function(v)
    Settings.Randomization = v
end)

CreateToggle(MainFrame, 0.55, true, function(v)
    Settings.Enabled = v
end)

CreateToggle(MainFrame, 0.68, true, function(v)
    Settings.WallCheck = v
end)

CreateToggle(MainFrame, 0.81, false, function(v)
    Settings.TeamCheck = v
end)

-- ========== ОСНОВНА ЛОГІКА АІМБОТА ==========
local function GetValidTargets()
    local targets = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            local part = player.Character:FindFirstChild(Settings.AimPart)
            if not part then
                part = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Head")
            end
            if part then
                table.insert(targets, {Player = player, Part = part})
            end
        end
    end
    return targets
end

local function IsVisible(targetPart)
    if not Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart}
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local function GetAngle(targetPos)
    local cameraPos = Camera.CFrame.Position
    local direction = (targetPos - cameraPos).Unit
    local angle = math.deg(math.acos(direction:Dot(Camera.CFrame.LookVector)))
    return angle
end

-- ========== ОСНОВНИЙ ЦИКЛ АІМБОТА ==========
local CurrentTarget = nil

RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then return end

    local targets = GetValidTargets()
    local bestTarget = nil
    local bestAngle = math.huge

    for _, target in pairs(targets) do
        local angle = GetAngle(target.Part.Position)
        if angle <= Settings.FOV and angle < bestAngle and IsVisible(target.Part) then
            bestAngle = angle
            bestTarget = target
        end
    end

    if bestTarget then
        CurrentTarget = bestTarget
        local targetPos = bestTarget.Part.Position
        
        -- Рандомізація наводки
        local randomOffset = Vector3.new(
            math.random(-Settings.Randomization * 10, Settings.Randomization * 10) / 10,
            math.random(-Settings.Randomization * 10, Settings.Randomization * 10) / 10,
            math.random(-Settings.Randomization * 10, Settings.Randomization * 10) / 10
        ) / 2
        targetPos = targetPos + randomOffset

        local cameraPos = Camera.CFrame.Position
        local direction = (targetPos - cameraPos).Unit
        local targetCFrame = CFrame.new(cameraPos, cameraPos + direction)

        if Settings.Smoothness == 0 then
            Camera.CFrame = targetCFrame
        else
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
        end
    else
        CurrentTarget = nil
    end
end)

-- ========== ВІДОБРАЖЕННЯ FOV (ПРОЗОРЕ КОЛО) ==========
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
FOVCircle.BackgroundTransparency = 1
FOVCircle.ZIndex = 0
FOVCircle.Parent = ScreenGui

local circle = Instance.new("ImageLabel")
circle.Image = "rbxassetid://16036349377"
circle.Size = UDim2.new(1, 0, 1, 0)
circle.BackgroundTransparency = 1
circle.ImageColor3 = Color3.fromRGB(180, 190, 200)
circle.ImageTransparency = 0.85
circle.Parent = FOVCircle

-- Оновлення FOV при зміні
local oldFOV = Settings.FOV
spawn(function()
    while wait(0.5) do
        if Settings.FOV ~= oldFOV then
            oldFOV = Settings.FOV
            FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
            FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
        end
    end
end)

-- ========== ЛОГІКА ВІДКРИТТЯ / ЗАКРИТТЯ НА RIGHT SHIFT ==========
local IsOpen = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        IsOpen = not IsOpen
        MainFrame.Visible = IsOpen
        FOVCircle.Visible = IsOpen
    end
end)

print("✅ ЧИСТИЙ GUI + АІМБОТ ЗАВАНТАЖЕНО!")
