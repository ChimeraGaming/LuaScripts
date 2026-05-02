--============================================================
-- CHIMERA SAVE WORLD GUI
--============================================================

--============================================================
-- CONFIG / ORIGINAL CODE
--============================================================

local CONFIG = {

	-- SaveInstance Source
	Params = {
		RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
		SSI = "saveinstance",
	},

	-- Save Options (EDIT HERE)
	Options = {
		SafeMode = false, -- true = safer but freezes UI
	},

	-- UI / Behavior Settings
	UpdateInterval = 30, -- seconds between file size checks
	StartPercent = 1, -- initial progress %
}

--============================================================
-- SERVICES
--============================================================

local CoreGui = game:GetService("CoreGui")

--============================================================
-- CLEAN OLD GUI
--============================================================

pcall(function()
	if CoreGui:FindFirstChild("ChimeraSaveWorldGUI") then
		CoreGui.ChimeraSaveWorldGUI:Destroy()
	end
end)

--============================================================
-- GUI SETUP
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "ChimeraSaveWorldGUI"
gui.ResetOnSpawn = false
gui.Parent = gethui and gethui() or CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 380, 0, 175)
main.AnchorPoint = Vector2.new(0.5, 0)
main.Position = UDim2.new(0.5, 0, 0, 30)
main.BackgroundColor3 = Color3.fromRGB(22, 24, 28)
main.BorderSizePixel = 0
main.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 36)
title.Position = UDim2.new(0, 12, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Save World"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 32, 0, 32)
close.Position = UDim2.new(1, -38, 0, 6)
close.BackgroundColor3 = Color3.fromRGB(160,45,45)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255,255,255)
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.Parent = main

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 26)
status.Position = UDim2.new(0, 12, 0, 45)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(200,200,200)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

local barBack = Instance.new("Frame")
barBack.Size = UDim2.new(1, -24, 0, 22)
barBack.Position = UDim2.new(0, 12, 0, 75)
barBack.BackgroundColor3 = Color3.fromRGB(60,60,60)
barBack.Parent = main

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(80,220,120)
barFill.Parent = barBack

local percentText = Instance.new("TextLabel")
percentText.Size = UDim2.new(1,0,1,0)
percentText.BackgroundTransparency = 1
percentText.Text = "0%"
percentText.TextColor3 = Color3.fromRGB(255,255,255)
percentText.Font = Enum.Font.GothamBold
percentText.TextSize = 14
percentText.Parent = barBack

local fileSizeText = Instance.new("TextLabel")
fileSizeText.Size = UDim2.new(1, -24, 0, 24)
fileSizeText.Position = UDim2.new(0, 12, 0, 100)
fileSizeText.BackgroundTransparency = 1
fileSizeText.Text = "File size: not started"
fileSizeText.TextColor3 = Color3.fromRGB(180,180,180)
fileSizeText.Font = Enum.Font.Gotham
fileSizeText.TextSize = 13
fileSizeText.TextXAlignment = Enum.TextXAlignment.Left
fileSizeText.Parent = main

local saveButton = Instance.new("TextButton")
saveButton.Size = UDim2.new(1, -24, 0, 30)
saveButton.Position = UDim2.new(0, 12, 0, 135)
saveButton.BackgroundColor3 = Color3.fromRGB(65,120,220)
saveButton.Text = "Save World"
saveButton.TextColor3 = Color3.fromRGB(255,255,255)
saveButton.Font = Enum.Font.GothamBold
saveButton.TextSize = 15
saveButton.Parent = main

--============================================================
-- HELPERS
--============================================================

local saving = false
local percent = 0
local currentSize = 0
local totalSize = 0

local function setProgress(p, txt)
	percent = math.clamp(p, 0, 100)
	barFill.Size = UDim2.new(percent/100,0,1,0)
	percentText.Text = math.floor(percent).."%"
	if txt then status.Text = txt end
end

local function formatBytes(bytes)
	if not bytes or bytes <= 0 then return "0 B" end
	local units = {"B","KB","MB","GB"}
	local size = bytes
	local i = 1
	while size >= 1024 and i < #units do
		size = size / 1024
		i += 1
	end
	return string.format("%.2f %s", size, units[i])
end

local function setFileProgress(size)
	currentSize = size or 0
	if currentSize > totalSize then totalSize = currentSize end

	if totalSize > 0 then
		local calc = math.floor((currentSize / totalSize) * 100)
		if calc > percent then
			setProgress(calc, "Saving... file growing")
		end
		fileSizeText.Text = "File size: "..formatBytes(currentSize).." / "..formatBytes(totalSize)
	else
		fileSizeText.Text = "File size: scanning..."
	end
end

local function getNewestFile()
	if not listfiles then return nil end
	local newest
	pcall(function()
		for _,f in ipairs(listfiles("")) do
			local l = tostring(f):lower()
			if l:find(".rbxl") or l:find(".rbxm") or l:find(".xml") then
				newest = f
			end
		end
	end)
	return newest
end

local function getFileSize(path)
	if not path or not readfile then return 0 end
	local ok,data = pcall(readfile,path)
	if ok and data then return #data end
	return 0
end

--============================================================
-- BUTTONS
--============================================================

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

saveButton.MouseButton1Click:Connect(function()
	if saving then return end
	saving = true

	percent = CONFIG.StartPercent
	currentSize = 0
	totalSize = 0

	saveButton.Text = "Saving..."
	saveButton.BackgroundColor3 = Color3.fromRGB(90,90,90)

	setProgress(percent, "Loading...")
	fileSizeText.Text = "File size: scanning..."

	-- Track file growth
	task.spawn(function()
		while saving do
			task.wait(CONFIG.UpdateInterval)
			local file = getNewestFile()
			local size = getFileSize(file)
			if size > 0 then
				setFileProgress(size)
			end
		end
	end)

	-- Run SaveInstance
	task.spawn(function()
		local ok, err = pcall(function()
			local synsaveinstance = loadstring(
				game:HttpGet(CONFIG.Params.RepoURL..CONFIG.Params.SSI..".luau", true),
				CONFIG.Params.SSI
			)()

			setProgress(2, "Saving world...")
			synsaveinstance(CONFIG.Options)
		end)

		saving = false

		if ok then
			local file = getNewestFile()
			local size = getFileSize(file)

			if file then
				fileSizeText.Text = "Saved to: "..tostring(file)
				status.Text = "Complete | "..formatBytes(size)
			else
				fileSizeText.Text = "Saved, but output path not detected"
				status.Text = "Locate: {Executor} > workspace > File"
			end

			setProgress(100, "Complete")
			saveButton.Text = "Done"
			saveButton.BackgroundColor3 = Color3.fromRGB(50,150,80)
		else
			setProgress(100, "Failed")
			saveButton.Text = "Failed"
			saveButton.BackgroundColor3 = Color3.fromRGB(160,50,50)
			warn(err)
		end
	end)
end)
