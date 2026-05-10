-- Colin Hub: Auto-Aim (No Key Hold) + ESP
-- F4 = меню
-- Увімкнув тогл — аім сам працює постійно

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Colin Hub | Auto-Aim & ESP", "BloodTheme")
Library.ToggleKey = Enum.KeyCode.F4

-- Змінні
_G.AutoAim = false
_G.EspEnabled = false
_G.Smoothness = 0.1
_G.TeamCheck = true
_G.AimRadius = 500
_G.ShowTracers = true
_G.ShowNames = true
_G.ShowHP = true
_G.ShowDistance = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Вкладка Аімботу
local Main = Window:NewTab("Аімбот")
local MainSection = Main:NewSection("Автоматичне наведення")

MainSection:NewToggle("Авто-Аім (Постійно)", "Наводиться сам без кнопок", function(state)
    _G.AutoAim = state
end)

MainSection:NewSlider("Плавність", "Менше = швидше наведення", 300, 10, function(s)
    _G.Smoothness = s / 1000
end)

MainSection:NewToggle("Перевірка команди", "Не чіпати своїх", function(state)
    _G.TeamCheck = state
end)

MainSection:NewSlider("Радіус захвату", "Більше = далі хапає", 1000, 100, function(s)
    _G.AimRadius = s
end)

-- Вкладка ESP
local Visuals = Window:NewTab("Візуал")
local VisualSection = Visuals:NewSection("ESP Налаштування")

VisualSection:NewToggle("Box ESP", "Бачити ворогів крізь стіни", function(state)
    _G.EspEnabled = state
end)

VisualSection:NewToggle("Трейсери", "Лінії до ворогів", function(state)
    _G.ShowTracers = state
end)

VisualSection:NewToggle("Імена", "Показувати ніки", function(state)
    _G.ShowNames = state
end)

VisualSection:NewToggle("HP", "Показувати здоров'я", function(state)
    _G.ShowHP = state
end)

VisualSection:NewToggle("Дистанція", "Показувати відстань", function(state)
    _G.ShowDistance = state
end)

-- ФУНКЦІЯ ПОШУКУ ЦІЛІ
local function GetClosestPlayer()
    local target = nil
    local shortestDistance = _G.AimRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local myTeam = LocalPlayer.Team

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChild("Humanoid")
        
        if not (head and hum) or hum.Health <= 0 then continue end
        if _G.TeamCheck and player.Team == myTeam then continue end

        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen then
            local magnitude = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
            if magnitude < shortestDistance then
                target = head
                shortestDistance = magnitude
            end
        end
    end
    return target
end

-- ЦИКЛ АІМБОТУ (працює постійно, коли тогл увімкнено)
RunService.RenderStepped:Connect(function()
    if _G.AutoAim then
        local target = GetClosestPlayer()
        if target then
            local lookVector = (target.Position - Camera.CFrame.Position).Unit
            local targetCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, _G.Smoothness)
        end
    end
end)

-- ЛОГІКА ESP
local ESPCache = {}

local function RemoveESP(player)
    if ESPCache[player] then
        for _, obj in pairs(ESPCache[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPCache[player] = nil
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local esp = {}
    
    esp.Box = Drawing.new("Square")
    esp.Box.Visible = false
    esp.Box.Color = Color3.fromRGB(255, 50, 50)
    esp.Box.Thickness = 2
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    
    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Visible = false
    esp.Tracer.Color = Color3.fromRGB(255, 255, 255)
    esp.Tracer.Thickness = 1
    esp.Tracer.Transparency = 0.7
    
    esp.NameTag = Drawing.new("Text")
    esp.NameTag.Visible = false
    esp.NameTag.Color = Color3.fromRGB(255, 255, 255)
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
    esp.HPBar.Color = Color3.fromRGB(0, 255, 0)
    esp.HPBar.Filled = true
    esp.HPBar.Transparency = 1
    
    ESPCache[player] = esp
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not player.Parent then
            RemoveESP(player)
            connection:Disconnect()
            return
        end
        
        local enabled = _G.EspEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid")
        
        if not enabled or (player.Character.Humanoid.Health <= 0) then
            for _, obj in pairs(esp) do obj.Visible = false end
            return
        end
        
        if _G.TeamCheck and player.Team == LocalPlayer.Team then
            for _, obj in pairs(esp) do obj.Visible = false end
            return
        end
        
        local root = player.Character.HumanoidRootPart
        local hum = player.Character.Humanoid
        local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)
        
        if not rootOnScreen then
            for _, obj in pairs(esp) do obj.Visible = false end
            return
        end
        
        local topPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
        local botPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, -3.5, 0))
        local boxHeight = math.abs(topPos.Y - botPos.Y)
        local boxWidth = boxHeight / 1.8
        
        if _G.EspEnabled then
            esp.Box.Visible = true
            esp.Box.Size = Vector2.new(boxWidth, boxHeight)
            esp.Box.Position = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight / 2)
        else
            esp.Box.Visible = false
        end
        
        if _G.ShowTracers then
            esp.Tracer.Visible = true
            esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + boxHeight / 2)
        else
            esp.Tracer.Visible = false
        end
        
        if _G.ShowNames then
            local label = player.Name
            if _G.ShowHP then label = label .. " [" .. math.floor(hum.Health) .. " HP]" end
            if _G.ShowDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                label = label .. " [" .. math.floor(dist) .. "m]"
            end
            esp.NameTag.Visible = true
            esp.NameTag.Text = label
            esp.NameTag.Position = Vector2.new(rootPos.X, rootPos.Y - boxHeight / 2 - 16)
        else
            esp.NameTag.Visible = false
        end
        
        if _G.ShowHP then
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

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end

Players.PlayerAdded:Connect(function(p) CreateESP(p) end)
Players.PlayerRemoving:Connect(function(p) RemoveESP(p) end)

Library:Notify("Colin Hub", "F4 — меню | Аім працює без кнопок", 5)
