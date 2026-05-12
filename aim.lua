--[[
    Arsenal GOD-MODE v2 - Colin Edition (Extreme Optimization)
    Додано: Silent Aim, Drawing ESP, Optimized WallCheck, Auto-Ammo Fix.
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local settings = {
    enabled = true,
    silentAim = true, -- Кулі летять в ціль самі
    aimbot = true,    -- Плавна доводка камери
    aimbotFOV = 150,
    aimbotSmooth = 4,
    aimPart = "Head",
    teamCheck = true,
    wallCheck = true,
    
    -- ESP Налаштування
    esp = true,
    espColor = Color3.fromRGB(255, 0, 80),
    
    -- Модифікації зброї
    noRecoil = true,
    infiniteAmmo = true
}

-- Пул для ESP об'єктів (щоб не створювати нові щосекунди)
local espPool = {}

-- Малювання FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Radius = settings.aimbotFOV
FOVCircle.Filled = false
FOVCircle.Color = settings.espColor
FOVCircle.Visible = true

-- Функція перевірки перешкод (Wall Check)
local function IsVisible(part)
    if not settings.wallCheck then return true end
    local castPoints = {Camera.CFrame.Position, part.Position}
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(castPoints[1], castPoints[2] - castPoints[1], params)
    return not result
end

-- Покращений пошук найближчої цілі
local function GetTarget()
    local closestDist = settings.aimbotFOV
    local target = nil
    local mouseLoc = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            if settings.teamCheck and player.Team == LocalPlayer.Team then continue end
            if player.Character.Humanoid.Health <= 0 then continue end
            
            local part = player.Character:FindFirstChild(settings.aimPart)
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and IsVisible(part) then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mouseLoc).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        target = {Part = part, Player = player, Pos = screenPos}
                    end
                end
            end
        end
    end
    return target
end

-- --- SILENT AIM (Хукаємо відправку пострілів) ---
local oldNamecall
oldNamecall = hookmetatable(game, {
    __namecall = function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if settings.silentAim and method == "FireServer" and self.Name == "HitPart" then
            local target = GetTarget()
            if target then
                args[1] = target.Part -- Замінюємо частину, в яку влучили, на голову цілі
                args[2] = target.Part.Position -- Замінюємо позицію влучання
            end
        end
        return oldNamecall(self, unpack(args))
    end
})

-- --- ГРАФІКА ТА ЛОГІКА ---
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = settings.aimbotFOV
    
    local targetData = GetTarget()
    
    -- Плавний Aimbot (якщо натиснута ПКМ)
    if settings.aimbot and targetData and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local lookAt = CFrame.new(Camera.CFrame.Position, targetData.Part.Position)
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, 1 / settings.aimbotSmooth)
    end
    
    -- Оптимізований ESP
    if settings.esp then
        for _, player in pairs(Players:GetPlayers()) do
            local char = player.Character
            if char and player ~= LocalPlayer and player.Character:FindFirstChild("HumanoidRootPart") then
                if settings.teamCheck and player.Team == LocalPlayer.Team then 
                    if espPool[player] then espPool[player].Visible = false end
                    continue 
                end
                
                local hrp = char.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    if not espPool[player] then
                        espPool[player] = Drawing.new("Square")
                        espPool[player].Thickness = 1
                        espPool[player].Filled = false
                    end
                    
                    local sizeX = 1000 / screenPos.Z
                    local sizeY = 1500 / screenPos.Z
                    
                    espPool[player].Size = Vector2.new(sizeX, sizeY)
                    espPool[player].Position = Vector2.new(screenPos.X - sizeX/2, screenPos.Y - sizeY/2)
                    espPool[player].Color = settings.espColor
                    espPool[player].Visible = true
                elseif espPool[player] then
                    espPool[player].Visible = false
                end
            elseif espPool[player] then
                espPool[player].Visible = false
            end
        end
    end
end)

-- --- ОПТИМІЗОВАНИЙ INFINITE AMMO (через Garbage Collector) ---
task.spawn(function()
    while task.wait(1) do
        if settings.enabled and settings.infiniteAmmo then
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" and rawget(v, "Ammo") and rawget(v, "MaxAmmo") then
                    v.Ammo = 999
                end
            end
        end
    end
end)

print("Arsenal GOD-MODE v2 Loaded. Silent Aim: Active.")
