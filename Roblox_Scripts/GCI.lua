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

local grassEnabled = false
local cactusEnabled = false
local connection = nil
local running = false

local GRASS_RANGE = 150
local CACTUS_RANGE = GRASS_RANGE * 5

local BATCH_SIZE = 120
local TOUCHES_PER_PART = 1

local grassCache = {}
local cactusCache = {}
local grassIndex = 1
local cactusIndex = 1

local savedPos = UDim2.fromOffset(120, 120)
local bubblePos = UDim2.fromOffset(120, 120)

local function getRoot()
	local char = Player.Character
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
end

local function rebuildGrassCache()
	grassCache = {}
	grassIndex = 1

	local folder = Workspace:FindFirstChild("GrassObjects")
	if not folder then return end

	for _, v in ipairs(folder:GetDescendants()) do
		if v:IsA("BasePart") and v.Name == "g" then
			table.insert(grassCache, v)
		end
	end
end

local function rebuildCactusCache()
	cactusCache = {}
	cactusIndex = 1

	local folder = Workspace:FindFirstChild("GrassObjects")
	if not folder then return end

	for _, v in ipairs(folder:GetDescendants()) do
		if v:IsA("BasePart") and v.Name == "g" then
			table.insert(cactusCache, v)
		end
	end
end

local function isInsideSquare(part, root, range)
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

local function processCache(cache, index, range)
	local root = getRoot()
	if not root then return index end
	if #cache == 0 then return index end

	local originalCF = root.CFrame

	for i = 1, BATCH_SIZE do
		if not grassEnabled and not cactusEnabled then break end

		if index > #cache then
			index = 1
		end

		local part = cache[index]
		index += 1

		if part and part.Parent and part:IsA("BasePart") and isInsideSquare(part, root, range) then
			pcall(function()
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				root.CFrame = CFrame.new(
					part.Position.X,
					originalCF.Position.Y,
					part.Position.Z
				)
			end)

			for j = 1, TOUCHES_PER_PART do
				touch(part, root)
			end

			pcall(function()
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				root.CFrame = originalCF
			end)
		end
	end

	return index
end

local function loop()
	if running then return end
	running = true

	if grassEnabled then
		if #grassCache == 0 then rebuildGrassCache() end
		grassIndex = processCache(grassCache, grassIndex, GRASS_RANGE)
	end

	if cactusEnabled then
		if #cactusCache == 0 then rebuildCactusCache() end
		cactusIndex = processCache(cactusCache, cactusIndex, CACTUS_RANGE)
	end

	running = false
end

local function startLoop()
	if connection then return end
	connection = RunService.Heartbeat:Connect(function()
		if grassEnabled or cactusEnabled then
			loop()
		end
	end)
end

local function stopLoopIfNeeded()
	if grassEnabled or cactusEnabled then return end
	if connection then
		connection:Disconnect()
		connection = nil
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
frame.Size = UDim2.fromOffset(300, 360)
frame.Position = savedPos
frame.BackgroundColor3 = Color3.fromRGB(15, 35, 22)
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
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(26, 26)
minimize.Position = UDim2.new(1, -66, 0, 10)
minimize.Text = "-"
minimize.BackgroundColor3 = Color3.fromRGB(35, 75, 45)
minimize.TextColor3 = Color3.fromRGB(180, 255, 190)
minimize.Parent = frame
corner(minimize, 8)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(26, 26)
close.Position = UDim2.new(1, -34, 0, 10)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(80, 25, 25)
close.TextColor3 = Color3.fromRGB(255, 150, 150)
close.Parent = frame
corner(close, 8)

local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(1, -75, 0, 45)
dragArea.BackgroundTransparency = 1
dragArea.Text = ""
dragArea.Parent = frame

-- Grass Button
local grassButton = Instance.new("TextButton")
grassButton.Size = UDim2.fromOffset(230, 42)
grassButton.Position = UDim2.fromOffset(35, 58)
grassButton.Text = "Grass Cutting Off"
grassButton.BackgroundColor3 = Color3.fromRGB(55, 70, 55)
grassButton.TextColor3 = Color3.fromRGB(235, 235, 235)
grassButton.Font = Enum.Font.GothamBold
grassButton.TextSize = 18
grassButton.Parent = frame
corner(grassButton, 12)

-- Cactus Button
local cactusButton = Instance.new("TextButton")
cactusButton.Size = UDim2.fromOffset(230, 36)
cactusButton.Position = UDim2.fromOffset(35, 105)
cactusButton.Text = "Cactus Off"
cactusButton.BackgroundColor3 = Color3.fromRGB(60, 60, 45)
cactusButton.TextColor3 = Color3.fromRGB(235, 235, 200)
cactusButton.Font = Enum.Font.GothamBold
cactusButton.TextSize = 16
cactusButton.Parent = frame
corner(cactusButton, 10)

local cactusNote = Instance.new("TextLabel")
cactusNote.Size = UDim2.fromOffset(230, 20)
cactusNote.Position = UDim2.fromOffset(35, 145)
cactusNote.BackgroundTransparency = 1
cactusNote.Text = "Only use in Desert"
cactusNote.TextColor3 = Color3.fromRGB(220, 200, 120)
cactusNote.Font = Enum.Font.Gotham
cactusNote.TextSize = 12
cactusNote.Parent = frame

-- GitHub Button
local github = Instance.new("TextButton")
github.Size = UDim2.fromOffset(230, 24)
github.Position = UDim2.fromOffset(35, 175)
github.Text = "GitHub | ChimeraGaming"
github.BackgroundColor3 = Color3.fromRGB(25, 45, 32)
github.TextColor3 = Color3.fromRGB(175, 220, 180)
github.Font = Enum.Font.GothamBold
github.TextSize = 12
github.Parent = frame
corner(github, 8)

-- Infinite Yield Button
local iy = Instance.new("TextButton")
iy.Size = UDim2.fromOffset(230, 24)
iy.Position = UDim2.fromOffset(35, 205)
iy.Text = "Load Infinite Yield"
iy.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
iy.TextColor3 = Color3.fromRGB(220, 220, 255)
iy.Font = Enum.Font.GothamBold
iy.TextSize = 12
iy.Parent = frame
corner(iy, 8)

local iyNote = Instance.new("TextLabel")
iyNote.Size = UDim2.fromOffset(230, 18)
iyNote.Position = UDim2.fromOffset(35, 232)
iyNote.BackgroundTransparency = 1
iyNote.Text = "Enable AntiAFK for best results"
iyNote.TextColor3 = Color3.fromRGB(200, 200, 255)
iyNote.Font = Enum.Font.Gotham
iyNote.TextSize = 11
iyNote.Parent = frame

-- Popup
local popup = Instance.new("TextLabel")
popup.Size = UDim2.fromOffset(230, 24)
popup.Position = UDim2.fromOffset(35, 255)
popup.BackgroundColor3 = Color3.fromRGB(35, 75, 45)
popup.Text = "Copied to clipboard"
popup.TextColor3 = Color3.fromRGB(220, 255, 225)
popup.Font = Enum.Font.GothamBold
popup.TextSize = 12
popup.Visible = false
popup.Parent = frame
corner(popup, 8)

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -20, 0, 34)
credit.Position = UDim2.fromOffset(10, 285)
credit.BackgroundTransparency = 1
credit.Text = "Credit | Chimera__Gaming\nFREE AT RSCRIPTS"
credit.Font = Enum.Font.Gotham
credit.TextSize = 11
credit.TextColor3 = Color3.fromRGB(175, 220, 180)
credit.TextWrapped = true
credit.Parent = frame

-- Button Logic
grassButton.MouseButton1Click:Connect(function()
	grassEnabled = not grassEnabled
	grassButton.Text = grassEnabled and "Grass Cutting On" or "Grass Cutting Off"
	grassButton.BackgroundColor3 = grassEnabled and Color3.fromRGB(40,150,65) or Color3.fromRGB(55,70,55)

	if grassEnabled then
		rebuildGrassCache()
		startLoop()
	else
		stopLoopIfNeeded()
	end
end)

cactusButton.MouseButton1Click:Connect(function()
	cactusEnabled = not cactusEnabled
	cactusButton.Text = cactusEnabled and "Cactus On" or "Cactus Off"
	cactusButton.BackgroundColor3 = cactusEnabled and Color3.fromRGB(150,120,40) or Color3.fromRGB(60,60,45)

	if cactusEnabled then
		rebuildCactusCache()
		startLoop()
	else
		stopLoopIfNeeded()
	end
end)

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

close.MouseButton1Click:Connect(function()
	if connection then connection:Disconnect() end
	gui:Destroy()
end)

-- Drag
local dragging = false
local dragStart, startPos

dragArea.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = UIS:GetMouseLocation()
		startPos = frame.Position
	end
end)

UIS.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local m = UIS:GetMouseLocation()
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + (m.X - dragStart.X),
			startPos.Y.Scale,
			startPos.Y.Offset + (m.Y - dragStart.Y)
		)
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

print("Grass + Cactus Collector Loaded")
