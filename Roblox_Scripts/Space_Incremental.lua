--============================================================
-- Space Automation UI
-- Tabs + Minimize + Clickers + WIP Systems
-- Credit | Chimera__Gaming
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
-- 02. RATES / TIMING
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

local PANEL_H_MAIN     = 250
local PANEL_H_CLICKERS = 370

local PANEL_POS = UDim2.new(0.5, -PANEL_W/2, 0.35, -PANEL_H_MAIN/2)

--============================================================
-- 04. CLEANUP
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
-- 06. MAIN PANEL
--============================================================

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

--============================================================
-- 07. HEADER
--============================================================

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

--============================================================
-- 08. WINDOW BUTTONS
--============================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(22, 22)
Close.Position = UDim2.new(1, -28, 0, 6)
Close.Text = "✖"
Close.Parent = Panel

local Min = Instance.new("TextButton")
Min.Size = UDim2.fromOffset(22, 22)
Min.Position = UDim2.new(1, -54, 0, 6)
Min.Text = "—"
Min.Parent = Panel

--============================================================
-- 09. TAB SYSTEM
--============================================================

local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(1, -24, 0, 30)
Tabs.Position = UDim2.fromOffset(12, 34)
Tabs.BackgroundTransparency = 1
Tabs.Parent = Panel

local function makeTab(x, label)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(120, 26)
	b.Position = UDim2.fromOffset(x, 2)
	b.Text = label
	b.Parent = Tabs
	return b
end

local TabMain     = makeTab(0, "Main")
local TabClickers = makeTab(130, "Clickers")

--============================================================
-- 10. CONTENT FRAMES
--============================================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -24, 1, -112)
Content.Position = UDim2.fromOffset(12, 66)
Content.BackgroundTransparency = 1
Content.Parent = Panel

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromScale(1,1)
MainFrame.Parent = Content

local ClickersFrame = Instance.new("Frame")
ClickersFrame.Size = UDim2.fromScale(1,1)
ClickersFrame.Visible = false
ClickersFrame.Parent = Content

--============================================================
-- 11. TOGGLE HELPER
--============================================================

local function makeToggle(parent, y, label)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 42)
	b.Position = UDim2.fromOffset(0, y)
	b.Text = label .. ": OFF"
	b.Parent = parent
	return b
end

--============================================================
-- 12. MAIN TAB TOGGLES
--============================================================

local ToggleCollector = makeToggle(MainFrame, 0,   "Object Collector")
local ToggleAFK       = makeToggle(MainFrame, 50,  "Anti-AFK")
local ToggleWS        = makeToggle(MainFrame, 100, "WalkSpeed 100")

--============================================================
-- 13. CLICKER TAB TOGGLES
--============================================================

local ToggleMining   = makeToggle(ClickersFrame, 0,   "Meteorite Mining")
local ToggleMachine  = makeToggle(ClickersFrame, 50,  "Electric Machine")
local ToggleMachine2 = makeToggle(ClickersFrame, 100, "Electric Machine 2000")
local ToggleRune     = makeToggle(ClickersFrame, 150, "Auto Rune (WIP)")
local ToggleTungsten = makeToggle(ClickersFrame, 200, "Auto Tungsten (WIP)")

--============================================================
-- 14. HELPER FUNCTIONS
--============================================================

local function clickAt(x, y)
	VIM:SendMouseMoveEvent(x, y, game)
	VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
	VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

--============================================================
-- 15. TAB SWITCHING
--============================================================

local function showMain()
	MainFrame.Visible = true
	ClickersFrame.Visible = false
end

local function showClickers()
	MainFrame.Visible = false
	ClickersFrame.Visible = true
end

TabMain.MouseButton1Click:Connect(showMain)
TabClickers.MouseButton1Click:Connect(showClickers)

--============================================================
-- 16. MINIMIZE SYSTEM
--============================================================

local Bubble

local function makeBubble()
	Bubble = Instance.new("Frame")
	Bubble.Size = UDim2.fromOffset(46,46)
	Bubble.Parent = Gui
end

Min.MouseButton1Click:Connect(function()
	Panel.Visible = false
	makeBubble()
end)

--============================================================
-- 17. CLOSE SYSTEM
--============================================================

Close.MouseButton1Click:Connect(function()
	Gui:Destroy()
end)

--============================================================
-- 18. LOADED
--============================================================

print("[Space Automation] Loaded")
