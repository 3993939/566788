--[[
    ВИПРАВЛЕНИЙ ТА ОПТИМІЗОВАНИЙ AIMBOT PRO v3
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ГОЛОВНЕ ВІКНО (Orion Library)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "🔫 AIMBOT PRO v3",
    HidePremium = false,
    SaveConfig = true,
    IntroText = "АКТИВОВАНО",
    IntroEnabled = true
})

local MainTab = Window:MakeTab({
    Name = "Налаштування",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- НАЛАШТУВАННЯ
local Settings = {
    Enabled = true,
    Smoothness = 0.15,
    FOV = 150,
    TeamCheck = false,
    WallCheck = true,
    AimPart = "Head",
    ShowFOV = true
}

-- МАЛЮВАННЯ FOV КОЛА (Drawing API)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Radius = Settings.FOV
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Visible = Settings.ShowFOV

-- ЕЛЕМЕНТИ УПРАВЛІННЯ GUI
MainTab:AddToggle({
    Name = "🟢 Увімкнути Аім",
    Default = Settings.Enabled,
    Callback = function(value)
        Settings.Enabled = value
    end
})

MainTab:AddToggle({
    Name = "⭕ Показувати коло FOV",
    Default = Settings.ShowFOV,
    Callback = function(value)
        Settings.ShowFOV = value
        FOVCircle.Visible = value
    end
})

MainTab:AddSlider({
    Name = "🎯 Плавність (0 = миттєво)",
    Min = 0,
    Max = 0.5,
    Default = Settings.Smoothness,
    Increment = 0.01,
    Callback = function(value)
        Settings.Smoothness = value
    end
})

MainTab:AddSlider({
    Name = "📐 Радіус FOV",
    Min = 30,
    Max = 500,
    Default = Settings.FOV,
    Increment = 5,
    Callback = function(value)
        Settings.FOV = value
        FOVCircle.Radius = value
    end
})

MainTab:AddDropdown({
    Name = "🎯 Частина тіла",
    Default = "Голова",
    Options = {"Голова", "Тулуб"},
    Callback = function(value)
        if value == "Голова" then 
            Settings.AimPart = "Head"
        elseif value == "Тулуб" then 
            Settings.AimPart = "HumanoidRootPart"
        end
    end
})

MainTab:AddToggle({
    Name = "🧱 Перевірка стін",
    Default = Settings.WallCheck,
    Callback = function(value)
        Settings.WallCheck = value
    end
})

MainTab:AddToggle({
    Name = "👥 Перевірка команди",
    Default = Settings.TeamCheck,
    Callback = function(value)
        Settings.TeamCheck = value
    end
})

-- ПЕРЕВІРКА ВИДИМОСТІ (RAYCAST)
local function IsVisible(targetPart, targetCharacter)
    if not Settings.WallCheck then return true end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local ignoreList = {Camera}
    if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
    if targetCharacter then table.insert(ignoreList, targetCharacter) end
    
    raycastParams.FilterDescendantsInstances = ignoreList
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

-- ПОШУК НАЙБЛИЖЧОЇ ЦІЛІ У МЕЖАХ FOV
local function GetClosestTarget()
    local closestTarget = nil
    local shortestDistance = Settings.FOV
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local part = char:FindFirstChild(Settings.AimPart) or char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                
                if part then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    
                    if onScreen then
                        local targetPos2D = Vector2.new(screenPos.X, screenPos.Y)
                        local distance = (targetPos2D - centerScreen).Magnitude
                        
                        if distance <= shortestDistance then
                            if IsVisible(part, char) then
                                shortestDistance = distance
                                closestTarget = part
                            end
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

-- ОСНОВНИЙ ЦИКЛ ОНОВЛЕННЯ
RunService.RenderStepped:Connect(function()
    -- Оновлення позиції кола FOV у центрі екрана
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if not Settings.Enabled then return end

    local targetPart = GetClosestTarget()
    
    if targetPart then
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        
        if Settings.Smoothness == 0 then
            Camera.CFrame = targetCFrame
        else
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
        end
    end
end)

-- ТЕСТОВИЙ СПАВН NPC (ДЛЯ ОФЛАЙНУ)
MainTab:AddButton({
    Name = "🧟 Спавнити тестових NPC",
    Callback = function()
        for i = 1, 3 do
            local model = Instance.new("Model")
            model.Name = "Dummy_NPC_" .. i
            
            local humanoid = Instance.new("Humanoid", model)
            
            local root = Instance.new("Part")
            root.Name = "HumanoidRootPart"
            root.Size = Vector3.new(2, 2, 1)
            root.Position = LocalPlayer.Character and (LocalPlayer.Character.PrimaryPart.Position + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20))) or Vector3.new(0, 5, 0)
            root.Anchored = true
            root.Parent = model
            
            local head = Instance.new("Part")
            head.Name = "Head"
            head.Size = Vector3.new(1.2, 1.2, 1.2)
            head.Position = root.Position + Vector3.new(0, 2.5, 0)
            head.Anchored = true
            head.Color = Color3.fromRGB(255, 200, 150)
            head.Parent = model
            
            model.PrimaryPart = root
            model.Parent = workspace
        end
        
        OrionLib:MakeNotification({
            Name = "Успішно",
            Content = "Створено NPC для тестування",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

OrionLib:Init()
print("✅ AIMBOT PRO v3 УСПІШНО ЗАВАНТАЖЕНО!")
