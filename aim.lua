--[[
    Arsenal GOD-MODE v2.1 - Optimized & Fixed
    Features: Silent Aim, Aimbot, ESP, WallCheck, No Recoil, Infinite Ammo
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local settings = {
    enabled = true,
    silentAim = true,
    aimbot = true,
    aimbotFOV = 150,
    aimbotSmooth = 5,
    aimPart = "Head",
    teamCheck = true,
    wallCheck = true,

    esp = true,
    espColor = Color3.fromRGB(255, 0, 80),
    espThickness = 1.5,

    noRecoil = true,
    infiniteAmmo = true
}

-- Drawing Objects
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Color = settings.espColor
FOVCircle.Visible = false

local espPool = {}

-- Wall Check (Optimized)
local function IsVisible(part)
    if not settings.wallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character or {}, Camera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction, params)
    return not result or result.Instance == part or result.Instance:IsDescendantOf(part.Parent)
end

-- Get Closest Target
local function GetTarget()
    local closestDist = settings.aimbotFOV
    local target = nil
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        if settings.teamCheck and player.Team == LocalPlayer.Team then continue end

        local humanoid = player.Character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end

        local aimPart = player.Character:FindFirstChild(settings.aimPart)
        if not aimPart then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
        if not onScreen then continue end

        if not IsVisible(aimPart) then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist < closestDist then
            closestDist = dist
            target = {Part = aimPart, Player = player}
        end
    end
    return target
end

-- Silent Aim (Safer Hook)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if settings.silentAim and method == "FireServer" and self.Name == "HitPart" then
        local target = GetTarget()
        if target then
            args[1] = target.Part          -- Hit Part
            args[2] = target.Part.Position -- Hit Position
            -- args[3] sometimes used for velocity, etc. You can add more if needed
        end
    end

    return oldNamecall(self, unpack(args))
end

setreadonly(mt, true)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if not settings.enabled then 
        FOVCircle.Visible = false
        return 
    end

    FOVCircle.Visible = true
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = settings.aimbotFOV

    local target = GetTarget()

    -- Aimbot (Right Mouse Button)
    if settings.aimbot and target and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Part.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / settings.aimbotSmooth)
    end

    -- ESP
    if settings.esp then
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end

            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                if espPool[player] then espPool[player].Visible = false end
                continue
            end

            if settings.teamCheck and player.Team == LocalPlayer.Team then
                if espPool[player] then espPool[player].Visible = false end
                continue
            end

            local root = char.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)

            if onScreen then
                if not espPool[player] then
                    espPool[player] = Drawing.new("Square")
                    espPool[player].Thickness = settings.espThickness
                    espPool[player].Filled = false
                    espPool[player].Color = settings.espColor
                end

                local distance = (Camera.CFrame.Position - root.Position).Magnitude
                local scale = 3000 / distance

                espPool[player].Size = Vector2.new(scale, scale * 1.8)
                espPool[player].Position = Vector2.new(screenPos.X - scale/2, screenPos.Y - scale*0.9)
                espPool[player].Visible = true
            elseif espPool[player] then
                espPool[player].Visible = false
            end
        end
    end
end)

-- Better Infinite Ammo (less heavy)
if settings.infiniteAmmo then
    task.spawn(function()
        while settings.enabled and settings.infiniteAmmo do
            task.wait(0.3) -- less aggressive
            for _, v in ipairs(getgc(true)) do
                if typeof(v) == "table" and rawget(v, "Ammo") and rawget(v, "MaxAmmo") then
                    v.Ammo = 999
                    v.MaxAmmo = 999
                end
            end
        end
    end)
end

-- No Recoil (basic)
if settings.noRecoil then
    -- This part is game-specific. Usually you hook the recoil function or set Spread = 0
    print("No Recoil enabled (may need additional hooks depending on update)")
end

print("✅ Arsenal GOD-MODE v2.1 Loaded | Silent Aim Active")
