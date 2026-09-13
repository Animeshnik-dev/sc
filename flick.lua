-- Ryzen Hub v3 | [FPS] Flick
-- Aimbot (E) + Skeleton ESP + God Mode + Aim FOV
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= GUI =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RyzenHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 240, 0, 340)
Main.Position = UDim2.new(0, 15, 0, 15)
Main.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.Text = "Ryzen Hub | [FPS] Flick"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Main

-- ================= Кнопки =================
local function makeButton(text, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = Main
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn
    return btn
end

local ESPBtn    = makeButton("ESP Skeleton: OFF", 45)
local AimbotBtn = makeButton("Aimbot (E): OFF", 90)
local GodBtn    = makeButton("God Mode: OFF", 135)
local AimFOVBtn = makeButton("Aim FOV: 100", 180)
local FOVBtn    = makeButton("Camera FOV: 70", 225)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 60)
Status.Position = UDim2.new(0, 10, 0, 265)
Status.BackgroundTransparency = 1
Status.Text = "Ryzen Hub v3 загружен"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.TextWrapped = true
Status.Parent = Main

-- ================= SKELETON ESP =================
-- Скелет: соединяем ключевые точки персонажа линиями
local espEnabled = false
local espDrawings = {} -- [player] = {lines}
local espLastUpdate = 0

-- Кости скелета (пары частей для соединения)
local skeletonPairs = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
    {"Left Arm", "Left Leg"},
    {"Right Arm", "Right Leg"},
}

local function getPart(char, name)
    -- Совместимость R6 / R15
    local map = {
        ["Torso"] = {"Torso", "UpperTorso", "LowerTorso"},
        ["Left Arm"] = {"Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand"},
        ["Right Arm"] = {"Right Arm", "RightUpperArm", "RightLowerArm", "RightHand"},
        ["Left Leg"] = {"Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
        ["Right Leg"] = {"Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"},
        ["Head"] = {"Head"},
    }
    for _, n in ipairs(map[name] or {name}) do
        local p = char:FindFirstChild(n)
        if p then return p end
    end
    return nil
end

local function createSkeleton(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    -- Удалить старый
    if espDrawings[player] then
        for _, line in ipairs(espDrawings[player]) do
            if line then line:Remove() end
        end
    end

    local lines = {}
    for _, pair in ipairs(skeletonPairs) do
        local p1 = getPart(char, pair[1])
        local p2 = getPart(char, pair[2])
        if p1 and p2 then
            local line = Drawing.new("Line")
            line.Color = Color3.fromRGB(0, 255, 100)
            line.Thickness = 1.5
            line.Transparency = 1
            line.Visible = false
            table.insert(lines, line)
        else
            table.insert(lines, nil)
        end
    end
    espDrawings[player] = lines
end

local function updateSkeleton()
    for player, lines in pairs(espDrawings) do
        local char = player.Character
        if not char or not char:FindFirstChildOfClass("Humanoid") or char.Humanoid.Health <= 0 then
            for _, line in ipairs(lines) do
                if line then line.Visible = false end
            end
        else
            local idx = 1
            for _, pair in ipairs(skeletonPairs) do
                local line = lines[idx]
                if line then
                    local p1 = getPart(char, pair[1])
                    local p2 = getPart(char, pair[2])
                    if p1 and p2 then
                        local v1, on1 = Camera:WorldToViewportPoint(p1.Position)
                        local v2, on2 = Camera:WorldToViewportPoint(p2.Position)
                        if on1 and on2 then
                            line.From = Vector2.new(v1.X, v1.Y)
                            line.To = Vector2.new(v2.X, v2.Y)
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                end
                idx = idx + 1
            end
        end
    end
end

local function clearSkeleton()
    for _, lines in pairs(espDrawings) do
        for _, line in ipairs(lines) do
            if line then line:Remove() end
        end
    end
    espDrawings = {}
end

local function toggleESP()
    espEnabled = not espEnabled
    ESPBtn.Text = "ESP Skeleton: " .. (espEnabled and "ON" or "OFF")
    if espEnabled then
        Status.Text = "Skeleton ESP включён"
        -- Создать скелеты для всех
        for _, p in ipairs(Players:GetPlayers()) do createSkeleton(p) end
        Players.PlayerAdded:Connect(createSkeleton)
        Players.PlayerRemoving:Connect(function(p)
            if espDrawings[p] then
                for _, line in ipairs(espDrawings[p]) do
                    if line then line:Remove() end
                end
                espDrawings[p] = nil
            end
        end)
    else
        clearSkeleton()
        Status.Text = "Skeleton ESP выключен"
    end
end

ESPBtn.MouseButton1Click:Connect(toggleESP)

-- ================= AIMBOT (клавиша E) =================
local aimbotEnabled = false
local aimbotFOV = 100 -- пикселей (радиус)
local aimbotConn

local function getClosestTarget()
    local closest = nil
    local shortest = aimbotFOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local head = player.Character:FindFirstChild("Head")
            if hum and head and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = head
                    end
                end
            end
        end
    end
    return closest
end

local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    AimbotBtn.Text = "Aimbot (E): " .. (aimbotEnabled and "ON" or "OFF")
    if aimbotEnabled then
        Status.Text = "Aimbot включён (зажми E)"
        aimbotConn = RunService.RenderStepped:Connect(function()
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                local target = getClosestTarget()
                if target then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                end
            end
        end)
    else
        if aimbotConn then aimbotConn:Disconnect() aimbotConn = nil end
        Status.Text = "Aimbot выключен"
    end
end

AimbotBtn.MouseButton1Click:Connect(toggleAimbot)

-- ================= AIM FOV (настройка радиуса аимбота) =================
local aimFovValues = {50, 100, 150, 200, 300}
local aimFovIndex = 2
AimFOVBtn.Text = "Aim FOV: " .. aimFovValues[aimFovIndex]
aimbotFOV = aimFovValues[aimFovIndex]

AimFOVBtn.MouseButton1Click:Connect(function()
    aimFovIndex = aimFovIndex + 1
    if aimFovIndex > #aimFovValues then aimFovIndex = 1 end
    aimbotFOV = aimFovValues[aimFovIndex]
    AimFOVBtn.Text = "Aim FOV: " .. aimbotFOV
    Status.Text = "Aim FOV: " .. aimbotFOV
end)

-- ================= GOD MODE (изменённый) =================
local godEnabled = false
local godLoop

local function applyGod()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.MaxHealth = math.huge
    hum.Health = math.huge
    -- Отключаем урон через ForceField
    if not char:FindFirstChildOfClass("ForceField") then
        local ff = Instance.new("ForceField")
        ff.Visible = false
        ff.Parent = char
    end
end

local function toggleGod()
    godEnabled = not godEnabled
    GodBtn.Text = "God Mode: " .. (godEnabled and "ON" or "OFF")
    if godEnabled then
        Status.Text = "God Mode включён"
        applyGod()
        -- Респавн
        LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.2)
            if godEnabled then applyGod() end
        end)
        -- Постоянная поддержка
        godLoop = task.spawn(function()
            while godEnabled do
                task.wait(0.5)
                if godEnabled then applyGod() end
            end
        end)
    else
        if godLoop then task.cancel(godLoop) godLoop = nil end
        -- Убираем ForceField
        local char = LocalPlayer.Character
        if char then
            for _, obj in ipairs(char:GetChildren()) do
                if obj:IsA("ForceField") then obj:Destroy() end
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = 100
                hum.Health = 100
            end
        end
        Status.Text = "God Mode выключен"
    end
end

GodBtn.MouseButton1Click:Connect(toggleGod)

-- ================= CAMERA FOV =================
local camFovValues = {70, 90, 110, 120}
local camFovIndex = 1
Camera.FieldOfView = camFovValues[camFovIndex]
FOVBtn.Text = "Camera FOV: " .. camFovValues[camFovIndex]

FOVBtn.MouseButton1Click:Connect(function()
    camFovIndex = camFovIndex + 1
    if camFovIndex > #camFovValues then camFovIndex = 1 end
    Camera.FieldOfView = camFovValues[camFovIndex]
    FOVBtn.Text = "Camera FOV: " .. camFovValues[camFovIndex]
end)

-- ================= ГЛАВНЫЙ ЦИКЛ (ESP 1 раз в секунду) =================
RunService.Heartbeat:Connect(function()
    if not espEnabled then return end
    if tick() - espLastUpdate >= 1 then
        espLastUpdate = tick()
        updateSkeleton()
        -- Создать для новых
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and not espDrawings[p] then
                createSkeleton(p)
            end
        end
    end
    -- Отрисовка скелета каждый кадр (для плавности)
    updateSkeleton()
end)

Status.Text = "Ryzen Hub v3 загружен | E — аимбот"