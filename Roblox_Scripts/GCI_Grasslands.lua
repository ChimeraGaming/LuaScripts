--============================================================
-- Grassland Fighting UI
-- Closest Enemy Pathfinding + Teleport + Fly Fallback
-- Auto Leave Dungeon Countdown
--============================================================

--============================================================
-- 01. SERVICES
--============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

--============================================================
-- 02. PLAYER + SETTINGS
--============================================================

local player = Players.LocalPlayer

local running = false
local autoMaster = false
local flySpeed = 200
local walkSpeed = 200
local flying = false
local savedShops = {}
local inMoveCycle = false
local noclipConnection = nil
local currentMastery = nil
local lastMasterClick = 0

local TELEPORT_DISTANCE = 1000
local NO_ENEMY_LEAVE_SECONDS = 10

local noEnemyCountdownActive = false
local noEnemyCountdownStart = 0

--============================================================
-- 03. ACTIVE GAME FOLDER
--============================================================

local activeFolder = workspace
	:WaitForChild("Building")
	:WaitForChild("Structures")
	:WaitForChild("GG")
	:WaitForChild("Active")

--============================================================
-- 04. ROOT GUI
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "GrasslandFightingGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 310, 0, 520)
frame.Position = UDim2.new(0.35, 0, 0.30, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 22, 18)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(80, 180, 95)
frameStroke.Thickness = 2
frameStroke.Parent = frame

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 10)
padding.Parent = frame

--============================================================
-- 05. HEADER
--============================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -42, 0, 32)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Grassland Fighting"
title.TextColor3 = Color3.fromRGB(220, 255, 220)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -42, 0, 18)
subtitle.Position = UDim2.new(0, 0, 0, 28)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Closest enemy pathfinder"
subtitle.TextColor3 = Color3.fromRGB(150, 190, 150)
subtitle.TextSize = 11
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -30, 0, 0)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = close

--============================================================
-- 06. UI HELPERS
--============================================================

local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = instance
	return corner
end

local function addStroke(instance, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(60, 90, 60)
	stroke.Thickness = thickness or 1
	stroke.Parent = instance
	return stroke
end

local function makeButton(text, y, height, color)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, height or 38)
	button.Position = UDim2.new(0, 0, 0, y)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.BackgroundColor3 = color or Color3.fromRGB(45, 90, 55)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.AutoButtonColor = true
	button.Parent = frame

	addCorner(button, 9)
	addStroke(button, Color3.fromRGB(90, 130, 90), 1)

	return button
end

local function makeLabel(text, y, size, color)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, size or 22)
	label.Position = UDim2.new(0, 0, 0, y)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or Color3.fromRGB(230, 240, 230)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	return label
end

--============================================================
-- 07. MAIN CONTROLS
--============================================================

local toggle = makeButton("Start Combat: OFF", 58, 42, Color3.fromRGB(120, 45, 45))

local enemyCountLabel = makeLabel("Enemies Remaining: 0", 108, 22)
local pathStatusLabel = makeLabel("Path: Idle", 132, 42, Color3.fromRGB(190, 220, 190))
pathStatusLabel.TextWrapped = true
pathStatusLabel.TextYAlignment = Enum.TextYAlignment.Top

local speedLabel = makeLabel("Walk/Fly Speed: 200", 178, 22, Color3.fromRGB(190, 220, 190))

local autoMasterButton = makeButton("Auto Master Room: OFF", 210, 36, Color3.fromRGB(120, 45, 45))

local masterNote = Instance.new("TextLabel")
masterNote.Size = UDim2.new(1, 0, 0, 44)
masterNote.Position = UDim2.new(0, 0, 0, 252)
masterNote.BackgroundColor3 = Color3.fromRGB(28, 34, 28)
masterNote.Text = "Note: Keep Auto Master OFF if you want to duplicate rooms. Use ON only when farming crystal and gold."
masterNote.TextColor3 = Color3.fromRGB(210, 225, 210)
masterNote.Font = Enum.Font.Gotham
masterNote.TextSize = 11
masterNote.TextWrapped = true
masterNote.TextXAlignment = Enum.TextXAlignment.Left
masterNote.TextYAlignment = Enum.TextYAlignment.Center
masterNote.Parent = frame

addCorner(masterNote, 8)
addStroke(masterNote, Color3.fromRGB(55, 80, 55), 1)

local masteryStatus = makeLabel("Master Room: Not Found", 304, 22)

local duplicateMasterButton = makeButton("Duplicate Master", 332, 36, Color3.fromRGB(55, 70, 55))
local listShops = makeButton("List Shops", 376, 36, Color3.fromRGB(45, 85, 140))
local clearShops = makeButton("Clear Shops", 418, 32, Color3.fromRGB(125, 45, 45))

--============================================================
-- 08. SHOP LIST
--============================================================

local shopList = Instance.new("ScrollingFrame")
shopList.Size = UDim2.new(1, 0, 1, -460)
shopList.Position = UDim2.new(0, 0, 0, 456)
shopList.BackgroundColor3 = Color3.fromRGB(25, 30, 25)
shopList.BorderSizePixel = 0
shopList.ScrollBarThickness = 6
shopList.CanvasSize = UDim2.new(0, 0, 0, 0)
shopList.Parent = frame

addCorner(shopList, 8)
addStroke(shopList, Color3.fromRGB(55, 80, 55), 1)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = shopList

local shopPadding = Instance.new("UIPadding")
shopPadding.PaddingLeft = UDim.new(0, 6)
shopPadding.PaddingRight = UDim.new(0, 6)
shopPadding.PaddingTop = UDim.new(0, 6)
shopPadding.PaddingBottom = UDim.new(0, 6)
shopPadding.Parent = shopList

--============================================================
-- 09. CHARACTER HELPERS
--============================================================

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function getRoot()
	return getCharacter():FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	return getCharacter():FindFirstChildOfClass("Humanoid")
end

local function applyWalkSpeed()
	local humanoid = getHumanoid()

	if humanoid then
		humanoid.WalkSpeed = walkSpeed
	end
end

local function teleportTo(part)
	local root = getRoot()

	if root and part and part:IsA("BasePart") then
		root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	end
end

--============================================================
-- 10. ENEMY HELPERS
--============================================================

local function countEnemies()
	local count = 0

	for _, descendant in ipairs(activeFolder:GetDescendants()) do
		if descendant.Name == "Enemy" then
			local startCombat = descendant:FindFirstChild("StartCombat")

			if startCombat and startCombat:IsA("BasePart") then
				count += 1
			end
		end
	end

	return count
end

local function updateEnemyCount()
	enemyCountLabel.Text = "Enemies Remaining: " .. tostring(countEnemies())
end

local function getClosestEnemy()
	local root = getRoot()
	if not root then return nil, nil end

	local closestPart = nil
	local closestDistance = math.huge

	for _, descendant in ipairs(activeFolder:GetDescendants()) do
		if descendant.Name == "Enemy" then
			local startCombat = descendant:FindFirstChild("StartCombat")

			if startCombat and startCombat:IsA("BasePart") then
				local distance = (root.Position - startCombat.Position).Magnitude

				if distance < closestDistance then
					closestDistance = distance
					closestPart = startCombat
				end
			end
		end
	end

	return closestPart, closestDistance
end

--============================================================
-- 11. LEAVE DUNGEON HELPER
--============================================================

local function clickLeaveDungeon()
	local ok, button = pcall(function()
		return player
			:WaitForChild("PlayerGui")
			:WaitForChild("MobileUI")
			:WaitForChild("Minigame")
			:WaitForChild("Dungeon")
			:WaitForChild("Misc")
			:WaitForChild("Leave")
			:WaitForChild("LeaveDungeon")
	end)

	if ok and button then
		pcall(function()
			button:Activate()
		end)

		pcall(function()
			if firesignal then
				firesignal(button.MouseButton1Click)
			end
		end)

		pcall(function()
			if firesignal then
				firesignal(button.Activated)
			end
		end)

		pathStatusLabel.Text = "Path: Leave Dungeon clicked"
		return true
	end

	pathStatusLabel.Text = "Path: Leave Dungeon not found"
	return false
end

--============================================================
-- 12. MASTERY ROOM HELPERS
--============================================================

local function findMasteryRoom()
	for _, descendant in ipairs(activeFolder:GetDescendants()) do
		if descendant.Name == "Mastery" then
			local context = descendant:FindFirstChild("InteractableContext")

			if context then
				local clickDetector = context:FindFirstChildOfClass("ClickDetector") or context:FindFirstChild("ClickDetector")
				local click = context:FindFirstChild("Click")

				if clickDetector or click then
					return descendant
				end
			end
		end
	end

	return nil
end

local function clickMasteryRoom(masteryRoom)
	if not masteryRoom then
		return false
	end

	local context = masteryRoom:FindFirstChild("InteractableContext")
	if not context then
		return false
	end

	local clickDetector = context:FindFirstChildOfClass("ClickDetector") or context:FindFirstChild("ClickDetector")
	local prompt = context:FindFirstChildOfClass("ProximityPrompt")

	if clickDetector and fireclickdetector then
		fireclickdetector(clickDetector)
		return true
	end

	if prompt and fireproximityprompt then
		fireproximityprompt(prompt)
		return true
	end

	return false
end

local function updateMasteryStatus()
	currentMastery = findMasteryRoom()

	if currentMastery then
		masteryStatus.Text = "Master Room: Found"
		duplicateMasterButton.BackgroundColor3 = Color3.fromRGB(45, 95, 145)
	else
		masteryStatus.Text = "Master Room: Not Found"
		duplicateMasterButton.BackgroundColor3 = Color3.fromRGB(55, 70, 55)
	end
end

--============================================================
-- 13. NOCLIP + FLY FALLBACK
--============================================================

local function setNoclip(state)
	if noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
	end

	if state then
		noclipConnection = RunService.Stepped:Connect(function()
			local character = player.Character
			if not character then return end

			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	end
end

local function stopFlyAndNoclip()
	flying = false
	setNoclip(false)

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if root then
		root.Anchored = false
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end

	if humanoid then
		humanoid.PlatformStand = false
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		humanoid.WalkSpeed = walkSpeed
	end

	if not noEnemyCountdownActive then
		pathStatusLabel.Text = "Path: Idle"
	end
end

local function flyTo(part)
	local root = getRoot()
	local humanoid = getHumanoid()

	if not root or not humanoid or not part or not part:IsA("BasePart") then
		return
	end

	pathStatusLabel.Text = "Path: Fly Fallback"

	flying = true
	setNoclip(true)

	humanoid.PlatformStand = true
	root.Anchored = false

	local targetPosition = part.Position + Vector3.new(0, 4, 0)

	while running and flying and root.Parent and part.Parent do
		local currentPosition = root.Position
		local direction = targetPosition - currentPosition
		local distance = direction.Magnitude

		if distance <= 5 then
			root.CFrame = CFrame.new(targetPosition)
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			break
		end

		local delta = task.wait()

		root.CFrame = CFrame.new(
			currentPosition + direction.Unit * flySpeed * delta,
			targetPosition
		)

		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end
end

--============================================================
-- 14. PATHFINDING
--============================================================

local function pathfindTo(part)
	local root = getRoot()
	local humanoid = getHumanoid()

	if not root or not humanoid or not part or not part:IsA("BasePart") then
		return false
	end

	stopFlyAndNoclip()
	applyWalkSpeed()

	pathStatusLabel.Text = "Path: Calculating"

	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = true,
		WaypointSpacing = 4
	})

	local success = pcall(function()
		path:ComputeAsync(root.Position, part.Position)
	end)

	if not success or path.Status ~= Enum.PathStatus.Success then
		pathStatusLabel.Text = "Path: Failed"
		return false
	end

	pathStatusLabel.Text = "Path: Moving"

	for _, waypoint in ipairs(path:GetWaypoints()) do
		if not running then
			return false
		end

		if not part.Parent then
			pathStatusLabel.Text = "Path: Target Gone"
			return true
		end

		root = getRoot()
		humanoid = getHumanoid()

		if not root or not humanoid then
			return false
		end

		humanoid.WalkSpeed = walkSpeed

		if (root.Position - part.Position).Magnitude <= 6 then
			pathStatusLabel.Text = "Path: Reached"
			return true
		end

		if waypoint.Action == Enum.PathWaypointAction.Jump then
			humanoid.Jump = true
		end

		humanoid:MoveTo(waypoint.Position)

		local reached = false
		local finished = false
		local connection

		connection = humanoid.MoveToFinished:Connect(function(result)
			reached = result
			finished = true

			if connection then
				connection:Disconnect()
			end
		end)

		local startTime = os.clock()

		while running and not finished and os.clock() - startTime < 3 do
			task.wait(0.05)

			if not part.Parent then
				if connection then
					connection:Disconnect()
				end

				pathStatusLabel.Text = "Path: Target Gone"
				return true
			end

			root = getRoot()

			if root and (root.Position - part.Position).Magnitude <= 6 then
				if connection then
					connection:Disconnect()
				end

				pathStatusLabel.Text = "Path: Reached"
				return true
			end
		end

		if connection then
			connection:Disconnect()
		end

		if not reached then
			pathStatusLabel.Text = "Path: Stuck"
			return false
		end
	end

	pathStatusLabel.Text = "Path: Complete"
	return true
end

--============================================================
-- 15. COMBAT MOVEMENT
--============================================================

local function moveToStartCombat()
	if inMoveCycle then
		return
	end

	inMoveCycle = true

	local ok, err = pcall(function()
		local target, distance = getClosestEnemy()

		if running and target then
			noEnemyCountdownActive = false
			noEnemyCountdownStart = 0

			if distance and distance >= TELEPORT_DISTANCE then
				pathStatusLabel.Text = "Path: Teleport"

				stopFlyAndNoclip()
				teleportTo(target)

				task.wait(0.25)
			else
				pathStatusLabel.Text = "Path: Closest Enemy"

				local success = pathfindTo(target)

				if running and not success and target and target.Parent then
					flyTo(target)
				end
			end
		else
			if not noEnemyCountdownActive then
				pathStatusLabel.Text = "Path: No enemies detected"
			end
		end
	end)

	if not ok then
		pathStatusLabel.Text = "Path: Error"
		warn("Move cycle error:", err)
	end

	inMoveCycle = false
end

--============================================================
-- 16. SHOP HELPERS
--============================================================

local function shopAlreadySaved(anchor)
	for _, data in ipairs(savedShops) do
		if data.Anchor == anchor then
			return true
		end
	end

	return false
end

local function refreshShopButtons()
	for _, child in ipairs(shopList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for index, data in ipairs(savedShops) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, -4, 0, 32)
		button.Text = "Shop " .. index
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.BackgroundColor3 = Color3.fromRGB(45, 60, 45)
		button.Font = Enum.Font.GothamBold
		button.TextSize = 13
		button.LayoutOrder = index
		button.Parent = shopList

		addCorner(button, 7)
		addStroke(button, Color3.fromRGB(70, 100, 70), 1)

		button.MouseButton1Click:Connect(function()
			if data.Anchor and data.Anchor.Parent then
				teleportTo(data.Anchor)
			else
				button.Text = "Shop " .. index .. " missing"
				button.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
			end
		end)
	end

	shopList.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 14)
end

local function scanForShops()
	local newCount = 0

	for _, descendant in ipairs(activeFolder:GetDescendants()) do
		if descendant.Name == "Shop" then
			local anchor = descendant:FindFirstChild("Anchor")

			if anchor and anchor:IsA("BasePart") and not shopAlreadySaved(anchor) then
				table.insert(savedShops, {
					Shop = descendant,
					Anchor = anchor
				})

				newCount += 1
			end
		end
	end

	refreshShopButtons()

	if newCount > 0 then
		listShops.Text = "List Shops +" .. newCount
	else
		listShops.Text = "List Shops No New"
	end

	task.wait(1)

	if listShops and listShops.Parent then
		listShops.Text = "List Shops"
	end
end

local function clearAllShops()
	table.clear(savedShops)

	for _, child in ipairs(shopList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	shopList.CanvasSize = UDim2.new(0, 0, 0, 0)

	clearShops.Text = "Shops Cleared"

	task.wait(1)

	if clearShops and clearShops.Parent then
		clearShops.Text = "Clear Shops"
	end
end

--============================================================
-- 17. BUTTON EVENTS
--============================================================

toggle.MouseButton1Click:Connect(function()
	running = not running

	if running then
		inMoveCycle = false
		flying = false
		noEnemyCountdownActive = false
		noEnemyCountdownStart = 0

		toggle.Text = "Start Combat: ON"
		toggle.BackgroundColor3 = Color3.fromRGB(35, 140, 60)

		applyWalkSpeed()
	else
		running = false
		inMoveCycle = false
		flying = false
		noEnemyCountdownActive = false
		noEnemyCountdownStart = 0

		toggle.Text = "Start Combat: OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(120, 45, 45)

		stopFlyAndNoclip()
	end
end)

autoMasterButton.MouseButton1Click:Connect(function()
	autoMaster = not autoMaster

	if autoMaster then
		autoMasterButton.Text = "Auto Master Room: ON"
		autoMasterButton.BackgroundColor3 = Color3.fromRGB(35, 140, 60)
	else
		autoMasterButton.Text = "Auto Master Room: OFF"
		autoMasterButton.BackgroundColor3 = Color3.fromRGB(120, 45, 45)
	end
end)

duplicateMasterButton.MouseButton1Click:Connect(function()
	updateMasteryStatus()

	if currentMastery then
		local clicked = clickMasteryRoom(currentMastery)

		if clicked then
			duplicateMasterButton.Text = "Duplicate Clicked"
		else
			duplicateMasterButton.Text = "Click Failed"
		end

		task.wait(1)

		if duplicateMasterButton and duplicateMasterButton.Parent then
			duplicateMasterButton.Text = "Duplicate Master"
		end
	end
end)

listShops.MouseButton1Click:Connect(scanForShops)
clearShops.MouseButton1Click:Connect(clearAllShops)

close.MouseButton1Click:Connect(function()
	running = false
	autoMaster = false
	inMoveCycle = false
	flying = false
	noEnemyCountdownActive = false
	noEnemyCountdownStart = 0

	stopFlyAndNoclip()
	gui:Destroy()
end)

--============================================================
-- 18. CHARACTER RESET HANDLER
--============================================================

player.CharacterAdded:Connect(function()
	task.wait(1)

	if running then
		applyWalkSpeed()
	end

	inMoveCycle = false
	flying = false
end)

--============================================================
-- 19. STATUS LOOP
--============================================================

task.spawn(function()
	while gui.Parent do
		updateEnemyCount()
		updateMasteryStatus()

		if autoMaster and currentMastery and os.clock() - lastMasterClick >= 2 then
			lastMasterClick = os.clock()
			clickMasteryRoom(currentMastery)
		end

		task.wait(1)
	end
end)

--============================================================
-- 20. COMBAT LOOP
--============================================================

task.spawn(function()
	while gui.Parent do
		if running then
			applyWalkSpeed()
			moveToStartCombat()
		end

		task.wait(0.1)
	end
end)

--============================================================
-- 21. NO ENEMY LEAVE COUNTDOWN LOOP
--============================================================

task.spawn(function()
	while gui.Parent do
		if running then
			local enemyCount = countEnemies()

			if enemyCount <= 0 then
				if not noEnemyCountdownActive then
					noEnemyCountdownActive = true
					noEnemyCountdownStart = os.clock()
				end

				local elapsed = math.floor(os.clock() - noEnemyCountdownStart)
				local remaining = NO_ENEMY_LEAVE_SECONDS - elapsed

				if remaining > 0 then
					pathStatusLabel.Text = "Path: No enemies detected. Leaving dungeon in " .. tostring(remaining) .. "..."
				else
					pathStatusLabel.Text = "Path: Leaving dungeon"

					running = false
					inMoveCycle = false
					flying = false
					noEnemyCountdownActive = false
					noEnemyCountdownStart = 0

					toggle.Text = "Start Combat: OFF"
					toggle.BackgroundColor3 = Color3.fromRGB(120, 45, 45)

					stopFlyAndNoclip()
					clickLeaveDungeon()
				end
			else
				noEnemyCountdownActive = false
				noEnemyCountdownStart = 0
			end
		else
			noEnemyCountdownActive = false
			noEnemyCountdownStart = 0
		end

		task.wait(1)
	end
end)
