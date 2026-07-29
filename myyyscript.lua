--[[
    PURE CLEAN GLASS UI + ADVANCED AIMBOT (NO TEXT)
    - Відкриття / Закриття: [RightShift]
    - Спрацьовування аіму: На затискання ПКМ
    - Швидкість: 1 (Жорстке прилипання) -> 10 (Слабка доводка)
    - Режими AimPart (Клік по блоку): 1 = Head, 2 = Torso, 3 = Random
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ЗНИЩЕННЯ СТАРОГО GUI
if CoreGui:FindFirstChild("PureCleanUI_Container") then
    CoreGui.PureCleanUI_Container:Destroy()
end

-- СТВОРЕННЯ КОНТЕЙНЕРА
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PureCleanUI_Container"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ========== ЗБІЛЬШЕНЕ БІЛО-СІРЕ СКЛЯНЕ ВІКНО ==========
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainGlassFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 300) -- Збільшено розмір
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(235, 238, 242)
MainFrame.BackgroundTransparency = 0.65
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 22)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 1.8
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

-- ВНУТРІШНІЙ СІРИЙ АКЦЕНТНИЙ БЛОК
local InnerFrame = Instance.new("Frame")
InnerFrame.Name = "InnerAccent"
InnerFrame.Size = UDim2.new(1, -30, 1, -30)
InnerFrame.Position = UDim2.new(0, 15, 0, 15)
InnerFrame.BackgroundColor3 = Color3.fromRGB(180, 185, 195)
InnerFrame.BackgroundTransparency = 0.8
InnerFrame.Parent = MainFrame

local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, 16)
InnerCorner.Parent = InnerFrame

-- ========== НАЛАШТУВАННЯ АІМБОТА ==========
local Settings = {
    Enabled = true,
    Speed = 5, -- Швидкість від 1 до 10
    FOV = 150,
    WallCheck = true,
    TeamCheck = false,
    TargetMode = 1, -- 1 = Head, 2 = Torso, 3 = Random
    Randomization = 0.05,
    IsAiming = false
}

-- ========== СТВОРЕННЯ ЗБІЛЬШЕНИХ ПОВЗУНКІВ (БЕЗ ТЕКСТУ) ==========
local function CreateSlider(parent, yPos, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.88, 0, 0.085, 0)
    frame.Position = UDim2.new(0.06, 0, yPos, 0)
    frame.BackgroundTransparency = 0.6
    frame.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
    frame.Parent = parent

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0.4, 0)
    track.Position = UDim2.new(0, 0, 0.3, 0)
    track.BackgroundColor3 = Color3.fromRGB(150, 155, 165)
    track.BackgroundTransparency = 0.5
    track.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 120, 140)
    fill.BackgroundTransparency = 0.3
    fill.Parent = track

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(230, 235, 245)
    knob.BackgroundTransparency = 0.1
    knob.Parent = frame

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

-- ========== СТВОРЕННЯ ПЕРЕМИКАЧІВ (БЕЗ ТЕКСТУ) ==========
local function CreateToggle(parent, yPos, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.88, 0, 0.08, 0)
    frame.Position = UDim2.new(0.06, 0, yPos, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local toggleBox = Instance.new("Frame")
    toggleBox.Size = UDim2.new(0.1, 0, 0.8, 0)
    toggleBox.Position = UDim2.new(0.88, 0, 0.1, 0)
    toggleBox.BackgroundColor3 = default and Color3.fromRGB(140, 160, 180) or Color3.fromRGB(160, 165, 175)
    toggleBox.BackgroundTransparency = 0.4
    toggleBox.Parent = frame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBox

    local ball = Instance.new("Frame")
    ball.Size = UDim2.new(0.45, 0, 0.85, 0)
    ball.Position = default and UDim2.new(0.5, 0, 0.075, 0) or UDim2.new(0.05, 0, 0.075, 0)
    ball.BackgroundColor3 = Color3.fromRGB(240, 243, 248)
    ball.BackgroundTransparency = 0.2
    ball.Parent = toggleBox

    local ballCorner = Instance.new("UICorner")
    ballCorner.CornerRadius = UDim.new(1, 0)
    ballCorner.Parent = ball

    local state = default
    toggleBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            toggleBox.BackgroundColor3 = state and Color3.fromRGB(140, 160, 180) or Color3.fromRGB(160, 165, 175)
            ball.Position = state and UDim2.new(0.5, 0, 0.075, 0) or UDim2.new(0.05, 0, 0.075, 0)
            callback(state)
        end
    end)
end

-- ========== КНОПКА ВИБОРУ РЕЖИМУ НАЦІЛЮВАННЯ (1, 2, 3) ==========
local function CreateModeSelector(parent, yPos, callback)
    local selectorFrame = Instance.new("Frame")
    selectorFrame.Size = UDim2.new(0.88, 0, 0.085, 0)
    selectorFrame.Position = UDim2.new(0.06, 0, yPos, 0)
    selectorFrame.BackgroundColor3 = Color3.fromRGB(180, 185, 195)
    selectorFrame.BackgroundTransparency = 0.6
    selectorFrame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = selectorFrame

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0.31, 0, 0.8, 0)
    indicator.Position = UDim2.new(0.01, 0, 0.1, 0)
    indicator.BackgroundColor3 = Color3.fromRGB(120, 140, 160)
    indicator.BackgroundTransparency = 0.3
    indicator.Parent = selectorFrame

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 6)
    indCorner.Parent = indicator

    local currentMode = 1
    selectorFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            currentMode = currentMode + 1
            if currentMode > 3 then currentMode = 1 end
            
            if currentMode == 1 then
                indicator.Position = UDim2.new(0.01, 0, 0.1, 0)
            elseif currentMode == 2 then
                indicator.Position = UDim2.new(0.345, 0, 0.1, 0)
            elseif currentMode == 3 then
                indicator.Position = UDim2.new(0.68, 0, 0.1, 0)
            end
            
            callback(currentMode)
        end
    end)
end

-- ========== ВІДОБРАЖЕННЯ FOV (КОЛО НА ЕКРАНІ) ==========
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

local function UpdateFOVVisual()
    FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
    FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
end

-- ========== ДОДАВАННЯ ЕЛЕМЕНТІВ В GUI ==========
-- 1. Слайдер швидкості (1 to 10)
CreateSlider(MainFrame, 0.10, 1, 10, 5, function(v)
    Settings.Speed = math.round(v)
end)

-- 2. Слайдер FOV
CreateSlider(MainFrame, 0.22, 30, 450, 150, function(v)
    Settings.FOV = v
    UpdateFOVVisual()
end)

-- 3. Слайдер рандомізації/розкиду
CreateSlider(MainFrame, 0.34, 0, 0.2, 0.05, function(v)
    Settings.Randomization = v
end)

-- 4. Перемикач режимів націлювання (1 = Head, 2 = Torso, 3 = Random)
CreateModeSelector(MainFrame, 0.47, function(mode)
    Settings.TargetMode = mode
end)

-- 5. Тогли (Enabled, WallCheck, TeamCheck)
CreateToggle(MainFrame, 0.60, true, function(v)
    Settings.Enabled = v
end)

CreateToggle(MainFrame, 0.72, true, function(v)
    Settings.WallCheck = v
end)

CreateToggle(MainFrame, 0.84, false, function(v)
    Settings.TeamCheck = v
end)

-- ========== ПЕРЕВІРКА ПКМ ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.IsAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Settings.IsAiming = false
    end
end)

-- ========== ОСНОВНА ЛОГІКА АІМБОТА ==========
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
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

local function GetClosestTarget()
    local closestTarget = nil
    local shortestDistance = Settings.FOV
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local part = GetAimPart(char)
                
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    
                    if onScreen then
                        local targetPos2D = Vector2.new(screenPos.X, screenPos.Y)
                        local distance = (targetPos2D - centerScreen).Magnitude
                        
                        if distance <= shortestDistance then
                            if IsVisible(part, char) then
                                shortestDistance = distance
                                closestTarget = part
                            end
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

-- ========== ОСНОВНИЙ ЦИКЛ ОНОВЛЕННЯ ==========
RunService.RenderStepped:Connect(function()
    if not Settings.Enabled or not Settings.IsAiming then return end

    local targetPart = GetClosestTarget()
    
    if targetPart then
        local targetPos = targetPart.Position
        
        -- Рандомізація зміщення
        if Settings.Randomization > 0 then
            local randomOffset = Vector3.new(
                math.random(-Settings.Randomization * 10, Settings.Randomization * 10) / 10,
                math.random(-Settings.Randomization * 10, Settings.Randomization * 10) / 10,
                math.random(-Settings.Randomization * 10, Settings.Randomization * 10) / 10
            )
            targetPos = targetPos + randomOffset
        end

        local cameraPos = Camera.CFrame.Position
        local targetCFrame = CFrame.new(cameraPos, targetPos)

        -- РОЗРАХУНОК ШВИДКОСТІ (1 = 1.0 / прилипання, 10 = 0.05 / слабка доводка)
        local lerpAlpha
        if Settings.Speed == 1 then
            lerpAlpha = 1.0
        else
            -- Масштабування від 0.85 (Speed 2) до 0.05 (Speed 10)
            lerpAlpha = 0.85 - ((Settings.Speed - 2) * 0.1)
            lerpAlpha = math.clamp(lerpAlpha, 0.05, 1.0)
        end

        if lerpAlpha >= 1.0 then
            Camera.CFrame = targetCFrame
        else
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, lerpAlpha)
        end
    end
end)

-- ========== ВІДКРИТТЯ / ЗАКРИТТЯ НА RIGHT SHIFT ==========
local IsOpen = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        IsOpen = not IsOpen
        MainFrame.Visible = IsOpen
        FOVCircle.Visible = IsOpen
    end
end)

print("✅ ENHANCED GLASS UI + AIMBOT READY!")
