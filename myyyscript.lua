--[[
    АІМБОТ ЗАВЖДИ АКТИВНИЙ (БЕЗ ПКМ) + ВИПРАВЛЕНИЙ ESP
    - Відкриття / Закриття: [RightShift]
    - Вкладки: Aimbot | ESP | Visuals
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========== ЗНИЩЕННЯ СТАРОГО GUI ==========
if CoreGui:FindFirstChild("AimbotGUI") then
    CoreGui.AimbotGUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ========== НАЛАШТУВАННЯ ==========
local Settings = {
    Enabled = true,
    Smoothness = 0.2,
    FOV = 200,
    WallCheck = true,
    TeamCheck = false,
    TargetMode = 1,
    Randomization = 0.05,
    ESPEnabled = false,
    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    FOVCircleEnabled = true,
    Crosshair = true,
}

-- ========== ГОЛОВНЕ ВІКНО ==========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 380)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.7
MainStroke.Parent = MainFrame

-- ========== БІЧНА ПАНЕЛЬ ==========
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 70, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Sidebar.BackgroundTransparency = 0.6
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 14)
SidebarCorner.Parent = Sidebar

-- ========== КОНТЕЙНЕР ВКЛАДОК ==========
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -80, 1, -16)
ContentArea.Position = UDim2.new(0, 75, 0, 8)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = MainFrame

local Tabs = {"Aimbot", "ESP", "Visuals"}
local TabFrames = {}
local TabButtons = {}

for i, name in ipairs(Tabs) do
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = (i == 1)
    frame.Parent = ContentArea
    TabFrames[name] = frame
end

local icons = {"🎯", "👁️", "🎨"}
for i, name in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 55)
    btn.Position = UDim2.new(0, 0, 0, 15 + (i-1) * 65)
    btn.BackgroundTransparency = 0.8
    btn.Text = icons[i] .. "\n" .. name
    btn.TextColor3 = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 170, 190)
    btn.TextSize = 11
    btn.TextWrapped = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = Sidebar
    
    btn.MouseButton1Click:Connect(function()
        for n, frame in pairs(TabFrames) do
            frame.Visible = (n == name)
        end
        for j, button in pairs(TabButtons) do
            button.TextColor3 = (j == i) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 170, 190)
            button.BackgroundTransparency = (j == i) and 0.6 or 0.8
        end
    end)
    TabButtons[i] = btn
end

-- ========== ФУНКЦІЇ GUI ==========
local function CreateSlider(parent, y, w, min, max, def, label, cb)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(w or 0.85, 0, 0, 38)
    frame.Position = UDim2.new(0.07, 0, y, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 0.4, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. string.format("%.2f", def)
    lbl.TextColor3 = Color3.fromRGB(210, 215, 225)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0.2, 0)
    track.Position = UDim2.new(0, 0, 0.6, 0)
    track.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
    track.BackgroundTransparency = 0.4
    track.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 70, 110)
    fill.BackgroundTransparency = 0.2
    fill.Parent = track

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((def - min) / (max - min), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BackgroundTransparency = 0.3
    knob.Parent = frame

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false
    local function update(val)
        val = math.clamp(val, min, max)
        local p = (val - min) / (max - min)
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, -6, 0.5, -6)
        lbl.Text = label .. ": " .. string.format("%.2f", val)
        cb(val)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            update(min + p * (max - min))
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local p = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            update(min + p * (max - min))
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function CreateToggle(parent, y, w, def, label, cb)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(w or 0.85, 0, 0, 28)
    frame.Position = UDim2.new(0.07, 0, y, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(210, 215, 225)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 38, 0, 18)
    sw.Position = UDim2.new(1, -42, 0.5, -9)
    sw.BackgroundColor3 = def and Color3.fromRGB(255, 70, 110) or Color3.fromRGB(50, 55, 70)
    sw.BackgroundTransparency = 0.3
    sw.Parent = frame

    local swCorner = Instance.new("UICorner")
    swCorner.CornerRadius = UDim.new(1, 0)
    swCorner.Parent = sw

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = def and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BackgroundTransparency = 0.2
    dot.Parent = sw

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local state = def
    sw.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            sw.BackgroundColor3 = state and Color3.fromRGB(255, 70, 110) or Color3.fromRGB(50, 55, 70)
            dot.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
            cb(state)
        end
    end)
end

local function CreateModeSelector(parent, y, w)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(w or 0.4, 0, 0, 32)
    frame.Position = UDim2.new(0.07, 0, y, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "Target: Head"
    lbl.TextColor3 = Color3.fromRGB(210, 215, 225)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.4, 0, 0.7, 0)
    btn.Position = UDim2.new(0.6, 0, 0.15, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 70, 110)
    btn.BackgroundTransparency = 0.3
    btn.Text = "Switch"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local modes = {"Head", "Torso", "Random"}
    local idx = 1
    btn.MouseButton1Click:Connect(function()
        idx = idx % 3 + 1
        Settings.TargetMode = idx
        lbl.Text = "Target: " .. modes[idx]
    end)
end

-- ========== ЗАПОВНЕННЯ ВКЛАДКИ AIMBOT ==========
local at = TabFrames["Aimbot"]
CreateSlider(at, 0.02, 0.45, 0.01, 0.5, 0.2, "Smoothness", function(v) Settings.Smoothness = v end)
CreateSlider(at, 0.15, 0.45, 30, 450, 200, "FOV", function(v)
    Settings.FOV = v
    if Settings.FOVCircleEnabled then
        FOVCircle.Size = UDim2.new(0, v * 2, 0, v * 2)
        FOVCircle.Position = UDim2.new(0.5, -v, 0.5, -v)
    end
end)
CreateSlider(at, 0.28, 0.45, 0, 0.2, 0.05, "Random", function(v) Settings.Randomization = v end)

CreateToggle(at, 0.42, 0.4, true, "Enabled", function(v) Settings.Enabled = v end)
CreateToggle(at, 0.52, 0.4, true, "Wall Check", function(v) Settings.WallCheck = v end)
CreateToggle(at, 0.62, 0.4, false, "Team Check", function(v) Settings.TeamCheck = v end)
CreateModeSelector(at, 0.42, 0.45)

-- ========== ЗАПОВНЕННЯ ВКЛАДКИ ESP ==========
local et = TabFrames["ESP"]
CreateToggle(et, 0.02, 0.9, false, "ESP Enabled", function(v) Settings.ESPEnabled = v end)
CreateToggle(et, 0.12, 0.9, true, "Box ESP", function(v) Settings.ESPBox = v end)
CreateToggle(et, 0.22, 0.9, true, "Name ESP", function(v) Settings.ESPName = v end)
CreateToggle(et, 0.32, 0.9, true, "Health Bar", function(v) Settings.ESPHealth = v end)

-- ========== ЗАПОВНЕННЯ ВКЛАДКИ VISUALS ==========
local vt = TabFrames["Visuals"]
CreateToggle(vt, 0.02, 0.9, true, "FOV Circle", function(v)
    Settings.FOVCircleEnabled = v
    FOVCircle.Visible = v
end)
CreateToggle(vt, 0.12, 0.9, true, "Crosshair", function(v)
    Settings.Crosshair = v
    Crosshair.Visible = v
end)

-- ========== FOV КОЛО (ВИДИМЕ) ==========
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = true
FOVCircle.ZIndex = 2
FOVCircle.Parent = ScreenGui

local FOVImg = Instance.new("ImageLabel")
FOVImg.Image = "rbxassetid://16036349377"
FOVImg.Size = UDim2.new(1, 0, 1, 0)
FOVImg.BackgroundTransparency = 1
FOVImg.ImageColor3 = Color3.fromRGB(255, 70, 110)
FOVImg.ImageTransparency = 0.75
FOVImg.Parent = FOVCircle

-- ========== ПРИЦІЛ ==========
local Crosshair = Instance.new("Frame")
Crosshair.Size = UDim2.new(0, 16, 0, 16)
Crosshair.Position = UDim2.new(0.5, -8, 0.5, -8)
Crosshair.BackgroundTransparency = 1
Crosshair.Visible = true
Crosshair.ZIndex = 2
Crosshair.Parent = ScreenGui

for _, data in ipairs({
    {0.5, -0.5, 0, 0, 2, 6},
    {0.5, -0.5, 1, -6, 2, 6},
    {0, 0, 0.5, -0.5, 6, 2},
    {1, -6, 0.5, -0.5, 6, 2}
}) do
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, data[5], 0, data[6])
    bar.Position = UDim2.new(data[1], data[2], data[3], data[4])
    bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bar.BackgroundTransparency = 0.3
    bar.Parent = Crosshair
end

-- ========== ЯДРО АІМБОТА (ЗАВЖДИ АКТИВНИЙ) ==========
local function GetPlayers()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if Settings.TeamCheck and plr.Team == LocalPlayer.Team then
                continue
            end
            local char = plr.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                table.insert(list, plr)
            end
        end
    end
    return list
end

local function GetTargetPart(char)
    if Settings.TargetMode == 1 then
        return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    elseif Settings.TargetMode == 2 then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
    elseif Settings.TargetMode == 3 then
        local parts = {}
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        if head then table.insert(parts, head) end
        if torso then table.insert(parts, torso) end
        return #parts > 0 and parts[math.random(1, #parts)] or nil
    end
    return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
end

local function CheckWall(targetPos)
    if not Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = (targetPos - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {Camera, LocalPlayer.Character}
    local result = Workspace:Raycast(origin, dir, params)
    return result == nil
end

local function FindTarget()
    local best = nil
    local bestDist = Settings.FOV
    local center = Camera.ViewportSize / 2
    
    for _, plr in ipairs(GetPlayers()) do
        local char = plr.Character
        local part = GetTargetPart(char)
        if part then
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if dist < bestDist then
                    if CheckWall(part.Position) then
                        bestDist = dist
                        best = part
                    end
                end
            end
        end
    end
    return best
end

-- ========== ЦИКЛ АІМБОТА (ПРАЦЮЄ ЗАВЖДИ) ==========
RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then return end
    
    local target = FindTarget()
    if target then
        local targetPos = target.Position
        
        if Settings.Randomization > 0 then
            local r = Settings.Randomization * 8
            targetPos = targetPos + Vector3.new(
                math.random(-r, r) / 10,
                math.random(-r, r) / 10,
                math.random(-r, r) / 10
            )
        end
        
        local targetCF = CFrame.new(Camera.CFrame.Position, targetPos)
        
        if Settings.Smoothness <= 0.01 then
            Camera.CFrame = targetCF
        else
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, Settings.Smoothness)
        end
    end
end)

-- ========== ESP (ВИПРАВЛЕНО – БОКС ПІД ГРАВЦЕМ) ==========
local ESPObjects = {}

local function CreateESP(player)
    if ESPObjects[player] then return end
    
    local char = player.Character
    if not char then return end
    
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 50, 0, 70)  -- Збільшено для правильного відображення
    box.BackgroundColor3 = Color3.fromRGB(255, 70, 110)
    box.BackgroundTransparency = 0.7
    box.BorderSizePixel = 0
    box.Visible = false
    box.ZIndex = 3
    box.Parent = ScreenGui
    
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, 0, 0, 16)
    nameLbl.Position = UDim2.new(0, 0, 1, 2)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = player.Name
    nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLbl.TextSize = 10
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.Parent = box
    
    local health = Instance.new("Frame")
    health.Size = UDim2.new(1, 0, 0, 4)
    health.Position = UDim2.new(0, 0, 1, -4)
    health.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    health.Parent = box
    
    ESPObjects[player] = {Box = box, Name = nameLbl, Health = health}
end

local function UpdateESP()
    for plr, data in pairs(ESPObjects) do
        local char = plr.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            if root then
                local pos, on = Camera:WorldToViewportPoint(root.Position)
                if on then
                    data.Box.Visible = true
                    -- Правильне позиціонування: бокс по центру гравця
                    data.Box.Position = UDim2.new(0, pos.X - 25, 0, pos.Y - 35)
                    
                    local hp = char.Humanoid.Health / char.Humanoid.MaxHealth
                    data.Health.Size = UDim2.new(math.clamp(hp, 0, 1), 0, 0, 4)
                    data.Health.BackgroundColor3 = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
                else
                    data.Box.Visible = false
                end
            end
        else
            data.Box.Visible = false
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if Settings.ESPEnabled then
            CreateESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        ESPObjects[player].Box:Destroy()
        ESPObjects[player] = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.ESPEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and not ESPObjects[plr] then
                CreateESP(plr)
            end
        end
        UpdateESP()
    else
        for _, data in pairs(ESPObjects) do
            data.Box.Visible = false
        end
    end
end)

-- ========== ВІДКРИТТЯ/ЗАКРИТТЯ GUI ==========
local UIVisible = true

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        UIVisible = not UIVisible
        MainFrame.Visible = UIVisible
        if not UIVisible then
            FOVCircle.Visible = false
            Crosshair.Visible = false
        else
            FOVCircle.Visible = Settings.FOVCircleEnabled
            Crosshair.Visible = Settings.Crosshair
        end
    end
end)

print("✅ АІМБОТ ЗАВЖДИ АКТИВНИЙ + ВИПРАВЛЕНИЙ ESP")
print("📌 ВІДКРИТТЯ: ПРАВИЙ SHIFT | АІМ: БЕЗ КНОПОК, НАВОДИТЬСЯ ПОСТІЙНО")
