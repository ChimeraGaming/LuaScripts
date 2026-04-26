-- Object Collector UI + WalkSpeed Slider + Give 100k Drops + Anti AFK + Collapsible 👊 Bubble
-- Credit | Chimera__Gaming
-- FREE AT RSCRIPTS

--------------- Services
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local UIS               = game:GetService("UserInputService")
local VIM               = game:GetService("VirtualInputManager")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--------------- Remove old UI if present
local old = PlayerGui:FindFirstChild("ObjectCollectorUI")
if old then old:Destroy() end

--------------- Folders / Remotes
local EventsFolder  = ReplicatedStorage:FindFirstChild("Events")
local evCollect     = EventsFolder and EventsFolder:FindFirstChild("CollectObject")

--------------- Root GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "ObjectCollectorUI"
Gui.IgnoreGuiInset = true
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

--------------- Panel
local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.Size = UDim2.fromOffset(260, 280) -- a bit taller for Anti AFK button
Panel.Position = UDim2.new(0.5, -130, 0.35, -140)
Panel.BackgroundColor3 = Color3.fromRGB(10, 12, 28)
Panel.BackgroundTransparency = 0.05
Panel.BorderSizePixel = 0
Panel.Parent = Gui

Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 12)
local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = Color3.fromRGB(0, 200, 255)
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = Panel

--------------- Header (Title + drag area)
local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -80, 0, 24)
Title.Position = UDim2.fromOffset(12, 6)
Title.Text = "Object Collector"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(150, 230, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Panel

--------------- Close button
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

--------------- Collapse button
local Collapse = Instance.new("TextButton")
Collapse.Size = UDim2.fromOffset(22, 22)
Collapse.Position = UDim2.new(1, -54, 0, 6)
Collapse.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Collapse.Text = "▼"
Collapse.Font = Enum.Font.GothamBold
Collapse.TextSize = 16
Collapse.TextColor3 = Color3.fromRGB(150, 200, 255)
Collapse.AutoButtonColor = false
Collapse.Parent = Panel
Instance.new("UICorner", Collapse).CornerRadius = UDim.new(0, 6)

--------------- Dragging (Title bar only)
local dragging = false
local dragStart
local startPos

local function mouseInTitleArea()
    local m = UIS:GetMouseLocation()
    local p = Panel.AbsolutePosition
    local s = Panel.AbsoluteSize
    -- only top ~30px is draggable
    return m.X >= p.X and m.X <= p.X + s.X and m.Y >= p.Y and m.Y <= p.Y + 30
end

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and mouseInTitleArea() then
        dragging = true
        dragStart = UIS:GetMouseLocation()
        startPos = Panel.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and dragStart and startPos then
        local m = UIS:GetMouseLocation()
        local dx = m.X - dragStart.X
        local dy = m.Y - dragStart.Y
        Panel.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + dx,
            startPos.Y.Scale, startPos.Y.Offset + dy
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--------------- Object Collector toggle
local ToggleCollect = Instance.new("TextButton")
ToggleCollect.Size = UDim2.new(1, -24, 0, 44)
ToggleCollect.Position = UDim2.fromOffset(12, 44)
ToggleCollect.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
ToggleCollect.Text = "Object Collector: OFF"
ToggleCollect.Font = Enum.Font.GothamBold
ToggleCollect.TextSize = 18
ToggleCollect.TextColor3 = Color3.fromRGB(180, 220, 255)
ToggleCollect.AutoButtonColor = false
ToggleCollect.Parent = Panel
Instance.new("UICorner", ToggleCollect).CornerRadius = UDim.new(0, 10)

local collecting = false
local collectThread

local function setCollectVisual(on)
    if on then
        ToggleCollect.Text = "Object Collector: ON"
        ToggleCollect.BackgroundColor3 = Color3.fromRGB(40, 0, 120)
        ToggleCollect.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        ToggleCollect.Text = "Object Collector: OFF"
        ToggleCollect.BackgroundColor3 = Color3.fromRGB(30, 30, 60)
        ToggleCollect.TextColor3 = Color3.fromRGB(180, 220, 255)
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
        if collectThread then task.cancel(collectThread) end
        collectThread = task.spawn(collectorLoop)
    else
        if collectThread then task.cancel(collectThread) collectThread = nil end
    end
end)

setCollectVisual(false)

--------------- WalkSpeed slider 50–100
local MIN_WS = 50
local MAX_WS = 100
local currentWS = 75

local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(1, -24, 0, 60)
SliderFrame.Position = UDim2.fromOffset(12, 96)
SliderFrame.BackgroundTransparency = 1
SliderFrame.Parent = Panel

local WSLabel = Instance.new("TextLabel")
WSLabel.BackgroundTransparency = 1
WSLabel.Size = UDim2.new(1, 0, 0, 24)
WSLabel.Position = UDim2.fromOffset(0, 0)
WSLabel.Font = Enum.Font.GothamBold
WSLabel.TextSize = 16
WSLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
WSLabel.TextXAlignment = Enum.TextXAlignment.Left
WSLabel.Text = "WalkSpeed: " .. currentWS
WSLabel.Parent = SliderFrame

local Bar = Instance.new("Frame")
Bar.Size = UDim2.new(1, 0, 0, 6)
Bar.Position = UDim2.fromOffset(0, 34)
Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
Bar.BorderSizePixel = 0
Bar.Parent = SliderFrame
Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 3)

local Fill = Instance.new("Frame")
Fill.Size = UDim2.new((currentWS - MIN_WS) / (MAX_WS - MIN_WS), 0, 1, 0)
Fill.Position = UDim2.fromOffset(0, 0)
Fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Fill.BorderSizePixel = 0
Fill.Parent = Bar
Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)

local Knob = Instance.new("Frame")
Knob.Size = UDim2.fromOffset(12, 12)
Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Knob.BorderSizePixel = 0
Knob.Parent = Bar
Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

local function updateKnob()
    local alpha = (currentWS - MIN_WS) / (MAX_WS - MIN_WS)
    Fill.Size = UDim2.new(alpha, 0, 1, 0)
    Knob.Position = UDim2.new(alpha, -6, 0.5, -6)
    WSLabel.Text = "WalkSpeed: " .. currentWS
end

updateKnob()

local draggingSlider = false

local function setValueFromMouse(x)
    local pos = Bar.AbsolutePosition.X
    local size = Bar.AbsoluteSize.X
    if size <= 0 then return end
    local alpha = math.clamp((x - pos) / size, 0, 1)
    currentWS = math.floor(MIN_WS + (MAX_WS - MIN_WS) * alpha + 0.5)
    updateKnob()
end

Bar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
        setValueFromMouse(UIS:GetMouseLocation().X)
    end
end)

Knob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
        setValueFromMouse(UIS:GetMouseLocation().X)
    end
end)

UIS.InputChanged:Connect(function(input)
    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        setValueFromMouse(UIS:GetMouseLocation().X)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

--------------- WalkSpeed enforcement loop (every 0.01s)
task.spawn(function()
    while Gui.Parent do
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = currentWS
        end
        task.wait(0.01)
    end
end)

--------------- Give 100,000 Each Drop button
local GiveDrops = Instance.new("TextButton")
GiveDrops.Size = UDim2.new(1, -24, 0, 40)
GiveDrops.Position = UDim2.fromOffset(12, 156)
GiveDrops.BackgroundColor3 = Color3.fromRGB(50, 30, 70)
GiveDrops.Text = "Give 100,000 Each Drop"
GiveDrops.Font = Enum.Font.GothamBold
GiveDrops.TextSize = 16
GiveDrops.TextColor3 = Color3.fromRGB(255, 255, 255)
GiveDrops.AutoButtonColor = false
GiveDrops.Parent = Panel
Instance.new("UICorner", GiveDrops).CornerRadius = UDim.new(0, 10)

local function give100kDrops()
    local stats = Player:FindFirstChild("Stats")
    if not stats then return end

    -- assumes Drop1 .. Drop6 exist under Stats
    for i = 1, 6 do
        local v = stats:FindFirstChild("Drop" .. i)
        if v and typeof(v.Value) == "number" then
            v.Value = v.Value + 100000
        end
    end
end

GiveDrops.MouseButton1Click:Connect(give100kDrops)

--------------- Anti AFK button (jump every 10 seconds, with real input + Humanoid jump)
local AntiAFK = Instance.new("TextButton")
AntiAFK.Size = UDim2.new(1, -24, 0, 40)
AntiAFK.Position = UDim2.fromOffset(12, 200)
AntiAFK.BackgroundColor3 = Color3.fromRGB(30, 60, 60)
AntiAFK.Text = "Anti AFK: OFF"
AntiAFK.Font = Enum.Font.GothamBold
AntiAFK.TextSize = 16
AntiAFK.TextColor3 = Color3.fromRGB(180, 220, 255)
AntiAFK.AutoButtonColor = false
AntiAFK.Parent = Panel
Instance.new("UICorner", AntiAFK).CornerRadius = UDim.new(0, 10)

local antiAFKOn = false
local antiAFKThread

local function setAntiAFKVisual(on)
    if on then
        AntiAFK.Text = "Anti AFK: ON"
        AntiAFK.BackgroundColor3 = Color3.fromRGB(0, 130, 90)
        AntiAFK.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        AntiAFK.Text = "Anti AFK: OFF"
        AntiAFK.BackgroundColor3 = Color3.fromRGB(30, 60, 60)
        AntiAFK.TextColor3 = Color3.fromRGB(180, 220, 255)
    end
end

local function doJumpOnce()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        -- try humanoid jump
        hum.Jump = true
        -- and also spoof a spacebar press just in case
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    end
end

local function antiAFKLoop()
    while antiAFKOn and Gui.Parent do
        -- jump immediately on start of cycle
        doJumpOnce()

        -- then wait 10 seconds in small slices so we can stop cleanly
        local total = 0
        while total < 10 and antiAFKOn and Gui.Parent do
            task.wait(0.2)
            total += 0.2
        end
    end
end

AntiAFK.MouseButton1Click:Connect(function()
    antiAFKOn = not antiAFKOn
    setAntiAFKVisual(antiAFKOn)
    if antiAFKOn then
        if antiAFKThread then task.cancel(antiAFKThread) end
        antiAFKThread = task.spawn(antiAFKLoop)
    else
        if antiAFKThread then
            task.cancel(antiAFKThread)
            antiAFKThread = nil
        end
    end
end)

setAntiAFKVisual(false)

--------------- Credit label
local Credit = Instance.new("TextLabel")
Credit.BackgroundTransparency = 1
Credit.Size = UDim2.new(1, -24, 0, 32)
Credit.Position = UDim2.new(0, 12, 1, -40)
Credit.Font = Enum.Font.GothamSemibold
Credit.TextSize = 12
Credit.TextColor3 = Color3.fromRGB(140, 190, 220)
Credit.TextXAlignment = Enum.TextXAlignment.Left
Credit.TextYAlignment = Enum.TextYAlignment.Top
Credit.TextWrapped = true
Credit.Text = "Credit | Chimera__Gaming\nFREE AT RSCRIPTS"
Credit.Parent = Panel

--------------- Collapse → 👊 bubble (remembers position)
local Bubble
local savedPanelPos = Panel.Position
local bubblePos = UDim2.new(0.5, -23, 0.1, 0)

local function showBubble()
    if Bubble and Bubble.Parent then return end

    Bubble = Instance.new("Frame")
    Bubble.Name = "PunchBubble"
    Bubble.Size = UDim2.fromOffset(46, 46)
    Bubble.Position = bubblePos
    Bubble.BackgroundColor3 = Color3.fromRGB(20, 24, 44)
    Bubble.BorderSizePixel = 0
    Bubble.Parent = Gui

    Instance.new("UICorner", Bubble).CornerRadius = UDim.new(1, 0)
    local s = Instance.new("UIStroke")
    s.Thickness = 2
    s.Color = Color3.fromRGB(0, 200, 255)
    s.Parent = Bubble

    local Icon = Instance.new("TextButton")
    Icon.Size = UDim2.fromScale(1, 1)
    Icon.BackgroundTransparency = 1
    Icon.Text = "👊"
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 26
    Icon.TextColor3 = Color3.fromRGB(180, 230, 255)
    Icon.AutoButtonColor = false
    Icon.Parent = Bubble

    -- drag bubble
    local bDragging = false
    local bStart
    local bPos

    local function beginDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            bDragging = true
            bStart = UIS:GetMouseLocation()
            bPos = Bubble.Position
        end
    end

    Bubble.InputBegan:Connect(beginDrag)
    Icon.InputBegan:Connect(beginDrag)

    UIS.InputChanged:Connect(function(input)
        if bDragging and input.UserInputType == Enum.UserInputType.MouseMovement and bStart and bPos then
            local m = UIS:GetMouseLocation()
            local dx = m.X - bStart.X
            local dy = m.Y - bStart.Y
            Bubble.Position = UDim2.new(
                bPos.X.Scale, bPos.X.Offset + dx,
                bPos.Y.Scale, bPos.Y.Offset + dy
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
        if Bubble then Bubble:Destroy() Bubble = nil end
        Panel.Visible = true
        Panel.Position = savedPanelPos
    end)
end

Collapse.MouseButton1Click:Connect(function()
    savedPanelPos = Panel.Position
    Panel.Visible = false
    showBubble()
end)

--------------- Close button behavior 
Close.MouseButton1Click:Connect(function()
    collecting = false
    if collectThread then task.cancel(collectThread) end
    antiAFKOn = false
    if antiAFKThread then task.cancel(antiAFKThread) end
    Gui:Destroy()
end)

print("[Object Collector] UI Loaded.")
