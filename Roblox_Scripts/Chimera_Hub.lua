--============================================================
-- Chimera Hub
-- Loads scripts from ChimeraGaming/LuaScripts
-- Credit | Chimera__Gaming
--============================================================

--============================================================
-- 01. SERVICES
--============================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--============================================================
-- 02. CLEANUP
--============================================================

local old = PlayerGui:FindFirstChild("ChimeraHub")
if old then
	old:Destroy()
end

--============================================================
-- 03. SCRIPT LINKS
--============================================================

local BASE = "https://raw.githubusercontent.com/ChimeraGaming/LuaScripts/main/Roblox_Scripts/"
local GITHUB_LINK = "https://github.com/ChimeraGaming/LuaScripts"
local HUB_BACKGROUND_IMAGE = "rbxassetid://80879264147094"
local HUB_BUTTON_IMAGE = "rbxassetid://90113253212765"

local tabs = {
	Games = {
		{ Name = "[✨] Aura Farming Incremental", File = "Aura_Farming_Incremental.lua" },
		{ Name = "🌱 Grass Cutting Incremental 🌱", File = "GCI.lua" },
		{ Name = "[🔮] Knowledge Incremental", File = "Knowledge_Incremental.lua" },
		{ Name = "Money Incremental 💸", File = "Money_Incremental.lua" },
		{ Name = "🌙 [UPD 5] Moon Incremental", File = "Moon_Incremental.lua" },
		{ Name = "[🌎] Space Incremental", File = "Space_Incremental.lua" }
	},

	Tools = {
		{ Name = "💾 World Saver", File = "World_Saver.lua" },
		{ Name = "⌛Anti AFK", File = "Anti_AFK.lua" },
		{ Name = "📁Dex Explorer", File = "Dex_Explorer_V2.lua" },
		{ Name = "Simple UI for copying player coordinates", File = "Simple_Copy_Cords.lua" },
		{
			Name = "Infinite Yield",
			Custom = function()
				loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
			end
		}
	},

	Credit = {
		{
			Name = "Copy GitHub Link",
			Custom = function()
				if setclipboard then
					setclipboard(GITHUB_LINK)
					print("[Chimera Hub] GitHub link copied")
				else
					print("[Chimera Hub] GitHub:", GITHUB_LINK)
				end
			end
		}
	}
}

--============================================================
-- 04. ROOT GUI
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "ChimeraHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

--============================================================
-- 05. MAIN WINDOW
--============================================================

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(400, 500)
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Parent = gui

local background = Instance.new("ImageLabel")
background.Name = "HubBackground"
background.Size = UDim2.fromScale(1, 1)
background.BackgroundTransparency = 1
background.Image = HUB_BACKGROUND_IMAGE
background.ScaleType = Enum.ScaleType.Stretch
background.ZIndex = 1
background.Parent = frame

--============================================================
-- 06. TITLE
--============================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.fromOffset(272, 48)
title.Position = UDim2.fromOffset(64, 27)
title.BackgroundTransparency = 1
title.Text = "Chimera Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 226, 166)
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 3
title.Parent = frame

--============================================================
-- 07. CLOSE BUTTON
--============================================================

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(26, 26)
close.Position = UDim2.new(1, -41, 0, 14)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.BackgroundColor3 = Color3.fromRGB(75, 35, 24)
close.TextColor3 = Color3.fromRGB(255, 211, 143)
close.ZIndex = 4
close.Parent = frame

Instance.new("UICorner", close).CornerRadius = UDim.new(1, 0)

local closeStroke = Instance.new("UIStroke")
closeStroke.Color = Color3.fromRGB(146, 91, 47)
closeStroke.Thickness = 1
closeStroke.Parent = close

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

--============================================================
-- 08. BUTTON CREATOR
--============================================================

local function createButton(text, y, callback)
	local container = Instance.new("Frame")
	container.Name = "ScriptButton"
	container.Size = UDim2.fromOffset(340, 48)
	container.Position = UDim2.fromOffset(30, y)
	container.BackgroundTransparency = 1
	container.ZIndex = 2
	container.Parent = frame

	local buttonImage = Instance.new("ImageLabel")
	buttonImage.Name = "Background"
	buttonImage.Size = UDim2.fromScale(1, 1)
	buttonImage.BackgroundTransparency = 1
	buttonImage.Image = HUB_BUTTON_IMAGE
	buttonImage.ScaleType = Enum.ScaleType.Stretch
	buttonImage.ZIndex = 2
	buttonImage.Parent = container

	local button = Instance.new("TextButton")
	button.Name = "Hitbox"
	button.Size = UDim2.new(1, -20, 1, -12)
	button.Position = UDim2.fromOffset(10, 6)
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.BackgroundTransparency = 1
	button.TextColor3 = Color3.fromRGB(255, 235, 195)
	button.TextStrokeColor3 = Color3.fromRGB(35, 15, 8)
	button.TextStrokeTransparency = 0.45
	button.ZIndex = 3
	button.Parent = container

	button.MouseButton1Click:Connect(callback)

	return container
end

--============================================================
-- 09. CREDIT FOOTER
--============================================================

local creditFooter = Instance.new("TextLabel")
creditFooter.Name = "CreditFooter"
creditFooter.Size = UDim2.new(1, -90, 0, 30)
creditFooter.Position = UDim2.fromOffset(45, 416)
creditFooter.BackgroundTransparency = 1
creditFooter.Text = "Credit | Chimera__Gaming\n" .. GITHUB_LINK
creditFooter.Font = Enum.Font.Gotham
creditFooter.TextSize = 10
creditFooter.TextColor3 = Color3.fromRGB(213, 177, 124)
creditFooter.TextWrapped = true
creditFooter.TextXAlignment = Enum.TextXAlignment.Center
creditFooter.TextYAlignment = Enum.TextYAlignment.Center
creditFooter.ZIndex = 5
creditFooter.Parent = frame

--============================================================
-- 10. LOAD SCRIPT HELPER
--============================================================

local function loadScript(fileName)
	local url = BASE .. fileName

	local success, result = pcall(function()
		return game:HttpGet(url)
	end)

	if success and result and result ~= "" then
		local loaded, err = pcall(function()
			loadstring(result)()
		end)

		if not loaded then
			warn("[Chimera Hub] Script error:", fileName, err)
		end
	else
		warn("[Chimera Hub] Failed to load:", fileName)
	end
end

--============================================================
-- 11. TABS SYSTEM
--============================================================

local activeTab = "Games"
local scriptButtons = {}

local function resizeFrameForTab(tabName)
	frame.Size = UDim2.fromOffset(400, 500)
	creditFooter.Position = UDim2.fromOffset(45, 416)
end

local function clearScriptButtons()
	for _, b in ipairs(scriptButtons) do
		b:Destroy()
	end

	table.clear(scriptButtons)
end

local function updateTabColors(g, t, c)
	local activeColor = Color3.fromRGB(255, 222, 145)
	local inactiveColor = Color3.fromRGB(210, 177, 125)

	if activeTab == "Games" then
		g.TextColor3 = activeColor
	else
		g.TextColor3 = inactiveColor
	end

	if activeTab == "Tools" then
		t.TextColor3 = activeColor
	else
		t.TextColor3 = inactiveColor
	end

	if activeTab == "Credit" then
		c.TextColor3 = activeColor
	else
		c.TextColor3 = inactiveColor
	end
end

local function renderTab(tabName, g, t, c)
	activeTab = tabName
	clearScriptButtons()
	resizeFrameForTab(tabName)

	local y = 137

	for _, item in ipairs(tabs[tabName]) do
		local callback = item.File and function()
			loadScript(item.File)
		end or item.Custom

		local btn = createButton(item.Name, y, callback)
		table.insert(scriptButtons, btn)

		y = y + 46
	end

	creditFooter.Visible = true
	creditFooter.ZIndex = 5
	updateTabColors(g, t, c)
end

--============================================================
-- 12. TAB BUTTONS
--============================================================

local gamesTab = Instance.new("TextButton")
gamesTab.Size = UDim2.fromOffset(102, 38)
gamesTab.Position = UDim2.fromOffset(38, 89)
gamesTab.Text = "Games"
gamesTab.ZIndex = 3
gamesTab.Parent = frame

local toolsTab = gamesTab:Clone()
toolsTab.Position = UDim2.fromOffset(149, 89)
toolsTab.Text = "Tools"
toolsTab.Parent = frame

local creditTab = gamesTab:Clone()
creditTab.Position = UDim2.fromOffset(260, 89)
creditTab.Text = "Credit"
creditTab.Parent = frame

for _, btn in ipairs({ gamesTab, toolsTab, creditTab }) do
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.BackgroundTransparency = 1
	btn.TextColor3 = Color3.fromRGB(210, 177, 125)
	btn.TextStrokeColor3 = Color3.fromRGB(35, 15, 8)
	btn.TextStrokeTransparency = 0.55
end

gamesTab.MouseButton1Click:Connect(function()
	renderTab("Games", gamesTab, toolsTab, creditTab)
end)

toolsTab.MouseButton1Click:Connect(function()
	renderTab("Tools", gamesTab, toolsTab, creditTab)
end)

creditTab.MouseButton1Click:Connect(function()
	renderTab("Credit", gamesTab, toolsTab, creditTab)
end)

--============================================================
-- 13. INIT
--============================================================

renderTab("Games", gamesTab, toolsTab, creditTab)

--============================================================
-- 14. DRAGGING
--============================================================

local dragging = false
local dragStart
local startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = UIS:GetMouseLocation()
		startPos = frame.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local mouse = UIS:GetMouseLocation()

		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + mouse.X - dragStart.X,
			startPos.Y.Scale,
			startPos.Y.Offset + mouse.Y - dragStart.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

--============================================================
-- 15. LOADED
--============================================================

print("[Chimera Hub] Loaded")
