-- Universal GUI Menu + ESP + Smooth Silent Aim by Colin [FIXED]
-- Fixed: Drawing library compatibility, CoreGui access

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== БЕЗПЕЧНЕ СТВОРЕННЯ GUI ==========
local function GetSafeGui()
    local success, result = pcall(function()
        if syn and syn.protect_gui then
            return game:GetService("CoreGui")
        end
    end)
    if success and result then return result end
    
    success, result = pcall(function()
        if gethui then return gethui() end
    end)
    if success and result then return result end
    
    success, result = pcall(function()
        if get_hidden_gui then return get_hidden_gui() end
    end)
    if success and result then return result end
    
    success, result = pcall(function()
        return game:GetService("CoreGui")
    end)
    if success then return result end
    
    return nil
end

local CoreGui = GetSafeGui()
if not CoreGui then
    warn("Cannot access CoreGui, using PlayerGui instead")
    CoreGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- ========== БЕЗПЕЧНА БІБЛІОТЕКА МАЛЮВАННЯ ==========
local DrawingLib = {}
DrawingLib.Objects = {}
DrawingLib.Available = false

-- Перевірка доступності Drawing
local function CheckDrawing()
    local success = pcall(function()
        local test = Drawing.new("Line")
        if test then
            test:Remove()
            return true
        end
    end)
    return success
end

DrawingLib.Available = CheckDrawing()

function DrawingLib:Create(type, props)
    if not DrawingLib.Available then return nil end
    
    local success, drawing = pcall(function()
        local d = Drawing.new(type)
        for prop, value in pairs(props) do
            pcall(function() d[prop] = value end)
        end
        return d
    end)
    
    if success and drawing then
        table.insert(DrawingLib.Objects, drawing)
        return drawing
    end
    return nil
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
        MenuColor = Color3.fromRGB(65, 105, 225),
        AccentColor = Color3.fromRGB(255, 50, 80),
        BackgroundColor = Color3.fromRGB(30, 30, 30)
    }
}

local Aimbot = {Target = nil, FOVCircle = nil}
local ESPCache = {}

-- ========== ESP ФУНКЦІЇ (ВИПРАВЛЕНО) ==========
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
    if not DrawingLib.Available then return end
    DrawingLib:ClearAll()
    ESPCache = {}
    
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
                    if Settings.ESP.TeamCheck then
                        if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                            goto continue
                        end
                        if plr.TeamColor and LocalPlayer.TeamColor and plr.TeamColor == LocalPlayer.TeamColor then
                            goto continue
                        end
                    end
                    
                    local color = Settings.ESP.BoxColor
                    local label = plr.Name
                    if Settings.ESP.Health then label = label .. " [" .. math.floor(hum.Health) .. " HP]" end
                    if Settings.ESP.Distance then label = label .. " [" .. math.floor(dist) .. "m]" end
                    
                    local espData = {Head = head, Label = label, Color = color}
                    
                    if Settings.ESP.Boxes then
                        espData.Box = DrawingLib:Create("Square", {
                            Color = color, Thickness = 2, Transparency = 1, Filled = false, Visible = false
                        })
                    end
                    
                    if Settings.ESP.Tracers then
                        espData.Tracer = DrawingLib:Create("Line", {
                            Color = Settings.ESP.TracerColor, Thickness = 1, Transparency = 0.8, Visible = false
                        })
                    end
                    
                    espData.Text = DrawingLib:Create("Text", {
                        Color = color, Size = 14, Center = true, Outline = true,
                        OutlineColor = Color3.new(0, 0, 0), Text = label, Visible = false
                    })
                    
                    table.insert(ESPCache, espData)
                end
            end
        end
        ::continue::
    end
end

local function RenderESP()
    if not DrawingLib.Available then return end
    
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    
    for _, data in ipairs(ESPCache) do
        if data.Head and data.Head.Parent then
            local screenPos, onScreen = Camera:WorldToViewportPoint(data.Head.Position)
            
            if onScreen then
                local scale = math.clamp(2000 / math.max((Camera.CFrame.Position - data.Head.Position).Magnitude, 1), 0.5, 4)
                local boxSize = Vector2.new(math.floor(scale * 2.5), math.floor(scale * 3.5))
                
                if data.Box then
                    data.Box.Visible = true
                    data.Box.Size = boxSize
                    data.Box.Position = Vector2.new(screenPos.X - boxSize.X/2, screenPos.Y - boxSize.Y/2)
                end
                
                if data.Tracer then
                    data.Tracer.Visible = true
                    data.Tracer.From = screenCenter
                    data.Tracer.To = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y/2)
                end
                
                if data.Text then
                    data.Text.Visible = true
                    data.Text.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y/2 - 20)
                end
            else
                if data.Box then data.Box.Visible = false end
                if data.Tracer then data.Tracer.Visible = false end
                if data.Text then data.Text.Visible = false end
            end
        end
    end
end

-- ========== АІМБОТ (ВИПРАВЛЕНО) ==========
local function GetAimTarget()
    local bestDist = Settings.Aimbot.FOV
    local bestTarget = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end
        
        local hum = plr.Character:FindFirstChild("Humanoid")
        local hitPart = plr.Character:FindFirstChild(Settings.Aimbot.HitPart)
        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
        
        if not (hum and hitPart and hrp) then continue end
        if hum.Health <= 0 then continue end
        
        if Settings.Aimbot.TeamCheck then
            if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end
            if plr.TeamColor and LocalPlayer.TeamColor and plr.TeamColor == LocalPlayer.TeamColor then continue end
        end
        
        if not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then continue end
        local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if dist > Settings.Aimbot.MaxDistance then continue end
        if Settings.Aimbot.WallCheck and IsBehindWall(hitPart) then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
        if not onScreen then continue end
        
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if screenDist < bestDist then
            bestDist = screenDist
            bestTarget = {Part = hitPart, Player = plr}
        end
    end
    
    return bestTarget
end

local function PerformAim()
    if not Settings.Aimbot.Enabled then
        Aimbot.Target = nil
        return
    end
    
    local aimKeyPressed = false
    pcall(function()
        if Settings.Aimbot.AimKey == "MouseButton2" then
            aimKeyPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        elseif Settings.Aimbot.AimKey == "MouseButton1" then
            aimKeyPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        end
    end)
    
    if not aimKeyPressed then
        Aimbot.Target = nil
        return
    end
    
    if not Aimbot.Target or not Aimbot.Target.Part or not Aimbot.Target.Part.Parent then
        Aimbot.Target = GetAimTarget()
    end
    
    if Aimbot.Target and Aimbot.Target.Part then
        local targetDir = (Aimbot.Target.Part.Position - Camera.CFrame.Position).Unit
        local smoothDir = Camera.CFrame.LookVector:Lerp(targetDir, Settings.Aimbot.Smoothness)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + smoothDir)
    end
end

local function UpdateFOVCircle()
    if Aimbot.FOVCircle then
        pcall(function()
            Aimbot.FOVCircle.Visible = Settings.Aimbot.Enabled and Settings.Aimbot.ShowFOV
            Aimbot.FOVCircle.Radius = Settings.Aimbot.FOV
            Aimbot.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            Aimbot.FOVCircle.Color = Settings.Aimbot.FOVColor
        end)
    end
end

-- ========== GUI МЕНЮ ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ColinsMenu"
ScreenGui.ResetOnSpawn = false

-- Безпечний Parent
pcall(function()
    ScreenGui.Parent = CoreGui
end)

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

local function SwitchTab(tabName)
    ActiveTab = tabName
    for _, frame in pairs(Tabs) do
        frame.Visible = false
    end
    if Tabs[tabName] then
        Tabs[tabName].Visible = true
    end
    for name, btn in pairs(TabButtons) do
        btn.BackgroundColor3 = name == tabName and Settings.Visuals.MenuColor or Color3.fromRGB(50, 50, 50)
    end
end

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
    
    btn.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
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

-- ESP тогли
CreateToggle(Tabs["ESP"], "ESP Enabled", Settings.ESP, "Enabled", 0)
CreateToggle(Tabs["ESP"], "Team Check", Settings.ESP, "TeamCheck", 35)
CreateToggle(Tabs["ESP"], "Show Health", Settings.ESP, "Health", 70)
CreateToggle(Tabs["ESP"], "Show Distance", Settings.ESP, "Distance", 105)
CreateToggle(Tabs["ESP"], "Show Boxes", Settings.ESP, "Boxes", 140)
CreateToggle(Tabs["ESP"], "Show Tracers", Settings.ESP, "Tracers", 175)

-- Aimbot тогли
CreateToggle(Tabs["Aimbot"], "Aimbot Enabled", Settings.Aimbot, "Enabled", 0)
CreateToggle(Tabs["Aimbot"], "Show FOV Circle", Settings.Aimbot, "ShowFOV", 35)
CreateToggle(Tabs["Aimbot"], "Team Check", Settings.Aimbot, "TeamCheck", 70)
CreateToggle(Tabs["Aimbot"], "Wall Check", Settings.Aimbot, "WallCheck", 105)

-- Слайдери для Aimbot
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
    sliderBtn.Parent = sliderFrame
    
    local dragging = false
    
    local function updateSlider(input)
        local mousePos = UserInputService:GetMouseLocation()
        local sliderPos = sliderFrame.AbsolutePosition.X
        local sliderWidth = sliderFrame.AbsoluteSize.X
        local ratio = math.clamp((mousePos.X - sliderPos) / math.max(sliderWidth, 1), 0, 1)
        local value = minVal + (maxVal - minVal) * ratio
        if settingKey == "Smoothness" then
            value = math.round(value * 100) / 100
        else
            value = math.floor(value)
        end
        settingTable[settingKey] = value
        label.Text = name .. ": " .. tostring(value)
        sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        sliderBtn.Position = UDim2.new(ratio, -7, 0.5, -7)
    end
    
    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
        updateSlider()
    end)
    
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
end

CreateSlider(Tabs["Aimbot"], "Smoothness", Settings.Aimbot, "Smoothness", 0.01, 1, 150)
CreateSlider(Tabs["Aimbot"], "FOV Radius", Settings.Aimbot, "FOV", 50, 500, 205)
CreateSlider(Tabs["Aimbot"], "Max Distance", Settings.Aimbot, "MaxDistance", 500, 10000, 260)

-- Закриття
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

-- Тогл F4
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- FOV коло
if DrawingLib.Available then
    Aimbot.FOVCircle = DrawingLib:Create("Circle", {
        Radius = Settings.Aimbot.FOV,
        Position = Vector2.new(0, 0),
        Color = Settings.Aimbot.FOVColor,
        Transparency = 0.7,
        Thickness = 1,
        Filled = false,
        Visible = false
    })
end

-- Головні цикли
RunService.Heartbeat:Connect(function()
    UpdateFOVCircle()
    UpdateESP()
    PerformAim()
end)

RunService.RenderStepped:Connect(function()
    RenderESP()
end)

-- Безпечне очищення
ScreenGui.Destroying:Connect(function()
    DrawingLib:ClearAll()
end)

print("Colin's Universal Menu [FIXED] Loaded! F4 = toggle menu.")
print("ESP: " .. (DrawingLib.Available and "Drawing OK" or "Drawing disabled, GUI only"))
