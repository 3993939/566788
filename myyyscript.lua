-- Roblox UI Framework (F4 Toggle, Tabs, Buttons, Toggles, Sliders)
-- Clean modular style

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local Settings = {
    MenuVisible = true,
    Theme = {
        Main = Color3.fromRGB(30,30,30),
        Top = Color3.fromRGB(45,45,45),
        Side = Color3.fromRGB(35,35,35),
        Accent = Color3.fromRGB(0,170,255),
        Text = Color3.fromRGB(255,255,255)
    }
}

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FrameworkUI"
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = game.CoreGui
end)

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 500, 0, 350)
Main.Position = UDim2.new(0.5, -250, 0.5, -175)
Main.BackgroundColor3 = Settings.Theme.Main
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- TOPBAR
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1,0,0,35)
TopBar.BackgroundColor3 = Settings.Theme.Top
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Professional Menu Framework"
Title.TextColor3 = Settings.Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,30,0,30)
Close.Position = UDim2.new(1,-35,0,2)
Close.Text = "×"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 18
Close.TextColor3 = Settings.Theme.Text
Close.BackgroundColor3 = Color3.fromRGB(200,50,50)
Close.BorderSizePixel = 0
Close.Parent = TopBar
Instance.new("UICorner", Close).CornerRadius = UDim.new(0,6)

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,130,1,-35)
Sidebar.Position = UDim2.new(0,0,0,35)
Sidebar.BackgroundColor3 = Settings.Theme.Side
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

-- CONTENT
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-130,1,-35)
Content.Position = UDim2.new(0,130,0,35)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Tabs = {}
local CurrentTab = nil
local TabCount = 0

-- UTILITIES
local function Tween(obj, props)
    TweenService:Create(obj, TweenInfo.new(0.2), props):Play()
end

local function CreateTab(name)
    TabCount += 1

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,-10,0,35)
    Button.Position = UDim2.new(0,5,0,(TabCount-1)*40 + 5)
    Button.BackgroundColor3 = Settings.Theme.Top
    Button.Text = name
    Button.TextColor3 = Settings.Theme.Text
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.BorderSizePixel = 0
    Button.Parent = Sidebar
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0,6)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1,0,1,0)
    Page.CanvasSize = UDim2.new(0,0,0,600)
    Page.ScrollBarThickness = 4
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = Content

    if not CurrentTab then
        CurrentTab = Page
        Page.Visible = true
    end

    Button.MouseButton1Click:Connect(function()
        if CurrentTab then
            CurrentTab.Visible = false
        end
        CurrentTab = Page
        Page.Visible = true
    end)

    Tabs[name] = Page
    return Page
end

local function CreateButton(parent, text, posY, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1,-20,0,40)
    Btn.Position = UDim2.new(0,10,0,posY)
    Btn.BackgroundColor3 = Settings.Theme.Top
    Btn.Text = text
    Btn.TextColor3 = Settings.Theme.Text
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.BorderSizePixel = 0
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)

    Btn.MouseButton1Click:Connect(callback)

    Btn.MouseEnter:Connect(function()
        Tween(Btn, {BackgroundColor3 = Settings.Theme.Accent})
    end)

    Btn.MouseLeave:Connect(function()
        Tween(Btn, {BackgroundColor3 = Settings.Theme.Top})
    end)
end

local function CreateToggle(parent, text, posY, default, callback)
    local state = default

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(1,-20,0,40)
    Toggle.Position = UDim2.new(0,10,0,posY)
    Toggle.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    Toggle.Text = text .. ": " .. (state and "ON" or "OFF")
    Toggle.TextColor3 = Settings.Theme.Text
    Toggle.Font = Enum.Font.Gotham
    Toggle.TextSize = 14
    Toggle.BorderSizePixel = 0
    Toggle.Parent = parent
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,6)

    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Toggle.Text = text .. ": " .. (state and "ON" or "OFF")
        Toggle.BackgroundColor3 = state and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        callback(state)
    end)
end

-- EXAMPLE TABS
local MainTab = CreateTab("Main")
local SettingsTab = CreateTab("Settings")

CreateButton(MainTab, "Example Button", 10, function()
    print("Button clicked!")
end)

CreateToggle(MainTab, "Example Toggle", 60, false, function(state)
    print("Toggle:", state)
end)

CreateButton(SettingsTab, "Change Theme Accent", 10, function()
    Settings.Theme.Accent = Color3.fromRGB(
        math.random(0,255),
        math.random(0,255),
        math.random(0,255)
    )
end)

-- CLOSE BUTTON
Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    Settings.MenuVisible = false
end)

-- F4 TOGGLE
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.F4 then
        Settings.MenuVisible = not Settings.MenuVisible
        Main.Visible = Settings.MenuVisible
    end
end)

print("Framework Loaded Successfully!")
