--[[
    РОБОЧИЙ АІМБОТ З ПЛАВНИМ НАВЕДЕННЯМ ТА ПЕРЕВІРКОЮ СТІН
    ВСТАВТЕ В БУДЬ-ЯКИЙ ЕКЗЕКУТОР (LEVEL 7)
    КЕРУВАННЯ: КНОПКА "СТАРТ" В GUI
]]

-- СТВОРЕННЯ GUI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ГОЛОВНЕ ВІКНО
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
    AimPart = "Head"
}

-- ПЕРЕМИКАЧ ВКЛ/ВИКЛ
MainTab:AddToggle({
    Name = "🟢 Увімкнути Аім",
    Default = true,
    Callback = function(value)
        Settings.Enabled = value
    end
})

MainTab:AddSlider({
    Name = "🎯 Плавність (0 = миттєво)",
    Min = 0,
    Max = 0.5,
    Default = 0.15,
    Increment = 0.01,
    Callback = function(value)
        Settings.Smoothness = value
    end
})

MainTab:AddSlider({
    Name = "📐 Радіус FOV",
    Min = 50,
    Max = 400,
    Default = 150,
    Increment = 5,
    Callback = function(value)
        Settings.FOV = value
    end
})

MainTab:AddDropdown({
    Name = "🎯 Частина тіла",
    Default = "Голова",
    Options = {"Голова", "Тулуб", "Ноги"},
    Callback = function(value)
        if value == "Голова" then Settings.AimPart = "Head"
        elseif value == "Тулуб" then Settings.AimPart = "UpperTorso"
        elseif value == "Ноги" then Settings.AimPart = "LowerTorso" end
    end
})

MainTab:AddToggle({
    Name = "🧱 Перевірка стін",
    Default = true,
    Callback = function(value)
        Settings.WallCheck = value
    end
})

-- СПИСОК ГРАВЦІВ
local function GetValidTargets()
    local targets = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            local part = player.Character:FindFirstChild(Settings.AimPart)
            if part then
                table.insert(targets, {Player = player, Part = part})
            end
        end
    end
    return targets
end

-- ПЕРЕВІРКА СТІН (RAYCAST)
local function IsVisible(targetPart)
    if not Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart}
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

-- ОБЧИСЛЕННЯ КУТІВ
local function GetAngle(targetPos)
    local cameraPos = Camera.CFrame.Position
    local direction = (targetPos - cameraPos).Unit
    local angle = math.deg(math.acos(direction:Dot(Camera.CFrame.LookVector)))
    return angle
end

-- ОБ'ЄКТ ДЛЯ ПЛАВНОСТІ
local CurrentTarget = nil

-- ОСНОВНИЙ ЦИКЛ
RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then return end

    local targets = GetValidTargets()
    local bestTarget = nil
    local bestAngle = math.huge

    for _, target in pairs(targets) do
        local angle = GetAngle(target.Part.Position)
        if angle <= Settings.FOV and angle < bestAngle and IsVisible(target.Part) then
            bestAngle = angle
            bestTarget = target
        end
    end

    if bestTarget then
        CurrentTarget = bestTarget
        local targetPos = bestTarget.Part.Position
        local cameraPos = Camera.CFrame.Position
        local direction = (targetPos - cameraPos).Unit
        local targetCFrame = CFrame.new(cameraPos, cameraPos + direction)

        if Settings.Smoothness == 0 then
            Camera.CFrame = targetCFrame
        else
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
        end
    else
        CurrentTarget = nil
    end
end)

-- ВІДОБРАЖЕННЯ FOV (КОЛО НА ЕКРАНІ)
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
FOVCircle.BackgroundTransparency = 1
FOVCircle.ZIndex = 999
FOVCircle.Parent = LocalPlayer.PlayerGui:WaitForChild("ScreenGui") or Instance.new("ScreenGui", LocalPlayer.PlayerGui)

local circle = Instance.new("ImageLabel")
circle.Image = "rbxassetid://16036349377"
circle.Size = UDim2.new(1, 0, 1, 0)
circle.BackgroundTransparency = 1
circle.ImageColor3 = Color3.fromRGB(255, 0, 0)
circle.ImageTransparency = 0.7
circle.Parent = FOVCircle

-- ОНОВЛЕННЯ РАДІУСА ПРИ ЗМІНІ
MainTab:AddButton({
    Name = "🔄 Оновити FOV коло",
    Callback = function()
        FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
        FOVCircle.Position = UDim2.new(0.5, -Settings.FOV, 0.5, -Settings.FOV)
    end
})

-- ТЕСТОВИЙ СПАВН МОБІВ (ДЛЯ ОФЛАЙНУ)
MainTab:AddButton({
    Name = "🧟 Спавнити тестових NPC",
    Callback = function()
        for i = 1, 5 do
            local model = Instance.new("Model")
            model.Name = "NPC_" .. i
            local humanoid = Instance.new("Humanoid")
            humanoid.Parent = model
            local part = Instance.new("Part")
            part.Size = Vector3.new(2, 5, 1)
            part.Position = Vector3.new(math.random(-50, 50), 5, math.random(-50, 50))
            part.Anchored = true
            part.Parent = model
            model.Parent = workspace
            -- Додаємо голову
            local head = Instance.new("Part")
            head.Size = Vector3.new(1, 1, 1)
            head.Position = part.Position + Vector3.new(0, 3, 0)
            head.Anchored = true
            head.Name = "Head"
            head.Parent = model
            -- Тулуб
            local torso = Instance.new("Part")
            torso.Size = Vector3.new(2, 2, 1)
            torso.Position = part.Position + Vector3.new(0, 1.5, 0)
            torso.Anchored = true
            torso.Name = "UpperTorso"
            torso.Parent = model
        end
        OrionLib:MakeNotification({
            Name = "Готово",
            Content = "Створено 5 NPC для тестування",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

OrionLib:Init()
print("✅ AIMBOT PRO v3 ЗАВАНТАЖЕНО!")
