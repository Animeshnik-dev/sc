-- Ryzen Hub v3 | [FPS] Flick (Skeleton Fix + Box ESP)
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

local ESPBtn    = makeButton("ESP: OFF", 45)
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

-- ================= ESP (Highlight + BillboardGui) =================
local espEnabled = false
local espObjects = {} -- [player] = {highlight, billboard, box}

local function removeESP(player)
    if espObjects[player] then
        for _, obj in ipairs(espObjects[player]) do
            if obj and obj.Parent then obj:Destroy() end
        end
        espObjects[player] = nil
    end
end

local function createESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    removeESP(player)

    local objects = {}

    -- Highlight (подсветка)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.FillColor = Color3.fromRGB(0, 255, 100)
    highlight.OutlineColor = Color3.fromRGB(0, 255, 100)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char
    table.insert(objects, highlight)

    -- BillboardGui (имя + дистанция)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = char:FindFirstChild("Head") or char

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Parent = billboard
    table.insert(objects, billboard)

    espObjects[player] = objects
end

local function clearAllESP()
    for player, _ in pairs(espObjects) do
        removeESP(player)
    end
    espObjects = {}
end

local function toggleESP()
    espEnabled = not espEnabled
    ESPBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    if espEnabled then
        Status.Text = "ESP включён"
        for _, p in ipairs(Players:GetPlayers()) do createESP(p) end

        -- Обновление при добавлении игроков
        Players.PlayerAdded:Connect(function(p)
            task.wait(1)
            if espEnabled then createESP(p) end
        end)

        -- Обновление при респавне
        Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function()
                task.wait(1)
                if espEnabled then createESP(p) end
            end)
        end)

        Players.PlayerRemoving:Connect(removeESP)

        -- Цикл проверки живых игроков
        RunService.Heartbeat:Connect(function()
            if not espEnabled then return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local char = p.Character
                    if char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.Health > 0 then
                        if not espObjects[p] then createESP(p) end
                    else
                        removeESP(p)
                    end
                end
            end
        end)
    else
        clearAllESP()
        Status.Text = "ESP выключен"
    end
end

ESPBtn.MouseButton1Click:Connect(toggleESP)

-- ================= AIMBOT (клавиша E) =================
local aimbotEnabled = false
local aimbotFOV = 100
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
        if aimbotConn then
            aimbotConn:Disconnect()
            aimbotConn = nil
        end
        Status.Text = "Aimbot выключен"
    end
end

AimbotBtn.MouseButton1Click:Connect(toggleAimbot)

-- ================= AIM FOV =================
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

-- ================= GOD MODE =================
local godEnabled = false
local godLoop

local function applyGod()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.MaxHealth = math.huge
    hum.Health = math.huge
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
        LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.2)
            if godEnabled then applyGod() end
        end)
        godLoop = task.spawn(function()
            while godEnabled do
                task.wait(0.5)
                if godEnabled then applyGod() end
            end
        end)
    else
        if godLoop then
            task.cancel(godLoop)
            godLoop = nil
        end
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

Status.Text = "Ryzen Hub v3 загружен | E — аимбот"
