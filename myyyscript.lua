--[[
    PURE CLEAN GLASS UI (NO TEXT)
    - Відкриття / Закриття: [RightShift]
    - Кольори: Напівпрозорий білий / сірий
    - Жодного тексту чи написів
]]

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- ЗНИЩЕННЯ СТАРОГО GUI, ЯКЩО ВОНО ІСНУЄ
if CoreGui:FindFirstChild("PureCleanUI_Container") then
    CoreGui.PureCleanUI_Container:Destroy()
end

-- СТВОРЕННЯ КОНТЕЙНЕРА
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PureCleanUI_Container"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- ОСНОВНЕ БІЛО-СІРЕ СКЛЯНЕ ВІКНО
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainGlassFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 220)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(235, 238, 242) -- Світло-сірий / білий
MainFrame.BackgroundTransparency = 0.65 -- Чисте напівпрозоре скло
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

-- ЗАКРУГЛЕННЯ КУТІВ
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = MainFrame

-- МАКСИМАЛЬНО АКУРАТНА БІЛА ОБВОДКА
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

-- ВНУТРІШНІЙ СІРИЙ АКТЕНТНИЙ БЛОК (БЕЗ ТЕКСТУ)
local InnerFrame = Instance.new("Frame")
InnerFrame.Name = "InnerAccent"
InnerFrame.Size = UDim2.new(1, -30, 1, -30)
InnerFrame.Position = UDim2.new(0, 15, 0, 15)
InnerFrame.BackgroundColor3 = Color3.fromRGB(180, 185, 195)
InnerFrame.BackgroundTransparency = 0.8
InnerFrame.Parent = MainFrame

local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, 14)
InnerCorner.Parent = InnerFrame

-- ЛОГІКА ВІДКРИТТЯ / ЗАКРИТТЯ НА RIGHT SHIFT
local IsOpen = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        IsOpen = not IsOpen
        MainFrame.Visible = IsOpen
    end
end)
