--============================================================
-- Dirt Incremental X
-- Beta | Credit: ChimeraGaming
-- Free at Github
-- https://github.com/ChimeraGaming/LuaScripts
--============================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("DirtIncrementalCollector")
if old then
	old:Destroy()
end

local Spawning = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Spawning")
local ClearDirtServer = Spawning:FindFirstChild("ClearDirtServer")

local ENABLED = false
local connection = nil
local FIXING = false

local RADIUS = 45
local OUT_OF_RANGE_LIMIT = 65
local MAX_DIRT_COUNT = 50

local LOOP_DELAY = 0.06
local TOUCH_DELAY = 0.012
local STUCK_FIX_DELAY = 1.25
local REFILL_WAIT = 0.45

local MAX_DIRT_ATTEMPTS = 8
local dirtAttempts = {}

local GITHUB_URL = "https://github.com/ChimeraGaming/LuaScripts"

local lastFix = 0

--============================================================
-- CODES
--============================================================

local CODE_LIST = {
	"wowpotionbox",
	"secretcode123",
	"freeexcluck",
	"tungsahur",
	"myticketss",
	"newboxes",
	"verynicebro",
	"bigluck67",
	"moreopeningkeys",
	"pleasefreepots",
	"superluck21",
	"freepots67",
	"ilovedirt",
	"smallhouse",
	"greencactus",
	"volcanosecret",
	"backtowork",
	"potions3",
	"morerng",
	"ticketssecret",
}

--============================================================
-- EGG LOCATIONS
--============================================================

local EGG_LIST = {
	{"Egg #1", Vector3.new(-34, 1705, -1633)},
	{"Egg #2", Vector3.new(-211, 1706, -1599)},
	{"Egg #3", Vector3.new(-296, 1826, -802)},
	{"Egg #4", Vector3.new(-58, 1826, -754)},
	{"Egg #5", Vector3.new(649, 1883, -1237)},
	{"Egg #6", Vector3.new(512, 1882, -1340)},
	{"Egg #7", Vector3.new(1420, 1960, -2830)},
	{"Egg #8", Vector3.new(1179, 1960, -2780)},
}

--============================================================
-- PARKOUR LOCATIONS
--============================================================

local PARKOUR_LIST = {
	{"Ice Complete", Vector3.new(-1263, 1842, -558)},
}

--============================================================
-- GUI
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "DirtIncrementalCollector"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(430, 420)
frame.Position = UDim2.fromOffset(120, 120)
frame.BackgroundColor3 = Color3.fromRGB(35, 25, 18)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 30)
title.Position = UDim2.fromOffset(10, 5)
title.BackgroundTransparency = 1
title.Text = "[CRIMSON] 💩 Dirt Incremental X"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.fromOffset(390, 5)
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

--============================================================
-- POPUP
--============================================================

local popup = Instance.new("TextLabel")
popup.Size = UDim2.fromOffset(220, 30)
popup.Position = UDim2.fromOffset(105, 10)
popup.BackgroundColor3 = Color3.fromRGB(50, 140, 55)
popup.TextColor3 = Color3.fromRGB(255, 255, 255)
popup.Font = Enum.Font.GothamBold
popup.TextSize = 12
popup.Visible = false
popup.BorderSizePixel = 0
popup.Parent = frame

local popupCorner = Instance.new("UICorner")
popupCorner.CornerRadius = UDim.new(0, 8)
popupCorner.Parent = popup

local popupToken = 0

local function showPopup(text)
	popupToken += 1
	local token = popupToken

	popup.Text = text
	popup.Visible = true

	task.delay(1, function()
		if popupToken == token then
			popup.Visible = false
		end
	end)
end

--============================================================
-- TELEPORT FUNCTION
--============================================================

local function teleportTo(position, label)
	local char = Player.Character or Player.CharacterAdded:Wait()
	local hrp = char:FindFirstChild("HumanoidRootPart")

	if not hrp then
		showPopup("No HumanoidRootPart")
		return
	end

	hrp.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
	showPopup("Teleported " .. label)
end

--============================================================
-- TABS
--============================================================

local tabHolder = Instance.new("Frame")
tabHolder.Size = UDim2.new(1, -20, 0, 35)
tabHolder.Position = UDim2.fromOffset(10, 40)
tabHolder.BackgroundTransparency = 1
tabHolder.Parent = frame

local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -20, 1, -90)
contentHolder.Position = UDim2.fromOffset(10, 80)
contentHolder.BackgroundTransparency = 1
contentHolder.Parent = frame

local pages = {}
local buttons = {}

local function setActivePage(name)
	for pageName, page in pairs(pages) do
		page.Visible = pageName == name
	end

	for buttonName, button in pairs(buttons) do
		if buttonName == name then
			button.BackgroundColor3 = Color3.fromRGB(110, 75, 45)
		else
			button.BackgroundColor3 = Color3.fromRGB(70, 55, 40)
		end
	end
end

local function createPage(name, order)
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(95, 30)
	button.Position = UDim2.fromOffset((order - 1) * 100, 0)
	button.Text = name
	button.BackgroundColor3 = Color3.fromRGB(70, 55, 40)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.BorderSizePixel = 0
	button.Parent = tabHolder

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 6)
	bc.Parent = button

	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.ScrollBarThickness = 4
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Visible = false
	page.Parent = contentHolder

	pages[name] = page
	buttons[name] = button

	button.MouseButton1Click:Connect(function()
		setActivePage(name)
	end)

	return page
end

local mainPage = createPage("Main", 1)
local eggPage = createPage("Egg Hunt", 2)
local codePage = createPage("Codes", 3)
local parkourPage = createPage("Parkour", 4)

setActivePage("Main")

--============================================================
-- MAIN PAGE
--============================================================

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 42)
toggle.Position = UDim2.fromOffset(10, 10)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(95, 55, 35)
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.GothamBlack
toggle.TextSize = 18
toggle.BorderSizePixel = 0
toggle.Parent = mainPage

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 8)
tc.Parent = toggle

local note = Instance.new("TextLabel")
note.Size = UDim2.new(1, -20, 0, 150)
note.Position = UDim2.fromOffset(10, 60)
note.BackgroundTransparency = 1
note.TextWrapped = true
note.TextYAlignment = Enum.TextYAlignment.Top
note.Text = "Beta script. Bugs will be present and future updates will continue.\n\nFailsafe added: if dirt count exceeds 50 it fully local clears then calls server clear. If player moves too far away from dirt range, collector turns OFF.\n\nCredit: ChimeraGaming\nFree at Github."
note.TextColor3 = Color3.fromRGB(255, 255, 255)
note.Font = Enum.Font.Gotham
note.TextSize = 13
note.Parent = mainPage

local githubButton = Instance.new("TextButton")
githubButton.Size = UDim2.new(1, -20, 0, 35)
githubButton.Position = UDim2.fromOffset(10, 225)
githubButton.Text = "COPY GITHUB LINK"
githubButton.BackgroundColor3 = Color3.fromRGB(70, 55, 40)
githubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
githubButton.Font = Enum.Font.GothamBold
githubButton.TextSize = 13
githubButton.BorderSizePixel = 0
githubButton.Parent = mainPage

local githubCorner = Instance.new("UICorner")
githubCorner.CornerRadius = UDim.new(0, 8)
githubCorner.Parent = githubButton

githubButton.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard(GITHUB_URL)
		showPopup("Copied GitHub Link")
	else
		showPopup("Clipboard Unsupported")
	end
end)

--============================================================
-- EGG HUNT PAGE
--============================================================

for i, data in ipairs(EGG_LIST) do
	local name = data[1]
	local position = data[2]

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 34)
	btn.Position = UDim2.fromOffset(5, (i - 1) * 38)
	btn.BackgroundColor3 = Color3.fromRGB(60, 45, 35)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.Text = name .. " | Teleport"
	btn.BorderSizePixel = 0
	btn.Parent = eggPage

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = btn

	btn.MouseButton1Click:Connect(function()
		teleportTo(position, name)
	end)
end

eggPage.CanvasSize = UDim2.fromOffset(0, #EGG_LIST * 40)

--============================================================
-- CODE PAGE
--============================================================

for i, code in ipairs(CODE_LIST) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 30)
	btn.Position = UDim2.fromOffset(5, (i - 1) * 34)
	btn.BackgroundColor3 = Color3.fromRGB(60, 45, 35)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.Text = code
	btn.BorderSizePixel = 0
	btn.Parent = codePage

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = btn

	btn.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard(code)
			showPopup("Copied Code")
		else
			showPopup("Clipboard Unsupported")
		end
	end)
end

codePage.CanvasSize = UDim2.fromOffset(0, #CODE_LIST * 35)

--============================================================
-- PARKOUR PAGE
--============================================================

for i, data in ipairs(PARKOUR_LIST) do
	local name = data[1]
	local position = data[2]

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.Position = UDim2.fromOffset(5, (i - 1) * 39)
	btn.BackgroundColor3 = Color3.fromRGB(60, 45, 35)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.Text = name .. " | Teleport"
	btn.BorderSizePixel = 0
	btn.Parent = parkourPage

	local pcc = Instance.new("UICorner")
	pcc.CornerRadius = UDim.new(0, 6)
	pcc.Parent = btn

	btn.MouseButton1Click:Connect(function()
		teleportTo(position, name)
	end)
end

parkourPage.CanvasSize = UDim2.fromOffset(0, #PARKOUR_LIST * 40)

--============================================================
-- COLLECTOR HELPERS
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

local function getDirtCount()
	local root = getRoot()
	if not root then
		return 0
	end

	return #root:GetChildren()
end

local function localClearAllDirts()
	local root = getRoot()
	if not root then
		return 0
	end

	local removed = 0

	for _, dirt in ipairs(root:GetChildren()) do
		if dirt then
			pcall(function()
				dirt:Destroy()
				removed += 1
			end)
		end
	end

	table.clear(dirtAttempts)

	return removed
end

local function forceClear()
	localClearAllDirts()

	task.wait(0.05)

	pcall(function()
		if ClearDirtServer then
			ClearDirtServer:FireServer()
		end
	end)

	task.wait(REFILL_WAIT)
end

local function removeNoTouchDirt()
	local root = getRoot()
	if not root then
		return 0
	end

	local removed = 0

	for _, dirt in ipairs(root:GetChildren()) do
		if dirt and dirt.Parent and not hasTouchInterest(dirt) then
			dirt:Destroy()
			removed += 1
		end
	end

	return removed
end

local function getClosestDirtDistance()
	local root = getRoot()
	local hrp = getHRP()

	if not root or not hrp then
		return nil
	end

	local closest = nil

	for _, dirt in ipairs(root:GetChildren()) do
		if dirt and dirt.Parent then
			local touchParts = getTouchParts(dirt)

			for _, part in ipairs(touchParts) do
				if part and part.Parent and part:IsA("BasePart") then
					local distance = (hrp.Position - part.Position).Magnitude

					if not closest or distance < closest then
						closest = distance
					end
				end
			end
		end
	end

	return closest
end

local function turnOffCollector(reason)
	ENABLED = false
	FIXING = false
	connection = nil

	toggle.Text = "OFF"
	toggle.BackgroundColor3 = Color3.fromRGB(95, 55, 35)

	showPopup(reason or "Collector OFF")
end

local function checkFailsafes()
	local dirtCount = getDirtCount()

	if dirtCount > MAX_DIRT_COUNT then
		forceClear()
		showPopup("Full Cleared Dirt Overflow")
		return false
	end

	local closestDistance = getClosestDirtDistance()

	if closestDistance and closestDistance > OUT_OF_RANGE_LIMIT then
		turnOffCollector("Out Of Range OFF")
		return true
	end

	return false
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
					local stoppedByFailsafe = checkFailsafes()

					if stoppedByFailsafe then
						return
					end

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

close.MouseButton1Click:Connect(function()
	stopCollector()
	gui:Destroy()
end)

--============================================================
-- DRAGGING
--============================================================

local dragging = false
local dragStart
local startPos

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
	if isInside(close, pos) then
		return true
	end

	for _, button in pairs(buttons) do
		if isInside(button, pos) then
			return true
		end
	end

	return false
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if isNoDrag(input.Position) then
			return
		end

		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart

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
		dragging = false
	end
end)
