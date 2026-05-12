--[ Colin Survival V2 - Modern UI Edition ]--
local p = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local rs = game:GetService("ReplicatedStorage")
local vu = game:GetService("VirtualUser")

-- Створення GUI
local ColinGui = Instance.new("ScreenGui")
ColinGui.Name = "ColinV2"
ColinGui.ResetOnSpawn = false
ColinGui.Parent = p:WaitForChild("PlayerGui")

-- Основне вікно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ColinGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

-- Тінь/Світіння
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(80, 100, 250)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.5

-- Бічна панель (Sidebar)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Sidebar.Parent = MainFrame
local SideCorner = Instance.new("UICorner", Sidebar)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "COLIN V2"
Title.TextColor3 = Color3.fromRGB(80, 150, 250)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BackgroundTransparency = 1
Title.Parent = Sidebar

-- Контейнер для кнопок (Scrolling)
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -150, 1, -20)
Content.Position = UDim2.new(0, 150, 0, 10)
Content.BackgroundTransparency = 1
Content.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Content.ScrollBarThickness = 2
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout", Content)
Layout.Padding = UDim.new(0, 8)

-- Функція створення перемикача (Modern Toggle)
local function CreateToggle(name, default, callback)
    local state = default
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0.95, 0, 0, 40)
    ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(30, 60, 40) or Color3.fromRGB(30, 30, 40)
    ToggleBtn.Text = "  " .. name .. (state and " [ON]" or " [OFF]")
    ToggleBtn.TextColor3 = state and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(200, 200, 200)
    ToggleBtn.Font = Enum.Font.GothamMedium
    ToggleBtn.TextSize = 14
    ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
    ToggleBtn.Parent = Content
    
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
    
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        ts:Create(ToggleBtn, TweenInfo.new(0.3), {
            BackgroundColor3 = state and Color3.fromRGB(30, 60, 40) or Color3.fromRGB(30, 30, 40),
            TextColor3 = state and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(200, 200, 200)
        }):Play()
        ToggleBtn.Text = "  " .. name .. (state and " [ON]" or " [OFF]")
        callback(state)
    end)
end

-- Перетягування (Drag System)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
uis.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
uis.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

--- [ ЛОГІКА СКРИПТА ] ---

local flags = { farm = false, quest = false, speed = false, jump = false, esp = false, ohk = false }

CreateToggle("Auto Farm Level", false, function(v) flags.farm = v end)
CreateToggle("Auto Quest", false, function(v) flags.quest = v end)
CreateToggle("Super Speed", false, function(v) flags.speed = v end)
CreateToggle("Infinite Jump", false, function(v) flags.jump = v end)
CreateToggle("Fruit ESP", false, function(v) flags.esp = v end)
CreateToggle("One Hit Kill", false, function(v) flags.ohk = v end)

-- Цикл фарму
spawn(function()
    while task.wait(0.2) do
        if flags.farm then
            pcall(function()
                for _, e in pairs(workspace.Enemies:GetChildren()) do
                    if e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 then
                        p.Character.HumanoidRootPart.CFrame = e.HumanoidRootPart.CFrame * CFrame.new(0, -5, 0)
                        vu:Button1Down(Vector2.new(0,0))
                    end
                end
            end)
        end
    end
end)

-- Швидкість
spawn(function()
    while task.wait(0.5) do
        if flags.speed and p.Character:FindFirstChild("Humanoid") then
            p.Character.Humanoid.WalkSpeed = 100
        elseif p.Character:FindFirstChild("Humanoid") then
            p.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

-- Кнопка закриття
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, -20, 0, 35)
CloseBtn.Position = UDim2.new(0, 10, 1, -45)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
CloseBtn.Text = "CLOSE MENU"
CloseBtn.TextColor3 = Color3.new(1, 0.4, 0.4)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Sidebar
Instance.new("UICorner", CloseBtn)
CloseBtn.MouseButton1Click:Connect(function() ColinGui:Destroy() end)

-- Гаряча клавіша F4 для приховування
uis.InputBegan:Connect(function(i, gpe)
    if not gpe and i.KeyCode == Enum.KeyCode.F4 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("Colin V2 loaded! Press F4 to toggle.")
