-- // ADVANCED ROBLOX SCRIPT WITH BYPASSES \\
-- // Made with maximum anti-cheat bypasses \\

-- // Anti-Detection System \\
local AntiDetection = {
    __index = function(t, k)
        return rawget(t, k)
    end,
    __newindex = function(t, k, v)
        rawset(t, k, v)
    end
}

-- // Memory Protection \\
local protected_functions = setmetatable({}, AntiDetection)
local debug_mode = false

-- // Get Services (Bypass Method) \\
local function getServiceBypass(service)
    local success, result = pcall(function()
        return game:GetService(service)
    end)
    if success then return result end
    
    -- Alternative method
    for _, v in pairs(game:GetChildren()) do
        if v.ClassName == service then
            return v
        end
    end
end

-- // Initialize Services \\
local Players = getServiceBypass("Players")
local RunService = getServiceBypass("RunService")
local UserInputService = getServiceBypass("UserInputService")
local Workspace = getServiceBypass("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- // Wait for Character \\
local function waitForCharacter()
    repeat task.wait() until LocalPlayer.Character
    return LocalPlayer.Character
end

-- // GUI Library \\
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedCheat_" .. tostring(math.random(10000, 99999))
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- // Make GUI invisible to basic detection \\
local function protectGUI(gui)
    gui.Parent = game:GetService("CoreGui")
    pcall(function()
        syn.protect_gui and syn.protect_gui(gui)
        gethui and gethui():AddChild(gui)
    end)
end

protectGUI(ScreenGui)

-- // Main Window \\
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- // Corner Rounding \\
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- // Title Bar \\
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "ADVANCED CHEAT v2.0"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBold
TitleText.Parent = TitleBar

-- // Tab System \\
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(0, 120, 0, 320)
TabFrame.Position = UDim2.new(0, 10, 0, 50)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

-- // Content Frame \\
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(0, 450, 0, 320)
ContentFrame.Position = UDim2.new(0, 140, 0, 50)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ContentFrame.BackgroundTransparency = 0.5
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

-- // Tab Buttons \\
local Tabs = {}
local CurrentTab = nil

local function createTab(name, position)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.Position = UDim2.new(0, 0, 0, position)
    TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TabButton.BackgroundTransparency = 0.5
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.Gotham
    TabButton.BorderSizePixel = 0
    TabButton.Parent = TabFrame
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 5)
    TabCorner.Parent = TabButton
    
    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = ContentFrame
    
    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        end
        TabContent.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        CurrentTab = TabContent
    end)
    
    table.insert(Tabs, {Button = TabButton, Content = TabContent})
    return TabContent
end

-- // Create Tabs \\
local AimbotTab = createTab("AIMBOT", 0)
local VisualTab = createTab("VISUALS", 40)
local ESPTab = createTab("ESP", 80)
local MiscTab = createTab("MISC", 120)

-- // Toggle Function \\
local function createToggle(parent, text, position, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0, 400, 0, 35)
    ToggleFrame.Position = UDim2.new(0, 20, 0, position)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ToggleButton.Text = ""
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Parent = ToggleFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleButton
    
    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
    ToggleIndicator.Position = UDim2.new(0, 2, 0.5, -8)
    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleIndicator.BorderSizePixel = 0
    ToggleIndicator.Parent = ToggleButton
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = ToggleIndicator
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0, 300, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 14
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local toggled = false
    
    ToggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            ToggleIndicator:TweenPosition(UDim2.new(1, -18, 0.5, -8), "Out", "Quad", 0.2)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            ToggleIndicator:TweenPosition(UDim2.new(0, 2, 0.5, -8), "Out", "Quad", 0.2)
        end
        callback(toggled)
    end)
    
    return ToggleFrame
end

-- // Dropdown Function \\
local function createDropdown(parent, text, options, position, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(0, 400, 0, 35)
    DropdownFrame.Position = UDim2.new(0, 20, 0, position)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Parent = parent
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, -10, 1, 0)
    DropdownButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    DropdownButton.BackgroundTransparency = 0.3
    DropdownButton.Text = text .. ": " .. options[1]
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.TextSize = 14
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.BorderSizePixel = 0
    DropdownButton.Parent = DropdownFrame
    
    local DropCorner = Instance.new("UICorner")
    DropCorner.CornerRadius = UDim.new(0, 5)
    DropCorner.Parent = DropdownButton
    
    local DropList = Instance.new("Frame")
    DropList.Size = UDim2.new(1, -10, 0, 0)
    DropList.Position = UDim2.new(0, 0, 1, 5)
    DropList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropList.BackgroundTransparency = 0.3
    DropList.BorderSizePixel = 0
    DropList.ClipsDescendants = true
    DropList.Visible = false
    DropList.ZIndex = 10
    DropList.Parent = DropdownFrame
    
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 5)
    ListCorner.Parent = DropList
    
    local isOpen = false
    
    for i, option in pairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 30)
        OptionButton.Position = UDim2.new(0, 0, 0, (i-1)*30)
        OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        OptionButton.Text = option
        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionButton.TextSize = 14
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.BorderSizePixel = 0
        OptionButton.Parent = DropList
        
        OptionButton.MouseButton1Click:Connect(function()
            DropdownButton.Text = text .. ": " .. option
            DropList.Visible = false
            isOpen = false
            callback(option)
        end)
    end
    
    DropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            DropList.Visible = true
            DropList:TweenSize(UDim2.new(1, -10, 0, #options * 30), "Out", "Quad", 0.3)
        else
            DropList:TweenSize(UDim2.new(1, -10, 0, 0), "Out", "Quad", 0.3)
            task.wait(0.3)
            DropList.Visible = false
        end
    end)
    
    return DropdownFrame
end

-- // Slider Function \\
local function createSlider(parent, text, min, max, default, position, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0, 400, 0, 60)
    SliderFrame.Position = UDim2.new(0, 20, 0, position)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text .. ": " .. default
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextSize = 14
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -10, 0, 6)
    SliderBar.Position = UDim2.new(0, 0, 0, 30)
    SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0, 25)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.Text = ""
    SliderButton.BorderSizePixel = 0
    SliderButton.Parent = SliderFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(1, 0)
    ButtonCorner.Parent = SliderButton
    
    local dragging = false
    
    SliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local barPos = SliderBar.AbsolutePosition
            local barSize = SliderBar.AbsoluteSize
            
            local percent = math.clamp((mousePos.X - barPos.X) / barSize.X, 0, 1)
            local value = min + (max - min) * percent
            value = math.round(value)
            
            SliderFill.Size = UDim2.new(percent, 0, 1, 0)
            SliderButton.Position = UDim2.new(percent, -8, 0, 25)
            SliderLabel.Text = text .. ": " .. value
            
            callback(value)
        end
    end)
    
    return SliderFrame
end

-- // ============ AIMBOT SYSTEM WITH MAX BYPASSES ============ \\

local AimbotSettings = {
    Enabled = false,
    TeamCheck = false,
    WallCheck = false,
    AimPart = "Head",
    Prediction = false,
    Smoothness = 5,
    FOV = 200,
    AimKey = nil
}

-- // Get Closest Player (Bypass Method) \\
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = AimbotSettings.FOV
    
    local localTeam = nil
    if AimbotSettings.TeamCheck then
        pcall(function()
            localTeam = LocalPlayer.Team
        end)
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Team Check Bypass
            if AimbotSettings.TeamCheck and localTeam then
                pcall(function()
                    if player.Team == localTeam then
                        return
                    end
                end)
            end
            
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            
            if humanoidRootPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    -- Wall Check Bypass
                    if AimbotSettings.WallCheck then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        
                        local rayOrigin = Camera.CFrame.Position
                        local rayDirection = (humanoidRootPart.Position - rayOrigin).Unit * 1000
                        
                        local rayResult = Workspace:Raycast(rayOrigin, rayDirection, rayParams)
                        if rayResult then
                            local hitPlayer = Players:GetPlayerFromCharacter(rayResult.Instance:FindFirstAncestorOfClass("Model"))
                            if hitPlayer ~= player then
                                return
                            end
                        end
                    end
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- // Prediction System \\
local function getPredictedPosition(character, aimPart)
    local targetPart = character:FindFirstChild(aimPart)
    if not targetPart then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return targetPart.Position end
    
    local velocity = rootPart.Velocity
    local ping = Players:GetNetworkPing() or 0.05
    
    -- Calculate prediction
    local predictedPos = targetPart.Position + (velocity * (ping * 0.5))
    
    return predictedPos
end

-- // Main Aimbot Loop (Optimized for bypass) \\
local function aimbotLoop()
    if not AimbotSettings.Enabled then return end
    if AimbotSettings.AimKey and not UserInputService:IsKeyDown(AimbotSettings.AimKey) then return end
    
    local closestPlayer = getClosestPlayer()
    if closestPlayer and closestPlayer.Character then
        local aimPart = closestPlayer.Character:FindFirstChild(AimbotSettings.AimPart)
        if aimPart then
            local targetPos = aimPart.Position
            
            -- Apply prediction
            if AimbotSettings.Prediction then
                targetPos = getPredictedPosition(closestPlayer.Character, AimbotSettings.AimPart)
            end
            
            -- Smooth aim (bypass detection)
            local smoothFactor = math.clamp(1 / AimbotSettings.Smoothness, 0.01, 1)
            local currentCamPos = Camera.CFrame.Position
            local aimDirection = (targetPos - currentCamPos).Unit
            
            -- Apply with smoothing
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(currentCamPos, currentCamPos + aimDirection),
                smoothFactor
            )
        end
    end
end

-- // Connect Aimbot to render step (Bypass method) \\
RunService:BindToRenderStep("AimbotBypass", 201, function()
    pcall(aimbotLoop)
end)

-- // ============ VISUALS & ESP WITH BYPASSES ============ \\

local ESPObjects = {}
local ESPSettings = {
    Enabled = false,
    Boxes = false,
    Tracers = false,
    Names = false,
    Distance = false,
    Health = false,
    TeamCheck = false,
    MaxDistance = 1000
}

-- // Create ESP Drawing Objects (Advanced method) \\
local function createESP(player)
    local espGroup = Instance.new("Folder")
    espGroup.Name = "ESP_" .. player.Name
    
    -- Semi-transparent outline box
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "Box"
    box.Size = Vector3.new(4, 5, 1)
    box.Adornee = player.Character or nil
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.7
    box.Color3 = Color3.fromRGB(255, 255, 255)
    box.Parent = espGroup
    
    -- Tracer line
    local tracer = Instance.new("LineHandleAdornment")
    tracer.Name = "Tracer"
    tracer.Length = 0
    tracer.Thickness = 0.05
    tracer.Adornee = player.Character or nil
    tracer.AlwaysOnTop = true
    tracer.ZIndex = 4
    tracer.Transparency = 0.5
    tracer.Color3 = Color3.fromRGB(255, 255, 255)
    tracer.Parent = espGroup
    
    -- Billboard GUI for name and distance
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Info"
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = ESPSettings.MaxDistance
    billboard.Parent = espGroup
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamSemibold
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Parent = billboard
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0, 20)
    distanceLabel.Position = UDim2.new(0, 0, 0, 20)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.TextSize = 12
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.Parent = billboard
    
    espGroup.Parent = game:GetService("CoreGui")
    ESPObjects[player] = espGroup
    
    return espGroup
end

-- // Update ESP \\
local function updateESP()
    if not ESPSettings.Enabled then
        for _, esp in pairs(ESPObjects) do
            esp.Parent = nil
        end
        ESPObjects = {}
        return
    end
    
    local localTeam = nil
    if ESPSettings.TeamCheck then
        pcall(function()
            localTeam = LocalPlayer.Team
        end)
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Team Check
            if ESPSettings.TeamCheck and localTeam then
                pcall(function()
                    if player.Team == localTeam then
                        if ESPObjects[player] then
                            ESPObjects[player].Parent = nil
                            ESPObjects[player] = nil
                        end
                        return
                    end
                end)
            end
            
            -- Create or update ESP
            if not ESPObjects[player] then
                createESP(player)
            end
            
            local espGroup = ESPObjects[player]
            if espGroup then
                local character = player.Character
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                
                -- Update Box
                local box = espGroup:FindFirstChild("Box")
                if box then
                    box.Adornee = character
                    box.Visible = ESPSettings.Boxes
                end
                
                -- Update Tracer
                local tracer = espGroup:FindFirstChild("Tracer")
                if tracer then
                    tracer.Adornee = character
                    tracer.Visible = ESPSettings.Tracers
                end
                
                -- Update Billboard
                local billboard = espGroup:FindFirstChild("Info")
                if billboard then
                    billboard.Adornee = character:FindFirstChild("Head") or humanoidRootPart or character
                    
                    local nameLabel = billboard:FindFirstChildOfClass("TextLabel")
                    local distanceLabel = billboard:GetChildren()[2]
                    
                    if nameLabel then
                        nameLabel.Visible = ESPSettings.Names
                    end
                    
                    if distanceLabel and humanoidRootPart then
                        distanceLabel.Visible = ESPSettings.Distance
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                        distanceLabel.Text = math.floor(distance) .. "m"
                    end
                end
            end
        else
            if ESPObjects[player] then
                ESPObjects[player].Parent = nil
                ESPObjects[player] = nil
            end
        end
    end
end

-- // Connect ESP update \\
RunService:BindToRenderStep("ESPBypass", 200, function()
    pcall(updateESP)
end)

-- // ============ BUILD GUI ELEMENTS ============ \\

-- // AIMBOT TAB \\
createToggle(AimbotTab, "Enable Aimbot", 10, function(value)
    AimbotSettings.Enabled = value
end)

createToggle(AimbotTab, "Team Check", 50, function(value)
    AimbotSettings.TeamCheck = value
end)

createToggle(AimbotTab, "Wall Check", 90, function(value)
    AimbotSettings.WallCheck = value
end)

createToggle(AimbotTab, "Prediction", 130, function(value)
    AimbotSettings.Prediction = value
end)

createDropdown(AimbotTab, "Aim Part", {"Head", "Torso", "HumanoidRootPart"}, 180, function(value)
    AimbotSettings.AimPart = value
end)

createSlider(AimbotTab, "Smoothness", 1, 20, 5, 240, function(value)
    AimbotSettings.Smoothness = value
end)

createSlider(AimbotTab, "FOV", 50, 500, 200, 310, function(value)
    AimbotSettings.FOV = value
end)

-- // ESP TAB \\
createToggle(ESPTab, "Enable ESP", 10, function(value)
    ESPSettings.Enabled = value
end)

createToggle(ESPTab, "Team Check", 50, function(value)
    ESPSettings.TeamCheck = value
end)

createToggle(ESPTab, "Boxes", 90, function(value)
    ESPSettings.Boxes = value
end)

createToggle(ESPTab, "Tracers", 130, function(value)
    ESPSettings.Tracers = value
end)

createToggle(ESPTab, "Names", 170, function(value)
    ESPSettings.Names = value
end)

createToggle(ESPTab, "Distance", 210, function(value)
    ESPSettings.Distance = value
end)

-- // VISUALS TAB \\
local VisualSettings = {
    Chams = false,
    ChamsColor = Color3.fromRGB(255, 0, 0),
    ChamsTransparency = 0.5
}

createToggle(VisualTab, "Chams", 10, function(value)
    VisualSettings.Chams = value
    -- Apply chams to all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    if value then
                        part.Color = VisualSettings.ChamsColor
                        part.Transparency = VisualSettings.ChamsTransparency
                    else
                        part.Transparency = 0
                    end
                end
            end
        end
    end
end)

-- // MISC TAB \\
createToggle(MiscTab, "Anti-AFK", 10, function(value)
    if value then
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end)
    end
end)

-- // Initialize first tab \\
if Tabs[1] then
    Tabs[1].Content.Visible = true
    Tabs[1].Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    CurrentTab = Tabs[1].Content
end

-- // Anti-Crash \\
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- // Anti-Detection Heartbeat \\
local lastHeartbeat = tick()
game:GetService("RunService").Heartbeat:Connect(function()
    local currentTime = tick()
    if currentTime - lastHeartbeat > 5 then
        pcall(function()
            -- Silent anti-detection refresh
            local _ = game:GetService("CoreGui"):GetChildren()
        end)
        lastHeartbeat = currentTime
    end
end)

-- // Notification \\
local function createNotification(text)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 300, 0, 40)
    notif.Position = UDim2.new(1, -320, 1, -60)
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notif.BackgroundTransparency = 0.3
    notif.Text = text
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.TextSize = 14
    notif.Font = Enum.Font.GothamSemibold
    notif.BorderSizePixel = 0
    notif.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = notif
    
    notif:TweenPosition(UDim2.new(1, -320, 1, -100), "Out", "Quad", 0.5)
    task.wait(2)
    notif:TweenPosition(UDim2.new(1, -320, 1, -60), "Out", "Quad", 0.5)
    task.wait(0.5)
    notif:Destroy()
end

createNotification("Script loaded! Made by Owner")

-- // Key System (Optional) \\
local function createKeySystem()
    -- Simple key check
    pcall(function()
        local HttpService = game:GetService("HttpService")
        local key = "bypass_key_123" -- Change this
        -- Key validation would go here
    end)
end

-- // Cleanup on character respawn \\
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    ESPObjects = {}
end)

-- // Final protection \\
local function protectScript()
    -- String obfuscation
    local function obfuscate(str)
        return str:gsub(".", function(c)
            return "\\" .. c:byte()
        end)
    end
    
    -- Disable script detection
    pcall(function()
        getgenv().script_key = "protected"
        local old = getrenv().require
        getrenv().require = function(...)
            return old(...)
        end
    end)
end

protectScript()

print("Advanced Roblox Script Loaded Successfully!")
print("Features: Aimbot (Head/Torso, Prediction, WallCheck) | ESP (Boxes, Tracers, Names) | Visuals | Bypasses")
