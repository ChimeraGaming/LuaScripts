--============================================================
-- Space Automation UI
-- Tabs + Minimize + Auto Rune WIP + Auto Tungsten WIP
-- Credit | Chimera__Gaming
-- Found Free at RSCRIPTS
--============================================================

--============================================================
-- 01. SERVICES
--============================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local UIS               = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local VIM               = game:GetService("VirtualInputManager")
local Camera            = workspace.CurrentCamera

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--============================================================
-- 02. RATES
--============================================================

local CLICKER_CPS   = 10
local INTERVAL      = 1 / CLICKER_CPS

local RUNE_CPS      = 2
local RUNE_INTERVAL = 1 / RUNE_CPS

local TUNG_CPS      = 1
local TUNG_INTERVAL = 1 / TUNG_CPS

--============================================================
-- 03. PANEL SETTINGS
--============================================================

local PANEL_W = 280
local PANEL_H_MAIN = 250
local PANEL_H_CLICKERS = 370
local PANEL_POS = UDim2.new(0.5, -PANEL_W / 2, 0.35, -PANEL_H_MAIN / 2)

--============================================================
-- 04. CLEANUP OLD UI
--============================================================

local old = PlayerGui:FindFirstChild("SpaceTabsUI")
if old then
	old:Destroy()
end

--============================================================
-- 05. ROOT GUI
--============================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "SpaceTabsUI"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

--============================================================
-- 06. STATE FOR THREADS / CONNECTIONS
--============================================================

local collectorRunning = false
local collectorThread = nil

local afkRunning = false
local afkThread = nil

local wsRunning = false
local wsThread = nil

local miningRunning = false
local miningConn = nil

local machineRunning = false
local machineConn = nil

local machine2Running = false
local machine2Conn = nil

local runeRunning = false
local runeConn = nil

local tungRunning = false
local tungConn = nil

--============================================================
-- 07. MAIN PANEL
--============================================================

local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.Size = UDim2.fromOffset(PANEL_W, PANEL_H_MAIN)
Panel.Position = PANEL_POS
Panel.BackgroundColor3 = Color3.fromRGB(10, 12, 28)
Panel.BackgroundTransparency = 0.05
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Parent = Gui

Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 12)

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0, 200, 255)
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = Panel

--============================================================
-- 08. HEADER
--============================================================

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 32)
Header.Position = UDim2.fromOffset(0, 0)
Header.BackgroundTransparency = 1
Header.Active = true
Header.Parent = Panel

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -72, 0, 24)
Title.Position = UDim2.fromOffset(12, 6)
Title.Text = "Space Automation"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(150, 230, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

--============================================================
-- 09. CLOSE BUTTON
--============================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(22, 22)
Close.Position = UDim2.new(1, -28, 0, 6)
Close.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Close.Text = "X"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 13
Close.TextColor3 = Color3.fromRGB(255, 100, 100)
Close.AutoButtonColor = false
Close.Parent = Header

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

--============================================================
-- 10. MINIMIZE BUTTON
--============================================================

local Min = Instance.new("TextButton")
Min.Size = UDim2.fromOffset(22, 22)
Min.Position = UDim2.new(1, -54, 0, 6)
Min.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Min.Text = "-"
Min.Font = Enum.Font.GothamBold
Min.TextSize = 16
Min.TextColor3 = Color3.fromRGB(150, 200, 255)
Min.AutoButtonColor = false
Min.Parent = Header

Instance.new("UICorner", Min).CornerRadius = UDim.new(0, 6)

--============================================================
-- 11. TABS
--============================================================

local Tabs = Instance.new("Frame")
Tabs.BackgroundTransparency = 1
Tabs.Size = UDim2.new(1, -24, 0, 30)
Tabs.Position = UDim2.fromOffset(12, 34)
Tabs.Parent = Panel

local function makeTab(xOffset, label)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(120, 26)
	b.Position = UDim2.fromOffset(xOffset, 2)
	b.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
	b.Text = label
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(180, 220, 255)
	b.AutoButtonColor = false
	b.Parent = Tabs

	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

	return b
end

local TabMain = makeTab(0, "Main")
local TabClickers = makeTab(130, "Clickers")

local function setActiveTab(btn, active)
	if active then
		btn.BackgroundColor3 = Color3.fromRGB(60, 70, 140)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
		btn.TextColor3 = Color3.fromRGB(180, 220, 255)
	end
end

--============================================================
-- 12. CONTENT
--============================================================

local Content = Instance.new("Frame")
Content.BackgroundTransparency = 1
Content.Size = UDim2.new(1, -24, 1, -112)
Content.Position = UDim2.fromOffset(12, 66)
Content.Parent = Panel

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromScale(1, 1)
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = Content

local ClickersFrame = Instance.new("Frame")
ClickersFrame.Name = "ClickersFrame"
ClickersFrame.Size = UDim2.fromScale(1, 1)
ClickersFrame.BackgroundTransparency = 1
ClickersFrame.Visible = false
ClickersFrame.Parent = Content

--============================================================
-- 13. TOGGLE HELPER
--============================================================

local function makeToggle(parent, y, label)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 42)
	b.Position = UDim2.fromOffset(0, y)
	b.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
	b.Text = label .. ": OFF"
	b.Font = Enum.Font.GothamBold
	b.TextSize = 18
	b.TextColor3 = Color3.fromRGB(180, 220, 255)
	b.AutoButtonColor = false
	b.Parent = parent

	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

	return b
end

--============================================================
-- 14. DRAGGING SYSTEM
--============================================================

local dragging = false
local didDrag = false
local dragStartMouse = nil
local startPos = nil
local lastDragAt = 0
local THRESH = 6

Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		didDrag = false
		dragStartMouse = UIS:GetMouseLocation()
		startPos = Panel.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and dragStartMouse and startPos then
		local m = UIS:GetMouseLocation()
		local dx = m.X - dragStartMouse.X
		local dy = m.Y - dragStartMouse.Y

		if not didDrag and (math.abs(dx) > THRESH or math.abs(dy) > THRESH) then
			didDrag = true
		end

		Panel.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + dx,
			startPos.Y.Scale,
			startPos.Y.Offset + dy
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if dragging and didDrag then
			lastDragAt = os.clock()
		end

		dragging = false
		didDrag = false
		dragStartMouse = nil
		startPos = nil
	end
end)

local function justDragged()
	return (os.clock() - lastDragAt) < 0.12
end

--============================================================
-- 15. HELPERS
--============================================================

local function clickAt(x, y)
	VIM:SendMouseMoveEvent(x, y, game)
	VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
	VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function getScreenPointsFromModel(model)
	local cf, size = model:GetBoundingBox()
	local half = size / 2
	local pts = {}
	local cx = 0
	local cy = 0
	local n = 0

	local corners = {
		Vector3.new(-half.X, -half.Y, -half.Z),
		Vector3.new( half.X, -half.Y, -half.Z),
		Vector3.new(-half.X,  half.Y, -half.Z),
		Vector3.new( half.X,  half.Y, -half.Z),
		Vector3.new(-half.X, -half.Y,  half.Z),
		Vector3.new( half.X, -half.Y,  half.Z),
		Vector3.new(-half.X,  half.Y,  half.Z),
		Vector3.new( half.X,  half.Y,  half.Z),
	}

	for _, off in ipairs(corners) do
		local wp = cf:PointToWorldSpace(off)
		local sp, on = Camera:WorldToViewportPoint(wp)

		if on then
			table.insert(pts, Vector2.new(sp.X, sp.Y))
			cx += sp.X
			cy += sp.Y
			n += 1
		end
	end

	if n > 0 then
		table.insert(pts, Vector2.new(cx / n, cy / n))
	end

	return pts
end

--============================================================
-- 16. REMOTES
--============================================================

local EventsFolder = ReplicatedStorage:FindFirstChild("Events")

local evCollect  = EventsFolder and EventsFolder:FindFirstChild("CollectObject")
local evMine     = EventsFolder and EventsFolder:FindFirstChild("Mine")
local evMachine  = EventsFolder and EventsFolder:FindFirstChild("MachinePower")
local evMachine2 = EventsFolder and EventsFolder:FindFirstChild("MachinePower2")
local evRune     = EventsFolder and EventsFolder:FindFirstChild("CreateRune")
local evPrestige = EventsFolder and EventsFolder:FindFirstChild("Prestige")

--============================================================
-- 17. MAIN TAB TOGGLES
--============================================================

local ToggleCollector = makeToggle(MainFrame, 0, "Object Collector")
local ToggleAFK = makeToggle(MainFrame, 50, "Anti-AFK")
local ToggleWS = makeToggle(MainFrame, 100, "WalkSpeed 100")

--============================================================
-- 18. OBJECT COLLECTOR
--============================================================

local function setCollectorVisual(on)
	if on then
		ToggleCollector.Text = "Object Collector: ON"
		ToggleCollector.BackgroundColor3 = Color3.fromRGB(40, 0, 120)
		ToggleCollector.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		ToggleCollector.Text = "Object Collector: OFF"
		ToggleCollector.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
		ToggleCollector.TextColor3 = Color3.fromRGB(180, 220, 255)
	end
end

local function collectorLoop()
	while collectorRunning and Gui.Parent do
		local folder = Workspace:FindFirstChild("Objects")

		if folder and evCollect then
			for _, obj in ipairs(folder:GetChildren()) do
				local id = tonumber(obj.Name)

				if id then
					pcall(function()
						evCollect:FireServer(id)
						obj:Destroy()
					end)
				end
			end
		end

		task.wait()
	end
end

ToggleCollector.MouseButton1Click:Connect(function()
	if justDragged() then return end

	collectorRunning = not collectorRunning
	setCollectorVisual(collectorRunning)

	if collectorRunning then
		if collectorThread then
			task.cancel(collectorThread)
		end

		collectorThread = task.spawn(collectorLoop)
	else
		if collectorThread then
			task.cancel(collectorThread)
			collectorThread = nil
		end
	end
end)

setCollectorVisual(false)

--============================================================
-- 19. ANTI AFK
--============================================================

local function setAFKVisual(on)
	if on then
		ToggleAFK.Text = "Anti-AFK: ON"
		ToggleAFK.BackgroundColor3 = Color3.fromRGB(0, 110, 90)
		ToggleAFK.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		ToggleAFK.Text = "Anti-AFK: OFF"
		ToggleAFK.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
		ToggleAFK.TextColor3 = Color3.fromRGB(180, 220, 255)
	end
end

local function afkLoop()
	while afkRunning and Gui.Parent do
		task.wait(10)

		if not afkRunning or not Gui.Parent then
			break
		end

		pcall(function()
			VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
			task.wait(0.08)
			VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
		end)

		local character = Player.Character or Player.CharacterAdded:Wait()
		local hum = character:FindFirstChildOfClass("Humanoid")

		if hum then
			hum.Jump = true
		end
	end
end

ToggleAFK.MouseButton1Click:Connect(function()
	if justDragged() then return end

	afkRunning = not afkRunning
	setAFKVisual(afkRunning)

	if afkRunning then
		if afkThread then
			task.cancel(afkThread)
		end

		afkThread = task.spawn(afkLoop)
	else
		if afkThread then
			task.cancel(afkThread)
			afkThread = nil
		end
	end
end)

setAFKVisual(false)

--============================================================
-- 20. WALKSPEED 100
--============================================================

local DEFAULT_WS = 16
local WS_VALUE = 100
local WS_INTERVAL = 0.01

local function setWSVisual(on)
	if on then
		ToggleWS.Text = "WalkSpeed 100: ON"
		ToggleWS.BackgroundColor3 = Color3.fromRGB(90, 190, 255)
		ToggleWS.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		ToggleWS.Text = "WalkSpeed 100: OFF"
		ToggleWS.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
		ToggleWS.TextColor3 = Color3.fromRGB(180, 220, 255)
	end
end

local function applyWalkSpeedLoop()
	while wsRunning and Gui.Parent do
		local char = Player.Character or Player.CharacterAdded:Wait()
		local hum = char:FindFirstChildOfClass("Humanoid")

		if hum then
			hum.WalkSpeed = WS_VALUE
		end

		task.wait(WS_INTERVAL)
	end
end

ToggleWS.MouseButton1Click:Connect(function()
	if justDragged() then return end

	wsRunning = not wsRunning
	setWSVisual(wsRunning)

	if wsRunning then
		if wsThread then
			task.cancel(wsThread)
		end

		wsThread = task.spawn(applyWalkSpeedLoop)
	else
		if wsThread then
			task.cancel(wsThread)
			wsThread = nil
		end

		local char = Player.Character or Player.CharacterAdded:Wait()
		local hum = char:FindFirstChildOfClass("Humanoid")

		if hum then
			hum.WalkSpeed = DEFAULT_WS
		end
	end
end)

setWSVisual(false)

--============================================================
-- 21. CLICKERS TAB TOGGLES
--============================================================

local ToggleMining = makeToggle(ClickersFrame, 0, "Meteorite Mining")
local ToggleMachine = makeToggle(ClickersFrame, 50, "Electric Machine")
local ToggleMachine2 = makeToggle(ClickersFrame, 100, "Electric Machine 2000")
local ToggleRune = makeToggle(ClickersFrame, 150, "Auto Rune WIP")
local ToggleTungsten = makeToggle(ClickersFrame, 200, "Auto Tungsten WIP")

--============================================================
-- 22. MINING / MACHINE VISUALS
--============================================================

local function setMiningVisual(on)
	if on then
		ToggleMining.Text = "Meteorite Mining: ON"
		ToggleMining.BackgroundColor3 = Color3.fromRGB(80, 0, 140)
		ToggleMining.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		ToggleMining.Text = "Meteorite Mining: OFF"
		ToggleMining.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
		ToggleMining.TextColor3 = Color3.fromRGB(180, 220, 255)
	end
end

local function setMachineVisual(on)
	if on then
		ToggleMachine.Text = "Electric Machine: ON"
		ToggleMachine.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
		ToggleMachine.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		ToggleMachine.Text = "Electric Machine: OFF"
		ToggleMachine.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
		ToggleMachine.TextColor3 = Color3.fromRGB(180, 220, 255)
	end
end

local function setMachine2Visual(on)
	if on then
		ToggleMachine2.Text = "Electric Machine 2000: ON"
		ToggleMachine2.BackgroundColor3 = Color3.fromRGB(0, 160, 120)
		ToggleMachine2.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		ToggleMachine2.Text = "Electric Machine 2000: OFF"
		ToggleMachine2.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
		ToggleMachine2.TextColor3 = Color3.fromRGB(180, 220, 255)
	end
end

local function stopMineMach()
	if miningConn then
		miningConn:Disconnect()
		miningConn = nil
	end

	if machineConn then
		machineConn:Disconnect()
		machineConn = nil
	end

	if machine2Conn then
		machine2Conn:Disconnect()
		machine2Conn = nil
	end

	miningRunning = false
	machineRunning = false
	machine2Running = false

	setMiningVisual(false)
	setMachineVisual(false)
	setMachine2Visual(false)
end

--============================================================
-- 23. METEORITE MINING
--============================================================

local mine_acc = 0
local mine_pts = {}
local mine_idx = 1
local mine_hitbox = nil

local function getMiningHitbox()
	local mining = workspace:FindFirstChild("Mining")
	if not mining then return nil end

	local hb = mining:FindFirstChild("MiningHitbox")

	if hb and hb:IsA("Model") then
		return hb
	end

	return nil
end

local function fireMineRemote()
	if not (evMine and evMine:IsA("RemoteEvent")) then
		return
	end

	for i = 1, 10 do
		pcall(function()
			evMine:FireServer(i)
		end)
	end
end

local function startMining()
	if miningRunning then return end

	stopMineMach()

	miningRunning = true
	mine_acc = 0
	mine_pts = {}
	mine_idx = 1
	mine_hitbox = nil

	miningConn = RunService.Heartbeat:Connect(function(dt)
		if not miningRunning then return end

		mine_acc += dt

		while mine_acc >= INTERVAL do
			mine_acc -= INTERVAL
			fireMineRemote()

			if not mine_hitbox or not mine_hitbox.Parent then
				mine_hitbox = getMiningHitbox()
				mine_pts = {}
				mine_idx = 1
			end

			if mine_hitbox then
				if #mine_pts == 0 then
					mine_pts = getScreenPointsFromModel(mine_hitbox)
					mine_idx = 1
				end

				local p = mine_pts[mine_idx]

				if p then
					clickAt(p.X, p.Y)
				end

				mine_idx = (mine_idx % math.max(1, #mine_pts)) + 1
			end
		end
	end)
end

local function stopMining()
	if not miningRunning then return end

	miningRunning = false

	if miningConn then
		miningConn:Disconnect()
		miningConn = nil
	end
end

ToggleMining.MouseButton1Click:Connect(function()
	if justDragged() then return end

	if miningRunning then
		stopMining()
		setMiningVisual(false)
	else
		startMining()
		setMiningVisual(true)
	end
end)

setMiningVisual(false)

--============================================================
-- 24. ELECTRIC MACHINE
--============================================================

local mach_acc = 0
local mach_model = nil
local mach_pts = {}
local mach_idx = 1

local function getMachineModel()
	local upgrade = workspace:FindFirstChild("UpgradeBoards")
	if not upgrade then return nil end

	local machine = upgrade:FindFirstChild("Machine")

	if machine and machine:IsA("Model") then
		return machine
	end

	return nil
end

local function fireMachineRemote()
	if evMachine and evMachine:IsA("RemoteEvent") then
		pcall(function()
			evMachine:FireServer()
		end)
	end
end

local function startMachine()
	if machineRunning then return end

	stopMineMach()

	machineRunning = true
	mach_acc = 0
	mach_model = nil
	mach_pts = {}
	mach_idx = 1

	machineConn = RunService.Heartbeat:Connect(function(dt)
		if not machineRunning then return end

		mach_acc += dt

		while mach_acc >= INTERVAL do
			mach_acc -= INTERVAL
			fireMachineRemote()

			if not mach_model or not mach_model.Parent then
				mach_model = getMachineModel()
				mach_pts = {}
				mach_idx = 1
			end

			if mach_model then
				if #mach_pts == 0 then
					mach_pts = getScreenPointsFromModel(mach_model)
					mach_idx = 1
				end

				local p = mach_pts[mach_idx]

				if p then
					clickAt(p.X, p.Y)
				end

				mach_idx = (mach_idx % math.max(1, #mach_pts)) + 1
			end
		end
	end)
end

local function stopMachine()
	if not machineRunning then return end

	machineRunning = false

	if machineConn then
		machineConn:Disconnect()
		machineConn = nil
	end
end

ToggleMachine.MouseButton1Click:Connect(function()
	if justDragged() then return end

	if machineRunning then
		stopMachine()
		setMachineVisual(false)
	else
		startMachine()
		setMachineVisual(true)
	end
end)

setMachineVisual(false)

--============================================================
-- 25. ELECTRIC MACHINE 2000
--============================================================

local mach2_acc = 0
local mach2_model = nil
local mach2_pts = {}
local mach2_idx = 1

local function fireMachineRemote2()
	if evMachine2 and evMachine2:IsA("RemoteEvent") then
		pcall(function()
			evMachine2:FireServer()
		end)
	end
end

local function startMachine2()
	if machine2Running then return end

	stopMineMach()

	machine2Running = true
	mach2_acc = 0
	mach2_model = nil
	mach2_pts = {}
	mach2_idx = 1

	machine2Conn = RunService.Heartbeat:Connect(function(dt)
		if not machine2Running then return end

		mach2_acc += dt

		while mach2_acc >= INTERVAL do
			mach2_acc -= INTERVAL
			fireMachineRemote2()

			if not mach2_model or not mach2_model.Parent then
				mach2_model = getMachineModel()
				mach2_pts = {}
				mach2_idx = 1
			end

			if mach2_model then
				if #mach2_pts == 0 then
					mach2_pts = getScreenPointsFromModel(mach2_model)
					mach2_idx = 1
				end

				local p = mach2_pts[mach2_idx]

				if p then
					clickAt(p.X, p.Y)
				end

				mach2_idx = (mach2_idx % math.max(1, #mach2_pts)) + 1
			end
		end
	end)
end

local function stopMachine2()
	if not machine2Running then return end

	machine2Running = false

	if machine2Conn then
		machine2Conn:Disconnect()
		machine2Conn = nil
	end
end

ToggleMachine2.MouseButton1Click:Connect(function()
	if justDragged() then return end

	if machine2Running then
		stopMachine2()
		setMachine2Visual(false)
	else
		startMachine2()
		setMachine2Visual(true)
	end
end)

setMachine2Visual(false)

--============================================================
-- 26. AUTO RUNE WIP
--============================================================

local rune_acc = 0
local FORCE_RANGE = 1e6

local function getRunePart()
	local up = workspace:FindFirstChild("UpgradeBoards")

	if up and up:FindFirstChild("Runes") then
		local p = up.Runes:FindFirstChild("CreateRune")

		if p and p:IsA("BasePart") then
			return p
		end
	end

	for _, d in ipairs(workspace:GetDescendants()) do
		if d.Name == "CreateRune" and d:IsA("BasePart") then
			return d
		end
	end
end

local function onScreenPoint(part)
	local sp, on = Camera:WorldToViewportPoint(part.Position)

	if on then
		return Vector2.new(sp.X, sp.Y)
	end
end

local function setRuneVisual(on)
	if on then
		ToggleRune.Text = "Auto Rune WIP: ON"
		ToggleRune.BackgroundColor3 = Color3.fromRGB(100, 40, 160)
		ToggleRune.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		ToggleRune.Text = "Auto Rune WIP: OFF"
		ToggleRune.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
		ToggleRune.TextColor3 = Color3.fromRGB(180, 220, 255)
	end
end

local function startRune()
	if runeRunning then return end

	runeRunning = true
	rune_acc = 0

	runeConn = RunService.Heartbeat:Connect(function(dt)
		if not runeRunning then return end

		rune_acc += dt

		while rune_acc >= RUNE_INTERVAL do
			rune_acc -= RUNE_INTERVAL

			if not evRune or not evRune.Parent then
				local evs = ReplicatedStorage:FindFirstChild("Events")
				evRune = evs and evs:FindFirstChild("CreateRune") or nil
			end

			if evRune then
				pcall(function()
					evRune:FireServer()
				end)
			end

			local part = getRunePart()

			if part then
				local cd = part:FindFirstChildOfClass("ClickDetector")

				if cd then
					pcall(function()
						cd.MaxActivationDistance = FORCE_RANGE
					end)
				end

				local pt = onScreenPoint(part)

				if pt then
					clickAt(pt.X, pt.Y)
				end
			end
		end
	end)
end

local function stopRune()
	if not runeRunning then return end

	runeRunning = false

	if runeConn then
		runeConn:Disconnect()
		runeConn = nil
	end
end

ToggleRune.MouseButton1Click:Connect(function()
	if justDragged() then return end

	if runeRunning then
		stopRune()
		setRuneVisual(false)
	else
		startRune()
		setRuneVisual(true)
	end
end)

setRuneVisual(false)

--============================================================
-- 27. AUTO TUNGSTEN WIP
--============================================================

local tung_acc = 0

local function getTungstenPart()
	local t = workspace:FindFirstChild("Tungsten")

	if t then
		local p = t:FindFirstChild("Prestige")

		if p and p:IsA("BasePart") then
			return p
		end
	end

	for _, d in ipairs(workspace:GetDescendants()) do
		if d.Name == "Prestige" and d:IsA("BasePart") and (not t or d:IsDescendantOf(t)) then
			return d
		end
	end
end

local function setTungVisual(on)
	if on then
		ToggleTungsten.Text = "Auto Tungsten WIP: ON"
		ToggleTungsten.BackgroundColor3 = Color3.fromRGB(120, 60, 160)
		ToggleTungsten.TextColor3 = Color3.fromRGB(255, 255, 255)
	else
		ToggleTungsten.Text = "Auto Tungsten WIP: OFF"
		ToggleTungsten.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
		ToggleTungsten.TextColor3 = Color3.fromRGB(180, 220, 255)
	end
end

local function startTungsten()
	if tungRunning then return end

	tungRunning = true
	tung_acc = 0

	tungConn = RunService.Heartbeat:Connect(function(dt)
		if not tungRunning then return end

		tung_acc += dt

		while tung_acc >= TUNG_INTERVAL do
			tung_acc -= TUNG_INTERVAL

			local part = getTungstenPart()

			if not part then
				break
			end

			local cd = part:FindFirstChildOfClass("ClickDetector")

			if cd then
				pcall(function()
					cd.MaxActivationDistance = math.huge
				end)
			end

			if not evPrestige or not evPrestige.Parent then
				local evs = ReplicatedStorage:FindFirstChild("Events")
				evPrestige = evs and evs:FindFirstChild("Prestige") or nil
			end

			if evPrestige then
				pcall(function()
					evPrestige:FireServer()
				end)
			end

			local sp, on = Camera:WorldToViewportPoint(part.Position)

			if on then
				clickAt(sp.X, sp.Y)
			end
		end
	end)
end

local function stopTungsten()
	if not tungRunning then return end

	tungRunning = false

	if tungConn then
		tungConn:Disconnect()
		tungConn = nil
	end
end

ToggleTungsten.MouseButton1Click:Connect(function()
	if justDragged() then return end

	if tungRunning then
		stopTungsten()
		setTungVisual(false)
	else
		startTungsten()
		setTungVisual(true)
	end
end)

setTungVisual(false)

--============================================================
-- 28. FOOTERS
--============================================================

local FooterCommon = Instance.new("TextLabel")
FooterCommon.BackgroundTransparency = 1
FooterCommon.Size = UDim2.new(1, -24, 0, 32)
FooterCommon.Position = UDim2.new(0, 12, 1, -36)
FooterCommon.TextWrapped = true
FooterCommon.Font = Enum.Font.GothamSemibold
FooterCommon.TextSize = 12
FooterCommon.TextColor3 = Color3.fromRGB(140, 190, 220)
FooterCommon.TextXAlignment = Enum.TextXAlignment.Left
FooterCommon.TextYAlignment = Enum.TextYAlignment.Top
FooterCommon.Text = "Credit: Chimera__Gaming  |\nAdjust click speeds to match server limits"
FooterCommon.Parent = Panel

local FooterClickers = Instance.new("TextLabel")
FooterClickers.BackgroundTransparency = 1
FooterClickers.Size = UDim2.new(1, -24, 0, 16)
FooterClickers.Position = UDim2.new(0, 12, 1, -54)
FooterClickers.Font = Enum.Font.GothamSemibold
FooterClickers.TextSize = 12
FooterClickers.TextColor3 = Color3.fromRGB(200, 170, 255)
FooterClickers.TextXAlignment = Enum.TextXAlignment.Left
FooterClickers.Text = "WIP: Clickers need player nearby"
FooterClickers.Visible = false
FooterClickers.Parent = Panel

--============================================================
-- 29. TAB WIRING
--============================================================

local function tweenPanelHeight(h)
	TweenService:Create(
		Panel,
		TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = UDim2.fromOffset(PANEL_W, h)}
	):Play()
end

local function showMain()
	MainFrame.Visible = true
	ClickersFrame.Visible = false

	setActiveTab(TabMain, true)
	setActiveTab(TabClickers, false)

	FooterClickers.Visible = false

	tweenPanelHeight(PANEL_H_MAIN)
end

local function showClickers()
	MainFrame.Visible = false
	ClickersFrame.Visible = true

	setActiveTab(TabMain, false)
	setActiveTab(TabClickers, true)

	FooterClickers.Visible = true

	tweenPanelHeight(PANEL_H_CLICKERS)
end

TabMain.MouseButton1Click:Connect(function()
	if justDragged() then return end
	showMain()
end)

TabClickers.MouseButton1Click:Connect(function()
	if justDragged() then return end
	showClickers()
end)

showMain()

--============================================================
-- 30. MINIMIZE ROCKET BUBBLE
--============================================================

local Bubble = nil
local savedPanelPos = Panel.Position
local savedBubblePos = UDim2.new(0.5, -23, 0.1, 0)

local function makeBubble()
	if Bubble and Bubble.Parent then
		return
	end

	Bubble = Instance.new("TextButton")
	Bubble.Name = "RocketBubble"
	Bubble.Size = UDim2.fromOffset(46, 46)
	Bubble.Position = savedBubblePos
	Bubble.BackgroundColor3 = Color3.fromRGB(20, 24, 44)
	Bubble.BorderSizePixel = 0
	Bubble.Text = "🚀"
	Bubble.Font = Enum.Font.GothamBold
	Bubble.TextSize = 26
	Bubble.TextColor3 = Color3.fromRGB(180, 230, 255)
	Bubble.AutoButtonColor = false
	Bubble.Parent = Gui

	Instance.new("UICorner", Bubble).CornerRadius = UDim.new(1, 0)

	local s = Instance.new("UIStroke")
	s.Thickness = 2
	s.Color = Color3.fromRGB(0, 200, 255)
	s.Parent = Bubble

	local bDragging = false
	local bDidDrag = false
	local bStart = nil
	local bPos = nil

	Bubble.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			bDragging = true
			bDidDrag = false
			bStart = UIS:GetMouseLocation()
			bPos = Bubble.Position
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if bDragging and input.UserInputType == Enum.UserInputType.MouseMovement and bStart and bPos and Bubble and Bubble.Parent then
			local m = UIS:GetMouseLocation()
			local dx = m.X - bStart.X
			local dy = m.Y - bStart.Y

			if math.abs(dx) > THRESH or math.abs(dy) > THRESH then
				bDidDrag = true
			end

			Bubble.Position = UDim2.new(
				bPos.X.Scale,
				bPos.X.Offset + dx,
				bPos.Y.Scale,
				bPos.Y.Offset + dy
			)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and bDragging then
			bDragging = false
			savedBubblePos = Bubble.Position
		end
	end)

	Bubble.MouseButton1Click:Connect(function()
		if bDidDrag then
			return
		end

		savedBubblePos = Bubble.Position

		if Bubble then
			Bubble:Destroy()
			Bubble = nil
		end

		Panel.Visible = true
		Panel.Position = savedPanelPos
	end)
end

Min.MouseButton1Click:Connect(function()
	if justDragged() then return end

	savedPanelPos = Panel.Position
	Panel.Visible = false

	makeBubble()
end)

--============================================================
-- 31. CLOSE / CLEANUP
--============================================================

local function cleanupAll()
	collectorRunning = false
	afkRunning = false
	wsRunning = false
	miningRunning = false
	machineRunning = false
	machine2Running = false
	runeRunning = false
	tungRunning = false

	if collectorThread then
		task.cancel(collectorThread)
		collectorThread = nil
	end

	if afkThread then
		task.cancel(afkThread)
		afkThread = nil
	end

	if wsThread then
		task.cancel(wsThread)
		wsThread = nil
	end

	if miningConn then
		miningConn:Disconnect()
		miningConn = nil
	end

	if machineConn then
		machineConn:Disconnect()
		machineConn = nil
	end

	if machine2Conn then
		machine2Conn:Disconnect()
		machine2Conn = nil
	end

	if runeConn then
		runeConn:Disconnect()
		runeConn = nil
	end

	if tungConn then
		tungConn:Disconnect()
		tungConn = nil
	end

	local char = Player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")

	if hum then
		hum.WalkSpeed = 16
	end
end

Close.MouseButton1Click:Connect(function()
	if justDragged() then return end

	cleanupAll()

	if Gui then
		Gui:Destroy()
	end
end)

Gui.Destroying:Connect(function()
	cleanupAll()
end)

--============================================================
-- 32. LOADED
--============================================================

print(string.format(
	"[Space Automation] Loaded. Clickers=%d CPS | Rune=%d/s | Tungsten=%d/s",
	CLICKER_CPS,
	RUNE_CPS,
	TUNG_CPS
))
