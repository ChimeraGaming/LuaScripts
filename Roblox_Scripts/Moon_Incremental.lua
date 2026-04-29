--============================================================
-- Moon Incremental
-- Essence + Astral Chunk TP Collector
-- Credit | Chimera__Gaming
--============================================================

--============================================================
-- SERVICES
--============================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("MoonIncremental")
if old then old:Destroy() end

--============================================================
-- SETTINGS
--============================================================

local TP_RANGE = 850
local BATCH_SIZE = 120
local TOUCHES_PER_PART = 1

--============================================================
-- STATE
--============================================================

local essenceTPEnabled = false
local astralTPEnabled = false
local activeTarget = nil

local connection = nil
local running = false

local cache = {}
local index = 1

local savedPos = UDim2.fromOffset(120, 120)
local bubblePos = UDim2.fromOffset(120, 120)

--============================================================
-- CHARACTER
--============================================================

local function getRoot()
	local char = Player.Character
	if not char then return nil end

	return char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
end

--============================================================
-- CACHE
--============================================================

local function rebuildCache(targetType)
	cache = {}
	index = 1

	if targetType == "Essence" then
		for _, folder in ipairs(Workspace:GetChildren()) do
			if string.find(folder.Name, "MyEssence") then
				for _, essenceFolder in ipairs(folder:GetChildren()) do
					if essenceFolder.Name == "Essence" then
						for _, v in ipairs(essenceFolder:GetDescendants()) do
							if v:IsA("BasePart") then
								table.insert(cache, v)
							end
						end
					end
				end
			end
		end
	end

	if targetType == "AstralChunk" then
		for _, v in ipairs(Workspace:GetChildren()) do
			if v.Name == "AstralChunk" then
				if v:IsA("BasePart") then
					table.insert(cache, v)
				else
					for _, d in ipairs(v:GetDescendants()) do
						if d:IsA("BasePart") then
							table.insert(cache, d)
						end
					end
				end
			end
		end
	end
end

local function isInsideSquare(part, root, range)
	local dx = math.abs(part.Position.X - root.Position.X)
	local dz = math.abs(part.Position.Z - root.Position.Z)
	local half = range / 2

	return dx <= half and dz <= half
end

--============================================================
-- TP LOGIC
--============================================================

local function touch(part, root)
	pcall(function()
		part.CanTouch = true
		part.CanCollide = false
		firetouchinterest(root, part, 0)
		firetouchinterest(root, part, 1)
	end)
end

local function teleportToPart(part, root)
	local original = root.CFrame

	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = CFrame.new(
			part.Position.X,
			original.Position.Y,
			part.Position.Z
		)
	end)

	for i = 1, TOUCHES_PER_PART do
		touch(part, root)
	end

	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = original
	end)
end

local function processTP()
	local root = getRoot()
	if not root or not activeTarget then return end

	if #cache == 0 then
		rebuildCache(activeTarget)
	end

	for i = 1, BATCH_SIZE do
		if not essenceTPEnabled and not astralTPEnabled then break end

		if index > #cache then
			index = 1
			rebuildCache(activeTarget)
		end

		local part = cache[index]
		index += 1

		if part and part.Parent and part:IsA("BasePart") then
			if isInsideSquare(part, root, TP_RANGE) then
				teleportToPart(part, root)
			end
		end
	end
end

local function startLoop()
	if connection then return end

	rebuildCache(activeTarget)

	connection = RunService.Heartbeat:Connect(function()
		if not essenceTPEnabled and not astralTPEnabled then return end
		if running then return end

		running = true
		processTP()
		running = false
	end)
end

local function stopLoop()
	essenceTPEnabled = false
	astralTPEnabled = false
	activeTarget = nil
	running = false

	if connection then
		connection:Disconnect()
		connection = nil
	end
end

--============================================================
-- UI HELPERS
--============================================================

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

--============================================================
-- UI
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "MoonIncremental"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(320, 390)
frame.Position = savedPos
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 35)
frame.BorderSizePixel = 0
frame.Parent = gui
corner(frame, 14)
stroke(frame, Color3.fromRGB(145, 120, 255), 2)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -82, 0, 34)
title.Position = UDim2.fromOffset(14, 12)
title.BackgroundTransparency = 1
title.Text = "Moon Incremental"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(235, 230, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(26, 26)
minimize.Position = UDim2.new(1, -66, 0, 10)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 18
minimize.BackgroundColor3 = Color3.fromRGB(50, 42, 95)
minimize.TextColor3 = Color3.fromRGB(235, 230, 255)
minimize.Parent = frame
corner(minimize, 8)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(26, 26)
close.Position = UDim2.new(1, -34, 0, 10)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.BackgroundColor3 = Color3.fromRGB(80, 25, 45)
close.TextColor3 = Color3.fromRGB(255, 170, 190)
close.Parent = frame
corner(close, 8)

local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(1, -75, 0, 45)
dragArea.BackgroundTransparency = 1
dragArea.Text = ""
dragArea.Parent = frame

local divider1 = Instance.new("Frame")
divider1.Size = UDim2.new(1, -30, 0, 1)
divider1.Position = UDim2.fromOffset(15, 52)
divider1.BackgroundColor3 = Color3.fromRGB(145, 120, 255)
divider1.BorderSizePixel = 0
divider1.Parent = frame

--============================================================
-- BUTTONS
--============================================================

local essenceButton = Instance.new("TextButton")
essenceButton.Size = UDim2.fromOffset(270, 38)
essenceButton.Position = UDim2.fromOffset(25, 72)
essenceButton.Text = "Essence TP Off"
essenceButton.BackgroundColor3 = Color3.fromRGB(55, 45, 95)
essenceButton.TextColor3 = Color3.fromRGB(235, 235, 255)
essenceButton.Font = Enum.Font.GothamBold
essenceButton.TextSize = 16
essenceButton.Parent = frame
corner(essenceButton, 10)

local astralButton = Instance.new("TextButton")
astralButton.Size = UDim2.fromOffset(270, 38)
astralButton.Position = UDim2.fromOffset(25, 118)
astralButton.Text = "Astral Chunk TP Off"
astralButton.BackgroundColor3 = Color3.fromRGB(55, 45, 95)
astralButton.TextColor3 = Color3.fromRGB(235, 235, 255)
astralButton.Font = Enum.Font.GothamBold
astralButton.TextSize = 16
astralButton.Parent = frame
corner(astralButton, 10)

local github = Instance.new("TextButton")
github.Size = UDim2.fromOffset(270, 30)
github.Position = UDim2.fromOffset(25, 170)
github.Text = "GitHub | ChimeraGaming LuaScripts"
github.BackgroundColor3 = Color3.fromRGB(30, 28, 55)
github.TextColor3 = Color3.fromRGB(205, 195, 255)
github.Font = Enum.Font.GothamBold
github.TextSize = 12
github.Parent = frame
corner(github, 8)

local iy = Instance.new("TextButton")
iy.Size = UDim2.fromOffset(270, 30)
iy.Position = UDim2.fromOffset(25, 208)
iy.Text = "Load Infinite Yield"
iy.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
iy.TextColor3 = Color3.fromRGB(220, 220, 255)
iy.Font = Enum.Font.GothamBold
iy.TextSize = 12
iy.Parent = frame
corner(iy, 8)

local iyNote = Instance.new("TextLabel")
iyNote.Size = UDim2.fromOffset(270, 24)
iyNote.Position = UDim2.fromOffset(25, 244)
iyNote.BackgroundTransparency = 1
iyNote.Text = "> Enable AntiAFK for best results"
iyNote.TextColor3 = Color3.fromRGB(205, 195, 255)
iyNote.Font = Enum.Font.Gotham
iyNote.TextSize = 11
iyNote.TextWrapped = true
iyNote.TextXAlignment = Enum.TextXAlignment.Left
iyNote.Parent = frame

local popup = Instance.new("TextLabel")
popup.Size = UDim2.fromOffset(270, 26)
popup.Position = UDim2.fromOffset(25, 272)
popup.BackgroundColor3 = Color3.fromRGB(50, 42, 95)
popup.Text = "Copied to clipboard"
popup.TextColor3 = Color3.fromRGB(235, 230, 255)
popup.Font = Enum.Font.GothamBold
popup.TextSize = 12
popup.Visible = false
popup.Parent = frame
corner(popup, 8)

local divider2 = Instance.new("Frame")
divider2.Size = UDim2.new(1, -30, 0, 1)
divider2.Position = UDim2.fromOffset(15, 310)
divider2.BackgroundColor3 = Color3.fromRGB(145, 120, 255)
divider2.BorderSizePixel = 0
divider2.Parent = frame

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -20, 0, 54)
credit.Position = UDim2.fromOffset(10, 320)
credit.BackgroundTransparency = 1
credit.Text = "Credit | Chimera__Gaming\nFREE AT RSCRIPTS"
credit.Font = Enum.Font.Gotham
credit.TextSize = 11
credit.TextColor3 = Color3.fromRGB(205, 195, 255)
credit.TextWrapped = true
credit.Parent = frame

--============================================================
-- BUTTON LOGIC
--============================================================

local function updateButtons()
	essenceButton.Text = essenceTPEnabled and "Essence TP On" or "Essence TP Off"
	astralButton.Text = astralTPEnabled and "Astral Chunk TP On" or "Astral Chunk TP Off"

	essenceButton.BackgroundColor3 = essenceTPEnabled and Color3.fromRGB(120, 90, 255) or Color3.fromRGB(55, 45, 95)
	astralButton.BackgroundColor3 = astralTPEnabled and Color3.fromRGB(120, 90, 255) or Color3.fromRGB(55, 45, 95)
end

essenceButton.MouseButton1Click:Connect(function()
	local newState = not essenceTPEnabled

	essenceTPEnabled = false
	astralTPEnabled = false
	activeTarget = nil

	if newState then
		essenceTPEnabled = true
		activeTarget = "Essence"
		rebuildCache(activeTarget)
		startLoop()
	else
		stopLoop()
	end

	updateButtons()
end)

astralButton.MouseButton1Click:Connect(function()
	local newState = not astralTPEnabled

	essenceTPEnabled = false
	astralTPEnabled = false
	activeTarget = nil

	if newState then
		astralTPEnabled = true
		activeTarget = "AstralChunk"
		rebuildCache(activeTarget)
		startLoop()
	else
		stopLoop()
	end

	updateButtons()
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
	loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

close.MouseButton1Click:Connect(function()
	stopLoop()
	gui:Destroy()
end)

--============================================================
-- DRAG FRAME
--============================================================

local dragging = false
local dragStart
local startPos

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
		if dragging then
			savedPos = frame.Position
		end

		dragging = false
	end
end)

--============================================================
-- MINIMIZE BUBBLE
--============================================================

local bubble = Instance.new("TextButton")
bubble.Size = UDim2.fromOffset(52, 52)
bubble.Position = bubblePos
bubble.BackgroundColor3 = Color3.fromRGB(18, 16, 35)
bubble.Text = "🌙"
bubble.Font = Enum.Font.GothamBold
bubble.TextSize = 24
bubble.TextColor3 = Color3.fromRGB(235, 230, 255)
bubble.Visible = false
bubble.Parent = gui
corner(bubble, 26)
stroke(bubble, Color3.fromRGB(145, 120, 255), 2)

local bubbleDragging = false
local bubbleDragStart
local bubbleStartPos
local bubbleMoved = false

bubble.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		bubbleDragging = true
		bubbleMoved = false
		bubbleDragStart = UIS:GetMouseLocation()
		bubbleStartPos = bubble.Position
	end
end)

UIS.InputChanged:Connect(function(i)
	if bubbleDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local m = UIS:GetMouseLocation()
		local dx = m.X - bubbleDragStart.X
		local dy = m.Y - bubbleDragStart.Y

		if math.abs(dx) > 3 or math.abs(dy) > 3 then
			bubbleMoved = true
		end

		bubble.Position = UDim2.new(
			bubbleStartPos.X.Scale,
			bubbleStartPos.X.Offset + dx,
			bubbleStartPos.Y.Scale,
			bubbleStartPos.Y.Offset + dy
		)
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 and bubbleDragging then
		bubbleDragging = false
		bubblePos = bubble.Position

		if not bubbleMoved then
			frame.Position = bubble.Position
			frame.Visible = true
			bubble.Visible = false
		end
	end
end)

minimize.MouseButton1Click:Connect(function()
	savedPos = frame.Position
	bubble.Position = frame.Position
	frame.Visible = false
	bubble.Visible = true
end)

print("Moon Incremental Loaded")
