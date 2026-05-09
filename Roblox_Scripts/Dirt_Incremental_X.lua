--============================================================
-- Dirt Incremental Collector
-- Touch Radius + Auto ClearDirtServer Fix
-- Beta | Credit: ChimeraGaming
--============================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("DirtIncrementalCollector")
if old then old:Destroy() end

local Spawning = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Spawning")
local ClearDirtServer = Spawning:FindFirstChild("ClearDirtServer")

local ENABLED = false
local connection = nil
local FIXING = false

local RADIUS = 45
local LOOP_DELAY = 0.06
local TOUCH_DELAY = 0.012
local STUCK_FIX_DELAY = 1.25
local REFILL_WAIT = 0.35

local MAX_DIRT_ATTEMPTS = 8
local dirtAttempts = {}

local GITHUB_URL = "https://github.com/ChimeraGaming/LuaScripts"

local lastFix = 0

local dragging = false
local dragStart
local startPos
local dragMoved = false

local minimized = false
local savedNormalPosition = UDim2.fromOffset(120, 120)
local savedMinimizedPosition = UDim2.fromOffset(120, 120)

--============================================================
-- HELPERS
--============================================================

local function getRoot()
	return Workspace:FindFirstChild("ClientDirts")
end

local function getCharacter()
	return Player.Character or Player.CharacterAdded:Wait()
end

local function getHRP()
	local char = getCharacter()
	return char:FindFirstChild("HumanoidRootPart")
end

local function getTouchParts(obj)
	local parts = {}
	local seen = {}

	if not obj or not obj.Parent then
		return parts
	end

	for _, v in ipairs(obj:GetDescendants()) do
		if v:IsA("TouchTransmitter") or v.Name == "TouchInterest" then
			local parent = v.Parent

			if parent and parent:IsA("BasePart") and not seen[parent] then
				seen[parent] = true
				table.insert(parts, parent)
			end
		end
	end

	return parts
end

local function hasTouchInterest(obj)
	return #getTouchParts(obj) > 0
end

local function cleanupAttempts()
	for dirt in pairs(dirtAttempts) do
		if not dirt or not dirt.Parent then
			dirtAttempts[dirt] = nil
		end
	end
end

local function removeNoTouchDirt()
	local root = getRoot()
	if not root then return 0 end

	local removed = 0

	for _, dirt in ipairs(root:GetChildren()) do
		if dirt and dirt.Parent and not hasTouchInterest(dirt) then
			dirt:Destroy()
			removed += 1
		end
	end

	return removed
end

local function forceClear()
	pcall(function()
		if ClearDirtServer then
			ClearDirtServer:FireServer()
		end
	end)

	task.wait(REFILL_WAIT)
end

local function touchRadius()
	local root = getRoot()
	local hrp = getHRP()

	if not root or not hrp then
		return 0
	end

	cleanupAttempts()

	local touched = 0

	for _, dirt in ipairs(root:GetChildren()) do
		if dirt and dirt.Parent then
			local touchParts = getTouchParts(dirt)

			for _, part in ipairs(touchParts) do
				if part and part.Parent and part:IsA("BasePart") then
					local distance = (hrp.Position - part.Position).Magnitude

					if distance <= RADIUS then
						part.CanCollide = false

						dirtAttempts[dirt] = (dirtAttempts[dirt] or 0) + 1

						if dirtAttempts[dirt] >= MAX_DIRT_ATTEMPTS then
							dirtAttempts[dirt] = nil

							forceClear()
							return touched
						end

						if firetouchinterest then
							firetouchinterest(hrp, part, 0)
							task.wait(TOUCH_DELAY)
							firetouchinterest(hrp, part, 1)

							touched += 1
						end
					end
				end
			end
		end
	end

	return touched
end

local function waitForReadyDirt(timeout)
	local startTime = tick()

	while ENABLED and tick() - startTime < timeout do
		local root = getRoot()

		if root then
			for _, dirt in ipairs(root:GetChildren()) do
				if hasTouchInterest(dirt) then
					return true
				end
			end
		end

		task.wait(0.05)
	end

	return false
end

local function fixStuckDirt()
	if FIXING then return end
	if tick() - lastFix < STUCK_FIX_DELAY then return end

	lastFix = tick()
	FIXING = true

	removeNoTouchDirt()

	task.wait(0.1)

	forceClear()

	removeNoTouchDirt()
	waitForReadyDirt(1)

	FIXING = false
end

local function startCollector()
	if connection then return end

	connection = task.spawn(function()
		while ENABLED do
			local ok, err = pcall(function()
				if not FIXING then
					local touched = touchRadius()

					if touched == 0 then
						task.spawn(fixStuckDirt)
					end
				end
			end)

			if not ok then
				warn("Dirt Collector Error:", err)
				FIXING = false
			end

			task.wait(LOOP_DELAY)
		end

		connection = nil
	end)
end

local function stopCollector()
	ENABLED = false
	connection = nil
	FIXING = false
end

--============================================================
-- GUI
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "DirtIncrementalCollector"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260, 250)
frame.Position = savedNormalPosition
frame.BackgroundColor3 = Color3.fromRGB(35, 25, 18)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 32)
title.Position = UDim2.fromOffset(10, 4)
title.BackgroundTransparency = 1
title.Text = "Dirt Radius Collector"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(28, 28)
minimize.Position = UDim2.fromOffset(195, 6)
minimize.Text = "_"
minimize.BackgroundColor3 = Color3.fromRGB(70, 55, 40)
minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 16
minimize.BorderSizePixel = 0
minimize.Parent = frame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimize

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.fromOffset(227, 6)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(120, 35, 35)
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.BorderSizePixel = 0
close.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = close

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -30, 0, 42)
toggle.Position = UDim2.fromOffset(15, 55)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(95, 55, 35)
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.GothamBlack
toggle.TextSize = 18
toggle.BorderSizePixel = 0
toggle.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggle

local note = Instance.new("TextLabel")
note.Size = UDim2.new(1, -30, 0, 76)
note.Position = UDim2.fromOffset(15, 108)
note.BackgroundTransparency = 1
note.TextWrapped = true
note.TextYAlignment = Enum.TextYAlignment.Top
note.Text = "Beta script. Bugs will be present. This will be updated in the future. Best method is still to manually collect.\n\nCredit: ChimeraGaming"
note.TextColor3 = Color3.fromRGB(235, 235, 235)
note.Font = Enum.Font.Gotham
note.TextSize = 11
note.Parent = frame

local githubButton = Instance.new("TextButton")
githubButton.Size = UDim2.new(1, -30, 0, 34)
githubButton.Position = UDim2.fromOffset(15, 185)
githubButton.Text = "FREE AT GITHUB"
githubButton.BackgroundColor3 = Color3.fromRGB(70, 55, 40)
githubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
githubButton.Font = Enum.Font.GothamBlack
githubButton.TextSize = 13
githubButton.BorderSizePixel = 0
githubButton.Parent = frame

local githubCorner = Instance.new("UICorner")
githubCorner.CornerRadius = UDim.new(0, 8)
githubCorner.Parent = githubButton

local linkNote = Instance.new("TextLabel")
linkNote.Size = UDim2.new(1, -30, 0, 18)
linkNote.Position = UDim2.fromOffset(15, 223)
linkNote.BackgroundTransparency = 1
linkNote.Text = GITHUB_URL
linkNote.TextColor3 = Color3.fromRGB(190, 190, 190)
linkNote.Font = Enum.Font.Gotham
linkNote.TextSize = 9
linkNote.TextWrapped = true
linkNote.Parent = frame

local popup = Instance.new("TextLabel")
popup.Size = UDim2.fromOffset(170, 28)
popup.Position = UDim2.fromOffset(45, 150)
popup.BackgroundColor3 = Color3.fromRGB(50, 140, 55)
popup.TextColor3 = Color3.fromRGB(255, 255, 255)
popup.Text = "Copied GitHub link"
popup.Font = Enum.Font.GothamBold
popup.TextSize = 12
popup.Visible = false
popup.BorderSizePixel = 0
popup.Parent = frame

local popupCorner = Instance.new("UICorner")
popupCorner.CornerRadius = UDim.new(0, 8)
popupCorner.Parent = popup

toggle.MouseButton1Click:Connect(function()
	ENABLED = not ENABLED

	if ENABLED then
		toggle.Text = "ON"
		toggle.BackgroundColor3 = Color3.fromRGB(50, 140, 55)
		startCollector()
	else
		toggle.Text = "OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(95, 55, 35)
		stopCollector()
	end
end)

githubButton.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard(GITHUB_URL)

		popup.Text = "Copied GitHub link"
		popup.BackgroundColor3 = Color3.fromRGB(50, 140, 55)
	else
		popup.Text = "Clipboard not supported"
		popup.BackgroundColor3 = Color3.fromRGB(140, 45, 45)
	end

	popup.Visible = true

	task.wait(2)

	popup.Visible = false
end)

close.MouseButton1Click:Connect(function()
	stopCollector()
	gui:Destroy()
end)

--============================================================
-- DRAGGING
--============================================================

local function isInside(obj, pos)
	if not obj or not obj.Visible then
		return false
	end

	local ap = obj.AbsolutePosition
	local as = obj.AbsoluteSize

	return pos.X >= ap.X
		and pos.X <= ap.X + as.X
		and pos.Y >= ap.Y
		and pos.Y <= ap.Y + as.Y
end

local function isNoDrag(pos)
	if minimized then
		return false
	end

	return isInside(toggle, pos)
		or isInside(githubButton, pos)
		or isInside(minimize, pos)
		or isInside(close, pos)
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if isNoDrag(input.Position) then
			return
		end

		dragging = true
		dragMoved = false
		dragStart = input.Position
		startPos = frame.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart

		if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
			dragMoved = true
		end

		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if dragging then
			if minimized then
				savedMinimizedPosition = frame.Position
			else
				savedNormalPosition = frame.Position
			end
		end

		dragging = false
	end
end)

--============================================================
-- MINIMIZE
--============================================================

minimize.MouseButton1Click:Connect(function()
	if dragMoved then
		dragMoved = false
		return
	end

	minimized = not minimized

	if minimized then
		savedNormalPosition = frame.Position

		frame.Size = UDim2.fromOffset(58, 58)
		frame.Position = savedMinimizedPosition

		title.Visible = false
		toggle.Visible = false
		note.Visible = false
		githubButton.Visible = false
		linkNote.Visible = false
		popup.Visible = false
		close.Visible = false

		minimize.Size = UDim2.fromOffset(58, 58)
		minimize.Position = UDim2.fromOffset(0, 0)
		minimize.Text = "D"
		minimize.TextSize = 24
	else
		savedMinimizedPosition = frame.Position

		frame.Size = UDim2.fromOffset(260, 250)
		frame.Position = savedNormalPosition

		title.Visible = true
		toggle.Visible = true
		note.Visible = true
		githubButton.Visible = true
		linkNote.Visible = true
		close.Visible = true

		minimize.Size = UDim2.fromOffset(28, 28)
		minimize.Position = UDim2.fromOffset(195, 6)
		minimize.Text = "_"
		minimize.TextSize = 16
	end
end)
