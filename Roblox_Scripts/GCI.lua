--============================================================
--  GRASS COLLECTOR
--  Grass Cutting Incremental
--  Credit | Chimera__Gaming
--  FREE AT RSCRIPTS
--============================================================

--============================================================
--  01. SERVICES
--============================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

--============================================================
--  02. PLAYER SETUP
--============================================================

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("GrassCollector")
if old then old:Destroy() end

--============================================================
--  03. RANGE AND SPEED SETTINGS
--============================================================

local TP_GRASS_RANGE = 150
local WALK_GRASS_RANGE = 150
local DESERT_RANGE = 750
local INTERSECTION_RANGE = 150

local OLD_BATCH_SIZE = 180
local OLD_TOUCHES = 1

local WALK_SPEED = 1500
local WALK_REACH_DISTANCE = 5
local WALK_TIMEOUT = 4

local CLUSTER_SCAN_RADIUS = 50
local CLUSTER_DISTANCE_WEIGHT = 0.2

--============================================================
--  04. MODE STATES
--============================================================

local modes = {
	w1TpGrass = false,
	w1GrassWalk = false,
	w2TpGrass = false,
	w2GrassWalk = false,
	w2Desert = false,
	w2IntersectionWalk = false
}

--============================================================
--  05. LOOP AND CACHE STATE
--============================================================

local connection = nil
local running = false
local stopRequested = false
local cache = {}
local index = 1

--============================================================
--  06. UI MEMORY STATE
--============================================================

local savedPos = UDim2.fromOffset(120, 120)
local bubblePos = UDim2.fromOffset(120, 120)
local currentTab = "W1"

--============================================================
--  07. CHARACTER ROOT FINDER
--============================================================

local function getRoot()
	local char = Player.Character
	if not char then return nil end

	return char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
end

--============================================================
--  08. HUMANOID FINDER
--============================================================

local function getHumanoid()
	local char = Player.Character
	if not char then return nil end

	return char:FindFirstChildOfClass("Humanoid")
end

--============================================================
--  09. MODE CHECKER
--============================================================

local function anyModeOn()
	for _, v in pairs(modes) do
		if v then return true end
	end

	return false
end

--============================================================
--  10. GRASS CACHE BUILDER
--============================================================

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

--============================================================
--  11. SQUARE RANGE CHECK
--============================================================

local function isInsideSquare(part, root, range)
	local dx = math.abs(part.Position.X - root.Position.X)
	local dz = math.abs(part.Position.Z - root.Position.Z)
	local half = range / 2

	return dx <= half and dz <= half
end

--============================================================
--  12. TOUCH HANDLER
--============================================================

local function touch(part, root)
	if stopRequested then return end

	pcall(function()
		part.CanTouch = true
		part.CanCollide = false
		firetouchinterest(root, part, 0)
		firetouchinterest(root, part, 1)
	end)
end

--============================================================
--  13. OLD METHOD
--  Teleports player to grass, touches it, then returns
--============================================================

local function tpPlayerToGrass(part, root)
	if stopRequested then return end

	local originalCF = root.CFrame

	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = CFrame.new(part.Position.X, originalCF.Position.Y, part.Position.Z)
	end)

	for i = 1, OLD_TOUCHES do
		if stopRequested then break end
		touch(part, root)
	end

	if stopRequested then return end

	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = originalCF
	end)
end

--============================================================
--  14. SMART WALK TARGET FINDER
--  Finds the grass inside the largest nearby group
--============================================================

local function findNearestGrass(root, range)
	local folder = Workspace:FindFirstChild("GrassObjects")
	if not folder then return nil end

	local grassParts = {}

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") and part.Name == "g" and isInsideSquare(part, root, range) then
			table.insert(grassParts, part)
		end
	end

	if #grassParts == 0 then
		return nil
	end

	local bestPart = nil
	local bestScore = -math.huge

	for _, part in ipairs(grassParts) do
		if part and part.Parent then
			local groupCount = 0

			for _, other in ipairs(grassParts) do
				if other and other.Parent then
					local dist = (other.Position - part.Position).Magnitude

					if dist <= CLUSTER_SCAN_RADIUS then
						groupCount += 1
					end
				end
			end

			local playerDist = (part.Position - root.Position).Magnitude
			local score = groupCount - (playerDist * CLUSTER_DISTANCE_WEIGHT)

			if score > bestScore then
				bestScore = score
				bestPart = part
			end
		end
	end

	return bestPart
end

--============================================================
--  15. WALK METHOD
--  Forces WalkSpeed to 100 and walks to nearest grass
--============================================================

local function walkPlayerToGrass(root, range)
	if stopRequested then return end

	local humanoid = getHumanoid()
	if not humanoid then return end

	local target = findNearestGrass(root, range)
	if not target then return end

	local startTime = tick()

	humanoid.WalkSpeed = WALK_SPEED

	while target and target.Parent and not stopRequested do
		local currentRoot = getRoot()
		local currentHumanoid = getHumanoid()

		if not currentRoot or not currentHumanoid then
			break
		end

		currentHumanoid.WalkSpeed = WALK_SPEED
		currentHumanoid:MoveTo(target.Position)

		local dist = (target.Position - currentRoot.Position).Magnitude

		if dist <= WALK_REACH_DISTANCE then
			touch(target, currentRoot)
			break
		end

		if tick() - startTime >= WALK_TIMEOUT then
			break
		end

		task.wait(0.03)
	end

	if stopRequested then
		local currentRoot = getRoot()
		local currentHumanoid = getHumanoid()

		if currentRoot and currentHumanoid then
			currentHumanoid:MoveTo(currentRoot.Position)
		end
	end
end

--============================================================
--  16. MODE PROCESSOR
--============================================================

local function processMode(root, range, walkMode)
	if stopRequested or not anyModeOn() then return end

	if walkMode then
		walkPlayerToGrass(root, range)
		return
	end

	for i = 1, OLD_BATCH_SIZE do
		if stopRequested or not anyModeOn() then
			break
		end

		if index > #cache then
			index = 1
			rebuildCache()
		end

		local part = cache[index]
		index += 1

		if stopRequested or not anyModeOn() then
			break
		end

		if part and part.Parent and part:IsA("BasePart") and part.Name == "g" and isInsideSquare(part, root, range) then
			tpPlayerToGrass(part, root)
		end
	end
end

--============================================================
--  17. MAIN COLLECTION LOOP
--============================================================

local function loop()
	if running or stopRequested or not anyModeOn() then return end
	running = true

	local root = getRoot()

	if stopRequested or not root or type(firetouchinterest) ~= "function" then
		running = false
		return
	end

	if #cache == 0 then
		rebuildCache()
	end

	if stopRequested then running = false return end
	if modes.w1TpGrass then processMode(root, TP_GRASS_RANGE, false) end

	if stopRequested then running = false return end
	if modes.w1GrassWalk then processMode(root, WALK_GRASS_RANGE, true) end

	if stopRequested then running = false return end
	if modes.w2TpGrass then processMode(root, TP_GRASS_RANGE, false) end

	if stopRequested then running = false return end
	if modes.w2GrassWalk then processMode(root, WALK_GRASS_RANGE, true) end

	if stopRequested then running = false return end
	if modes.w2Desert then processMode(root, DESERT_RANGE, false) end

	if stopRequested then running = false return end
	if modes.w2IntersectionWalk then processMode(root, INTERSECTION_RANGE, true) end

	running = false
end

--============================================================
--  18. LOOP STARTER
--============================================================

local function startLoop()
	stopRequested = false

	if connection then return end

	rebuildCache()

	connection = RunService.Heartbeat:Connect(function()
		if anyModeOn() and not stopRequested then
			loop()
		end
	end)
end

--============================================================
--  19. LOOP STOPPER
--============================================================

local function hardStop()
	stopRequested = true
	running = false

	local root = getRoot()
	local humanoid = getHumanoid()

	if root and humanoid then
		humanoid:MoveTo(root.Position)
	end

	if connection then
		connection:Disconnect()
		connection = nil
	end
end

local function stopLoopIfNeeded()
	if anyModeOn() then return end
	hardStop()
end

--============================================================
--  20. UI HELPER FUNCTIONS
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
--  21. SCREEN GUI
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "GrassCollector"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

--============================================================
--  22. MAIN FRAME
--============================================================

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(330, 336)
frame.Position = savedPos
frame.BackgroundColor3 = Color3.fromRGB(15, 35, 22)
frame.BorderSizePixel = 0
frame.Parent = gui
corner(frame, 14)
stroke(frame, Color3.fromRGB(70, 180, 95), 2)

--============================================================
--  23. TITLE BAR
--============================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -82, 0, 30)
title.Position = UDim2.fromOffset(14, 10)
title.BackgroundTransparency = 1
title.Text = "🌱 Grass Cutting Incremental 🌱"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(220, 255, 225)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(26, 26)
minimize.Position = UDim2.new(1, -66, 0, 9)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 18
minimize.BackgroundColor3 = Color3.fromRGB(35, 75, 45)
minimize.TextColor3 = Color3.fromRGB(180, 255, 190)
minimize.Parent = frame
corner(minimize, 8)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(26, 26)
close.Position = UDim2.new(1, -34, 0, 9)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.BackgroundColor3 = Color3.fromRGB(80, 25, 25)
close.TextColor3 = Color3.fromRGB(255, 150, 150)
close.Parent = frame
corner(close, 8)

local dragArea = Instance.new("TextButton")
dragArea.Size = UDim2.new(1, -75, 0, 42)
dragArea.Position = UDim2.fromOffset(0, 0)
dragArea.BackgroundTransparency = 1
dragArea.Text = ""
dragArea.Parent = frame

--============================================================
--  24. TAB BUTTONS
--============================================================

local tabW1 = Instance.new("TextButton")
tabW1.Size = UDim2.fromOffset(90, 30)
tabW1.Position = UDim2.fromOffset(27, 48)
tabW1.Text = "W1"
tabW1.Font = Enum.Font.GothamBold
tabW1.TextSize = 13
tabW1.Parent = frame
corner(tabW1, 8)

local tabW2 = Instance.new("TextButton")
tabW2.Size = UDim2.fromOffset(90, 30)
tabW2.Position = UDim2.fromOffset(120, 48)
tabW2.Text = "W2"
tabW2.Font = Enum.Font.GothamBold
tabW2.TextSize = 13
tabW2.Parent = frame
corner(tabW2, 8)

local tabExtra = Instance.new("TextButton")
tabExtra.Size = UDim2.fromOffset(90, 30)
tabExtra.Position = UDim2.fromOffset(213, 48)
tabExtra.Text = "Extra"
tabExtra.Font = Enum.Font.GothamBold
tabExtra.TextSize = 13
tabExtra.Parent = frame
corner(tabExtra, 8)

--============================================================
--  25. PAGE CREATOR
--============================================================

local pages = {}

local function makePage(name)
	local p = Instance.new("Frame")
	p.Name = name
	p.Size = UDim2.new(1, -24, 1, -110)
	p.Position = UDim2.fromOffset(12, 88)
	p.BackgroundTransparency = 1
	p.Visible = false
	p.Parent = frame

	pages[name] = p

	return p
end

local w1 = makePage("W1")
local w2 = makePage("W2")
local extra = makePage("Extra")

--============================================================
--  26. UI ELEMENT BUILDERS
--============================================================

local function makeButton(parent, y, text, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(288, 34)
	b.Position = UDim2.fromOffset(9, y)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.fromRGB(235, 235, 235)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.Parent = parent
	corner(b, 9)

	return b
end

local function makeNote(parent, y, text, color, h)
	local n = Instance.new("TextLabel")
	n.Size = UDim2.fromOffset(288, h or 26)
	n.Position = UDim2.fromOffset(9, y)
	n.BackgroundTransparency = 1
	n.Text = text
	n.TextColor3 = color
	n.Font = Enum.Font.Gotham
	n.TextSize = 10
	n.TextWrapped = true
	n.TextYAlignment = Enum.TextYAlignment.Center
	n.Parent = parent

	return n
end

local function updateButton(button, onText, offText, active, onColor, offColor)
	button.Text = active and onText or offText
	button.BackgroundColor3 = active and onColor or offColor
end

--============================================================
--  27. W1 TAB CONTENT
--============================================================

local w1TpGrass = makeButton(w1, 0, "TP Grass Off", Color3.fromRGB(55, 70, 55))
makeNote(w1, 36, "This is the old way but can be faster", Color3.fromRGB(175, 220, 180), 24)

local w1GrassWalk = makeButton(w1, 66, "Grass Walk Off", Color3.fromRGB(45, 55, 65))
makeNote(w1, 102, "Walks to nearest grass with WalkSpeed forced to 100.", Color3.fromRGB(180, 210, 230), 36)

--============================================================
--  28. W2 TAB CONTENT
--============================================================

local w2TpGrass = makeButton(w2, 0, "TP Grass Off", Color3.fromRGB(55, 70, 55))
makeNote(w2, 36, "This is the old way but can be faster", Color3.fromRGB(175, 220, 180), 24)

local w2GrassWalk = makeButton(w2, 66, "Grass Walk Off", Color3.fromRGB(45, 55, 65))
makeNote(w2, 102, "Walks to nearest grass with WalkSpeed forced to 100.", Color3.fromRGB(180, 210, 230), 36)

local w2Desert = makeButton(w2, 146, "Desert Off", Color3.fromRGB(75, 65, 35))
makeNote(w2, 182, "Only use in Desert", Color3.fromRGB(230, 205, 120), 24)

local w2IntersectionWalk = makeButton(w2, 214, "Intersection Walk Off", Color3.fromRGB(65, 45, 75))
makeNote(w2, 250, "Only use this walker in Intersection or your game may break requiring rejoining world to fix.", Color3.fromRGB(235, 160, 180), 40)

--============================================================
--  29. EXTRA TAB CONTENT
--============================================================

local github = makeButton(extra, 0, "GitHub | ChimeraGaming LuaScripts", Color3.fromRGB(25, 45, 32))
local iy = makeButton(extra, 46, "Load Infinite Yield", Color3.fromRGB(35, 35, 45))
makeNote(extra, 84, "Enable AntiAFK for best results", Color3.fromRGB(200, 200, 255), 26)

local popup = Instance.new("TextLabel")
popup.Size = UDim2.fromOffset(288, 28)
popup.Position = UDim2.fromOffset(9, 116)
popup.BackgroundColor3 = Color3.fromRGB(35, 75, 45)
popup.Text = "Copied to clipboard"
popup.TextColor3 = Color3.fromRGB(220, 255, 225)
popup.Font = Enum.Font.GothamBold
popup.TextSize = 12
popup.Visible = false
popup.Parent = extra
corner(popup, 8)

--============================================================
--  30. CREDIT FOOTER
--============================================================

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -20, 0, 32)
credit.Position = UDim2.new(0, 10, 1, -39)
credit.BackgroundTransparency = 1
credit.Text = "Credit | Chimera__Gaming\nFREE AT RSCRIPTS"
credit.Font = Enum.Font.Gotham
credit.TextSize = 10
credit.TextColor3 = Color3.fromRGB(175, 220, 180)
credit.TextWrapped = true
credit.Parent = frame

--============================================================
--  31. HEIGHT MAP
--============================================================

local function setFrameHeight(tabName)
	if tabName == "W1" then
		frame.Size = UDim2.fromOffset(330, 300)
		credit.Position = UDim2.new(0, 10, 1, -39)
	elseif tabName == "W2" then
		frame.Size = UDim2.fromOffset(330, 424)
		credit.Position = UDim2.new(0, 10, 1, -39)
	elseif tabName == "Extra" then
		frame.Size = UDim2.fromOffset(330, 296)
		credit.Position = UDim2.new(0, 10, 1, -39)
	end
end

--============================================================
--  32. SINGLE MODE LOCK
--============================================================

local function refreshAllButtons()
	updateButton(w1TpGrass, "TP Grass On", "TP Grass Off", modes.w1TpGrass, Color3.fromRGB(40, 150, 65), Color3.fromRGB(55, 70, 55))
	updateButton(w1GrassWalk, "Grass Walk On", "Grass Walk Off", modes.w1GrassWalk, Color3.fromRGB(55, 120, 180), Color3.fromRGB(45, 55, 65))

	updateButton(w2TpGrass, "TP Grass On", "TP Grass Off", modes.w2TpGrass, Color3.fromRGB(40, 150, 65), Color3.fromRGB(55, 70, 55))
	updateButton(w2GrassWalk, "Grass Walk On", "Grass Walk Off", modes.w2GrassWalk, Color3.fromRGB(55, 120, 180), Color3.fromRGB(45, 55, 65))
	updateButton(w2Desert, "Desert On", "Desert Off", modes.w2Desert, Color3.fromRGB(150, 120, 40), Color3.fromRGB(75, 65, 35))
	updateButton(w2IntersectionWalk, "Intersection Walk On", "Intersection Walk Off", modes.w2IntersectionWalk, Color3.fromRGB(130, 70, 160), Color3.fromRGB(65, 45, 75))
end

local function disableAllModesExcept(modeName)
	hardStop()

	for k in pairs(modes) do
		if k ~= modeName then
			modes[k] = false
		end
	end

	refreshAllButtons()
end

local function toggleSingleMode(modeName)
	local newState = not modes[modeName]

	disableAllModesExcept(modeName)

	modes[modeName] = newState
	refreshAllButtons()

	if modes[modeName] then
		startLoop()
	else
		stopLoopIfNeeded()
	end
end

--============================================================
--  33. TAB SWITCHING
--============================================================

local function showTab(name)
	currentTab = name

	for pageName, page in pairs(pages) do
		page.Visible = pageName == name
	end

	tabW1.BackgroundColor3 = name == "W1" and Color3.fromRGB(40, 150, 65) or Color3.fromRGB(45, 60, 45)
	tabW2.BackgroundColor3 = name == "W2" and Color3.fromRGB(40, 150, 65) or Color3.fromRGB(45, 60, 45)
	tabExtra.BackgroundColor3 = name == "Extra" and Color3.fromRGB(40, 150, 65) or Color3.fromRGB(45, 60, 45)

	tabW1.TextColor3 = Color3.fromRGB(235, 255, 235)
	tabW2.TextColor3 = Color3.fromRGB(235, 255, 235)
	tabExtra.TextColor3 = Color3.fromRGB(235, 255, 235)

	setFrameHeight(name)
end

tabW1.MouseButton1Click:Connect(function()
	showTab("W1")
end)

tabW2.MouseButton1Click:Connect(function()
	showTab("W2")
end)

tabExtra.MouseButton1Click:Connect(function()
	showTab("Extra")
end)

--============================================================
--  34. COLLECTOR BUTTON CLICKS
--============================================================

w1TpGrass.MouseButton1Click:Connect(function()
	toggleSingleMode("w1TpGrass")
end)

w1GrassWalk.MouseButton1Click:Connect(function()
	toggleSingleMode("w1GrassWalk")
end)

w2TpGrass.MouseButton1Click:Connect(function()
	toggleSingleMode("w2TpGrass")
end)

w2GrassWalk.MouseButton1Click:Connect(function()
	toggleSingleMode("w2GrassWalk")
end)

w2Desert.MouseButton1Click:Connect(function()
	toggleSingleMode("w2Desert")
end)

w2IntersectionWalk.MouseButton1Click:Connect(function()
	toggleSingleMode("w2IntersectionWalk")
end)

--============================================================
--  35. EXTRA BUTTON CLICKS
--============================================================

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

--============================================================
--  36. CLOSE BUTTON
--============================================================

close.MouseButton1Click:Connect(function()
	hardStop()

	for k in pairs(modes) do
		modes[k] = false
	end

	gui:Destroy()
end)

--============================================================
--  37. DRAGGING
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
--  38. MINIMIZE BUBBLE
--============================================================

local bubble = Instance.new("TextButton")
bubble.Size = UDim2.fromOffset(52, 52)
bubble.Position = bubblePos
bubble.BackgroundColor3 = Color3.fromRGB(15, 35, 22)
bubble.Text = "🌱"
bubble.Font = Enum.Font.GothamBold
bubble.TextSize = 24
bubble.TextColor3 = Color3.fromRGB(220, 255, 225)
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
	showTab(currentTab)
end)

--============================================================
--  39. STARTUP
--============================================================

refreshAllButtons()
showTab("W1")

print("Grass Collector Tabs Loaded")
