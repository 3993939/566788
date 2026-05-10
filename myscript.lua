-- Universal GUI Menu + ESP + Smooth Silent Aim by Colin
-- Full package for the villagers

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ========== БІБЛІОТЕКА ==========
local DrawingLib = {}
DrawingLib.Objects = {}

function DrawingLib:Create(type, props)
    local drawing = Drawing.new(type)
    for prop, value in pairs(props) do
        drawing[prop] = value
    end
    table.insert(DrawingLib.Objects, drawing)
    return drawing
end

function DrawingLib:ClearAll()
    for _, v in pairs(DrawingLib.Objects) do
        pcall(function() v:Remove() end)
    end
    table.clear(DrawingLib.Objects)
end

-- ========== НАЛАШТУВАННЯ ==========
local Settings = {
    ESP = {
        Enabled = false,
        Players = true,
        TeamCheck = true,
        Health = true,
        Distance = true,
        Boxes = true,
        Tracers = true,
        HeadDots = true,
        MaxDistance = 3000,
        BoxColor = Color3.fromRGB(255, 255, 255),
        TracerColor = Color3.fromRGB(255, 255, 255)
    },
    Aimbot = {
        Enabled = false,
        AimKey = "MouseButton2",
        HitPart = "Head",
        Smoothness = 0.06,
        FOV = 200,
        ShowFOV = true,
        FOVColor = Color3.fromRGB(255, 255, 255),
        TeamCheck = true,
        WallCheck = true,
        MaxDistance = 3000
    },
    Visuals = {
        FOVColor = Color3.fromRGB(255, 255, 255),
        MenuColor = Color3.fromRGB(65, 105, 225),
        AccentColor = Color3.fromRGB(255, 50, 80),
        BackgroundColor = Color3.fromRGB(30, 30, 30)
    }
}

local ESP_Cache = {}
local Aimbot = {Target = nil, FOVCircle = nil}
local Connections = {}

-- ========== ESP ФУНКЦІЇ ==========
local function IsBehindWall(targetPart)
    if not Settings.Aimbot.WallCheck then return false end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return true end
    
    local origin = LocalPlayer.Character.Head.Position
    local direction = (targetPart.Position - origin).Unit * Settings.Aimbot.MaxDistance
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    if raycastResult then
        return not raycastResult.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

local function UpdateESP()
    DrawingLib:ClearAll()
    if not Settings.ESP.Enabled then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPos = LocalPlayer.Character.HumanoidRootPart.Position
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hum = plr.Character.Humanoid
            local hrp = plr.Character.HumanoidRootPart
            local head = plr.Character:FindFirstChild("Head")
            
            if hum.Health > 0 and head then
                local dist = (hrp.Position - rootPos).Magnitude
                
                if dist <= Settings.ESP.MaxDistance then
                    if Settings.ESP.TeamCheck and plr.TeamColor == LocalPlayer.TeamColor then
                        goto continue
                    end
                    
                    local color = Settings.ESP.BoxColor
                    local label = plr.Name
                    if Settings.ESP.Health then label = label .. " [" .. math.floor(hum.Health) .. " HP]" end
                    if Settings.ESP.Distance then label = label .. " [" .. math.floor(dist) .. "m]" end
                    
                    -- Бокс
                    if Settings.ESP.Boxes then
                        DrawingLib:Create("Square", {
                            Color = color, Thickness = 2, Transparency = 1, Filled = false, Visible = true,
                            Size = Vector2.new(0, 0), Position = Vector2.new(0, 0)
                        })
                    end
                    
                    -- Трейсер
                    if Settings.ESP.Tracers then
                        DrawingLib:Create("Line", {
                            Color = Settings.ESP.TracerColor, Thickness = 1, Transparency = 0.8, Visible = true,
                            From = Vector2.new(0, 0), To = Vector2.new(0, 0)
                        })
                    end
                    
                    -- Текст
                    DrawingLib:Create("Text", {
                        Color = color, Size = 14, Center = true, Outline = true,
                        OutlineColor = Color3.new(0, 0, 0), Text = label, Visible = true,
                        Position = Vector2.new(0, 0)
                    })
                end
            end
        end
        ::continue::
    end
end

local function RenderESP()
    local index = 1
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                if index <= #DrawingLib.Objects then
                    local scale = math.clamp(2000 / (Camera.CFrame.Position - head.Position).Magnitude, 0.5, 4)
                    local boxSize = Vector2.new(math.floor(scale * 2.5), math.floor(scale * 3.5))
                    
                    -- Бокс
                    if Settings.ESP.Boxes and DrawingLib.Objects[index] then
                        DrawingLib.Objects[index].Size = boxSize
                        DrawingLib.Objects[index].Position = Vector2.new(screenPos.X - boxSize.X/2, screenPos.Y - boxSize.Y/2)
                    end
                    if Settings.ESP.Boxes then index = index + 1 end
                    
                    -- Трейсер
                    if Settings.ESP.Tracers and DrawingLib.Objects[index] then
                        DrawingLib.Objects[index].From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        DrawingLib.Objects[index].To = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y/2)
                    end
                    if Settings.ESP.Tracers then index = index + 1 end
                    
                    -- Текст
                    if DrawingLib.Objects[index] then
                        DrawingLib.Objects[index].Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y/2 - 20)
                    end
                    index = index + 1
                end
            end
        end
    end
end

-- ========== АІМБОТ ФУНКЦІЇ ==========
local function GetAimTarget()
    local bestDist = Settings.Aimbot.FOV
    local bestTarget = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChild("Humanoid")
            local hitPart = plr.Character:FindFirstChild(Settings.Aimbot.HitPart)
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            
            if hum and hitPart and hrp and hum.Health > 0 then
                if Settings.Aimbot.TeamCheck and plr.TeamColor == LocalPlayer.TeamColor then continue end
                
                local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist > Settings.Aimbot.MaxDistance then continue end
                if Settings.Aimbot.WallCheck and IsBehindWall(hitPart) then continue end
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
                if onScreen then
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if screenDist < bestDist then
                        bestDist = screenDist
                        bestTarget = {Part = hitPart, Player = plr}
                    end
                end
            end
        end
    end
    return bestTarget
end

local function PerformAim()
    local aimKey = Settings.Aimbot.AimKey
    if aimKey == "MouseButton1" then aimKey = "MouseButton1"
    elseif aimKey == "MouseButton2" then aimKey = "MouseButton2"
    else aimKey = "MouseButton1" end
    
    if Settings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType[aimKey]) then
        if not Aimbot.Target or not Aimbot.Target.Part.Parent then
            Aimbot.Target = GetAimTarget()
        end
        if Aimbot.Target then
            local targetDir = (Aimbot.Target.Part.Position - Camera.CFrame.Position).Unit
            local smoothDir = Camera.CFrame.LookVector:Lerp(targetDir, Settings.Aimbot.Smoothness)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + smoothDir)
        end
    else
        Aimbot.Target = nil
    end
end

local function UpdateFOVCircle()
    if Aimbot.FOVCircle then
        Aimbot.FOVCircle.Visible = Settings.Aimbot.Enabled and Settings.Aimbot.ShowFOV
        Aimbot.FOVCircle.Radius = Settings.Aimbot.FOV
        Aimbot.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        Aimbot.FOVCircle.Color = Settings.Aimbot.FOVColor
    end
end

-- ========== GUI МЕНЮ ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ColinsMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = (syn and syn.protect_gui and CoreGui or gethui and gethui() or CoreGui)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Settings.Visuals.BackgroundColor
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Settings.Visuals.MenuColor
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local UICorner2 = Instance.new("UICorner", TopBar)
UICorner2.CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Text = " Colin's Survival Menu [F4]"
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Text = "×"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Settings.Visuals.AccentColor
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 20
CloseButton.Parent = TopBar

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0, 120, 1, -40)
TabFrame.Position = UDim2.new(0, 0, 0, 40)
TabFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -120, 1, -40)
ContentFrame.Position = UDim2.new(0, 120, 0, 40)
ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local Tabs = {}
local TabButtons = {}
local ActiveTab = "ESP"

-- Функція перемикання вкладок
local function SwitchTab(tabName)
    ActiveTab = tabName
    for _, frame in pairs(Tabs) do frame.Visible = false end
    if Tabs[tabName] then Tabs[tabName].Visible = true end
    for name, btn in pairs(TabButtons) do
        btn.BackgroundColor3 = name == tabName and Settings.Visuals.MenuColor or Color3.fromRGB(50, 50, 50)
    end
end

-- Створення вкладок
local tabNames = {"ESP", "Aimbot", "Visuals"}
for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Text = "  " .. name
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, (i-1)*40)
    btn.BackgroundColor3 = name == "ESP" and Settings.Visuals.MenuColor or Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = TabFrame
    TabButtons[name] = btn
    
    local frame = Instance.new("ScrollingFrame")
    frame.Size = UDim2.new(1, -10, 1, -10)
    frame.Position = UDim2.new(0, 5, 0, 5)
    frame.BackgroundTransparency = 1
    frame.ScrollBarThickness = 4
    frame.ScrollBarImageColor3 = Settings.Visuals.MenuColor
    frame.CanvasSize = UDim2.new(0, 0, 0, 500)
    frame.Visible = name == "ESP"
    frame.Parent = ContentFrame
    Tabs[name] = frame
    
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
end

-- Функція створення тоглу
local function CreateToggle(parent, name, settingTable, settingKey, yOffset)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.Position = UDim2.new(0, 5, 0, yOffset)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Text = settingTable[settingKey] and "ON" or "OFF"
    toggleBtn.Size = UDim2.new(0, 50, 0, 22)
    toggleBtn.Position = UDim2.new(1, -60, 0, 4)
    toggleBtn.BackgroundColor3 = settingTable[settingKey] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 12
    toggleBtn.Parent = frame
    
    toggleBtn.MouseButton1Click:Connect(function()
        settingTable[settingKey] = not settingTable[settingKey]
        toggleBtn.Text = settingTable[settingKey] and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = settingTable[settingKey] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    end)
    
    return frame
end

-- Створення тоглів ESP
local espToggles = {
    {"ESP Enabled", "Enabled"},
    {"Show Players", "Players"},
    {"Team Check", "TeamCheck"},
    {"Show Health", "Health"},
    {"Show Distance", "Distance"},
    {"Show Boxes", "Boxes"},
    {"Show Tracers", "Tracers"},
    {"Show Head Dots", "HeadDots"}
}

for i, toggle in ipairs(espToggles) do
    CreateToggle(Tabs["ESP"], toggle[1], Settings.ESP, toggle[2], (i-1)*35)
end

-- Створення тоглів Aimbot
local aimToggles = {
    {"Aimbot Enabled", "Enabled"},
    {"Show FOV Circle", "ShowFOV"},
    {"Team Check", "TeamCheck"},
    {"Wall Check", "WallCheck"}
}

for i, toggle in ipairs(aimToggles) do
    CreateToggle(Tabs["Aimbot"], toggle[1], Settings.Aimbot, toggle[2], (i-1)*35)
end

-- Функція слайдера
local function CreateSlider(parent, name, settingTable, settingKey, minVal, maxVal, yOffset)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.Position = UDim2.new(0, 5, 0, yOffset)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Text = name .. ": " .. tostring(settingTable[settingKey])
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -20, 0, 6)
    sliderFrame.Position = UDim2.new(0, 10, 0, 30)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = frame
    
    local sliderFill = Instance.new("Frame")
    local ratio = (settingTable[settingKey] - minVal) / (maxVal - minVal)
    sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    sliderFill.BackgroundColor3 = Settings.Visuals.MenuColor
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderFrame
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Text = ""
    sliderBtn.Size = UDim2.new(0, 14, 0, 14)
    sliderBtn.Position = UDim2.new(ratio, -7, 0.5, -7)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderBtn.BorderSizePixel = 0
    sliderBtn.Text = ""
    sliderBtn.Parent = sliderFrame
    
    local dragging = false
    sliderBtn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    sliderBtn.MouseButton1Click:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        local sliderPos = sliderFrame.AbsolutePosition.X
        local sliderWidth = sliderFrame.AbsoluteSize.X
        local ratio = math.clamp((mousePos.X - sliderPos) / sliderWidth, 0, 1)
        local value = minVal + (maxVal - minVal) * ratio
        settingTable[settingKey] = value
        label.Text = name .. ": " .. string.format("%.2f", value)
        sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        sliderBtn.Position = UDim2.new(ratio, -7, 0.5, -7)
    end)
    
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderFrame.AbsolutePosition.X
            local sliderWidth = sliderFrame.AbsoluteSize.X
            local ratio = math.clamp((mousePos.X - sliderPos) / sliderWidth, 0, 1)
            local value = minVal + (maxVal - minVal) * ratio
            settingTable[settingKey] = value
            label.Text = name .. ": " .. string.format("%.2f", value)
            sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
            sliderBtn.Position = UDim2.new(ratio, -7, 0.5, -7)
        end
    end)
end

CreateSlider(Tabs["Aimbot"], "Smoothness", Settings.Aimbot, "Smoothness", 0.01, 1, 140)
CreateSlider(Tabs["Aimbot"], "FOV Radius", Settings.Aimbot, "FOV", 50, 500, 195)
CreateSlider(Tabs["Aimbot"], "Max Distance", Settings.Aimbot, "MaxDistance", 500, 10000, 250)

-- Закриття меню
CloseButton.MouseButton1Click:Connect(function() ScreenGui:Enabled = false end)

-- Тогл меню на F4
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Створення FOV кола
Aimbot.FOVCircle = DrawingLib:Create("Circle", {
    Radius = Settings.Aimbot.FOV,
    Position = Vector2.new(0, 0),
    Color = Settings.Aimbot.FOVColor,
    Transparency = 0.7,
    Thickness = 1,
    Filled = false,
    Visible = false
})

-- Головні цикли
RunService.Heartbeat:Connect(function()
    UpdateFOVCircle()
    UpdateESP()
    PerformAim()
end)

RunService.RenderStepped:Connect(function()
    RenderESP()
end)

-- Очищення при закритті
ScreenGui.Destroying:Connect(function()
    DrawingLib:ClearAll()
    for _, conn in pairs(Connections) do pcall(function() conn:Disconnect() end) end
end)

print("Colin's Universal Menu Loaded! Press F4 to toggle menu.")
