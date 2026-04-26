--[[
  ⚡ Space Automation — Tabs + Minimize + Auto Rune (WIP) + Auto Tungsten (WIP)
   • Tabs: Main | Clickers
       - Main: Object Collector, Anti-AFK, WalkSpeed 100
       - Clickers: Meteorite Mining, Electric Machine, Electric Machine 2000, Auto Rune (WIP), Auto Tungsten (WIP, 1/s)
   • Auto Rune (WIP): Fires Events.CreateRune @ 2/s + VIM-click if on-screen
   • Auto Tungsten (WIP): Finds workspace.Tungsten.Prestige, bumps ClickDetector range, optionally fires Events.Prestige, then 1 real click/sec
   • Minimize → draggable [🚀] bubble

  Notes:
   - Mining/Machines are mutually exclusive with each other (not with Rune/Tungsten)
   - WalkSpeed 100 auto-enforced while ON (every 0.01s)
   - Credit footer includes a newline before the warning.
]]

------------------------- Services
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

-- === Rates ===
local CLICKER_CPS   = 10        -- mining/machines
local INTERVAL      = 1 / CLICKER_CPS
local RUNE_CPS      = 2         -- rune
local RUNE_INTERVAL = 1 / RUNE_CPS
local TUNG_CPS      = 1         -- tungsten
local TUNG_INTERVAL = 1 / TUNG_CPS

-- panel sizes per tab (shrunk)
local PANEL_W = 280
local PANEL_H_MAIN     = 250     -- smaller main
local PANEL_H_CLICKERS = 370     -- smaller clickers
local PANEL_POS = UDim2.new(0.5, -PANEL_W/2, 0.35, -PANEL_H_MAIN/2)

-- cleanup
local old = PlayerGui:FindFirstChild("SpaceTabsUI"); if old then old:Destroy() end

------------------------- Root GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "SpaceTabsUI"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

------------------------- Panel (draggable)
local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.Size = UDim2.fromOffset(PANEL_W, PANEL_H_MAIN)
Panel.Position = PANEL_POS
Panel.BackgroundColor3 = Color3.fromRGB(10,12,28)
Panel.BackgroundTransparency = 0.05
Panel.BorderSizePixel = 0
Panel.Parent = Gui

Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 12)
local Stroke = Instance.new("UIStroke", Panel)
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0, 200, 255)
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Header
local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -72, 0, 24)
Title.Position = UDim2.fromOffset(12, 6)
Title.Text = "Space Automation"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(150, 230, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

-- Close
local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(22, 22)
Close.Position = UDim2.new(1, -28, 0, 6)
Close.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Close.Text = "✖"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 13
Close.TextColor3 = Color3.fromRGB(255, 100, 100)
Close.AutoButtonColor = false
Close.Parent = Panel
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

-- Minimize
local Min = Instance.new("TextButton")
Min.Size = UDim2.fromOffset(22, 22)
Min.Position = UDim2.new(1, -54, 0, 6)
Min.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Min.Text = "—"
Min.Font = Enum.Font.GothamBold
Min.TextSize = 16
Min.TextColor3 = Color3.fromRGB(150, 200, 255)
Min.AutoButtonColor = false
Min.Parent = Panel
Instance.new("UICorner", Min).CornerRadius = UDim.new(0, 6)

------------------------- Tabs
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

local TabMain     = makeTab(0, "Main")
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

------------------------- Content
local Content = Instance.new("Frame")
Content.BackgroundTransparency = 1
Content.Size = UDim2.new(1, -24, 1, -112) -- a bit more top/bottom padding after shrink
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

------------------------- Dragging
local dragging, didDrag = false, false
local dragStartMouse, startPos
local lastDragAt = 0
local THRESH = 6

local function mouseInPanel()
	local m = UIS:GetMouseLocation()
	local p = Panel.AbsolutePosition
	local s = Panel.AbsoluteSize
	return m.X >= p.X and m.X <= p.X + s.X and m.Y >= p.Y and m.Y <= p.Y + s.Y
end

UIS.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and mouseInPanel() then
		dragging, didDrag = true, false
		dragStartMouse = UIS:GetMouseLocation()
		startPos = Panel.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and dragStartMouse and startPos then
		local m = UIS:GetMouseLocation()
		local dx, dy = m.X - dragStartMouse.X, m.Y - dragStartMouse.Y
		if not didDrag and (math.abs(dx) > THRESH or math.abs(dy) > THRESH) then didDrag = true end
		Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dx, startPos.Y.Scale, startPos.Y.Offset + dy)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if dragging and didDrag then lastDragAt = os.clock() end
		dragging, didDrag, dragStartMouse, startPos = false, false, nil, nil
	end
end)

local function justDragged() return (os.clock() - lastDragAt) < 0.12 end

------------------------- Helpers
local function clickAt(x, y)
	VIM:SendMouseMoveEvent(x, y, game)
	VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
	VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function getScreenPointsFromModel(model)
	local cf, size = model:GetBoundingBox()
	local half = size / 2
	local pts, cx, cy, n = {}, 0, 0, 0
	local corners = {
		Vector3.new(-half.X,-half.Y,-half.Z), Vector3.new(half.X,-half.Y,-half.Z),
		Vector3.new(-half.X, half.Y,-half.Z), Vector3.new(half.X, half.Y,-half.Z),
		Vector3.new(-half.X,-half.Y, half.Z), Vector3.new(half.X,-half.Y,  half.Z),
		Vector3.new(-half.X, half.Y,  half.Z), Vector3.new(half.X, half.Y,  half.Z),
	}
	for _, off in ipairs(corners) do
		local wp = cf:PointToWorldSpace(off)
		local sp, on = Camera:WorldToViewportPoint(wp)
		if on then
			table.insert(pts, Vector2.new(sp.X, sp.Y))
			cx += sp.X; cy += sp.Y; n += 1
		end
	end
	if n > 0 then table.insert(pts, Vector2.new(cx/n, cy/n)) end
	return pts
end

local EventsFolder  = ReplicatedStorage:FindFirstChild("Events")
local evCollect     = EventsFolder and EventsFolder:FindFirstChild("CollectObject")
local evMine        = EventsFolder and EventsFolder:FindFirstChild("Mine")
local evMachine     = EventsFolder and EventsFolder:FindFirstChild("MachinePower")
local evMachine2    = EventsFolder and EventsFolder:FindFirstChild("MachinePower2")
local evRune        = EventsFolder and EventsFolder:FindFirstChild("CreateRune")
local evPrestige    = EventsFolder and EventsFolder:FindFirstChild("Prestige")

------------------------- MAIN TAB
local ToggleCollector  = makeToggle(MainFrame,     0,  "Object Collector")
local ToggleAFK        = makeToggle(MainFrame,    50,  "Anti-AFK")
local ToggleWS         = makeToggle(MainFrame,   100,  "WalkSpeed 100")

-- Object Collector
local collectorRunning, collectorThread = false, nil
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
		if collectorThread then task.cancel(collectorThread) end
		collectorThread = task.spawn(collectorLoop)
	else
		if collectorThread then task.cancel(collectorThread) collectorThread=nil end
	end
end)
setCollectorVisual(false)

-- Anti-AFK
local afkRunning, afkThread = false, nil
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
		if not afkRunning or not Gui.Parent then break end
		pcall(function()
			VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
			task.wait(0.08)
			VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
		end)
		local character = Player.Character or Player.CharacterAdded:Wait()
		local hum = character:FindFirstChildOfClass("Humanoid")
		if hum then hum.Jump = true end
	end
end
ToggleAFK.MouseButton1Click:Connect(function()
	if justDragged() then return end
	afkRunning = not afkRunning
	setAFKVisual(afkRunning)
	if afkRunning then
		if afkThread then task.cancel(afkThread) end
		afkThread = task.spawn(afkLoop)
	else
		if afkThread then task.cancel(afkThread) afkThread=nil end
	end
end)
setAFKVisual(false)

-- WalkSpeed 100
local wsRunning, wsThread = false, nil
local DEFAULT_WS, WS_VALUE, WS_INTERVAL = 16, 100, 0.01
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
		if hum then hum.WalkSpeed = WS_VALUE end
		task.wait(WS_INTERVAL)
	end
end
ToggleWS.MouseButton1Click:Connect(function()
	if justDragged() then return end
	wsRunning = not wsRunning
	setWSVisual(wsRunning)
	if wsRunning then
		if wsThread then task.cancel(wsThread) end
		wsThread = task.spawn(applyWalkSpeedLoop)
	else
		if wsThread then task.cancel(wsThread) wsThread=nil end
		local char = Player.Character or Player.CharacterAdded:Wait()
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = DEFAULT_WS end
	end
end)
setWSVisual(false)

------------------------- CLICKERS TAB
local ToggleMining   = makeToggle(ClickersFrame,   0, "Meteorite Mining")
local ToggleMachine  = makeToggle(ClickersFrame,  50, "Electric Machine")
local ToggleMachine2 = makeToggle(ClickersFrame, 100, "Electric Machine 2000")
local ToggleRune     = makeToggle(ClickersFrame, 150, "Auto Rune (WIP)")
local ToggleTungsten = makeToggle(ClickersFrame, 200, "Auto Tungsten (WIP)")

-- exclusivity for mining/machines
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
	if miningConn then miningConn:Disconnect() miningConn=nil end
	if machineConn then machineConn:Disconnect() machineConn=nil end
	if machine2Conn then machine2Conn:Disconnect() machine2Conn=nil end
	miningRunning, machineRunning, machine2Running = false, false, false
	setMiningVisual(false); setMachineVisual(false); setMachine2Visual(false)
end

-- Mining loop
local miningRunning, miningConn = false, nil
local mine_acc, mine_pts, mine_idx, mine_hitbox = 0, {}, 1, nil
local function getMiningHitbox()
	local mining = workspace:FindFirstChild("Mining")
	if not mining then return nil end
	local hb = mining:FindFirstChild("MiningHitbox")
	if hb and hb:IsA("Model") then return hb end
	return nil
end
local function fireMineRemote()
	if not (evMine and evMine:IsA("RemoteEvent")) then return end
	for i=1,10 do pcall(function() evMine:FireServer(i) end) end
end
local function startMining()
	if miningRunning then return end
	stopMineMach()
	miningRunning = true
	mine_acc, mine_pts, mine_idx, mine_hitbox = 0, {}, 1, nil
	miningConn = RunService.Heartbeat:Connect(function(dt)
		if not miningRunning then return end
		mine_acc += dt
		while mine_acc >= INTERVAL do
			mine_acc -= INTERVAL
			fireMineRemote()
			if not mine_hitbox or not mine_hitbox.Parent then
				mine_hitbox = getMiningHitbox()
				mine_pts, mine_idx = {}, 1
			end
			if mine_hitbox then
				if #mine_pts == 0 then mine_pts = getScreenPointsFromModel(mine_hitbox); mine_idx = 1 end
				local p = mine_pts[mine_idx]
				if p then clickAt(p.X, p.Y) end
				mine_idx = (mine_idx % math.max(1, #mine_pts)) + 1
			end
		end
	end)
end
local function stopMining()
	if not miningRunning then return end
	miningRunning = false
	if miningConn then miningConn:Disconnect() miningConn=nil end
end
ToggleMining.MouseButton1Click:Connect(function()
	if justDragged() then return end
	if miningRunning then stopMining(); setMiningVisual(false)
	else startMining(); setMiningVisual(true) end
end)
setMiningVisual(false)

-- Machine
local machineRunning, machineConn = false, nil
local mach_acc, mach_model, mach_pts, mach_idx = 0, nil, {}, 1
local function getMachineModel()
	local upgrade = workspace:FindFirstChild("UpgradeBoards")
	if not upgrade then return nil end
	local machine = upgrade:FindFirstChild("Machine")
	if machine and machine:IsA("Model") then return machine end
	return nil
end
local function fireMachineRemote()
	if evMachine and evMachine:IsA("RemoteEvent") then pcall(function() evMachine:FireServer() end) end
end
local function startMachine()
	if machineRunning then return end
	stopMineMach()
	machineRunning = true
	mach_acc, mach_model, mach_pts, mach_idx = 0, nil, {}, 1
	machineConn = RunService.Heartbeat:Connect(function(dt)
		if not machineRunning then return end
		mach_acc += dt
		while mach_acc >= INTERVAL do
			mach_acc -= INTERVAL
			fireMachineRemote()
			if not mach_model or not mach_model.Parent then
				mach_model = getMachineModel()
				mach_pts, mach_idx = {}, 1
			end
			if mach_model then
				if #mach_pts == 0 then mach_pts = getScreenPointsFromModel(mach_model); mach_idx = 1 end
				local p = mach_pts[mach_idx]
				if p then clickAt(p.X, p.Y) end
				mach_idx = (mach_idx % math.max(1, #mach_pts)) + 1
			end
		end
	end)
end
local function stopMachine()
	if not machineRunning then return end
	machineRunning = false
	if machineConn then machineConn:Disconnect() machineConn=nil end
end
ToggleMachine.MouseButton1Click:Connect(function()
	if justDragged() then return end
	if machineRunning then stopMachine(); setMachineVisual(false)
	else startMachine(); setMachineVisual(true) end
end)
setMachineVisual(false)

-- Machine 2000
local machine2Running, machine2Conn = false, nil
local mach2_acc, mach2_model, mach2_pts, mach2_idx = 0, nil, {}, 1
local function fireMachineRemote2()
	if evMachine2 and evMachine2:IsA("RemoteEvent") then pcall(function() evMachine2:FireServer() end) end
end
local function startMachine2()
	if machine2Running then return end
	stopMineMach()
	machine2Running = true
	mach2_acc, mach2_model, mach2_pts, mach2_idx = 0, nil, {}, 1
	machine2Conn = RunService.Heartbeat:Connect(function(dt)
		if not machine2Running then return end
		mach2_acc += dt
		while mach2_acc >= INTERVAL do
			mach2_acc -= INTERVAL
			fireMachineRemote2()
			if not mach2_model or not mach2_model.Parent then
				mach2_model = getMachineModel()
				mach2_pts, mach2_idx = {}, 1
			end
			if mach2_model then
				if #mach2_pts == 0 then mach2_pts = getScreenPointsFromModel(mach2_model); mach2_idx = 1 end
				local p = mach2_pts[mach2_idx]
				if p then clickAt(p.X, p.Y) end
				mach2_idx = (mach2_idx % math.max(1, #mach2_pts)) + 1
			end
		end
	end)
end
local function stopMachine2()
	if not machine2Running then return end
	machine2Running = false
	if machine2Conn then machine2Conn:Disconnect() machine2Conn=nil end
end
ToggleMachine2.MouseButton1Click:Connect(function()
	if justDragged() then return end
	if machine2Running then stopMachine2(); setMachine2Visual(false)
	else startMachine2(); setMachine2Visual(true) end
end)
setMachine2Visual(false)

-- Rune (WIP) — 2/s
local runeRunning, runeConn = false, nil
local rune_acc = 0
local FORCE_RANGE = 1e6
local function getRunePart()
	local up = workspace:FindFirstChild("UpgradeBoards")
	if up and up:FindFirstChild("Runes") then
		local p = up.Runes:FindFirstChild("CreateRune")
		if p and p:IsA("BasePart") then return p end
	end
	for _, d in ipairs(workspace:GetDescendants()) do
		if d.Name == "CreateRune" and d:IsA("BasePart") then return d end
	end
end
local function onScreenPoint(part)
	local sp, on = Camera:WorldToViewportPoint(part.Position)
	if on then return Vector2.new(sp.X, sp.Y) end
end
local function setRuneVisual(on)
	if on then
		ToggleRune.Text = "Auto Rune (WIP): ON"
		ToggleRune.BackgroundColor3 = Color3.fromRGB(100, 40, 160)
		ToggleRune.TextColor3 = Color3.fromRGB(255,255,255)
	else
		ToggleRune.Text = "Auto Rune (WIP): OFF"
		ToggleRune.BackgroundColor3 = Color3.fromRGB(30,30,60)
		ToggleRune.TextColor3 = Color3.fromRGB(180,220,255)
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
				local evs = ReplicatedStorage:FindFirstChild("Events"); evRune = evs and evs:FindFirstChild("CreateRune") or nil
			end
			if evRune then pcall(function() evRune:FireServer() end) end
			local part = getRunePart()
			if part then
				local cd = part:FindFirstChildOfClass("ClickDetector")
				if cd then pcall(function() cd.MaxActivationDistance = FORCE_RANGE end) end
				local pt = onScreenPoint(part)
				if pt then clickAt(pt.X, pt.Y) end
			end
		end
	end)
end
local function stopRune()
	if not runeRunning then return end
	runeRunning = false
	if runeConn then runeConn:Disconnect() runeConn=nil end
end
ToggleRune.MouseButton1Click:Connect(function()
	if justDragged() then return end
	if runeRunning then stopRune(); setRuneVisual(false)
	else startRune(); setRuneVisual(true) end
end)
setRuneVisual(false)

-- Tungsten (WIP) — 1/s
local tungRunning, tungConn = false, nil
local tung_acc = 0
local function getTungstenPart()
	local t = workspace:FindFirstChild("Tungsten")
	if t then
		local p = t:FindFirstChild("Prestige")
		if p and p:IsA("BasePart") then return p end
	end
	for _, d in ipairs(workspace:GetDescendants()) do
		if d.Name == "Prestige" and d:IsA("BasePart") and (not t or d:IsDescendantOf(t)) then
			return d
		end
	end
end
local function setTungVisual(on)
	if on then
		ToggleTungsten.Text = "Auto Tungsten (WIP): ON"
		ToggleTungsten.BackgroundColor3 = Color3.fromRGB(120, 60, 160)
		ToggleTungsten.TextColor3 = Color3.fromRGB(255,255,255)
	else
		ToggleTungsten.Text = "Auto Tungsten (WIP): OFF"
		ToggleTungsten.BackgroundColor3 = Color3.fromRGB(30,30,60)
		ToggleTungsten.TextColor3 = Color3.fromRGB(180,220,255)
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
			if not part then break end
			local cd = part:FindFirstChildOfClass("ClickDetector")
			if cd then pcall(function() cd.MaxActivationDistance = math.huge end) end
			if not evPrestige or not evPrestige.Parent then
				local evs = ReplicatedStorage:FindFirstChild("Events"); evPrestige = evs and evs:FindFirstChild("Prestige") or nil
			end
			if evPrestige then pcall(function() evPrestige:FireServer() end) end
			local sp, on = Camera:WorldToViewportPoint(part.Position)
			if on then clickAt(sp.X, sp.Y) end
		end
	end)
end
local function stopTungsten()
	if not tungRunning then return end
	tungRunning = false
	if tungConn then tungConn:Disconnect() tungConn=nil end
end
ToggleTungsten.MouseButton1Click:Connect(function()
	if justDragged() then return end
	if tungRunning then stopTungsten(); setTungVisual(false)
	else startTungsten(); setTungVisual(true) end
end)
setTungVisual(false)

------------------------- Footers
-- Common credit + warning (now with a newline)
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
FooterCommon.Text = "Credit: Chimera__Gaming  |\n⚠ Adjusted click speeds to match server limits"
FooterCommon.Parent = Panel

-- Clickers-only note
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

------------------------- Tab wiring (with per-tab resize)
local function tweenPanelHeight(h)
	TweenService:Create(Panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(PANEL_W, h)}):Play()
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
TabMain.MouseButton1Click:Connect(function() if justDragged() then return end showMain() end)
TabClickers.MouseButton1Click:Connect(function() if justDragged() then return end showClickers() end)
showMain()

------------------------- Minimize → 🚀 bubble
local Bubble
local savedPanelPos = Panel.Position
local function makeBubble()
	if Bubble and Bubble.Parent then return end
	Bubble = Instance.new("Frame")
	Bubble.Name = "RocketBubble"
	Bubble.Size = UDim2.fromOffset(46, 46)
	Bubble.Position = UDim2.new(0.5, -23, 0.1, 0)
	Bubble.BackgroundColor3 = Color3.fromRGB(20, 24, 44)
	Bubble.BorderSizePixel = 0
	Bubble.Parent = Gui
	Instance.new("UICorner", Bubble).CornerRadius = UDim.new(1, 0)
	local s = Instance.new("UIStroke", Bubble); s.Thickness = 2; s.Color = Color3.fromRGB(0, 200, 255)
	local Icon = Instance.new("TextButton")
	Icon.Size = UDim2.fromScale(1, 1)
	Icon.BackgroundTransparency = 1
	Icon.Text = "🚀"
	Icon.Font = Enum.Font.GothamBold
	Icon.TextSize = 26
	Icon.TextColor3 = Color3.fromRGB(180, 230, 255)
	Icon.AutoButtonColor = false
	Icon.Parent = Bubble
	-- drag bubble
	local bDragging, bStart, bPos
	local function mouseInBubble()
		local m = UIS:GetMouseLocation()
		local p = Bubble.AbsolutePosition
		local s = Bubble.AbsoluteSize
		return m.X >= p.X and m.X <= p.X + s.X and m.Y >= p.Y and m.Y <= p.Y + s.Y
	end
	UIS.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 and Bubble and Bubble.Parent and mouseInBubble() then
			bDragging = true; bStart = UIS:GetMouseLocation(); bPos = Bubble.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if bDragging and i.UserInputType==Enum.UserInputType.MouseMovement and Bubble and Bubble.Parent then
			local m=UIS:GetMouseLocation(); local dx,dy=m.X-bStart.X, m.Y-bStart.Y
			Bubble.Position = UDim2.new(bPos.X.Scale, bPos.X.Offset+dx, bPos.Y.Scale, bPos.Y.Offset+dy)
		end
	end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then bDragging=false end end)
	Icon.MouseButton1Click:Connect(function()
		if Bubble then Bubble:Destroy() Bubble=nil end
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

------------------------- Close wiring
Close.MouseButton1Click:Connect(function()
	if justDragged() then return end
	collectorRunning = false; if collectorThread then task.cancel(collectorThread) collectorThread=nil end
	local function safe(f) if f then f() end end
	safe(function() miningConn:Disconnect() end)
	safe(function() machineConn:Disconnect() end)
	safe(function() machine2Conn:Disconnect() end)
	safe(function() runeConn:Disconnect() end)
	safe(function() tungConn:Disconnect() end)
	afkRunning = false; if afkThread then task.cancel(afkThread) afkThread=nil end
	wsRunning = false; if wsThread then task.cancel(wsThread) wsThread=nil end
	local char = Player.Character or Player.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = 16 end
	Gui:Destroy()
end)

print(string.format(
  "[Space Automation] Loaded. Clickers=%d CPS | Rune=%d/s | Tungsten=%d/s",
  CLICKER_CPS, RUNE_CPS, TUNG_CPS
))
