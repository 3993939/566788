-- Порожнє меню від Colin
-- Додавай свої кнопки/тогли куди треба

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local CloseButton = Instance.new("TextButton")
local TabFrame = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")

-- Головний GUI
ScreenGui.Name = "MyMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

Frame.Name = "Main"
Frame.Size = UDim2.new(0, 400, 0, 300)
Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

-- Верхня панель
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TopBar.BorderSizePixel = 0
TopBar.Parent = Frame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Text = "   My Script"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Кнопка закриття
CloseButton.Text = "×"
CloseButton.Size = UDim2.new(0, 26, 0, 26)
CloseButton.Position = UDim2.new(1, -28, 0, 2)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TopBar

-- Вкладки
TabFrame.Name = "Tabs"
TabFrame.Size = UDim2.new(0, 100, 1, -30)
TabFrame.Position = UDim2.new(0, 0, 0, 30)
TabFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TabFrame.BorderSizePixel = 0
TabFrame.Parent = Frame

-- Контент
ContentFrame.Name = "Content"
ContentFrame.Size = UDim2.new(1, -100, 1, -30)
ContentFrame.Position = UDim2.new(0, 100, 0, 30)
ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = Frame

-- Функція створення вкладки
function CreateTab(name)
    local Btn = Instance.new("TextButton")
    Btn.Text = name
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.Position = UDim2.new(0, 0, 0, #TabFrame:GetChildren() * 32)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.BorderSizePixel = 0
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Btn.Parent = TabFrame
    
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.CanvasSize = UDim2.new(0, 0, 0, 400)
    Page.Visible = false
    Page.Parent = ContentFrame
    
    Btn.MouseButton1Click:Connect(function()
        for _, p in ipairs(ContentFrame:GetChildren()) do
            if p:IsA("ScrollingFrame") then p.Visible = false end
        end
        Page.Visible = true
    end)
    
    if #TabFrame:GetChildren() == 2 then Page.Visible = true end
    
    return Page
end

-- Функція створення кнопки
function CreateButton(parent, text, y, callback)
    local Btn = Instance.new("TextButton")
    Btn.Text = text
    Btn.Size = UDim2.new(1, -20, 0, 35)
    Btn.Position = UDim2.new(0, 10, 0, y)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Btn.BorderSizePixel = 0
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Btn.Parent = parent
    
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- Функція створення тоглу
function CreateToggle(parent, text, y, default, callback)
    local Toggle = Instance.new("TextButton")
    Toggle.Text = text .. ": OFF"
    Toggle.Size = UDim2.new(1, -20, 0, 35)
    Toggle.Position = UDim2.new(0, 10, 0, y)
    Toggle.BackgroundColor3 = default and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(140, 0, 0)
    Toggle.BorderSizePixel = 0
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.Font = Enum.Font.Gotham
    Toggle.TextSize = 13
    Toggle.Parent = parent
    
    local state = default
    Toggle.MouseButton1Click:Connect(function()
        state = not state
        Toggle.Text = text .. ": " .. (state and "ON" or "OFF")
        Toggle.BackgroundColor3 = state and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(140, 0, 0)
        callback(state)
    end)
    
    return Toggle
end

-- Закриття меню
local guiVisible = true
CloseButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    Frame.Visible = guiVisible
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        guiVisible = not guiVisible
        Frame.Visible = guiVisible
    end
end)

-- ========== ПРИКЛАД ВИКОРИСТАННЯ ==========
local mainTab = CreateTab("Головна")

CreateButton(mainTab, "Привіт, світ!", 5, function()
    print("Кнопка натиснута!")
end)

CreateToggle(mainTab, "Мій тогл", 45, false, function(state)
    print("Тогл:", state)
end)

-- ========== СЮДИ ВСТАВЛЯЙ СВОЇ ФУНКЦІЇ ==========
-- Просто копіюй рядки з CreateButton/CreateToggle
-- і в callback пиши свій код

print("Empty menu loaded! F4 = hide/show")
