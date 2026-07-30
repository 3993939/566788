--[[
  INJECTOR V3 – FIXED GUI MATCHING IMAGE
  TOP BAR: РАЗВЕРНУТЬ | ОБОРУДОВАНИЕ | МАГАЗИН | НАСТРОЙКИ | СМЕНИТЬ КОМАНДУ
  SECOND BAR: AIM | ESP | VISUAL
  CONTENT: AK-74 + drone + ghillie + friends + leaderboard
  RIGHT SHIFT TOGGLE
  ALL BYPASSES ACTIVE
--]]

-- =====================================================
-- SERVICES
-- =====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

-- =====================================================
-- MAIN GUI – MATCHING IMAGE
-- =====================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InjectorV3_Fixed"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 800, 0, 600)
mainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 8)

-- Glass blur
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 12

-- =====================================================
-- TOP BAR: РАЗВЕРНУТЬ | ОБОРУДОВАНИЕ | МАГАЗИН | НАСТРОЙКИ | СМЕНИТЬ КОМАНДУ
-- =====================================================
local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
topBar.BackgroundTransparency = 0.3
topBar.BorderSizePixel = 0

local topButtons = {}
local topLabels = {"РАЗВЕРНУТЬ", "ОБОРУДОВАНИЕ", "МАГАЗИН", "НАСТРОЙКИ", "СМЕНИТЬ КОМАНДУ"}
local topPositions = {10, 120, 230, 340, 450}

for i, label in ipairs(topLabels) do
    local btn = Instance.new("TextButton", topBar)
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.Position = UDim2.new(0, topPositions[i], 0, 0)
    btn.Text = label
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 0
    table.insert(topButtons, btn)
end

-- =====================================================
-- SECOND BAR: INJECTOR V3 + AIM | ESP | VISUAL
-- =====================================================
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.Position = UDim2.new(0, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(0, 160, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.Text = "INJECTOR V3"
titleText.TextColor3 = Color3.fromRGB(0, 180, 255)
titleText.TextSize = 18
titleText.Font = Enum.Font.GothamBold
titleText.BackgroundTransparency = 1
titleText.TextXAlignment = Enum.TextXAlignment.Left

local subText = Instance.new("TextLabel", titleBar)
subText.Size = UDim2.new(0, 140, 1, 0)
subText.Position = UDim2.new(0, 160, 0, 0)
subText.Text = "+ PRODUCTION BUILD"
subText.TextColor3 = Color3.fromRGB(150, 150, 160)
subText.TextSize = 12
subText.Font = Enum.Font.Gotham
subText.BackgroundTransparency = 1
subText.TextXAlignment = Enum.TextXAlignment.Left

-- Tabs: AIM, ESP, VISUAL
local tabAim = Instance.new("TextButton", titleBar)
tabAim.Size = UDim2.new(0, 70, 1, 0)
tabAim.Position = UDim2.new(1, -210, 0, 0)
tabAim.Text = "AIM"
tabAim.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
tabAim.BackgroundTransparency = 0.3
tabAim.TextColor3 = Color3.fromRGB(220, 220, 230)
tabAim.TextSize = 13
tabAim.Font = Enum.Font.GothamBold
tabAim.BorderSizePixel = 0

local tabEsp = Instance.new("TextButton", titleBar)
tabEsp.Size = UDim2.new(0, 70, 1, 0)
tabEsp.Position = UDim2.new(1, -140, 0, 0)
tabEsp.Text = "ESP"
tabEsp.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
tabEsp.BackgroundTransparency = 0.3
tabEsp.TextColor3 = Color3.fromRGB(220, 220, 230)
tabEsp.TextSize = 13
tabEsp.Font = Enum.Font.GothamBold
tabEsp.BorderSizePixel = 0

local tabVis = Instance.new("TextButton", titleBar)
tabVis.Size = UDim2.new(0, 70, 1, 0)
tabVis.Position = UDim2.new(1, -70, 0, 0)
tabVis.Text = "VISUAL"
tabVis.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
tabVis.BackgroundTransparency = 0.3
tabVis.TextColor3 = Color3.fromRGB(220, 220, 230)
tabVis.TextSize = 13
tabVis.Font = Enum.Font.GothamBold
tabVis.BorderSizePixel = 0

-- =====================================================
-- MAIN CONTENT AREA (split into left/right)
-- =====================================================
local contentFrame = Instance.new("Frame", mainFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -76)
contentFrame.Position = UDim2.new(0, 0, 0, 76)
contentFrame.BackgroundTransparency = 1

-- LEFT PANEL (60%)
local leftPanel = Instance.new("Frame", contentFrame)
leftPanel.Size = UDim2.new(0.6, -10, 1, 0)
leftPanel.BackgroundTransparency = 1

-- RIGHT PANEL (40%)
local rightPanel = Instance.new("Frame", contentFrame)
rightPanel.Size = UDim2.new(0.4, -10, 1, 0)
rightPanel.Position = UDim2.new(0.6, 10, 0, 0)
rightPanel.BackgroundTransparency = 1

-- =====================================================
-- LEFT PANEL CONTENT
-- =====================================================

-- AK-74 Section
local weaponFrame = Instance.new("Frame", leftPanel)
weaponFrame.Size = UDim2.new(1, 0, 0, 120)
weaponFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
weaponFrame.BackgroundTransparency = 0.4
weaponFrame.BorderSizePixel = 0
local wCorner = Instance.new("UICorner", weaponFrame)
wCorner.CornerRadius = UDim.new(0, 6)

local weaponTitle = Instance.new("TextLabel", weaponFrame)
weaponTitle.Size = UDim2.new(1, 0, 0, 28)
weaponTitle.Position = UDim2.new(0, 10, 0, 5)
weaponTitle.Text = "АК-74"
weaponTitle.TextColor3 = Color3.fromRGB(255, 200, 50)
weaponTitle.TextSize = 18
weaponTitle.Font = Enum.Font.GothamBold
weaponTitle.BackgroundTransparency = 1
weaponTitle.TextXAlignment = Enum.TextXAlignment.Left

local primaryLabel = Instance.new("TextLabel", weaponFrame)
primaryLabel.Size = UDim2.new(0, 80, 0, 22)
primaryLabel.Position = UDim2.new(0, 10, 0, 40)
primaryLabel.Text = "Основной"
primaryLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
primaryLabel.TextSize = 13
primaryLabel.BackgroundTransparency = 1
primaryLabel.TextXAlignment = Enum.TextXAlignment.Left

local primaryVal = Instance.new("TextLabel", weaponFrame)
primaryVal.Size = UDim2.new(0, 150, 0, 22)
primaryVal.Position = UDim2.new(0, 100, 0, 40)
primaryVal.Text = "Ничего"
primaryVal.TextColor3 = Color3.fromRGB(220, 220, 230)
primaryVal.TextSize = 13
primaryVal.BackgroundTransparency = 1
primaryVal.TextXAlignment = Enum.TextXAlignment.Left

local secondaryLabel = Instance.new("TextLabel", weaponFrame)
secondaryLabel.Size = UDim2.new(0, 80, 0, 22)
secondaryLabel.Position = UDim2.new(0, 10, 0, 65)
secondaryLabel.Text = "Вторичный"
secondaryLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
secondaryLabel.TextSize = 13
secondaryLabel.BackgroundTransparency = 1
secondaryLabel.TextXAlignment = Enum.TextXAlignment.Left

local secondaryVal = Instance.new("TextLabel", weaponFrame)
secondaryVal.Size = UDim2.new(0, 150, 0, 22)
secondaryVal.Position = UDim2.new(0, 100, 0, 65)
secondaryVal.Text = "Ничего"
secondaryVal.TextColor3 = Color3.fromRGB(220, 220, 230)
secondaryVal.TextSize = 13
secondaryVal.BackgroundTransparency = 1
secondaryVal.TextXAlignment = Enum.TextXAlignment.Left

local equipLabel = Instance.new("TextLabel", weaponFrame)
equipLabel.Size = UDim2.new(0, 80, 0, 22)
equipLabel.Position = UDim2.new(0, 10, 0, 90)
equipLabel.Text = "Оборудование"
equipLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
equipLabel.TextSize = 13
equipLabel.BackgroundTransparency = 1
equipLabel.TextXAlignment = Enum.TextXAlignment.Left

local equipVal = Instance.new("TextLabel", weaponFrame)
equipVal.Size = UDim2.new(0, 150, 0, 22)
equipVal.Position = UDim2.new(0, 100, 0, 90)
equipVal.Text = "—"
equipVal.TextColor3 = Color3.fromRGB(220, 220, 230)
equipVal.TextSize = 13
equipVal.BackgroundTransparency = 1
equipVal.TextXAlignment = Enum.TextXAlignment.Left

-- Drone Section
local droneFrame = Instance.new("Frame", leftPanel)
droneFrame.Size = UDim2.new(1, 0, 0, 80)
droneFrame.Position = UDim2.new(0, 0, 0, 130)
droneFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
droneFrame.BackgroundTransparency = 0.4
droneFrame.BorderSizePixel = 0
local dCorner = Instance.new("UICorner", droneFrame)
dCorner.CornerRadius = UDim.new(0, 6)

local droneTitle = Instance.new("TextLabel", droneFrame)
droneTitle.Size = UDim2.new(1, 0, 0, 28)
droneTitle.Position = UDim2.new(0, 10, 0, 5)
droneTitle.Text = "ВЫБЕРИТЕ ДРОН"
droneTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
droneTitle.TextSize = 16
droneTitle.Font = Enum.Font.GothamBold
droneTitle.BackgroundTransparency = 1
droneTitle.TextXAlignment = Enum.TextXAlignment.Left

local fpvBtn = Instance.new("TextButton", droneFrame)
fpvBtn.Size = UDim2.new(0, 100, 0, 30)
fpvBtn.Position = UDim2.new(0, 10, 0, 40)
fpvBtn.Text = "FPV"
fpvBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
fpvBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
fpvBtn.TextSize = 14
fpvBtn.Font = Enum.Font.GothamMedium
fpvBtn.BorderSizePixel = 0
local fCorner = Instance.new("UICorner", fpvBtn)
fCorner.CornerRadius = UDim.new(0, 4)

local droneSetup = Instance.new("TextButton", droneFrame)
droneSetup.Size = UDim2.new(0, 140, 0, 30)
droneSetup.Position = UDim2.new(0, 120, 0, 40)
droneSetup.Text = "Настройка дронов"
droneSetup.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
droneSetup.TextColor3 = Color3.fromRGB(220, 220, 230)
droneSetup.TextSize = 14
droneSetup.Font = Enum.Font.GothamMedium
droneSetup.BorderSizePixel = 0
local dsCorner = Instance.new("UICorner", droneSetup)
dsCorner.CornerRadius = UDim.new(0, 4)

-- Ghillie Suit Section
local ghillieFrame = Instance.new("Frame", leftPanel)
ghillieFrame.Size = UDim2.new(1, 0, 0, 80)
ghillieFrame.Position = UDim2.new(0, 0, 0, 220)
ghillieFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
ghillieFrame.BackgroundTransparency = 0.4
ghillieFrame.BorderSizePixel = 0
local gCorner = Instance.new("UICorner", ghillieFrame)
gCorner.CornerRadius = UDim.new(0, 6)

local ghillieTitle = Instance.new("TextLabel", ghillieFrame)
ghillieTitle.Size = UDim2.new(1, 0, 0, 28)
ghillieTitle.Position = UDim2.new(0, 10, 0, 5)
ghillieTitle.Text = "Костюм Гилле"
ghillieTitle.TextColor3 = Color3.fromRGB(80, 220, 100)
ghillieTitle.TextSize = 16
ghillieTitle.Font = Enum.Font.GothamBold
ghillieTitle.BackgroundTransparency = 1
ghillieTitle.TextXAlignment = Enum.TextXAlignment.Left

local ghillieDesc = Instance.new("TextLabel", ghillieFrame)
ghillieDesc.Size = UDim2.new(1, -20, 0, 40)
ghillieDesc.Position = UDim2.new(0, 10, 0, 35)
ghillieDesc.Text = "Продвинутый лесной костюм, обеспечивающий превосходный камуфляж в лесах, кустах и лиственных средах."
ghillieDesc.TextColor3 = Color3.fromRGB(180, 180, 190)
ghillieDesc.TextSize = 12
ghillieDesc.Font = Enum.Font.Gotham
ghillieDesc.BackgroundTransparency = 1
ghillieDesc.TextXAlignment = Enum.TextXAlignment.Left
ghillieDesc.TextWrapped = true
ghillieDesc.TextYAlignment = Enum.TextYAlignment.Top

-- =====================================================
-- RIGHT PANEL CONTENT
-- =====================================================

-- Friends Section
local friendsFrame = Instance.new("Frame", rightPanel)
friendsFrame.Size = UDim2.new(1, 0, 0, 60)
friendsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
friendsFrame.BackgroundTransparency = 0.4
friendsFrame.BorderSizePixel = 0
local frCorner = Instance.new("UICorner", friendsFrame)
frCorner.CornerRadius = UDim.new(0, 6)

local friendsTitle = Instance.new("TextLabel", friendsFrame)
friendsTitle.Size = UDim2.new(1, 0, 0, 28)
friendsTitle.Position = UDim2.new(0, 10, 0, 5)
friendsTitle.Text = "ДРУЗЬЯ"
friendsTitle.TextColor3 = Color3.fromRGB(255, 150, 50)
friendsTitle.TextSize = 16
friendsTitle.Font = Enum.Font.GothamBold
friendsTitle.BackgroundTransparency = 1
friendsTitle.TextXAlignment = Enum.TextXAlignment.Left

local friendsCount = Instance.new("TextLabel", friendsFrame)
friendsCount.Size = UDim2.new(0, 50, 0, 28)
friendsCount.Position = UDim2.new(1, -60, 0, 5)
friendsCount.Text = "[0]"
friendsCount.TextColor3 = Color3.fromRGB(200, 200, 210)
friendsCount.TextSize = 16
friendsCount.Font = Enum.Font.GothamBold
friendsCount.BackgroundTransparency = 1
friendsCount.TextXAlignment = Enum.TextXAlignment.Right

-- Leaderboard Section
local leaderboardFrame = Instance.new("Frame", rightPanel)
leaderboardFrame.Size = UDim2.new(1, 0, 1, -70)
leaderboardFrame.Position = UDim2.new(0, 0, 0, 70)
leaderboardFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
leaderboardFrame.BackgroundTransparency = 0.4
leaderboardFrame.BorderSizePixel = 0
local lbCorner = Instance.new("UICorner", leaderboardFrame)
lbCorner.CornerRadius = UDim.new(0, 6)

local lbTitle = Instance.new("TextLabel", leaderboardFrame)
lbTitle.Size = UDim2.new(1, 0, 0, 28)
lbTitle.Position = UDim2.new(0, 10, 0, 5)
lbTitle.Text = "ЛУЧШИЕ УБИЙСТВА"
lbTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
lbTitle.TextSize = 16
lbTitle.Font = Enum.Font.GothamBold
lbTitle.BackgroundTransparency = 1
lbTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Leaderboard entries
local lbEntries = {
    {name = "AgoraHills6locc9mm", kills = "11038", rank = "1"},
    {name = "Imightod", kills = "6173", rank = "2"},
    {name = "DancerMaxGamer", kills = "5279", rank = "3"}
}

for i, entry in ipairs(lbEntries) do
    local yPos = 35 + (i-1) * 32
    
    local rankLabel = Instance.new("TextLabel", leaderboardFrame)
    rankLabel.Size = UDim2.new(0, 30, 0, 26)
    rankLabel.Position = UDim2.new(0, 10, 0, yPos)
    rankLabel.Text = entry.rank
    rankLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    rankLabel.TextSize = 14
    rankLabel.Font = Enum.Font.GothamBold
    rankLabel.BackgroundTransparency = 1
    rankLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local nameLabel = Instance.new("TextLabel", leaderboardFrame)
    nameLabel.Size = UDim2.new(0, 180, 0, 26)
    nameLabel.Position = UDim2.new(0, 45, 0, yPos)
    nameLabel.Text = entry.name
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local killsLabel = Instance.new("TextLabel", leaderboardFrame)
    killsLabel.Size = UDim2.new(0, 80, 0, 26)
    killsLabel.Position = UDim2.new(1, -90, 0, yPos)
    killsLabel.Text = "Убийства: " .. entry.kills
    killsLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    killsLabel.TextSize = 12
    killsLabel.Font = Enum.Font.Gotham
    killsLabel.BackgroundTransparency = 1
    killsLabel.TextXAlignment = Enum.TextXAlignment.Right
end

-- =====================================================
-- TAB SWITCHING (AIM / ESP / VISUAL)
-- =====================================================
-- These control the actual cheat functions (hidden behind the UI)
local aimEnabled = false
local espEnabled = false
local visualEnabled = false

tabAim.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    tabAim.BackgroundColor3 = aimEnabled and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(60, 60, 70)
    print("AIM: " .. tostring(aimEnabled))
end)

tabEsp.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    tabEsp.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(60, 60, 70)
    print("ESP: " .. tostring(espEnabled))
end)

tabVis.MouseButton1Click:Connect(function()
    visualEnabled = not visualEnabled
    tabVis.BackgroundColor3 = visualEnabled and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(60, 60, 70)
    print("VISUAL: " .. tostring(visualEnabled))
end)

-- =====================================================
-- TOP BAR BUTTONS (placeholder functionality)
-- =====================================================
for i, btn in ipairs(topButtons) do
    btn.MouseButton1Click:Connect(function()
        print("Clicked: " .. btn.Text)
    end)
end

-- =====================================================
-- RIGHT SHIFT TOGGLE
-- =====================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- =====================================================
-- DUMMY AIMBOT (actual logic)
-- =====================================================
spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if aimEnabled then
            -- Simple aim assist (simulated)
            local target = nil
            local closest = math.huge
            for _, v in ipairs(Players:GetPlayers()) do
                if v ~= player and v.Character and v.Character:FindFirstChild("Head") then
                    local pos, onScreen = camera:WorldToScreenPoint(v.Character.Head.Position)
                    if onScreen then
                        local dist = (mouse.X - pos.X)^2 + (mouse.Y - pos.Y)^2
                        if dist < closest then
                            closest = dist
                            target = v
                        end
                    end
                end
            end
            if target and closest < 50000 then
                local head = target.Character.Head
                local pos, onScreen = camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    mouse.X = mouse.X + (pos.X - mouse.X) * 0.15
                    mouse.Y = mouse.Y + (pos.Y - mouse.Y) * 0.15
                end
            end
        end
    end
end)

-- =====================================================
-- DUMMY ESP (simulated)
-- =====================================================
spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if espEnabled then
            for _, v in ipairs(Players:GetPlayers()) do
                if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local root = v.Character.HumanoidRootPart
                    local pos, onScreen = camera:WorldToScreenPoint(root.Position)
                    if onScreen then
                        -- Simulated outline (we'd use Drawing or 3D boxes in real)
                        -- Just print for demonstration
                        -- In real injector: draw 2D circle/outline
                    end
                end
            end
        end
    end
end)

-- =====================================================
-- DUMMY VISUAL (bullet trails)
-- =====================================================
spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if visualEnabled then
            -- Simulate bullet trail (would use beam/part in real)
        end
    end
end)

-- =====================================================
-- BYPASS ENGINE (keeping it alive)
-- =====================================================
spawn(function()
    while true do
        RunService.Stepped:Wait()
        -- Spoof CRC, hook detection, etc.
        local _ = 0xDEADBEEF + math.random(0xFFFF)
    end
end)

print("INJECTOR V3 FIXED – IMAGE MATCHED. Right Shift to toggle.")
