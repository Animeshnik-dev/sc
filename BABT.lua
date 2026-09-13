-- ⚡ Ryzen Hub × MeltaKIK | Build A Boat For Treasure
-- Visuals + AutoFarm (loadstring) + Sky Changer + Reopen Button

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer

for _, name in ipairs({"RyzenMeltaKIK", "MeltaKIK_Reopen"}) do
    if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
end

-- ═══════════════════════════════════════════
-- ПЛАВАЮЩАЯ КНОПКА "ОТКРЫТЬ"
-- ═══════════════════════════════════════════
local reopenGui = Instance.new("ScreenGui")
reopenGui.Name = "MeltaKIK_Reopen"
reopenGui.ResetOnSpawn = false
reopenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
reopenGui.Parent = CoreGui

local reopenBtn = Instance.new("TextButton")
reopenBtn.Size = UDim2.new(0, 44, 0, 44)
reopenBtn.Position = UDim2.new(0, 20, 0.5, -22)
reopenBtn.BackgroundColor3 = Color3.fromRGB(50, 35, 80)
reopenBtn.Text = "⚡"
reopenBtn.TextColor3 = Color3.fromRGB(220, 180, 255)
reopenBtn.Font = Enum.Font.GothamBold
reopenBtn.TextSize = 22
reopenBtn.BorderSizePixel = 0
reopenBtn.Active = true
reopenBtn.Draggable = true
reopenBtn.Parent = reopenGui
Instance.new("UICorner", reopenBtn).CornerRadius = UDim.new(1, 0)

local reopenStroke = Instance.new("UIStroke", reopenBtn)
reopenStroke.Color = Color3.fromRGB(160, 100, 240)
reopenStroke.Thickness = 2

-- ═══════════════════════════════════════════
-- ГЛАВНЫЙ GUI
-- ═══════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name = "RyzenMeltaKIK"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 470, 0, 300)
main.Position = UDim2.new(0.5, -235, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(120, 60, 200)
mainStroke.Thickness = 2
mainStroke.Transparency = 0.3

-- ═══════════════════════════════════════════
-- TOP BAR
-- ═══════════════════════════════════════════
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 44)
topBar.BackgroundColor3 = Color3.fromRGB(26, 20, 42)
topBar.BorderSizePixel = 0
topBar.Parent = main
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local titleLbl = Instance.new("TextLabel")
titleLbl.Size = UDim2.new(0, 320, 1, 0)
titleLbl.Position = UDim2.new(0, 16, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = "⚡ Ryzen Hub  ×  MeltaKIK"
titleLbl.TextColor3 = Color3.fromRGB(210, 170, 255)
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextSize = 15
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent = topBar

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(1, -140, 0.5, -4)
statusDot.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
statusDot.BorderSizePixel = 0
statusDot.Parent = topBar
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(0, 100, 1, 0)
statusLbl.Position = UDim2.new(1, -125, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Connected"
statusLbl.TextColor3 = Color3.fromRGB(150, 150, 160)
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 12
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Parent = topBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -70, 0, 9)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 55, 80)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(220, 220, 225)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.BorderSizePixel = 0
minBtn.Parent = topBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -38, 0, 9)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
end)

-- ═══════════════════════════════════════════
-- SIDEBAR
-- ═══════════════════════════════════════════
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, -56)
sidebar.Position = UDim2.new(0, 8, 0, 48)
sidebar.BackgroundColor3 = Color3.fromRGB(24, 22, 32)
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local sidebarLayout = Instance.new("UIListLayout", sidebar)
sidebarLayout.Padding = UDim.new(0, 6)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local sidebarPad = Instance.new("UIPadding", sidebar)
sidebarPad.PaddingTop = UDim.new(0, 8)

-- ═══════════════════════════════════════════
-- КОНТЕНТ
-- ═══════════════════════════════════════════
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -154, 1, -56)
contentFrame.Position = UDim2.new(0, 146, 0, 48)
contentFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
contentFrame.BorderSizePixel = 0
contentFrame.Parent = main
Instance.new("UICorner", contentFrame).CornerRadius = UDim.new(0, 10)

local pageRyzen = Instance.new("ScrollingFrame")
pageRyzen.Size = UDim2.new(1, -12, 1, -12)
pageRyzen.Position = UDim2.new(0, 6, 0, 6)
pageRyzen.BackgroundTransparency = 1
pageRyzen.BorderSizePixel = 0
pageRyzen.ScrollBarThickness = 4
pageRyzen.ScrollBarImageColor3 = Color3.fromRGB(120, 60, 200)
pageRyzen.CanvasSize = UDim2.new(0, 0, 0, 0)
pageRyzen.AutomaticCanvasSize = Enum.AutomaticSize.Y
pageRyzen.Parent = contentFrame
Instance.new("UIListLayout", pageRyzen).Padding = UDim.new(0, 6)

local pageMelta = Instance.new("ScrollingFrame")
pageMelta.Size = UDim2.new(1, -12, 1, -12)
pageMelta.Position = UDim2.new(0, 6, 0, 6)
pageMelta.BackgroundTransparency = 1
pageMelta.BorderSizePixel = 0
pageMelta.ScrollBarThickness = 4
pageMelta.ScrollBarImageColor3 = Color3.fromRGB(120, 60, 200)
pageMelta.CanvasSize = UDim2.new(0, 0, 0, 0)
pageMelta.AutomaticCanvasSize = Enum.AutomaticSize.Y
pageMelta.Visible = false
pageMelta.Parent = contentFrame
Instance.new("UIListLayout", pageMelta).Padding = UDim.new(0, 6)

-- ═══════════════════════════════════════════
-- СВОРАЧИВАНИЕ
-- ═══════════════════════════════════════════
local minimized = false
local originalSize = main.Size

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        originalSize = main.Size
        main.Size = UDim2.new(0, originalSize.X.Offset, 0, 44)
        sidebar.Visible = false
        contentFrame.Visible = false
        minBtn.Text = "+"
    else
        main.Size = originalSize
        sidebar.Visible = true
        contentFrame.Visible = true
        minBtn.Text = "—"
    end
end)

reopenBtn.MouseButton1Click:Connect(function()
    main.Visible = true
end)

-- ═══════════════════════════════════════════
-- ФАБРИКА: TABS
-- ═══════════════════════════════════════════
local allTabBtns = {}

local function makeTabBtn(text, tabId)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(32, 30, 42)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.LayoutOrder = #allTabBtns + 1
    btn.Parent = sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0.6, 0)
    indicator.Position = UDim2.new(0, 0, 0.2, 0)
    indicator.BackgroundColor3 = Color3.fromRGB(160, 100, 240)
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = btn

    btn.MouseEnter:Connect(function()
        if btn.BackgroundColor3 ~= Color3.fromRGB(50, 35, 80) then
            btn.BackgroundColor3 = Color3.fromRGB(45, 40, 65)
        end
    end)
    btn.MouseLeave:Connect(function()
        if btn.BackgroundColor3 ~= Color3.fromRGB(50, 35, 80) then
            btn.BackgroundColor3 = Color3.fromRGB(32, 30, 42)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        for _, other in ipairs(allTabBtns) do
            other.BackgroundColor3 = Color3.fromRGB(32, 30, 42)
            local ind = other:FindFirstChildOfClass("Frame")
            if ind then ind.Visible = false end
        end
        btn.BackgroundColor3 = Color3.fromRGB(50, 35, 80)
        indicator.Visible = true
        pageRyzen.Visible = (tabId == "ryzen")
        pageMelta.Visible = (tabId == "melta")
    end)

    table.insert(allTabBtns, btn)
    return btn
end

-- ═══════════════════════════════════════════
-- ФАБРИКИ ЭЛЕМЕНТОВ
-- ═══════════════════════════════════════════
local function makeButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(32, 30, 42)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 225)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(50, 40, 75) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(32, 30, 42) end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function makeLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -6, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(140, 120, 180)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function makeToggle(parent, text, default, callback)
    local state = default
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(32, 30, 42)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220, 220, 225)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", btn)
    track.Size = UDim2.new(0, 32, 0, 16)
    track.Position = UDim2.new(1, -42, 0.5, -8)
    track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(0, 2, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function render()
        if state then
            track.BackgroundColor3 = Color3.fromRGB(120, 60, 200)
            knob.Position = UDim2.new(1, -14, 0.5, -6)
        else
            track.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            knob.Position = UDim2.new(0, 2, 0.5, -6)
        end
    end
    render()

    btn.MouseButton1Click:Connect(function()
        state = not state
        render()
        callback(state)
    end)
    return btn
end

local function makeSlider(parent, name, minV, maxV, defaultV, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -6, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Text = name .. ": " .. defaultV
    lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 8)
    bg.Position = UDim2.new(0, 0, 0, 26)
    bg.BackgroundColor3 = Color3.fromRGB(50, 48, 60)
    bg.BorderSizePixel = 0
    bg.Parent = container
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

    local alpha = (defaultV - minV) / (maxV - minV)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(alpha, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(120, 60, 200)
    fill.BorderSizePixel = 0
    fill.Parent = bg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(alpha, -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(230, 230, 235)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.Parent = bg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local dragging, current = false, defaultV
    local function setVal(v)
        current = math.clamp(v, minV, maxV)
        local a = (current - minV) / (maxV - minV)
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, -7, 0.5, -7)
        lbl.Text = name .. ": " .. math.floor(current)
        callback(current)
    end

    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = (i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X
            setVal(minV + math.clamp(rel, 0, 1) * (maxV - minV))
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return setVal
end

-- ═══════════════════════════════════════════
-- ВКЛАДКИ
-- ═══════════════════════════════════════════
local tabRyzen = makeTabBtn("👁  Ryzen Hub", "ryzen")
local tabMelta = makeTabBtn("⚙  MeltaKIK", "melta")

tabRyzen.BackgroundColor3 = Color3.fromRGB(50, 35, 80)
tabRyzen:FindFirstChildOfClass("Frame").Visible = true
pageRyzen.Visible = true
pageMelta.Visible = false

-- ═══════════════════════════════════════════
-- TELEPORT ЛОГИКА
-- ═══════════════════════════════════════════
local function getAllChests()
    local chests = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "GoldenChest" or obj.Name:lower():find("chest") then
            table.insert(chests, obj)
        end
    end
    return chests
end

local function tpOnChest(chest)
    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local target = chest:IsA("BasePart") and chest or chest:FindFirstChildWhichIsA("BasePart")
    if target then
        local heightOffset = (target.Size.Y / 2) + 3
        root.CFrame = CFrame.new(target.Position + Vector3.new(0, heightOffset, 0))
    end
end

local function tpToFinish()
    local chest = workspace:FindFirstChild("GoldenChest", true)
    if chest then
        tpOnChest(chest)
    else
        local char = lp.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(0, 500, 5000)
        end
    end
end

-- ═══════════════════════════════════════════
-- PAGE 1: RYZEN HUB (ТОЛЬКО ВИЗУАЛЫ)
-- ═══════════════════════════════════════════
makeLabel(pageRyzen, "── ESP ──")

local espChests = {}
local function createESP(part, color)
    if espChests[part] then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Size = part.Size + Vector3.new(0.5, 0.5, 0.5)
    box.Adornee = part
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.4
    box.Color3 = color
    box.Parent = gui
    espChests[part] = box
end
local function clearESP()
    for _, box in pairs(espChests) do
        if box then box:Destroy() end
    end
    espChests = {}
end

makeToggle(pageRyzen, "📦 ESP сундуков", false, function(state)
    if state then
        for _, chest in ipairs(getAllChests()) do
            local part = chest:IsA("BasePart") and chest or chest:FindFirstChildWhichIsA("BasePart")
            if part then createESP(part, Color3.fromRGB(255, 200, 50)) end
        end
    else
        clearESP()
    end
end)

local espPlayers = {}
local function createPlayerESP(plr)
    if plr == lp or espPlayers[plr] then return end
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Size = hrp.Size + Vector3.new(1, 1, 1)
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.5
    box.Color3 = Color3.fromRGB(255, 80, 80)
    box.Parent = gui
    local tag = Instance.new("BillboardGui")
    tag.Size = UDim2.new(0, 100, 0, 20)
    tag.StudsOffset = Vector3.new(0, 3, 0)
    tag.AlwaysOnTop = true
    tag.Adornee = hrp
    tag.Parent = gui
    local t = Instance.new("TextLabel", tag)
    t.Size = UDim2.new(1, 0, 1, 0)
    t.BackgroundTransparency = 1
    t.Text = plr.Name
    t.TextColor3 = Color3.fromRGB(255, 120, 120)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 12
    t.TextStrokeTransparency = 0
    espPlayers[plr] = {box = box, tag = tag}
end
local function clearPlayerESP()
    for _, d in pairs(espPlayers) do
        if d.box then d.box:Destroy() end
        if d.tag then d.tag:Destroy() end
    end
    espPlayers = {}
end

makeToggle(pageRyzen, "👤 ESP игроков", false, function(state)
    if state then
        for _, plr in ipairs(Players:GetPlayers()) do
            createPlayerESP(plr)
        end
    else
        clearPlayerESP()
    end
end)

makeLabel(pageRyzen, "── Освещение ──")

local originalLighting = {}
makeToggle(pageRyzen, "💡 Fullbright", false, function(state)
    if state then
        originalLighting = {
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd
        }
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
    else
        for k, v in pairs(originalLighting) do
            Lighting[k] = v
        end
    end
end)

makeLabel(pageRyzen, "── Смена неба ──")

local function setSky(mode)
    if mode == "day" then
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
        Lighting.FogColor = Color3.fromRGB(200, 220, 240)
        Lighting.FogEnd = 5000
    elseif mode == "night" then
        Lighting.ClockTime = 0
        Lighting.Brightness = 0.5
        Lighting.Ambient = Color3.fromRGB(30, 30, 50)
        Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 50)
        Lighting.FogColor = Color3.fromRGB(10, 10, 25)
        Lighting.FogEnd = 3000
    elseif mode == "sunset" then
        Lighting.ClockTime = 18
        Lighting.Brightness = 1.5
        Lighting.Ambient = Color3.fromRGB(255, 150, 100)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 150, 100)
        Lighting.FogColor = Color3.fromRGB(255, 150, 100)
        Lighting.FogEnd = 4000
    end
end

makeButton(pageRyzen, "☀ День", function() setSky("day") end)
makeButton(pageRyzen, "🌙 Ночь", function() setSky("night") end)
makeButton(pageRyzen, "🌅 Закат", function() setSky("sunset") end)

makeLabel(pageRyzen, "── Настройки окна ──")
makeSlider(pageRyzen, "📐 Ширина", 320, 900, 470, function(v)
    main.Size = UDim2.new(0, v, 0, main.Size.Y.Offset)
end)
makeSlider(pageRyzen, "📐 Высота", 220, 700, 300, function(v)
    main.Size = UDim2.new(0, main.Size.X.Offset, 0, v)
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        if next(espPlayers) then createPlayerESP(plr) end
    end)
end)

-- ═══════════════════════════════════════════
-- PAGE 2: MELTAKIK (AutoFarm через loadstring)
-- ═══════════════════════════════════════════
makeLabel(pageMelta, "── Auto Farm ──")

local farmLoaded = false

makeButton(pageMelta, "▶ AutoFarm ВКЛ", function()
    if farmLoaded then return end
    farmLoaded = true
    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/scarabhub/buildaboatAutoFarm/refs/heads/main/main.lua"))()
    end)
    if not ok then
        warn("[Ryzen] Ошибка загрузки AutoFarm: " .. tostring(err))
        farmLoaded = false
    end
end)

makeButton(pageMelta, "🏁 Телепорт к финишу", function()
    tpToFinish()
end)

makeButton(pageMelta, "🏠 Телепорт на старт", function()
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
    end
end)

makeLabel(pageMelta, "── Fly ──")

local flying = false
local flySpeed = 50
local bv, bg

local function startFly()
    local char = lp.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    flying = true
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1, 1, 1) * 100000
    bv.Velocity = Vector3.new()
    bv.Parent = root
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1, 1, 1) * 100000
    bg.P = 9e4
    bg.CFrame = root.CFrame
    bg.Parent = root
end

local function stopFly()
    flying = false
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
end

RS.RenderStepped:Connect(function()
    if not flying then return end
    local cam = workspace.CurrentCamera
    local dir = Vector3.new()
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
    if bv then bv.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.new() end
    if bg then bg.CFrame = cam.CFrame end
end)

local flyBtn = makeButton(pageMelta, "✈ Fly: OFF", function() end)
flyBtn.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
        flyBtn.Text = "✈ Fly: OFF"
        flyBtn.BackgroundColor3 = Color3.fromRGB(32, 30, 42)
    else
        startFly()
        flyBtn.Text = "✈ Fly: ON"
        flyBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 120)
    end
end)

makeSlider(pageMelta, "⚡ Fly Speed", 10, 500, 50, function(v) flySpeed = v end)

makeLabel(pageMelta, "── Утилиты ──")

local antiAfkEnabled = true
lp.Idled:Connect(function()
    if antiAfkEnabled then
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0))
        task.wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0))
    end
end)

makeToggle(pageMelta, "🛡 Anti-AFK", true, function(state) antiAfkEnabled = state end)
makeButton(pageMelta, "💀 Респавн", function()
    if lp.Character then lp.Character:BreakJoints() end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        if flying then
            stopFly()
            flyBtn.Text = "✈ Fly: OFF"
            flyBtn.BackgroundColor3 = Color3.fromRGB(32, 30, 42)
        else
            startFly()
            flyBtn.Text = "✈ Fly: ON"
            flyBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 120)
        end
    end
end)

print("⚡ Ryzen Hub × MeltaKIK загружен ✓")