-- Simple Compact Coords UI
-- Built by Chimera__Gaming

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- Clean up if re-run
local old = pg:FindFirstChild("SimpleCoordsUI")
if old then old:Destroy() end

-- Root
local gui = Instance.new("ScreenGui")
gui.Name = "SimpleCoordsUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = pg

-- Window (smaller)
local window = Instance.new("Frame")
window.Name = "Window"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5)
window.Size = UDim2.fromOffset(240, 120)
window.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
window.BorderSizePixel = 0
window.Active = true
window.Parent = gui
local corner = Instance.new("UICorner", window); corner.CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", window); stroke.Thickness = 1; stroke.Color = Color3.fromRGB(80, 80, 90)

-- Credit
local credit = Instance.new("TextLabel")
credit.BackgroundTransparency = 1
credit.Text = "Built by Chimera__Gaming"
credit.Font = Enum.Font.GothamSemibold
credit.TextSize = 12
credit.TextColor3 = Color3.fromRGB(220, 220, 230)
credit.Size = UDim2.new(1, -20, 0, 20)
credit.Position = UDim2.new(0, 10, 0, 6)
credit.TextXAlignment = Enum.TextXAlignment.Left
credit.Parent = window

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.fromRGB(235, 235, 240)
closeBtn.BackgroundTransparency = 1
closeBtn.Size = UDim2.fromOffset(20, 20)
closeBtn.Position = UDim2.new(1, -24, 0, 4)
closeBtn.Parent = window
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Button
local btn = Instance.new("TextButton")
btn.Text = "Get Coords"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 16
btn.TextColor3 = Color3.fromRGB(245, 245, 250)
btn.BackgroundColor3 = Color3.fromRGB(70, 100, 255)
btn.Size = UDim2.fromOffset(140, 36)
btn.Position = UDim2.new(0.5, -70, 0.5, -10)
btn.Parent = window
local btnCorner = Instance.new("UICorner", btn); btnCorner.CornerRadius = UDim.new(0, 6)

-- Feedback
local feedback = Instance.new("TextLabel")
feedback.BackgroundTransparency = 1
feedback.Text = ""
feedback.Font = Enum.Font.Gotham
feedback.TextSize = 12
feedback.TextColor3 = Color3.fromRGB(210, 240, 210)
feedback.Size = UDim2.new(1, 0, 0, 16)
feedback.Position = UDim2.new(0, 0, 1, -22)
feedback.TextYAlignment = Enum.TextYAlignment.Center
feedback.TextXAlignment = Enum.TextXAlignment.Center
feedback.Parent = window

-- Clipboard / coords logic
local function round(n) return math.floor(n + 0.5) end
local function copyToClipboard(text)
	if typeof(setclipboard) == "function" then
		return pcall(function() setclipboard(text) end)
	end
	return false
end

btn.MouseButton1Click:Connect(function()
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then
		feedback.Text = "Character not found"
		feedback.TextColor3 = Color3.fromRGB(255, 150, 150)
		return
	end
	local p = root.Position
	local coords = string.format("%d, %d, %d", round(p.X), round(p.Y), round(p.Z))
	print("[Coords] " .. coords)
	if copyToClipboard(coords) then
		feedback.Text = "Copied: " .. coords
		feedback.TextColor3 = Color3.fromRGB(200, 255, 200)
		StarterGui:SetCore("SendNotification", {Title = "Coords", Text = coords, Duration = 2})
	else
		feedback.Text = "Clipboard not available"
		feedback.TextColor3 = Color3.fromRGB(255, 220, 170)
	end
end)

-- Dragging
local dragging, dragStart, startPos = false, nil, nil
local function beginDrag(input)
	dragging = true
	dragStart = input.Position
	startPos = window.Position
end
local function updateDrag(input)
	if not dragging then return end
	local delta = input.Position - dragStart
	window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
	                            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
window.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		beginDrag(input)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		updateDrag(input)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
