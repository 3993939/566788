--[ Блокс Фрутс - Повний виживальний скрипт (Colin Survival) ]--
local p = game.Players.LocalPlayer
local chr = p.Character or p.CharacterAdded:wait()
local rs = game:GetService("ReplicatedStorage")
local vu = game:GetService("VirtualUser")
local uis = game:GetService("UserInputService")

-- GUI
local scr = Instance.new("ScreenGui")
scr.Name = "ColinSurvival"
scr.ResetOnSpawn = false
scr.Parent = p.PlayerGui

local frm = Instance.new("Frame")
frm.Size = UDim2.new(0, 400, 0, 500)
frm.Pos = UDim2.new(0.5, -200, 0.5, -250)
frm.BackColor3 = Color3.fromRGB(20,20,35)
frm.Parent = scr
Instance.new("UICorner").CornerRadius = UDim.new(0,15)
Instance.new("UICorner").Parent = frm

local lst = Instance.new("ScrollingFrame")
lst.Size = UDim2.new(1,-20,1,-50)
lst.Pos = UDim2.new(0,10,0,45)
lst.BackTransparency = 1
lst.Parent = frm

local function btn(txt, y, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.95,0,0,45)
    b.Pos = UDim2.new(0.025,0,0,y)
    b.Text = txt
    b.BackColor3 = Color3.fromRGB(40,40,65)
    b.TextColor3 = Color3.new(1,1,1)
    b.Parent = lst
    Instance.new("UICorner").CornerRadius = UDim.new(0,10)
    Instance.new("UICorner").Parent = b
    b.MouseButton1Click:Connect(cb)
    return b
end

local function tgl(txt, y, def, cb)
    local b = btn(txt .. ": OFF", y, nil)
    local state = def
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = txt .. ": " .. (state and "ON✔️" or "OFF❌")
        cb(state)
    end)
    return b
end

-- стани
local farm, quest, speed, jump, esp, ohk, fly, noc = false, false, false, false, false, false, false, false
local spdVal = 85
local spdNorm = 16

-- Auto Farm
tgl("⚔️ AUTO FARM", 10, false, function(s) farm = s end)
spawn(function()
    while wait(0.25) do
        if farm and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            for _,e in pairs(workspace.Enemies:GetChildren()) do
                if e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 then
                    p.Character.HumanoidRootPart.CFrame = e.HumanoidRootPart.CFrame * CFrame.new(0,-3,0)
                    local t = p.Character:FindFirstChildWhichIsA("Tool")
                    if t then t:Activate() else vu:Button1Down(Vector2.new(0,0)) end
                    wait(0.1)
                end
            end
        end
    end
end)

-- Auto Quest
tgl("📜 AUTO QUEST", 65, false, function(s) quest = s end)
spawn(function()
    while wait(3) do
        if quest then
            pcall(function()
                rs.Remotes.CommF_:InvokeServer("StartQuest","BanditQuest1",1)
                wait(0.4)
                rs.Remotes.CommF_:InvokeServer("CompleteQuest")
            end)
        end
    end
end)

-- Speed
tgl("🏃 SPEED ("..spdVal..")", 120, false, function(s) speed = s end)
spawn(function()
    while wait(0.1) do
        if p.Character and p.Character:FindFirstChild("Humanoid") then
            p.Character.Humanoid.WalkSpeed = speed and spdVal or spdNorm
        end
    end
end)

-- Infinite Jump
tgl("🦘 INFINITE JUMP", 175, false, function(s) jump = s end)
uis.JumpRequest:Connect(function()
    if jump and p.Character then p.Character.Humanoid:ChangeState("Jumping") end
end)

-- ESP Fruit
tgl("🍎 ESP FRUIT", 230, false, function(s) 
    esp = s
    for _,v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():match("fruit") and esp then
            local h = Instance.new("Highlight")
            h.FillColor = Color3.fromRGB(255,200,0)
            h.Parent = v
            game.Debris:AddItem(h,0.5)
        end
    end
end)

-- One Hit Kill
tgl("💀 ONE HIT KILL", 285, false, function(s) ohk = s end)
spawn(function()
    while wait(0.2) do
        if ohk then
            for _,e in pairs(workspace.Enemies:GetChildren()) do
                if e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 then
                    e.Humanoid.Health = 0
                end
            end
        end
    end
end)

-- Fly
tgl("🕊️ FLY MODE (W)", 340, false, function(s) fly = s end)
local flyBody = nil
game:GetService("RunService").RenderStepped:Connect(function()
    if fly and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        if uis:IsKeyDown(Enum.KeyCode.W) then
            local hrp = p.Character.HumanoidRootPart
            if not flyBody then
                p.Character.Humanoid.PlatformStand = true
                flyBody = Instance.new("BodyVelocity")
                flyBody.MaxForce = Vector3.new(1,1,1)*100000
                flyBody.Parent = hrp
            end
            flyBody.Velocity = (workspace.CurrentCamera.CFrame.LookVector * 70) + Vector3.new(0,5,0)
        elseif flyBody then
            flyBody:Destroy()
            flyBody = nil
            p.Character.Humanoid.PlatformStand = false
        end
    elseif flyBody then
        flyBody:Destroy()
        flyBody = nil
        if p.Character then p.Character.Humanoid.PlatformStand = false end
    end
end)

-- No Clip
tgl("🧱 NO CLIP", 395, false, function(s) noc = s end)
spawn(function()
    while wait(0.15) do
        if noc and p.Character then
            p.Character.HumanoidRootPart.CanCollide = false
            wait(0.2)
            p.Character.HumanoidRootPart.CanCollide = true
        end
    end
end)

-- Teleports
btn("📍 TELEPORT TO NPC", 450, function()
    local npc = workspace:FindFirstChild("BanditQuestGiver") or workspace:FindFirstChild("QuestGiver")
    if npc and p.Character then
        p.Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0,-2,2)
    end
end)

btn("🔴 ЗАКРИТИ", 505, function() scr.Enabled = false end)

-- F4 hide
uis.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.F4 then frm.Visible = not frm.Visible end
end)

print("✅ Colin Survival Script v1 завантажено — Blox Fruits")
