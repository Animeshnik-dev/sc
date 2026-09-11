--=============================================================
-- RYZEN PREMIUM MULTI-TOOL v3.5 (FULL)
-- ESP | Aimbot | Fly | Noclip | Teleport | FPS BOOST
--=============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ============ КОНФИГ ============
local Config = {
    Enabled = true,
    ShowPlayers = true, ShowZombies = true, ShowOthers = true, ShowWeapons = true,
    ShowName = true, ShowHealth = true, ShowDistance = true, ShowBox = true,
    ShowChams = true, ShowSkeleton = false, ShowTracer = false,
    MaxDistance = 2000,
    AimbotEnabled = false, AimbotFOV = 150, AimbotSmooth = 15,
    AimbotVisibleCheck = false, AimbotTargetPlayers = true,
    AimbotTargetZombies = true, AimbotTargetOthers = false,
    AimbotKey = Enum.KeyCode.E,
    FlyEnabled = false, FlySpeed = 55,
    NoclipEnabled = false,
    FPSBoostEnabled = false,
    Colors = {
        Player = Color3.fromRGB(0, 255, 0),
        Zombie = Color3.fromRGB(0, 150, 255),
        Other  = Color3.fromRGB(255, 0, 0),
        Weapon = Color3.fromRGB(180, 0, 255),
        FOV    = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(160, 60, 255)
    }
}

local WEAPON_SPOTS = {
    {name = "Точка #1 — 183,305,184",   pos = Vector3.new(183, 305, 184)},
    {name = "Точка #2 — 136,334,501",   pos = Vector3.new(136, 334, 501)},
    {name = "Точка #3 — 115,324,676",   pos = Vector3.new(115, 324, 676)},
    {name = "Точка #4 — 320,272,140",   pos = Vector3.new(320, 272, 140)},
    {name = "Точка #5 — 3,268,187",     pos = Vector3.new(3, 268, 187)},
    {name = "Точка #6 — -104,313,461",  pos = Vector3.new(-104, 313, 461)},
    {name = "Точка #7 — -155,303,768",  pos = Vector3.new(-155, 303, 768)},
    {name = "Точка #8 — 233,373,49",    pos = Vector3.new(233, 373, 49)},
    {name = "Точка #9 — 148,260,326",   pos = Vector3.new(148, 260, 326)},
    {name = "Точка #10 — 157,344,607",  pos = Vector3.new(157, 344, 607)},
    {name = "Точка #11 — 326,511,392",  pos = Vector3.new(326, 511, 392)},
}

local ZOMBIE_KEYWORDS = {"zombie","zombi","undead","walker","infected","зомби","упырь","монстр"}

local DrawingAPI = (function()
    local ok = pcall(function() return Drawing.new("Line") end)
    return ok and Drawing or nil
end)()

local function D(class, props)
    if not DrawingAPI then return nil end
    local ok, d = pcall(function() return Drawing.new(class) end)
    if not ok or not d then return nil end
    for k, v in pairs(props) do pcall(function() d[k] = v end) end
    return d
end

local Cache = {
    ESP = {}, Weapons = {}, FOV = nil,
    LastScan = 0, ScanInterval = 1,
    CharCache = nil, HRPCache = nil,
}

-- ============ FPS BOOST ============
local FPSBoost = {
    Active = false,
    SavedLighting = {},
    SavedPostFX = {},
    SavedTerrain = {},
    SavedParticles = {},
    SavedTextures = {},
    SavedParts = {},
    NewConn = nil,
}

local function SaveLightingState()
    FPSBoost.SavedLighting = {
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        GeographicLatitude = Lighting.GeographicLatitude,
    }
end

local function RestoreLightingState()
    local s = FPSBoost.SavedLighting
    if s.GlobalShadows ~= nil then Lighting.GlobalShadows = s.GlobalShadows end
    if s.FogEnd then Lighting.FogEnd = s.FogEnd end
    if s.Ambient then Lighting.Ambient = s.Ambient end
    if s.OutdoorAmbient then Lighting.OutdoorAmbient = s.OutdoorAmbient end
    if s.Brightness then Lighting.Brightness = s.Brightness end
    if s.ClockTime then Lighting.ClockTime = s.ClockTime end
    if s.GeographicLatitude then Lighting.GeographicLatitude = s.GeographicLatitude end
end

local function OptimizeObject(obj)
    if obj:IsA("BasePart") then
        if not FPSBoost.SavedParts[obj] then
            FPSBoost.SavedParts[obj] = {
                Material = obj.Material,
                Reflectance = obj.Reflectance,
                CastShadow = obj.CastShadow,
            }
        end
        pcall(function()
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false
        end)
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        if FPSBoost.SavedTextures[obj] == nil then
            FPSBoost.SavedTextures[obj] = obj.Transparency
        end
        pcall(function() obj.Transparency = 1 end)
    elseif obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Fire")
        or obj:IsA("Smoke")
        or obj:IsA("Sparkles")
        or obj:IsA("Beam")
        or obj:IsA("PointLight")
        or obj:IsA("SpotLight")
        or obj:IsA("SurfaceLight") then
        if obj.Enabled ~= nil then
            if FPSBoost.SavedParticles[obj] == nil then
                FPSBoost.SavedParticles[obj] = obj.Enabled
            end
            pcall(function() obj.Enabled = false end)
        end
    end
end

local function EnableFPSBoost()
    if FPSBoost.Active then return end
    FPSBoost.Active = true
    SaveLightingState()

    -- 1. Освещение
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 300
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
    end)

    -- 2. Пост-эффекты
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            FPSBoost.SavedPostFX[effect] = effect.Enabled
            effect.Enabled = false
        end
    end

    -- 3. Атмосфера
    pcall(function()
        local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmo then
            FPSBoost.SavedTerrain["Atmosphere"] = {
                Density = atmo.Density, Offset = atmo.Offset,
                Color = atmo.Color, Decay = atmo.Decay,
                Glare = atmo.Glare, Haze = atmo.Haze,
            }
            atmo.Density = 0; atmo.Haze = 0; atmo.Glare = 0
        end
    end)

    -- 4. Terrain (вода)
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        pcall(function()
            FPSBoost.SavedTerrain["WaterWaveSize"] = terrain.WaterWaveSize
            FPSBoost.SavedTerrain["WaterWaveSpeed"] = terrain.WaterWaveSpeed
            FPSBoost.SavedTerrain["WaterReflectance"] = terrain.WaterReflectance
            FPSBoost.SavedTerrain["WaterTransparency"] = terrain.WaterTransparency
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
        end)
    end

    -- 5. Качество рендера (нативно)
    pcall(function()
        local rs = settings()
        if rs and rs.Rendering then
            rs.Rendering.QualityLevel = Enum.QualityLevel.Level01
        end
    end)

    -- 6. Объекты
    task.spawn(function()
        local processed = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            OptimizeObject(obj)
            processed = processed + 1
            if processed % 500 == 0 then task.wait() end
        end
    end)

    -- 7. Отслеживание новых объектов
    FPSBoost.NewConn = workspace.DescendantAdded:Connect(function(obj)
        if FPSBoost.Active then OptimizeObject(obj) end
    end)

    -- 8. FPS cap
    pcall(function() if setfpscap then setfpscap(120) end end)

    print("[FPS BOOST] Включён.")
end

local function DisableFPSBoost()
    if not FPSBoost.Active then return end
    FPSBoost.Active = false

    if FPSBoost.NewConn then
        FPSBoost.NewConn:Disconnect()
        FPSBoost.NewConn = nil
    end

    RestoreLightingState()

    for effect, enabled in pairs(FPSBoost.SavedPostFX) do
        if effect and effect.Parent then
            pcall(function() effect.Enabled = enabled end)
        end
    end
    FPSBoost.SavedPostFX = {}

    local atmoSaved = FPSBoost.SavedTerrain["Atmosphere"]
    if atmoSaved then
        local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
        if atmo then
            pcall(function()
                atmo.Density = atmoSaved.Density
                atmo.Offset = atmoSaved.Offset
                atmo.Color = atmoSaved.Color
                atmo.Decay = atmoSaved.Decay
                atmo.Glare = atmoSaved.Glare
                atmo.Haze = atmoSaved.Haze
            end)
        end
    end

    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        pcall(function()
            terrain.WaterWaveSize = FPSBoost.SavedTerrain["WaterWaveSize"] or 0.15
            terrain.WaterWaveSpeed = FPSBoost.SavedTerrain["WaterWaveSpeed"] or 10
            terrain.WaterReflectance = FPSBoost.SavedTerrain["WaterReflectance"] or 1
            terrain.WaterTransparency = FPSBoost.SavedTerrain["WaterTransparency"] or 1
        end)
    end

    for part, saved in pairs(FPSBoost.SavedParts) do
        if part and part.Parent then
            pcall(function()
                part.Material = saved.Material
                part.Reflectance = saved.Reflectance
                part.CastShadow = saved.CastShadow
            end)
        end
    end
    FPSBoost.SavedParts = {}

    for tex, trans in pairs(FPSBoost.SavedTextures) do
        if tex and tex.Parent then
            pcall(function() tex.Transparency = trans end)
        end
    end
    FPSBoost.SavedTextures = {}

    for fx, enabled in pairs(FPSBoost.SavedParticles) do
        if fx and fx.Parent and fx.Enabled ~= nil then
            pcall(function() fx.Enabled = enabled end)
        end
    end
    FPSBoost.SavedParticles = {}

    pcall(function() if setfpscap then setfpscap(240) end end)

    print("[FPS BOOST] Выключен.")
end

-- ============ УТИЛИТЫ ============
local function GetRoot(model)
    if not model or not model:IsA("Model") then return nil end
    return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
end

local function GetLocalHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    if Cache.CharCache ~= char or not Cache.HRPCache or not Cache.HRPCache.Parent then
        Cache.CharCache = char
        Cache.HRPCache = char:FindFirstChild("HumanoidRootPart")
    end
    return Cache.HRPCache
end

local function GetEntityType(model)
    local plr = Players:GetPlayerFromCharacter(model)
    if plr then return "Player", Config.Colors.Player, plr.Name end
    local n = string.lower(model.Name)
    for _, kw in ipairs(ZOMBIE_KEYWORDS) do
        if string.find(n, kw) then return "Zombie", Config.Colors.Zombie, model.Name end
    end
    if model:GetAttribute("Zombie") or model:GetAttribute("IsZombie") then
        return "Zombie", Config.Colors.Zombie, model.Name
    end
    return "Other", Config.Colors.Other, model.Name
end

local function IsGroundWeapon(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if not tool.Parent or not tool.Parent:IsA("Workspace") then return false end
    if not tool:FindFirstChild("Handle") then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild(tool.Name) == tool then return false end
    end
    return true
end

local function TeleportToPosition(pos)
    local hrp = GetLocalHRP()
    if not hrp then return false end
    pcall(function() hrp.Velocity = Vector3.zero end)
    pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero end)
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
    return true
end

local function TeleportAllSpots()
    task.spawn(function()
        for _, spot in ipairs(WEAPON_SPOTS) do
            TeleportToPosition(spot.pos)
            task.wait(1.2)
        end
    end)
end

local function TeleportToNearestPlayer()
    local hrp = GetLocalHRP()
    if not hrp then return false end
    local myPos = hrp.Position
    local best, bestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local r = plr.Character:FindFirstChild("HumanoidRootPart")
            local h = plr.Character:FindFirstChildOfClass("Humanoid")
            if r and h and h.Health > 0 then
                local d = (r.Position - myPos).Magnitude
                if d < bestDist then best, bestDist = r, d end
            end
        end
    end
    if best then return TeleportToPosition(best.Position) end
    return false
end

local SKELETON_BONES = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

-- ============ ESP ============
local function CreateESP(model)
    if not model or not model:IsA("Model") or Cache.ESP[model] then return end
    local skel = {}
    if DrawingAPI then
        for i = 1, #SKELETON_BONES do
            skel[i] = D("Line", {Thickness = 1, Visible = false, Color = Color3.fromRGB(255,255,255)})
        end
    end
    Cache.ESP[model] = {
        Box = D("Square", {Thickness = 1, Filled = false, Visible = false}),
        Name = D("Text", {Size = 14, Center = true, Outline = true, Visible = false}),
        Health = D("Text", {Size = 12, Center = true, Outline = true, Visible = false}),
        Distance = D("Text", {Size = 12, Center = true, Outline = true, Visible = false}),
        Tracer = D("Line", {Thickness = 1, Visible = false}),
        Highlight = nil,
        Skeleton = skel,
        LastType = nil, LastColor = nil, LastName = nil, LastTypeTime = 0,
    }
end

local function CreateHighlight(model)
    if not Config.ShowChams then return end
    local esp = Cache.ESP[model]
    if not esp or esp.Highlight then return end
    local _, color = GetEntityType(model)
    local hl = Instance.new("Highlight")
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0.65
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = model
    hl.Parent = (gethui and gethui()) or CoreGui
    esp.Highlight = hl
end

local function RemoveESP(model)
    local esp = Cache.ESP[model]
    if not esp then return end
    for k, o in pairs(esp) do
        if type(o) == "table" then
            for _, l in ipairs(o) do if l and l.Remove then l:Remove() end end
        elseif type(o) == "userdata" and o.Remove then o:Remove()
        elseif typeof(o) == "Instance" then o:Destroy() end
    end
    Cache.ESP[model] = nil
end

local function CreateWeaponESP(tool)
    if not tool or not tool:IsA("Tool") or Cache.Weapons[tool] then return end
    Cache.Weapons[tool] = {
        Box = D("Square", {Thickness = 1, Filled = false, Visible = false, Color = Config.Colors.Weapon}),
        Name = D("Text", {Size = 13, Center = true, Outline = true, Color = Config.Colors.Weapon, Visible = false}),
        Distance = D("Text", {Size = 11, Center = true, Outline = true, Color = Config.Colors.Weapon, Visible = false}),
    }
end

local function RemoveWeaponESP(tool)
    local esp = Cache.Weapons[tool]
    if not esp then return end
    for _, o in pairs(esp) do if o and o.Remove then o:Remove() end end
    Cache.Weapons[tool] = nil
end

-- ============ ОБНОВЛЕНИЕ ESP ============
local vpCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    vpCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

local function HideAllESP(esp)
    if esp.Box then esp.Box.Visible = false end
    if esp.Name then esp.Name.Visible = false end
    if esp.Health then esp.Health.Visible = false end
    if esp.Distance then esp.Distance.Visible = false end
    if esp.Tracer then esp.Tracer.Visible = false end
    if esp.Highlight then esp.Highlight.Enabled = false end
    if esp.Skeleton then for _, l in ipairs(esp.Skeleton) do if l then l.Visible = false end end end
end

local function UpdateEntityESP()
    local camPos = Camera.CFrame.Position
    local maxDist = Config.MaxDistance
    for model, esp in pairs(Cache.ESP) do
        local root = GetRoot(model)
        local hum = model:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 or not Config.Enabled then
            HideAllESP(esp); continue
        end

        local etype, color, displayName
        if esp.LastType and (tick() - esp.LastTypeTime) < 1 then
            etype, color, displayName = esp.LastType, esp.LastColor, esp.LastName
        else
            etype, color, displayName = GetEntityType(model)
            esp.LastType, esp.LastColor, esp.LastName = etype, color, displayName
            esp.LastTypeTime = tick()
        end

        local shouldShow = (etype == "Player" and Config.ShowPlayers)
                        or (etype == "Zombie" and Config.ShowZombies)
                        or (etype == "Other"  and Config.ShowOthers)
        if esp.Highlight then esp.Highlight.Enabled = shouldShow and Config.ShowChams end
        if not shouldShow then HideAllESP(esp); continue end

        local pos = root.Position
        local dist = (camPos - pos).Magnitude
        if dist > maxDist then HideAllESP(esp); continue end

        local sp, onScreen = Camera:WorldToViewportPoint(pos)
        if not onScreen then HideAllESP(esp); continue end

        local scale = 1000 / math.max(dist, 1)
        local w = math.clamp(scale * 1.5, 20, 220)
        local h = math.clamp(scale * 3, 30, 320)

        if esp.Box then
            esp.Box.Size = Vector2.new(w, h)
            esp.Box.Position = Vector2.new(sp.X - w/2, sp.Y - h/2)
            esp.Box.Color = color
            esp.Box.Visible = Config.ShowBox
        end
        if esp.Name then
            esp.Name.Position = Vector2.new(sp.X, sp.Y - h/2 - 15)
            esp.Name.Text = displayName
            esp.Name.Color = color
            esp.Name.Visible = Config.ShowName
        end
        if esp.Health and hum then
            esp.Health.Position = Vector2.new(sp.X, sp.Y + h/2 + 5)
            esp.Health.Text = string.format("HP: %d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
            esp.Health.Color = color
            esp.Health.Visible = Config.ShowHealth
        end
        if esp.Distance then
            esp.Distance.Position = Vector2.new(sp.X, sp.Y + h/2 + 20)
            esp.Distance.Text = string.format("[%d]", math.floor(dist))
            esp.Distance.Color = color
            esp.Distance.Visible = Config.ShowDistance
        end
        if esp.Tracer then
            esp.Tracer.From = vpCenter + Vector2.new(0, Camera.ViewportSize.Y/2 - 20)
            esp.Tracer.To = Vector2.new(sp.X, sp.Y + h/2)
            esp.Tracer.Color = color
            esp.Tracer.Visible = Config.ShowTracer
        end
        if esp.Skeleton then
            if Config.ShowSkeleton then
                for i, bp in ipairs(SKELETON_BONES) do
                    local line = esp.Skeleton[i]
                    if line then
                        local p1 = model:FindFirstChild(bp[1])
                        local p2 = model:FindFirstChild(bp[2])
                        if p1 and p2 then
                            local s1, o1 = Camera:WorldToViewportPoint(p1.Position)
                            local s2, o2 = Camera:WorldToViewportPoint(p2.Position)
                            if o1 and o2 then
                                line.From = Vector2.new(s1.X, s1.Y)
                                line.To = Vector2.new(s2.X, s2.Y)
                                line.Color = color
                                line.Visible = true
                            else line.Visible = false end
                        else line.Visible = false end
                    end
                end
            else
                for _, l in ipairs(esp.Skeleton) do if l then l.Visible = false end end
            end
        end
    end
end

local function UpdateWeaponESP()
    local camPos = Camera.CFrame.Position
    for tool, esp in pairs(Cache.Weapons) do
        if not IsGroundWeapon(tool) or not Config.Enabled or not Config.ShowWeapons then
            for _, o in pairs(esp) do if o then o.Visible = false end end
            if tool and not tool.Parent then RemoveWeaponESP(tool) end
            continue
        end
        local handle = tool:FindFirstChild("Handle")
        local dist = (camPos - handle.Position).Magnitude
        if dist > Config.MaxDistance then
            for _, o in pairs(esp) do if o then o.Visible = false end end
            continue
        end
        local sp, onScreen = Camera:WorldToViewportPoint(handle.Position)
        if not onScreen then
            for _, o in pairs(esp) do if o then o.Visible = false end end
            continue
        end
        local w, h = 35, 35
        if esp.Box then
            esp.Box.Size = Vector2.new(w, h)
            esp.Box.Position = Vector2.new(sp.X - w/2, sp.Y - h/2)
            esp.Box.Color = Config.Colors.Weapon
            esp.Box.Visible = true
        end
        if esp.Name then
            esp.Name.Position = Vector2.new(sp.X, sp.Y - h/2 - 12)
            esp.Name.Text = "🔫 " .. tool.Name
            esp.Name.Color = Config.Colors.Weapon
            esp.Name.Visible = true
        end
        if esp.Distance then
            esp.Distance.Position = Vector2.new(sp.X, sp.Y + h/2 + 4)
            esp.Distance.Text = string.format("[%d]", math.floor(dist))
            esp.Distance.Color = Config.Colors.Weapon
            esp.Distance.Visible = true
        end
    end
end

-- ============ СКАН ============
local function ScanEntities()
    local now = tick()
    if now - Cache.LastScan < Cache.ScanInterval then return end
    Cache.LastScan = now
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            CreateESP(plr.Character)
            if Config.ShowChams then CreateHighlight(plr.Character) end
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            if not Players:GetPlayerFromCharacter(obj) then
                CreateESP(obj)
                if Config.ShowChams then CreateHighlight(obj) end
            end
        elseif obj:IsA("Tool") then
            CreateWeaponESP(obj)
        end
    end
end

local function GetGroundWeapons()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if IsGroundWeapon(obj) then table.insert(list, obj) end
    end
    return list
end

local function GetAimbotTargets()
    local targets = {}
    for model in pairs(Cache.ESP) do
        local root = GetRoot(model)
        local hum = model:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then continue end
        local etype = GetEntityType(model)
        if etype == "Player" and not Config.AimbotTargetPlayers then continue end
        if etype == "Zombie" and not Config.AimbotTargetZombies then continue end
        if etype == "Other" and not Config.AimbotTargetOthers then continue end
        table.insert(targets, {model = model, root = root, hum = hum, etype = etype})
    end
    return targets
end

local function GetNearestWeapon()
    local weapons = GetGroundWeapons()
    if #weapons == 0 then return nil end
    local hrp = GetLocalHRP()
    if not hrp then return nil end
    local best, bestDist = nil, math.huge
    for _, w in ipairs(weapons) do
        local h = w:FindFirstChild("Handle")
        if h then
            local d = (h.Position - hrp.Position).Magnitude
            if d < bestDist then best, bestDist = w, d end
        end
    end
    return best
end

-- ============ AIMBOT ============
local function GetClosestTarget()
    local best, bestDist = nil, math.huge
    local camPos = Camera.CFrame.Position
    for _, t in ipairs(GetAimbotTargets()) do
        local sp, onScreen = Camera:WorldToViewportPoint(t.root.Position)
        if onScreen then
            local d = (Vector2.new(sp.X, sp.Y) - vpCenter).Magnitude
            if d < Config.AimbotFOV and d < bestDist then
                if Config.AimbotVisibleCheck then
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                    local res = workspace:Raycast(camPos, (t.root.Position - camPos).Unit * 1000, params)
                    if res and not res.Instance:IsDescendantOf(t.model) then continue end
                end
                best, bestDist = t, d
            end
        end
    end
    return best
end

local function UpdateFOVCircle()
    if not DrawingAPI then return end
    if not Cache.FOV then
        Cache.FOV = D("Circle", {Thickness = 1, Filled = false, Color = Config.Colors.FOV, Visible = false})
    end
    if not Cache.FOV then return end
    if not Config.AimbotEnabled then Cache.FOV.Visible = false; return end
    Cache.FOV.Position = vpCenter
    Cache.FOV.Radius = Config.AimbotFOV
    Cache.FOV.Visible = true
end

-- ============ FLY ============
local FlyState = {BV = nil, BG = nil, Active = false, AntiFling = nil}

local function StopFly()
    if not FlyState.Active then return end
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if FlyState.BV then FlyState.BV:Destroy() end
            if FlyState.BG then FlyState.BG:Destroy() end
            pcall(function() hrp.Velocity = Vector3.zero end)
            pcall(function() hrp.RotVelocity = Vector3.zero end)
        end
    end
    if FlyState.AntiFling then FlyState.AntiFling:Disconnect() end
    FlyState.BV, FlyState.BG, FlyState.AntiFling = nil, nil, nil
    FlyState.Active = false
end

local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    StopFly()
    local bv = Instance.new("BodyVelocity")
    bv.Name = "HumanoidStateVelocity"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.zero
    bv.P = 1250
    bv.Parent = hrp
    local bg = Instance.new("BodyGyro")
    bg.Name = "HumanoidStateGyro"
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 1000
    bg.D = 50
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    FlyState.AntiFling = RunService.Heartbeat:Connect(function()
        if not hrp or not hrp.Parent then return end
        pcall(function()
            if hrp.RotVelocity.Magnitude > 10 then hrp.RotVelocity = Vector3.zero end
        end)
    end)
    FlyState.BV, FlyState.BG, FlyState.Active = bv, bg, true
end

local function UpdateFly()
    if not Config.FlyEnabled then
        if FlyState.Active then StopFly() end
        return
    end
    if not FlyState.Active then StartFly(); return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not FlyState.BV or not FlyState.BG then return end
    local camCF = Camera.CFrame
    local move = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camCF.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camCF.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camCF.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camCF.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
    if move.Magnitude > 0 then move = move.Unit * Config.FlySpeed end
    FlyState.BV.Velocity = move
    FlyState.BG.CFrame = camCF
end

-- ============ NOCLIP ============
local NoclipConnection = nil

local function StartNoclip()
    if NoclipConnection then return end
    NoclipConnection = RunService.Stepped:Connect(function()
        if not Config.NoclipEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

local function StopNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
end

local function UpdateNoclip()
    if Config.NoclipEnabled then StartNoclip() else StopNoclip() end
end

-- ============ UI ============
local function CreateUI()
    local old = (gethui and gethui() or CoreGui):FindFirstChild("RyzenPremium")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "RyzenPremium"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Parent = (gethui and gethui()) or CoreGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 640, 0, 480)
    main.Position = UDim2.new(0.5, -320, 0.5, -240)
    main.BackgroundColor3 = Color3.fromRGB(16, 14, 22)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.ClipsDescendants = true
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Config.Colors.Accent
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 55)
    topBar.BackgroundColor3 = Color3.fromRGB(22, 18, 30)
    topBar.BorderSizePixel = 0
    topBar.Parent = main
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 20, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 15, 30)),
    })
    grad.Parent = topBar

    local topFix = Instance.new("Frame")
    topFix.Size = UDim2.new(1, 0, 0, 15)
    topFix.Position = UDim2.new(0, 0, 1, -15)
    topFix.BackgroundColor3 = Color3.fromRGB(22, 18, 30)
    topFix.BorderSizePixel = 0
    topFix.Parent = topBar

    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 380, 1, 0)
    logo.Position = UDim2.new(0, 22, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "⚡ RYZEN PREMIUM v3.5"
    logo.TextColor3 = Color3.fromRGB(220, 180, 255)
    logo.Font = Enum.Font.GothamBlack
    logo.TextSize = 20
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = topBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -42, 0, 12)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 70)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = topBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
    minimizeBtn.Position = UDim2.new(1, -80, 0, 12)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 60, 90)
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 20
    minimizeBtn.Parent = topBar
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 145, 1, -70)
    sidebar.Position = UDim2.new(0, 12, 0, 62)
    sidebar.BackgroundColor3 = Color3.fromRGB(22, 18, 30)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = sidebar
    Instance.new("UIPadding", sidebar).PaddingTop = UDim.new(0, 8)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -173, 1, -70)
    content.Position = UDim2.new(0, 165, 0, 62)
    content.BackgroundColor3 = Color3.fromRGB(22, 18, 30)
    content.BorderSizePixel = 0
    content.Parent = main
    Instance.new("UICorner", content).CornerRadius = UDim.new(0, 10)

    local pages = {}
    local function CreatePage(name)
        local page = Instance.new("ScrollingFrame")
        page.Name = name
        page.Size = UDim2.new(1, -16, 1, -16)
        page.Position = UDim2.new(0, 8, 0, 8)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = Config.Colors.Accent
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.Parent = content
        local l = Instance.new("UIListLayout")
        l.Padding = UDim.new(0, 6)
        l.SortOrder = Enum.SortOrder.LayoutOrder
        l.Parent = page
        return page
    end

    pages.ESP = CreatePage("ESP")
    pages.Aimbot = CreatePage("Aimbot")
    pages.Fly = CreatePage("Fly")
    pages.Teleport = CreatePage("Teleport")
    pages.Misc = CreatePage("Misc")

    local tabs = {}
    local function SelectTab(name)
        for tn, tab in pairs(tabs) do
            if tn == name then
                tab.BackgroundColor3 = Color3.fromRGB(50, 25, 80)
                tab.TextColor3 = Color3.fromRGB(220, 180, 255)
                pages[tn].Visible = true
            else
                tab.BackgroundColor3 = Color3.fromRGB(30, 24, 40)
                tab.TextColor3 = Color3.fromRGB(170, 160, 190)
                pages[tn].Visible = false
            end
        end
    end

    for _, t in ipairs({
        {name="👁 ESP", key="ESP"},
        {name="🎯 Aimbot", key="Aimbot"},
        {name="✈ Fly", key="Fly"},
        {name="⚡ Teleport", key="Teleport"},
        {name="🚀 FPS Boost", key="Misc"},
    }) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 38)
        btn.Position = UDim2.new(0, 8, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(30, 24, 40)
        btn.BorderSizePixel = 0
        btn.Text = "  " .. t.name
        btn.TextColor3 = Color3.fromRGB(170, 160, 190)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function() SelectTab(t.key) end)
        tabs[t.key] = btn
    end
    SelectTab("ESP")

    local minimized = false
    local savedSize = UDim2.new(0, 640, 0, 480)
    local savedPos = main.Position

    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            savedSize = main.Size; savedPos = main.Position
            sidebar.Visible = false; content.Visible = false
            TweenService:Create(main, TweenInfo.new(0.2), {Size = UDim2.new(0, 340, 0, 55)}):Play()
            minimizeBtn.Text = "+"; minimizeBtn.TextSize = 18
            logo.Text = "⚡ RYZEN PREMIUM (свёрнуто)"; logo.TextSize = 14
        else
            TweenService:Create(main, TweenInfo.new(0.2), {Size = savedSize, Position = savedPos}):Play()
            task.wait(0.2)
            sidebar.Visible = true; content.Visible = true
            minimizeBtn.Text = "-"; minimizeBtn.TextSize = 20
            logo.Text = "⚡ RYZEN PREMIUM v3.5"; logo.TextSize = 20
        end
    end)

    local resizer = Instance.new("TextButton")
    resizer.Size = UDim2.new(0, 18, 0, 18)
    resizer.Position = UDim2.new(1, -20, 1, -20)
    resizer.BackgroundColor3 = Config.Colors.Accent
    resizer.BackgroundTransparency = 0.4
    resizer.Text = ""
    resizer.BorderSizePixel = 0
    resizer.ZIndex = 10
    resizer.Parent = main
    Instance.new("UICorner", resizer).CornerRadius = UDim.new(0, 4)

    for i = 1, 3 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0, 2 + i * 2, 0, 2)
        line.Position = UDim2.new(1, -4 - i * 3, 1, -4 - (4 - i) * 3)
        line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        line.BorderSizePixel = 0
        line.ZIndex = 11
        line.Parent = resizer
    end

    local resizing = false
    local startSize, startMouse
    resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true; startSize = main.Size; startMouse = input.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local dx = input.Position.X - startMouse.X
            local dy = input.Position.Y - startMouse.Y
            main.Size = UDim2.new(0, math.clamp(startSize.X.Offset + dx, 400, 1400), 0, math.clamp(startSize.Y.Offset + dy, 300, 1000))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
    end)

    local function Section(parent, text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 28)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Config.Colors.Accent
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
    end

    local function Toggle(parent, name, key, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.BackgroundColor3 = Config[key] and Color3.fromRGB(45, 28, 65) or Color3.fromRGB(30, 24, 40)
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.Position = UDim2.new(1, -26, 0.5, -8)
        dot.BackgroundColor3 = Config[key] and (color or Config.Colors.Accent) or Color3.fromRGB(80, 70, 100)
        dot.BorderSizePixel = 0
        dot.Parent = btn
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -50, 1, 0)
        lbl.Position = UDim2.new(0, 14, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.TextColor3 = color or Color3.fromRGB(220, 215, 240)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = btn
        btn.MouseButton1Click:Connect(function()
            Config[key] = not Config[key]
            btn.BackgroundColor3 = Config[key] and Color3.fromRGB(45, 28, 65) or Color3.fromRGB(30, 24, 40)
            dot.BackgroundColor3 = Config[key] and (color or Config.Colors.Accent) or Color3.fromRGB(80, 70, 100)
            if callback then callback(Config[key]) end
        end)
    end

    local function Button(parent, name, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3 = Color3.fromRGB(35, 28, 48)
        btn.BorderSizePixel = 0
        btn.Text = name
        btn.TextColor3 = color or Color3.fromRGB(230, 220, 250)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(100, 50, 160)}):Play()
            task.delay(0.15, function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 28, 48)}):Play()
            end)
            callback()
        end)
    end

    local function Slider(parent, name, key, min, max, callback)
        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, 0, 0, 50)
        holder.BackgroundColor3 = Color3.fromRGB(30, 24, 40)
        holder.BorderSizePixel = 0
        holder.Parent = parent
        Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 8)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, 22)
        lbl.Position = UDim2.new(0, 12, 0, 2)
        lbl.BackgroundTransparency = 1
        lbl.Text = name .. ": " .. tostring(Config[key])
        lbl.TextColor3 = Color3.fromRGB(220, 215, 240)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = holder
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -24, 0, 6)
        bar.Position = UDim2.new(0, 12, 0, 32)
        bar.BackgroundColor3 = Color3.fromRGB(50, 42, 65)
        bar.BorderSizePixel = 0
        bar.Parent = holder
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((Config[key] - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Config.Colors.Accent
        fill.BorderSizePixel = 0
        fill.Parent = bar
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        local dragging = false
        local function update(input)
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            Config[key] = val
            lbl.Text = name .. ": " .. tostring(val)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            if callback then callback(val) end
        end
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
    end

    -- ESP PAGE
    Section(pages.ESP, "▸ ОСНОВНОЕ")
    Toggle(pages.ESP, "ESP вкл/выкл", "Enabled", Color3.fromRGB(255, 220, 0))
    Toggle(pages.ESP, "Подсветка тел (Chams)", "ShowChams", Color3.fromRGB(255, 100, 200))
    Toggle(pages.ESP, "Скелет", "ShowSkeleton", Color3.fromRGB(200, 200, 255))
    Toggle(pages.ESP, "Трассеры", "ShowTracer", Color3.fromRGB(255, 200, 100))
    Section(pages.ESP, "▸ ФИЛЬТРЫ")
    Toggle(pages.ESP, "● Игроки (зелёные)", "ShowPlayers", Color3.fromRGB(0, 255, 0))
    Toggle(pages.ESP, "● Зомби (синие)", "ShowZombies", Color3.fromRGB(0, 150, 255))
    Toggle(pages.ESP, "● Прочие (красные)", "ShowOthers", Color3.fromRGB(255, 0, 0))
    Toggle(pages.ESP, "● Оружие на земле", "ShowWeapons", Color3.fromRGB(180, 0, 255))
    Section(pages.ESP, "▸ ИНФО")
    Toggle(pages.ESP, "Имена", "ShowName")
    Toggle(pages.ESP, "Здоровье", "ShowHealth")
    Toggle(pages.ESP, "Дистанция", "ShowDistance")
    Toggle(pages.ESP, "Боксы", "ShowBox")
    Slider(pages.ESP, "Max Distance", "MaxDistance", 100, 5000)

    -- AIMBOT PAGE
    Section(pages.Aimbot, "▸ ОСНОВНОЕ")
    Toggle(pages.Aimbot, "Aimbot вкл/выкл (E)", "AimbotEnabled", Color3.fromRGB(255, 80, 80))
    Toggle(pages.Aimbot, "Проверка видимости", "AimbotVisibleCheck")
    Section(pages.Aimbot, "▸ ЦЕЛИ")
    Toggle(pages.Aimbot, "Игроки", "AimbotTargetPlayers", Color3.fromRGB(0, 255, 0))
    Toggle(pages.Aimbot, "Зомби", "AimbotTargetZombies", Color3.fromRGB(0, 150, 255))
    Toggle(pages.Aimbot, "Прочие", "AimbotTargetOthers", Color3.fromRGB(255, 0, 0))
    Section(pages.Aimbot, "▸ НАСТРОЙКИ")
    Slider(pages.Aimbot, "FOV", "AimbotFOV", 20, 800)
    Slider(pages.Aimbot, "Smooth", "AimbotSmooth", 1, 100, function(v) Config.AimbotSmooth = v / 100 end)
    Config.AimbotSmooth = 0.15

    -- FLY PAGE
    Section(pages.Fly, "▸ FLY")
    Toggle(pages.Fly, "✈ Fly вкл/выкл", "FlyEnabled", Color3.fromRGB(0, 255, 200))
    Slider(pages.Fly, "Speed", "FlySpeed", 10, 300)
    Section(pages.Fly, "▸ NOCLIP")
    Toggle(pages.Fly, "🚪 Noclip вкл/выкл", "NoclipEnabled", Color3.fromRGB(255, 200, 0))
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 60)
    info.BackgroundTransparency = 1
    info.Text = "WASD — движение\nSpace — вверх / LeftCtrl — вниз\nNoclip — проход через стены"
    info.TextColor3 = Color3.fromRGB(150, 140, 180)
    info.Font = Enum.Font.Gotham
    info.TextSize = 12
    info.TextWrapped = true
    info.Parent = pages.Fly

    -- TELEPORT PAGE
    Section(pages.Teleport, "▸ ТЕЛЕПОРТ К ИГРОКАМ")
    Button(pages.Teleport, "👤 TP к ближайшему игроку", Color3.fromRGB(0, 255, 100), function()
        TeleportToNearestPlayer()
    end)

    Section(pages.Teleport, "▸ БЫСТРЫЙ ТП")
    Button(pages.Teleport, "🚀 ПРОЙТИ ВСЕ ТОЧКИ ПО ОЧЕРЕДИ", Color3.fromRGB(255, 100, 255), function()
        TeleportAllSpots()
    end)
    Button(pages.Teleport, "📦 TP к ближайшему оружию", Color3.fromRGB(180, 0, 255), function()
        local w = GetNearestWeapon()
        if w then
            local handle = w:FindFirstChild("Handle")
            if handle then TeleportToPosition(handle.Position) end
        end
    end)
    Button(pages.Teleport, "🎲 TP к случайному оружию", Color3.fromRGB(255, 120, 255), function()
        local list = GetGroundWeapons()
        if #list > 0 then
            local pick = list[math.random(1, #list)]
            local handle = pick:FindFirstChild("Handle")
            if handle then TeleportToPosition(handle.Position) end
        end
    end)

    Section(pages.Teleport, "▸ ТОЧКИ СПАВНА ОРУЖИЯ")
    for i, spot in ipairs(WEAPON_SPOTS) do
        Button(pages.Teleport, spot.name, Color3.fromRGB(180, 0, 255), function()
            TeleportToPosition(spot.pos)
        end)
    end

    -- FPS BOOST PAGE (Misc)
    Section(pages.Misc, "▸ FPS BOOST")
    Toggle(pages.Misc, "🚀 FPS BOOST вкл/выкл", "FPSBoostEnabled", Color3.fromRGB(255, 200, 0), function(state)
        if state then EnableFPSBoost() else DisableFPSBoost() end
    end)
    Button(pages.Misc, "⚡ ВКЛЮЧИТЬ FPS BOOST СЕЙЧАС", Color3.fromRGB(255, 200, 0), function()
        Config.FPSBoostEnabled = true
        EnableFPSBoost()
    end)
    Button(pages.Misc, "🔄 ВЫКЛЮЧИТЬ FPS BOOST", Color3.fromRGB(100, 200, 255), function()
        Config.FPSBoostEnabled = false
        DisableFPSBoost()
    end)

    local fpsInfo = Instance.new("TextLabel")
    fpsInfo.Size = UDim2.new(1, 0, 0, 65)
    fpsInfo.BackgroundTransparency = 1
    fpsInfo.Text = "Отключает тени, частицы, текстуры, пост-эффекты.\nМатериалы заменены на Plastic.\nРаботает на слабых ПК."
    fpsInfo.TextColor3 = Color3.fromRGB(150, 140, 180)
    fpsInfo.Font = Enum.Font.Gotham
    fpsInfo.TextSize = 11
    fpsInfo.TextWrapped = true
    fpsInfo.TextYAlignment = Enum.TextYAlignment.Top
    fpsInfo.Parent = pages.Misc

    Section(pages.Misc, "▸ ИНФО")
    local stats = Instance.new("TextLabel")
    stats.Size = UDim2.new(1, 0, 0, 140)
    stats.BackgroundColor3 = Color3.fromRGB(30, 24, 40)
    stats.BorderSizePixel = 0
    stats.Text = "Загрузка..."
    stats.TextColor3 = Color3.fromRGB(220, 215, 240)
    stats.Font = Enum.Font.Gotham
    stats.TextSize = 12
    stats.TextXAlignment = Enum.TextXAlignment.Left
    stats.TextYAlignment = Enum.TextYAlignment.Top
    stats.Parent = pages.Misc
    Instance.new("UICorner", stats).CornerRadius = UDim.new(0, 8)
    Instance.new("UIPadding", stats).PaddingLeft = UDim.new(0, 12)
    Instance.new("UIPadding", stats).PaddingTop = UDim.new(0, 8)

    task.spawn(function()
        local lastT = tick()
        local frames = 0
        RunService.RenderStepped:Connect(function()
            frames = frames + 1
        end)
        while task.wait(0.5) do
            local count = 0
            for _ in pairs(Cache.ESP) do count += 1 end
            local wcount = #GetGroundWeapons()
            local now = tick()
            local fps = math.floor(frames / (now - lastT))
            frames = 0
            lastT = now
            stats.Text = string.format(
                "Сущностей в ESP: %d\nОружий на земле: %d\nFPS: ~%d\nПинг: %d ms\nFPS BOOST: %s\nТочек спавна: %d",
                count, wcount, fps,
                math.floor(LocalPlayer:GetNetworkPing() * 1000),
                FPSBoost.Active and "ВКЛ" or "ВЫКЛ",
                #WEAPON_SPOTS
            )
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            main.Visible = not main.Visible
        end
    end)
end

-- ============ ОТСЛЕЖИВАНИЕ ============
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        task.wait(0.5); CreateESP(c)
        if Config.ShowChams then CreateHighlight(c) end
    end)
end)
Players.PlayerRemoving:Connect(function(p)
    if p.Character then RemoveESP(p.Character) end
end)
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Humanoid") then
        task.wait(0.1)
        local m = obj.Parent
        if m and m:IsA("Model") then
            CreateESP(m); if Config.ShowChams then CreateHighlight(m) end
        end
    elseif obj:IsA("Tool") then
        task.wait(0.1); CreateWeaponESP(obj)
    end
end)
workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("Tool") then RemoveWeaponESP(obj) end
    if obj:IsA("Model") then RemoveESP(obj) end
end)

-- ============ ЗАПУСК ============
CreateUI()
ScanEntities()

task.spawn(function()
    while task.wait(1) do if Config.Enabled then ScanEntities() end end
end)

local frameSkip = 0
RunService.RenderStepped:Connect(function()
    if not Config.Enabled then return end
    frameSkip = frameSkip + 1
    if frameSkip % 2 == 0 or next(Cache.ESP) == nil then
        UpdateEntityESP()
    end
    UpdateWeaponESP()
end)

RunService.RenderStepped:Connect(function()
    UpdateFOVCircle()
    if not Config.AimbotEnabled then return end
    if not UserInputService:IsKeyDown(Config.AimbotKey) then return end
    local target = GetClosestTarget()
    if not target then return end
    local camPos = Camera.CFrame.Position
    local newCF = CFrame.new(camPos, target.root.Position)
    if Config.AimbotSmooth < 1 then
        Camera.CFrame = Camera.CFrame:Lerp(newCF, Config.AimbotSmooth)
    else
        Camera.CFrame = newCF
    end
end)

RunService.Heartbeat:Connect(UpdateFly)
RunService.Heartbeat:Connect(UpdateNoclip)

LocalPlayer.CharacterAdded:Connect(function()
    StopFly()
    task.wait(1)
    if Config.FlyEnabled then StartFly() end
end)

print("[Ryzen Premium v3.5 FULL] Загружен. ESP + Aimbot + Fly + Noclip + TP + FPS Boost")