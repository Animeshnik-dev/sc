-- Ryzen Hub | MM2 Edition v3.1
-- ESP + Aimbot + Fly Kill + Auto Farm + Noclip + Private + Admin Panel

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============ НАСТРОЙКА ADMIN / PREMIUM ============
local ADMIN_ID = 5699480575

local PremiumUsers = {
    [5699480575] = true,
}

local isAdmin = LocalPlayer.UserId == ADMIN_ID

local function isPremium()
    return PremiumUsers[LocalPlayer.UserId] == true
end

-- ============ КОНФИГ ============
local Config = {
    ESP = {
        Enabled = true,
        MurdererColor = Color3.fromRGB(255, 40, 40),
        SheriffColor = Color3.fromRGB(40, 120, 255),
        InnocentColor = Color3.fromRGB(40, 255, 80),
        FillTransparency = 0.5,
        OutlineTransparency = 0
    },
    Aimbot = {
        Enabled = false,
        Smoothness = 0.15,
        FOV = 300,
        ShowFOV = true,
        AimPart = "Head",
        Bind = Enum.KeyCode.E,
        BindMode = "Hold"
    },
    Kill = {
        KillMurderer = false,
        KillSheriff = false,
        FlySpeed = 67,
        SafeHeight = 100,
        Delay = 0.15,
        HeightOffset = 1
    },
    CoinFarm = {
        Enabled = false,
        FlySpeed = 80,
        Delay = 0.05,
        MaxDistance = 5000,
        IgnoreCollected = true,
        HeightOffset = 2.5
    },
    Noclip = {
        Enabled = false
    },
    Private = {
        AutoKillMurder = false,
        AutoWin = false,
        AntiRagdoll = false,
        SpeedHack = false,
        SpeedValue = 50,
        InfiniteJump = false
    },
    Visuals = {
        Fullbright = false
    }
}

local aimbotActive = false
local isBinding = false
local bindButtonRef = nil
local killLoopActive = false

-- ============ РОЛИ ============
local function getPlayerRole(player)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        if backpack:FindFirstChild("Knife") or backpack:FindFirstChild("Christmas Knife") or backpack:FindFirstChild("Bat") or backpack:FindFirstChild("Lantern") then
            return "Murderer"
        elseif backpack:FindFirstChild("Gun") or backpack:FindFirstChild("Revolver") then
            return "Sheriff"
        end
    end
    local char = player.Character
    if char then
        if char:FindFirstChild("Knife") or char:FindFirstChild("Christmas Knife") or char:FindFirstChild("Bat") or char:FindFirstChild("Lantern") then
            return "Murderer"
        elseif char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") then
            return "Sheriff"
        end
    end
    return "Innocent"
end

local function getMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if getPlayerRole(player) == "Murderer" then return player end
        end
    end
    return nil
end

local function getSheriff()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if getPlayerRole(player) == "Sheriff" then return player end
        end
    end
    return nil
end

-- ============ ESP ============
local ESPObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local role = getPlayerRole(player)
    local espColor = role == "Murderer" and Config.ESP.MurdererColor or (role == "Sheriff" and Config.ESP.SheriffColor or Config.ESP.InnocentColor)
    
    if char:FindFirstChild("RyzenESP") then
        local h = char.RyzenESP
        h.FillColor = espColor
        h.OutlineColor = Color3.new(1, 1, 1)
        h.FillTransparency = Config.ESP.FillTransparency
        h.OutlineTransparency = Config.ESP.OutlineTransparency
        ESPObjects[player] = h
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "RyzenESP"
    highlight.Parent = char
    highlight.Adornee = char
    highlight.FillColor = espColor
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = Config.ESP.FillTransparency
    highlight.OutlineTransparency = Config.ESP.OutlineTransparency
    ESPObjects[player] = highlight
end

local function removeESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].Parent then ESPObjects[player]:Destroy() end
        ESPObjects[player] = nil
    end
    local char = player.Character
    if char and char:FindFirstChild("RyzenESP") then char.RyzenESP:Destroy() end
end

local function updateAllESP()
    if not Config.ESP.Enabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then createESP(player) end
    end
end

-- ============ AIMBOT ============
local function getClosestMurderer()
    local murderer = getMurderer()
    if not murderer or not murderer.Character then return nil end
    local char = murderer.Character
    local part = char:FindFirstChild(Config.Aimbot.AimPart)
    if not part then return nil end
    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return nil end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
    if dist <= Config.Aimbot.FOV then return murderer, part end
    return nil
end

local fovCircle = nil
local function updateFOVCircle()
    if not Drawing then return end
    if Config.Aimbot.ShowFOV and Config.Aimbot.Enabled then
        if not fovCircle then
            fovCircle = Drawing.new("Circle")
            fovCircle.Thickness = 1.5
            fovCircle.NumSides = 80
            fovCircle.Filled = false
            fovCircle.Transparency = 0.8
            fovCircle.Color = Color3.fromRGB(180, 180, 180)
        end
        fovCircle.Visible = true
        fovCircle.Radius = Config.Aimbot.FOV
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        if fovCircle then fovCircle.Visible = false end
    end
end

-- ============ FLY ============
local function setCollisions(char, state)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = state
        end
    end
end

local function flyToPosition(targetPos, speed, timeout)
    local char = LocalPlayer.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return false end
    
    setCollisions(char, false)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
    
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Parent = root
    
    local startTime = tick()
    local timeout = timeout or 5
    
    while true do
        if not root.Parent or not char.Parent then
            bv:Destroy()
            return false
        end
        local delta = targetPos - root.Position
        local dist = delta.Magnitude
        if dist < 3 then break end
        if (tick() - startTime) > timeout then break end
        bv.Velocity = delta.Unit * speed
        task.wait(0.03)
    end
    
    bv:Destroy()
    setCollisions(char, true)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
    return true
end

local function flyKill(targetPlayer)
    local targetChar = targetPlayer and targetPlayer.Character
    local myChar = LocalPlayer.Character
    if not targetChar or not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return end
    
    local originalPos = myRoot.Position
    local upPos = Vector3.new(originalPos.X, Config.Kill.SafeHeight, originalPos.Z)
    flyToPosition(upPos, Config.Kill.FlySpeed, 3)
    task.wait(0.05)
    
    local targetPos = Vector3.new(targetRoot.Position.X, targetRoot.Position.Y + Config.Kill.HeightOffset, targetRoot.Position.Z)
    flyToPosition(targetPos, Config.Kill.FlySpeed, 5)
    task.wait(0.05)
    
    local tools = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, t in pairs(backpack:GetChildren()) do
            if t:IsA("Tool") then table.insert(tools, t) end
        end
    end
    for _, t in pairs(myChar:GetChildren()) do
        if t:IsA("Tool") then table.insert(tools, t) end
    end
    for _, tool in pairs(tools) do
        pcall(function() tool:Activate() end)
        task.wait(0.02)
    end
    
    task.wait(0.1)
    flyToPosition(upPos, Config.Kill.FlySpeed, 3)
    flyToPosition(originalPos, Config.Kill.FlySpeed, 5)
end

local function startKillLoop()
    task.spawn(function()
        while killLoopActive do
            if Config.Kill.KillMurderer then
                local murderer = getMurderer()
                if murderer then flyKill(murderer) end
            end
            if Config.Kill.KillSheriff then
                local sheriff = getSheriff()
                if sheriff then flyKill(sheriff) end
            end
            task.wait(Config.Kill.Delay)
        end
    end)
end

-- ============ АВТОФАРМ ============
local coinFarmActive = false

local function isCoinTarget(obj)
    if not obj or not obj:IsA("BasePart") then return false end
    local n = obj.Name:lower()
    if n == "coin" or n == "coinvisual" then
        if Config.CoinFarm.IgnoreCollected and obj.Transparency >= 1 then return false end
        return true
    end
    if n:find("coin") and not n:find("container") and not n:find("server") then
        return true
    end
    return false
end

local function findClosestCoin(root)
    local closest, closestDist = nil, math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if not coinFarmActive then break end
        if isCoinTarget(obj) then
            local dist = (obj.Position - root.Position).Magnitude
            if dist < closestDist and dist <= Config.CoinFarm.MaxDistance then
                closest = obj
                closestDist = dist
            end
        end
    end
    return closest
end

local function startCoinFarm()
    task.spawn(function()
        while coinFarmActive and Config.CoinFarm.Enabled do
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health > 0 then
                    local coin = findClosestCoin(root)
                    if coin then
                        local targetPos = coin.Position + Vector3.new(0, Config.CoinFarm.HeightOffset, 0)
                        flyToPosition(targetPos, Config.CoinFarm.FlySpeed, 5)
                    end
                end
            end
            task.wait(Config.CoinFarm.Delay)
        end
    end)
end

-- ============ NOCLIP ============
local noclipConnection = nil

local function enableNoclip()
    if noclipConnection then return end
    noclipConnection = RunService.Stepped:Connect(function()
        if not Config.Noclip.Enabled then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and not part.CanCollide then
                if part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- ============ ПРИВАТНЫЕ ФУНКЦИИ ============
local privateLoops = {
    autoKill = false,
    autoWin = false,
    antiRagdoll = false,
    speedHack = false,
    infiniteJump = false
}

local function startAutoKill()
    task.spawn(function()
        while privateLoops.autoKill and isPremium() do
            local murderer = getMurderer()
            if murderer and murderer.Character then
                flyKill(murderer)
            end
            task.wait(0.3)
        end
    end)
end

local function startAutoWin()
    task.spawn(function()
        while privateLoops.autoWin and isPremium() do
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    task.wait(0.5)
                    pcall(function() LocalPlayer:LoadCharacter() end)
                end
            end
            task.wait(0.2)
        end
    end)
end

local function startAntiRagdoll()
    task.spawn(function()
        while privateLoops.antiRagdoll and isPremium() do
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local state = hum:GetState()
                    if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

local speedConnection = nil
local function enableSpeedHack()
    if speedConnection then return end
    speedConnection = RunService.Heartbeat:Connect(function()
        if not privateLoops.speedHack then return end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = Config.Private.SpeedValue
            end
        end
    end)
end

local function disableSpeedHack()
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end

local infJumpConnection = nil
local function enableInfiniteJump()
    if infJumpConnection then return end
    infJumpConnection = UserInputService.JumpRequest:Connect(function()
        if not privateLoops.infiniteJump or not isPremium() then return end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function disableInfiniteJump()
    if infJumpConnection then
        infJumpConnection:Disconnect()
        infJumpConnection = nil
    end
end

-- ============ ВИЗУАЛЫ ============
local function applyVisuals()
    local lighting = game:GetService("Lighting")
    if Config.Visuals.Fullbright then
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
        lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        lighting.Brightness = 3
        lighting.FogEnd = 100000
        lighting.ClockTime = 14
    else
        lighting.Ambient = Color3.fromRGB(128, 128, 128)
        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        lighting.FogEnd = 100000
    end
end

-- ============ БИНД ============
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if isBinding or gameProcessed then return end
    if input.KeyCode == Config.Aimbot.Bind then
        if Config.Aimbot.BindMode == "Toggle" then
            aimbotActive = not aimbotActive
        else
            aimbotActive = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if isBinding then return end
    if input.KeyCode == Config.Aimbot.Bind then
        if Config.Aimbot.BindMode == "Hold" then aimbotActive = false end
    end
end)

RunService.RenderStepped:Connect(function()
    if not Config.Aimbot.Enabled or not aimbotActive then
        updateFOVCircle()
        return
    end
    local murderer, part = getClosestMurderer()
    if murderer and part then
        local targetPos = part.Position
        local currentCFrame = Camera.CFrame
        local newCFrame = CFrame.new(currentCFrame.Position, targetPos)
        Camera.CFrame = currentCFrame:Lerp(newCFrame, Config.Aimbot.Smoothness)
    end
    updateFOVCircle()
end)

-- ============ GUI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RyzenHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 620, 0, 420)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(70, 70, 80)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(0, 250, 1, 0)
LogoLabel.Position = UDim2.new(0, 15, 0, 0)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "⚡ RYZEN HUB"
LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoLabel.TextSize = 16
LogoLabel.Font = Enum.Font.GothamBlack
LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
LogoLabel.Parent = TitleBar

local VerLabel = Instance.new("TextLabel")
VerLabel.Size = UDim2.new(0, 150, 1, 0)
VerLabel.Position = UDim2.new(1, -230, 0, 0)
VerLabel.BackgroundTransparency = 1
VerLabel.Text = "v3.1 | " .. (isPremium() and "PREMIUM" or "FREE")
VerLabel.TextColor3 = isPremium() and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(150, 150, 160)
VerLabel.TextSize = 12
VerLabel.Font = Enum.Font.GothamBold
VerLabel.TextXAlignment = Enum.TextXAlignment.Right
VerLabel.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -95, 0, 6)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.TextSize = 16
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -60, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(230, 60, 60)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -50)
Sidebar.Position = UDim2.new(0, 10, 0, 45)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 8)
SidebarCorner.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 8)
SidebarPadding.PaddingLeft = UDim.new(0, 6)
SidebarPadding.PaddingRight = UDim.new(0, 6)
SidebarPadding.Parent = Sidebar

local ContentPanel = Instance.new("Frame")
ContentPanel.Size = UDim2.new(1, -180, 1, -55)
ContentPanel.Position = UDim2.new(0, 170, 0, 45)
ContentPanel.BackgroundTransparency = 1
ContentPanel.Parent = MainFrame

local tabs = {}
local activeTab = nil

local function createTab(name, icon, visible)
    if visible == false then return nil end
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 36)
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = "  " .. icon .. "  " .. name
    tabBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    tabBtn.TextSize = 13
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = Sidebar
    
    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 6)
    tCorner.Parent = tabBtn
    
    local tStroke = Instance.new("UIStroke")
    tStroke.Color = Color3.fromRGB(60, 60, 70)
    tStroke.Thickness = 1
    tStroke.Transparency = 1
    tStroke.Parent = tabBtn
    
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.Visible = false
    tabContent.Parent = ContentPanel
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = tabContent
    
    tabs[name] = { button = tabBtn, content = tabContent, stroke = tStroke }
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, tData in pairs(tabs) do
            tData.content.Visible = false
            tData.button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            tData.button.TextColor3 = Color3.fromRGB(180, 180, 190)
            tData.stroke.Transparency = 1
        end
        tabContent.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tStroke.Transparency = 0
        activeTab = name
    end)
    
    return tabContent
end

local function createToggle(parent, name, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = parent
    
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn
    
    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(60, 60, 70)
    bStroke.Thickness = 1
    bStroke.Parent = btn
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 36, 0, 18)
    indicator.Position = UDim2.new(1, -46, 0.5, -9)
    indicator.BackgroundColor3 = default and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 70)
    indicator.BorderSizePixel = 0
    indicator.Parent = btn
    
    local iCorner = Instance.new("UICorner")
    iCorner.CornerRadius = UDim.new(1, 0)
    iCorner.Parent = indicator
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = indicator
    
    local kCorner = Instance.new("UICorner")
    kCorner.CornerRadius = UDim.new(1, 0)
    kCorner.Parent = knob
    
    local state = default
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(indicator, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(60, 60, 70)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        callback(state)
    end)
end

local function createButton(parent, name, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(220, 220, 230)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = parent
    
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn
    
    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(60, 60, 70)
    bStroke.Thickness = 1
    bStroke.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createSlider(parent, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 6)
    fCorner.Parent = frame
    
    local fStroke = Instance.new("UIStroke")
    fStroke.Color = Color3.fromRGB(60, 60, 70)
    fStroke.Thickness = 1
    fStroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 18)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(220, 220, 230)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 0, 32)
    sliderBg.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(90, 130, 220)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = sliderBg    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local dragging = false
    local function update(input)
        local relX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * relX
        val = math.floor(val * 100) / 100
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -7, 0.5, -7)
        label.Text = name .. ": " .. tostring(val)
        callback(val)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end
    end)
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

local function createSection(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = "▸ " .. text
    label.TextColor3 = Color3.fromRGB(140, 140, 160)
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
end

local function createTextBox(parent, placeholder, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 36)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    box.BorderSizePixel = 0
    box.Text = ""
    box.PlaceholderText = placeholder
    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    box.TextColor3 = Color3.fromRGB(220, 220, 230)
    box.TextSize = 13
    box.Font = Enum.Font.GothamMedium
    box.ClearTextOnFocus = false
    box.Parent = parent
    
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = box
    
    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(60, 60, 70)
    bStroke.Thickness = 1
    bStroke.Parent = box
    
    box.FocusLost:Connect(function()
        callback(box.Text)
    end)
    
    return box
end

-- ============ ТАБЫ ============
local combatTab = createTab("Combat", "⚔", true)
local farmTab = createTab("Farm", "💰", true)
local noclipTab = createTab("Noclip", "🚪", true)
local visualTab = createTab("Visuals", "👁", true)
local miscTab = createTab("Misc", "⚙", true)
local privateTab = createTab("PRIVATE", "★", isPremium())
local adminTab = createTab("ADMIN", "🛡", isAdmin)
local settingsTab = createTab("Settings", "🔧", true)

-- COMBAT
createSection(combatTab, "AIMBOT")
createToggle(combatTab, "Aimbot Enabled", Config.Aimbot.Enabled, function(v)
    Config.Aimbot.Enabled = v
    aimbotActive = false
end)
createToggle(combatTab, "Show FOV", Config.Aimbot.ShowFOV, function(v) Config.Aimbot.ShowFOV = v end)
createSlider(combatTab, "FOV", 50, 800, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v end)
createSlider(combatTab, "Smoothness", 0.05, 1, Config.Aimbot.Smoothness, function(v) Config.Aimbot.Smoothness = v end)

local aimPartState = true
local aimPartBtn = createButton(combatTab, "Aim Part: Head", function() end)
if aimPartBtn then
    aimPartBtn.MouseButton1Click:Connect(function()
        aimPartState = not aimPartState
        Config.Aimbot.AimPart = aimPartState and "Head" or "HumanoidRootPart"
        aimPartBtn.Text = "Aim Part: " .. (aimPartState and "Head" or "Body")
    end)
end

bindButtonRef = createButton(combatTab, "Bind: " .. Config.Aimbot.Bind.Name, function()
    isBinding = true
    bindButtonRef.Text = "Press key..."
    bindButtonRef.TextColor3 = Color3.fromRGB(255, 200, 50)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.Aimbot.Bind = input.KeyCode
        isBinding = false
        if bindButtonRef then
            bindButtonRef.Text = "Bind: " .. input.KeyCode.Name
            bindButtonRef.TextColor3 = Color3.fromRGB(220, 220, 230)
        end
    end
end)

local bindModeState = true
local bindModeBtn = createButton(combatTab, "Bind Mode: Hold", function() end)
if bindModeBtn then
    bindModeBtn.MouseButton1Click:Connect(function()
        bindModeState = not bindModeState
        Config.Aimbot.BindMode = bindModeState and "Hold" or "Toggle"
        bindModeBtn.Text = "Bind Mode: " .. Config.Aimbot.BindMode
        aimbotActive = false
    end)
end

createSection(combatTab, "KILL FUNCTIONS (FLY)")
createToggle(combatTab, "Kill Murderer", false, function(v)
    Config.Kill.KillMurderer = v
    if v and not killLoopActive then
        killLoopActive = true
        startKillLoop()
    elseif not v and not Config.Kill.KillSheriff then
        killLoopActive = false
    end
end)
createToggle(combatTab, "Kill Sheriff", false, function(v)
    Config.Kill.KillSheriff = v
    if v and not killLoopActive then
        killLoopActive = true
        startKillLoop()
    elseif not v and not Config.Kill.KillMurderer then
        killLoopActive = false
    end
end)
createSlider(combatTab, "Kill Fly Speed", 10, 200, Config.Kill.FlySpeed, function(v) Config.Kill.FlySpeed = v end)
createSlider(combatTab, "Kill Delay", 0.05, 1, Config.Kill.Delay, function(v) Config.Kill.Delay = v end)

-- FARM
createSection(farmTab, "COIN FARM (FLY)")
createToggle(farmTab, "Автофарм монет", Config.CoinFarm.Enabled, function(v)
    Config.CoinFarm.Enabled = v
    coinFarmActive = v
    if v then startCoinFarm() end
end)
createSlider(farmTab, "Farm Fly Speed", 10, 200, Config.CoinFarm.FlySpeed, function(v) Config.CoinFarm.FlySpeed = v end)
createSlider(farmTab, "Farm Delay", 0.02, 0.5, Config.CoinFarm.Delay, function(v) Config.CoinFarm.Delay = v end)

-- NOCLIP
createSection(noclipTab, "NOCLIP")
createToggle(noclipTab, "Noclip (через стены)", Config.Noclip.Enabled, function(v)
    Config.Noclip.Enabled = v
    if v then enableNoclip() else disableNoclip() end
end)
local noclipInfo = Instance.new("TextLabel")
noclipInfo.Size = UDim2.new(1, 0, 0, 60)
noclipInfo.BackgroundTransparency = 1
noclipInfo.Text = "Noclip отключает коллизии у всех частей\nперсонажа. Работает постоянно, пока включён."
noclipInfo.TextColor3 = Color3.fromRGB(150, 150, 160)
noclipInfo.TextSize = 11
noclipInfo.Font = Enum.Font.Gotham
noclipInfo.TextWrapped = true
noclipInfo.TextYAlignment = Enum.TextYAlignment.Top
noclipInfo.Parent = noclipTab

-- VISUALS
createSection(visualTab, "ESP")
createToggle(visualTab, "ESP Enabled", Config.ESP.Enabled, function(v)
    Config.ESP.Enabled = v
    if not v then
        for player, _ in pairs(ESPObjects) do removeESP(player) end
        ESPObjects = {}
    else
        updateAllESP()
    end
end)
createSlider(visualTab, "ESP Fill Transparency", 0, 1, Config.ESP.FillTransparency, function(v)
    Config.ESP.FillTransparency = v
    for _, h in pairs(ESPObjects) do h.FillTransparency = v end
end)

createSection(visualTab, "LIGHTING")
createToggle(visualTab, "Fullbright", false, function(v)
    Config.Visuals.Fullbright = v
    applyVisuals()
end)

-- MISC
createSection(miscTab, "PLAYER")
createButton(miscTab, "Reset Character", function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end)
createButton(miscTab, "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

-- PRIVATE TAB
if privateTab and isPremium() then
    createSection(privateTab, "★ PRIVATE FEATURES (PREMIUM ONLY)")
    
    createToggle(privateTab, "Auto Kill Murderer", false, function(v)
        privateLoops.autoKill = v
        if v then startAutoKill() end
    end)
    
    createToggle(privateTab, "Auto Win (Auto Respawn)", false, function(v)
        privateLoops.autoWin = v
        if v then startAutoWin() end
    end)
    
    createToggle(privateTab, "Anti-Ragdoll", false, function(v)
        privateLoops.antiRagdoll = v
        if v then startAntiRagdoll() end
    end)
    
    createToggle(privateTab, "Infinite Jump", false, function(v)
        privateLoops.infiniteJump = v
        if v then enableInfiniteJump() else disableInfiniteJump() end
    end)
    
    createToggle(privateTab, "Speed Hack", false, function(v)
        privateLoops.speedHack = v
        if v then enableSpeedHack() else disableSpeedHack() end
    end)
    createSlider(privateTab, "Speed Value", 16, 200, Config.Private.SpeedValue, function(v)
        Config.Private.SpeedValue = v
    end)
end

-- ADMIN TAB
if adminTab and isAdmin then
    createSection(adminTab, "🛡 ADMIN PANEL")
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Premium users: " .. tostring(#PremiumUsers)
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    statusLabel.TextSize = 13
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = adminTab
    
    createSection(adminTab, "GRANT PREMIUM")
    
    local idBox = createTextBox(adminTab, "Введите UserID игрока...", function(text)
    end)
    
    createButton(adminTab, "✔ Выдать Premium", function()
        local idStr = idBox.Text
        local idNum = tonumber(idStr)
        if not idNum then
            statusLabel.Text = "❌ Неверный ID"
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            return
        end
        PremiumUsers[idNum] = true
        statusLabel.Text = "✔ Premium выдан: " .. tostring(idNum)
        statusLabel.TextColor3 = Color3.fromRGB(80, 220, 120)
    end)
    
    createButton(adminTab, "✖ Забрать Premium", function()
        local idStr = idBox.Text
        local idNum = tonumber(idStr)
        if not idNum then
            statusLabel.Text = "❌ Неверный ID"
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            return
        end
        if idNum == ADMIN_ID then
            statusLabel.Text = "❌ Нельзя забрать у админа"
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            return
        end
        PremiumUsers[idNum] = nil
        statusLabel.Text = "✖ Premium забран: " .. tostring(idNum)
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
    end)
    
    createSection(adminTab, "СПИСОК PREMIUM")
    
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, 0, 0, 120)
    listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    listFrame.BorderSizePixel = 0
    listFrame.Parent = adminTab
    
    local lfCorner = Instance.new("UICorner")
    lfCorner.CornerRadius = UDim.new(0, 6)
    lfCorner.Parent = listFrame
    
    local listLabel = Instance.new("TextLabel")
    listLabel.Size = UDim2.new(1, -10, 1, -10)
    listLabel.Position = UDim2.new(0, 5, 0, 5)
    listLabel.BackgroundTransparency = 1
    listLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    listLabel.TextSize = 12
    listLabel.Font = Enum.Font.Code
    listLabel.TextXAlignment = Enum.TextXAlignment.Left
    listLabel.TextYAlignment = Enum.TextYAlignment.Top
    listLabel.TextWrapped = true
    listLabel.Parent = listFrame
    
    local function refreshList()
        local str = ""
        local count = 0
        for id, _ in pairs(PremiumUsers) do
            str = str .. "• " .. tostring(id) .. (id == ADMIN_ID and " (ADMIN)" or "") .. "\n"
            count = count + 1
        end
        listLabel.Text = str
        statusLabel.Text = "Premium users: " .. tostring(count)
    end
    refreshList()
    
    createButton(adminTab, "🔄 Обновить список", refreshList)
end

-- SETTINGS
createSection(settingsTab, "GUI")
createButton(settingsTab, "Reset GUI Position", function()
    MainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
end)
createButton(settingsTab, "Destroy GUI (закрыть)", function()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("RyzenHub")
    if gui then gui:Destroy() end
end)

createSection(settingsTab, "INFO")
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 90)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Ryzen Hub v3.1\nMM2 Edition\n" ..
    "User ID: " .. tostring(LocalPlayer.UserId) .. "\n" ..
    "Status: " .. (isPremium() and "★ PREMIUM" or "FREE") .. "\n" ..
    "Admin: " .. (isAdmin and "YES" or "NO")
infoLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
infoLabel.TextSize = 12
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = settingsTab

-- Активация первого таба
tabs["Combat"].button.MouseButton1Click:Fire()
tabs["Combat"].button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
tabs["Combat"].button.TextColor3 = Color3.fromRGB(255, 255, 255)
tabs["Combat"].stroke.Transparency = 0
tabs["Combat"].content.Visible = true
activeTab = "Combat"

-- Minimize
local minimized = false
local originalSize = MainFrame.Size
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 620, 0, 40)
        Sidebar.Visible = false
        ContentPanel.Visible = false
    else
        MainFrame.Size = originalSize
        Sidebar.Visible = true
        ContentPanel.Visible = true
    end
end)

-- ============ ЗАКРЫТИЕ GUI (ГАРАНТИРОВАННОЕ) ============
CloseBtn.MouseButton1Click:Connect(function()
    -- Останавливаем все циклы
    pcall(function() killLoopActive = false end)
    pcall(function() coinFarmActive = false end)
    pcall(function()
        privateLoops.autoKill = false
        privateLoops.autoWin = false
        privateLoops.antiRagdoll = false
        privateLoops.speedHack = false
        privateLoops.infiniteJump = false
    end)
    
    -- Отключаем хуки
    pcall(function() disableNoclip() end)
    pcall(function() disableSpeedHack() end)
    pcall(function() disableInfiniteJump() end)
    
    -- Убираем FOV-круг
    pcall(function()
        if fovCircle then
            fovCircle:Remove()
            fovCircle = nil
        end
    end)
    
    -- Удаляем GUI (двумя способами для надёжности)
    pcall(function() ScreenGui:Destroy() end)
    pcall(function()
        local gui = LocalPlayer.PlayerGui:FindFirstChild("RyzenHub")
        if gui then gui:Destroy() end
    end)
end)

-- Автообновление ESP
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        if Config.ESP.Enabled then updateAllESP() end
    end
end)

Players.PlayerRemoving:Connect(function(player) removeESP(player) end)
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if Config.ESP.Enabled then createESP(player) end
    end)
end)

print("[Ryzen Hub] v3.1 загружен!")
print("[Ryzen Hub] Admin ID: " .. tostring(ADMIN_ID))
print("[Ryzen Hub] Your status: " .. (isPremium() and "PREMIUM" or "FREE") .. " | Admin: " .. (isAdmin and "YES" or "NO"))