--!strict
-- Ryzen Hub v1.6 — fixed FPS booster + real FPS counter

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LP: Player = Players.LocalPlayer
local Cam: Camera = workspace.CurrentCamera

-- ===== BRANDING =====
local HUB_NAME = "Ryzen Hub"
local HUB_VERSION = "v1.6"
local ACCENT = Color3.fromRGB(120, 200, 80)
local ACCENT_DARK = Color3.fromRGB(70, 140, 50)
local BG = Color3.fromRGB(22, 26, 22)
local PANEL = Color3.fromRGB(32, 38, 32)
local PANEL_LIGHT = Color3.fromRGB(42, 50, 42)
local TEXT = Color3.fromRGB(235, 240, 230)
local TEXT_DIM = Color3.fromRGB(150, 160, 145)
local OFF = Color3.fromRGB(55, 62, 55)
local ENEMY_COLOR = Color3.fromRGB(255, 70, 70)

-- ===== CONFIG =====
local cfg = {
	Speed = false, SpeedValue = 16,
	InfJump = false, InfJumpPower = 50,
	Noclip = false,
	ESP = true, Boxes = true, Names = true, Healthbar = true, Skeleton = true,
	Tracers = false, TeamCheck = true, WallCheck = true,
	Aimbot = false, SilentAim = false,
	AimBind = Enum.UserInputType.MouseButton2,
	FOV = 120, MaxDist = 800,
	FPSBooster = false,
	FPSCounter = true,
	VisualMode = "Default",
}

local function detectGame(): string
	if game.PlaceId == 17625359962 then return "Rivals" end
	if game.PlaceId == 126884695634066 then return "Grow a Garden" end
	return "Universal"
end
local CURRENT_GAME = detectGame()

-- ===== UTILS =====
local function getHRP(plr: Player): BasePart?
	local c = plr.Character
	if not c then return nil end
	local h = c:FindFirstChild("HumanoidRootPart")
	return (h and h:IsA("BasePart")) and h or nil
end

local function getHead(plr: Player): BasePart?
	local c = plr.Character
	if not c then return nil end
	local h = c:FindFirstChild("Head")
	return (h and h:IsA("BasePart")) and h or nil
end

local function isEnemy(plr: Player): boolean
	if plr == LP then return false end
	if not cfg.TeamCheck then return true end
	return plr.Team ~= LP.Team
end

local function isVisible(part: BasePart): boolean
	if not cfg.WallCheck then return true end
	local origin = Cam.CFrame.Position
	local dir = part.Position - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {LP.Character, Cam}
	local hit = workspace:Raycast(origin, dir, params)
	return hit == nil or hit.Instance:IsDescendantOf(part.Parent)
end

-- ===== SPEED =====
local speedPropConn: RBXScriptConnection? = nil

local function applySpeed()
	local c = LP.Character
	if not c then return end
	local hum = c:FindFirstChildOfClass("Humanoid")
	if not hum or not hum:IsA("Humanoid") then return end
	local target = cfg.Speed and cfg.SpeedValue or 16
	if hum.WalkSpeed ~= target then
		hum.WalkSpeed = target
	end
end

local function hookSpeedHum(hum: Humanoid)
	if speedPropConn then speedPropConn:Disconnect() end
	speedPropConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if cfg.Speed and hum.WalkSpeed ~= cfg.SpeedValue then
			hum.WalkSpeed = cfg.SpeedValue
		end
	end)
end

local function bindChar(c: Model)
	task.wait(0.1)
	local hum = c:WaitForChild("Humanoid", 5)
	if hum and hum:IsA("Humanoid") then
		hookSpeedHum(hum)
		applySpeed()
	end
end

if LP.Character then bindChar(LP.Character) end
LP.CharacterAdded:Connect(bindChar)
RunService.Stepped:Connect(applySpeed)

-- ===== ESP =====
local espFolder = Instance.new("Folder")
espFolder.Name = "RyzenESP"
espFolder.Parent = CoreGui

type ESPEntry = {
	box: BoxHandleAdornment,
	bb: BillboardGui,
	nameLabel: TextLabel,
	healthFill: Frame,
	skelLines: {LineHandleAdornment},
	conn: RBXScriptConnection?,
}

local espMap: {[Player]: ESPEntry} = {}

local SKEL_PAIRS = {
	{"Head", "UpperTorso"},
	{"UpperTorso", "LowerTorso"},
	{"UpperTorso", "LeftUpperArm"},
	{"LeftUpperArm", "LeftLowerArm"},
	{"LeftLowerArm", "LeftHand"},
	{"UpperTorso", "RightUpperArm"},
	{"RightUpperArm", "RightLowerArm"},
	{"RightLowerArm", "RightHand"},
	{"LowerTorso", "LeftUpperLeg"},
	{"LeftUpperLeg", "LeftLowerLeg"},
	{"LeftLowerLeg", "LeftFoot"},
	{"LowerTorso", "RightUpperLeg"},
	{"RightUpperLeg", "RightLowerLeg"},
	{"RightLowerLeg", "RightFoot"},
}

local function createESP(plr: Player): ()
	if plr == LP or espMap[plr] then return end
	local box = Instance.new("BoxHandleAdornment")
	box.Size = Vector3.new(2.5, 6, 2.5)
	box.AlwaysOnTop = true; box.ZIndex = 5; box.Transparency = 0.35
	box.Color3 = ENEMY_COLOR; box.Adornee = nil; box.Parent = espFolder

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(120, 40)
	bb.AlwaysOnTop = true
	bb.StudsOffset = Vector3.new(0, 3.5, 0)
	bb.Adornee = nil; bb.Parent = espFolder

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextScaled = true
	nameLabel.Text = plr.Name
	nameLabel.Parent = bb

	local hBg = Instance.new("Frame")
	hBg.Size = UDim2.new(0.8, 0, 0.25, 0)
	hBg.Position = UDim2.new(0.1, 0, 0.55, 0)
	hBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	hBg.BorderSizePixel = 0; hBg.Parent = bb

	local hFill = Instance.new("Frame")
	hFill.Size = UDim2.fromScale(1, 1)
	hFill.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
	hFill.BorderSizePixel = 0; hFill.Parent = hBg

	local skelLines: {LineHandleAdornment} = {}
	for _ = 1, #SKEL_PAIRS do
		local line = Instance.new("LineHandleAdornment")
		line.Thickness = 2
		line.AlwaysOnTop = true
		line.ZIndex = 6
		line.Color3 = Color3.fromRGB(255, 255, 255)
		line.Adornee = nil
		line.Parent = espFolder
		table.insert(skelLines, line)
	end

	local entry: ESPEntry = {box = box, bb = bb, nameLabel = nameLabel, healthFill = hFill, skelLines = skelLines, conn = nil}

	entry.conn = RunService.RenderStepped:Connect(function()
		if not cfg.ESP or not isEnemy(plr) then
			box.Adornee = nil; bb.Adornee = nil
			for _, l in ipairs(skelLines) do l.Adornee = nil end
			return
		end
		local char = plr.Character
		local hrp = getHRP(plr); local head = getHead(plr)
		if not hrp or not char then
			box.Adornee = nil; bb.Adornee = nil
			for _, l in ipairs(skelLines) do l.Adornee = nil end
			return
		end
		local dist = (hrp.Position - Cam.CFrame.Position).Magnitude
		if dist > cfg.MaxDist then
			box.Adornee = nil; bb.Adornee = nil
			for _, l in ipairs(skelLines) do l.Adornee = nil end
			return
		end
		box.Adornee = cfg.Boxes and hrp or nil
		if cfg.Names and head then
			bb.Adornee = head
			nameLabel.Text = string.format("%s [%d]", plr.Name, math.floor(dist))
		else bb.Adornee = nil end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum and cfg.Healthbar then
			local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
			hFill.Size = UDim2.fromScale(pct, 1)
			hFill.BackgroundColor3 = Color3.fromRGB(math.floor(255*(1-pct)), math.floor(255*pct), 60)
		end
		if cfg.Skeleton then
			for i, pair in ipairs(SKEL_PAIRS) do
				local a = char:FindFirstChild(pair[1])
				local b = char:FindFirstChild(pair[2])
				local line = skelLines[i]
				if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
					local mid = (a.Position + b.Position) / 2
					local dir = (b.Position - a.Position)
					local len = dir.Magnitude
					line.Adornee = workspace.Terrain
					line.CFrame = CFrame.lookAt(mid, mid + dir) * CFrame.new(0, 0, -len/2)
					line.Length = len
				else
					line.Adornee = nil
				end
			end
		else
			for _, l in ipairs(skelLines) do l.Adornee = nil end
		end
	end)
	espMap[plr] = entry
end

local function destroyESP(plr: Player): ()
	local e = espMap[plr]
	if not e then return end
	if e.conn then e.conn:Disconnect() end
	e.box:Destroy(); e.bb:Destroy()
	for _, l in ipairs(e.skelLines) do l:Destroy() end
	espMap[plr] = nil
end

for _, p in ipairs(Players:GetPlayers()) do task.spawn(createESP, p) end
Players.PlayerAdded:Connect(function(p) task.spawn(createESP, p) end)
Players.PlayerRemoving:Connect(destroyESP)

-- ===== FOV =====
local fovCircle: any = nil
local hasDrawing = pcall(function() return Drawing ~= nil end)

RunService.RenderStepped:Connect(function()
	if not hasDrawing then return end
	if cfg.Aimbot or cfg.SilentAim then
		if not fovCircle then
			fovCircle = Drawing.new("Circle")
			fovCircle.Thickness = 1; fovCircle.NumSides = 60
			fovCircle.Color = ACCENT; fovCircle.Transparency = 0.7
			fovCircle.Filled = false
		end
		fovCircle.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
		fovCircle.Radius = cfg.FOV
		fovCircle.Visible = true
	elseif fovCircle then
		fovCircle.Visible = false
	end
end)

-- ===== TARGET =====
local function findTarget(): (Player?, BasePart?)
	local closest: Player? = nil; local closestPart: BasePart? = nil
	local closestDist = cfg.FOV
	local center = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
	for _, plr in ipairs(Players:GetPlayers()) do
		if not isEnemy(plr) then continue end
		local head = getHead(plr); local hrp = getHRP(plr)
		if not head or not hrp then continue end
		if (hrp.Position - Cam.CFrame.Position).Magnitude > cfg.MaxDist then continue end
		if not isVisible(head) then continue end
		local sp, on = Cam:WorldToViewportPoint(head.Position)
		if not on then continue end
		local d2 = (Vector2.new(sp.X, sp.Y) - center).Magnitude
		if d2 < closestDist then
			closestDist = d2; closest = plr; closestPart = head
		end
	end
	return closest, closestPart
end

-- ===== AIMBOT =====
local aimHeld = false

UserInputService.InputBegan:Connect(function(i, p)
	if p then return end
	if i.UserInputType == cfg.AimBind or i.KeyCode == cfg.AimBind then
		aimHeld = true
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == cfg.AimBind or i.KeyCode == cfg.AimBind then
		aimHeld = false
	end
end)

RunService:BindToRenderStep("RyzenAim", Enum.RenderPriority.Camera.Value + 1, function()
	if not cfg.Aimbot or not aimHeld then return end
	local plr, part = findTarget()
	if plr and part then
		Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, part.Position)
	end
end)

-- ===== SILENT AIM =====
UserInputService.InputBegan:Connect(function(i, p)
	if p then return end
	if i.UserInputType == Enum.UserInputType.MouseButton1 and cfg.SilentAim then
		local plr, part = findTarget()
		if plr and part then
			local m = LP:GetMouse()
			m.TargetFilter = plr.Character
			m.Hit = CFrame.lookAt(Cam.CFrame.Position, part.Position)
		end
	end
end)

-- ===== INF JUMP + NOCLIP =====
UserInputService.JumpRequest:Connect(function()
	if not cfg.InfJump then return end
	local c = LP.Character
	if not c then return end
	local hum = c:FindFirstChildOfClass("Humanoid")
	local hrp = c:FindFirstChild("HumanoidRootPart")
	if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	if hrp and hrp:IsA("BasePart") then
		hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, cfg.InfJumpPower, hrp.AssemblyLinearVelocity.Z)
	end
end)

RunService.Stepped:Connect(function()
	if not cfg.Noclip then return end
	local c = LP.Character
	if not c then return end
	for _, p in ipairs(c:GetDescendants()) do
		if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
	end
end)

-- ============================================================
-- ===== FPS BOOSTER (FIXED) =====
-- ============================================================

local fpsBackup = {
	Quality = nil :: number?,
	HiddenInstances = {} :: {Instance},
}

local function isPostEffect(obj: Instance): boolean
	return obj:IsA("PostEffect")
		or obj:IsA("BloomEffect")
		or obj:IsA("BlurEffect")
		or obj:IsA("SunRaysEffect")
		or obj:IsA("DepthOfFieldEffect")
		or obj:IsA("ColorCorrectionEffect")
end

local function applyFPSBooster()
	-- 1. Качество рендера
	pcall(function()
		if settings and settings() and settings().Rendering then
			fpsBackup.Quality = settings().Rendering.QualityLevel
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end
	end)

	-- 2. Пост-эффекты (только PostEffect, НЕ Atmosphere)
	for _, obj in ipairs(Lighting:GetChildren()) do
		if isPostEffect(obj) then
			(obj :: any).Enabled = false
		end
	end

	-- 3. Текстуры/декали/частицы (кроме персонажа)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke")
			or obj:IsA("Fire") or obj:IsA("Sparkles") then
			if not obj:IsDescendantOf(LP.Character) then
				pcall(function() (obj :: any).Enabled = false end)
				table.insert(fpsBackup.HiddenInstances, obj)
			end
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			if not obj:IsDescendantOf(LP.Character) then
				pcall(function() (obj :: any).Transparency = 1 end)
				table.insert(fpsBackup.HiddenInstances, obj)
			end
		end
	end
end

local function resetFPSBooster()
	if fpsBackup.Quality then
		pcall(function()
			if settings and settings() and settings().Rendering then
				settings().Rendering.QualityLevel = fpsBackup.Quality
			end
		end)
	end
	for _, obj in ipairs(Lighting:GetChildren()) do
		if isPostEffect(obj) then
			pcall(function() (obj :: any).Enabled = true end)
		end
	end
	for _, obj in ipairs(fpsBackup.HiddenInstances) do
		if obj and obj.Parent then
			pcall(function()
				if (obj :: any).Enabled ~= nil then (obj :: any).Enabled = true end
				if (obj :: any).Transparency ~= nil then (obj :: any).Transparency = 0 end
			end)
		end
	end
	fpsBackup.HiddenInstances = {}
end

-- ===== VISUALS =====
local visualsBackup = {
	ClockTime = Lighting.ClockTime,
	Brightness = Lighting.Brightness,
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	FogEnd = Lighting.FogEnd,
	FogColor = Lighting.FogColor,
	FogStart = Lighting.FogStart,
}

local function applyVisuals(mode: string)
	if mode == "Default" then
		Lighting.ClockTime = visualsBackup.ClockTime
		Lighting.Brightness = visualsBackup.Brightness
		Lighting.Ambient = visualsBackup.Ambient
		Lighting.OutdoorAmbient = visualsBackup.OutdoorAmbient
		Lighting.FogEnd = visualsBackup.FogEnd
		Lighting.FogColor = visualsBackup.FogColor
		Lighting.FogStart = visualsBackup.FogStart
	elseif mode == "Day" then
		Lighting.ClockTime = 14
		Lighting.Brightness = 3
		Lighting.Ambient = Color3.fromRGB(120, 120, 120)
		Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
		Lighting.FogEnd = 100000
		Lighting.FogStart = 0
		Lighting.FogColor = Color3.fromRGB(200, 220, 255)
	elseif mode == "Night" then
		Lighting.ClockTime = 0
		Lighting.Brightness = 1.5
		Lighting.Ambient = Color3.fromRGB(70, 75, 95)
		Lighting.OutdoorAmbient = Color3.fromRGB(60, 65, 85)
		Lighting.FogEnd = 8000
		Lighting.FogStart = 0
		Lighting.FogColor = Color3.fromRGB(30, 35, 60)
	elseif mode == "Sunset" then
		Lighting.ClockTime = 18
		Lighting.Brightness = 2
		Lighting.Ambient = Color3.fromRGB(180, 120, 90)
		Lighting.OutdoorAmbient = Color3.fromRGB(200, 130, 90)
		Lighting.FogEnd = 5000
		Lighting.FogStart = 0
		Lighting.FogColor = Color3.fromRGB(255, 150, 90)
	end
end

-- ============================================================
-- ===== FPS COUNTER (РАБОЧИЙ) =====
-- ============================================================

local fpsCounterGui = Instance.new("ScreenGui")
fpsCounterGui.Name = "RyzenFPS"
fpsCounterGui.ResetOnSpawn = false
fpsCounterGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
fpsCounterGui.Parent = CoreGui

local fpsFrame = Instance.new("Frame")
fpsFrame.Size = UDim2.fromOffset(120, 60)
fpsFrame.Position = UDim2.fromOffset(20, 500)
fpsFrame.BackgroundColor3 = BG
fpsFrame.BackgroundTransparency = 0.25
fpsFrame.BorderSizePixel = 0
fpsFrame.Active = true
fpsFrame.Parent = fpsCounterGui

local fpsC = Instance.new("UICorner")
fpsC.CornerRadius = UDim.new(0, 8)
fpsC.Parent = fpsFrame

local fpsS = Instance.new("UIStroke")
fpsS.Color = ACCENT_DARK
fpsS.Thickness = 1
fpsS.Transparency = 0.3
fpsS.Parent = fpsFrame

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, 0, 0, 26)
fpsLabel.Position = UDim2.fromOffset(0, 4)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = ACCENT
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 20
fpsLabel.Text = "FPS: 0"
fpsLabel.Parent = fpsFrame

local fpsSub = Instance.new("TextLabel")
fpsSub.Size = UDim2.new(1, 0, 0, 22)
fpsSub.Position = UDim2.fromOffset(0, 32)
fpsSub.BackgroundTransparency = 1
fpsSub.TextColor3 = TEXT_DIM
fpsSub.Font = Enum.Font.Gotham
fpsSub.TextSize = 10
fpsSub.Text = "min 0 | max 0 | avg 0"
fpsSub.Parent = fpsFrame

local frameCount = 0
local lastTime = os.clock()
local minFPS = math.huge
local maxFPS = 0
local totalFPS = 0
local sampleCount = 0
local updateTimer = 0

RunService.RenderStepped:Connect(function(dt: number)
	frameCount += 1
	updateTimer += dt
	if updateTimer >= 0.25 then
		local currentFPS = math.floor(frameCount / updateTimer)
		frameCount = 0
		updateTimer = 0

		if currentFPS > 0 then
			minFPS = math.min(minFPS, currentFPS)
			maxFPS = math.max(maxFPS, currentFPS)
			totalFPS += currentFPS
			sampleCount += 1
		end

		if cfg.FPSCounter then
			fpsFrame.Visible = true
			fpsLabel.Text = "FPS: " .. tostring(currentFPS)

			local avg = if sampleCount > 0 then math.floor(totalFPS / sampleCount) else 0
			local minShow = if minFPS == math.huge then 0 else minFPS
			fpsSub.Text = string.format("min %d | max %d | avg %d", minShow, maxFPS, avg)

			local color = if currentFPS >= 60 then ACCENT
				elseif currentFPS >= 30 then Color3.fromRGB(255, 200, 80)
				else Color3.fromRGB(255, 80, 80)
			fpsLabel.TextColor3 = color
		else
			fpsFrame.Visible = false
		end
	end
end)

-- Drag FPS counter
local fpsDragging = false
local fpsDragStart: Vector2? = nil
local fpsStartPos: UDim2? = nil
fpsFrame.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		fpsDragging = true
		fpsDragStart = Vector2.new(i.Position.X, i.Position.Y)
		fpsStartPos = fpsFrame.Position
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if fpsDragging and i.UserInputType == Enum.UserInputType.MouseMovement and fpsDragStart and fpsStartPos then
		local d = Vector2.new(i.Position.X, i.Position.Y) - fpsDragStart
		fpsFrame.Position = UDim2.new(fpsStartPos.X.Scale, fpsStartPos.X.Offset + d.X, fpsStartPos.Y.Scale, fpsStartPos.Y.Offset + d.Y)
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then fpsDragging = false end
end)

-- ============================================================
-- ===== UI =====
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RyzenHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Open button (R, draggable)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.fromOffset(44, 44)
OpenBtn.Position = UDim2.fromOffset(20, 20)
OpenBtn.BackgroundColor3 = ACCENT
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 16
OpenBtn.Text = "R"
OpenBtn.BorderSizePixel = 0
OpenBtn.AutoButtonColor = false
OpenBtn.Active = true
OpenBtn.Parent = ScreenGui

local obC = Instance.new("UICorner")
obC.CornerRadius = UDim.new(1, 0)
obC.Parent = OpenBtn

local obS = Instance.new("UIStroke")
obS.Color = ACCENT_DARK
obS.Thickness = 2
obS.Parent = OpenBtn

OpenBtn.MouseEnter:Connect(function()
	TweenService:Create(OpenBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(140, 220, 100)}):Play()
end)
OpenBtn.MouseLeave:Connect(function()
	TweenService:Create(OpenBtn, TweenInfo.new(0.12), {BackgroundColor3 = ACCENT}):Play()
end)

-- Main
local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(520, 420)
Main.Position = UDim2.fromOffset(20, 64)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local mCorner = Instance.new("UICorner")
mCorner.CornerRadius = UDim.new(0, 14)
mCorner.Parent = Main

local mStroke = Instance.new("UIStroke")
mStroke.Color = ACCENT_DARK
mStroke.Thickness = 1.5
mStroke.Transparency = 0.3
mStroke.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundColor3 = PANEL
Header.BorderSizePixel = 0
Header.Parent = Main

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 14)
hCorner.Parent = Header

local hCover = Instance.new("Frame")
hCover.Size = UDim2.new(1, 0, 0, 14)
hCover.Position = UDim2.new(0, 0, 1, -14)
hCover.BackgroundColor3 = PANEL
hCover.BorderSizePixel = 0
hCover.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -140, 0, 22)
Title.Position = UDim2.fromOffset(56, 8)
Title.BackgroundTransparency = 1
Title.TextColor3 = TEXT
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = HUB_NAME .. " " .. HUB_VERSION
Title.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -140, 0, 16)
SubTitle.Position = UDim2.fromOffset(56, 30)
SubTitle.BackgroundTransparency = 1
SubTitle.TextColor3 = TEXT_DIM
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 11
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Text = "игра: " .. CURRENT_GAME
SubTitle.Parent = Header

local IconBg = Instance.new("Frame")
IconBg.Size = UDim2.fromOffset(36, 36)
IconBg.Position = UDim2.fromOffset(12, 8)
IconBg.BackgroundColor3 = ACCENT
IconBg.BorderSizePixel = 0
IconBg.Parent = Header

local iC = Instance.new("UICorner")
iC.CornerRadius = UDim.new(1, 0)
iC.Parent = IconBg

local IconTxt = Instance.new("TextLabel")
IconTxt.Size = UDim2.fromScale(1, 1)
IconTxt.BackgroundTransparency = 1
IconTxt.Text = "R"
IconTxt.Font = Enum.Font.GothamBold
IconTxt.TextSize = 18
IconTxt.TextColor3 = Color3.new(1, 1, 1)
IconTxt.Parent = IconBg

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.fromOffset(28, 28)
MinimizeBtn.Position = UDim2.new(1, -74, 0, 12)
MinimizeBtn.BackgroundColor3 = OFF
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = TEXT
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = Header

local mbC = Instance.new("UICorner")
mbC.CornerRadius = UDim.new(0, 8)
mbC.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(28, 28)
CloseBtn.Position = UDim2.new(1, -40, 0, 12)
CloseBtn.BackgroundColor3 = OFF
CloseBtn.Text = "X"
CloseBtn.TextColor3 = TEXT
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header

local cbC = Instance.new("UICorner")
cbC.CornerRadius = UDim.new(0, 8)
cbC.Parent = CloseBtn

-- Tab bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -24, 0, 36)
TabBar.Position = UDim2.fromOffset(12, 60)
TabBar.BackgroundColor3 = PANEL
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local tbC = Instance.new("UICorner")
tbC.CornerRadius = UDim.new(0, 10)
tbC.Parent = TabBar

local tbL = Instance.new("UIListLayout")
tbL.FillDirection = Enum.FillDirection.Horizontal
tbL.Padding = UDim.new(0, 6)
tbL.HorizontalAlignment = Enum.HorizontalAlignment.Left
tbL.VerticalAlignment = Enum.VerticalAlignment.Center
tbL.Parent = TabBar

local tbP = Instance.new("UIPadding")
tbP.PaddingLeft = UDim.new(0, 6)
tbP.Parent = TabBar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -24, 1, -112)
Content.Position = UDim2.fromOffset(12, 104)
Content.BackgroundTransparency = 1
Content.Parent = Main

local tabs: {[string]: ScrollingFrame} = {}
local tabButtons: {[string]: TextButton} = {}

local function selectTab(name: string)
	for n, p in pairs(tabs) do
		p.Visible = (n == name)
		local btn = tabButtons[n]
		local active = (n == name)
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = active and ACCENT or OFF,
			TextColor3 = active and Color3.new(1,1,1) or TEXT_DIM,
		}):Play()
	end
end

local function createTab(name: string): ScrollingFrame
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(100, 26)
	btn.BackgroundColor3 = OFF
	btn.TextColor3 = TEXT_DIM
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.Text = name
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Parent = TabBar

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(1, 0)
	bc.Parent = btn

	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = ACCENT
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = Content

	tabs[name] = page
	tabButtons[name] = btn
	btn.MouseButton1Click:Connect(function() selectTab(name) end)
	return page
end

-- Widgets
local yMap: {[ScrollingFrame]: number} = {}
local function nextY(page: ScrollingFrame): number
	local y = yMap[page] or 0
	yMap[page] = y + 40
	return y
end

local function addSection(page: ScrollingFrame, text: string): ()
	local y = nextY(page)
	yMap[page] = y + 28
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -10, 0, 22)
	lbl.Position = UDim2.fromOffset(5, y)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = ACCENT
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = text
	lbl.Parent = page
end

local function addToggle(page: ScrollingFrame, text: string, default: boolean, cb: (boolean) -> ()): ()
	local y = nextY(page)
	local card = Instance.new("TextButton")
	card.Size = UDim2.new(1, -10, 0, 34)
	card.Position = UDim2.fromOffset(5, y)
	card.BackgroundColor3 = PANEL_LIGHT
	card.Text = ""
	card.BorderSizePixel = 0
	card.AutoButtonColor = false
	card.Parent = page

	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0, 8)
	cc.Parent = card

	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(20, 20)
	dot.Position = UDim2.fromOffset(8, 7)
	dot.BackgroundColor3 = default and ACCENT or OFF
	dot.BorderSizePixel = 0
	dot.Parent = card

	local dc = Instance.new("UICorner")
	dc.CornerRadius = UDim.new(1, 0)
	dc.Parent = dot

	local dotIn = Instance.new("Frame")
	dotIn.Size = UDim2.fromOffset(8, 8)
	dotIn.Position = UDim2.fromScale(0.5, 0.5)
	dotIn.AnchorPoint = Vector2.new(0.5, 0.5)
	dotIn.BackgroundColor3 = Color3.new(1, 1, 1)
	dotIn.BorderSizePixel = 0
	dotIn.Visible = default
	dotIn.Parent = dot

	local diC = Instance.new("UICorner")
	diC.CornerRadius = UDim.new(1, 0)
	diC.Parent = dotIn

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -50, 1, 0)
	lbl.Position = UDim2.fromOffset(36, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = TEXT
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = text
	lbl.Parent = card

	local state = default
	card.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(52, 62, 52)}):Play()
	end)
	card.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.12), {BackgroundColor3 = PANEL_LIGHT}):Play()
	end)
	card.MouseButton1Click:Connect(function()
		state = not state
		dotIn.Visible = state
		TweenService:Create(dot, TweenInfo.new(0.15), {BackgroundColor3 = state and ACCENT or OFF}):Play()
		cb(state)
	end)
end

local function addSlider(page: ScrollingFrame, text: string, default: number, min: number, max: number, cb: (number) -> ()): ()
	local y = nextY(page)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -10, 0, 52)
	card.Position = UDim2.fromOffset(5, y)
	card.BackgroundColor3 = PANEL_LIGHT
	card.BorderSizePixel = 0
	card.Parent = page

	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0, 8)
	cc.Parent = card

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -16, 0, 20)
	lbl.Position = UDim2.fromOffset(10, 5)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = TEXT
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = text
	lbl.Parent = card

	local valLbl = Instance.new("TextLabel")
	valLbl.Size = UDim2.new(0, 60, 0, 20)
	valLbl.Position = UDim2.new(1, -70, 0, 5)
	valLbl.BackgroundTransparency = 1
	valLbl.TextColor3 = ACCENT
	valLbl.Font = Enum.Font.GothamBold
	valLbl.TextSize = 12
	valLbl.TextXAlignment = Enum.TextXAlignment.Right
	valLbl.Text = tostring(default)
	valLbl.Parent = card

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -20, 0, 6)
	bar.Position = UDim2.fromOffset(10, 36)
	bar.BackgroundColor3 = OFF
	bar.BorderSizePixel = 0
	bar.Parent = card

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(1, 0)
	bc.Parent = bar

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale((default - min)/(max - min), 1)
	fill.BackgroundColor3 = ACCENT
	fill.BorderSizePixel = 0
	fill.Parent = bar

	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(1, 0)
	fc.Parent = fill

	local dragging = false
	local function update(x: number)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local v = math.floor(min + (max - min) * rel)
		fill.Size = UDim2.fromScale(rel, 1)
		valLbl.Text = tostring(v)
		cb(v)
	end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true; update(i.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			update(i.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
end

local function addButton(page: ScrollingFrame, text: string, cb: () -> ()): ()
	local y = nextY(page)
	local card = Instance.new("TextButton")
	card.Size = UDim2.new(1, -10, 0, 32)
	card.Position = UDim2.fromOffset(5, y)
	card.BackgroundColor3 = PANEL_LIGHT
	card.TextColor3 = TEXT
	card.Font = Enum.Font.Gotham
	card.TextSize = 12
	card.Text = text
	card.BorderSizePixel = 0
	card.AutoButtonColor = false
	card.Parent = page

	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0, 8)
	cc.Parent = card

	card.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(52, 62, 52)}):Play()
	end)
	card.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.12), {BackgroundColor3 = PANEL_LIGHT}):Play()
	end)
	card.MouseButton1Click:Connect(cb)
end

-- Tabs
local universalTab = createTab("Universal")
local rivalsTab = createTab("Rivals")
local visualsTab = createTab("Visuals")
local perfTab = createTab("Performance")

local defaultTab = if CURRENT_GAME == "Rivals" then "Rivals" else "Universal"
selectTab(defaultTab)

-- Universal
addSection(universalTab, "Движение")
addToggle(universalTab, "SpeedHack", false, function(v) cfg.Speed = v; applySpeed() end)
addSlider(universalTab, "WalkSpeed", 16, 16, 300, function(v) cfg.SpeedValue = v; applySpeed() end)
addToggle(universalTab, "Infinite Jump", false, function(v) cfg.InfJump = v end)
addSlider(universalTab, "Jump Power", 50, 10, 200, function(v) cfg.InfJumpPower = v end)
addToggle(universalTab, "Noclip", false, function(v) cfg.Noclip = v end)

-- Rivals
addSection(rivalsTab, "Визуалы")
addToggle(rivalsTab, "ESP", true, function(v) cfg.ESP = v end)
addToggle(rivalsTab, "Boxes", true, function(v) cfg.Boxes = v end)
addToggle(rivalsTab, "Names", true, function(v) cfg.Names = v end)
addToggle(rivalsTab, "Healthbar", true, function(v) cfg.Healthbar = v end)
addToggle(rivalsTab, "Skeleton", true, function(v) cfg.Skeleton = v end)
addToggle(rivalsTab, "Team Check", true, function(v) cfg.TeamCheck = v end)
addToggle(rivalsTab, "Wall Check", true, function(v) cfg.WallCheck = v end)
addSection(rivalsTab, "Бой")
addToggle(rivalsTab, "Aimbot", false, function(v) cfg.Aimbot = v end)
addToggle(rivalsTab, "Silent Aim", false, function(v) cfg.SilentAim = v end)
addSlider(rivalsTab, "FOV", 120, 20, 500, function(v) cfg.FOV = v end)
addSlider(rivalsTab, "Max Distance", 800, 100, 3000, function(v) cfg.MaxDist = v end)
addSection(rivalsTab, "Бинд аима")
addButton(rivalsTab, "Бинд: ПКМ (Mouse2)", function() cfg.AimBind = Enum.UserInputType.MouseButton2 end)
addButton(rivalsTab, "Бинд: ЛКМ (Mouse1)", function() cfg.AimBind = Enum.UserInputType.MouseButton1 end)
addButton(rivalsTab, "Бинд: E", function() cfg.AimBind = Enum.KeyCode.E end)
addButton(rivalsTab, "Бинд: Q", function() cfg.AimBind = Enum.KeyCode.Q end)
addButton(rivalsTab, "Бинд: Left Shift", function() cfg.AimBind = Enum.KeyCode.LeftShift end)
addButton(rivalsTab, "Бинд: Left Alt", function() cfg.AimBind = Enum.KeyCode.LeftAlt end)

-- Visuals
addSection(visualsTab, "Время суток")
addButton(visualsTab, "Default (по умолчанию)", function() cfg.VisualMode = "Default"; applyVisuals("Default") end)
addButton(visualsTab, "Day (день)", function() cfg.VisualMode = "Day"; applyVisuals("Day") end)
addButton(visualsTab, "Night (ночь, не всё темно)", function() cfg.VisualMode = "Night"; applyVisuals("Night") end)
addButton(visualsTab, "Sunset (закат)", function() cfg.VisualMode = "Sunset"; applyVisuals("Sunset") end)
addSection(visualsTab, "FOV камеры")
addSlider(visualsTab, "Camera FOV", 70, 50, 120, function(v) Cam.FieldOfView = v end)

-- Performance
addSection(perfTab, "FPS Booster")
addToggle(perfTab, "FPS Booster", false, function(v)
	cfg.FPSBooster = v
	if v then applyFPSBooster() else resetFPSBooster() end
end)
addButton(perfTab, "Boost один раз", function() applyFPSBooster() end)
addButton(perfTab, "Сбросить графику", function() resetFPSBooster() end)
addSection(perfTab, "FPS Счётчик")
addToggle(perfTab, "FPS Counter", true, function(v) cfg.FPSCounter = v end)
addButton(perfTab, "Сбросить min/max/avg", function()
	minFPS = math.huge; maxFPS = 0; totalFPS = 0; sampleCount = 0
end)

-- Open / minimize / close
local function openMenu()
	Main.Visible = true
	Main.Size = UDim2.fromOffset(0, 0)
	TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(520, 420)
	}):Play()
end

local function hideMenu()
	local t = TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.fromOffset(0, 0)
	})
	t:Play()
	t.Completed:Connect(function() Main.Visible = false end)
end

MinimizeBtn.MouseButton1Click:Connect(function() Main.Visible = false end)
CloseBtn.MouseButton1Click:Connect(function()
	Main.Visible = false
	Main.Size = UDim2.fromOffset(520, 420)
end)

-- Drag open button
local btnDragging = false
local btnDragStart: Vector2? = nil
local btnStartPos: UDim2? = nil
local btnMoved = false

OpenBtn.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		btnDragging = true
		btnMoved = false
		btnDragStart = Vector2.new(i.Position.X, i.Position.Y)
		btnStartPos = OpenBtn.Position
	end
end)
OpenBtn.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		if not btnMoved and btnDragging then
			if Main.Visible then hideMenu() else openMenu() end
		end
		btnDragging = false
	end
end)

UserInputService.InputChanged:Connect(function(i)
	if btnDragging and i.UserInputType == Enum.UserInputType.MouseMovement and btnDragStart and btnStartPos then
		local d = Vector2.new(i.Position.X, i.Position.Y) - btnDragStart
		if math.abs(d.X) > 3 or math.abs(d.Y) > 3 then btnMoved = true end
		OpenBtn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + d.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + d.Y)
	end
end)

-- Drag main
local dragging = false
local dragStart: Vector2? = nil
local startPos: UDim2? = nil
Header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = Vector2.new(i.Position.X, i.Position.Y)
		startPos = Main.Position
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement and dragStart and startPos then
		local d = Vector2.new(i.Position.X, i.Position.Y) - dragStart
		Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

print("[" .. HUB_NAME .. "] " .. HUB_VERSION .. " loaded | game: " .. CURRENT_GAME)