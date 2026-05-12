-- Blox Fruits BIG SURVIVAL MENU by Colin v3 - Extended Edition
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ColinBigSurvivalMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 520)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 18)
UICorner.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25,25,45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8,8,18))
}
UIGradient.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 70)
Title.BackgroundTransparency = 0.2
Title.BackgroundColor3 = Color3.fromRGB(0, 180, 140)
Title.Text = "COLIN BIG SURVIVAL MENU v3"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = MainFrame

-- Auto Farm
local AutoFarmToggle = Instance.new("TextButton")
AutoFarmToggle.Size = UDim2.new(0.9, 0, 0, 50)
AutoFarmToggle.Position = UDim2.new(0.05, 0, 0, 90)
AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
AutoFarmToggle.Text = "AUTO FARM (LEVELS): OFF"
AutoFarmToggle.TextColor3 = Color3.new(1,1,1)
AutoFarmToggle.TextScaled = true
AutoFarmToggle.Font = Enum.Font.GothamBold
AutoFarmToggle.Parent = MainFrame

local farming = false
AutoFarmToggle.MouseButton1Click:Connect(function()
    farming = not farming
    AutoFarmToggle.Text = "AUTO FARM (LEVELS): " .. (farming and "ON" or "OFF")
end)

spawn(function()
    while wait(0.35) do
        if farming and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    local root = LocalPlayer.Character.HumanoidRootPart
                    root.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, -3.8, 0)
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    else
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
                        game:GetService("VirtualUser"):Button1Up(Vector2.new(0,0))
                    end
                    wait(0.2)
                end
            end
        end
    end
end)

-- ESP Fruits
local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(0.9, 0, 0, 50)
ESPToggle.Position = UDim2.new(0.05, 0, 0, 150)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
ESPToggle.Text = "ESP ON FRUITS: OFF"
ESPToggle.TextColor3 = Color3.new(1,1,1)
ESPToggle.TextScaled = true
ESPToggle.Font = Enum.Font.GothamBold
ESPToggle.Parent = MainFrame

local highlights = {}
ESPToggle.MouseButton1Click:Connect(function()
    local on = ESPToggle.Text:find("ON")
    ESPToggle.Text = "ESP ON FRUITS: " .. (on and "OFF" or "ON")
    if not on then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name:find("Fruit") or obj.Name:lower():find("apple") or obj.Name:lower():find("banana") or obj.Name:lower():find("kiwi") then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(255, 215, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.3
                hl.OutlineTransparency = 0
                hl.Parent = obj
                table.insert(highlights, hl)
            end
        end
    else
        for _, h in ipairs(highlights) do h:Destroy() end
        highlights = {}
    end
end)

-- Auto Quest
local QuestToggle = Instance.new("TextButton")
QuestToggle.Size = UDim2.new(0.9, 0, 0, 50)
QuestToggle.Position = UDim2.new(0.05, 0, 0, 210)
QuestToggle.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
QuestToggle.Text = "AUTO QUEST: OFF"
QuestToggle.TextColor3 = Color3.new(1,1,1)
QuestToggle.TextScaled = true
QuestToggle.Font = Enum.Font.GothamBold
QuestToggle.Parent = MainFrame

local questing = false
QuestToggle.MouseButton1Click:Connect(function()
    questing = not questing
    QuestToggle.Text = "AUTO QUEST: " .. (questing and "ON" or "OFF")
end)

spawn(function()
    while wait(5) do
        if questing then
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CompleteQuest")
            end)
        end
    end
end)

-- WalkSpeed
local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Size = UDim2.new(0.9, 0, 0, 50)
SpeedToggle.Position = UDim2.new(0.05, 0, 0, 270)
SpeedToggle.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
SpeedToggle.Text = "WALKSPEED BOOST: OFF"
SpeedToggle.TextColor3 = Color3.new(1,1,1)
SpeedToggle.TextScaled = true
SpeedToggle.Font = Enum.Font.GothamBold
SpeedToggle.Parent = MainFrame

local speedBoost = false
SpeedToggle.MouseButton1Click:Connect(function()
    speedBoost = not speedBoost
    SpeedToggle.Text = "WALKSPEED BOOST: " .. (speedBoost and "ON" or "OFF")
end)

spawn(function()
    while wait(0.1) do
        if speedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 85
        elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

-- Infinite Jump
local JumpToggle = Instance.new("TextButton")
JumpToggle.Size = UDim2.new(0.9, 0, 0, 50)
JumpToggle.Position = UDim2.new(0.05, 0, 0, 330)
JumpToggle.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
JumpToggle.Text = "INFINITE JUMP: OFF"
JumpToggle.TextColor3 = Color3.new(1,1,1)
JumpToggle.TextScaled = true
JumpToggle.Font = Enum.Font.GothamBold
JumpToggle.Parent = MainFrame

local infJump = false
JumpToggle.MouseButton1Click:Connect(function()
    infJump = not infJump
    JumpToggle.Text = "INFINITE JUMP: " .. (infJump and "ON" or "OFF")
end)

UserInputService.JumpRequest:Connect(function()
    if infJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- F4 Toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("BIG Blox Fruits Survival Menu v3 LOADED - Colin")
