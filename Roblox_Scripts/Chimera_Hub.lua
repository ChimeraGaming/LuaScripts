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

local scripts = {
	{
		Name = "[✨] Aura Farming Incremental",
		File = "Aura_Farming_Incremental.lua"
	},
	{
		Name = "🌱 Grass Cutting Incremental 🌱",
		File = "GCI.lua"
	},
	{
		Name = "Money Incremental 💸",
		File = "Money_Incremental.lua"
	},
	{
		Name = "🌙 [UPD 5] Moon Incremental",
		File = "Moon_Incremental.lua"
	},
	{
		Name = "Simple UI for copying player coordinates",
		File = "Simple_Copy_Cords.lua"
	},
	{
		Name = "[🌎] Space Incremental",
		File = "Space_Incremental.lua"
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
frame.Size = UDim2.fromOffset(320, 380)
frame.Position = UDim2.new(0.5, -160, 0.5, -190)
frame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 2

--============================================================
-- 06. TITLE
--============================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 36)
title.Position = UDim2.fromOffset(12, 8)
title.BackgroundTransparency = 1
title.Text = "Chimera Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(220, 240, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

--============================================================
-- 07. CLOSE BUTTON
--============================================================

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -38, 0, 8)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.BackgroundColor3 = Color3.fromRGB(80, 25, 35)
close.TextColor3 = Color3.fromRGB(255, 160, 160)
close.Parent = frame

Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

--============================================================
-- 08. BUTTON CREATOR
--============================================================

local function createButton(text, y, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(280, 38)
	button.Position = UDim2.fromOffset(20, y)
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.BackgroundColor3 = Color3.fromRGB(30, 45, 70)
	button.TextColor3 = Color3.fromRGB(235, 245, 255)
	button.Parent = frame

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

	button.MouseButton1Click:Connect(callback)

	return button
end

--============================================================
-- 09. LOAD SCRIPT HELPER
--============================================================

local function loadScript(fileName)
	local url = BASE .. fileName

	local success, result = pcall(function()
		return game:HttpGet(url)
	end)

	if success and result then
		loadstring(result)()
	else
		warn("Failed to load: " .. url)
	end
end

--============================================================
-- 10. SCRIPT BUTTONS
--============================================================

local y = 55

for _, scriptInfo in ipairs(scripts) do
	createButton(scriptInfo.Name, y, function()
		loadScript(scriptInfo.File)
	end)

	y += 45
end

--============================================================
-- 11. CREDIT
--============================================================

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -24, 0, 40)
credit.Position = UDim2.new(0, 12, 1, -48)
credit.BackgroundTransparency = 1
credit.Text = "Credit | Chimera__Gaming\nFREE AT RSCRIPTS"
credit.Font = Enum.Font.Gotham
credit.TextSize = 12
credit.TextColor3 = Color3.fromRGB(160, 210, 235)
credit.TextWrapped = true
credit.Parent = frame

--============================================================
-- 12. DRAGGING
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
-- 13. LOADED
--============================================================

print("[Chimera Hub] Loaded")
