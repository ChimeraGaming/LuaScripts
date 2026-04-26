-- Grass Collector
-- 🌱 Grass Cutting Incremental 🌱
-- Credit | Chimera__Gaming
-- FREE AT RSCRIPTS

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("GrassCollector")
if old then old:Destroy() end

local enabled = false
local connection = nil
local running = false

local range = 150
local BATCH_SIZE = 120
local TOUCHES_PER_GRASS = 1

local cache = {}
local index = 1

local savedPos = UDim2.fromOffset(120, 120)
local bubblePos = UDim2.fromOffset(120, 120)

local function getRoot()
	local char = Player.Character
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
end

local function rebuildCache()
	cache = {}
	index = 1

	local folder = Workspace:FindFirstChild("GrassObjects")
	if not folder then return end

	for _, v in ipairs(folder:GetDescendants()) do
		if v:IsA("BasePart") and v.Name == "g" then
			table.insert(cache, v)
		end
	end
end

local function isInsideSquare(part, root)
	local dx = math.abs(part.Position.X - root.Position.X)
	local dz = math.abs(part.Position.Z - root.Position.Z)
	local half = range / 2
	return dx <= half and dz <= half
end

local function touch(part, root)
	pcall(function()
		part.CanTouch = true
		part.CanCollide = false
		firetouchinterest(root, part, 0)
		firetouchinterest(root, part, 1)
	end)
end

local function collectBatch()
	if running or not enabled then return end
	running = true

	local root = getRoot()
	if not root or type(firetouchinterest) ~= "function" then
		running = false
		return
	end

	if #cache == 0 then
		rebuildCache()
		running = false
		return
	end

	local originalCF = root.CFrame

	for i = 1, BATCH_SIZE do
		if not enabled then break end

		if index > #cache then
			index = 1
			rebuildCache()
		end

		local part = cache[index]
		index += 1

		if part and part.Parent and isInsideSquare(part, root) then
			pcall(function()
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				root.CFrame = CFrame.new(
					part.Position.X,
					originalCF.Position.Y,
					part.Position.Z
				)
			end)

			for j = 1, TOUCHES_PER_GRASS do
				if not enabled then break end
				touch(part, root)
			end

			pcall(function()
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				root.CFrame = originalCF
			end)
		end
	end

	running = false
end

-- UI helpers
local function corner(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
end

local function stroke(obj, color, t)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = t
	s.Parent = obj
end

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "GrassCollector"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(300, 250)
frame.Position = savedPos
frame.BackgroundColor3 = Color3.fromRGB(15, 35, 22)
frame.BorderSizePixel = 0
frame.Parent = gui
corner(frame, 14)
stroke(frame, Color3.fromRGB(70, 180, 95), 2)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -82, 0, 34)
title.Position = UDim2.fromOffset(14, 12)
title.BackgroundTransparency = 1
title.Text = "🌱 Grass Cutting Incremental 🌱"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(220, 255, 225)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextTruncate = Enum.TextTruncate.AtEnd
title.ZIndex = 6
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(26, 26)
minimize.Position = UDim2.new(1, -66, 0, 10)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 18
minimize.BackgroundColor3 = Color3.fromRGB(35, 75, 45)
minimize.TextColor3 = Color3.fromRGB(180, 255, 190)
minimize.AutoButtonColor = false
minimize.ZIndex = 7
minimize.Parent = frame
corner(minimize, 8)
stroke(minimize, Color3.fromRGB(70, 150, 85), 1)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(26, 26)
close.Position = UDim2.new(1, -34, 0, 10)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.BackgroundColor3 = Color3.fromRGB(80, 25, 25)
close.TextColor3 = Color3.fromRGB(255, 150, 150)
close.AutoButtonColor = false
close.ZIndex = 7
close.Parent = frame
corner(close, 8)
stroke(close, Color3.fromRGB(150, 60, 60), 1)

local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(1, -75, 0, 45)
dragArea.Position = UDim2.fromOffset(0, 0)
dragArea.BackgroundTransparency = 1
dragArea.Text = ""
dragArea.AutoButtonColor = false
dragArea.ZIndex = 5
dragArea.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(230, 42)
button.Position = UDim2.fromOffset(35, 58)
button.Text = "Off"
button.BackgroundColor3 = Color3.fromRGB(55, 70, 55)
button.TextColor3 = Color3.fromRGB(235, 235, 235)
button.Font = Enum.Font.GothamBold
button.TextSize = 22
button.AutoButtonColor = false
button.Parent = frame
corner(button, 12)
stroke(button, Color3.fromRGB(95, 120, 95), 1)

-- GitHub button
local github = Instance.new("TextButton")
github.Size = UDim2.fromOffset(230, 24)
github.Position = UDim2.fromOffset(35, 105)
github.Text = "GitHub | ChimeraGaming"
github.BackgroundColor3 = Color3.fromRGB(25, 45, 32)
github.TextColor3 = Color3.fromRGB(175, 220, 180)
github.Font = Enum.Font.GothamBold
github.TextSize = 12
github.AutoButtonColor = false
github.Parent = frame
corner(github, 8)
stroke(github, Color3.fromRGB(70, 180, 95), 1)

-- Infinite Yield button
local iy = Instance.new("TextButton")
iy.Size = UDim2.fromOffset(230, 24)
iy.Position = UDim2.fromOffset(35, 132)
iy.Text = "Load Infinite Yield"
iy.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
iy.TextColor3 = Color3.fromRGB(220, 220, 255)
iy.Font = Enum.Font.GothamBold
iy.TextSize = 12
iy.AutoButtonColor = false
iy.Parent = frame
corner(iy, 8)
stroke(iy, Color3.fromRGB(100, 100, 160), 1)

-- Popup
local popup = Instance.new("TextLabel")
popup.Size = UDim2.fromOffset(230, 24)
popup.Position = UDim2.fromOffset(35, 159)
popup.BackgroundColor3 = Color3.fromRGB(35, 75, 45)
popup.Text = "Copied to clipboard"
popup.TextColor3 = Color3.fromRGB(220, 255, 225)
popup.Font = Enum.Font.GothamBold
popup.TextSize = 12
popup.Visible = false
popup.Parent = frame
corner(popup, 8)
stroke(popup, Color3.fromRGB(70, 180, 95), 1)

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -20, 0, 34)
credit.Position = UDim2.fromOffset(10, 188)
credit.BackgroundTransparency = 1
credit.Text = "Credit | Chimera__Gaming\nFREE AT RSCRIPTS"
credit.Font = Enum.Font.Gotham
credit.TextSize = 11
credit.TextColor3 = Color3.fromRGB(175, 220, 180)
credit.TextWrapped = true
credit.Parent = frame

github.MouseButton1Click:Connect(function()
	setclipboard("https://github.com/ChimeraGaming/LuaScripts")

	popup.Visible = true
	task.delay(3, function()
		if popup and popup.Parent then
			popup.Visible = false
		end
	end)
end)

iy.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Infinite-Yield-43437"))()
end)

-- collector control
local function startCollector()
	if connection then connection:Disconnect() end
	rebuildCache()
	connection = RunService.Heartbeat:Connect(function()
		if enabled then collectBatch() end
	end)
end

local function stopCollector()
	if connection then connection:Disconnect() end
	connection = nil
	running = false
end

button.MouseButton1Click:Connect(function()
	enabled = not enabled

	button.Text = enabled and "On" or "Off"
	button.BackgroundColor3 = enabled and Color3.fromRGB(40, 150, 65) or Color3.fromRGB(55, 70, 55)

	if enabled then
		startCollector()
	else
		stopCollector()
	end
end)

close.MouseButton1Click:Connect(function()
	enabled = false
	stopCollector()
	gui:Destroy()
end)

-- drag logic
local dragging = false
local dragStart
local startPos

dragArea.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = UIS:GetMouseLocation()
		startPos = frame.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local m = UIS:GetMouseLocation()
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + (m.X - dragStart.X),
			startPos.Y.Scale,
			startPos.Y.Offset + (m.Y - dragStart.Y)
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if dragging then
			savedPos = frame.Position
		end
		dragging = false
	end
end)

-- minimize + bubble
local bubble = Instance.new("TextButton")
bubble.Size = UDim2.fromOffset(52, 52)
bubble.Position = bubblePos
bubble.BackgroundColor3 = Color3.fromRGB(15, 35, 22)
bubble.Text = "🌱"
bubble.Font = Enum.Font.GothamBold
bubble.TextSize = 24
bubble.TextColor3 = Color3.fromRGB(220, 255, 225)
bubble.AutoButtonColor = false
bubble.Visible = false
bubble.Parent = gui
corner(bubble, 26)
stroke(bubble, Color3.fromRGB(70, 180, 95), 2)

minimize.MouseButton1Click:Connect(function()
	savedPos = frame.Position
	bubble.Position = frame.Position
	frame.Visible = false
	bubble.Visible = true
end)

bubble.MouseButton1Click:Connect(function()
	frame.Position = bubble.Position
	frame.Visible = true
	bubble.Visible = false
end)

print("Grass Collector Loaded")
