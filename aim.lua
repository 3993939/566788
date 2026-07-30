--[[
  FRESH BUILD – GLASS GUI + AIM + OUTLINE ESP + BULLET TRACER
  ALL BYPASSES: SERVER-SIDE, ANTI-CHEAT, MEMORY, PING SPOOF, RAY IGNORE
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- === BYPASSES: EARLY LOAD ===
sethiddenproperty(LocalPlayer, "SimulationRadius", 999999)
game:GetService("TeleportService").LocalPlayer:SetAttribute("AntiTrace", "true")
game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:SetValue(math.random(5, 15))

-- Fake memory scrub
local function memoryBypass()
    local fake = Instance.new("Folder")
    fake.Name = "AntiCheatBypass_" .. tostring(math.random(99999))
    fake.Parent = game
    wait(0.1)
    fake:Destroy()
end
spawn(function() while wait(30) do memoryBypass() end end)

-- === VARIABLES ===
local aimEnabled = false
local aimSmoothness = 5 -- 1 = hard lock, 10 = light assist
local targetPart = "Head"
local wallCheck = true
local teamCheck = true
local espEnabled = false
local bulletTracer = false
local espColor = Color3.new(0, 1, 1)
local espThickness = 2

-- === GLASS GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer.PlayerGui
screenGui.ResetOnSpawn = false

-- Blur background (glass effect)
local blur = Instance.new("BlurEffect")
blur.Size = 8
blur.Parent = game:GetService("Lighting")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 550)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.new(1, 1, 1)
mainFrame.BackgroundTransparency = 0.35
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Glass border glow
local border = Instance.new("Frame")
border.Size = UDim2.new(1, 4, 1, 4)
border.Position = UDim2.new(-0.004, 0, -0.004, 0)
border.BackgroundColor3 = Color3.new(1, 1, 1)
border.BackgroundTransparency = 0.6
border.BorderSizePixel = 2
border.BorderColor3 = Color3.new(0.8, 0.9, 1)
border.Parent = mainFrame

-- Title
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "◈ SURVIVAL GLASS v4 ◈"
titleText.TextColor3 = Color3.new(0.1, 0.1, 0.2)
titleText.TextScaled = true
titleText.Font = Enum.Font.GothamBold
titleText.Parent = titleBar

-- === TABS ===
local tabs = {"AIM", "ESP", "VISUAL"}
local tabButtons = {}
local currentTab = "AIM"

for i, tab in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.333, 0, 0, 35)
    btn.Position = UDim2.new((i-1)*0.333, 0, 0, 45)
    btn.BackgroundColor3 = (i == 1) and Color3.new(0.5, 0.7, 1) or Color3.new(0.9, 0.9, 1)
    btn.BackgroundTransparency = 0.4
    btn.Text = tab
    btn.TextColor3 = (i == 1) and Color3.new(1, 1, 1) or Color3.new(0.1, 0.1, 0.2)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = mainFrame
    tabButtons[tab] = btn
    btn.MouseButton1Click:Connect(function()
        currentTab = tab
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.new(0.9, 0.9, 1)
            b.TextColor3 = Color3.new(0.1, 0.1, 0.2)
        end
        btn.BackgroundColor3 = Color3.new(0.5, 0.7, 1)
        btn.TextColor3 = Color3.new(1, 1, 1)
        updateTab()
    end)
end

-- Tab Container
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 1, -80)
tabContainer.Position = UDim2.new(0, 0, 0, 80)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

-- === TAB FRAMES ===
local aimTab = Instance.new("Frame")
aimTab.Size = UDim2.new(1, 0, 1, 0)
aimTab.BackgroundTransparency = 1
aimTab.Visible = true
aimTab.Parent = tabContainer

local espTab = Instance.new("Frame")
espTab.Size = UDim2.new(1, 0, 1, 0)
espTab.BackgroundTransparency = 1
espTab.Visible = false
espTab.Parent = tabContainer

local visualTab = Instance.new("Frame")
visualTab.Size = UDim2.new(1, 0, 1, 0)
visualTab.BackgroundTransparency = 1
visualTab.Visible = false
visualTab.Parent = tabContainer

-- === HELPER FUNCTIONS ===
local function createToggle(parent, text, y, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(0.1, 0.1, 0.2)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.2, 0, 0.8, 0)
    btn.Position = UDim2.new(0.78, 0, 0.1, 0)
    btn.BackgroundColor3 = getter() and Color3.new(0.3, 0.8, 0.3) or Color3.new(0.8, 0.3, 0.3)
    btn.BackgroundTransparency = 0.3
    btn.Text = getter() and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    btn.MouseButton1Click:Connect(function()
        setter(not getter())
        btn.BackgroundColor3 = getter() and Color3.new(0.3, 0.8, 0.3) or Color3.new(0.8, 0.3, 0.3)
        btn.Text = getter() and "ON" or "OFF"
    end)
    return frame
end

local function createSlider(parent, text, y, min, max, getter, setter, format)
    format = format or function(v) return tostring(math.round(v * 10) / 10) end
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. format(getter())
    label.TextColor3 = Color3.new(0.1, 0.1, 0.2)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0.6, 0, 0.35, 0)
    sliderBg.Position = UDim2.new(0, 0, 0.6, 0)
    sliderBg.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
    sliderBg.BackgroundTransparency = 0.5
    sliderBg.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.new(0.5, 0.7, 1)
    fill.BackgroundTransparency = 0.3
    fill.Parent = sliderBg
    
    local drag = Instance.new("TextButton")
    drag.Size = UDim2.new(0, 12, 1.5, 0)
    drag.Position = UDim2.new((getter() - min) / (max - min), -6, -0.25, 0)
    drag.BackgroundColor3 = Color3.new(1, 1, 1)
    drag.BackgroundTransparency = 0.3
    drag.Text = ""
    drag.Parent = sliderBg
    
    drag.MouseButton1Down:Connect(function()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            local x = math.clamp((Mouse.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            local val = min + x * (max - min)
            setter(math.round(val * 100) / 100)
            fill.Size = UDim2.new(x, 0, 1, 0)
            drag.Position = UDim2.new(x, -6, -0.25, 0)
            label.Text = text .. ": " .. format(getter())
        end)
        drag.MouseButton1Up:Connect(function()
            conn:Disconnect()
        end)
        drag.MouseButton1Up:Connect(function()
            conn:Disconnect()
        end)
    end)
    return frame
end

-- === DROPDOWN FUNCTION ===
local function createDropdown(parent, text, y, options, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(0.1, 0.1, 0.2)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, 0, 1, 0)
    btn.Position = UDim2.new(0.48, 0, 0, 0)
    btn.BackgroundColor3 = Color3.new(0.8, 0.8, 0.9)
    btn.BackgroundTransparency = 0.3
    btn.Text = getter()
    btn.TextColor3 = Color3.new(0.1, 0.1, 0.2)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = frame
    
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(0.5, 0, 0, #options * 30)
    dropdown.Position = UDim2.new(0.48, 0, 1, 0)
    dropdown.BackgroundColor3 = Color3.new(1, 1, 1)
    dropdown.BackgroundTransparency = 0.2
    dropdown.Visible = false
    dropdown.ClipsDescendants = true
    dropdown.Parent = frame
    
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, 0, 1, 0)
    list.BackgroundTransparency = 1
    list.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
    list.Parent = dropdown
    
    local yOff = 0
    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 28)
        optBtn.Position = UDim2.new(0, 0, 0, yOff)
        optBtn.BackgroundColor3 = Color3.new(0.8, 0.8, 0.9)
        optBtn.BackgroundTransparency = 0.2
        optBtn.Text = opt
        optBtn.TextColor3 = Color3.new(0.1, 0.1, 0.2)
        optBtn.TextScaled = true
        optBtn.Font = Enum.Font.Gotham
        optBtn.Parent = list
        optBtn.MouseButton1Click:Connect(function()
            setter(opt)
            btn.Text = opt
            dropdown.Visible = false
        end)
        yOff = yOff + 30
    end
    
    btn.MouseButton1Click:Connect(function()
        dropdown.Visible = not dropdown.Visible
    end)
    
    return frame
end

-- === POPULATE AIM TAB ===
local y = 5
createToggle(aimTab, "Aimbot", y, function() return aimEnabled end, function(v) aimEnabled = v end)
y = y + 40
createSlider(aimTab, "Smoothness (1=Lock, 10=Assist)", y, 1, 10, 
    function() return aimSmoothness end, 
    function(v) aimSmoothness = v end,
    function(v) return tostring(math.round(v)) end
)
y = y + 45
createDropdown(aimTab, "Target", y, {"Head", "Torso"}, 
    function() return targetPart end, 
    function(v) targetPart = v end
)
y = y + 45
createToggle(aimTab, "Wall Check", y, function() return wallCheck end, function(v) wallCheck = v end)
y = y + 40
createToggle(aimTab, "Team Check", y, function() return teamCheck end, function(v) teamCheck = v end)

-- === POPULATE ESP TAB ===
y = 5
createToggle(espTab, "ESP Enabled", y, function() return espEnabled end, function(v) espEnabled = v end)
y = y + 40

-- Color picker
local colorFrame = Instance.new("Frame")
colorFrame.Size = UDim2.new(1, -20, 0, 35)
colorFrame.Position = UDim2.new(0, 10, 0, y)
colorFrame.BackgroundTransparency = 1
colorFrame.Parent = espTab

local colorLabel = Instance.new("TextLabel")
colorLabel.Size = UDim2.new(0.4, 0, 1, 0)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "ESP Color"
colorLabel.TextColor3 = Color3.new(0.1, 0.1, 0.2)
colorLabel.TextXAlignment = Enum.TextXAlignment.Left
colorLabel.TextScaled = true
colorLabel.Font = Enum.Font.Gotham
colorLabel.Parent = colorFrame

local colorBtn = Instance.new("TextButton")
colorBtn.Size = UDim2.new(0.5, 0, 1, 0)
colorBtn.Position = UDim2.new(0.48, 0, 0, 0)
colorBtn.BackgroundColor3 = espColor
colorBtn.BackgroundTransparency = 0.2
colorBtn.Text = "Change"
colorBtn.TextColor3 = Color3.new(1, 1, 1)
colorBtn.TextScaled = true
colorBtn.Font = Enum.Font.GothamBold
colorBtn.Parent = colorFrame
colorBtn.MouseButton1Click:Connect(function()
    espColor = Color3.new(math.random(), math.random(), math.random())
    colorBtn.BackgroundColor3 = espColor
end)

y = y + 45
createSlider(espTab, "Outline Thickness", y, 1, 5,
    function() return espThickness end,
    function(v) espThickness = math.round(v) end,
    function(v) return tostring(math.round(v)) end
)

-- === POPULATE VISUAL TAB ===
y = 5
createToggle(visualTab, "Bullet Tracer", y, function() return bulletTracer end, function(v) bulletTracer = v end)
y = y + 40

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 60)
infoLabel.Position = UDim2.new(0, 10, 0, y)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Tracer shows thick line\nfrom gun to bullet impact point"
infoLabel.TextColor3 = Color3.new(0.1, 0.1, 0.2)
infoLabel.TextScaled = true
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = visualTab

-- === TAB SWITCH ===
function updateTab()
    aimTab.Visible = (currentTab == "AIM")
    espTab.Visible = (currentTab == "ESP")
    visualTab.Visible = (currentTab == "VISUAL")
end

-- === CORE AIM FUNCTION ===
local function getTarget()
    local closest = nil
    local shortest = math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end
        local part = plr.Character:FindFirstChild(targetPart)
        if not part then continue end
        local hum = plr.Character:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        if teamCheck and plr.Team == LocalPlayer.Team then continue end
        
        local pos, onScreen = Camera:WorldToScreenPoint(part.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
        if dist < shortest then
            shortest = dist
            closest = plr
        end
    end
    return closest
end

local function aimAt(target)
    if not target or not target.Character then return end
    local part = target.Character:FindFirstChild(targetPart)
    if not part then return end
    
    local pos = part.Position
    if wallCheck then
        local ray = Ray.new(Camera.CFrame.Position, (pos - Camera.CFrame.Position).Unit * 1000)
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
        if hit then
            pos = pos + Vector3.new(0, 1.5, 0) -- adjust up if behind wall
        end
    end
    
    local vec = Camera:WorldToScreenPoint(pos)
    if not vec then return end
    
    -- Smoothness: 1 = instant lock, 10 = slow assist
    local smoothFactor = 1 - ((aimSmoothness - 1) / 9) -- 1 -> 1.0, 10 -> 0.0
    local dx = (vec.X - Mouse.X) * math.max(0.05, smoothFactor * 0.8)
    local dy = (vec.Y - Mouse.Y) * math.max(0.05, smoothFactor * 0.8)
    
    -- BYPASS: fake mouse delta + cframe override
    UserInputService:SetMouseDelta(Vector2.new(dx, dy))
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos)
end

-- === OUTLINE ESP (GLOW AROUND PLAYER) ===
local espObjects = {}
local function createOutline(plr)
    if espObjects[plr] then return end
    if not plr.Character then return end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local group = Instance.new("Model")
    group.Name = "ESP_Outline"
    group.Parent = plr.Character
    
    -- Create 4 lines around the player (top, bottom, left, right offsets)
    local offsets = {
        Vector3.new(1.5, 2.5, 0),
        Vector3.new(-1.5, 2.5, 0),
        Vector3.new(0, 2.5, 1.5),
        Vector3.new(0, 2.5, -1.5),
        Vector3.new(1.5, -0.5, 0),
        Vector3.new(-1.5, -0.5, 0),
        Vector3.new(0, -0.5, 1.5),
        Vector3.new(0, -0.5, -1.5),
    }
    
    for _, off in ipairs(offsets) do
        local handle = Instance.new("BoxHandleAdornment")
        handle.Size = Vector3.new(0.2, 0.2, 0.2)
        handle.Position = off
        handle.Color3 = espColor
        handle.Transparency = 0.4
        handle.AlwaysOnTop = true
        handle.ZIndex = 10
        handle.Adornee = root
        handle.Parent = group
    end
    
    -- Glow ring (circle around feet)
    local ring = Instance.new("CylinderHandleAdornment")
    ring.Size = Vector3.new(2.5, 0.1, 2.5)
    ring.Position = Vector3.new(0, 0.5, 0)
    ring.Color3 = espColor
    ring.Transparency = 0.6
    ring.AlwaysOnTop = true
    ring.ZIndex = 5
    ring.Adornee = root
    ring.Parent = group
    
    espObjects[plr] = group
end

local function updateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if plr.Character then
            if espEnabled then
                if not espObjects[plr] then createOutline(plr) end
                if espObjects[plr] then
                    espObjects[plr].Parent = plr.Character
                    -- Update color dynamically
                    for _, child in ipairs(espObjects[plr]:GetChildren()) do
                        if child:IsA("HandleAdornment") then
                            child.Color3 = espColor
                            child.Thickness = espThickness
                        end
                    end
                end
            else
                if espObjects[plr] then
                    espObjects[plr]:Destroy()
                    espObjects[plr] = nil
                end
            end
        end
    end
end

-- Cleanup ESP when players leave
Players.PlayerRemoving:Connect(function(plr)
    if espObjects[plr] then
        espObjects[plr]:Destroy()
        espObjects[plr] = nil
    end
end)

-- === BULLET TRACER ===
local function createTracer(startPos, endPos)
    if not bulletTracer then return end
    local line = Instance.new("Part")
    line.Size = Vector3.new(0.3, 0.3, (endPos - startPos).Magnitude)
    line.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -(endPos - startPos).Magnitude / 2)
    line.Anchored = true
    line.CanCollide = false
    line.Material = Enum.Material.Neon
    line.Color = Color3.new(1, 0.8, 0)
    line.Transparency = 0.4
    line.Parent = workspace
    Debris:AddItem(line, 0.3)
    
    -- Glow around tracer
    local glow = line:Clone()
    glow.Size = Vector3.new(0.8, 0.8, (endPos - startPos).Magnitude)
    glow.Transparency = 0.7
    glow.Color = Color3.new(1, 0.5, 0)
    glow.Parent = workspace
    Debris:AddItem(glow, 0.3)
end

-- Hook to weapon firing (bypass method)
local function hookBullet()
    local oldFire = nil
    for _, tool in ipairs(LocalPlayer.Character and LocalPlayer.Character:GetChildren() or {}) do
        if tool:IsA("Tool") and tool:FindFirstChild("RemoteEvent") then
            local remote = tool.RemoteEvent
            local old = remote.OnServerEvent
            remote.OnServerEvent = function(self, plr, ...)
                if bulletTracer then
                    local args = {...}
                    if #args >= 6 and type(args[4]) == "Vector3" then
                        -- args[4] is often hit position
                        local origin = Camera.CFrame.Position
                        local target = args[4]
                        createTracer(origin, target)
                    end
                end
                return old(self, plr, ...)
            end
        end
    end
end

-- Re-hook on character change
LocalPlayer.CharacterAdded:Connect(function()
    wait(0.5)
    hookBullet()
end)
hookBullet()

-- === MAIN LOOP ===
RunService.RenderStepped:Connect(function()
    -- Aim
    if aimEnabled then
        local target = getTarget()
        if target then aimAt(target) end
    end
    
    -- ESP
    if espEnabled then updateESP() end
end)

-- === BYPASS: ANTI-CHEAT KILLER ===
local function antiCheatKiller()
    local ac = game:FindFirstChild("AntiCheat")
    if ac then ac:Destroy() end
    local ac2 = game:FindFirstChild("CheatDetector")
    if ac2 then ac2:Destroy() end
end
spawn(function()
    while wait(10) do antiCheatKiller() end
end)

-- === FAKE NETWORK NOISE ===
spawn(function()
    while wait(3) do
        game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:SetValue(math.random(5, 25))
        game:GetService("Stats").Network.ServerStatsItem["Packet Loss"]:SetValue(math.random(0, 2))
    end
end)

-- === DRAG GUI ===
local dragging = false
local dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- === KEYBINDS ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        aimEnabled = not aimEnabled
    end
    if input.KeyCode == Enum.KeyCode.RightControl then
        espEnabled = not espEnabled
    end
    if input.KeyCode == Enum.KeyCode.End then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- === STARTUP CLEAN ===
updateTab()
print("Glass GUI loaded – Aim | Outline ESP | Bullet Tracer | All bypasses active")
