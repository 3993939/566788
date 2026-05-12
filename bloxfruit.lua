-- Blox Fruits ULTIMATE SURVIVAL MENU v4 - Colin Full Edition
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ColinUltimateMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 680)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -340)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 70)
Title.BackgroundColor3 = Color3.fromRGB(200, 50, 80)
Title.BackgroundTransparency = 0.2
Title.Text = "COLIN ULTIMATE MENU v4"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = MainFrame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -90)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 80)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 900)
ScrollingFrame.Parent = MainFrame

local function MakeButton(text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 50)
    btn.Position = UDim2.new(0.025, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = ScrollingFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function MakeToggle(text, y, defaultValue, onToggle)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 50)
    btn.Position = UDim2.new(0.025, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = ScrollingFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = btn
    local state = defaultValue
    btn.Text = text .. ": OFF"
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        onToggle(state)
    end)
    return btn
end

-- STATS
local farming = false
local questing = false
local speedBoost = false
local infJump = false
local espFruits = false
local espChests = false
local autoRaid = false
local autoStats = false
local oneHit = false
local autoFruitSniper = false
local autoElite = false
local autoSeaBeast = false
local noClip = false
local flyMode = false
local autoBuyBelly = false

-- Fruit ESP
local highlights = {}
local chestHighlights = {}

-- Auto Farm
MakeToggle("AUTO FARM (LEVELS)", 10, false, function(val) farming = val end)

spawn(function()
    while wait(0.3) do
        if farming and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, -3, 0)
                        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() else VirtualUser:Button1Down(Vector2.new(0,0)) end
                        wait(0.15)
                    end
                end
            end)
        end
    end
end)

-- Auto Quest
MakeToggle("AUTO QUEST", 70, false, function(val) questing = val end)

spawn(function()
    while wait(4) do
        if questing then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                wait(0.5)
                ReplicatedStorage.Remotes.CommF_:InvokeServer("CompleteQuest")
            end)
        end
    end
end)

-- WalkSpeed
MakeToggle("WALKSPEED BOOST (85)", 130, false, function(val) speedBoost = val end)

spawn(function()
    while wait(0.1) do
        if speedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 85
        elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and not speedBoost then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

-- Infinite Jump
MakeToggle("INFINITE JUMP", 190, false, function(val) infJump = val end)

UserInputService.JumpRequest:Connect(function()
    if infJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- ESP Fruits
MakeToggle("ESP FRUITS", 250, false, function(val)
    espFruits = val
    if espFruits then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("fruit") or obj.Name:lower():find("apple") or obj.Name:lower():find("banana") or obj.Name:lower():find("dragon") then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(255, 200, 0)
                hl.OutlineColor = Color3.new(1,1,1)
                hl.Parent = obj
                table.insert(highlights, hl)
            end
        end
    else
        for _, h in ipairs(highlights) do h:Destroy() end
        highlights = {}
    end
end)

-- ESP Chests
MakeToggle("ESP CHESTS", 310, false, function(val)
    espChests = val
    if espChests then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("chest") or obj.Name:lower():find("barrel") then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(0, 200, 255)
                hl.Parent = obj
                table.insert(chestHighlights, hl)
            end
        end
    else
        for _, h in ipairs(chestHighlights) do h:Destroy() end
        chestHighlights = {}
    end
end)

-- Auto Raid
MakeToggle("AUTO RAID", 370, false, function(val) autoRaid = val end)

spawn(function()
    while wait(10) do
        if autoRaid then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Raids", "Start")
            end)
        end
    end
end)

-- Auto Stats (melee/defense)
MakeToggle("AUTO STATS (STR/DEF)", 430, false, function(val) autoStats = val end)

spawn(function()
    while wait(2) do
        if autoStats then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Melee")
                ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", "Defense")
            end)
        end
    end
end)

-- One Hit Kill
MakeToggle("ONE HIT KILL (бета)", 490, false, function(val) oneHit = val end)

spawn(function()
    while wait(0.2) do
        if oneHit and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        enemy.Humanoid.Health = 0
                    end
                end
            end)
        end
    end
end)

-- Auto Fruit Sniper
MakeToggle("AUTO FRUIT SNIPER", 550, false, function(val) autoFruitSniper = val end)

spawn(function()
    while wait(1) do
        if autoFruitSniper then
            pcall(function()
                local fruit = nil
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name:lower():find("fruit") then
                        fruit = obj
                        break
                    end
                end
                if fruit and LocalPlayer.Character then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = fruit.Parent.Parent.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end)

-- Auto Elite Hunter
MakeToggle("AUTO ELITE HUNTER", 610, false, function(val) autoElite = val end)

spawn(function()
    while wait(30) do
        if autoElite then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter")
            end)
        end
    end
end)

-- Auto Sea Beast
MakeToggle("AUTO SEA BEAST", 670, false, function(val) autoSeaBeast = val end)

-- No Clip / Wall Hack
MakeToggle("NO CLIP (легкий)", 730, false, function(val) noClip = val end)

spawn(function()
    while wait(0.2) do
        if noClip and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CanCollide = false
            wait(0.3)
            LocalPlayer.Character.HumanoidRootPart.CanCollide = true
        end
    end
end)

-- Fly Mode
MakeToggle("FLY MODE", 790, false, function(val) flyMode = val end)

local flying = false
UserInputService.Thumbstick1:Connect(function()
    if flyMode then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            flying = not flying
            if flying then
                char.Humanoid.PlatformStand = true
                local bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(1,1,1)*100000
                bodyVel.Parent = hrp
                while flying and flyMode do
                    bodyVel.Velocity = (Camera.CFrame.LookVector *50) + Vector3.new(0,20,0)
                    wait(0.05)
                end
                bodyVel:Destroy()
                char.Humanoid.PlatformStand = false
            end
        end
    end
end)

-- Auto Buy Beli Farm (фейк, але якщо є remote)
MakeButton("AUTO BUY BELI (фарм)", 850, function()
    pcall(function()
        for i=1,10 do
            ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "PirateRum", 1)
            wait(0.3)
        end
    end)
end)

-- Teleport to NPC
MakeButton("TELEPORT TO QUEST NPC", 910, function()
    pcall(function()
        local npc = Workspace.NPCs:FindFirstChild("QuestGiver") or Workspace:FindFirstChild("BanditQuestGiver")
        if npc and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, -2, 2)
        end
    end)
end)

-- Close Menu button
MakeButton("ЗАКРИТИ МЕНЮ", 970, function()
    ScreenGui.Enabled = false
end)

-- F4 toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("COLIN ULTIMATE MENU v4 LOADED - Blox Fruits Full Survival")
