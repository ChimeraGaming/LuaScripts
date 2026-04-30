--============================================================
-- [🔮] Knowledge Incremental
-- Tome TP Collector
-- Credit | Chimera__Gaming
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

--============================================================
-- 02. CLEANUP
--============================================================
local old = PlayerGui:FindFirstChild("KnowledgeIncremental")
if old then
	old:Destroy()
end

--============================================================
-- 03. SETTINGS
--============================================================
local TP_RANGE = 850
local BATCH_SIZE = 120
local TOUCHES_PER_PART = 1

--============================================================
-- 04. STATE
--============================================================
local tomeTPEnabled = false
local connection = nil
local running = false
local cache = {}
local index = 1

local savedPos = UDim2.fromOffset(120, 120)
local bubblePos = UDim2.fromOffset(120, 120)

--============================================================
-- 05. CHARACTER
--============================================================
local function getRoot()
	local char = Player.Character
	if not char then return nil end

	return char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
end

--============================================================
-- 06. TELEPORT FUNCTION
--============================================================
local function tpTo(x, y, z)
	local root = getRoot()
	if not root then return end

	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = CFrame.new(x, y, z)
	end)
end

--============================================================
-- 07. CACHE
--============================================================
local function rebuildCache()
	cache = {}
	index = 1

	for _, obj in ipairs(Workspace:GetChildren()) do
		if string.sub(obj.Name, 1, 5) == "Tome_" then
			if obj:IsA("BasePart") then
				table.insert(cache, obj)
			else
				for _, d in ipairs(obj:GetDescendants()) do
					if d:IsA("BasePart") then
						table.insert(cache, d)
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
-- 08. TP LOGIC
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
	if not root then return end

	if #cache == 0 then
		rebuildCache()
	end

	for i = 1, BATCH_SIZE do
		if not tomeTPEnabled then
			break
		end

		if index > #cache then
			index = 1
			rebuildCache()
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

	rebuildCache()

	connection = RunService.Heartbeat:Connect(function()
		if not tomeTPEnabled then return end
		if running then return end

		running = true
		processTP()
		running = false
	end)
end

local function stopLoop()
	tomeTPEnabled = false
	running = false

	if connection then
		connection:Disconnect()
		connection = nil
	end
end

--============================================================
-- 09. UI HELPERS
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

local function makeButton(parent, text, pos, size)
	local b = Instance.new("TextButton")
	b.Size = size or UDim2.fromOffset(270, 34)
	b.Position = pos
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
	b.TextColor3 = Color3.fromRGB(245, 235, 255)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.Parent = parent
	corner(b, 9)
	return b
end

local function makeLabel(parent, text, pos, size)
	local l = Instance.new("TextLabel")
	l.Size = size or UDim2.fromOffset(270, 22)
	l.Position = pos
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(220, 200, 255)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 12
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

--============================================================
-- 10. ROOT GUI
--============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "KnowledgeIncremental"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(340, 430)
frame.Position = savedPos
frame.BackgroundColor3 = Color3.fromRGB(22, 14, 38)
frame.BorderSizePixel = 0
frame.Parent = gui
corner(frame, 14)
stroke(frame, Color3.fromRGB(170, 90, 255), 2)

--============================================================
-- 11. TITLE BAR
--============================================================
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -82, 0, 34)
title.Position = UDim2.fromOffset(14, 12)
title.BackgroundTransparency = 1
title.Text = "[🔮] Knowledge Incremental"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(245, 230, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(26, 26)
minimize.Position = UDim2.new(1, -66, 0, 10)
minimize.Text = "-"
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 18
minimize.BackgroundColor3 = Color3.fromRGB(65, 35, 105)
minimize.TextColor3 = Color3.fromRGB(245, 230, 255)
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
divider1.BackgroundColor3 = Color3.fromRGB(170, 90, 255)
divider1.BorderSizePixel = 0
divider1.Parent = frame

--============================================================
-- 12. TAB BUTTONS
--============================================================
local mainTabButton = makeButton(frame, "Main", UDim2.fromOffset(20, 65), UDim2.fromOffset(145, 30))
local tpTabButton = makeButton(frame, "TP", UDim2.fromOffset(175, 65), UDim2.fromOffset(145, 30))

--============================================================
-- 13. TAB CONTAINERS
--============================================================
local mainTab = Instance.new("Frame")
mainTab.Size = UDim2.new(1, -30, 1, -110)
mainTab.Position = UDim2.fromOffset(15, 105)
mainTab.BackgroundTransparency = 1
mainTab.Parent = frame

local tpTab = Instance.new("Frame")
tpTab.Size = mainTab.Size
tpTab.Position = mainTab.Position
tpTab.BackgroundTransparency = 1
tpTab.Visible = false
tpTab.Parent = frame

--============================================================
-- 14. TAB SWITCHING
--============================================================
local function switchTab(tab)
	mainTab.Visible = tab == "Main"
	tpTab.Visible = tab == "TP"

	mainTabButton.BackgroundColor3 = tab == "Main" and Color3.fromRGB(150, 75, 255) or Color3.fromRGB(60, 40, 100)
	tpTabButton.BackgroundColor3 = tab == "TP" and Color3.fromRGB(150, 75, 255) or Color3.fromRGB(60, 40, 100)
end

mainTabButton.MouseButton1Click:Connect(function()
	switchTab("Main")
end)

tpTabButton.MouseButton1Click:Connect(function()
	switchTab("TP")
end)

--============================================================
-- 15. MAIN TAB BUTTONS
--============================================================
local tomeButton = makeButton(mainTab, "Tome TP Off", UDim2.fromOffset(20, 10), UDim2.fromOffset(270, 38))

local testKnowledge = makeButton(mainTab, "Test Auto Knowledge", UDim2.fromOffset(20, 58), UDim2.fromOffset(270, 38))

local github = makeButton(mainTab, "GitHub | ChimeraGaming LuaScripts", UDim2.fromOffset(20, 110), UDim2.fromOffset(270, 30))
github.BackgroundColor3 = Color3.fromRGB(35, 25, 60)
github.TextColor3 = Color3.fromRGB(225, 200, 255)
github.TextSize = 12

local iy = makeButton(mainTab, "Load Infinite Yield", UDim2.fromOffset(20, 148), UDim2.fromOffset(270, 30))
iy.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
iy.TextColor3 = Color3.fromRGB(230, 220, 255)
iy.TextSize = 12

local iyNote = makeLabel(mainTab, "> Enable AntiAFK for best results", UDim2.fromOffset(20, 184), UDim2.fromOffset(270, 24))
iyNote.Font = Enum.Font.Gotham
iyNote.TextSize = 11
iyNote.TextWrapped = true

local popup = Instance.new("TextLabel")
popup.Size = UDim2.fromOffset(270, 26)
popup.Position = UDim2.fromOffset(20, 215)
popup.BackgroundColor3 = Color3.fromRGB(65, 35, 105)
popup.Text = "Copied to clipboard"
popup.TextColor3 = Color3.fromRGB(245, 230, 255)
popup.Font = Enum.Font.GothamBold
popup.TextSize = 12
popup.Visible = false
popup.Parent = mainTab
corner(popup, 8)

local credit = Instance.new("TextLabel")
credit.Size = UDim2.fromOffset(270, 54)
credit.Position = UDim2.fromOffset(20, 255)
credit.BackgroundTransparency = 1
credit.Text = "Credit | Chimera__Gaming\nFREE AT RSCRIPTS"
credit.Font = Enum.Font.Gotham
credit.TextSize = 11
credit.TextColor3 = Color3.fromRGB(220, 200, 255)
credit.TextWrapped = true
credit.Parent = mainTab

--============================================================
-- 16. MAIN TAB LOGIC
--============================================================
local function updateButtons()
	tomeButton.Text = tomeTPEnabled and "Tome TP On" or "Tome TP Off"
	tomeButton.BackgroundColor3 = tomeTPEnabled and Color3.fromRGB(150, 75, 255) or Color3.fromRGB(60, 40, 100)
end

tomeButton.MouseButton1Click:Connect(function()
	local newState = not tomeTPEnabled

	stopLoop()

	if newState then
		tomeTPEnabled = true
		rebuildCache()
		startLoop()
	end

	updateButtons()
end)

testKnowledge.MouseButton1Click:Connect(function()
	local root = getRoot()
	if not root then return end

	local original = root.CFrame

	testKnowledge.Text = "Testing Knowledge..."
	testKnowledge.BackgroundColor3 = Color3.fromRGB(150, 75, 255)

	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = CFrame.new(778, 4, 10)
	end)

	task.wait(0.15)

	pcall(function()
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = original
	end)

	testKnowledge.Text = "Test Auto Knowledge"
	testKnowledge.BackgroundColor3 = Color3.fromRGB(60, 40, 100)
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

--============================================================
-- 17. TP TAB BUTTONS
--============================================================
makeLabel(tpTab, "Locations", UDim2.fromOffset(20, 5), UDim2.fromOffset(270, 22))

local study = makeButton(tpTab, "Study", UDim2.fromOffset(20, 32), UDim2.fromOffset(135, 32))
local archives = makeButton(tpTab, "Archives", UDim2.fromOffset(165, 32), UDim2.fromOffset(135, 32))

local sanctum = makeButton(tpTab, "Sanctum", UDim2.fromOffset(20, 72), UDim2.fromOffset(135, 32))
local chamber = makeButton(tpTab, "Chamber E6", UDim2.fromOffset(165, 72), UDim2.fromOffset(135, 32))

local observatory = makeButton(tpTab, "Observatory T1", UDim2.fromOffset(20, 112), UDim2.fromOffset(135, 32))
local ascendedStudy = makeButton(tpTab, "Ascended Study T6", UDim2.fromOffset(165, 112), UDim2.fromOffset(135, 32))

local forgottenDepths = makeButton(tpTab, "Forgotten Depths", UDim2.fromOffset(92, 152), UDim2.fromOffset(160, 32))

--============================================================
-- 18. TP TAB LOGIC
--============================================================
study.MouseButton1Click:Connect(function()
	tpTo(2, 172, -49)
end)

archives.MouseButton1Click:Connect(function()
	tpTo(17, 172, 45)
end)

sanctum.MouseButton1Click:Connect(function()
	tpTo(-19, 172, 64)
end)

chamber.MouseButton1Click:Connect(function()
	tpTo(-74, 172, 65)
end)

observatory.MouseButton1Click:Connect(function()
	tpTo(-110, 172, 43)
end)

ascendedStudy.MouseButton1Click:Connect(function()
	tpTo(-116, 172, 2)
end)

forgottenDepths.MouseButton1Click:Connect(function()
	tpTo(64, 172, -1)
end)

--============================================================
-- 19. CLOSE LOGIC
--============================================================
close.MouseButton1Click:Connect(function()
	stopLoop()
	gui:Destroy()
end)

--============================================================
-- 20. DRAG FRAME
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
-- 21. MINIMIZE BUBBLE
--============================================================
local bubble = Instance.new("TextButton")
bubble.Size = UDim2.fromOffset(52, 52)
bubble.Position = bubblePos
bubble.BackgroundColor3 = Color3.fromRGB(22, 14, 38)
bubble.Text = "🔮"
bubble.Font = Enum.Font.GothamBold
bubble.TextSize = 24
bubble.TextColor3 = Color3.fromRGB(245, 230, 255)
bubble.Visible = false
bubble.Parent = gui
corner(bubble, 26)
stroke(bubble, Color3.fromRGB(170, 90, 255), 2)

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

--============================================================
-- 22. INIT
--============================================================
switchTab("Main")
updateButtons()

print("[🔮] Knowledge Incremental Loaded")
