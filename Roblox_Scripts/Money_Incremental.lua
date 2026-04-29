--============================================================
-- Chimera Utility Hub
-- Uniform Tabs + Mini Farm Toggles
-- Credit | Chimera__Gaming
-- Found Free at RSCRIPTS
--============================================================

--============================================================
-- 01. CONFIG — GEM / LEAF FARMS
--============================================================

local GEM_PATH    = {"Main","Gems","GemFolder"}
local LEAF_PATH   = {"Main","Leaves","LeafFolder"}

local HOVER_Y     = 2
local YIELD_EVERY = 60

--============================================================
-- 02. CONFIG — QUICKMINE
--============================================================

local DISPLAY_ORES = {"Stone","Coal","Copper","Iron","Silver","Gold","Diamond","Emerald"}

local TP_OFFSET     = Vector3.new(0, 4, 0)
local SCAN_INTERVAL = 0.12
local CAMP_REFRESH  = 0.45

local FILL_TRANS    = 1
local OUTLINE_TRANS = 0

--============================================================
-- 03. CONFIG — TELEPORTS
--============================================================

local TELEPORTS = {
	{"Leaderboards", Vector3.new(-1042,14,471)},
	{"Spawn", Vector3.new(-1054,14,46)},
	{"Runes", Vector3.new(-1049,14,-403)},
	{"Factory", Vector3.new(1693,14,-1201)},
	{"AFK", Vector3.new(1770,14,-1085)},
	{"Reincarnation", Vector3.new(2088,14,-1188)},
	{"Block Breaking", Vector3.new(2270,14,-1027)},
	{"Rings", Vector3.new(-1874,14,4214)},
	{"Tree", Vector3.new(-1896,14,4391)},
	{"Box", Vector3.new(-2157,14,4397)},
	{"Halloween 2025", Vector3.new(-2440,14,4164)},
	{"Cave Gems", Vector3.new(-8377,-242,9775)},
	{"Cave Box", Vector3.new(-8523,-242,9942)},
	{"The Mine", Vector3.new(-7988,-232,10093)},
	{"Pickaxe Upgrades", Vector3.new(-7849,-242,9768)},
	{"Jungle", Vector3.new(-7656,14,719)},
}

--============================================================
-- 04. SERVICES
--============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

--============================================================
-- 05. CHARACTER HELPERS
--============================================================

local function waitForHumanoid()
	local ch = LP.Character or LP.CharacterAdded:Wait()
	local hum = ch:FindFirstChildWhichIsA("Humanoid")

	while not hum do
		ch = LP.Character or LP.CharacterAdded:Wait()
		hum = ch:FindFirstChildWhichIsA("Humanoid")
		task.wait(0.05)
	end

	return hum
end

local function getHRP()
	local ch = LP.Character or LP.CharacterAdded:Wait()
	local p  = ch:FindFirstChild("HumanoidRootPart")

	while not p do
		ch = LP.Character or LP.CharacterAdded:Wait()
		p  = ch:FindFirstChild("HumanoidRootPart")
		task.wait(0.02)
	end

	return p
end

local HRP = getHRP()

LP.CharacterAdded:Connect(function()
	task.wait(0.25)
	HRP = getHRP()
end)

--============================================================
-- 06. DRAG SYSTEM
--============================================================

local function makeDraggable(frame, dragHandle)
	dragHandle = dragHandle or frame

	local dragging, dragStart, startPos = false

	local function update(input)
		local d = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + d.X,
			startPos.Y.Scale,
			startPos.Y.Offset + d.Y
		)
	end

	dragHandle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = i.Position
			startPos = frame.Position

			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			update(i)
		end
	end)
end

--============================================================
-- 07. ROOT GUI
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "Chimera_MultiTab_UI"
gui.ResetOnSpawn = false
gui.Parent = PG

--============================================================
-- 08. MINIMIZE BUBBLE
--============================================================

local bubble = Instance.new("TextButton")
bubble.Size = UDim2.fromOffset(56,56)
bubble.Position = UDim2.new(0,24,0.7,0)
bubble.Text = "💵"
bubble.TextScaled = true
bubble.Visible = false
bubble.BackgroundColor3 = Color3.fromRGB(20,20,20)
bubble.Parent = gui

Instance.new("UICorner", bubble).CornerRadius = UDim.new(1,0)

makeDraggable(bubble)

--============================================================
-- 09. MAIN WINDOW
--============================================================

local window = Instance.new("Frame")
window.Size = UDim2.fromOffset(760,560)
window.Position = UDim2.new(0.5,-380,0.5,-280)
window.BackgroundColor3 = Color3.fromRGB(18,18,22)
window.Parent = gui

Instance.new("UICorner", window).CornerRadius = UDim.new(0,14)

--============================================================
-- 10. TOPBAR
--============================================================

local topbar = Instance.new("Frame", window)
topbar.Size = UDim2.new(1,0,0,44)

local title = Instance.new("TextLabel", topbar)
title.Text = "Chimera Utility Hub"

--============================================================
-- 11. BUTTONS (MIN / CLOSE)
--============================================================

local closeBtn = Instance.new("TextButton", topbar)
closeBtn.Text = "❌"

local minBtn = Instance.new("TextButton", topbar)
minBtn.Text = "💵"

makeDraggable(window, topbar)

--============================================================
-- 12. TAB SYSTEM
--============================================================

local tabRail = Instance.new("Frame", window)
local content = Instance.new("Frame", window)

--============================================================
-- 13. PAGE MANAGEMENT
--============================================================

local pages = {}

local function makePage()
	local p = Instance.new("Frame")
	p.Visible = false
	p.Parent = content
	return p
end

local function showPage(i)
	for k,v in ipairs(pages) do
		v.Visible = (k == i)
	end
end

--============================================================
-- 14. WALKSPEED SYSTEM
--============================================================

local minWS, maxWS, currentWS = 50, 100, 50

task.spawn(function()
	while true do
		local hum = waitForHumanoid()
		if hum then
			hum.WalkSpeed = currentWS
		end
		task.wait(0.05)
	end
end)

--============================================================
-- 15. QUICKMINE CORE
--============================================================

local function tpAndPin(pos)
	local hrp = getHRP()
	local cf = CFrame.new(pos + TP_OFFSET)

	hrp.CFrame = cf
end

--============================================================
-- 16. TELEPORT SYSTEM
--============================================================

local function fastTP(pos)
	local hrp = getHRP()
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
end

--============================================================
-- 17. MINI TOGGLES (💎 🍃)
--============================================================

local function makeMiniToggle(data)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromOffset(56,56)
	holder.Position = data.position
	holder.Parent = gui

	local btn = Instance.new("TextButton", holder)
	btn.Text = data.emoji
	btn.Size = UDim2.fromScale(1,1)

	makeDraggable(holder, btn)

	btn.MouseButton1Click:Connect(function()
		data.onToggle()
	end)
end

--============================================================
-- 18. WINDOW CONTROLS
--============================================================

local function setMinimized(state)
	window.Visible = not state
	bubble.Visible = state
end

minBtn.MouseButton1Click:Connect(function()
	setMinimized(true)
end)

bubble.MouseButton1Click:Connect(function()
	setMinimized(false)
end)

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

--============================================================
-- 19. LOADED
--============================================================

print("[Chimera Utility Hub] Loaded.")
