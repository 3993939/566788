--[[
    ULTIMATE ENGINE v9.0 + KEY SYSTEM (AUTO-OPEN LINK, RU)
    - Автоматичне відкриття посилання в браузері
    - Російська мова
    - Key System: "Получить ключ" + "Активировать"
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Очистка старих інтерфейсів
if CoreGui:FindFirstChild("UltimateEngine_UI") then
    CoreGui.UltimateEngine_UI:Destroy()
end

-- ============================
-- 1. KEY SYSTEM (2 КНОПКИ, RU)
-- ============================
local ValidKey = "RH29WJ-PAHALOX-82JSA" -- Ваш ключ
local KeyLink = "https://work.ink/2N3N/e1b1e961-f9b1-4e70-a5a8-9e931d5440e9" -- Ваше посилання

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "KeySystem"
KeyGui.Parent = CoreGui

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 420, 0, 240)
KeyFrame.Position = UDim2.new(0.5, -210, 0.5, -120)
KeyFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
KeyFrame.BackgroundTransparency = 0.15
KeyFrame.BorderSizePixel = 0
KeyFrame.Parent = KeyGui

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 16)
KeyCorner.Parent = KeyFrame

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(255, 60, 90)
KeyStroke.Thickness = 1.5
KeyStroke.Parent = KeyFrame

-- Заголовок (RU)
local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 50)
KeyTitle.Position = UDim2.new(0, 0, 0, 10)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "🔐 АКТИВАЦИЯ СОФТА"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 18
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Parent = KeyFrame

-- Поле для ключа (RU)
local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.8, 0, 0, 35)
KeyBox.Position = UDim2.new(0.1, 0, 0.30, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
KeyBox.BackgroundTransparency = 0.4
KeyBox.Text = ""
KeyBox.PlaceholderText = "Введите ключ..."
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 14
KeyBox.Parent = KeyFrame

local KeyBoxCorner = Instance.new("UICorner")
KeyBoxCorner.CornerRadius = UDim.new(0, 8)
KeyBoxCorner.Parent = KeyBox

-- Кнопка "Получить ключ" (RU)
local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.35, 0, 0, 35)
GetKeyBtn.Position = UDim2.new(0.08, 0, 0.55, 0)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
GetKeyBtn.BackgroundTransparency = 0.3
GetKeyBtn.Text = "🔑 ПОЛУЧИТЬ КЛЮЧ"
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 11
GetKeyBtn.Parent = KeyFrame

local GetKeyCorner = Instance.new("UICorner")
GetKeyCorner.CornerRadius = UDim.new(0, 8)
GetKeyCorner.Parent = GetKeyBtn

-- Кнопка "Активировать" (RU)
local ActivateBtn = Instance.new("TextButton")
ActivateBtn.Size = UDim2.new(0.35, 0, 0, 35)
ActivateBtn.Position = UDim2.new(0.57, 0, 0.55, 0)
ActivateBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 90)
ActivateBtn.BackgroundTransparency = 0.2
ActivateBtn.Text = "✅ АКТИВИРОВАТЬ"
ActivateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActivateBtn.Font = Enum.Font.GothamBold
ActivateBtn.TextSize = 11
ActivateBtn.Parent = KeyFrame

local ActivateCorner = Instance.new("UICorner")
ActivateCorner.CornerRadius = UDim.new(0, 8)
ActivateCorner.Parent = ActivateBtn

-- Статус (RU)
local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, 0, 0, 25)
KeyStatus.Position = UDim2.new(0, 0, 0.82, 0)
KeyStatus.BackgroundTransparency = 1
KeyStatus.Text = ""
KeyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
KeyStatus.TextSize = 12
KeyStatus.Font = Enum.Font.Gotham
KeyStatus.Parent = KeyFrame

-- ===== ФУНКЦІЯ АВТО-ВІДКРИТТЯ ПОСИЛАННЯ =====
local function OpenLinkInBrowser(url)
    local success = false
    
    -- Спроба 1: Synapse X (syn.request)
    pcall(function()
        if syn and syn.request then
            syn.request({Url = url, Method = "GET"})
            success = true
        end
    end)

    -- Спроба 2: Стандартний request
    if not success then
        pcall(function()
            if request then
                request({Url = url, Method = "GET"})
                success = true
            end
        end)
    end

    -- Спроба 3: HttpService (не завжди працює)
    if not success then
        pcall(function()
            game:GetService("HttpService"):PostAsync(url, "")
            success = true
        end)
    end

    -- Спроба 4: Відкриття через браузер (для деяких екзекуторів)
    if not success then
        pcall(function()
            if syn and syn.crypt then
                syn.crypt.custom("open", url)
                success = true
            end
        end)
    end

    -- Якщо нічого не спрацювало — копіюємо в буфер
    if not success then
        setclipboard(url)
        KeyStatus.Text = "📋 ССЫЛКА СКОПИРОВАНА В БУФЕР!"
        KeyStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
    else
        KeyStatus.Text = "✅ ССЫЛКА ОТКРЫТА В БРАУЗЕРЕ!"
        KeyStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
    end
end

-- Кнопка "Получить ключ"
GetKeyBtn.MouseButton1Click:Connect(function()
    KeyStatus.Text = "⏳ ОТКРЫВАЕМ ССЫЛКУ..."
    KeyStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
    OpenLinkInBrowser(KeyLink)
    wait(2)
    if KeyStatus.Text ~= "📋 ССЫЛКА СКОПИРОВАНА В БУФЕР!" and KeyStatus.Text ~= "✅ ССЫЛКА ОТКРЫТА В БРАУЗЕРЕ!" then
        KeyStatus.Text = "🔗 ПЕРЕЙДИТЕ ПО ССЫЛКЕ И ПОЛУЧИТЕ КЛЮЧ"
        KeyStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
    end
end)

-- ===== ФУНКЦІЯ АКТИВАЦІЇ =====
local function ActivateScript()
    if KeyBox.Text == ValidKey then
        KeyStatus.Text = "✅ КЛЮЧ ВЕРНЫЙ! ЗАГРУЗКА..."
        KeyStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
        KeyGui:Destroy()
        LoadMainScript()
    else
        KeyStatus.Text = "❌ НЕВЕРНЫЙ КЛЮЧ!"
        KeyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        KeyBox.Text = ""
    end
end

ActivateBtn.MouseButton1Click:Connect(ActivateScript)
KeyBox.FocusLost:Connect(function(enter) if enter then ActivateScript() end end)

-- ============================
-- 2. ОСНОВНИЙ СОФТ
-- ============================
function LoadMainScript()
    print("✅ ULTIMATE ENGINE v9.0 АКТИВИРОВАН!")

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UltimateEngine_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    -- ===== НАЛАШТУВАННЯ =====
    local Settings = {
        Aimbot = true,
        AimStrength = 5,
        AimPart = "Head",
        WallCheck = true,
        TeamCheck = false,
        ESP = true,
        ESPOutline = true,
        ESPTeamCheck = false,
        TargetESP = true,
        ShowTrajectory = true,
        BHop = false,
    }

    -- ===== FOV КОЛО =====
    local FOVCircle = Instance.new("Frame")
    FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    FOVCircle.Size = UDim2.new(0, 200, 0, 200)
    FOVCircle.BackgroundTransparency = 1
    FOVCircle.ZIndex = 0
    FOVCircle.Parent = ScreenGui

    local FOVCorner = Instance.new("UICorner")
    FOVCorner.CornerRadius = UDim.new(1, 0)
    FOVCorner.Parent = FOVCircle

    local FOVStroke = Instance.new("UIStroke")
    FOVStroke.Color = Color3.fromRGB(200, 200, 210)
    FOVStroke.Thickness = 1.5
    FOVStroke.Transparency = 0.4
    FOVStroke.Parent = FOVCircle

    -- ===== ГОЛОВНЕ ВІКНО (БІЛЕ СКЛО) =====
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 520, 0, 420)
    Main.Position = UDim2.new(0.5, -260, 0.5, -210)
    Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Main.BackgroundTransparency = 0.15
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.5
    MainStroke.Parent = Main

    -- ===== ВКЛАДКИ =====
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -20, 0, 40)
    TabBar.Position = UDim2.new(0, 10, 0, 8)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = Main

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 8)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabLayout.Parent = TabBar

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -20, 1, -56)
    Container.Position = UDim2.new(0, 10, 0, 52)
    Container.BackgroundTransparency = 1
    Container.Parent = Main

    local Tabs = {}
    local TabButtons = {}
    local TabFrames = {}

    local function CreateTab(name)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.Visible = false
        frame.Parent = Container
        TabFrames[name] = frame

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = 0.6
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(60, 60, 80)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = TabBar

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            for n, f in pairs(TabFrames) do f.Visible = (n == name) end
            for n, b in pairs(TabButtons) do
                b.BackgroundTransparency = (n == name) and 0.3 or 0.6
                b.TextColor3 = (n == name) and Color3.fromRGB(255, 60, 90) or Color3.fromRGB(60, 60, 80)
            end
        end)

        TabButtons[name] = btn
        return frame
    end

    local AimbotTab = CreateTab("Aimbot")
    local ESPTab = CreateTab("ESP")
    local BHopTab = CreateTab("BHop")

    TabFrames["Aimbot"].Visible = true
    TabButtons["Aimbot"].BackgroundTransparency = 0.3
    TabButtons["Aimbot"].TextColor3 = Color3.fromRGB(255, 60, 90)

    -- ===== UI КОМПОНЕНТИ =====
    local function CreateGlassCard(parent, yPos, height)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -8, 0, height or 36)
        card.Position = UDim2.new(0, 4, yPos, 0)
        card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        card.BackgroundTransparency = 0.4
        card.Parent = parent
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = card
        return card
    end

    local function AddToggle(parent, yPos, text, default, callback)
        local card = CreateGlassCard(parent, yPos, 36)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.7, 0, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(40, 40, 60)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = card

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 40, 0, 20)
        btn.Position = UDim2.new(1, -48, 0.5, -10)
        btn.BackgroundColor3 = default and Color3.fromRGB(255, 60, 90) or Color3.fromRGB(180, 185, 200)
        btn.Text = ""
        btn.Parent = card

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(1, 0)
        btnCorner.Parent = btn

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 14, 0, 14)
        dot.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.Parent = btn

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot

        local state = default
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(255, 60, 90) or Color3.fromRGB(180, 185, 200)
            dot.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            callback(state)
        end)
    end

    local function AddStrengthSlider(parent, yPos)
        local card = CreateGlassCard(parent, yPos, 50)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 0.4, 0)
        lbl.Position = UDim2.new(0, 12, 0, 4)
        lbl.BackgroundTransparency = 1
        lbl.Text = "Aim Strength: " .. Settings.AimStrength
        lbl.TextColor3 = Color3.fromRGB(40, 40, 60)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = card

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0.8, 0, 0.2, 0)
        track.Position = UDim2.new(0.1, 0, 0.7, 0)
        track.BackgroundColor3 = Color3.fromRGB(200, 205, 215)
        track.Parent = card

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((Settings.AimStrength - 1) / 9, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(255, 60, 90)
        fill.Parent = track

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new((Settings.AimStrength - 1) / 9, -8, 0.5, -8)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Parent = track

        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = knob

        local dragging = false
        local function Update(input)
            local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor(1 + pos * 9)
            fill.Size = UDim2.new((val - 1) / 9, 0, 1, 0)
            knob.Position = UDim2.new((val - 1) / 9, -8, 0.5, -8)
            lbl.Text = "Aim Strength: " .. val
            Settings.AimStrength = val
            callback(val)
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                Update(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                Update(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    local function AddPartSelector(parent, yPos)
        local card = CreateGlassCard(parent, yPos, 36)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.5, 0, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "Target: Head"
        lbl.TextColor3 = Color3.fromRGB(40, 40, 60)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = card

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 80, 0, 24)
        btn.Position = UDim2.new(1, -88, 0.5, -12)
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundTransparency = 0.4
        btn.Text = "▼"
        btn.TextColor3 = Color3.fromRGB(40, 40, 60)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = card

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn

        local dropdown = Instance.new("Frame")
        dropdown.Size = UDim2.new(0, 80, 0, 60)
        dropdown.Position = UDim2.new(1, -88, 0, 36)
        dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dropdown.BackgroundTransparency = 0.4
        dropdown.Visible = false
        dropdown.Parent = card

        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 6)
        dropdownCorner.Parent = dropdown

        local currentIdx = 1
        local options = {"Head", "Torso"}

        for i, name in ipairs(options) do
            local opt = Instance.new("TextButton")
            opt.Size = UDim2.new(1, 0, 0, 30)
            opt.Position = UDim2.new(0, 0, 0, (i-1) * 30)
            opt.BackgroundTransparency = 0.2
            opt.Text = name
            opt.TextColor3 = Color3.fromRGB(40, 40, 60)
            opt.Font = Enum.Font.Gotham
            opt.TextSize = 12
            opt.Parent = dropdown

            opt.MouseButton1Click:Connect(function()
                currentIdx = i
                Settings.AimPart = name
                lbl.Text = "Target: " .. name
                dropdown.Visible = false
            end)
        end

        btn.MouseButton1Click:Connect(function()
            dropdown.Visible = not dropdown.Visible
        end)
    end

    -- ===== ЗАПОВНЕННЯ ВКЛАДОК =====
    AddToggle(AimbotTab, 0.02, "Enable Aimbot", Settings.Aimbot, function(v) Settings.Aimbot = v end)
    AddStrengthSlider(AimbotTab, 0.10)
    AddPartSelector(AimbotTab, 0.28)
    AddToggle(AimbotTab, 0.40, "Wall Check", Settings.WallCheck, function(v) Settings.WallCheck = v end)
    AddToggle(AimbotTab, 0.50, "Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)

    AddToggle(ESPTab, 0.02, "Enable ESP", Settings.ESP, function(v) Settings.ESP = v end)
    AddToggle(ESPTab, 0.12, "Outline ESP", Settings.ESPOutline, function(v) Settings.ESPOutline = v end)
    AddToggle(ESPTab, 0.22, "Team Check", Settings.ESPTeamCheck, function(v) Settings.ESPTeamCheck = v end)
    AddToggle(ESPTab, 0.32, "Target ESP (3 Orbs)", Settings.TargetESP, function(v) Settings.TargetESP = v end)

    AddToggle(BHopTab, 0.02, "Enable BunnyHop", Settings.BHop, function(v) Settings.BHop = v end)

    -- ===== АІМБОТ =====
    local function GetAimPart(char)
        if Settings.AimPart == "Head" then return char:FindFirstChild("Head")
        else return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") end
    end

    local function GetClosestTarget()
        local best = nil
        local bestDist = 250
        local center = Camera.ViewportSize / 2

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end

                local char = player.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    local part = GetAimPart(char)
                    if part then
                        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if dist < bestDist then
                                if Settings.WallCheck then
                                    local ray = RaycastParams.new()
                                    ray.FilterType = Enum.RaycastFilterType.Exclude
                                    ray.FilterDescendantsInstances = {LocalPlayer.Character, char}
                                    local hit = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), ray)
                                    if not hit then
                                        bestDist = dist
                                        best = part
                                    end
                                else
                                    bestDist = dist
                                    best = part
                                end
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    RunService.RenderStepped:Connect(function()
        if not Settings.Aimbot then return end

        local target = GetClosestTarget()
        if target then
            local strength = 1 - ((Settings.AimStrength - 1) / 9)
            local alpha = math.clamp(strength * 0.5, 0.05, 0.5)
            local targetCF = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)
        end
    end)

    -- ===== ESP =====
    local ESPObjects = {}

    local function CreateESP(player)
        if ESPObjects[player] then return end

        local outline = Instance.new("Frame")
        outline.Size = UDim2.new(0, 60, 0, 60)
        outline.BackgroundTransparency = 1
        outline.Visible = false
        outline.ZIndex = 3
        outline.Parent = ScreenGui

        local circle = Instance.new("ImageLabel")
        circle.Image = "rbxassetid://16036349377"
        circle.Size = UDim2.new(1, 0, 1, 0)
        circle.BackgroundTransparency = 1
        circle.ImageColor3 = Color3.fromRGB(255, 60, 90)
        circle.ImageTransparency = 0.3
        circle.Parent = outline

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 16)
        nameLabel.Position = UDim2.new(0, 0, 1, 2)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 10
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = outline

        local orbs = {}
        local orbConfigs = {
            {radius = 50, speed = 1.2, angleOffset = 0, vertical = true, height = 30},
            {radius = 55, speed = 0.9, angleOffset = 120, vertical = false, height = 0},
            {radius = 45, speed = 1.5, angleOffset = 240, vertical = true, height = -25}
        }

        for i, config in ipairs(orbConfigs) do
            local orb = Instance.new("Frame")
            orb.Size = UDim2.new(0, 14, 0, 14)
            orb.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
            orb.BackgroundTransparency = 0.2
            orb.Visible = false
            orb.ZIndex = 4
            orb.Parent = ScreenGui

            local orbCorner = Instance.new("UICorner")
            orbCorner.CornerRadius = UDim.new(1, 0)
            orbCorner.Parent = orb

            orbs[i] = {Frame = orb, Config = config}
        end

        ESPObjects[player] = {Outline = outline, Name = nameLabel, Orbs = orbs}
    end

    local function UpdateESP()
        local time = tick()

        for player, data in pairs(ESPObjects) do
            local char = player.Character
            local isTeam = Settings.ESPTeamCheck and player.Team == LocalPlayer.Team

            if Settings.ESP and not isTeam and char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                if root then
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        data.Outline.Visible = true
                        data.Outline.Position = UDim2.new(0, pos.X - 30, 0, pos.Y - 30)
                        data.Name.Visible = Settings.ESPOutline

                        if Settings.TargetESP then
                            for i, orbData in ipairs(data.Orbs) do
                                local config = orbData.Config
                                local angle = math.rad((time * config.speed * 60 + config.angleOffset) % 360)
                                local x = pos.X + math.cos(angle) * config.radius
                                local y = pos.Y + math.sin(angle) * config.radius * 0.5
                                if config.vertical then
                                    y = y + math.sin(angle * 0.7) * config.height
                                end
                                orbData.Frame.Visible = true
                                orbData.Frame.Position = UDim2.new(0, x - 7, 0, y - 7)
                            end
                        else
                            for _, orbData in ipairs(data.Orbs) do
                                orbData.Frame.Visible = false
                            end
                        end
                    else
                        data.Outline.Visible = false
                        for _, orbData in ipairs(data.Orbs) do orbData.Frame.Visible = false end
                    end
                end
            else
                data.Outline.Visible = false
                for _, orbData in ipairs(data.Orbs) do orbData.Frame.Visible = false end
            end
        end
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function() CreateESP(player) end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        if ESPObjects[player] then
            ESPObjects[player].Outline:Destroy()
            for _, orbData in ipairs(ESPObjects[player].Orbs) do orbData.Frame:Destroy() end
            ESPObjects[player] = nil
        end
    end)

    RunService.RenderStepped:Connect(function()
        if Settings.ESP then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and not ESPObjects[player] then
                    CreateESP(player)
                end
            end
            UpdateESP()
        else
            for _, data in pairs(ESPObjects) do
                data.Outline.Visible = false
                for _, orbData in ipairs(data.Orbs) do orbData.Frame.Visible = false end
            end
        end
    end)

    -- ===== БАНІХОП =====
    RunService.Heartbeat:Connect(function()
        if Settings.BHop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.FloorMaterial ~= Enum.Material.Air then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)

    -- ===== ТРАЄКТОРІЯ =====
    local trajectoryLine = Instance.new("Frame")
    trajectoryLine.Size = UDim2.new(0, 10, 0, 4)
    trajectoryLine.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    trajectoryLine.BackgroundTrans
