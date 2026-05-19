--============================================================
-- Grass Collector UI
--============================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("GrassCollector")
if old then old:Destroy() end

local RANGE_LEVEL = 1
local RANGE_MIN = 1
local RANGE_MAX = 100
local RANGE_ENABLED = false

local BG = "https://www.roblox.com/asset-thumbnail/image?assetId=100488071891852&width=420&height=420&format=png"

local connection
local original = {}

local dragging = false
local dragStart
local startPos
local minimizedDragMoved = false

local minimized = false
local savedNormalPosition = UDim2.fromOffset(120, 120)
local savedMinimizedPosition = UDim2.fromOffset(120, 120)

local function getFolder()
	return Workspace:FindFirstChild("GrassCollider")
end

local function save(part)
	if original[part] then return end

	original[part] = {
		Size = part.Size
	}
end

local function apply(part)
	if not part:IsA("BasePart") then return end

	save(part)

	local base = original[part]

	part.Size = Vector3.new(
		base.Size.X * RANGE_LEVEL,
		base.Size.Y,
		base.Size.Z * RANGE_LEVEL
	)

	part.CanTouch = true
	part.CanCollide = false
end

local function update()
	local folder = getFolder()
	if not folder then return end

	for _, v in ipairs(folder:GetDescendants()) do
		if v:IsA("BasePart") then
			apply(v)
		end
	end
end

local function start()
	if connection then return end

	connection = RunService.Heartbeat:Connect(function()
		if RANGE_ENABLED then
			update()
		end
	end)
end

local function stop()
	if connection then
		connection:Disconnect()
		connection = nil
	end
end

local function teleportToCoolWorld()
	local character = Player.Character or Player.CharacterAdded:Wait()
	local root = character:FindFirstChild("HumanoidRootPart")

	if root then
		root.CFrame = CFrame.new(-170, -37, 390)
	end
end

local gui = Instance.new("ScreenGui")
gui.Name = "GrassCollector"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(340, 340)
frame.Position = savedNormalPosition
frame.BackgroundTransparency = 1
frame.Parent = gui

local bg = Instance.new("ImageLabel")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundTransparency = 1
bg.Image = BG
bg.ScaleType = Enum.ScaleType.Stretch
bg.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -40, 0, 24)
label.Position = UDim2.fromOffset(20, 76)
label.BackgroundTransparency = 1
label.Text = "Collector Range: 1/100"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextStrokeTransparency = 0.25
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.Parent = frame

local barBack = Instance.new("Frame")
barBack.Size = UDim2.fromOffset(225, 18)
barBack.Position = UDim2.fromOffset(25, 112)
barBack.BackgroundColor3 = Color3.fromRGB(28, 80, 38)
barBack.BorderSizePixel = 0
barBack.Parent = frame

local barBackCorner = Instance.new("UICorner")
barBackCorner.CornerRadius = UDim.new(0, 9)
barBackCorner.Parent = barBack

local fill = Instance.new("Frame")
fill.Size = UDim2.fromOffset(8, 18)
fill.BackgroundColor3 = Color3.fromRGB(125, 240, 100)
fill.BorderSizePixel = 0
fill.Parent = barBack

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 9)
fillCorner.Parent = fill

local knob = Instance.new("Frame")
knob.Size = UDim2.fromOffset(18, 28)
knob.Position = UDim2.fromOffset(0, -5)
knob.BackgroundColor3 = Color3.fromRGB(245, 255, 245)
knob.BorderSizePixel = 0
knob.Parent = barBack

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(0, 9)
knobCorner.Parent = knob

local knobStroke = Instance.new("UIStroke")
knobStroke.Color = Color3.fromRGB(25, 80, 30)
knobStroke.Thickness = 2
knobStroke.Parent = knob

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(34, 34)
toggle.Position = UDim2.fromOffset(270, 104)
toggle.Text = ""
toggle.BackgroundColor3 = Color3.fromRGB(45, 135, 55)
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.GothamBlack
toggle.TextSize = 24
toggle.BorderSizePixel = 0
toggle.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggle

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(15, 70, 20)
toggleStroke.Thickness = 2
toggleStroke.Parent = toggle

toggle.MouseButton1Click:Connect(function()
	RANGE_ENABLED = not RANGE_ENABLED

	if RANGE_ENABLED then
		toggle.Text = "✓"
		toggle.BackgroundColor3 = Color3.fromRGB(70, 190, 75)
		start()
	else
		toggle.Text = ""
		toggle.BackgroundColor3 = Color3.fromRGB(45, 135, 55)
		stop()
	end
end)

local sliding = false

local function setRangeFromX(x)
	local percent = math.clamp(
		(x - barBack.AbsolutePosition.X) / barBack.AbsoluteSize.X,
		0,
		1
	)

	RANGE_LEVEL = math.floor(percent * RANGE_MAX)

	if RANGE_LEVEL < RANGE_MIN then
		RANGE_LEVEL = RANGE_MIN
	end

	local fillWidth = math.clamp(
		percent * barBack.AbsoluteSize.X,
		8,
		barBack.AbsoluteSize.X
	)

	fill.Size = UDim2.fromOffset(fillWidth, 18)
	knob.Position = UDim2.fromOffset(fillWidth - 9, -5)

	label.Text = "Collector Range: " .. RANGE_LEVEL .. "/100"
end

barBack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		sliding = true
		setRangeFromX(input.Position.X)
	end
end)

knob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		sliding = true
	end
end)

UIS.InputChanged:Connect(function(input)
	if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
		setRangeFromX(input.Position.X)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		sliding = false
	end
end)

local function makeButton(text, x, y)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(118, 38)
	btn.Position = UDim2.fromOffset(x, y)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(74, 60, 130)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextStrokeTransparency = 0.5
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.BorderSizePixel = 0
	btn.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(30, 20, 70)
	stroke.Thickness = 2
	stroke.Parent = btn

	return btn
end

local infYield = makeButton("Inf Yield", 42, 152)
local grassland = makeButton("Grassland", 178, 152)
local solarian = makeButton("Solarian", 42, 196)
local planetRun = makeButton("Planet Run", 178, 196)

infYield.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

grassland.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ChimeraGaming/LuaScripts/main/Roblox_Scripts/GCI_Grasslands.lua"))()
end)

solarian.MouseButton1Click:Connect(function()
	print("Solarian not linked yet")
end)

planetRun.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ChimeraGaming/LuaScripts/main/Roblox_Scripts/GCI_Planet_Run.lua"))()
end)

local note = Instance.new("TextLabel")
note.Size = UDim2.new(1, -40, 0, 22)
note.Position = UDim2.fromOffset(20, 246)
note.BackgroundTransparency = 1
note.Text = "Enable AntiAFK for best results"
note.TextColor3 = Color3.fromRGB(255, 255, 255)
note.TextStrokeTransparency = 0.25
note.Font = Enum.Font.GothamBold
note.TextSize = 12
note.Parent = frame

local credit = Instance.new("TextLabel")
credit.Size = UDim2.fromOffset(150, 18)
credit.Position = UDim2.fromOffset(88, 270)
credit.BackgroundTransparency = 1
credit.Text = "Credit | Chimera__Gaming"
credit.TextColor3 = Color3.fromRGB(230, 255, 230)
credit.TextStrokeTransparency = 0.4
credit.Font = Enum.Font.Gotham
credit.TextSize = 10
credit.TextXAlignment = Enum.TextXAlignment.Left
credit.Parent = frame

local coolButton = Instance.new("TextButton")
coolButton.Size = UDim2.fromOffset(30, 30)
coolButton.Position = UDim2.fromOffset(246, 263)
coolButton.Text = "😎"
coolButton.BackgroundColor3 = Color3.fromRGB(45, 135, 55)
coolButton.TextColor3 = Color3.fromRGB(255, 255, 255)
coolButton.Font = Enum.Font.GothamBlack
coolButton.TextSize = 18
coolButton.BorderSizePixel = 0
coolButton.Parent = frame

local coolCorner = Instance.new("UICorner")
coolCorner.CornerRadius = UDim.new(1, 0)
coolCorner.Parent = coolButton

local coolStroke = Instance.new("UIStroke")
coolStroke.Color = Color3.fromRGB(15, 70, 20)
coolStroke.Thickness = 2
coolStroke.Parent = coolButton

coolButton.MouseButton1Click:Connect(function()
	teleportToCoolWorld()
end)

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(44, 34)
minimize.Position = UDim2.fromOffset(18, 258)
minimize.Text = "━"
minimize.BackgroundTransparency = 1
minimize.TextColor3 = Color3.fromRGB(0, 170, 255)
minimize.TextStrokeTransparency = 0
minimize.Font = Enum.Font.GothamBlack
minimize.TextSize = 34
minimize.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(44, 44)
close.Position = UDim2.fromOffset(285, 248)
close.Text = "X"
close.BackgroundTransparency = 1
close.TextColor3 = Color3.fromRGB(255, 0, 35)
close.TextStrokeTransparency = 0
close.Font = Enum.Font.GothamBlack
close.TextSize = 34
close.Parent = frame

close.MouseButton1Click:Connect(function()
	stop()
	gui:Destroy()
end)

local function isInside(obj, pos)
	if not obj or not obj.Visible then return false end

	local ap = obj.AbsolutePosition
	local as = obj.AbsoluteSize

	return pos.X >= ap.X
		and pos.X <= ap.X + as.X
		and pos.Y >= ap.Y
		and pos.Y <= ap.Y + as.Y
end

local function isOnNoDragArea(pos)
	if minimized then
		return false
	end

	return isInside(barBack, pos)
		or isInside(knob, pos)
		or isInside(toggle, pos)
		or isInside(infYield, pos)
		or isInside(grassland, pos)
		or isInside(solarian, pos)
		or isInside(planetRun, pos)
		or isInside(coolButton, pos)
		or isInside(minimize, pos)
		or isInside(close, pos)
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if isOnNoDragArea(input.Position) then
			return
		end

		dragging = true
		minimizedDragMoved = false
		dragStart = input.Position
		startPos = frame.Position
	end
end)

minimize.InputBegan:Connect(function(input)
	if minimized and input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		minimizedDragMoved = false
		dragStart = input.Position
		startPos = frame.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart

		if minimized and (math.abs(delta.X) > 4 or math.abs(delta.Y) > 4) then
			minimizedDragMoved = true
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

minimize.MouseButton1Click:Connect(function()
	if minimized and minimizedDragMoved then
		minimizedDragMoved = false
		return
	end

	minimized = not minimized

	if minimized then
		savedNormalPosition = frame.Position

		frame.Size = UDim2.fromOffset(72, 72)
		frame.Position = savedMinimizedPosition

		bg.Visible = false
		label.Visible = false
		barBack.Visible = false
		toggle.Visible = false
		infYield.Visible = false
		grassland.Visible = false
		solarian.Visible = false
		planetRun.Visible = false
		note.Visible = false
		credit.Visible = false
		coolButton.Visible = false
		close.Visible = false

		minimize.Size = UDim2.fromOffset(70, 70)
		minimize.Position = UDim2.fromOffset(1, 1)
		minimize.Text = "🚜"
		minimize.BackgroundTransparency = 1
		minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
		minimize.TextStrokeTransparency = 0
		minimize.Font = Enum.Font.GothamBlack
		minimize.TextSize = 38
	else
		savedMinimizedPosition = frame.Position

		frame.Size = UDim2.fromOffset(340, 340)
		frame.Position = savedNormalPosition

		bg.Visible = true
		label.Visible = true
		barBack.Visible = true
		toggle.Visible = true
		infYield.Visible = true
		grassland.Visible = true
		solarian.Visible = true
		planetRun.Visible = true
		note.Visible = true
		credit.Visible = true
		coolButton.Visible = true
		close.Visible = true

		minimize.Size = UDim2.fromOffset(44, 34)
		minimize.Position = UDim2.fromOffset(18, 258)
		minimize.Text = "━"
		minimize.TextColor3 = Color3.fromRGB(0, 170, 255)
		minimize.TextStrokeTransparency = 0
		minimize.Font = Enum.Font.GothamBlack
		minimize.TextSize = 34

		close.Position = UDim2.fromOffset(285, 248)
	end
end)
