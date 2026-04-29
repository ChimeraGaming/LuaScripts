--============================================================
-- Money Incremental
-- Credit | Chimera__Gaming
-- FREE AT RSCRIPTS
--============================================================

--============================================================
-- 01. CONFIG
--============================================================

local GEM_PATH    = {"Main","Gems","GemFolder"}
local LEAF_PATH   = {"Main","Leaves","LeafFolder"}
local HOVER_Y     = 2
local YIELD_EVERY = 60

local DISPLAY_ORES = {"Stone","Coal","Copper","Iron","Silver","Gold","Diamond","Emerald"}
local TP_OFFSET     = Vector3.new(0, 4, 0)
local SCAN_INTERVAL = 0.12
local CAMP_REFRESH  = 0.45
local FILL_TRANS    = 1
local OUTLINE_TRANS = 0

local TELEPORTS = {
    {"Leaderboards",       Vector3.new(-1042, 14,   471)},
    {"Spawn",              Vector3.new(-1054, 14,    46)},
    {"Runes",              Vector3.new(-1049, 14,  -403)},
    {"Factory",            Vector3.new( 1693, 14, -1201)},
    {"AFK",                Vector3.new( 1770, 14, -1085)},
    {"Reincarnation",      Vector3.new( 2088, 14, -1188)},
    {"Block Breaking",     Vector3.new( 2270, 14, -1027)},
    {"Rings",              Vector3.new(-1874, 14,  4214)},
    {"Tree",               Vector3.new(-1896, 14,  4391)},
    {"Box",                Vector3.new(-2157, 14,  4397)},
    {"Halloween 2025",     Vector3.new(-2440, 14,  4164)},
    {"Cave Gems",          Vector3.new(-8377,-242,  9775)},
    {"Cave Box",           Vector3.new(-8523,-242,  9942)},
    {"The Mine",           Vector3.new(-7988,-232, 10093)},
    {"Pickaxe Upgrades",   Vector3.new(-7849,-242,  9768)},
    {"Jungle",             Vector3.new(-7656, 14,   719)},
}

--============================================================
-- 02. SERVICES
--============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

--============================================================
-- 03. CLEANUP OLD UI
--============================================================

local old = PG:FindFirstChild("MoneyIncrementalUI")
if old then
    old:Destroy()
end

local old2 = PG:FindFirstChild("Chimera_MultiTab_UI")
if old2 then
    old2:Destroy()
end

--============================================================
-- 04. CHARACTER HELPERS
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
    local p = ch:FindFirstChild("HumanoidRootPart")

    while not p do
        ch = LP.Character or LP.CharacterAdded:Wait()
        p = ch:FindFirstChild("HumanoidRootPart")
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
-- 05. MONEY THEME COLORS
--============================================================

local MoneyDark     = Color3.fromRGB(10, 24, 16)
local MoneyPanel    = Color3.fromRGB(16, 38, 24)
local MoneyCard     = Color3.fromRGB(20, 50, 32)
local MoneyGreen    = Color3.fromRGB(50, 220, 120)
local MoneyGold     = Color3.fromRGB(255, 205, 75)
local MoneySoft     = Color3.fromRGB(190, 255, 210)
local MoneyText     = Color3.fromRGB(235, 255, 240)
local DangerRed     = Color3.fromRGB(205, 65, 75)

--============================================================
-- 06. DRAG HELPER
--============================================================

local function makeDraggable(frame: Instance, dragHandle: Instance?)
    dragHandle = dragHandle or frame
    frame.Active = true
    dragHandle.Active = true

    local dragging = false
    local dragStart
    local startPos
    local moved = false

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = UserInputService:GetMouseLocation()
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mouse = UserInputService:GetMouseLocation()
            local dx = mouse.X - dragStart.X
            local dy = mouse.Y - dragStart.Y

            if math.abs(dx) > 3 or math.abs(dy) > 3 then
                moved = true
            end

            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + dx,
                startPos.Y.Scale,
                startPos.Y.Offset + dy
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return function()
        return moved
    end
end

--============================================================
-- 07. ROOT GUI
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "MoneyIncrementalUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PG

--============================================================
-- 08. MINIMIZE BUBBLE
--============================================================

local bubble = Instance.new("TextButton")
bubble.Name = "MoneyBubble"
bubble.Size = UDim2.fromOffset(56, 56)
bubble.Position = UDim2.new(0, 24, 0.7, 0)
bubble.Text = "💵"
bubble.TextScaled = true
bubble.Visible = false
bubble.BackgroundColor3 = MoneyPanel
bubble.TextColor3 = MoneyGold
bubble.AutoButtonColor = false
bubble.Parent = gui

Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)

local bubStroke = Instance.new("UIStroke", bubble)
bubStroke.Thickness = 2
bubStroke.Color = MoneyGreen

local bubbleMovedCheck = makeDraggable(bubble, bubble)

--============================================================
-- 09. MAIN WINDOW
--============================================================

local window = Instance.new("Frame")
window.Name = "Window"
window.Size = UDim2.fromOffset(760, 560)
window.Position = UDim2.new(0.5, -380, 0.5, -280)
window.BackgroundColor3 = MoneyDark
window.BorderSizePixel = 0
window.Parent = gui

Instance.new("UICorner", window).CornerRadius = UDim.new(0, 14)

local wstroke = Instance.new("UIStroke", window)
wstroke.Thickness = 2
wstroke.Color = MoneyGreen

local wgrad = Instance.new("UIGradient", window)
wgrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 35, 18)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 50, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 22, 16))
})
wgrad.Rotation = 35

--============================================================
-- 10. TOPBAR
--============================================================

local topbar = Instance.new("Frame", window)
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 44)
topbar.BackgroundColor3 = Color3.fromRGB(12, 32, 20)
topbar.BorderSizePixel = 0

Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel", topbar)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -140, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.Font = Enum.Font.GothamBold
title.Text = "Money Incremental 💸"
title.TextSize = 20
title.TextColor3 = MoneyText
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", topbar)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(255, 245, 245)
closeBtn.Size = UDim2.fromOffset(36, 28)
closeBtn.Position = UDim2.new(1, -44, 0, 8)
closeBtn.BackgroundColor3 = DangerRed
closeBtn.AutoButtonColor = false

Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local minBtn = Instance.new("TextButton", topbar)
minBtn.Text = "💵"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.TextColor3 = MoneyGold
minBtn.Size = UDim2.fromOffset(36, 28)
minBtn.Position = UDim2.new(1, -88, 0, 8)
minBtn.BackgroundColor3 = Color3.fromRGB(25, 80, 45)
minBtn.AutoButtonColor = false

Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

makeDraggable(window, topbar)

--============================================================
-- 11. LAYOUT FRAMES
--============================================================

local tabRail = Instance.new("Frame", window)
tabRail.Name = "TabRail"
tabRail.Size = UDim2.new(0, 200, 1, -90)
tabRail.Position = UDim2.new(0, 10, 0, 54)
tabRail.BackgroundColor3 = Color3.fromRGB(12, 35, 22)
tabRail.BorderSizePixel = 0

Instance.new("UICorner", tabRail).CornerRadius = UDim.new(0, 12)

local railStroke = Instance.new("UIStroke", tabRail)
railStroke.Thickness = 1.5
railStroke.Color = Color3.fromRGB(45, 135, 75)

local tabList = Instance.new("UIListLayout", tabRail)
tabList.Padding = UDim.new(0, 8)
tabList.SortOrder = Enum.SortOrder.LayoutOrder

local tabPadding = Instance.new("UIPadding", tabRail)
tabPadding.PaddingTop = UDim.new(0, 10)
tabPadding.PaddingLeft = UDim.new(0, 10)
tabPadding.PaddingRight = UDim.new(0, 10)

local content = Instance.new("Frame", window)
content.Name = "Content"
content.Size = UDim2.new(1, -230, 1, -90)
content.Position = UDim2.new(0, 220, 0, 54)
content.BackgroundColor3 = Color3.fromRGB(8, 24, 16)
content.BorderSizePixel = 0

Instance.new("UICorner", content).CornerRadius = UDim.new(0, 12)

local cstroke = Instance.new("UIStroke", content)
cstroke.Thickness = 1.5
cstroke.Color = Color3.fromRGB(35, 110, 65)

--============================================================
-- 12. CREDIT
--============================================================

local creditWrap = Instance.new("Frame", window)
creditWrap.Size = UDim2.new(0, 440, 0, 56)
creditWrap.Position = UDim2.new(0, 10, 1, -66)
creditWrap.BackgroundColor3 = Color3.fromRGB(12, 32, 20)
creditWrap.BackgroundTransparency = 0.05
creditWrap.BorderSizePixel = 0

Instance.new("UICorner", creditWrap).CornerRadius = UDim.new(0, 12)

local cws = Instance.new("UIStroke", creditWrap)
cws.Thickness = 1.2
cws.Color = Color3.fromRGB(70, 180, 105)
cws.Transparency = 0.25

local credit = Instance.new("TextLabel", creditWrap)
credit.BackgroundTransparency = 1
credit.Size = UDim2.new(1, -16, 1, -12)
credit.Position = UDim2.new(0, 8, 0, 6)
credit.Font = Enum.Font.Gotham
credit.Text = "Credit: Chimera__Gaming   |   Found Free at RSCRIPTS   |   If you lag: turn down graphics, disable popups, or change servers."
credit.TextSize = 13
credit.TextWrapped = true
credit.TextColor3 = MoneySoft
credit.TextXAlignment = Enum.TextXAlignment.Left
credit.TextYAlignment = Enum.TextYAlignment.Center

--============================================================
-- 13. UI HELPERS
--============================================================

local function makeTabButton(text, width, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(width, 34)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = MoneyText
    b.BackgroundColor3 = color
    b.AutoButtonColor = true
    b.Parent = tabRail

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    local s = Instance.new("UIStroke", b)
    s.Thickness = 1.2
    s.Color = Color3.fromRGB(8, 18, 12)

    return b
end

local pagesFolder = Instance.new("Folder", content)
pagesFolder.Name = "Pages"

local pages = {}

local function makePage()
    local p = Instance.new("Frame")
    p.Size = UDim2.fromScale(1, 1)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.Parent = pagesFolder
    return p
end

local function showPage(i)
    for k, v in ipairs(pages) do
        v.Visible = (k == i)
    end
end

local function makeCard(parent, titleText, accentRGB)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, -24, 1, -24)
    card.Position = UDim2.new(0, 12, 0, 12)
    card.BackgroundColor3 = MoneyCard
    card.BackgroundTransparency = 0.05
    card.BorderSizePixel = 0

    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", card)
    stroke.Thickness = 1.5
    stroke.Color = accentRGB or MoneyGreen
    stroke.Transparency = 0.2

    local titleLabel = Instance.new("TextLabel", card)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -20, 0, 34)
    titleLabel.Position = UDim2.new(0, 10, 0, 8)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = titleText
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = MoneyText
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    return card, titleLabel
end

--============================================================
-- 14. TAB 1 MAIN
--============================================================

local tab1 = makeTabButton("Main", 140, Color3.fromRGB(38, 150, 80))
local page1 = makePage()
pages[1] = page1

local mainCard, mainTitle = makeCard(page1, "Money Incremental Tools", MoneyGold)
makeDraggable(mainCard, mainTitle)

local mainInfo = Instance.new("TextLabel", mainCard)
mainInfo.BackgroundTransparency = 1
mainInfo.Size = UDim2.new(1, -20, 0, 80)
mainInfo.Position = UDim2.new(0, 10, 0, 44)
mainInfo.Font = Enum.Font.GothamBold
mainInfo.TextSize = 20
mainInfo.TextWrapped = true
mainInfo.TextXAlignment = Enum.TextXAlignment.Center
mainInfo.TextYAlignment = Enum.TextYAlignment.Center
mainInfo.TextColor3 = MoneyText
mainInfo.Text = "Money Incremental 💸\nUtility Hub"

local infiniteYieldBtn = Instance.new("TextButton", mainCard)
infiniteYieldBtn.Size = UDim2.new(1, -20, 0, 48)
infiniteYieldBtn.Position = UDim2.new(0, 10, 0, 140)
infiniteYieldBtn.BackgroundColor3 = Color3.fromRGB(32, 120, 68)
infiniteYieldBtn.Text = "Infinite Yield"
infiniteYieldBtn.TextColor3 = Color3.fromRGB(245, 255, 245)
infiniteYieldBtn.Font = Enum.Font.GothamBold
infiniteYieldBtn.TextSize = 20
infiniteYieldBtn.AutoButtonColor = true

Instance.new("UICorner", infiniteYieldBtn).CornerRadius = UDim.new(0, 12)

local iyStroke = Instance.new("UIStroke", infiniteYieldBtn)
iyStroke.Thickness = 1.5
iyStroke.Color = MoneyGold
iyStroke.Transparency = 0.15

infiniteYieldBtn.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
end)

local iyNote = Instance.new("TextLabel", mainCard)
iyNote.BackgroundTransparency = 1
iyNote.Size = UDim2.new(1, -20, 0, 70)
iyNote.Position = UDim2.new(0, 10, 0, 200)
iyNote.Font = Enum.Font.GothamMedium
iyNote.TextSize = 15
iyNote.TextWrapped = true
iyNote.TextXAlignment = Enum.TextXAlignment.Left
iyNote.TextYAlignment = Enum.TextYAlignment.Top
iyNote.TextColor3 = MoneySoft
iyNote.Text = "> Note: Enable Anti AFK inside Infinite Yield for best results."

--============================================================
-- 15. SHARED QUICKMINE LOCKING
--============================================================

local noclipConn, freezeConn, alignPos, alignOri, holdAtt

local function makeLockRig(hrp)
    holdAtt = hrp:FindFirstChild("QM_HoldAtt") or Instance.new("Attachment", hrp)
    holdAtt.Name = "QM_HoldAtt"

    alignPos = hrp:FindFirstChild("QM_AlignPos") or Instance.new("AlignPosition", hrp)
    alignPos.Name = "QM_AlignPos"
    alignPos.Attachment0 = holdAtt
    alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
    alignPos.ApplyAtCenterOfMass = true
    alignPos.RigidityEnabled = true
    alignPos.MaxForce = math.huge
    alignPos.Responsiveness = 200

    alignOri = hrp:FindFirstChild("QM_AlignOri") or Instance.new("AlignOrientation", hrp)
    alignOri.Name = "QM_AlignOri"
    alignOri.Attachment0 = holdAtt
    alignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignOri.RigidityEnabled = true
    alignOri.MaxAngularVelocity = math.huge
    alignOri.MaxTorque = math.huge
    alignOri.Responsiveness = 200
end

local function setLockTarget(cf)
    local hrp = getHRP()
    if not hrp then return end

    if not holdAtt or not alignPos or not alignOri then
        makeLockRig(hrp)
    end

    alignPos.Position = cf.Position
    alignOri.CFrame = cf
    hrp.CFrame = cf
end

local function enableNoClipFreeze()
    local ch = LP.Character or LP.CharacterAdded:Wait()
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local hrp = getHRP()

    if not noclipConn then
        noclipConn = RunService.Stepped:Connect(function()
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                end
            end
        end)
    end

    if not freezeConn then
        freezeConn = RunService.Heartbeat:Connect(function()
            if hrp and hrp.Parent then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end

    makeLockRig(hrp)

    if hum then
        hum.PlatformStand = true
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        hum.JumpPower = 0
        hum.WalkSpeed = 0
    end
end

local function disableNoClipFreeze()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end

    if freezeConn then
        freezeConn:Disconnect()
        freezeConn = nil
    end

    local ch = LP.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")

    if hum then
        hum.PlatformStand = false
    end

    if hrp then
        for _, n in ipairs({"QM_AlignPos", "QM_AlignOri", "QM_HoldAtt"}) do
            local x = hrp:FindFirstChild(n)
            if x then
                x:Destroy()
            end
        end
    end
end

local function tpAndPin(pos)
    local hrp = getHRP()
    if not hrp or not pos then return end

    local cf = CFrame.new(pos + TP_OFFSET, pos + TP_OFFSET + hrp.CFrame.LookVector)
    setLockTarget(cf)
end

--============================================================
-- 16. MINI TOGGLE FACTORY
--============================================================

local function makeMiniToggle(opts)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.fromOffset(56, 56)
    holder.Position = opts.positionUDim2 or UDim2.new(1, -70, 0.5, -28)
    holder.BackgroundTransparency = 1
    holder.Parent = gui

    local btn = Instance.new("TextButton", holder)
    btn.Size = UDim2.fromScale(1, 1)
    btn.Text = opts.emoji or "💎"
    btn.TextScaled = true
    btn.BackgroundColor3 = opts.baseColor or MoneyGreen
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false

    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local bstroke = Instance.new("UIStroke", btn)
    bstroke.Thickness = 2
    bstroke.Color = Color3.fromRGB(10, 20, 14)
    bstroke.Transparency = 0.2

    local closeX = Instance.new("TextButton", holder)
    closeX.Size = UDim2.fromOffset(16, 16)
    closeX.Position = UDim2.new(1, -10, 0, -6)
    closeX.Text = "X"
    closeX.TextSize = 12
    closeX.Font = Enum.Font.GothamBold
    closeX.BackgroundColor3 = DangerRed
    closeX.TextColor3 = Color3.new(1, 1, 1)
    closeX.AutoButtonColor = false

    Instance.new("UICorner", closeX).CornerRadius = UDim.new(1, 0)

    local miniMovedCheck = makeDraggable(holder, btn)

    local running = false

    local function paint()
        btn.BackgroundColor3 = running and Color3.fromRGB(44, 180, 120) or (opts.baseColor or MoneyGreen)
        bstroke.Color = running and Color3.fromRGB(220, 255, 230) or Color3.fromRGB(10, 20, 14)
    end

    paint()

    btn.MouseButton1Click:Connect(function()
        if miniMovedCheck and miniMovedCheck() then return end

        running = not running
        paint()

        if opts.onToggle then
            opts.onToggle(running)
        end
    end)

    closeX.MouseButton1Click:Connect(function()
        holder.Visible = false
    end)

    return {
        set = function(state)
            running = state
            paint()
        end,
        show = function()
            holder.Visible = true
        end,
        hide = function()
            holder.Visible = false
        end,
        instance = holder
    }
end

--============================================================
-- 17. TAB 2 CAVE GEM FARM
--============================================================

local tab2 = makeTabButton("Cave Gem Farm", 160, Color3.fromRGB(65, 170, 220))
local page2 = makePage()
pages[2] = page2

local gemCard, gemTitle = makeCard(page2, "Reincarnation 3: Gem Collector", Color3.fromRGB(120, 240, 255))
makeDraggable(gemCard, gemTitle)

local statusBox2 = Instance.new("Frame", gemCard)
statusBox2.Size = UDim2.new(1, -20, 0, 56)
statusBox2.Position = UDim2.new(0, 10, 0, 44)
statusBox2.BackgroundColor3 = Color3.fromRGB(40, 90, 105)
statusBox2.BackgroundTransparency = 0.15
statusBox2.BorderSizePixel = 0

Instance.new("UICorner", statusBox2).CornerRadius = UDim.new(0, 10)

local sStroke = Instance.new("UIStroke", statusBox2)
sStroke.Thickness = 1.2
sStroke.Color = Color3.fromRGB(180, 255, 255)
sStroke.Transparency = 0.2

local statusLabel2 = Instance.new("TextLabel", statusBox2)
statusLabel2.BackgroundTransparency = 1
statusLabel2.Size = UDim2.new(1, -12, 1, -12)
statusLabel2.Position = UDim2.new(0, 6, 0, 6)
statusLabel2.Text = "Idle"
statusLabel2.TextColor3 = Color3.fromRGB(210, 255, 255)
statusLabel2.Font = Enum.Font.GothamMedium
statusLabel2.TextSize = 22
statusLabel2.TextXAlignment = Enum.TextXAlignment.Center
statusLabel2.TextYAlignment = Enum.TextYAlignment.Center

local notes2 = Instance.new("TextLabel", gemCard)
notes2.BackgroundTransparency = 1
notes2.Size = UDim2.new(1, -20, 0, 200)
notes2.Position = UDim2.new(0, 10, 0, 108)
notes2.Font = Enum.Font.GothamMedium
notes2.TextSize = 18
notes2.TextWrapped = true
notes2.TextXAlignment = Enum.TextXAlignment.Left
notes2.TextColor3 = Color3.fromRGB(230, 245, 255)
notes2.Text = [[Credit | Chimera__Gaming

If you lag:
- Turn down graphics
- Disable popups
- Change servers

FREE at RSCRIPTS]]

local toggleGem = Instance.new("TextButton", gemCard)
toggleGem.Size = UDim2.new(1, -20, 0, 46)
toggleGem.Position = UDim2.new(0, 10, 1, -56)
toggleGem.BackgroundColor3 = Color3.fromRGB(80, 170, 220)
toggleGem.Text = "Start"
toggleGem.TextColor3 = Color3.new(1, 1, 1)
toggleGem.Font = Enum.Font.GothamBold
toggleGem.TextSize = 20
toggleGem.AutoButtonColor = false

Instance.new("UICorner", toggleGem).CornerRadius = UDim.new(0, 12)

local function resolveFolder(pathArr)
    local n = workspace

    for _, k in ipairs(pathArr) do
        n = n:FindFirstChild(k)
        if not n then
            return nil
        end
    end

    return n
end

local function partsFrom(inst)
    local out = {}

    for _, d in ipairs(inst:GetDescendants()) do
        if d:IsA("BasePart") then
            table.insert(out, d)
        end
    end

    return out
end

local function alive(i)
    return i and i.Parent ~= nil
end

local function tpTouch(part)
    if not (alive(part) and HRP and HRP.Parent) then return end

    HRP.CFrame = CFrame.new(part.Position + Vector3.new(0, HOVER_Y, 0))

    pcall(function()
        firetouchinterest(HRP, part, 0)
    end)

    pcall(function()
        firetouchinterest(HRP, part, 1)
    end)
end

local runningGem = false
local queueGem = {}
local seenGem = {}
local gemFolder = resolveFolder(GEM_PATH)

local function enqueueGem(g)
    if not g or g.Name:lower() ~= "gem" or seenGem[g] then return end

    seenGem[g] = true
    table.insert(queueGem, g)
end

if gemFolder then
    for _, c in ipairs(gemFolder:GetChildren()) do
        if c.Name:lower() == "gem" then
            enqueueGem(c)
        end
    end

    gemFolder.ChildAdded:Connect(function(c)
        if c.Name:lower() == "gem" then
            enqueueGem(c)
        end
    end)
end

local function sweepGems()
    local tickCount = 0

    while runningGem do
        if #queueGem == 0 and gemFolder then
            for _, c in ipairs(gemFolder:GetChildren()) do
                if c.Name:lower() == "gem" then
                    enqueueGem(c)
                end
            end
        end

        local g = table.remove(queueGem, 1)

        if g then
            seenGem[g] = nil

            if alive(g) then
                local parts = partsFrom(g)

                table.sort(parts, function(a, b)
                    return (a.Position - HRP.Position).Magnitude < (b.Position - HRP.Position).Magnitude
                end)

                for _, p in ipairs(parts) do
                    if not alive(g) then break end

                    tpTouch(p)
                    tickCount += 1

                    if tickCount % YIELD_EVERY == 0 then
                        RunService.Heartbeat:Wait()
                    end
                end
            end
        else
            RunService.Heartbeat:Wait()
        end

        statusLabel2.Text = (#queueGem > 0) and ("Queue: " .. #queueGem) or "Idle"
    end

    statusLabel2.Text = "Stopped"
end

local gemMini

local function setGemRunning(state)
    if runningGem == state then return end

    runningGem = state
    toggleGem.Text = runningGem and "Stop" or "Start"
    toggleGem.BackgroundColor3 = runningGem and DangerRed or Color3.fromRGB(80, 170, 220)

    if gemMini then
        gemMini.set(runningGem)
    end

    if runningGem then
        task.spawn(sweepGems)
    end
end

toggleGem.MouseButton1Click:Connect(function()
    setGemRunning(not runningGem)
end)

--============================================================
-- 18. TAB 3 MINE FARM
--============================================================

local tab3 = makeTabButton("Mine Farm", 140, Color3.fromRGB(200, 110, 55))
local page3 = makePage()
pages[3] = page3

local mineCard, mineTitle = makeCard(page3, "QuickMine Ores", Color3.fromRGB(255, 170, 100))
makeDraggable(mineCard, mineTitle)

local controls = Instance.new("Frame", mineCard)
controls.Size = UDim2.new(1, -20, 0, 36)
controls.Position = UDim2.new(0, 10, 0, 44)
controls.BackgroundTransparency = 1

local function mkBtn(txt, x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 110, 1, 0)
    b.Position = UDim2.new(0, x, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(45, 65, 45)
    b.TextColor3 = MoneyText
    b.TextSize = 14
    b.Font = Enum.Font.Gotham
    b.Text = txt
    b.BorderSizePixel = 0
    b.AutoButtonColor = true
    b.Parent = controls

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(80, 120, 80)
    s.Thickness = 1
    s.Transparency = 0.3

    return b
end

local selectAll = mkBtn("Select All", 0)
local clearAll = mkBtn("Clear All", 114)
local runBtn = mkBtn("Run: OFF", 228)
runBtn.BackgroundColor3 = Color3.fromRGB(86, 44, 44)

local list = Instance.new("ScrollingFrame", mineCard)
list.Size = UDim2.new(1, -20, 1, -100)
list.Position = UDim2.new(0, 10, 0, 90)
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.ScrollBarThickness = 6
list.BackgroundTransparency = 1
list.BorderSizePixel = 0

local listLayout = Instance.new("UIListLayout", list)
listLayout.Padding = UDim.new(0, 6)

local enabled = {}
for _, n in ipairs(DISPLAY_ORES) do
    enabled[n] = false
end

local buttons = {}

local function makeRow(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Text = "  " .. name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.BackgroundColor3 = Color3.fromRGB(35, 55, 38)
    btn.TextColor3 = MoneyText
    btn.AutoButtonColor = true
    btn.Parent = list

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(70, 110, 75)
    s.Thickness = 1
    s.Transparency = 0.4

    local function refresh()
        btn.BackgroundColor3 = enabled[name] and Color3.fromRGB(38, 120, 60) or Color3.fromRGB(35, 55, 38)
    end

    btn.MouseButton1Click:Connect(function()
        enabled[name] = not enabled[name]
        refresh()
    end)

    refresh()
    buttons[name] = btn
end

for _, name in ipairs(DISPLAY_ORES) do
    makeRow(name)
end

selectAll.MouseButton1Click:Connect(function()
    for k in pairs(enabled) do
        enabled[k] = true
    end

    for _, b in pairs(buttons) do
        b.BackgroundColor3 = Color3.fromRGB(38, 120, 60)
    end
end)

clearAll.MouseButton1Click:Connect(function()
    for k in pairs(enabled) do
        enabled[k] = false
    end

    for _, b in pairs(buttons) do
        b.BackgroundColor3 = Color3.fromRGB(35, 55, 38)
    end
end)

local function tryPath()
    local mine = workspace:FindFirstChild("Mine")

    if mine then
        local ores = mine:FindFirstChild("Ores")
        if ores then
            return ores
        end
    end

    local function scan(parent)
        for _, x in ipairs(parent:GetChildren()) do
            if x:IsA("Folder") then
                local hits = 0

                for _, n in ipairs(DISPLAY_ORES) do
                    if x:FindFirstChild(n) then
                        hits += 1
                    end
                end

                if hits >= 2 then
                    return x
                end

                local nxt = scan(x)
                if nxt then
                    return nxt
                end
            elseif x:IsA("Model") then
                local nxt = scan(x)
                if nxt then
                    return nxt
                end
            end
        end
    end

    return scan(workspace)
end

local ORES_ROOT = tryPath()

local function worldPos(inst)
    if not inst or not inst.Parent then return nil end

    if inst:IsA("BasePart") then
        return inst.Position
    end

    if inst:IsA("Model") and inst.PrimaryPart then
        return inst.PrimaryPart.Position
    end

    local p = inst:FindFirstChildWhichIsA("BasePart", true)
    return p and p.Position or nil
end

local function stillOre(inst)
    return inst and inst.Parent and ORES_ROOT and inst:IsDescendantOf(ORES_ROOT)
end

local function nearestEnabledOre()
    if not ORES_ROOT then return nil end

    local origin = getHRP().Position
    local best, bestD

    for name, on in pairs(enabled) do
        if on then
            local container = ORES_ROOT:FindFirstChild(name)

            if container and (container:IsA("Folder") or container:IsA("Model")) then
                for _, child in ipairs(container:GetChildren()) do
                    local p = worldPos(child)

                    if p then
                        local d = (p - origin).Magnitude

                        if not bestD or d < bestD then
                            bestD = d
                            best = child
                        end
                    end
                end
            end
        end
    end

    return best, bestD
end

local currentHL, rainbowConn

local function attachHighlight(target)
    if not target then return end

    if not currentHL then
        currentHL = Instance.new("Highlight")
        currentHL.Name = "QuickMineTargetHL"
        currentHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        currentHL.FillTransparency = FILL_TRANS
        currentHL.OutlineTransparency = OUTLINE_TRANS
        currentHL.Parent = CoreGui
    end

    currentHL.Adornee = target

    if not rainbowConn then
        local t = 0

        rainbowConn = RunService.RenderStepped:Connect(function(dt)
            t += dt
            local c = Color3.fromHSV((t * 0.35) % 1, 0.9, 1)
            currentHL.OutlineColor = c
            currentHL.FillColor = c
        end)
    end
end

local function clearHighlight()
    if currentHL then
        currentHL.Adornee = nil
    end

    if rainbowConn then
        rainbowConn:Disconnect()
        rainbowConn = nil
    end
end

_G.__qm_running = false

runBtn.MouseButton1Click:Connect(function()
    _G.__qm_running = not _G.__qm_running

    local running = _G.__qm_running
    runBtn.Text = running and "Run: ON" or "Run: OFF"
    runBtn.BackgroundColor3 = running and Color3.fromRGB(44, 120, 65) or Color3.fromRGB(86, 44, 44)

    if running then
        enableNoClipFreeze()
    else
        disableNoClipFreeze()
        clearHighlight()
    end
end)

task.spawn(function()
    while page3.Parent do
        if _G.__qm_running then
            local target

            repeat
                local newRoot = tryPath()

                if newRoot ~= ORES_ROOT then
                    ORES_ROOT = newRoot
                end

                target = nearestEnabledOre()
                task.wait(SCAN_INTERVAL)
            until not page3.Parent or not _G.__qm_running or target

            if page3.Parent and _G.__qm_running and target then
                attachHighlight(target)

                local lastPin = 0

                while _G.__qm_running and stillOre(target) do
                    local pos = worldPos(target)

                    if pos and (tick() - lastPin) >= CAMP_REFRESH then
                        tpAndPin(pos)
                        lastPin = tick()
                    end

                    RunService.Heartbeat:Wait()
                end

                clearHighlight()
                task.wait(0.05)
            end
        else
            task.wait(0.1)
        end
    end
end)

mineCard.Destroying:Connect(function()
    _G.__qm_running = false
    disableNoClipFreeze()
    clearHighlight()
end)

--============================================================
-- 19. TAB 4 JUNGLE LEAF FARM
--============================================================

local tab4 = makeTabButton("Jungle Leaf Farm", 180, Color3.fromRGB(50, 185, 110))
local page4 = makePage()
pages[4] = page4

local leafCard, leafTitle = makeCard(page4, "Jungle Leaf Farm | Hyper TP", Color3.fromRGB(120, 220, 170))
makeDraggable(leafCard, leafTitle)

local statusBox4 = Instance.new("Frame", leafCard)
statusBox4.Size = UDim2.new(1, -20, 0, 56)
statusBox4.Position = UDim2.new(0, 10, 0, 44)
statusBox4.BackgroundColor3 = Color3.fromRGB(40, 85, 70)
statusBox4.BackgroundTransparency = 0.15
statusBox4.BorderSizePixel = 0

Instance.new("UICorner", statusBox4).CornerRadius = UDim.new(0, 10)

local s4 = Instance.new("UIStroke", statusBox4)
s4.Thickness = 1.2
s4.Color = Color3.fromRGB(170, 255, 210)
s4.Transparency = 0.2

local statusLabel4 = Instance.new("TextLabel", statusBox4)
statusLabel4.BackgroundTransparency = 1
statusLabel4.Size = UDim2.new(1, -12, 1, -12)
statusLabel4.Position = UDim2.new(0, 6, 0, 6)
statusLabel4.Text = "Idle"
statusLabel4.TextColor3 = Color3.fromRGB(205, 255, 225)
statusLabel4.Font = Enum.Font.GothamMedium
statusLabel4.TextSize = 22
statusLabel4.TextXAlignment = Enum.TextXAlignment.Center
statusLabel4.TextYAlignment = Enum.TextYAlignment.Center

local notes4 = Instance.new("TextLabel", leafCard)
notes4.BackgroundTransparency = 1
notes4.Size = UDim2.new(1, -20, 0, 200)
notes4.Position = UDim2.new(0, 10, 0, 108)
notes4.Font = Enum.Font.GothamMedium
notes4.TextSize = 18
notes4.TextWrapped = true
notes4.TextXAlignment = Enum.TextXAlignment.Left
notes4.TextColor3 = Color3.fromRGB(220, 245, 230)
notes4.Text = [[Credit | Chimera__Gaming

If you lag:
- Turn down graphics
- Disable popups
- Change servers

FREE at RSCRIPTS]]

local toggleLeaf = Instance.new("TextButton", leafCard)
toggleLeaf.Size = UDim2.new(1, -20, 0, 46)
toggleLeaf.Position = UDim2.new(0, 10, 1, -56)
toggleLeaf.BackgroundColor3 = Color3.fromRGB(76, 170, 130)
toggleLeaf.Text = "Start"
toggleLeaf.TextColor3 = Color3.new(1, 1, 1)
toggleLeaf.Font = Enum.Font.GothamBold
toggleLeaf.TextSize = 20
toggleLeaf.AutoButtonColor = false

Instance.new("UICorner", toggleLeaf).CornerRadius = UDim.new(0, 12)

local function enqueueLeaf(t, seen, q)
    if not t or t.Name:lower() ~= "leaf" or seen[t] then return end

    seen[t] = true
    table.insert(q, t)
end

local runningLeaf = false
local queueLeaf = {}
local seenLeaf = {}
local leafFolder = resolveFolder(LEAF_PATH)

if leafFolder then
    for _, c in ipairs(leafFolder:GetChildren()) do
        if c.Name:lower() == "leaf" then
            enqueueLeaf(c, seenLeaf, queueLeaf)
        end
    end

    leafFolder.ChildAdded:Connect(function(c)
        if c.Name:lower() == "leaf" then
            enqueueLeaf(c, seenLeaf, queueLeaf)
        end
    end)
end

local function sweepLeaves()
    local tickCount = 0

    while runningLeaf do
        if #queueLeaf == 0 and leafFolder then
            for _, c in ipairs(leafFolder:GetChildren()) do
                if c.Name:lower() == "leaf" then
                    enqueueLeaf(c, seenLeaf, queueLeaf)
                end
            end
        end

        local leaf = table.remove(queueLeaf, 1)

        if leaf then
            seenLeaf[leaf] = nil

            if alive(leaf) then
                local parts = partsFrom(leaf)

                table.sort(parts, function(a, b)
                    return (a.Position - HRP.Position).Magnitude < (b.Position - HRP.Position).Magnitude
                end)

                for _, p in ipairs(parts) do
                    if not alive(leaf) then break end

                    tpTouch(p)
                    tickCount += 1

                    if tickCount % YIELD_EVERY == 0 then
                        RunService.Heartbeat:Wait()
                    end
                end
            end
        else
            RunService.Heartbeat:Wait()
        end

        statusLabel4.Text = (#queueLeaf > 0) and ("Queue: " .. #queueLeaf) or "Idle"
    end

    statusLabel4.Text = "Stopped"
end

local leafMini

local function setLeafRunning(state)
    if runningLeaf == state then return end

    runningLeaf = state
    toggleLeaf.Text = runningLeaf and "Stop" or "Start"
    toggleLeaf.BackgroundColor3 = runningLeaf and DangerRed or Color3.fromRGB(76, 170, 130)

    if leafMini then
        leafMini.set(runningLeaf)
    end

    if runningLeaf then
        task.spawn(sweepLeaves)
    end
end

toggleLeaf.MouseButton1Click:Connect(function()
    setLeafRunning(not runningLeaf)
end)

--============================================================
-- 20. TAB 5 TELEPORTS
--============================================================

local tab5 = makeTabButton("Teleports", 140, Color3.fromRGB(120, 160, 70))
local page5 = makePage()
pages[5] = page5

local tpCard, tpTitle = makeCard(page5, "Faster Teleports", MoneyGold)
makeDraggable(tpCard, tpTitle)

local hint = Instance.new("TextLabel", tpCard)
hint.BackgroundTransparency = 1
hint.Size = UDim2.new(1, -20, 0, 18)
hint.Position = UDim2.new(0, 10, 0, 44)
hint.Font = Enum.Font.Gotham
hint.Text = "Instant TP | Spawns about 3 studs above target and kills bounce."
hint.TextSize = 12
hint.TextColor3 = MoneySoft
hint.TextXAlignment = Enum.TextXAlignment.Left

local scroll = Instance.new("ScrollingFrame", tpCard)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Size = UDim2.new(1, -20, 1, -76)
scroll.Position = UDim2.new(0, 10, 0, 66)
scroll.ScrollBarThickness = 6
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0, 220, 0, 40)
grid.CellPadding = UDim2.new(0, 10, 0, 10)
grid.FillDirectionMaxCells = 2

local function fastTP(posV3)
    local hrp = getHRP()
    if not hrp then return end

    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(posV3 + Vector3.new(0, 3, 0))

    RunService.Heartbeat:Wait()

    if hrp and hrp.Parent then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

for _, entry in ipairs(TELEPORTS) do
    local label, v3 = entry[1], entry[2]

    local btn = Instance.new("TextButton", scroll)
    btn.Text = label
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextColor3 = MoneyText
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true

    if label == "Halloween 2025" then
        btn.BackgroundColor3 = Color3.fromRGB(230, 120, 20)
    else
        btn.BackgroundColor3 = Color3.fromRGB(32, 90, 52)
    end

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local bstroke = Instance.new("UIStroke", btn)
    bstroke.Thickness = 1.2
    bstroke.Color = (label == "Halloween 2025") and Color3.fromRGB(255, 220, 160) or Color3.fromRGB(90, 180, 120)
    bstroke.Transparency = 0.15

    btn.MouseButton1Click:Connect(function()
        fastTP(v3)
    end)

    btn.MouseButton2Click:Connect(function()
        if setclipboard then
            setclipboard(("{%d, %d, %d}"):format(v3.X, v3.Y, v3.Z))
        end
    end)

    btn.MouseEnter:Connect(function()
        if label == "Halloween 2025" then
            btn.BackgroundColor3 = Color3.fromRGB(250, 150, 40)
        else
            btn.BackgroundColor3 = Color3.fromRGB(45, 120, 70)
        end
    end)

    btn.MouseLeave:Connect(function()
        if label == "Halloween 2025" then
            btn.BackgroundColor3 = Color3.fromRGB(230, 120, 20)
        else
            btn.BackgroundColor3 = Color3.fromRGB(32, 90, 52)
        end
    end)
end

--============================================================
-- 21. TAB 6 SUGGESTIONS
--============================================================

local tab6 = makeTabButton("Suggestions", 160, Color3.fromRGB(65, 155, 85))
local page6 = makePage()
pages[6] = page6

local sugCard, sugTitle = makeCard(page6, "Suggestions", MoneyGreen)
makeDraggable(sugCard, sugTitle)

local big = Instance.new("TextLabel", sugCard)
big.BackgroundTransparency = 1
big.Size = UDim2.new(1, -20, 1, -60)
big.Position = UDim2.new(0, 10, 0, 40)
big.Font = Enum.Font.GothamBlack
big.TextSize = 28
big.TextWrapped = true
big.TextXAlignment = Enum.TextXAlignment.Center
big.TextYAlignment = Enum.TextYAlignment.Center
big.TextColor3 = MoneyText
big.Text = "Head to RSCRIPTS and leave a suggestion for what to add next!"

--============================================================
-- 22. TAB BINDING
--============================================================

local function bindTab(btn, index)
    btn.MouseButton1Click:Connect(function()
        showPage(index)
    end)
end

bindTab(tab1, 1)
bindTab(tab2, 2)
bindTab(tab3, 3)
bindTab(tab4, 4)
bindTab(tab5, 5)
bindTab(tab6, 6)

showPage(1)

--============================================================
-- 23. WINDOW CONTROLS
--============================================================

local function setMinimized(state)
    window.Visible = not state
    bubble.Visible = state
end

minBtn.MouseButton1Click:Connect(function()
    setMinimized(true)
end)

bubble.MouseButton1Click:Connect(function()
    if bubbleMovedCheck and bubbleMovedCheck() then return end
    setMinimized(false)
end)

closeBtn.MouseButton1Click:Connect(function()
    _G.__qm_running = false
    runningGem = false
    runningLeaf = false

    disableNoClipFreeze()
    clearHighlight()

    if gui then
        gui:Destroy()
    end
end)

--============================================================
-- 24. MINI TOGGLES
--============================================================

gemMini = makeMiniToggle{
    emoji = "💎",
    baseColor = Color3.fromRGB(80, 170, 220),
    positionUDim2 = UDim2.new(1, -70, 0.5, -140),
    onToggle = function(state)
        setGemRunning(state)
    end
}

leafMini = makeMiniToggle{
    emoji = "🍃",
    baseColor = Color3.fromRGB(76, 170, 130),
    positionUDim2 = UDim2.new(1, -70, 0.5, -76),
    onToggle = function(state)
        setLeafRunning(state)
    end
}

if runningGem then
    gemMini.set(true)
end

if runningLeaf then
    leafMini.set(true)
end

--============================================================
-- 25. LOADED
--============================================================

print("[Money Incremental] UI Loaded.")
