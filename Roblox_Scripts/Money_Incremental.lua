--[[
  Chimera Utility Hub — Uniform Tabs + Mini Farm Toggles
  - Draggable, Closable (❌), Minimizable to 💵 bubble
  - Left rail tabs with uniform cards + consistent styling
  - Main: WalkSpeed slider 50–100 (enforced)
  - Tab 2: Cave Gem Farm — Hyper TP (queue + nearest-part touches)
  - Tab 3: Mine Farm — QuickMine Ores (nearest-only + no-bounce pin + rainbow outline)
      * Removed path line per request
  - Tab 4: Jungle Leaf Farm — Hyper TP (same notes as Gem, larger text; removed targets text)
  - Tab 5: Faster Teleports (Halloween 2025 button is orange)
  - Tab 6: Suggestions (Big text: Go to RSCRIPTS and leave a suggestion)
  - Mini Toggles: floating, draggable, closable 💎 and 🍃 buttons to start/stop Gem/Leaf farms

  Credit: Chimera__Gaming
  Found Free at RSCRIPTS
]]

---------------- CONFIG: Gem/Leaf Farms ----------------
local GEM_PATH    = {"Main","Gems","GemFolder"}         -- Parts named "Gem"
local LEAF_PATH   = {"Main","Leaves","LeafFolder"}      -- Parts named "Leaf"
local HOVER_Y     = 2
local YIELD_EVERY = 60
--------------------------------------------------------

---------------- CONFIG: QuickMine (Tab 3) --------------
local DISPLAY_ORES = {"Stone","Coal","Copper","Iron","Silver","Gold","Diamond","Emerald"}
local TP_OFFSET     = Vector3.new(0, 4, 0)
local SCAN_INTERVAL = 0.12
local CAMP_REFRESH  = 0.45
local FILL_TRANS    = 1
local OUTLINE_TRANS = 0
--------------------------------------------------------

---------------- CONFIG: Teleports (Tab 5) --------------
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
    {"Halloween 2025",     Vector3.new(-2440, 14,  4164)}, -- special orange styling
    {"Cave Gems",          Vector3.new(-8377,-242,  9775)},
    {"Cave Box",           Vector3.new(-8523,-242,  9942)},
    {"The Mine",           Vector3.new(-7988,-232, 10093)},
    {"Pickaxe Upgrades",   Vector3.new(-7849,-242,  9768)},
    {"Jungle",             Vector3.new(-7656, 14,   719)},
}
--------------------------------------------------------

-- Services / basics
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

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
LP.CharacterAdded:Connect(function() task.wait(0.25); HRP = getHRP() end)

local function makeDraggable(frame: Instance, dragHandle: Instance?)
    dragHandle = dragHandle or frame
    local dragging, dragStart, startPos = false
    local function update(input)
        local d = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
    dragHandle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = frame.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i)
        end
    end)
end

-- Root GUI
local gui = Instance.new("ScreenGui")
gui.Name = "Chimera_MultiTab_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = PG

-- 💵 bubble (minimize)
local bubble = Instance.new("TextButton")
bubble.Size = UDim2.fromOffset(56, 56)
bubble.Position = UDim2.new(0, 24, 0.7, 0)
bubble.Text = "💵"
bubble.TextScaled = true
bubble.Visible = false
bubble.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
bubble.Parent = gui
Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)
local bubStroke = Instance.new("UIStroke", bubble); bubStroke.Thickness = 2; bubStroke.Color = Color3.fromRGB(0, 255, 120)
makeDraggable(bubble, bubble)

-- Window
local window = Instance.new("Frame")
window.Size = UDim2.fromOffset(760, 560)
window.Position = UDim2.new(0.5, -380, 0.5, -280)
window.BackgroundColor3 = Color3.fromRGB(18,18,22)
window.Parent = gui
Instance.new("UICorner", window).CornerRadius = UDim.new(0,14)
local wstroke = Instance.new("UIStroke", window); wstroke.Thickness = 2; wstroke.Color = Color3.fromRGB(60,140,255)

-- Topbar
local topbar = Instance.new("Frame", window)
topbar.Size = UDim2.new(1,0,0,44)
topbar.BackgroundColor3 = Color3.fromRGB(24,24,28)
Instance.new("UICorner", topbar).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", topbar)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1,-140,1,0)
title.Position = UDim2.new(0,12,0,0)
title.Font = Enum.Font.GothamBold
title.Text = "Chimera Utility Hub"
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(230,240,255)
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", topbar)
closeBtn.Text = "❌"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(245,245,245)
closeBtn.Size = UDim2.fromOffset(36,28)
closeBtn.Position = UDim2.new(1,-44,0,8)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,60,70)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)

local minBtn = Instance.new("TextButton", topbar)
minBtn.Text = "💵"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.TextColor3 = Color3.fromRGB(245,245,245)
minBtn.Size = UDim2.fromOffset(36,28)
minBtn.Position = UDim2.new(1,-88,0,8)
minBtn.BackgroundColor3 = Color3.fromRGB(60,140,255)
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,8)

makeDraggable(window, topbar)

-- Left rail + content
local tabRail = Instance.new("Frame", window)
tabRail.Size = UDim2.new(0, 200, 1, -90)
tabRail.Position = UDim2.new(0, 10, 0, 54)
tabRail.BackgroundColor3 = Color3.fromRGB(26,26,32)
Instance.new("UICorner", tabRail).CornerRadius = UDim.new(0,12)
local railStroke = Instance.new("UIStroke", tabRail); railStroke.Thickness = 1.5; railStroke.Color = Color3.fromRGB(80,90,120)
local tabList = Instance.new("UIListLayout", tabRail); tabList.Padding = UDim.new(0,8)

local content = Instance.new("Frame", window)
content.Size = UDim2.new(1,-230,1,-90)
content.Position = UDim2.new(0,220,0,54)
content.BackgroundColor3 = Color3.fromRGB(14,14,18)
Instance.new("UICorner", content).CornerRadius = UDim.new(0,12)
local cstroke = Instance.new("UIStroke", content); cstroke.Thickness = 1.5; cstroke.Color = Color3.fromRGB(50,60,90)

-- Bottom-left credit bubble (fits both credit + notes)
local creditWrap = Instance.new("Frame", window)
creditWrap.Size = UDim2.new(0, 440, 0, 56)
creditWrap.Position = UDim2.new(0, 10, 1, -66)
creditWrap.BackgroundColor3 = Color3.fromRGB(22,22,28)
creditWrap.BackgroundTransparency = 0.05
Instance.new("UICorner", creditWrap).CornerRadius = UDim.new(0, 12)
local cws = Instance.new("UIStroke", creditWrap); cws.Thickness=1.2; cws.Color = Color3.fromRGB(70,80,120); cws.Transparency = 0.25

local credit = Instance.new("TextLabel", creditWrap)
credit.BackgroundTransparency = 1
credit.Size = UDim2.new(1,-16,1,-12)
credit.Position = UDim2.new(0,8,0,6)
credit.Font = Enum.Font.Gotham
credit.Text = "Credit: Chimera__Gaming   •   Found Free at RSCRIPTS   •   If you lag: turn down graphics, disable popups, or change servers."
credit.TextSize = 13
credit.TextWrapped = true
credit.TextColor3 = Color3.fromRGB(180,200,255)
credit.TextXAlignment = Enum.TextXAlignment.Left
credit.TextYAlignment = Enum.TextYAlignment.Center

-- Tab/button/page helpers
local function makeTabButton(text, width, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(width, 34)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(235,240,255)
    b.BackgroundColor3 = color
    b.AutoButtonColor = true
    b.Parent = tabRail
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    local s = Instance.new("UIStroke", b); s.Thickness = 1.2; s.Color = Color3.fromRGB(15,15,20)
    return b
end

local pagesFolder = Instance.new("Folder", content); pagesFolder.Name = "Pages"
local pages = {}
local function makePage()
    local p = Instance.new("Frame")
    p.Size = UDim2.fromScale(1,1); p.BackgroundTransparency = 1; p.Visible = false; p.Parent = pagesFolder
    return p
end
local function showPage(i) for k,v in ipairs(pages) do v.Visible = (k==i) end end

-- UNIFORM CARD MAKER (used in Tabs 2–6)
local function makeCard(parent, titleText, accentRGB)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, -24, 1, -24)
    card.Position = UDim2.new(0, 12, 0, 12)
    card.BackgroundColor3 = Color3.fromRGB(24,24,30)
    card.BackgroundTransparency = 0.05
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", card); stroke.Thickness = 1.5; stroke.Color = accentRGB or Color3.fromRGB(90,110,170); stroke.Transparency = 0.2

    local title = Instance.new("TextLabel", card)
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1,-20,0,34)
    title.Position = UDim2.new(0,10,0,8)
    title.Font = Enum.Font.GothamBold
    title.Text = titleText
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(230,230,255)
    title.TextXAlignment = Enum.TextXAlignment.Left

    return card, title
end

----------------------------------------------------------------
-- TAB 1: Main (WalkSpeed)
----------------------------------------------------------------
local tab1 = makeTabButton("Main", 140, Color3.fromRGB(70,110,255))
local page1 = makePage(); pages[1] = page1

-- slider UI
local sliderLabel = Instance.new("TextLabel", page1)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Size = UDim2.new(1,-40,0,28)
sliderLabel.Position = UDim2.new(0,20,0,24)
sliderLabel.Font = Enum.Font.GothamBold
sliderLabel.Text = "WalkSpeed"
sliderLabel.TextSize = 16
sliderLabel.TextColor3 = Color3.fromRGB(220,230,255)
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left

local valueLabel = Instance.new("TextLabel", page1)
valueLabel.BackgroundTransparency = 1
valueLabel.Size = UDim2.fromOffset(80,28)
valueLabel.Position = UDim2.new(1,-90,0,24)
valueLabel.Font = Enum.Font.GothamBold
valueLabel.Text = "50"
valueLabel.TextSize = 16
valueLabel.TextColor3 = Color3.fromRGB(120,255,180)
valueLabel.TextXAlignment = Enum.TextXAlignment.Right

local sliderBar = Instance.new("Frame", page1)
sliderBar.Size = UDim2.new(1,-40,0,10)
sliderBar.Position = UDim2.new(0,20,0,64)
sliderBar.BackgroundColor3 = Color3.fromRGB(40,45,70)
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0,6)

local fill = Instance.new("Frame", sliderBar)
fill.Size = UDim2.new(0,0,1,0)
fill.BackgroundColor3 = Color3.fromRGB(60,200,140)
Instance.new("UICorner", fill).CornerRadius = UDim.new(0,6)

local knob = Instance.new("Frame", sliderBar)
knob.Size = UDim2.fromOffset(16,16)
knob.Position = UDim2.new(0,-8,0.5,-8)
knob.BackgroundColor3 = Color3.fromRGB(230,240,255)
Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
local kstroke = Instance.new("UIStroke", knob); kstroke.Thickness = 1.2; kstroke.Color = Color3.fromRGB(40,50,80)

local minWS, maxWS, currentWS = 50, 100, 50
local draggingSlider=false
local function setSliderFromX(x)
    local a = (x - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
    a = math.clamp(a,0,1)
    local ws = math.floor(minWS + (maxWS-minWS)*a + 0.5)
    currentWS = ws
    valueLabel.Text = tostring(ws)
    fill.Size = UDim2.new(a,0,1,0)
    knob.Position = UDim2.new(a,-8,0.5,-8)
end
sliderBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        draggingSlider=true; setSliderFromX(i.Position.X)
    end
end)
sliderBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingSlider=false end
end)
UserInputService.InputChanged:Connect(function(i)
    if draggingSlider and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        setSliderFromX(i.Position.X)
    end
end)
local enforcing = true
task.spawn(function()
    while enforcing do
        local hum = waitForHumanoid()
        if hum and hum.Parent and hum.WalkSpeed ~= currentWS then hum.WalkSpeed = currentWS end
        task.wait(0.05)
    end
end)

----------------------------------------------------------------
-- SHARED (QuickMine): no-clip / freeze / lock
----------------------------------------------------------------
local noclipConn, freezeConn, alignPos, alignOri, holdAtt
local function makeLockRig(hrp)
    holdAtt = hrp:FindFirstChild("QM_HoldAtt") or Instance.new("Attachment", hrp); holdAtt.Name = "QM_HoldAtt"
    alignPos = hrp:FindFirstChild("QM_AlignPos") or Instance.new("AlignPosition", hrp)
    alignPos.Name="QM_AlignPos"; alignPos.Attachment0=holdAtt; alignPos.Mode=Enum.PositionAlignmentMode.OneAttachment
    alignPos.ApplyAtCenterOfMass=true; alignPos.RigidityEnabled=true; alignPos.MaxForce=math.huge; alignPos.Responsiveness=200
    alignOri = hrp:FindFirstChild("QM_AlignOri") or Instance.new("AlignOrientation", hrp)
    alignOri.Name="QM_AlignOri"; alignOri.Attachment0=holdAtt; alignOri.Mode=Enum.OrientationAlignmentMode.OneAttachment
    alignOri.RigidityEnabled=true; alignOri.MaxAngularVelocity=math.huge; alignOri.MaxTorque=math.huge; alignOri.Responsiveness=200
end
local function setLockTarget(cf)
    local hrp = getHRP(); if not hrp then return end
    if not holdAtt or not alignPos or not alignOri then makeLockRig(hrp) end
    alignPos.Position = cf.Position; alignOri.CFrame = cf; hrp.CFrame = cf
end
local function enableNoClipFreeze()
    local ch = LP.Character or LP.CharacterAdded:Wait()
    local hum = ch:FindFirstChildOfClass("Humanoid")
    local hrp = getHRP()
    if not noclipConn then
        noclipConn = RunService.Stepped:Connect(function()
            for _,p in ipairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
        end)
    end
    if not freezeConn then
        freezeConn = RunService.Heartbeat:Connect(function()
            if hrp and hrp.Parent then hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity=Vector3.zero end
        end)
    end
    makeLockRig(hrp)
    if hum then hum.PlatformStand=true; hum:ChangeState(Enum.HumanoidStateType.Physics); hum.JumpPower=0; hum.WalkSpeed=0 end
end
local function disableNoClipFreeze()
    if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
    if freezeConn then freezeConn:Disconnect(); freezeConn=nil end
    local ch=LP.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid"); local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
    if hum then hum.PlatformStand=false end
    if hrp then for _,n in ipairs({"QM_AlignPos","QM_AlignOri","QM_HoldAtt"}) do local x=hrp:FindFirstChild(n); if x then x:Destroy() end end end
end
local function tpAndPin(pos)
    local hrp = getHRP(); if not hrp or not pos then return end
    local cf = CFrame.new(pos + TP_OFFSET, pos + TP_OFFSET + hrp.CFrame.LookVector)
    setLockTarget(cf)
end

----------------------------------------------------------------
-- Mini Toggle Factory (💎 and 🍃)
----------------------------------------------------------------
local function makeMiniToggle(opts)
    -- opts: {emoji, baseColor, positionUDim2, onToggle}
    local holder = Instance.new("Frame"); holder.Size = UDim2.fromOffset(56,56)
    holder.Position = opts.positionUDim2 or UDim2.new(1,-70,0.5,-28)
    holder.BackgroundTransparency = 1; holder.Parent = gui

    local btn = Instance.new("TextButton", holder)
    btn.Size = UDim2.fromScale(1,1)
    btn.Text = opts.emoji or "💎"
    btn.TextScaled = true
    btn.BackgroundColor3 = opts.baseColor or Color3.fromRGB(95,170,255)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    local bstroke = Instance.new("UIStroke", btn); bstroke.Thickness = 2; bstroke.Color = Color3.fromRGB(15,15,20); bstroke.Transparency = 0.2

    local closeX = Instance.new("TextButton", holder)
    closeX.Size = UDim2.fromOffset(16,16); closeX.Position = UDim2.new(1,-10,0,-6)
    closeX.Text = "✕"; closeX.TextSize = 12; closeX.Font = Enum.Font.GothamBold
    closeX.BackgroundColor3 = Color3.fromRGB(200,60,70); closeX.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", closeX).CornerRadius = UDim.new(1,0)

    makeDraggable(holder, btn)

    local running = false
    local function paint()
        btn.BackgroundColor3 = running and Color3.fromRGB(44, 180, 120) or (opts.baseColor or Color3.fromRGB(95,170,255))
        bstroke.Color = running and Color3.fromRGB(220,255,230) or Color3.fromRGB(15,15,20)
    end
    paint()

    btn.MouseButton1Click:Connect(function()
        running = not running; paint()
        if opts.onToggle then opts.onToggle(running) end
    end)
    closeX.MouseButton1Click:Connect(function() holder.Visible = false end)

    return {
        set = function(state) running = state; paint() end,
        show = function() holder.Visible = true end,
        hide = function() holder.Visible = false end,
        instance = holder
    }
end

----------------------------------------------------------------
-- TAB 2: Cave Gem Farm (uniform card)
----------------------------------------------------------------
local tab2 = makeTabButton("Cave Gem Farm", 160, Color3.fromRGB(100,90,255))
local page2 = makePage(); pages[2] = page2
local gemCard, gemTitle = makeCard(page2, "Reincarnation 3: Gem Collector", Color3.fromRGB(150,240,255))
makeDraggable(gemCard, gemTitle)

local statusBox2 = Instance.new("Frame", gemCard)
statusBox2.Size = UDim2.new(1,-20,0,56); statusBox2.Position = UDim2.new(0,10,0,44)
statusBox2.BackgroundColor3 = Color3.fromRGB(60,100,120); statusBox2.BackgroundTransparency = 0.15
Instance.new("UICorner", statusBox2).CornerRadius = UDim.new(0,10)
local sStroke = Instance.new("UIStroke", statusBox2); sStroke.Thickness = 1.2; sStroke.Color = Color3.fromRGB(180,255,255); sStroke.Transparency=0.2

local statusLabel2 = Instance.new("TextLabel", statusBox2)
statusLabel2.BackgroundTransparency = 1; statusLabel2.Size = UDim2.new(1,-12,1,-12); statusLabel2.Position = UDim2.new(0,6,0,6)
statusLabel2.Text = "Idle"; statusLabel2.TextColor3 = Color3.fromRGB(210,255,255); statusLabel2.Font=Enum.Font.GothamMedium; statusLabel2.TextSize=22
statusLabel2.TextXAlignment = Enum.TextXAlignment.Center; statusLabel2.TextYAlignment = Enum.TextYAlignment.Center

local notes2 = Instance.new("TextLabel", gemCard)
notes2.BackgroundTransparency = 1; notes2.Size = UDim2.new(1,-20,0,200); notes2.Position = UDim2.new(0,10,0,108)
notes2.Font = Enum.Font.GothamMedium; notes2.TextSize = 18; notes2.TextWrapped = true; notes2.TextXAlignment = Enum.TextXAlignment.Left
notes2.TextColor3 = Color3.fromRGB(230,245,255)
notes2.Text = [[Credit | Chimera__Gaming

⚠ If you lag:
- Turn down graphics
- Disable popups
- Change servers

FREE at RSCRIPTS]]

local toggleGem = Instance.new("TextButton", gemCard)
toggleGem.Size = UDim2.new(1,-20,0,46); toggleGem.Position = UDim2.new(0,10,1,-56)
toggleGem.BackgroundColor3 = Color3.fromRGB(95,170,255); toggleGem.Text = "Start"
toggleGem.TextColor3 = Color3.new(1,1,1); toggleGem.Font=Enum.Font.GothamBold; toggleGem.TextSize=20
Instance.new("UICorner", toggleGem).CornerRadius = UDim.new(0,12)

-- gem internals
local function resolveFolder(pathArr)
    local n = workspace
    for _,k in ipairs(pathArr) do
        n = n:FindFirstChild(k); if not n then return nil end
    end
    return n
end
local function partsFrom(inst)
    local out = {}
    for _,d in ipairs(inst:GetDescendants()) do
        if d:IsA("BasePart") then table.insert(out, d) end
    end
    return out
end
local function alive(i) return i and i.Parent ~= nil end
local function tpTouch(part)
    if not (alive(part) and HRP and HRP.Parent) then return end
    HRP.CFrame = CFrame.new(part.Position + Vector3.new(0,HOVER_Y,0))
    pcall(function() firetouchinterest(HRP, part, 0) end)
    pcall(function() firetouchinterest(HRP, part, 1) end)
end

local runningGem=false
local queueGem, seenGem = {}, {}
local gemFolder = resolveFolder(GEM_PATH)
local function enqueueGem(g)
    if not g or g.Name:lower() ~= "gem" or seenGem[g] then return end
    seenGem[g] = true; table.insert(queueGem, g)
end
if gemFolder then
    for _,c in ipairs(gemFolder:GetChildren()) do if c.Name:lower()=="gem" then enqueueGem(c) end end
    gemFolder.ChildAdded:Connect(function(c) if c.Name:lower()=="gem" then enqueueGem(c) end end)
end
local function sweepGems()
    local tickCount=0
    while runningGem do
        if #queueGem==0 and gemFolder then
            for _,c in ipairs(gemFolder:GetChildren()) do if c.Name:lower()=="gem" then enqueueGem(c) end end
        end
        local g = table.remove(queueGem,1)
        if g then
            seenGem[g]=nil
            if alive(g) then
                local parts = partsFrom(g)
                table.sort(parts, function(a,b) return (a.Position - HRP.Position).Magnitude < (b.Position - HRP.Position).Magnitude end)
                for _,p in ipairs(parts) do
                    if not alive(g) then break end
                    tpTouch(p); tickCount += 1
                    if tickCount % YIELD_EVERY == 0 then RunService.Heartbeat:Wait() end
                end
            end
        else
            RunService.Heartbeat:Wait()
        end
        statusLabel2.Text = (#queueGem>0) and ("Queue: "..#queueGem) or "Idle"
    end
    statusLabel2.Text = "Stopped"
end

-- Mini + setter for Gem
local gemMini
local function setGemRunning(state)
    if runningGem == state then return end
    runningGem = state
    toggleGem.Text = runningGem and "Stop" or "Start"
    toggleGem.BackgroundColor3 = runningGem and Color3.fromRGB(255,90,90) or Color3.fromRGB(95,170,255)
    if gemMini then gemMini.set(runningGem) end
    if runningGem then task.spawn(sweepGems) end
end
toggleGem.MouseButton1Click:Connect(function() setGemRunning(not runningGem) end)

----------------------------------------------------------------
-- TAB 3: Mine Farm — QuickMine (uniform card)
----------------------------------------------------------------
local tab3 = makeTabButton("Mine Farm", 140, Color3.fromRGB(255,120,90))
local page3 = makePage(); pages[3] = page3
local mineCard, mineTitle = makeCard(page3, "QuickMine Ores", Color3.fromRGB(255,150,120))
makeDraggable(mineCard, mineTitle)

-- controls + list (inside mineCard) — NO PATH TEXT (removed)
local controls = Instance.new("Frame", mineCard)
controls.Size=UDim2.new(1,-20,0,36); controls.Position=UDim2.new(0,10,0,44); controls.BackgroundTransparency=1
local function mkBtn(txt,x)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(0,110,1,0); b.Position=UDim2.new(0,x,0,0)
    b.BackgroundColor3=Color3.fromRGB(50,54,60); b.TextColor3=Color3.fromRGB(235,235,245); b.TextSize=14; b.Font=Enum.Font.Gotham; b.Text=txt
    b.BorderSizePixel=0; Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)
    local s=Instance.new("UIStroke",b); s.Color=Color3.fromRGB(70,74,82); s.Thickness=1; s.Transparency=0.3
    b.Parent=controls; return b
end
local selectAll = mkBtn("Select All",0)
local clearAll  = mkBtn("Clear All",114)
local runBtn    = mkBtn("Run: OFF",228); runBtn.BackgroundColor3=Color3.fromRGB(86,44,44)

local list = Instance.new("ScrollingFrame", mineCard)
list.Size=UDim2.new(1,-20,1,-100); list.Position=UDim2.new(0,10,0,90)
list.AutomaticCanvasSize=Enum.AutomaticSize.Y; list.ScrollBarThickness=6; list.BackgroundTransparency=1
Instance.new("UIListLayout", list).Padding = UDim.new(0,6)

local enabled = {}; for _,n in ipairs(DISPLAY_ORES) do enabled[n]=false end
local buttons = {}
local function makeRow(name)
    local btn = Instance.new("TextButton")
    btn.Size=UDim2.new(1,0,0,30); btn.TextXAlignment=Enum.TextXAlignment.Left; btn.Text="  "..name
    btn.Font=Enum.Font.Gotham; btn.TextSize=14; btn.BorderSizePixel=0; btn.BackgroundColor3=Color3.fromRGB(45,45,52)
    btn.TextColor3=Color3.fromRGB(220,220,230); btn.AutoButtonColor=true
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    local s=Instance.new("UIStroke",btn); s.Color=Color3.fromRGB(66,70,78); s.Thickness=1; s.Transparency=0.4
    btn.Parent=list
    local function refresh() btn.BackgroundColor3 = enabled[name] and Color3.fromRGB(38,94,60) or Color3.fromRGB(45,45,52) end
    btn.MouseButton1Click:Connect(function() enabled[name]=not enabled[name]; refresh() end)
    refresh(); buttons[name]=btn
end
for _,name in ipairs(DISPLAY_ORES) do makeRow(name) end
selectAll.MouseButton1Click:Connect(function() for k in pairs(enabled) do enabled[k]=true end for _,b in pairs(buttons) do b.BackgroundColor3=Color3.fromRGB(38,94,60) end end)
clearAll.MouseButton1Click:Connect(function() for k in pairs(enabled) do enabled[k]=false end for _,b in pairs(buttons) do b.BackgroundColor3=Color3.fromRGB(45,45,52) end end)

-- path + target helpers
local function tryPath()
    local mine = workspace:FindFirstChild("Mine")
    if mine then local ores = mine:FindFirstChild("Ores"); if ores then return ores end end
    local function scan(parent)
        for _,x in ipairs(parent:GetChildren()) do
            if x:IsA("Folder") then
                local hits=0; for _,n in ipairs(DISPLAY_ORES) do if x:FindFirstChild(n) then hits+=1 end end
                if hits>=2 then return x end
                local nxt = scan(x); if nxt then return nxt end
            elseif x:IsA("Model") then local nxt=scan(x); if nxt then return nxt end end
        end
    end
    return scan(workspace)
end
local ORES_ROOT = tryPath()

local function worldPos(inst)
    if not inst or not inst.Parent then return nil end
    if inst:IsA("BasePart") then return inst.Position end
    if inst:IsA("Model") and inst.PrimaryPart then return inst.PrimaryPart.Position end
    local p = inst:FindFirstChildWhichIsA("BasePart", true)
    return p and p.Position or nil
end
local function stillOre(inst) return inst and inst.Parent and ORES_ROOT and inst:IsDescendantOf(ORES_ROOT) end

local function nearestEnabledOre()
    if not ORES_ROOT then return nil end
    local origin = getHRP().Position
    local best, bestD
    for name,on in pairs(enabled) do
        if on then
            local container = ORES_ROOT:FindFirstChild(name)
            if container and (container:IsA("Folder") or container:IsA("Model")) then
                for _,child in ipairs(container:GetChildren()) do
                    local p = worldPos(child)
                    if p then local d=(p-origin).Magnitude; if not bestD or d<bestD then bestD=d; best=child end end
                end
            end
        end
    end
    return best, bestD
end

-- highlight (rainbow)
local currentHL, rainbowConn
local function attachHighlight(target)
    if not target then return end
    if not currentHL then
        currentHL = Instance.new("Highlight"); currentHL.Name="QuickMineTargetHL"
        currentHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        currentHL.FillTransparency = FILL_TRANS; currentHL.OutlineTransparency = OUTLINE_TRANS
        currentHL.Parent = game:GetService("CoreGui")
    end
    currentHL.Adornee = target
    if not rainbowConn then
        local t=0; rainbowConn = RunService.RenderStepped:Connect(function(dt)
            t += dt; local c=Color3.fromHSV((t*0.35)%1,0.9,1); currentHL.OutlineColor=c; currentHL.FillColor=c
        end)
    end
end
local function clearHighlight() if currentHL then currentHL.Adornee=nil end if rainbowConn then rainbowConn:Disconnect(); rainbowConn=nil end end

-- run loop
_G.__qm_running = false
runBtn.MouseButton1Click:Connect(function()
    _G.__qm_running = not _G.__qm_running
    local running = _G.__qm_running
    runBtn.Text = running and "Run: ON" or "Run: OFF"
    runBtn.BackgroundColor3 = running and Color3.fromRGB(44,86,56) or Color3.fromRGB(86,44,44)
    if running then enableNoClipFreeze() else disableNoClipFreeze(); clearHighlight() end
end)
task.spawn(function()
    while page3.Parent do
        if _G.__qm_running then
            local target
            repeat
                local newRoot = tryPath()
                if newRoot ~= ORES_ROOT then ORES_ROOT = newRoot end
                target = nearestEnabledOre()
                task.wait(SCAN_INTERVAL)
            until not page3.Parent or not _G.__qm_running or target
            if page3.Parent and _G.__qm_running and target then
                attachHighlight(target)
                local lastPin=0
                while _G.__qm_running and stillOre(target) do
                    local pos = worldPos(target)
                    if pos and (tick()-lastPin)>=CAMP_REFRESH then tpAndPin(pos); lastPin=tick() end
                    RunService.Heartbeat:Wait()
                end
                clearHighlight(); task.wait(0.05)
            end
        else task.wait(0.1) end
    end
end)
mineCard.Destroying:Connect(function() _G.__qm_running=false; disableNoClipFreeze(); clearHighlight() end)

----------------------------------------------------------------
-- TAB 4: Jungle Leaf Farm — (uniform card)
----------------------------------------------------------------
local tab4 = makeTabButton("Jungle Leaf Farm", 180, Color3.fromRGB(60,190,120))
local page4 = makePage(); pages[4] = page4
local leafCard, leafTitle = makeCard(page4, "Jungle Leaf Farm — Hyper TP", Color3.fromRGB(120,220,170))
makeDraggable(leafCard, leafTitle)

local statusBox4 = Instance.new("Frame", leafCard)
statusBox4.Size = UDim2.new(1,-20,0,56); statusBox4.Position = UDim2.new(0,10,0,44)
statusBox4.BackgroundColor3 = Color3.fromRGB(40,85,70); statusBox4.BackgroundTransparency = 0.15
Instance.new("UICorner", statusBox4).CornerRadius = UDim.new(0,10)
local s4 = Instance.new("UIStroke", statusBox4); s4.Thickness=1.2; s4.Color = Color3.fromRGB(170,255,210); s4.Transparency=0.2

local statusLabel4 = Instance.new("TextLabel", statusBox4)
statusLabel4.BackgroundTransparency=1; statusLabel4.Size=UDim2.new(1,-12,1,-12); statusLabel4.Position=UDim2.new(0,6,0,6)
statusLabel4.Text="Idle"; statusLabel4.TextColor3=Color3.fromRGB(205,255,225); statusLabel4.Font=Enum.Font.GothamMedium; statusLabel4.TextSize=22
statusLabel4.TextXAlignment=Enum.TextXAlignment.Center; statusLabel4.TextYAlignment=Enum.TextYAlignment.Center

-- Same note as Gem, larger text; removed targets text
local notes4 = Instance.new("TextLabel", leafCard)
notes4.BackgroundTransparency=1; notes4.Size=UDim2.new(1,-20,0,200); notes4.Position=UDim2.new(0,10,0,108)
notes4.Font=Enum.Font.GothamMedium; notes4.TextSize=18; notes4.TextWrapped=true; notes4.TextXAlignment=Enum.TextXAlignment.Left
notes4.TextColor3=Color3.fromRGB(220,245,230)
notes4.Text = [[Credit | Chimera__Gaming

⚠ If you lag:
- Turn down graphics
- Disable popups
- Change servers

FREE at RSCRIPTS]]

local toggleLeaf = Instance.new("TextButton", leafCard)
toggleLeaf.Size=UDim2.new(1,-20,0,46); toggleLeaf.Position=UDim2.new(0,10,1,-56)
toggleLeaf.BackgroundColor3=Color3.fromRGB(76,170,130); toggleLeaf.Text="Start"
toggleLeaf.TextColor3=Color3.new(1,1,1); toggleLeaf.Font=Enum.Font.GothamBold; toggleLeaf.TextSize=20
Instance.new("UICorner", toggleLeaf).CornerRadius=UDim.new(0,12)

-- LEAF internals (mirrors gem; name == "Leaf")
local function resolveLeafFolder() return resolveFolder(LEAF_PATH) end
local function enqueueLeaf(t, seen, q)
    if not t or t.Name:lower() ~= "leaf" or seen[t] then return end
    seen[t]=true; table.insert(q, t)
end
local runningLeaf=false
local queueLeaf, seenLeaf = {}, {}
local leafFolder = resolveLeafFolder()
if leafFolder then
    for _,c in ipairs(leafFolder:GetChildren()) do if c.Name:lower()=="leaf" then enqueueLeaf(c, seenLeaf, queueLeaf) end end
    leafFolder.ChildAdded:Connect(function(c) if c.Name:lower()=="leaf" then enqueueLeaf(c, seenLeaf, queueLeaf) end end)
end

local function sweepLeaves()
    local tickCount=0
    while runningLeaf do
        if #queueLeaf==0 and leafFolder then
            for _,c in ipairs(leafFolder:GetChildren()) do if c.Name:lower()=="leaf" then enqueueLeaf(c, seenLeaf, queueLeaf) end end
        end
        local leaf = table.remove(queueLeaf,1)
        if leaf then
            seenLeaf[leaf]=nil
            if alive(leaf) then
                local parts = partsFrom(leaf)
                table.sort(parts, function(a,b) return (a.Position - HRP.Position).Magnitude < (b.Position - HRP.Position).Magnitude end)
                for _,p in ipairs(parts) do
                    if not alive(leaf) then break end
                    tpTouch(p); tickCount += 1
                    if tickCount % YIELD_EVERY == 0 then RunService.Heartbeat:Wait() end
                end
            end
        else
            RunService.Heartbeat:Wait()
        end
        statusLabel4.Text = (#queueLeaf>0) and ("Queue: "..#queueLeaf) or "Idle"
    end
    statusLabel4.Text = "Stopped"
end

-- Mini + setter for Leaf
local leafMini
local function setLeafRunning(state)
    if runningLeaf == state then return end
    runningLeaf = state
    toggleLeaf.Text = runningLeaf and "Stop" or "Start"
    toggleLeaf.BackgroundColor3 = runningLeaf and Color3.fromRGB(255,90,90) or Color3.fromRGB(76,170,130)
    if leafMini then leafMini.set(runningLeaf) end
    if runningLeaf then task.spawn(sweepLeaves) end
end
toggleLeaf.MouseButton1Click:Connect(function() setLeafRunning(not runningLeaf) end)

----------------------------------------------------------------
-- TAB 5: Faster Teleports (uniform card)
----------------------------------------------------------------
local tab5 = makeTabButton("Teleports", 140, Color3.fromRGB(150,120,255))
local page5 = makePage(); pages[5] = page5
local tpCard, tpTitle = makeCard(page5, "Faster Teleports", Color3.fromRGB(150,120,255))
makeDraggable(tpCard, tpTitle)

local hint = Instance.new("TextLabel", tpCard)
hint.BackgroundTransparency = 1
hint.Size = UDim2.new(1,-20,0,18)
hint.Position = UDim2.new(0,10,0,44)
hint.Font = Enum.Font.Gotham
hint.Text = "Instant TP — spawns ~3 studs above target; kills bounce."
hint.TextSize = 12
hint.TextColor3 = Color3.fromRGB(190,185,225)
hint.TextXAlignment = Enum.TextXAlignment.Left

local scroll = Instance.new("ScrollingFrame", tpCard)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
scroll.Size = UDim2.new(1,-20,1,-76); scroll.Position = UDim2.new(0,10,0,66)
scroll.ScrollBarThickness = 6; scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local grid = Instance.new("UIGridLayout", scroll); grid.CellSize = UDim2.new(0, 220, 0, 40); grid.CellPadding = UDim2.new(0, 10, 0, 10); grid.FillDirectionMaxCells = 2

local function fastTP(posV3)
    local hrp = getHRP(); if not hrp then return end
    hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero
    hrp.CFrame = CFrame.new(posV3 + Vector3.new(0,3,0))
    RunService.Heartbeat:Wait()
    if hrp and hrp.Parent then hrp.AssemblyLinearVelocity = Vector3.zero; hrp.AssemblyAngularVelocity = Vector3.zero end
end

for _,entry in ipairs(TELEPORTS) do
    local label, v3 = entry[1], entry[2]
    local btn = Instance.new("TextButton", scroll)
    btn.Text = label; btn.Font = Enum.Font.GothamMedium; btn.TextSize = 14; btn.TextColor3 = Color3.fromRGB(240,238,255)
    if label == "Halloween 2025" then
        btn.BackgroundColor3 = Color3.fromRGB(230,120,20) -- ORANGE special
    else
        btn.BackgroundColor3 = Color3.fromRGB(58,52,95)
    end
    btn.BorderSizePixel = 0; btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
    local bstroke = Instance.new("UIStroke", btn); bstroke.Thickness = 1.2; bstroke.Color = (label=="Halloween 2025") and Color3.fromRGB(255,220,160) or Color3.fromRGB(110,100,170); bstroke.Transparency = 0.15
    btn.MouseButton1Click:Connect(function() fastTP(v3) end)
    btn.MouseButton2Click:Connect(function() if setclipboard then setclipboard(("{%d, %d, %d}"):format(v3.X, v3.Y, v3.Z)) end end)
    btn.MouseEnter:Connect(function()
        if label == "Halloween 2025" then
            btn.BackgroundColor3 = Color3.fromRGB(250,150,40)
        else
            btn.BackgroundColor3 = Color3.fromRGB(82,74,132)
        end
    end)
    btn.MouseLeave:Connect(function()
        if label == "Halloween 2025" then
            btn.BackgroundColor3 = Color3.fromRGB(230,120,20)
        else
            btn.BackgroundColor3 = Color3.fromRGB(58,52,95)
        end
    end)
end

----------------------------------------------------------------
-- TAB 6: Suggestions (uniform card)
----------------------------------------------------------------
local tab6 = makeTabButton("Suggestions", 160, Color3.fromRGB(120,170,255))
local page6 = makePage(); pages[6] = page6
local sugCard, sugTitle = makeCard(page6, "Suggestions", Color3.fromRGB(120,170,255))
makeDraggable(sugCard, sugTitle)

local big = Instance.new("TextLabel", sugCard)
big.BackgroundTransparency = 1
big.Size = UDim2.new(1,-20,1,-60)
big.Position = UDim2.new(0,10,0,40)
big.Font = Enum.Font.GothamBlack
big.TextSize = 28
big.TextWrapped = true
big.TextXAlignment = Enum.TextXAlignment.Center
big.TextYAlignment = Enum.TextYAlignment.Center
big.TextColor3 = Color3.fromRGB(210,230,255)
big.Text = "Head to RSCRIPTS and leave a suggestion for what to add next!"

----------------------------------------------------------------
-- Tab binding + window controls
----------------------------------------------------------------
local function bindTab(btn, index) btn.MouseButton1Click:Connect(function() showPage(index) end) end
bindTab(tab1,1); bindTab(tab2,2); bindTab(tab3,3); bindTab(tab4,4); bindTab(tab5,5); bindTab(tab6,6)
showPage(1)

local function setMinimized(state) window.Visible = not state; bubble.Visible = state end
minBtn.MouseButton1Click:Connect(function() setMinimized(true) end)
bubble.MouseButton1Click:Connect(function() setMinimized(false) end)

closeBtn.MouseButton1Click:Connect(function() enforcing=false; if gui then gui:Destroy() end end)

----------------------------------------------------------------
-- Create the MINI toggles now that everything exists
----------------------------------------------------------------
gemMini = makeMiniToggle{
    emoji = "💎",
    baseColor = Color3.fromRGB(95,170,255),
    positionUDim2 = UDim2.new(1, -70, 0.5, -140),
    onToggle = function(state) setGemRunning(state) end
}
leafMini = makeMiniToggle{
    emoji = "🍃",
    baseColor = Color3.fromRGB(76,170,130),
    positionUDim2 = UDim2.new(1, -70, 0.5, -76),
    onToggle = function(state) setLeafRunning(state) end
}
-- If you auto-start either farm, reflect it in the minis:
if runningGem  then gemMini.set(true)  end
if runningLeaf then leafMini.set(true) end
