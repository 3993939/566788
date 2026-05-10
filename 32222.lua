-- Colin Hub: Aimbot + Auto Shoot + Rainbow ESP

--[[
    Можливості:
    - Aimbot: FOV, плавність, вибір кнопки (ПКМ/ЛКМ/клавіша)
    - Auto Shoot: автоматична стрільба при наведенні
    - ESP: Rainbow Boxes, трейсери, імена, здоров'я, дистанція
    - Team Check: не чіпає своїх
    - Wall Check: не наводиться крізь стіни
]]

-- Створення GUI через Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Colin Hub | Rainbow Edition",
   LoadingTitle = "Завантаження...",
   LoadingSubtitle = "by Colin",
   Theme = "Default",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ColinRainbow",
      FileName = "Config"
   }
})

-- ==================== СЕРВІСИ ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ==================== ЗМІННІ НАЛАШТУВАНЬ ====================
_G.AimbotEnabled = false
_G.AutoShootEnabled = false
_G.Smoothness = 0.08
_G.FOV = 200
_G.TeamCheck = true
_G.WallCheck = true
_G.HitPart = "Head"
_G.AimKey = "MouseButton2" -- За замовчуванням права кнопка миші

_G.ESPEnabled = false
_G.ESPRainbow = true
_G.ESPBoxes = true
_G.ESPTracers = true
_G.ESPNames = true
_G.ESPHealth = true

-- ==================== ТАБЛИЦЯ ДЛЯ ESP ОБ'ЄКТІВ ====================
local ESPObjects = {}

-- ==================== ФУНКЦІЇ ESP ====================
local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

-- Отримання кольору веселки
local function GetRainbowColor(speed)
    local hue = (tick() * (speed or 1)) % 1
    return Color3.fromHSV(hue, 1, 1)
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local esp = {}
    
    -- Box
    esp.Box = Drawing.new("Square")
    esp.Box.Visible = false
    esp.Box.Thickness = 2
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    
    -- Tracer
    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Visible = false
    esp.Tracer.Thickness = 1
    esp.Tracer.Transparency = 0.7
    
    -- Name
    esp.NameTag = Drawing.new("Text")
    esp.NameTag.Visible = false
    esp.NameTag.Size = 14
    esp.NameTag.Center = true
    esp.NameTag.Outline = true
    esp.NameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    -- HP Bar Background
    esp.HPBarBg = Drawing.new("Square")
    esp.HPBarBg.Visible = false
    esp.HPBarBg.Color = Color3.fromRGB(40, 40, 40)
    esp.HPBarBg.Filled = true
    esp.HPBarBg.Transparency = 1
    
    -- HP Bar
    esp.HPBar = Drawing.new("Square")
    esp.HPBar.Visible = false
    esp.HPBar.Filled = true
    esp.HPBar.Transparency = 1
    
    ESPObjects[player] = esp
    
    -- Оновлення
    RunService.RenderStepped:Connect(function()
        if not player.Parent then
            RemoveESP(player)
            return
        end
        
        if not _G.ESPEnabled then
            for _, obj in pairs(esp) do obj.Visible = false end
            return
        end
        
        local char = player.Character
        if not char then
            for _, obj in pairs(esp) do obj.Visible = false end
            return
        end
        
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChild("Humanoid")
        
        if not (root and hum and hum.Health > 0) then
            for _, obj in pairs(esp) do obj.Visible = false end
            return
        end
        
        -- Team Check
        if _G.TeamCheck and player.Team == LocalPlayer.Team then
            for _, obj in pairs(esp) do obj.Visible = false end
            return
        end
        
        local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)
        
        if not rootOnScreen then
            for _, obj in pairs(esp) do obj.Visible = false end
            return
        end
        
        local topPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
        local botPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, -3.5, 0))
        
        local boxHeight = math.abs(topPos.Y - botPos.Y)
        local boxWidth = boxHeight / 1.8
        
        -- Box
        if _G.ESPBoxes then
            esp.Box.Visible = true
            esp.Box.Size = Vector2.new(boxWidth, boxHeight)
            esp.Box.Position = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight / 2)
            if _G.ESPRainbow then
                esp.Box.Color = GetRainbowColor(0.8)
            else
                esp.Box.Color = Color3.fromRGB(255, 255, 255)
            end
        else
            esp.Box.Visible = false
        end
        
        -- Tracer
        if _G.ESPTracers then
            esp.Tracer.Visible = true
            esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + boxHeight / 2)
            if _G.ESPRainbow then
                esp.Tracer.Color = GetRainbowColor(0.6)
            else
                esp.Tracer.Color = Color3.fromRGB(255, 255, 255)
            end
        else
            esp.Tracer.Visible = false
        end
        
        -- Name
        if _G.ESPNames then
            local label = player.Name
            if _G.ESPHealth then
                label = label .. " [" .. math.floor(hum.Health) .. " HP]"
            end
            esp.NameTag.Visible = true
            esp.NameTag.Text = label
            esp.NameTag.Position = Vector2.new(rootPos.X, rootPos.Y - boxHeight / 2 - 16)
            if _G.ESPRainbow then
                esp.NameTag.Color = GetRainbowColor(1)
            else
                esp.NameTag.Color = Color3.fromRGB(255, 255, 255)
            end
        else
            esp.NameTag.Visible = false
        end
        
        -- HP Bar
        if _G.ESPHealth then
            local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            esp.HPBarBg.Visible = true
            esp.HPBarBg.Size = Vector2.new(boxWidth, 3)
            esp.HPBarBg.Position = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight / 2 - 6)
            esp.HPBar.Visible = true
            esp.HPBar.Size = Vector2.new(boxWidth * hpRatio, 3)
            esp.HPBar.Position = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight / 2 - 6)
            
            if hpRatio > 0.6 then
                esp.HPBar.Color = Color3.fromRGB(0, 255, 0)
            elseif hpRatio > 0.3 then
                esp.HPBar.Color = Color3.fromRGB(255, 255, 0)
            else
                esp.HPBar.Color = Color3.fromRGB(255, 0, 0)
            end
        else
            esp.HPBarBg.Visible = false
            esp.HPBar.Visible = false
        end
    end)
end

-- Ініціалізація ESP
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- ==================== ФУНКЦІЇ АІМБОТУ ====================

-- Wall Check
local function IsBehindWall(targetPart)
    if not _G.WallCheck then return false end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return true end
    
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local result = workspace:Raycast(origin, direction, rayParams)
    if result then
        return not result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return false
end

-- Пошук цілі
local function GetAimTarget()
    local bestDist = _G.FOV
    local bestTarget = nil
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end
        local hum = char:FindFirstChild("Humanoid")
        local hitPart = char:FindFirstChild(_G.HitPart)
        if not (hum and hitPart) or hum.Health <= 0 then continue end
        if _G.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
        if onScreen then
            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
            if screenDist < bestDist then
                if not IsBehindWall(hitPart) then
                    bestDist = screenDist
                    bestTarget = hitPart
                end
            end
        end
    end
    return bestTarget
end

-- Функція перевірки натискання клавіші аіму
local function IsAimKeyPressed()
    local aimKey = _G.AimKey
    if aimKey == "MouseButton1" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif aimKey == "MouseButton2" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    else
        -- Якщо це клавіша клавіатури
        return UserInputService:IsKeyDown(Enum.KeyCode[aimKey])
    end
end

-- Auto Shoot
local function AutoShoot()
    if _G.AutoShootEnabled and _G.AimbotEnabled then
        VirtualInputManager:Button1Down(Vector2.new(), game:GetService("UserInputService"))
        task.wait(0.05)
        VirtualInputManager:Button1Up(Vector2.new(), game:GetService("UserInputService"))
    end
end

-- Основний цикл аіму
local currentTarget = nil

RunService.RenderStepped:Connect(function()
    if _G.AimbotEnabled and IsAimKeyPressed() then
        local target = GetAimTarget()
        if target then
            -- Плавне наведення
            local targetDirection = (target.Position - Camera.CFrame.Position).Unit
            local smoothFrame = Camera.CFrame.LookVector:Lerp(targetDirection, _G.Smoothness)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + smoothFrame)
            
            -- Auto Shoot при наведенні
            AutoShoot()
            
            -- Автоматична активація ПКМ
            if _G.AutoShootEnabled then
                VirtualInputManager:Button2Down(Vector2.new(), game:GetService("UserInputService"))
                task.wait(0.01)
                VirtualInputManager:Button2Up(Vector2.new(), game:GetService("UserInputService"))
            end
        end
        currentTarget = target
    else
        currentTarget = nil
    end
end)

-- ==================== GUI ВКЛАДКИ ====================

-- Вкладка Aimbot
local AimTab = Window:CreateTab("Aimbot", 4483362458)

AimTab:CreateSection("Основні налаштування")
AimTab:CreateToggle({
   Name = "Увімкнути Aimbot",
   CurrentValue = false,
   Callback = function(v) _G.AimbotEnabled = v end,
})
AimTab:CreateToggle({
   Name = "Auto Shoot",
   CurrentValue = false,
   Callback = function(v) _G.AutoShootEnabled = v end,
})

AimTab:CreateSection("Кнопка активації")
AimTab:CreateButton({
   Name = "Кнопка: ПКМ",
   Callback = function() _G.AimKey = "MouseButton2" end,
})
AimTab:CreateButton({
   Name = "Кнопка: ЛКМ",
   Callback = function() _G.AimKey = "MouseButton1" end,
})
AimTab:CreateButton({
   Name = "Кнопка: E",
   Callback = function() _G.AimKey = "E" end,
})
AimTab:CreateButton({
   Name = "Кнопка: Q",
   Callback = function() _G.AimKey = "Q" end,
})

AimTab:CreateSection("Ціль")
AimTab:CreateButton({
   Name = "Target: Head",
   Callback = function() _G.HitPart = "Head" end,
})
AimTab:CreateButton({
   Name = "Target: Torso",
   Callback = function() _G.HitPart = "HumanoidRootPart" end,
})

AimTab:CreateSection("Налаштування")
AimTab:CreateSlider({
   Name = "Плавність (Smoothness)",
   Range = {0.01, 0.3},
   Increment = 0.01,
   CurrentValue = 0.08,
   Callback = function(v) _G.Smoothness = v end,
})
AimTab:CreateSlider({
   Name = "FOV (Радіус)",
   Range = {50, 500},
   Increment = 5,
   CurrentValue = 200,
   Callback = function(v) _G.FOV = v end,
})
AimTab:CreateToggle({
   Name = "Team Check",
   CurrentValue = true,
   Callback = function(v) _G.TeamCheck = v end,
})
AimTab:CreateToggle({
   Name = "Wall Check",
   CurrentValue = true,
   Callback = function(v) _G.WallCheck = v end,
})

-- Вкладка ESP
local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateSection("Налаштування ESP")
ESPTab:CreateToggle({
   Name = "Увімкнути ESP",
   CurrentValue = false,
   Callback = function(v) _G.ESPEnabled = v end,
})
ESPTab:CreateToggle({
   Name = "Rainbow Mode",
   CurrentValue = true,
   Callback = function(v) _G.ESPRainbow = v end,
})
ESPTab:CreateToggle({
   Name = "Бокси",
   CurrentValue = true,
   Callback = function(v) _G.ESPBoxes = v end,
})
ESPTab:CreateToggle({
   Name = "Трейсери",
   CurrentValue = true,
   Callback = function(v) _G.ESPTracers = v end,
})
ESPTab:CreateToggle({
   Name = "Імена",
   CurrentValue = true,
   Callback = function(v) _G.ESPNames = v end,
})
ESPTab:CreateToggle({
   Name = "HP Бари",
   CurrentValue = true,
   Callback = function(v) _G.ESPHealth = v end,
})

Rayfield:LoadConfiguration()
