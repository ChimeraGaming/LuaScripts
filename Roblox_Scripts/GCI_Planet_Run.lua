--============================================================
-- Planet Run UI
--============================================================

--============================================================
-- 01. SERVICES
--============================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--============================================================
-- 02. PLAYER / CONSTANTS
--============================================================

local player = Players.LocalPlayer

local MIN_SPEED = 50
local MAX_SPEED = 200
local speedValue = 100

local DEFAULT_MIN_RUN_TIME = 21
local START_WAIT_TIME = 2
local DAILY_ZONE_BONUS = 50

local dailyRunning = false
local dailyRunButton
local dailyTokenButton

--============================================================
-- 03. ROUTE DATA
--============================================================

local zones = {
    ["Zone 1: The Island"] = {
        ["1-1"] = { minTime = 21, tokens = 6, path = {
            CFrame.new(-58, -24985, 19959),
            CFrame.new(-62, -24978, 19418),
            CFrame.new(-125, -24986, 19139),
            CFrame.new(166, -24986, 18893),
            CFrame.new(594, -24970, 18975),
            CFrame.new(593, -24970, 19354),
            CFrame.new(588, -24986, 19852),
            CFrame.new(592, -24986, 19953),
        }},
        ["1-2"] = { minTime = 21, tokens = 6, path = {
            CFrame.new(-1668, -24985, 19960),
            CFrame.new(-1699, -24957, 19572),
            CFrame.new(-1713, -24942, 19184),
            CFrame.new(-1433, -24905, 18884),
            CFrame.new(-1102, -24934, 19116),
            CFrame.new(-1233, -24937, 19361),
            CFrame.new(-1025, -24968, 19764),
            CFrame.new(-1023, -24985, 19956),
        }},
        ["1-3"] = { minTime = 21, tokens = 6, path = {
            CFrame.new(-3279, -24985, 19959),
            CFrame.new(-3236, -24985, 19511),
            CFrame.new(-3239, -24964, 19093),
            CFrame.new(-2939, -24925, 18906),
            CFrame.new(-2665, -24971, 19136),
            CFrame.new(-2549, -24968, 19592),
            CFrame.new(-2630, -24969, 19835),
            CFrame.new(-2635, -24985, 19953),
        }},
    },

    ["Zone 2: Space"] = {
        ["2-1"] = { minTime = 21, tokens = 6, path = {
            CFrame.new(3163, -24985, 16443),
            CFrame.new(3185, -24970, 16019),
            CFrame.new(3022, -24873, 15793),
            CFrame.new(3285, -24834, 15522),
            CFrame.new(3570, -24749, 15641),
            CFrame.new(3627, -24733, 15880),
            CFrame.new(3751, -24754, 16159),
            CFrame.new(3801, -24796, 16440),
        }},
        ["2-2"] = { minTime = 21, tokens = 6, path = {
            CFrame.new(1553, -24985, 16443),
            CFrame.new(1555, -24928, 15979),
            CFrame.new(1453, -24890, 15572),
            CFrame.new(1765, -24898, 15384),
            CFrame.new(2191, -24907, 15377),
            CFrame.new(2209, -24907, 15620),
            CFrame.new(2194, -24928, 15950),
            CFrame.new(2205, -24929, 16125),
        }},
        ["2-3"] = { minTime = 21, tokens = 5, path = {
            CFrame.new(-40, -24985, 16442),
            CFrame.new(-56, -24990, 16006),
            CFrame.new(-162, -24966, 15669),
            CFrame.new(425, -24926, 15340),
            CFrame.new(782, -24935, 15529),
            CFrame.new(726, -24940, 16219),
            CFrame.new(706, -24985, 16345),
        }},
    },

    ["Zone 3: Anti Realm"] = {
        ["3-1"] = { minTime = 21, tokens = 5, path = {
            CFrame.new(-6497, -24985, 19959),
            CFrame.new(-6523, -24981, 19543),
            CFrame.new(-6262, -24946, 19153),
            CFrame.new(-5960, -24973, 19011),
            CFrame.new(-6054, -24954, 19339),
            CFrame.new(-5928, -24974, 19727),
            CFrame.new(-5858, -24985, 19956),
        }},
        ["3-2"] = { minTime = 21, tokens = 5, path = {
            CFrame.new(-7804, -24985, 19959),
            CFrame.new(-8186, -24932, 19658),
            CFrame.new(-8186, -24918, 19330),
            CFrame.new(-8284, -24956, 18988),
            CFrame.new(-7176, -24924, 19158),
            CFrame.new(-7412, -24924, 19664),
            CFrame.new(-7778, -24802, 19612),
        }},
        ["3-3"] = { minTime = 21, tokens = 6, path = {
            CFrame.new(-10139, -24720, 20150),
            CFrame.new(-10141, -24796, 19607),
            CFrame.new(-10037, -24752, 19073),
            CFrame.new(-10029, -24677, 19493),
            CFrame.new(-9356, -24637, 19204),
            CFrame.new(-8723, -24648, 19598),
            CFrame.new(-8823, -24505, 19981),
            CFrame.new(-8801, -24488, 20132),
        }},
    },

    ["Zone 4: Dark Forest"] = {
        ["4-1"] = { minTime = 21, tokens = 6, path = {
            CFrame.new(-6761, -24883, 16566),
            CFrame.new(-6673, -24923, 16022),
            CFrame.new(-6613, -24897, 15658),
            CFrame.new(-6383, -24941, 15526),
            CFrame.new(-5980, -24930, 15556),
            CFrame.new(-5905, -24907, 15900),
            CFrame.new(-6182, -24851, 16037),
            CFrame.new(-6195, -24840, 16351),
        }},
        ["4-2"] = { minTime = 21, tokens = 6, path = {
            CFrame.new(-8347, -24893, 16509),
            CFrame.new(-8408, -24959, 15620),
            CFrame.new(-7512, -24903, 15442),
            CFrame.new(-8049, -24959, 15858),
            CFrame.new(-8285, -24817, 16220),
            CFrame.new(-7569, -24959, 15863),
            CFrame.new(-7282, -24907, 16328),
            CFrame.new(-7385, -24893, 16507),
        }},
    },

    ["Zone Lol: Gamer Mode"] = {
        ["Lol-1"] = { minTime = 60, tokens = 1, path = {
            CFrame.new(9890, -24985, 19956),
            CFrame.new(9867, -24867, 19713),
            CFrame.new(9867, -24866, 19704),
        }},
        ["Lol-2"] = { minTime = 70, tokens = 2, path = {
            CFrame.new(11501, -24985, 19957),
            CFrame.new(11476, -24867, 19711),
            CFrame.new(11476, -24866, 19702),
        }},
        ["Lol-3"] = { minTime = 150, tokens = 3, path = {
            CFrame.new(13111, -24985, 19956),
            CFrame.new(13096, -24867, 19713),
            CFrame.new(13096, -24867, 19713),
            CFrame.new(13080, -24867, 19712),
            CFrame.new(13086, -24866, 19703),
        }},
        ["Lol-4"] = { minTime = 180, tokens = 4, path = {
            CFrame.new(14720, -24985, 19956),
            CFrame.new(14689, -24867, 19711),
            CFrame.new(14704, -24867, 19710),
            CFrame.new(14704, -24867, 19710),
        }},
        ["Lol-5"] = { minTime = 240, tokens = 5, path = {
            CFrame.new(16330, -24985, 19956),
            CFrame.new(16297, -24867, 19710),
            CFrame.new(16318, -24867, 19710),
            CFrame.new(16318, -24867, 19710),
        }},
    },
}

local unlockLolCFrame = CFrame.new(-9400, -24638, 19070)

--============================================================
-- 04. DISPLAY ORDER
--============================================================

local zoneOrder = {
    "Zone 1: The Island",
    "Zone 2: Space",
    "Zone 3: Anti Realm",
    "Zone 4: Dark Forest",
    "Zone Lol: Gamer Mode",
}

local levelOrder = {
    ["Zone 1: The Island"] = {"1-1", "1-2", "1-3"},
    ["Zone 2: Space"] = {"2-1", "2-2", "2-3"},
    ["Zone 3: Anti Realm"] = {"3-1", "3-2", "3-3"},
    ["Zone 4: Dark Forest"] = {"4-1", "4-2"},
    ["Zone Lol: Gamer Mode"] = {"Lol-1", "Lol-2", "Lol-3", "Lol-4", "Lol-5"},
}

--============================================================
-- 05. CORE FUNCTIONS
--============================================================

local function formatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
    return getCharacter():WaitForChild("HumanoidRootPart")
end

local function getHumanoid()
    return getCharacter():WaitForChild("Humanoid")
end

local function applyWalkSpeed()
    getHumanoid().WalkSpeed = speedValue
end

local function teleportTo(cf)
    applyWalkSpeed()
    getHRP().CFrame = cf
end

local function setStatus(label, text)
    if label then
        label.Text = text
    end
end

local function getAllLevels()
    local list = {}

    for _, zoneName in ipairs(zoneOrder) do
        for _, levelName in ipairs(levelOrder[zoneName]) do
            table.insert(list, {
                zoneName = zoneName,
                levelName = levelName,
                levelData = zones[zoneName][levelName],
            })
        end
    end

    return list
end

local function getTokenCount()
    local total = 0

    for _, item in ipairs(getAllLevels()) do
        total += item.levelData.tokens or 0
    end

    return total
end

local function getDailyRunTokenCount()
    return getTokenCount() + (#zoneOrder * DAILY_ZONE_BONUS)
end

local function getTotalFairTime()
    local total = 0

    for _, item in ipairs(getAllLevels()) do
        total += item.levelData.minTime or DEFAULT_MIN_RUN_TIME
    end

    return total
end

local function getTokenRunTime()
    local total = 0

    for _, item in ipairs(getAllLevels()) do
        local path = item.levelData.path

        if path and #path > 1 then
            for i = 1, #path - 1 do
                total += (path[i + 1].Position - path[i].Position).Magnitude / speedValue
            end

            total += START_WAIT_TIME
        end
    end

    return total
end

local function updateDailyButtonText()
    if dailyRunButton then
        dailyRunButton.Text = "Daily Run (" .. getDailyRunTokenCount() .. " Tokens) " .. formatTime(getTotalFairTime())
    end

    if dailyTokenButton then
        dailyTokenButton.Text = "Daily Token - skip timer (" .. getTokenCount() .. " Tokens) " .. formatTime(getTokenRunTime())
    end
end

local function waitWithCountdown(levelName, remaining, statusLabel)
    local endTime = os.clock() + remaining

    while os.clock() < endTime do
        local left = math.max(0, math.ceil(endTime - os.clock()))
        setStatus(statusLabel, levelName .. " final clear in " .. formatTime(left))
        task.wait(0.2)
    end
end

local function waitAtStart(levelName, statusLabel)
    for t = START_WAIT_TIME, 1, -1 do
        setStatus(statusLabel, levelName .. " starting in " .. t .. "s")
        task.wait(1)
    end
end

local function runPath(levelName, levelData, statusLabel, skipTimer)
    local path = levelData.path
    local minRunTime = levelData.minTime or DEFAULT_MIN_RUN_TIME

    if not path or #path == 0 then
        setStatus(statusLabel, levelName .. " has no path yet")
        return
    end

    local startTime = os.clock()

    for i, cf in ipairs(path) do
        setStatus(statusLabel, levelName .. " > teleport " .. i .. "/" .. #path)
        teleportTo(cf)

        if i == 1 then
            waitAtStart(levelName, statusLabel)
        end

        if i == #path and not skipTimer then
            local remaining = minRunTime - (os.clock() - startTime)

            if remaining > 0 then
                waitWithCountdown(levelName, remaining, statusLabel)
            end
        end

        task.wait(0.05)
    end

    setStatus(statusLabel, levelName .. " complete")
end

local function runDaily(statusLabel, skipTimer)
    if dailyRunning then
        setStatus(statusLabel, "Daily run already active")
        return
    end

    dailyRunning = true
    applyWalkSpeed()

    local levels = getAllLevels()
    local tokenTotal = skipTimer and getTokenCount() or getDailyRunTokenCount()
    local expectedTime = skipTimer and getTokenRunTime() or getTotalFairTime()
    local startTime = os.clock()

    for index, item in ipairs(levels) do
        local elapsed = os.clock() - startTime

        setStatus(
            statusLabel,
            "Daily " .. index .. "/" .. #levels ..
            " | Tokens: " .. tokenTotal ..
            " | Time: " .. formatTime(elapsed) ..
            " / " .. formatTime(expectedTime) ..
            " | Running " .. item.levelName
        )

        runPath(item.levelName, item.levelData, statusLabel, skipTimer)
        task.wait(0.25)
    end

    setStatus(statusLabel, "Daily complete | Tokens: " .. tokenTotal .. " | Total Time: " .. formatTime(os.clock() - startTime))
    dailyRunning = false
end

--============================================================
-- 06. CLEANUP OLD UI
--============================================================

local old = game.CoreGui:FindFirstChild("PlanetRunUI")
if old then
    old:Destroy()
end

--============================================================
-- 07. ROOT GUI
--============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "PlanetRunUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 390, 0, 690)
main.Position = UDim2.new(0.5, -195, 0.5, -345)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

--============================================================
-- 08. TITLE BAR
--============================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -78, 0, 40)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Planet Run"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 30, 0, 30)
minimize.Position = UDim2.new(1, -70, 0, 5)
minimize.Text = "-"
minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
minimize.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 18
minimize.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -36, 0, 5)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.BackgroundColor3 = Color3.fromRGB(125, 35, 35)
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.Parent = main

local bubble = Instance.new("TextButton")
bubble.Size = UDim2.new(0, 115, 0, 38)
bubble.Position = UDim2.new(0, 20, 0.5, -19)
bubble.Text = "Planet Run"
bubble.TextColor3 = Color3.fromRGB(255, 255, 255)
bubble.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
bubble.Font = Enum.Font.GothamBold
bubble.TextSize = 14
bubble.Visible = false
bubble.Active = true
bubble.Draggable = true
bubble.Parent = gui

--============================================================
-- 09. SPEED SLIDER
--============================================================

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -24, 0, 25)
speedLabel.Position = UDim2.new(0, 12, 0, 45)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "WalkSpeed: " .. speedValue
speedLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
speedLabel.TextSize = 14
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = main

local sliderBack = Instance.new("Frame")
sliderBack.Size = UDim2.new(1, -24, 0, 8)
sliderBack.Position = UDim2.new(0, 12, 0, 76)
sliderBack.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
sliderBack.BorderSizePixel = 0
sliderBack.Parent = main

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((speedValue - MIN_SPEED) / (MAX_SPEED - MIN_SPEED), 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(90, 180, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBack

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(0, 18, 0, 18)
sliderButton.Position = UDim2.new(sliderFill.Size.X.Scale, -9, 0.5, -9)
sliderButton.Text = ""
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.BorderSizePixel = 0
sliderButton.Parent = sliderBack

local draggingSlider = false

--============================================================
-- 10. HEADER / WARNING / DAILY BUTTONS
--============================================================

local line = Instance.new("Frame")
line.Size = UDim2.new(1, -24, 0, 1)
line.Position = UDim2.new(0, 12, 0, 100)
line.BackgroundColor3 = Color3.fromRGB(90, 90, 110)
line.BorderSizePixel = 0
line.Parent = main

local farmingTitle = Instance.new("TextLabel")
farmingTitle.Size = UDim2.new(1, -24, 0, 28)
farmingTitle.Position = UDim2.new(0, 12, 0, 108)
farmingTitle.BackgroundTransparency = 1
farmingTitle.Text = "Farming Buttons"
farmingTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
farmingTitle.TextSize = 18
farmingTitle.Font = Enum.Font.GothamBold
farmingTitle.TextXAlignment = Enum.TextXAlignment.Left
farmingTitle.Parent = main

local warning = Instance.new("TextLabel")
warning.Size = UDim2.new(1, -24, 0, 48)
warning.Position = UDim2.new(0, 12, 0, 136)
warning.BackgroundColor3 = Color3.fromRGB(45, 32, 20)
warning.BorderSizePixel = 0
warning.Text = "WARNING: 1-1 through 4-2 complete at 21s.\nLol runs use fair times. Tokens only show once per day."
warning.TextColor3 = Color3.fromRGB(255, 210, 140)
warning.TextSize = 12
warning.Font = Enum.Font.GothamBold
warning.TextWrapped = true
warning.Parent = main

dailyRunButton = Instance.new("TextButton")
dailyRunButton.Size = UDim2.new(1, -24, 0, 32)
dailyRunButton.Position = UDim2.new(0, 12, 0, 190)
dailyRunButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dailyRunButton.BackgroundColor3 = Color3.fromRGB(45, 110, 70)
dailyRunButton.Font = Enum.Font.GothamBold
dailyRunButton.TextSize = 14
dailyRunButton.Parent = main

dailyTokenButton = Instance.new("TextButton")
dailyTokenButton.Size = UDim2.new(1, -24, 0, 32)
dailyTokenButton.Position = UDim2.new(0, 12, 0, 226)
dailyTokenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dailyTokenButton.BackgroundColor3 = Color3.fromRGB(70, 95, 150)
dailyTokenButton.Font = Enum.Font.GothamBold
dailyTokenButton.TextSize = 14
dailyTokenButton.Parent = main

local unlockLolButton = Instance.new("TextButton")
unlockLolButton.Size = UDim2.new(1, -24, 0, 32)
unlockLolButton.Position = UDim2.new(0, 12, 0, 262)
unlockLolButton.Text = "Unlock Zone Lol: Gamer Mode"
unlockLolButton.TextColor3 = Color3.fromRGB(255, 255, 255)
unlockLolButton.BackgroundColor3 = Color3.fromRGB(120, 70, 180)
unlockLolButton.Font = Enum.Font.GothamBold
unlockLolButton.TextSize = 14
unlockLolButton.Parent = main

local unlockNote = Instance.new("TextLabel")
unlockNote.Size = UDim2.new(1, -24, 0, 28)
unlockNote.Position = UDim2.new(0, 12, 0, 296)
unlockNote.BackgroundTransparency = 1
unlockNote.Text = "Enter Zone 3-3, then click this to unlock Gamer Mode."
unlockNote.TextColor3 = Color3.fromRGB(200, 190, 230)
unlockNote.TextSize = 12
unlockNote.Font = Enum.Font.Gotham
unlockNote.TextXAlignment = Enum.TextXAlignment.Left
unlockNote.Parent = main

--============================================================
-- 11. SCROLL AREA
--============================================================

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -24, 1, -377)
scroll.Position = UDim2.new(0, 12, 0, 327)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = main

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -5, 0, 0)
content.BackgroundTransparency = 1
content.Parent = scroll

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

--============================================================
-- 12. STATUS BAR
--============================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 44)
status.Position = UDim2.new(0, 12, 1, -50)
status.BackgroundTransparency = 1
status.Text = "Idle"
status.TextColor3 = Color3.fromRGB(180, 220, 255)
status.TextSize = 13
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextWrapped = true
status.Parent = main

--============================================================
-- 13. BUILD FARMING BUTTONS
--============================================================

local orderNum = 0

for _, zoneName in ipairs(zoneOrder) do
    orderNum += 1

    local zoneHeader = Instance.new("TextLabel")
    zoneHeader.Size = UDim2.new(1, 0, 0, 28)
    zoneHeader.BackgroundColor3 = Color3.fromRGB(25, 25, 36)
    zoneHeader.BorderSizePixel = 0
    zoneHeader.Text = zoneName
    zoneHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    zoneHeader.TextSize = 15
    zoneHeader.Font = Enum.Font.GothamBold
    zoneHeader.TextXAlignment = Enum.TextXAlignment.Left
    zoneHeader.LayoutOrder = orderNum
    zoneHeader.Parent = content

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10)
    pad.Parent = zoneHeader

    for _, levelName in ipairs(levelOrder[zoneName]) do
        orderNum += 1

        local levelData = zones[zoneName][levelName]

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 38)
        row.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
        row.BorderSizePixel = 0
        row.LayoutOrder = orderNum
        row.Parent = content

        local levelLabel = Instance.new("TextLabel")
        levelLabel.Size = UDim2.new(1, -60, 1, 0)
        levelLabel.Position = UDim2.new(0, 10, 0, 0)
        levelLabel.BackgroundTransparency = 1
        levelLabel.Text = levelName .. " [" .. tostring(levelData.tokens or 0) .. " Tokens] [" .. tostring(levelData.minTime or DEFAULT_MIN_RUN_TIME) .. "s]"
        levelLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
        levelLabel.TextSize = 14
        levelLabel.Font = Enum.Font.GothamBold
        levelLabel.TextXAlignment = Enum.TextXAlignment.Left
        levelLabel.Parent = row

        local onceButton = Instance.new("TextButton")
        onceButton.Size = UDim2.new(0, 35, 0, 28)
        onceButton.Position = UDim2.new(1, -43, 0.5, -14)
        onceButton.Text = "[1]"
        onceButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        onceButton.BackgroundColor3 = Color3.fromRGB(45, 90, 140)
        onceButton.Font = Enum.Font.GothamBold
        onceButton.TextSize = 14
        onceButton.Parent = row

        onceButton.MouseButton1Click:Connect(function()
            task.spawn(function()
                runPath(levelName, levelData, status, false)
            end)
        end)
    end
end

--============================================================
-- 14. CONNECTIONS
--============================================================

minimize.MouseButton1Click:Connect(function()
    main.Visible = false
    bubble.Visible = true
end)

bubble.MouseButton1Click:Connect(function()
    bubble.Visible = false
    main.Visible = true
end)

close.MouseButton1Click:Connect(function()
    dailyRunning = false
    gui:Destroy()
end)

dailyRunButton.MouseButton1Click:Connect(function()
    task.spawn(function()
        runDaily(status, false)
    end)
end)

dailyTokenButton.MouseButton1Click:Connect(function()
    task.spawn(function()
        runDaily(status, true)
    end)
end)

unlockLolButton.MouseButton1Click:Connect(function()
    teleportTo(unlockLolCFrame)
    setStatus(status, "Teleported to Zone Lol unlock button")
end)

sliderButton.MouseButton1Down:Connect(function()
    draggingSlider = true
end)

sliderBack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

RunService.RenderStepped:Connect(function()
    if draggingSlider and sliderBack.Parent then
        local mouse = player:GetMouse()
        local percent = math.clamp((mouse.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)

        speedValue = math.floor(MIN_SPEED + ((MAX_SPEED - MIN_SPEED) * percent))
        speedLabel.Text = "WalkSpeed: " .. speedValue

        applyWalkSpeed()
        updateDailyButtonText()

        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderButton.Position = UDim2.new(percent, -9, 0.5, -9)
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    applyWalkSpeed()
end)

--============================================================
-- 15. SCROLL SIZE UPDATE
--============================================================

task.defer(function()
    applyWalkSpeed()
    updateDailyButtonText()

    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    content.Size = UDim2.new(1, -5, 0, layout.AbsoluteContentSize.Y + 10)
end)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    content.Size = UDim2.new(1, -5, 0, layout.AbsoluteContentSize.Y + 10)
end)
