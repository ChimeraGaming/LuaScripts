--============================================================
-- Anti AFK + Popup Notification
--============================================================

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--============================================================
-- POPUP UI
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "AntiAFKPopup"
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(220, 60)
frame.Position = UDim2.new(1, -240, 1, -80)
frame.BackgroundColor3 = Color3.fromRGB(20, 30, 45)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1, -10, 1, -10)
text.Position = UDim2.fromOffset(5, 5)
text.BackgroundTransparency = 1
text.Text = "Anti AFK Enabled"
text.Font = Enum.Font.GothamBold
text.TextSize = 14
text.TextColor3 = Color3.fromRGB(200, 240, 255)
text.Parent = frame

--============================================================
-- AUTO REMOVE POPUP (5s)
--============================================================

task.delay(5, function()
	if gui then
		gui:Destroy()
	end
end)

--============================================================
-- ANTIAFK LOGIC (yours, cleaned + merged)
--============================================================

local GC = getconnections or get_signal_cons

if GC then
	for _, v in pairs(GC(player.Idled)) do
		if v.Disable then
			v:Disable()
		elseif v.Disconnect then
			v:Disconnect()
		end
	end
else
	player.Idled:Connect(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end

player.Idled:Connect(function()
	VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
	task.wait(1)
	VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

print("[Anti AFK] Active")
