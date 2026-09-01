-- ============================================
-- GUEST V2 - MURDERER 2 ESP + AIMBOT HUB
-- Версия: 10.0 FINAL
-- С разделами Combat, Visuals, World & Beauty, Misc & Farm
-- ============================================

-- Проверка игры
if game.PlaceId ~= 142823291 then
    warn("ЭТОТ СКРИПТ ПРЕДНАЗНАЧЕН ДЛЯ MURDERER 2!")
    return
end

-- ============================================
-- СЕРВИСЫ
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ============================================
-- УДАЛЕНИЕ СТАРОГО GUI
-- ============================================
if CoreGui:FindFirstChild("GuestV2GUI") then
    CoreGui.GuestV2GUI:Destroy()
end

-- ============================================
-- НАСТРОЙКИ
-- ============================================
local Settings = {
    ESPEnabled = true,
    ScanEnabled = true,
    MurdererColor = Color3.fromRGB(255, 0, 0),
    SheriffColor = Color3.fromRGB(0, 150, 255),
    InnocentColor = Color3.fromRGB(0, 255, 100),
    ShowMurderer = true,
    ShowSheriff = true,
    ShowInnocent = true,
    ShowNames = true,
    PulseEffect = true,
    
    AimBotEnabled = true,
    AimKey = Enum.KeyCode.E,
    AimFOV = 150,
    AimSmoothness = 0.3,
    KillAll = false,
    KillMurderer = false,
    AutoFarm = false,
    
    SpeedHack = false,
    SpeedValue = 35,
    NoClip = false,
    WalkToMurderer = false,
    SafeDistance = 100,
    
    FullBright = false,
    FOV = 70,
    Skybox = false,
    ColorCorrection = false,
    MotionBlur = false,
}

-- ============================================
-- ДАННЫЕ ОБ ИГРОКАХ
-- ============================================
local PlayerData = {
    Murderer = nil,
    Sheriff = nil,
    Innocents = {},
}

-- ============================================
-- VISUALS ЭФФЕКТЫ
-- ============================================
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient
local originalSkybox = nil

local function toggleFullBright(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
    else
        Lighting.Brightness = originalBrightness or 0.5
        Lighting.Ambient = originalAmbient or Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = originalOutdoorAmbient or Color3.fromRGB(127, 127, 127)
        Lighting.GlobalShadows = true
        Lighting.ShadowSoftness = 0.5
    end
end

local skyboxAssets = {
    "rbxassetid://159367689",
    "rbxassetid://159367690", 
    "rbxassetid://159367691",
    "rbxassetid://159367692",
    "rbxassetid://159367693",
    "rbxassetid://159367694",
}

local function toggleSkybox(enabled)
    if enabled then
        if not originalSkybox then
            originalSkybox = {
                Up = Lighting.SkyboxUp,
                Down = Lighting.SkyboxDown,
                Left = Lighting.SkyboxLeft,
                Right = Lighting.SkyboxRight,
                Front = Lighting.SkyboxFront,
                Back = Lighting.SkyboxBack,
            }
        end
        Lighting.SkyboxUp = skyboxAssets[1]
        Lighting.SkyboxDown = skyboxAssets[2]
        Lighting.SkyboxLeft = skyboxAssets[3]
        Lighting.SkyboxRight = skyboxAssets[4]
        Lighting.SkyboxFront = skyboxAssets[5]
        Lighting.SkyboxBack = skyboxAssets[6]
        Lighting.Ambient = Color3.fromRGB(150, 100, 200)
        Lighting.Brightness = 0.8
    else
        if originalSkybox then
            Lighting.SkyboxUp = originalSkybox.Up
            Lighting.SkyboxDown = originalSkybox.Down
            Lighting.SkyboxLeft = originalSkybox.Left
            Lighting.SkyboxRight = originalSkybox.Right
            Lighting.SkyboxFront = originalSkybox.Front
            Lighting.SkyboxBack = originalSkybox.Back
            Lighting.Ambient = originalAmbient or Color3.fromRGB(127, 127, 127)
            Lighting.Brightness = originalBrightness or 0.5
        end
    end
end

local colorCorr = nil
local function toggleColorCorrection(enabled)
    if enabled then
        if not colorCorr then
            colorCorr = Instance.new("ColorCorrectionEffect")
            colorCorr.Name = "GuestColorCorr"
            colorCorr.Saturation = 0.4
            colorCorr.Contrast = 0.3
            colorCorr.Brightness = 0.1
            colorCorr.Parent = Lighting
        end
    else
        if colorCorr then
            colorCorr:Destroy()
            colorCorr = nil
        end
    end
end

local blurEffect = nil
local blurDepth = nil

local function toggleMotionBlur(enabled)
    if enabled then
        if not blurEffect then
            blurEffect = Instance.new("BlurEffect")
            blurEffect.Name = "GuestBlur"
            blurEffect.Size = 8
            blurEffect.Parent = Lighting
        end
        if not blurDepth then
            blurDepth = Instance.new("DepthOfFieldEffect")
            blurDepth.Name = "GuestDepth"
            blurDepth.FarIntensity = 0.5
            blurDepth.NearIntensity = 0
            blurDepth.FocusDistance = 10
            blurDepth.InFocusRadius = 5
            blurDepth.Parent = Lighting
        end
    else
        if blurEffect then
            blurEffect:Destroy()
            blurEffect = nil
        end
        if blurDepth then
            blurDepth:Destroy()
            blurDepth = nil
        end
    end
end

local function applyVisuals()
    toggleFullBright(Settings.FullBright)
    toggleSkybox(Settings.Skybox)
    toggleColorCorrection(Settings.ColorCorrection)
    toggleMotionBlur(Settings.MotionBlur)
end

-- ============================================
-- MOVEMENT FUNCTIONS
-- ============================================
local function speedHack()
    if not Settings.SpeedHack then return end
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = Settings.SpeedValue
        humanoid.JumpPower = 50
    end
end

local function noClip()
    if not Settings.NoClip then return end
    local character = LocalPlayer.Character
    if not character then return end
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function walkToMurderer()
    if not Settings.WalkToMurderer then return end
    local murderer = PlayerData.Murderer
    if not murderer or not murderer.Character then return end
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local murdererRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart or not murdererRoot then return end
    local distance = (rootPart.Position - murdererRoot.Position).Magnitude
    if distance < Settings.SafeDistance then
        local direction = (rootPart.Position - murdererRoot.Position).Unit
        local targetPos = rootPart.Position + direction * Settings.SafeDistance
        rootPart.CFrame = CFrame.new(targetPos)
    end
end

-- ============================================
-- KILL ALL
-- ============================================
local function killAll()
    if not Settings.KillAll then return end
    local murderer = PlayerData.Murderer
    if not murderer or not murderer.Character then return end
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= murderer and player ~= LocalPlayer then
            local targetChar = player.Character
            if targetChar and targetChar:FindFirstChild("Humanoid") then
                local humanoid = targetChar.Humanoid
                if humanoid.Health > 0 then
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        rootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 2, 0))
                        task.wait(0.05)
                        humanoid.Health = 0
                        task.wait(0.1)
                    end
                end
            end
        end
    end
end

-- ============================================
-- KILL MURDERER
-- ============================================
local function killMurderer()
    if not Settings.KillMurderer then return end
    local murderer = PlayerData.Murderer
    if not murderer or not murderer.Character then return end
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot then
        rootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 2, 0))
        task.wait(0.05)
        local humanoid = murderer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            humanoid.Health = 0
        end
    end
end

-- ============================================
-- AUTO FARM
-- ============================================
local collectedCoins = {}

local function autoFarm()
    if not Settings.AutoFarm then return end
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    local coins = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("coin") then
            table.insert(coins, obj)
        end
    end
    
    table.sort(coins, function(a, b)
        local distA = (a.Position - rootPart.Position).Magnitude
        local distB = (b.Position - rootPart.Position).Magnitude
        return distA < distB
    end)
    
    for _, coin in ipairs(coins) do
        if not collectedCoins[coin] then
            rootPart.CFrame = CFrame.new(coin.Position + Vector3.new(0, 2, 0))
            collectedCoins[coin] = true
            task.wait(0.1)
            break
        end
    end
end

-- ============================================
-- СОЗДАНИЕ GUI - GUEST V2
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GuestV2GUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- ============================================
-- ГЛАВНОЕ ОКНО (БОЛЬШОЕ)
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 560)
MainFrame.Position = UDim2.new(0.5, -260, 0.4, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 20)
MainFrame.BackgroundTransparency = 0.02
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(80, 50, 150)
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Selectable = true
MainFrame.Draggable = false
MainFrame.Visible = true

-- ГЛАВНЫЙ КОРНЕР
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 16)
Corner.Parent = MainFrame

-- ГРАДИЕНТ
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 50, 200)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 20, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 50, 200))
})
Gradient.Rotation = 45
Gradient.Parent = MainFrame

-- ============================================
-- ЗАГОЛОВОК GUEST V2
-- ============================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 40)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 16)
TitleBarCorner.Parent = TitleBar

-- ЗАГОЛОВОК
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GUEST V2"
Title.TextColor3 = Color3.fromRGB(180, 130, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextStrokeTransparency = 0.2
Title.TextStrokeColor3 = Color3.fromRGB(100, 50, 200)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- ЛИНИЯ
local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.5, 0, 0, 2)
Line.Position = UDim2.new(0.25, 0, 1, -2)
Line.BackgroundColor3 = Color3.fromRGB(180, 130, 255)
Line.BackgroundTransparency = 0.4
Line.BorderSizePixel = 0
Line.Parent = TitleBar

-- КНОПКА ЗАКРЫТИЯ
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -42, 0.5, -17.5)
CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
CloseButton.BackgroundTransparency = 0.3
CloseButton.BorderSizePixel = 1
CloseButton.BorderColor3 = Color3.fromRGB(100, 50, 100)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(200, 40, 40),
        BackgroundTransparency = 0.2,
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(40, 40, 80),
        BackgroundTransparency = 0.3,
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- ============================================
-- ПЕРЕТАСКИВАНИЕ
-- ============================================
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        TitleBar.BackgroundTransparency = 0.1
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        TitleBar.BackgroundTransparency = 0.2
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================
-- БОКОВАЯ ПАНЕЛЬ РАЗДЕЛОВ (СЛЕВА)
-- ============================================
local SidePanel = Instance.new("Frame")
SidePanel.Size = UDim2.new(0, 130, 0, 470)
SidePanel.Position = UDim2.new(0, 10, 0, 60)
SidePanel.BackgroundColor3 = Color3.fromRGB(15, 15, 35)
SidePanel.BackgroundTransparency = 0.3
SidePanel.BorderSizePixel = 1
SidePanel.BorderColor3 = Color3.fromRGB(60, 40, 100)
SidePanel.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = SidePanel

-- КНОПКИ РАЗДЕЛОВ (ВЕРТИКАЛЬНЫЕ)
local function createSideButton(parent, yPos, text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 42)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(60, 40, 100)
    btn.Text = text
    btn.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1,
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.3,
        }):Play()
    end)
    
    return btn
end

local CombatBtn = createSideButton(SidePanel, 10, "Combat", Color3.fromRGB(255, 130, 130))
local VisualsBtn = createSideButton(SidePanel, 62, "Visuals", Color3.fromRGB(130, 200, 255))
local WorldBtn = createSideButton(SidePanel, 114, "World", Color3.fromRGB(130, 255, 130))
local MiscBtn = createSideButton(SidePanel, 166, "Misc", Color3.fromRGB(255, 200, 130))

-- ============================================
-- ОСНОВНАЯ ОБЛАСТЬ КОНТЕНТА (СПРАВА)
-- ============================================
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(0.72, 0, 0.88, 0)
ContentArea.Position = UDim2.new(0.26, 0, 0.11, 0)
ContentArea.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
ContentArea.BackgroundTransparency = 0.1
ContentArea.BorderSizePixel = 1
ContentArea.BorderColor3 = Color3.fromRGB(40, 30, 80)
ContentArea.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 12)
ContentCorner.Parent = ContentArea

-- ============================================
-- РАЗДЕЛЫ КОНТЕНТА
-- ============================================
local CombatSection = Instance.new("Frame")
CombatSection.Size = UDim2.new(0.94, 0, 0.94, 0)
CombatSection.Position = UDim2.new(0.03, 0, 0.03, 0)
CombatSection.BackgroundTransparency = 1
CombatSection.Parent = ContentArea
CombatSection.Visible = true

local VisualSection = Instance.new("Frame")
VisualSection.Size = UDim2.new(0.94, 0, 0.94, 0)
VisualSection.Position = UDim2.new(0.03, 0, 0.03, 0)
VisualSection.BackgroundTransparency = 1
VisualSection.Parent = ContentArea
VisualSection.Visible = false

local WorldSection = Instance.new("Frame")
WorldSection.Size = UDim2.new(0.94, 0, 0.94, 0)
WorldSection.Position = UDim2.new(0.03, 0, 0.03, 0)
WorldSection.BackgroundTransparency = 1
WorldSection.Parent = ContentArea
WorldSection.Visible = false

local MiscSection = Instance.new("Frame")
MiscSection.Size = UDim2.new(0.94, 0, 0.94, 0)
MiscSection.Position = UDim2.new(0.03, 0, 0.03, 0)
MiscSection.BackgroundTransparency = 1
MiscSection.Parent = ContentArea
MiscSection.Visible = false

-- ============================================
-- ПЕРЕКЛЮЧЕНИЕ РАЗДЕЛОВ
-- ============================================
CombatBtn.MouseButton1Click:Connect(function()
    CombatSection.Visible = true
    VisualSection.Visible = false
    WorldSection.Visible = false
    MiscSection.Visible = false
    CombatBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    CombatBtn.BackgroundTransparency = 0.1
    VisualsBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
    VisualsBtn.BackgroundTransparency = 0.3
    WorldBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
    WorldBtn.BackgroundTransparency = 0.3
    MiscBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
    MiscBtn.BackgroundTransparency = 0.3
end)

VisualsBtn.MouseButton1Click:Connect(function()
    CombatSection.Visible = false
    VisualSection.Visible = true
    WorldSection.Visible = false
    MiscSection.Visible = false
    VisualsBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 180)
    VisualsBtn.BackgroundTransparency = 0.1
    CombatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
    CombatBtn.BackgroundTransparency = 0.3
    WorldBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
    WorldBtn.BackgroundTransparency = 0.3
    MiscBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
    MiscBtn.BackgroundTransparency = 0.3
end)

WorldBtn.MouseButton1Click:Connect(function()
    CombatSection.Visible = false
    VisualSection.Visible = false
    WorldSection.Visible = true
    MiscSection.Visible = false
    WorldBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    WorldBtn.BackgroundTransparency = 0.1
    CombatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
    CombatBtn.BackgroundTransparency = 0.3
    VisualsBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
    VisualsBtn.BackgroundTransparency = 0.3
    MiscBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
    MiscBtn.BackgroundTransparency = 0.3
end)

MiscBtn.MouseButton1Click:Connect(function()
    CombatSection.Visible = false
    VisualSection.Visible = false
    WorldSection.Visible = false
    MiscSection.Visible = true
    MiscBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
    MiscBtn.BackgroundTransparency = 0.1
    CombatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
    CombatBtn.BackgroundTransparency = 0.3
    VisualsBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
    VisualsBtn.BackgroundTransparency = 0.3
    WorldBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
    WorldBtn.BackgroundTransparency = 0.3
end)

-- ============================================
-- ФУНКЦИЯ СОЗДАНИЯ ТОГГЛА
-- ============================================
local function createToggle(parent, yPos, text, settingName, defaultColor)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 42, 0, 22)
    toggle.Position = UDim2.new(0.83, 0, 0.5, -11)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 1, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(150, 150, 200)
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local isOn = true
    
    toggle.MouseButton1Click:Connect(function()
        isOn = not isOn
        Settings[settingName] = isOn
        
        if isOn then
            toggle.BackgroundColor3 = defaultColor or Color3.fromRGB(0, 200, 100)
            knob.Position = UDim2.new(0, 21, 0.5, -9)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
            knob.Position = UDim2.new(0, 1, 0.5, -9)
            knob.BackgroundColor3 = Color3.fromRGB(150, 150, 200)
        end
        
        applyVisuals()
    end)
    
    toggle.BackgroundColor3 = defaultColor or Color3.fromRGB(0, 200, 100)
    knob.Position = UDim2.new(0, 21, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
end

-- ============================================
-- ФУНКЦИЯ СОЗДАНИЯ СЛАЙДЕРА
-- ============================================
local function createSlider(parent, yPos, label, settingName, minVal, maxVal, defaultVal, formatFn)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.Position = UDim2.new(0, 0, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.6, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label .. " " .. (formatFn and formatFn(defaultVal) or tostring(defaultVal))
    labelText.TextColor3 = Color3.fromRGB(220, 220, 255)
    labelText.TextScaled = true
    labelText.Font = Enum.Font.GothamMedium
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 1, 0)
    valueLabel.Position = UDim2.new(0.85, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = formatFn and formatFn(defaultVal) or tostring(defaultVal)
    valueLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
    valueLabel.TextScaled = true
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = frame
    
    local slider = Instance.new("TextButton")
    slider.Size = UDim2.new(0.22, 0, 0, 6)
    slider.Position = UDim2.new(0.62, 0, 0.5, -3)
    slider.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    slider.BorderSizePixel = 0
    slider.Text = ""
    slider.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local function updateValue(value)
        value = math.clamp(value, minVal, maxVal)
        Settings[settingName] = value
        valueLabel.Text = formatFn and formatFn(value) or tostring(math.floor(value))
        labelText.Text = label .. " " .. (formatFn and formatFn(value) or tostring(math.floor(value)))
        fill.Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0)
    end
    
    slider.MouseButton1Click:Connect(function()
        local choices = {}
        local step = (maxVal - minVal) / 6
        for i = 0, 6 do
            table.insert(choices, minVal + i * step)
        end
        local current = Settings[settingName]
        local nextIndex = 1
        for i, v in ipairs(choices) do
            if math.abs(v - current) < step / 2 then
                nextIndex = i % #choices + 1
                break
            end
        end
        updateValue(choices[nextIndex])
        
        if settingName == "FOV" then
            Workspace.CurrentCamera.FieldOfView = Settings.FOV
        end
    end)
    
    slider.MouseButton2Click:Connect(function()
        updateValue(defaultVal)
        if settingName == "FOV" then
            Workspace.CurrentCamera.FieldOfView = Settings.FOV
        end
    end)
    
    return updateValue
end

-- ============================================
-- РАЗДЕЛ COMBAT
-- ============================================
local CombatTitle = Instance.new("TextLabel")
CombatTitle.Size = UDim2.new(1, 0, 0, 30)
CombatTitle.Position = UDim2.new(0, 0, 0, 5)
CombatTitle.BackgroundTransparency = 1
CombatTitle.Text = "⚔️ COMBAT"
CombatTitle.TextColor3 = Color3.fromRGB(255, 130, 130)
CombatTitle.TextScaled = true
CombatTitle.Font = Enum.Font.GothamBold
CombatTitle.Parent = CombatSection

createToggle(CombatSection, 42, "AimBot:", "AimBotEnabled", Color3.fromRGB(255, 80, 80))

-- Выбор клавиши
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(1, 0, 0, 32)
KeyFrame.Position = UDim2.new(0, 0, 0, 78)
KeyFrame.BackgroundTransparency = 1
KeyFrame.Parent = CombatSection

local KeyLabel = Instance.new("TextLabel")
KeyLabel.Size = UDim2.new(0.5, 0, 1, 0)
KeyLabel.Position = UDim2.new(0, 0, 0, 0)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "Aim Key:"
KeyLabel.TextColor3 = Color3.fromRGB(200, 200, 230)
KeyLabel.TextScaled = true
KeyLabel.Font = Enum.Font.GothamMedium
KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
KeyLabel.Parent = KeyFrame

local KeyButton = Instance.new("TextButton")
KeyButton.Size = UDim2.new(0, 55, 0, 26)
KeyButton.Position = UDim2.new(0.7, 0, 0.5, -13)
KeyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
KeyButton.BorderSizePixel = 1
KeyButton.BorderColor3 = Color3.fromRGB(60, 60, 100)
KeyButton.Text = "E"
KeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyButton.TextScaled = true
KeyButton.Font = Enum.Font.GothamBold
KeyButton.Parent = KeyFrame

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 6)
KeyCorner.Parent = KeyButton

KeyButton.MouseButton1Click:Connect(function()
    KeyButton.Text = "..."
    local input = UserInputService.InputBegan:Wait()
    if input.UserInputType == Enum.UserInputType.Keyboard then
        Settings.AimKey = input.KeyCode
        KeyButton.Text = input.KeyCode.Name
    end
end)

createToggle(CombatSection, 118, "Kill All (летает и убивает):", "KillAll", Color3.fromRGB(255, 80, 80))
createToggle(CombatSection, 154, "Kill Murderer:", "KillMurderer", Color3.fromRGB(255, 200, 80))

local TargetInfo = Instance.new("TextLabel")
TargetInfo.Size = UDim2.new(1, 0, 0, 25)
TargetInfo.Position = UDim2.new(0, 0, 0, 195)
TargetInfo.BackgroundTransparency = 1
TargetInfo.Text = "🎯 Target: None"
TargetInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
TargetInfo.TextScaled = true
TargetInfo.Font = Enum.Font.GothamMedium
TargetInfo.Parent = CombatSection

-- ============================================
-- РАЗДЕЛ VISUALS (ФИОЛЕТОВЫЙ)
-- ============================================
local VisualTitle = Instance.new("TextLabel")
VisualTitle.Size = UDim2.new(1, 0, 0, 30)
VisualTitle.Position = UDim2.new(0, 0, 0, 5)
VisualTitle.BackgroundTransparency = 1
VisualTitle.Text = "🎨 VISUALS"
VisualTitle.TextColor3 = Color3.fromRGB(180, 130, 255)
VisualTitle.TextScaled = true
VisualTitle.Font = Enum.Font.GothamBold
VisualTitle.Parent = VisualSection

createToggle(VisualSection, 42, "Fullbright (Beta Team / 8 Photos):", "FullBright", Color3.fromRGB(200, 150, 255))

createSlider(VisualSection, 80, "Field of View (FOV Kameram):", "FOV", 50, 120, 70, function(v)
    return tostring(math.floor(v))
end)

createToggle(VisualSection, 125, "Custom Purple Galaxy Skybox:", "Skybox", Color3.fromRGB(200, 150, 255))
createToggle(VisualSection, 160, "Color Correction (Combine uBeta):", "ColorCorrection", Color3.fromRGB(200, 150, 255))
createToggle(VisualSection, 195, "Motion Blur Effect:", "MotionBlur", Color3.fromRGB(200, 150, 255))

-- ============================================
-- РАЗДЕЛ WORLD & BEAUTY
-- ============================================
local WorldTitle = Instance.new("TextLabel")
WorldTitle.Size = UDim2.new(1, 0, 0, 30)
WorldTitle.Position = UDim2.new(0, 0, 0, 5)
WorldTitle.BackgroundTransparency = 1
WorldTitle.Text = "🌍 WORLD & BEAUTY"
WorldTitle.TextColor3 = Color3.fromRGB(130, 255, 130)
WorldTitle.TextScaled = true
WorldTitle.Font = Enum.Font.GothamBold
WorldTitle.Parent = WorldSection

createToggle(WorldSection, 42, "Speed Hack:", "SpeedHack", Color3.fromRGB(130, 255, 130))

createSlider(WorldSection, 78, "Speed Value:", "SpeedValue", 16, 50, 35, function(v)
    return tostring(math.floor(v))
end)

createToggle(WorldSection, 120, "No Clip (проход через стены):", "NoClip", Color3.fromRGB(130, 255, 130))

-- ============================================
-- РАЗДЕЛ MISC & FARM
-- ============================================
local MiscTitle = Instance.new("TextLabel")
MiscTitle.Size = UDim2.new(1, 0, 0, 30)
MiscTitle.Position = UDim2.new(0, 0, 0, 5)
MiscTitle.BackgroundTransparency = 1
MiscTitle.Text = "🛠️ MISC & FARM"
MiscTitle.TextColor3 = Color3.fromRGB(255, 200, 130)
MiscTitle.TextScaled = true
MiscTitle.Font = Enum.Font.GothamBold
MiscTitle.Parent = MiscSection

createToggle(MiscSection, 42, "Auto Farm Coins:", "AutoFarm", Color3.fromRGB(255, 200, 130))
createToggle(MiscSection, 78, "Walk To Murderer (безопасно):", "WalkToMurderer", Color3.fromRGB(255, 200, 130))

createSlider(MiscSection, 115, "Safe Distance:", "SafeDistance", 50, 200, 100, function(v)
    return tostring(math.floor(v))
end)

-- ============================================
-- AIMBOT СИСТЕМА
-- ============================================
local aimCircle = nil

local function createAimCircle()
    if aimCircle then aimCircle:Destroy() end
    aimCircle = Instance.new("Frame")
    aimCircle.Size = UDim2.new(0, Settings.AimFOV, 0, Settings.AimFOV)
    aimCircle.Position = UDim2.new(0.5, -Settings.AimFOV/2, 0.5, -Settings.AimFOV/2)
    aimCircle.BackgroundTransparency = 1
    aimCircle.BorderSizePixel = 2
    aimCircle.BorderColor3 = Color3.fromRGB(255, 0, 0)
    aimCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    aimCircle.BackgroundTransparency = 0.8
    aimCircle.Parent = LocalPlayer.PlayerGui
    aimCircle.ZIndex = 999
    aimCircle.Visible = false
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = aimCircle
end

createAimCircle()

local function aimBot()
    if not Settings.AimBotEnabled then 
        if aimCircle then aimCircle.Visible = false end
        return 
    end
    
    local target = PlayerData.Murderer
    if not target or not target.Character then 
        if aimCircle then aimCircle.Visible = false end
        TargetInfo.Text = "🎯 Target: None"
        return 
    end
    
    local targetHead = target.Character:FindFirstChild("Head")
    if not targetHead then 
        if aimCircle then aimCircle.Visible = false end
        return 
    end
    
    if aimCircle then 
        aimCircle.Visible = true
        aimCircle.Size = UDim2.new(0, Settings.AimFOV, 0, Settings.AimFOV)
        aimCircle.Position = UDim2.new(0.5, -Settings.AimFOV/2, 0.5, -Settings.AimFOV/2)
    end
    
    TargetInfo.Text = "🎯 Target: " .. target.Name
    TargetInfo.TextColor3 = Settings.MurdererColor
    
    if UserInputService:IsKeyDown(Settings.AimKey) then
        local camera = Workspace.CurrentCamera
        local targetPos = targetHead.Position
        local cameraPos = camera.CFrame.Position
        
        local targetCFrame = CFrame.lookAt(cameraPos, targetPos)
        local currentCFrame = camera.CFrame
        local newCFrame = currentCFrame:Lerp(targetCFrame, Settings.AimSmoothness)
        camera.CFrame = newCFrame
        
        if aimCircle then
            aimCircle.BorderColor3 = Color3.fromRGB(0, 255, 0)
        end
    else
        if aimCircle then
            aimCircle.BorderColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
end

-- ============================================
-- ЗАПУСК ФУНКЦИЙ
-- ============================================
task.spawn(function()
    while task.wait(0.3) do
        if Settings.KillAll then pcall(killAll) end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if Settings.KillMurderer then pcall(killMurderer) end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if Settings.AutoFarm then pcall(autoFarm) end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if Settings.SpeedHack then pcall(speedHack) end
        if Settings.NoClip then pcall(noClip) end
        if Settings.WalkToMurderer then pcall(walkToMurderer) end
    end
end)

-- ============================================
-- ESP СИСТЕМА
-- ============================================
local activeHighlights = {}
local nameTags = {}

local function clearHighlights()
    for _, h in ipairs(activeHighlights) do
        pcall(function() h:Destroy() end)
    end
    activeHighlights = {}
    for _, tag in ipairs(nameTags) do
        pcall(function() tag:Destroy() end)
    end
    nameTags = {}
end

local function createHighlight(character, color, showName, playerName)
    if not character or not character:IsA("Model") then return end
    if not Settings.ESPEnabled then return end
    
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Highlight") then
            child:Destroy()
        end
        if child:IsA("BillboardGui") and child.Name == "GuestNameTag" then
            child:Destroy()
        end
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = character
    highlight.FillColor = color
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    table.insert(activeHighlights, highlight)
    
    if Settings.ShowNames and showName and playerName then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "GuestNameTag"
        billboard.Size = UDim2.new(0, 100, 0, 30)
        billboard.Adornee = character:FindFirstChild("Head") or character
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = character
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = playerName
        nameLabel.TextColor3 = color
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Parent = billboard
        table.insert(nameTags, billboard)
    end
    
    if Settings.PulseEffect then
        spawn(function()
            local t = 0
            while highlight and highlight.Parent do
                t = t + 0.02
                local pulse = 0.2 + math.sin(t * 4) * 0.15
                highlight.FillTransparency = pulse
                highlight.OutlineTransparency = pulse - 0.05
                task.wait(0.02)
            end
        end)
    end
    return highlight
end

-- ============================================
-- SCAN PLAYERS
-- ============================================
local function scanPlayers()
    if not Settings.ScanEnabled then return end
    
    clearHighlights()
    PlayerData.Murderer = nil
    PlayerData.Sheriff = nil
    PlayerData.Innocents = {}
    
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= LocalPlayer then
            local character = otherPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                if humanoid.Health > 0 then
                    local roleFound = false
                    
                    local hasKnife = false
                    for _, child in ipairs(character:GetChildren()) do
                        if child:IsA("Tool") then
                            local name = child.Name:lower()
                            if name:find("knife") or name:find("dagger") or name:find("blade") or name:find("нож") then
                                hasKnife = true
                                break
                            end
                        end
                    end
                    
                    if not hasKnife then
                        local backpack = otherPlayer:FindFirstChild("Backpack")
                        if backpack then
                            for _, child in ipairs(backpack:GetChildren()) do
                                if child:IsA("Tool") then
                                    local name = child.Name:lower()
                                    if name:find("knife") or name:find("dagger") or name:find("blade") or name:find("нож") then
                                        hasKnife = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                    
                    if hasKnife then
                        PlayerData.Murderer = otherPlayer
                        if Settings.ShowMurderer then
                            createHighlight(character, Settings.MurdererColor, true, "MURDERER: " .. otherPlayer.Name)
                        end
                        roleFound = true
                    end
                    
                    if not roleFound then
                        local hasGun = false
                        for _, child in ipairs(character:GetChildren()) do
                            if child:IsA("Tool") then
                                local name = child.Name:lower()
                                if name:find("gun") or name:find("pistol") or name:find("revolver") or name:find("пистолет") then
                                    hasGun = true
                                    break
                                end
                            end
                        end
                        
                        if not hasGun then
                            local backpack = otherPlayer:FindFirstChild("Backpack")
                            if backpack then
                                for _, child in ipairs(backpack:GetChildren()) do
                                    if child:IsA("Tool") then
                                        local name = child.Name:lower()
                                        if name:find("gun") or name:find("pistol") or name:find("revolver") or name:find("пистолет") then
                                            hasGun = true
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        
                        if hasGun then
                            PlayerData.Sheriff = otherPlayer
                            if Settings.ShowSheriff then
                                createHighlight(character, Settings.SheriffColor, true, "SHERIFF: " .. otherPlayer.Name)
                            end
                            roleFound = true
                        end
                    end
                    
                    if not roleFound then
                        table.insert(PlayerData.Innocents, otherPlayer)
                        if Settings.ShowInnocent then
                            createHighlight(character, Settings.InnocentColor, true, "INNOCENT: " .. otherPlayer.Name)
                        end
                    end
                end
            end
        end
    end
end

-- ============================================
-- ЗАПУСК
-- ============================================
task.spawn(function()
    while task.wait(1.5) do
        pcall(scanPlayers)
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        pcall(aimBot)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    pcall(scanPlayers)
end)

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    pcall(scanPlayers)
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    pcall(scanPlayers)
end)

applyVisuals()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        pcall(scanPlayers)
    end
    if input.KeyCode == Enum.KeyCode.H and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("========================================")
print("  GUEST V2 LOADED SUCCESSFULLY!")
print("  Version: 10.0 FINAL")
print("  Game: Murderer 2")
print("========================================")
print("  Разделы: Combat | Visuals | World | Misc")
print("========================================")