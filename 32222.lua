-- Colin Hub: Aimbot + Rainbow ESP [NO VIRTUALINPUTMANAGER - FIXED 267]
-- F4 = меню

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Colin Hub | Safe Edition",
   LoadingTitle = "Завантаження...",
   LoadingSubtitle = "by Colin",
   Theme = "Default",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ColinSafe",
      FileName = "Config"
   }
})

-- ==================== СЕРВІСИ ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ==================== ЗМІННІ ====================
_G.AimbotEnabled = false
_G.AutoShootEnabled = false
_G.Smoothness = 0.08
_G.FOV = 200
_G.TeamCheck = true
_G.WallCheck = true
_G.HitPart = "Head"
_G.AimKey = "MouseButton2"

_G.ESPEnabled = false
_G.ESPRainbow = true
_G.ESPBoxes = true
_G.ESPTracers = true
_G.ESPNames = true
_G.ESPHealth = true

-- ==================== ESP ====================
local ESPObjects = {}

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

local function GetRainbowColor(speed)
    local hue = (tick() * (speed or 1)) % 1
    return Color3.fromHSV(hue, 1, 1)
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local esp = {}
    
    esp.Box = Drawing.new("Square")
    esp.Box.Visible = false
    esp.Box.Thickness = 2
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    
    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Visible = false
    esp.Tracer.Thickness = 1
    esp.Tracer.Transparency = 0.7
    
    esp.NameTag = Drawing.new("Text")
    esp.NameTag.Visible = false
    esp.NameTag.Size = 14
    esp.NameTag.Center = true
    esp.NameTag.Outline = true
    esp.NameTag.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    esp.HPBarBg = Drawing.new("Square")
    esp.HPBarBg.Visible = false
    esp.HPBarBg.Color = Color3.fromRGB(40, 40, 40)
    esp.HPBarBg.Filled = true
    esp.HPBarBg.Transparency = 1
    
    esp.HPBar = Drawing.new("Square")
    esp.HPBar.Visible = false
    esp.HPBar.Filled = true
    esp.HPBar.Transparency = 1
    
    ESPObjects[player] = esp
    
    RunService.RenderStepped:Connect(function()
        if not player.Parent then RemoveESP(player) return end
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
        local hum = char:FindFirstChild("Humanoid")
        
        if not (root and hum and hum.Health > 0) then
            for _, obj in pairs(esp) do obj.Visible = false end
            return
        end
        
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
        
        if _G.ESPBoxes then
            esp.Box.Visible = true
            esp.Box.Size = Vector2.new(boxWidth, boxHeight)
            esp.Box.Position = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2)
            esp.Box.Color = _G.ESPRainbow and GetRainbowColor(0.8) or Color3.fromRGB(255, 255, 255)
        else
            esp.Box.Visible = false
        end
        
        if _G.ESPTracers then
            esp.Tracer.Visible = true
            esp.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + boxHeight/2)
            esp.Tracer.Color = _G.ESPRainbow and GetRainbowColor(0.6) or Color3.fromRGB(255, 255, 255)
        else
            esp.Tracer.Visible = false
        end
        
        if _G.ESPNames then
            local label = player.Name
            if _G.ESPHealth then label = label .. " [" .. math.floor(hum.Health) .. " HP]" end
            esp.NameTag.Visible = true
            esp.NameTag.Text = label
            esp.NameTag.Position = Vector2.new(rootPos.X, rootPos.Y - boxHeight/2 - 16)
            esp.NameTag.Color = _G.ESPRainbow and GetRainbowColor(1) or Color3.fromRGB(255, 255, 255)
        else
            esp.NameTag.Visible = false
        end
        
        if _G.ESPHealth then
            local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            esp.HPBarBg.Visible = true
            esp.HPBarBg.Size = Vector2.new(boxWidth, 3)
            esp.HPBarBg.Position = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2 - 6)
            esp.HPBar.Visible = true
            esp.HPBar.Size = Vector2.new(boxWidth * hpRatio, 3)
            esp.HPBar.Position = Vector2.new(rootPos.X - boxWidth/2, rootPos.Y - boxHeight/2 - 6)
            esp.HPBar.Color = hpRatio > 0.6 and Color3.fromRGB(0, 255, 0) or (hpRatio > 0.3 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0))
        else
            esp.HPBarBg.Visible = false
            esp.HPBar.Visible = false
        end
    end)
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- ==================== АІМБОТ ====================
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

local function IsAimKeyPressed()
    local aimKey = _G.AimKey
    if aimKey == "MouseButton1" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif aimKey == "MouseButton2" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    else
        return UserInputService:IsKeyDown(Enum.KeyCode[aimKey])
    end
end

-- БЕЗПЕЧНИЙ Auto Shoot (без VirtualInputManager)
local function SafeClick()
    pcall(function()
        -- Спроба через стандартний Mouse
        Mouse:Button1Down()
        task.wait(0.05)
        Mouse:Button1Up()
    end)
end

RunService.RenderStepped:Connect(function()
    if _G.AimbotEnabled and IsAimKeyPressed() then
        local target = GetAimTarget()
        if target then
            local targetDirection = (target.Position - Camera.CFrame.Position).Unit
            local smoothFrame = Camera.CFrame.LookVector:Lerp(targetDirection, _G.Smoothness)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + smoothFrame)
            
            -- Auto Shoot (без VirtualInputManager)
            if _G.AutoShootEnabled then
                SafeClick()
            end
        end
    end
end)

-- ==================== GUI ====================
local AimTab = Window:CreateTab("Aimbot", 4483362458)
AimTab:CreateSection("Основні налаштування")
AimTab:CreateToggle({Name = "Увімкнути Aimbot", CurrentValue = false, Callback = function(v) _G.AimbotEnabled = v end})
AimTab:CreateToggle({Name = "Auto Shoot (Safe)", CurrentValue = false, Callback = function(v) _G.AutoShootEnabled = v end})

AimTab:CreateSection("Кнопка активації")
AimTab:CreateButton({Name = "Кнопка: ПКМ", Callback = function() _G.AimKey = "MouseButton2" end})
AimTab:CreateButton({Name = "Кнопка: ЛКМ", Callback = function() _G.AimKey = "MouseButton1" end})
AimTab:CreateButton({Name = "Кнопка: E", Callback = function() _G.AimKey = "E" end})
AimTab:CreateButton({Name = "Кнопка: Q", Callback = function() _G.AimKey = "Q" end})

AimTab:CreateSection("Ціль")
AimTab:CreateButton({Name = "Target: Head", Callback = function() _G.HitPart = "Head" end})
AimTab:CreateButton({Name = "Target: Torso", Callback = function() _G.HitPart = "HumanoidRootPart" end})

AimTab:CreateSection("Налаштування")
AimTab:CreateSlider({Name = "Плавність", Range = {0.01, 0.3}, Increment = 0.01, CurrentValue = 0.08, Callback = function(v) _G.Smoothness = v end})
AimTab:CreateSlider({Name = "FOV (Радіус)", Range = {50, 500}, Increment = 5, CurrentValue = 200, Callback = function(v) _G.FOV = v end})
AimTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) _G.TeamCheck = v end})
AimTab:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(v) _G.WallCheck = v end})

local ESPTab = Window:CreateTab("ESP", 4483362458)
ESPTab:CreateSection("Налаштування ESP")
ESPTab:CreateToggle({Name = "Увімкнути ESP", CurrentValue = false, Callback = function(v) _G.ESPEnabled = v end})
ESPTab:CreateToggle({Name = "Rainbow Mode", CurrentValue = true, Callback = function(v) _G.ESPRainbow = v end})
ESPTab:CreateToggle({Name = "Бокси", CurrentValue = true, Callback = function(v) _G.ESPBoxes = v end})
ESPTab:CreateToggle({Name = "Трейсери", CurrentValue = true, Callback = function(v) _G.ESPTracers = v end})
ESPTab:CreateToggle({Name = "Імена", CurrentValue = true, Callback = function(v) _G.ESPNames = v end})
ESPTab:CreateToggle({Name = "HP Бари", CurrentValue = true, Callback = function(v) _G.ESPHealth = v end})

Rayfield:LoadConfiguration()
