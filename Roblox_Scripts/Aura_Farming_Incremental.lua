--============================================================
-- Aura Farming Incremental
-- Credit | Chimera__Gaming
-- FREE AT RSCRIPTS
--============================================================

--============================================================
-- 01. SERVICES
--============================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local UIS               = game:GetService("UserInputService")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--============================================================
-- 02. CLEANUP OLD UI
--============================================================

local old = PlayerGui:FindFirstChild("AuraFarmingUI")
if old then
	old:Destroy()
end

--============================================================
-- 03. FOLDERS AND REMOTES
--============================================================

local EventsFolder = ReplicatedStorage:FindFirstChild("Events")
local evCollect    = EventsFolder and EventsFolder:FindFirstChild("CollectObject")

--============================================================
-- 04. ROOT GUI
--============================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "AuraFarmingUI"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

--============================================================
-- 05. AURA COLORS
--============================================================

local AuraDark      = Color3.fromRGB(18, 9, 35)
local AuraPanel     = Color3.fromRGB(25, 12, 48)
local AuraPanel2    = Color3.fromRGB(38, 18, 70)
local AuraPurple    = Color3.fromRGB(145, 80, 255)
local AuraPink      = Color3.fromRGB(255, 90, 210)
local AuraBlue      = Color3.fromRGB(90, 220, 255)
local AuraText      = Color3.fromRGB(235, 220, 255)
local AuraSoftText  = Color3.fromRGB(190, 170, 255)

--============================================================
-- 06. PANEL
--============================================================

local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.Size = UDim2.fromOffset(280, 250)
Panel.Position = UDim2.new(0.5, -140, 0.35, -125)
Panel.BackgroundColor3 = AuraDark
Panel.BackgroundTransparency = 0.04
Panel.BorderSizePixel = 0
Panel.Active = true
Panel.Parent = Gui

Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 16)

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = AuraPurple
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = Panel

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 10, 55)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(42, 17, 78)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 12, 38))
})
Gradient.Rotation = 35
Gradient.Parent = Panel

--============================================================
-- 07. HEADER
--============================================================

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 36)
Header.Position = UDim2.fromOffset(0, 0)
Header.BackgroundTransparency = 1
Header.Active = true
Header.Parent = Panel

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -82, 1, 0)
Title.Position = UDim2.fromOffset(12, 0)
Title.Text = "[✨] Aura Collector"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextColor3 = AuraText
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

--============================================================
-- 08. CLOSE BUTTON
--============================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(24, 24)
Close.Position = UDim2.new(1, -30, 0, 6)
Close.BackgroundColor3 = Color3.fromRGB(55, 18, 45)
Close.Text = "X"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 13
Close.TextColor3 = Color3.fromRGB(255, 120, 160)
Close.AutoButtonColor = false
Close.Active = true
Close.Parent = Header

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 7)

--============================================================
-- 09. COLLAPSE BUTTON
--============================================================

local Collapse = Instance.new("TextButton")
Collapse.Size = UDim2.fromOffset(24, 24)
Collapse.Position = UDim2.new(1, -58, 0, 6)
Collapse.BackgroundColor3 = Color3.fromRGB(35, 20, 65)
Collapse.Text = "v"
Collapse.Font = Enum.Font.GothamBold
Collapse.TextSize = 16
Collapse.TextColor3 = AuraBlue
Collapse.AutoButtonColor = false
Collapse.Active = true
Collapse.Parent = Header

Instance.new("UICorner", Collapse).CornerRadius = UDim.new(0, 7)

--============================================================
-- 10. PANEL DRAGGING
--============================================================

local panelDragging = false
local panelDragStart
local panelStartPos

local function beginPanelDrag(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		panelDragging = true
		panelDragStart = UIS:GetMouseLocation()
		panelStartPos = Panel.Position
	end
end

Header.InputBegan:Connect(beginPanelDrag)
Title.InputBegan:Connect(beginPanelDrag)

UIS.InputChanged:Connect(function(input)
	if panelDragging and input.UserInputType == Enum.UserInputType.MouseMovement and panelDragStart and panelStartPos then
		local mousePos = UIS:GetMouseLocation()
		local dx = mousePos.X - panelDragStart.X
		local dy = mousePos.Y - panelDragStart.Y

		Panel.Position = UDim2.new(
			panelStartPos.X.Scale,
			panelStartPos.X.Offset + dx,
			panelStartPos.Y.Scale,
			panelStartPos.Y.Offset + dy
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		panelDragging = false
	end
end)

--============================================================
-- 11. BUTTON HELPER
--============================================================

local function makeButton(name, text, y, bgColor, textColor)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, -24, 0, 42)
	btn.Position = UDim2.fromOffset(12, y)
	btn.BackgroundColor3 = bgColor
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.TextColor3 = textColor or AuraText
	btn.AutoButtonColor = false
	btn.Active = true
	btn.Parent = Panel

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 11)

	local btnStroke = Instance.new("UIStroke")
	btnStroke.Thickness = 1
	btnStroke.Color = Color3.fromRGB(95, 55, 155)
	btnStroke.Transparency = 0.35
	btnStroke.Parent = btn

	return btn
end

--============================================================
-- 12. AURA COLLECTOR TOGGLE
--============================================================

local ToggleCollect = makeButton(
	"ToggleCollect",
	"Aura Collector: OFF",
	46,
	AuraPanel2,
	AuraText
)

local collecting = false
local collectThread

local function setCollectVisual(on)
	if on then
		ToggleCollect.Text = "Aura Collector: ON"
		ToggleCollect.BackgroundColor3 = Color3.fromRGB(95, 30, 180)
		ToggleCollect.TextColor3 = Color3.fromRGB(255, 245, 255)
	else
		ToggleCollect.Text = "Aura Collector: OFF"
		ToggleCollect.BackgroundColor3 = AuraPanel2
		ToggleCollect.TextColor3 = AuraText
	end
end

local function collectorLoop()
	while collecting and Gui.Parent do
		local folder = Workspace:FindFirstChild("Objects")

		if folder and evCollect then
			for _, obj in ipairs(folder:GetChildren()) do
				pcall(function()
					local id = tonumber(obj.Name)

					if id then
						evCollect:FireServer(id)
					else
						evCollect:FireServer(obj)
					end

					obj:Destroy()
				end)
			end
		end

		task.wait(0.1)
	end
end

ToggleCollect.MouseButton1Click:Connect(function()
	collecting = not collecting
	setCollectVisual(collecting)

	if collecting then
		if collectThread then
			task.cancel(collectThread)
		end

		collectThread = task.spawn(collectorLoop)
	else
		if collectThread then
			task.cancel(collectThread)
			collectThread = nil
		end
	end
end)

setCollectVisual(false)

--============================================================
-- 13. GIVE DROPS BUTTON
--============================================================

local GiveDrops = makeButton(
	"GiveDrops",
	"Give 100,000 Each Drop",
	96,
	Color3.fromRGB(72, 28, 105),
	Color3.fromRGB(255, 245, 255)
)

local function give100kDrops()
	local stats = Player:FindFirstChild("Stats")

	if not stats then
		return
	end

	for i = 1, 6 do
		local v = stats:FindFirstChild("Drop" .. i)

		if v and typeof(v.Value) == "number" then
			v.Value = v.Value + 100000
		end
	end
end

GiveDrops.MouseButton1Click:Connect(give100kDrops)

--============================================================
-- 14. INFINITE YIELD BUTTON
--============================================================

local InfiniteYield = makeButton(
	"InfiniteYield",
	"Infinite Yield",
	146,
	Color3.fromRGB(42, 24, 90),
	AuraText
)

InfiniteYield.MouseButton1Click:Connect(function()
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
	end)
end)

--============================================================
-- 15. INFINITE YIELD NOTE
--============================================================

local IYNote = Instance.new("TextLabel")
IYNote.BackgroundTransparency = 1
IYNote.Size = UDim2.new(1, -24, 0, 34)
IYNote.Position = UDim2.fromOffset(12, 190)
IYNote.Font = Enum.Font.GothamSemibold
IYNote.TextSize = 12
IYNote.TextColor3 = AuraSoftText
IYNote.TextXAlignment = Enum.TextXAlignment.Left
IYNote.TextYAlignment = Enum.TextYAlignment.Top
IYNote.TextWrapped = true
IYNote.Text = "> Note: Enable Anti AFK inside Infinite Yield for best results."
IYNote.Parent = Panel

--============================================================
-- 16. CREDIT LABEL
--============================================================

local Credit = Instance.new("TextLabel")
Credit.BackgroundTransparency = 1
Credit.Size = UDim2.new(1, -24, 0, 28)
Credit.Position = UDim2.new(0, 12, 1, -32)
Credit.Font = Enum.Font.GothamSemibold
Credit.TextSize = 12
Credit.TextColor3 = Color3.fromRGB(165, 210, 255)
Credit.TextXAlignment = Enum.TextXAlignment.Left
Credit.TextYAlignment = Enum.TextYAlignment.Top
Credit.TextWrapped = true
Credit.Text = "Credit | Chimera__Gaming\nFREE AT RSCRIPTS"
Credit.Parent = Panel

--============================================================
-- 17. COLLAPSE BUBBLE
--============================================================

local Bubble
local savedPanelPos = Panel.Position
local bubblePos = UDim2.new(0.5, -24, 0.1, 0)

local function showBubble()
	if Bubble and Bubble.Parent then
		return
	end

	Bubble = Instance.new("Frame")
	Bubble.Name = "AuraBubble"
	Bubble.Size = UDim2.fromOffset(50, 50)
	Bubble.Position = bubblePos
	Bubble.BackgroundColor3 = AuraPanel
	Bubble.BorderSizePixel = 0
	Bubble.Active = true
	Bubble.Parent = Gui

	Instance.new("UICorner", Bubble).CornerRadius = UDim.new(1, 0)

	local bStroke = Instance.new("UIStroke")
	bStroke.Thickness = 2
	bStroke.Color = AuraPink
	bStroke.Parent = Bubble

	local bGradient = Instance.new("UIGradient")
	bGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(65, 25, 120)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 12, 45))
	})
	bGradient.Rotation = 45
	bGradient.Parent = Bubble

	local Icon = Instance.new("TextButton")
	Icon.Size = UDim2.fromScale(1, 1)
	Icon.BackgroundTransparency = 1
	Icon.Text = "✨"
	Icon.Font = Enum.Font.GothamBold
	Icon.TextSize = 27
	Icon.TextColor3 = Color3.fromRGB(255, 220, 255)
	Icon.AutoButtonColor = false
	Icon.Active = true
	Icon.Parent = Bubble

	local bDragging = false
	local bMoved = false
	local bStart
	local bPos

	local function beginBubbleDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			bDragging = true
			bMoved = false
			bStart = UIS:GetMouseLocation()
			bPos = Bubble.Position
		end
	end

	Bubble.InputBegan:Connect(beginBubbleDrag)
	Icon.InputBegan:Connect(beginBubbleDrag)

	UIS.InputChanged:Connect(function(input)
		if bDragging and input.UserInputType == Enum.UserInputType.MouseMovement and bStart and bPos then
			local mousePos = UIS:GetMouseLocation()
			local dx = mousePos.X - bStart.X
			local dy = mousePos.Y - bStart.Y

			if math.abs(dx) > 3 or math.abs(dy) > 3 then
				bMoved = true
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
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			bDragging = false
			bubblePos = Bubble.Position
		end
	end)

	Icon.MouseButton1Click:Connect(function()
		if bMoved then
			return
		end

		if Bubble then
			Bubble:Destroy()
			Bubble = nil
		end

		Panel.Visible = true
		Panel.Position = savedPanelPos
	end)
end

Collapse.MouseButton1Click:Connect(function()
	savedPanelPos = Panel.Position
	Panel.Visible = false
	showBubble()
end)

--============================================================
-- 18. CLOSE BUTTON BEHAVIOR
--============================================================

Close.MouseButton1Click:Connect(function()
	collecting = false

	if collectThread then
		task.cancel(collectThread)
		collectThread = nil
	end

	Gui:Destroy()
end)

--============================================================
-- 19. LOADED
--============================================================

print("[Aura Farming Incremental] UI Loaded.")
