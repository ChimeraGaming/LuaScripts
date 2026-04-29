--============================================================
-- Grass Collector
-- Grass Cutting Incremental
-- Credit | Chimera__Gaming
-- FREE AT RSCRIPTS
--============================================================

--============================================================
-- 01. SERVICES
--============================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("GrassCollector")
if old then old:Destroy() end

--============================================================
-- 02. SETTINGS
--============================================================

local TP_RANGE = 150
local DESERT_RANGE = 850

local WALK_RANGE = 850
local WALK_SPEED = 50
local WALK_RECHECK_DELAY = 0

local BATCH_SIZE = 120
local TOUCHES_PER_PART = 1

--============================================================
-- 03. STATE
--============================================================

local tpEnabled = false
local desertEnabled = false
local walkEnabled = false

local connection = nil
local running = false

local walkConnection = nil
local walkTarget = nil
local originalWalkSpeed = nil
local lastWalkSearch = 0

local cache = {}
local index = 1

local savedPos = UDim2.fromOffset(120, 120)
local bubblePos = UDim2.fromOffset(120, 120)

--============================================================
-- 04. CHARACTER HELPERS
--============================================================

local function getChar()
	return Player.Character
end

local function getRoot()
	local char = getChar()
	if not char then return nil end

	return char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
end

local function getHumanoid()
	local char = getChar()
	if not char then return nil end

	return char:FindFirstChildOfClass("Humanoid")
end

local function forceJump()
	local hum = getHumanoid()

	if hum then
		hum.Jump = true
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end

--============================================================
-- 05. CACHE HELPERS
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

local function isInsideSquare(part, root, range)
	local dx = math.abs(part.Position.X - root.Position.X)
	local dz = math.abs(part.Position.Z - root.Position.Z)
	local half = range / 2

	return dx <= half and dz <= half
end

local function findNearestG(range)
	local root = getRoot()
	if not root then return nil end

	local folder = Workspace:FindFirstChild("GrassObjects")
	if not folder then return nil end

	local closest = nil
	local closestDist = math.huge

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") and part.Name == "g" and part.Parent then
			if isInsideSquare(part, root, range) then
				local dist = (part.Position - root.Position).Magnitude

				if dist < closestDist then
					closestDist = dist
					closest = part
				end
			end
		end
	end

	return closest
end

--============================================================
-- 06. TOUCH / TELEPORT COLLECTOR
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
	local originalCF = root.CFrame

	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = CFrame.new(
			part.Position.X,
			originalCF.Position.Y,
			part.Position.Z
		)
	end)

	for i = 1, TOUCHES_PER_PART do
		touch(part, root)
	end

	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = originalCF
	end)
end

local function processTeleport(range, modeCheck)
	local root = getRoot()
	if not root or type(firetouchinterest) ~= "function" then return end

	if #cache == 0 then
		rebuildCache()
	end

	for i = 1, BATCH_SIZE do
		if not modeCheck() then break end

		if index > #cache then
			index = 1
			rebuildCache()
		end

		local part = cache[index]
		index += 1

		if part and part.Parent and part:IsA("BasePart") and part.Name == "g" then
			if isInsideSquare(part, root, range) then
				teleportToPart(part, root)
			end
		end
	end
end

local function collectBatch()
	if running then return end
	running = true

	if tpEnabled then
		processTeleport(TP_RANGE, function()
			return tpEnabled
		end)
	end

	if desertEnabled then
		processTeleport(DESERT_RANGE, function()
			return desertEnabled
		end)
	end

	running = false
end

local function shouldRun()
	return tpEnabled or desertEnabled
end

local function startLoop()
	if connection then return end
	rebuildCache()

	connection = RunService.Heartbeat:Connect(function()
		if shouldRun() then
			collectBatch()
		end
	end)
end

local function stopLoopIfNeeded()
	if shouldRun() then return end

	if connection then
		connection:Disconnect()
		connection = nil
	end

	running = false
end

--============================================================
-- 07. WALK COLLECTOR
--============================================================

local function startWalk()
	if walkConnection then return end

	local hum = getHumanoid()
	if hum then
		originalWalkSpeed = originalWalkSpeed or hum.WalkSpeed
		hum.WalkSpeed = WALK_SPEED
		hum.AutoRotate = true
	end

	walkConnection = RunService.Heartbeat:Connect(function()
		if not walkEnabled then return end

		local humNow = getHumanoid()
		local root = getRoot()

		if not humNow or not root then return end

		humNow.WalkSpeed = WALK_SPEED
		humNow.AutoRotate = true

		if not walkTarget or not walkTarget.Parent then
			walkTarget = findNearestG(WALK_RANGE)
		end

		if not walkTarget or not walkTarget.Parent then
			return
		end

		if not isInsideSquare(walkTarget, root, WALK_RANGE) then
			walkTarget = nil
			return
		end

		local targetPos = Vector3.new(
			walkTarget.Position.X,
			root.Position.Y,
			walkTarget.Position.Z
		)

		local distance = (targetPos - root.Position).Magnitude

		if distance <= 5 then
			touch(walkTarget, root)
			walkTarget = nil
			return
		end

		humNow:MoveTo(targetPos)
	end)
end

local function stopWalk()
	walkEnabled = false
	walkTarget = nil
	lastWalkSearch = 0

	if walkConnection then
		walkConnection:Disconnect()
		walkConnection = nil
	end

	local hum = getHumanoid()
	local root = getRoot()

	if hum and root then
		hum:MoveTo(root.Position)

		if originalWalkSpeed then
			hum.WalkSpeed = originalWalkSpeed
		end
	end
end

--============================================================
-- 08. UI HELPERS
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
-- 09. MAIN UI
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "GrassCollector"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(320, 410)
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
title.Text = "Grass Cutting Incremental"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(220, 255, 225)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(26, 26)
minimize.Position = UDim2.new(1, -66, 0, 10)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 18
minimize.BackgroundColor3 = Color3.fromRGB(35, 75, 45)
minimize.TextColor3 = Color3.fromRGB(180, 255, 190)
minimize.Parent = frame
corner(minimize, 8)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(26, 26)
close.Position = UDim2.new(1, -34, 0, 10)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.BackgroundColor3 = Color3.fromRGB(80, 25, 25)
close.TextColor3 = Color3.fromRGB(255, 150, 150)
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
divider1.BackgroundColor3 = Color3.fromRGB(70, 180, 95)
divider1.BorderSizePixel = 0
divider1.Parent = frame

--============================================================
-- 10. BUTTONS
--============================================================

local tpButton = Instance.new("TextButton")
tpButton.Size = UDim2.fromOffset(270, 38)
tpButton.Position = UDim2.fromOffset(25, 70)
tpButton.Text = "TP Off"
tpButton.BackgroundColor3 = Color3.fromRGB(75, 65, 35)
tpButton.TextColor3 = Color3.fromRGB(235, 235, 235)
tpButton.Font = Enum.Font.GothamBold
tpButton.TextSize = 16
tpButton.Parent = frame
corner(tpButton, 10)

local desertButton = Instance.new("TextButton")
desertButton.Size = UDim2.fromOffset(270, 38)
desertButton.Position = UDim2.fromOffset(25, 116)
desertButton.Text = "Desert Off"
desertButton.BackgroundColor3 = Color3.fromRGB(55, 70, 55)
desertButton.TextColor3 = Color3.fromRGB(235, 235, 235)
desertButton.Font = Enum.Font.GothamBold
desertButton.TextSize = 16
desertButton.Parent = frame
corner(desertButton, 10)

local walkButton = Instance.new("TextButton")
walkButton.Size = UDim2.fromOffset(270, 38)
walkButton.Position = UDim2.fromOffset(25, 164)
walkButton.Text = "Ghost Walk Off"
walkButton.BackgroundColor3 = Color3.fromRGB(45, 55, 65)
walkButton.TextColor3 = Color3.fromRGB(235, 235, 235)
walkButton.Font = Enum.Font.GothamBold
walkButton.TextSize = 16
walkButton.Parent = frame
corner(walkButton, 10)

local ghostWalkNote = Instance.new("TextLabel")
ghostWalkNote.Size = UDim2.fromOffset(270, 30)
ghostWalkNote.Position = UDim2.fromOffset(25, 205)
ghostWalkNote.BackgroundTransparency = 1
ghostWalkNote.Text = "> Player might walk then stop, it is now ghost walking"
ghostWalkNote.TextColor3 = Color3.fromRGB(190, 220, 240)
ghostWalkNote.Font = Enum.Font.Gotham
ghostWalkNote.TextSize = 11
ghostWalkNote.TextWrapped = true
ghostWalkNote.TextXAlignment = Enum.TextXAlignment.Left
ghostWalkNote.Parent = frame

local github = Instance.new("TextButton")
github.Size = UDim2.fromOffset(270, 30)
github.Position = UDim2.fromOffset(25, 242)
github.Text = "GitHub | ChimeraGaming LuaScripts"
github.BackgroundColor3 = Color3.fromRGB(25, 45, 32)
github.TextColor3 = Color3.fromRGB(175, 220, 180)
github.Font = Enum.Font.GothamBold
github.TextSize = 12
github.Parent = frame
corner(github, 8)

local iy = Instance.new("TextButton")
iy.Size = UDim2.fromOffset(270, 30)
iy.Position = UDim2.fromOffset(25, 280)
iy.Text = "Load Infinite Yield"
iy.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
iy.TextColor3 = Color3.fromRGB(220, 220, 255)
iy.Font = Enum.Font.GothamBold
iy.TextSize = 12
iy.Parent = frame
corner(iy, 8)

local iyNote = Instance.new("TextLabel")
iyNote.Size = UDim2.fromOffset(270, 24)
iyNote.Position = UDim2.fromOffset(25, 316)
iyNote.BackgroundTransparency = 1
iyNote.Text = "> Enable AntiAFK for best results"
iyNote.TextColor3 = Color3.fromRGB(200, 200, 255)
iyNote.Font = Enum.Font.Gotham
iyNote.TextSize = 11
iyNote.TextWrapped = true
iyNote.Parent = frame

local popup = Instance.new("TextLabel")
popup.Size = UDim2.fromOffset(270, 26)
popup.Position = UDim2.fromOffset(25, 342)
popup.BackgroundColor3 = Color3.fromRGB(35, 75, 45)
popup.Text = "Copied to clipboard"
popup.TextColor3 = Color3.fromRGB(220, 255, 225)
popup.Font = Enum.Font.GothamBold
popup.TextSize = 12
popup.Visible = false
popup.Parent = frame
corner(popup, 8)

local divider2 = Instance.new("Frame")
divider2.Size = UDim2.new(1, -30, 0, 1)
divider2.Position = UDim2.fromOffset(15, 372)
divider2.BackgroundColor3 = Color3.fromRGB(70, 180, 95)
divider2.BorderSizePixel = 0
divider2.Parent = frame

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -20, 0, 34)
credit.Position = UDim2.fromOffset(10, 378)
credit.BackgroundTransparency = 1
credit.Text = "Credit | Chimera__Gaming\nFREE AT RSCRIPTS"
credit.Font = Enum.Font.Gotham
credit.TextSize = 11
credit.TextColor3 = Color3.fromRGB(175, 220, 180)
credit.TextWrapped = true
credit.Parent = frame

--============================================================
-- 11. BUTTON LOGIC
--============================================================

local function disableOtherModes(activeMode)
	if activeMode ~= "tp" then
		tpEnabled = false
		tpButton.Text = "TP Off"
		tpButton.BackgroundColor3 = Color3.fromRGB(75, 65, 35)
	end

	if activeMode ~= "desert" then
		desertEnabled = false
		desertButton.Text = "Desert Off"
		desertButton.BackgroundColor3 = Color3.fromRGB(55, 70, 55)
	end

	if activeMode ~= "walk" then
		if walkEnabled then
			stopWalk()
		end

		walkEnabled = false
		walkButton.Text = "Ghost Walk Off"
		walkButton.BackgroundColor3 = Color3.fromRGB(45, 55, 65)
	end

	stopLoopIfNeeded()
end

tpButton.MouseButton1Click:Connect(function()
	local newState = not tpEnabled

	disableOtherModes("tp")

	tpEnabled = newState
	tpButton.Text = tpEnabled and "TP On" or "TP Off"
	tpButton.BackgroundColor3 = tpEnabled and Color3.fromRGB(150, 120, 40) or Color3.fromRGB(75, 65, 35)

	if tpEnabled then
		startLoop()
	else
		stopLoopIfNeeded()
	end
end)

desertButton.MouseButton1Click:Connect(function()
	local wasOn = desertEnabled
	local newState = not desertEnabled

	disableOtherModes("desert")

	desertEnabled = newState
	desertButton.Text = desertEnabled and "Desert On" or "Desert Off"
	desertButton.BackgroundColor3 = desertEnabled and Color3.fromRGB(40, 150, 65) or Color3.fromRGB(55, 70, 55)

	if desertEnabled then
		startLoop()
	else
		stopLoopIfNeeded()

		if wasOn then
			forceJump()
		end
	end
end)

walkButton.MouseButton1Click:Connect(function()
	local newState = not walkEnabled

	disableOtherModes("walk")

	walkEnabled = newState
	walkButton.Text = walkEnabled and "Ghost Walk On" or "Ghost Walk Off"
	walkButton.BackgroundColor3 = walkEnabled and Color3.fromRGB(55, 120, 180) or Color3.fromRGB(45, 55, 65)

	if walkEnabled then
		startWalk()
	else
		stopWalk()
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
	tpEnabled = false
	desertEnabled = false
	walkEnabled = false

	stopLoopIfNeeded()
	stopWalk()

	if connection then
		connection:Disconnect()
		connection = nil
	end

	gui:Destroy()
end)

--============================================================
-- 12. DRAG LOGIC
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
		if dragging then savedPos = frame.Position end
		dragging = false
	end
end)

--============================================================
-- 13. MINIMIZE BUBBLE
--============================================================

local bubble = Instance.new("TextButton")
bubble.Size = UDim2.fromOffset(52, 52)
bubble.Position = bubblePos
bubble.BackgroundColor3 = Color3.fromRGB(15, 35, 22)
bubble.Text = "G"
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
end)

--============================================================
-- 14. LOADED
--============================================================

print("Grass Collector Simplified Loaded")
