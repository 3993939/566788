--[[
    AIMBOT PRO v3 (UPDATED)
    - Перемикання меню: RightShift або Клік на круглу іконку з черепом
    - Аімбот: Наведення при затиснутій ПКМ (Right Mouse Button)
    - Покращена плавність наведення
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ЗАВАНТАЖЕННЯ БІБЛІОТЕКИ ORION
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
    ShowFOV = true,
    AimKey = Enum.UserInputType.MouseButton2, -- Аім на ПКМ
    IsAiming = false
}

-- СТВОРЕННЯ КРУГЛОЇ ІКОНКИ З ЧЕРЕПОМ НА ЕКРАНІ
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotToggleGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local SkullButton = Instance.new("ImageButton")
SkullButton.Name = "SkullToggle"
SkullButton.Size = UDim2.new(0, 50, 0, 50)
SkullButton.Position = UDim2.new(0, 15, 0.5, -25)
SkullButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
SkullButton.BackgroundTransparency = 0.2
SkullButton.Image = "rbxassetid://10723380252" -- Іконка черепа
SkullButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
SkullButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0) -- Робимо повністю круглою
UICorner.Parent = SkullButton

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 0)
UIStroke.Thickness = 2
UIStroke.Parent = SkullButton

-- ЛОГІКА ВІДКРИТТЯ/ЗАКРИТТЯ GUI
local MenuOpen = true
local function ToggleMenu()
    MenuOpen = not MenuOpen
    local mainFrame = game:GetService("CoreGui"):FindFirstChild("Orion")
    if mainFrame then
        mainFrame.Enabled = MenuOpen
    end
end

-- Відкриття по кліку на іконку
SkullButton.MouseButton1Click:Connect(function()
    ToggleMenu()
end)

-- Відкриття по кнопці RightShift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        ToggleMenu()
    end
end)

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
    Name = "🟢 Увімкнути Аім (Затисни ПКМ)",
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
    Name = "🎯 Плавність (чим більше — тим плавніше)",
    Min = 0.01,
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

-- ЗЧИТУВАННЯ ЗАТИСКАННЯ ПКМ
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Settings.AimKey then
        Settings.IsAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Settings.AimKey then
        Settings.IsAiming = false
    end
end)

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

-- ОСНОВНИЙ ЦИКЛ ОНОВЛЕННЯ ТА ПЛАВНОГО НАВЕДЕННЯ
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Працює тільки якщо функція увімкнена ТА затиснуто ПКМ
    if not Settings.Enabled or not Settings.IsAiming then return end

    local targetPart = GetClosestTarget()
    
    if targetPart then
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        
        -- Плавне згладжування камери
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Settings.Smoothness)
    end
end)

OrionLib:Init()
print("✅ AIMBOT PRO v3 ЗАВАНТАЖЕНО! Натисніть RightShift або Іконку для відкриття меню.")
