-- Blox Fruits Advanced Menu Script by Colin - Survival Priority
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Beautiful GUI Menu
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ColinSurvivalMenu"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 380)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Title.Text = "COLIN SURVIVAL MENU - Blox Fruits"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 1, -70)
TabFrame.Position = UDim2.new(0, 10, 0, 60)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

-- Auto Farm by Level
local AutoFarmToggle = Instance.new("TextButton")
AutoFarmToggle.Size = UDim2.new(0.9, 0, 0, 50)
AutoFarmToggle.Position = UDim2.new(0.05, 0, 0, 20)
AutoFarmToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
AutoFarmToggle.Text = "AUTO FARM BY LEVEL: OFF"
AutoFarmToggle.TextColor3 = Color3.new(1,1,1)
AutoFarmToggle.Parent = TabFrame

local farming = false
AutoFarmToggle.MouseButton1Click:Connect(function()
    farming = not farming
    AutoFarmToggle.Text = "AUTO FARM BY LEVEL: " .. (farming and "ON" or "OFF")
end)

spawn(function()
    while wait(0.8) do
        if farming then
            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    local playerLevel = LocalPlayer.Data.Level.Value
                    local enemyLevel = tonumber(enemy.Name:match("%d+")) or 0
                    if math.abs(playerLevel - enemyLevel) <= 15 then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, -3, 0)
                        game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
                        wait(0.15)
                        game:GetService("VirtualUser"):Button1Up(Vector2.new(0,0))
                    end
                end
            end
        end
    end
end)

-- ESP on Fruits
local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(0.9, 0, 0, 50)
ESPToggle.Position = UDim2.new(0.05, 0, 0, 90)
ESPToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
ESPToggle.Text = "ESP ON FRUITS: OFF"
ESPToggle.TextColor3 = Color3.new(1,1,1)
ESPToggle.Parent = TabFrame

local fruitESP = {}
ESPToggle.MouseButton1Click:Connect(function()
    local enabled = ESPToggle.Text:find("ON")
    ESPToggle.Text = "ESP ON FRUITS: " .. (enabled and "OFF" or "ON")
    
    if not enabled then
        for _, fruit in pairs(Workspace:GetChildren()) do
            if fruit.Name:find("Fruit") or fruit:FindFirstChild("Fruit") then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(0, 255, 100)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Parent = fruit
                table.insert(fruitESP, highlight)
            end
        end
    else
        for _, h in pairs(fruitESP) do h:Destroy() end
        fruitESP = {}
    end
end)

print("Beautiful Blox Fruits Menu + Auto Farm + Fruit ESP Loaded - Colin")
