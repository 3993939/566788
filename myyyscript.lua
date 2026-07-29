--[[
    Серверний адмін-скрипт з GUI (Glassmorphism)
    Функції: Aimbot, ESP, Fly, Speed, NoClip
    Тип: Script (не LocalScript)
    Місце: ServerScriptService
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ==================== СТВОРЕННЯ REMOTE EVENT ====================
local RemoteEvent = Instance.new("RemoteEvent")
RemoteEvent.Name = "AdminCommands"
RemoteEvent.Parent = ReplicatedStorage

-- ==================== НАЛАШТУВАННЯ ГРАВЦІВ ====================
local playerSettings = {} -- {[player] = {esp=false, aimbot=false, fly=false, speed=16, noclip=false, fov=150}}

-- ==================== GUI СТВОРЕННЯ (ДЛЯ КОЖНОГО ГРАВЦЯ) ====================
local function createGUI(player)
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Очищаємо старі GUI
	for _, v in ipairs(playerGui:GetChildren()) do
		if v.Name == "AdminGlass" then
			v:Destroy()
		end
	end
	
	-- ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AdminGlass"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	
	-- Головний контейнер
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 320, 0, 420)
	mainFrame.Position = UDim2.new(1, -340, 0.5, -210)
	mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	mainFrame.BackgroundTransparency = 0.85
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.Draggable = true
	mainFrame.Parent = screenGui
	
	-- Скруглення
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = mainFrame
	
	-- Тінь
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Size = UDim2.new(1, 30, 1, 30)
	shadow.Position = UDim2.new(0, -15, 0, -15)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://6015897843"
	shadow.ImageTransparency = 0.6
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 49, 49)
	shadow.Parent = mainFrame
	
	-- Рамка скла
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.4
	stroke.Parent = mainFrame
	
	-- Заголовок
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 50)
	titleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	titleBar.BackgroundTransparency = 0.7
	titleBar.BorderSizePixel = 0
	titleBar.Parent = mainFrame
	
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 16)
	titleCorner.Parent = titleBar
	
	local titleStroke = Instance.new("UIStroke")
	titleStroke.Thickness = 0.8
	titleStroke.Color = Color3.fromRGB(255, 255, 255)
	titleStroke.Transparency = 0.3
	titleStroke.Parent = titleBar
	
	local titleText = Instance.new("TextLabel")
	titleText.Size = UDim2.new(0.8, 0, 1, 0)
	titleText.Position = UDim2.new(0.05, 0, 0, 0)
	titleText.BackgroundTransparency = 1
	titleText.Text = "🔮 GLASS ADMIN"
	titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleText.TextSize = 20
	titleText.Font = Enum.Font.GothamBold
	titleText.TextXAlignment = Enum.TextXAlignment.Left
	titleText.Parent = titleBar
	
	-- Кнопка закриття
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -40, 0, 10)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
	closeButton.BackgroundTransparency = 0.3
	closeButton.Text = "✕"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 18
	closeButton.Font = Enum.Font.GothamBold
	closeButton.BorderSizePixel = 0
	closeButton.Parent = titleBar
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton
	
	closeButton.MouseButton1Click:Connect(function()
		mainFrame.Visible = false
	end)
	
	-- Скрол-фрейм для контенту
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "ScrollFrame"
	scrollFrame.Size = UDim2.new(1, -10, 1, -60)
	scrollFrame.Position = UDim2.new(0, 5, 0, 55)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 4
	scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
	scrollFrame.ScrollBarImageTransparency = 0.5
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 750)
	scrollFrame.Parent = mainFrame
	
	local uiList = Instance.new("UIListLayout")
	uiList.Padding = UDim.new(0, 8)
	uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiList.Parent = scrollFrame
	
	-- ==================== ФУНКЦІЯ СТВОРЕННЯ КНОПКИ ====================
	local function createButton(text, color, callback)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0.9, 0, 0, 40)
		button.BackgroundColor3 = color or Color3.fromRGB(100, 150, 255)
		button.BackgroundTransparency = 0.6
		button.Text = text
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 16
		button.Font = Enum.Font.GothamSemibold
		button.BorderSizePixel = 0
		button.Parent = scrollFrame
		
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 10)
		btnCorner.Parent = button
		
		local btnStroke = Instance.new("UIStroke")
		btnStroke.Thickness = 1
		btnStroke.Color = Color3.fromRGB(255, 255, 255)
		btnStroke.Transparency = 0.5
		btnStroke.Parent = button
		
		-- Ефект наведення
		button.MouseEnter:Connect(function()
			local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.3})
			tween:Play()
		end)
		button.MouseLeave:Connect(function()
			local tween = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.6})
			tween:Play()
		end)
		
		button.MouseButton1Click:Connect(callback)
		return button
	end
	
	-- ==================== ФУНКЦІЯ СТВОРЕННЯ ПЕРЕМИКАЧА ====================
	local function createToggle(text, default, callback)
		local toggleFrame = Instance.new("Frame")
		toggleFrame.Size = UDim2.new(0.9, 0, 0, 40)
		toggleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleFrame.BackgroundTransparency = 0.8
		toggleFrame.BorderSizePixel = 0
		toggleFrame.Parent = scrollFrame
		
		local toggleCorner = Instance.new("UICorner")
		toggleCorner.CornerRadius = UDim.new(0, 10)
		toggleCorner.Parent = toggleFrame
		
		local toggleStroke = Instance.new("UIStroke")
		toggleStroke.Thickness = 1
		toggleStroke.Color = Color3.fromRGB(255, 255, 255)
		toggleStroke.Transparency = 0.4
		toggleStroke.Parent = toggleFrame
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.65, 0, 1, 0)
		label.Position = UDim2.new(0.05, 0, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextSize = 15
		label.Font = Enum.Font.GothamMedium
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = toggleFrame
		
		local switchFrame = Instance.new("Frame")
		switchFrame.Size = UDim2.new(0, 44, 0, 22)
		switchFrame.Position = UDim2.new(1, -55, 0.5, -11)
		switchFrame.BackgroundColor3 = default and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(150, 150, 150)
		switchFrame.BackgroundTransparency = 0.3
		switchFrame.BorderSizePixel = 0
		switchFrame.Parent = toggleFrame
		
		local switchCorner = Instance.new("UICorner")
		switchCorner.CornerRadius = UDim.new(1, 0)
		switchCorner.Parent = switchFrame
		
		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 18, 0, 18)
		dot.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dot.BackgroundTransparency = 0.1
		dot.BorderSizePixel = 0
		dot.Parent = switchFrame
		
		local dotCorner = Instance.new("UICorner")
		dotCorner.CornerRadius = UDim.new(1, 0)
		dotCorner.Parent = dot
		
		local toggled = default or false
		
		local function updateToggle()
			if toggled then
				switchFrame.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
				local tween = TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9)})
				tween:Play()
			else
				switchFrame.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
				local tween = TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -9)})
				tween:Play()
			end
		end
		
		toggleFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				toggled = not toggled
				updateToggle()
				callback(toggled)
			end
		end)
		
		return toggleFrame
	end
	
	-- ==================== СЛАЙДЕР ====================
	local function createSlider(text, min, max, default, callback)
		local sliderFrame = Instance.new("Frame")
		sliderFrame.Size = UDim2.new(0.9, 0, 0, 55)
		sliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		sliderFrame.BackgroundTransparency = 0.8
		sliderFrame.BorderSizePixel = 0
		sliderFrame.Parent = scrollFrame
		
		local sliderCorner = Instance.new("UICorner")
		sliderCorner.CornerRadius = UDim.new(0, 10)
		sliderCorner.Parent = sliderFrame
		
		local sliderStroke = Instance.new("UIStroke")
		sliderStroke.Thickness = 1
		sliderStroke.Color = Color3.fromRGB(255, 255, 255)
		sliderStroke.Transparency = 0.4
		sliderStroke.Parent = sliderFrame
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -10, 0, 20)
		label.Position = UDim2.new(0, 5, 0, 5)
		label.BackgroundTransparency = 1
		label.Text = text .. ": " .. default
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextSize = 13
		label.Font = Enum.Font.GothamMedium
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = sliderFrame
		
		local slider = Instance.new("TextBox")
		slider.Size = UDim2.new(1, -10, 0, 6)
		slider.Position = UDim2.new(0, 5, 0, 32)
		slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		slider.BackgroundTransparency = 0.5
		slider.Text = ""
		slider.BorderSizePixel = 0
		slider.Parent = sliderFrame
		
		local sliderCorner2 = Instance.new("UICorner")
		sliderCorner2.CornerRadius = UDim.new(1, 0)
		sliderCorner2.Parent = slider
		
		local fill = Instance.new("Frame")
		fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = Color3.fromRGB(150, 200, 255)
		fill.BackgroundTransparency = 0.2
		fill.BorderSizePixel = 0
		fill.Parent = slider
		
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(1, 0)
		fillCorner.Parent = fill
		
		sliderFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local connection
				connection = RunService.RenderStepped:Connect(function()
					if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
						connection:Disconnect()
						return
					end
					local mousePos = UserInputService:GetMouseLocation()
					local sliderPos = slider.AbsolutePosition
					local sliderSize = slider.AbsoluteSize
					local percent = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
					local value = math.floor(min + (max - min) * percent)
					fill.Size = UDim2.new(percent, 0, 1, 0)
					label.Text = text .. ": " .. value
					callback(value)
				end)
			end
		end)
		
		return sliderFrame
	end
	
	-- ==================== РОЗДІЛЮВАЧ ====================
	local function createDivider(text)
		local div = Instance.new("Frame")
		div.Size = UDim2.new(0.9, 0, 0, 25)
		div.BackgroundTransparency = 1
		div.Parent = scrollFrame
		
		local line = Instance.new("Frame")
		line.Size = UDim2.new(1, 0, 0, 1)
		line.Position = UDim2.new(0, 0, 0.5, 0)
		line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		line.BackgroundTransparency = 0.5
		line.BorderSizePixel = 0
		line.Parent = div
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0, 120, 0, 20)
		label.Position = UDim2.new(0.5, -60, 0, 3)
		label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
		label.BackgroundTransparency = 0.5
		label.Text = text
		label.TextColor3 = Color3.fromRGB(200, 200, 255)
		label.TextSize = 12
		label.Font = Enum.Font.GothamBold
		label.Parent = div
		
		local labelCorner = Instance.new("UICorner")
		labelCorner.CornerRadius = UDim.new(0, 6)
		labelCorner.Parent = label
	end
	
	-- ==================== НАПОВНЕННЯ КНОПКАМИ ====================
	local settings = playerSettings[player] or {
		esp = false,
		aimbot = false,
		fly = false,
		speed = 16,
		noclip = false,
		fov = 150
	}
	playerSettings[player] = settings
	
	createDivider("🎯 AIMBOT")
	
	createToggle("Aimbot", settings.aimbot, function(value)
		settings.aimbot = value
		RemoteEvent:FireClient(player, "aimbot", value)
	end)
	
	createSlider("FOV", 50, 500, settings.fov, function(value)
		settings.fov = value
		RemoteEvent:FireClient(player, "fov", value)
	end)
	
	createDivider("👁️ ESP")
	
	createToggle("ESP", settings.esp, function(value)
		settings.esp = value
		RemoteEvent:FireClient(player, "esp", value)
	end)
	
	createToggle("Team Check", true, function(value)
		RemoteEvent:FireClient(player, "teamCheck", value)
	end)
	
	createToggle("Boxes", true, function(value)
		RemoteEvent:FireClient(player, "boxes", value)
	end)
	
	createToggle("Tracers", true, function(value)
		RemoteEvent:FireClient(player, "tracers", value)
	end)
	
	createDivider("🏃 MOVEMENT")
	
	createToggle("Fly", settings.fly, function(value)
		settings.fly = value
		RemoteEvent:FireClient(player, "fly", value)
	end)
	
	createToggle("NoClip", settings.noclip, function(value)
		settings.noclip = value
		RemoteEvent:FireClient(player, "noclip", value)
	end)
	
	createSlider("Speed", 16, 200, settings.speed, function(value)
		settings.speed = value
		RemoteEvent:FireClient(player, "speed", value)
	end)
	
	createDivider("⚡ ACTIONS")
	
	createButton("🔄 Respawn", Color3.fromRGB(150, 100, 255), function()
		player:LoadCharacter()
	end)
	
	createButton("💀 Kill All (Nearby)", Color3.fromRGB(255, 80, 80), function()
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				for _, other in ipairs(Players:GetPlayers()) do
					if other ~= player and other.Character then
						local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
						if otherRoot and (otherRoot.Position - root.Position).Magnitude < 100 then
							local otherHum = other.Character:FindFirstChild("Humanoid")
							if otherHum then
								otherHum.Health = 0
							end
						end
					end
				end
			end
		end
	end)
	
	createButton("🎒 Give Tools", Color3.fromRGB(100, 200, 150), function()
		local char = player.Character
		if char then
			local backpack = player:FindFirstChild("Backpack")
			if backpack then
				-- Тут можна додати видачу інструментів
				print("Tools given to " .. player.Name)
			end
		end
	end)
	
	-- ==================== КНОПКА ВІДКРИТТЯ ====================
	local openButton = Instance.new("TextButton")
	openButton.Size = UDim2.new(0, 50, 0, 50)
	openButton.Position = UDim2.new(0.5, -25, 0.95, -55)
	openButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	openButton.BackgroundTransparency = 0.75
	openButton.Text = "🔮"
	openButton.TextSize = 28
	openButton.Font = Enum.Font.GothamBold
	openButton.BorderSizePixel = 0
	openButton.Parent = screenGui
	
	local openCorner = Instance.new("UICorner")
	openCorner.CornerRadius = UDim.new(0, 14)
	openCorner.Parent = openButton
	
	local openStroke = Instance.new("UIStroke")
	openStroke.Thickness = 1.5
	openStroke.Color = Color3.fromRGB(255, 255, 255)
	openStroke.Transparency = 0.4
	openStroke.Parent = openButton
	
	openButton.MouseButton1Click:Connect(function()
		mainFrame.Visible = not mainFrame.Visible
	end)
	
	-- Спочатку приховати
	mainFrame.Visible = false
end

-- ==================== ВИДАЧА GUI ПРИ ПРИЄДНАННІ ====================
Players.PlayerAdded:Connect(function(player)
	playerSettings[player] = {
		esp = false,
		aimbot = false,
		fly = false,
		speed = 16,
		noclip = false,
		fov = 150
	}
	
	player.CharacterAdded:Connect(function()
		task.wait(0.5)
		createGUI(player)
	end)
	
	createGUI(player)
end)

Players.PlayerRemoving:Connect(function(player)
	playerSettings[player] = nil
end)

-- ==================== ОБРОБКА КОМАНД ВІД КЛІЄНТА ====================
RemoteEvent.OnServerEvent:Connect(function(player, command, value)
	if command == "killAll" then
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				for _, other in ipairs(Players:GetPlayers()) do
					if other ~= player and other.Character then
						local otherRoot = other.Character:FindFirstChild("HumanoidRootPart")
						if otherRoot and (otherRoot.Position - root.Position).Magnitude < 100 then
							local otherHum = other.Character:FindFirstChild("Humanoid")
							if otherHum then
								otherHum.Health = 0
							end
						end
					end
				end
			end
		end
	end
end)
