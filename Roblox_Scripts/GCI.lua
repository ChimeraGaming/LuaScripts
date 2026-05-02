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

local RANGE_LEVEL = 1
local RANGE_MIN = 1
local RANGE_MAX = 100
local RANGE_ENABLED = false

--============================================================
-- 03. STATE
--============================================================

local rangeEnforceConnection = nil
local originalCollectorData = {}

local savedPos = UDim2.fromOffset(120, 120)
local bubblePos = UDim2.fromOffset(120, 120)

--============================================================
-- 04. COLLECTOR RANGE HELPERS
--============================================================

local function getCollectorFolder()
	return Workspace:FindFirstChild("GrassCollider")
end

local function saveOriginalCollectorData(part)
	if originalCollectorData[part] then return end

	originalCollectorData[part] = {
		Size = part.Size,
		CanTouch = part.CanTouch,
		CanCollide = part.CanCollide,
		Transparency = part.Transparency,
		Massless = part.Massless
	}
end

local function applyCollectorPart(part)
	if not part or not part:IsA("BasePart") then return end

	saveOriginalCollectorData(part)

	local original = originalCollectorData[part]

	part.Size = Vector3.new(
		original.Size.X * RANGE_LEVEL,
		original.Size.Y,
		original.Size.Z * RANGE_LEVEL
	)

	part.CanTouch = true
	part.CanCollide = false
	part.Massless = true
end

local function updateCollectorSize()
	local folder = getCollectorFolder()
	if not folder then return end

	if folder:IsA("BasePart") then
		applyCollectorPart(folder)
	end

	for _, obj in ipairs(folder:GetDescendants()) do
		if obj:IsA("BasePart") then
			applyCollectorPart(obj)
		end
	end
end

local function startRangeEnforcer()
	if rangeEnforceConnection then return end

	rangeEnforceConnection = RunService.Heartbeat:Connect(function()
		if RANGE_ENABLED then
			updateCollectorSize()
		end
	end)
end

local function stopRangeEnforcer()
	if rangeEnforceConnection then
		rangeEnforceConnection:Disconnect()
		rangeEnforceConnection = nil
	end
end

local function resetCollectorSize()
	for part, data in pairs(originalCollectorData) do
		if part and part.Parent and part:IsA("BasePart") then
			part.Size = data.Size
			part.CanTouch = data.CanTouch
			part.CanCollide = data.CanCollide
			part.Transparency = data.Transparency
			part.Massless = data.Massless
		end
	end
end

--============================================================
-- 05. UI HELPERS
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
-- 06. MAIN UI
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "GrassCollector"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(320, 280)
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
-- 07. RANGE SLIDER + RADIAL TOGGLE
--============================================================

local rangeLabel = Instance.new("TextLabel")
rangeLabel.Size = UDim2.fromOffset(270, 20)
rangeLabel.Position = UDim2.fromOffset(25, 85)
rangeLabel.BackgroundTransparency = 1
rangeLabel.Text = "Collector Range: " .. RANGE_LEVEL .. " / 100"
rangeLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
rangeLabel.Font = Enum.Font.GothamBold
rangeLabel.TextSize = 12
rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
rangeLabel.Parent = frame

local rangeSlider = Instance.new("TextButton")
rangeSlider.Size = UDim2.fromOffset(215, 22)
rangeSlider.Position = UDim2.fromOffset(25, 110)
rangeSlider.BackgroundColor3 = Color3.fromRGB(35, 75, 45)
rangeSlider.Text = ""
rangeSlider.AutoButtonColor = false
rangeSlider.Parent = frame
corner(rangeSlider, 8)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(RANGE_LEVEL / RANGE_MAX, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(120, 220, 140)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = rangeSlider
corner(sliderFill, 8)

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.fromOffset(14, 28)
sliderKnob.Position = UDim2.new(RANGE_LEVEL / RANGE_MAX, -7, 0.5, -14)
sliderKnob.BackgroundColor3 = Color3.fromRGB(220, 255, 225)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = rangeSlider
corner(sliderKnob, 7)

local radialButton = Instance.new("TextButton")
radialButton.Size = UDim2.fromOffset(28, 28)
radialButton.Position = UDim2.fromOffset(265, 107)
radialButton.BackgroundColor3 = Color3.fromRGB(35, 65, 42)
radialButton.Text = ""
radialButton.AutoButtonColor = false
radialButton.Parent = frame
corner(radialButton, 14)
stroke(radialButton, Color3.fromRGB(70, 180, 95), 2)

local radialDot = Instance.new("Frame")
radialDot.Size = UDim2.fromOffset(14, 14)
radialDot.Position = UDim2.fromOffset(7, 7)
radialDot.BackgroundColor3 = Color3.fromRGB(120, 220, 140)
radialDot.BorderSizePixel = 0
radialDot.Visible = false
radialDot.Parent = radialButton
corner(radialDot, 7)

local sliding = false

local function refreshRangeToggle()
	if RANGE_ENABLED then
		radialButton.BackgroundColor3 = Color3.fromRGB(45, 120, 65)
		radialDot.Visible = true
	else
		radialButton.BackgroundColor3 = Color3.fromRGB(35, 65, 42)
		radialDot.Visible = false
	end
end

local function toggleCollectorRange()
	RANGE_ENABLED = not RANGE_ENABLED

	if RANGE_ENABLED then
		updateCollectorSize()
		startRangeEnforcer()
	else
		resetCollectorSize()
	end

	refreshRangeToggle()
end

local function setRangeFromMouse()
	local mouse = UIS:GetMouseLocation()
	local rel = (mouse.X - rangeSlider.AbsolutePosition.X) / rangeSlider.AbsoluteSize.X

	rel = math.clamp(rel, 0, 1)

	local newLevel = math.floor(rel * (RANGE_MAX - RANGE_MIN) + RANGE_MIN + 0.5)
	newLevel = math.clamp(newLevel, RANGE_MIN, RANGE_MAX)

	RANGE_LEVEL = newLevel

	local percent = RANGE_LEVEL / RANGE_MAX

	sliderFill.Size = UDim2.new(percent, 0, 1, 0)
	sliderKnob.Position = UDim2.new(percent, -7, 0.5, -14)
	rangeLabel.Text = "Collector Range: " .. RANGE_LEVEL .. " / 100"

	if RANGE_ENABLED then
		updateCollectorSize()
	end
end

rangeSlider.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		sliding = true
		setRangeFromMouse()
	end
end)

sliderKnob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		sliding = true
		setRangeFromMouse()
	end
end)

radialButton.MouseButton1Click:Connect(toggleCollectorRange)

--============================================================
-- 08. EXTRA BUTTONS
--============================================================

local github = Instance.new("TextButton")
github.Size = UDim2.fromOffset(270, 30)
github.Position = UDim2.fromOffset(25, 150)
github.Text = "GitHub | ChimeraGaming LuaScripts"
github.BackgroundColor3 = Color3.fromRGB(25, 45, 32)
github.TextColor3 = Color3.fromRGB(175, 220, 180)
github.Font = Enum.Font.GothamBold
github.TextSize = 12
github.Parent = frame
corner(github, 8)

local iy = Instance.new("TextButton")
iy.Size = UDim2.fromOffset(270, 30)
iy.Position = UDim2.fromOffset(25, 188)
iy.Text = "Load Infinite Yield"
iy.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
iy.TextColor3 = Color3.fromRGB(220, 220, 255)
iy.Font = Enum.Font.GothamBold
iy.TextSize = 12
iy.Parent = frame
corner(iy, 8)

local iyNote = Instance.new("TextLabel")
iyNote.Size = UDim2.fromOffset(270, 24)
iyNote.Position = UDim2.fromOffset(25, 224)
iyNote.BackgroundTransparency = 1
iyNote.Text = "> Enable AntiAFK for best results"
iyNote.TextColor3 = Color3.fromRGB(200, 200, 255)
iyNote.Font = Enum.Font.Gotham
iyNote.TextSize = 11
iyNote.TextWrapped = true
iyNote.Parent = frame

local popup = Instance.new("TextLabel")
popup.Size = UDim2.fromOffset(270, 26)
popup.Position = UDim2.fromOffset(25, 224)
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
divider2.Position = UDim2.fromOffset(15, 250)
divider2.BackgroundColor3 = Color3.fromRGB(70, 180, 95)
divider2.BorderSizePixel = 0
divider2.Parent = frame

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -20, 0, 22)
credit.Position = UDim2.fromOffset(10, 254)
credit.BackgroundTransparency = 1
credit.Text = "Credit | Chimera__Gaming | FREE AT RSCRIPTS"
credit.Font = Enum.Font.Gotham
credit.TextSize = 10
credit.TextColor3 = Color3.fromRGB(175, 220, 180)
credit.TextWrapped = true
credit.Parent = frame

--============================================================
-- 09. BUTTON LOGIC
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

close.MouseButton1Click:Connect(function()
	RANGE_ENABLED = false
	stopRangeEnforcer()
	resetCollectorSize()
	gui:Destroy()
end)

--============================================================
-- 10. DRAG LOGIC
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

	if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
		setRangeFromMouse()
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		if dragging then
			savedPos = frame.Position
		end

		dragging = false
		sliding = false
	end
end)

--============================================================
-- 11. MINIMIZE BUBBLE
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
-- 12. LOADED
--============================================================

refreshRangeToggle()
startRangeEnforcer()

print("Grass Collector Loaded")
