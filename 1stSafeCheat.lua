local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G SafeCheat | V12 GOD MODE",
   LoadingTitle = "Gokalp Ultimate System",
   LoadingSubtitle = "by Gemini (V12.0)",
   ConfigurationSaving = { Enabled = false }
})

-- AYARLAR
local Settings = {
    EspEnabled = false,
    TracerEnabled = false,
    Names = false,
    Distances = false,
    HealthBar = false, -- Yeni Health Bar
    BoxColor = Color3.fromRGB(0, 255, 0),
    AimbotEnabled = false,
    WallCheck = true,
    FovRadius = 150,
    ShowFov = false,
    Smoothness = 0.2, -- Yumuşaklık Geri Geldi
    AimPart = "HumanoidRootPart",
    WalkSpeed = 16,
    FlyEnabled = false,
    FlySpeed = 50,
    NoclipEnabled = false
}

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV ÇEMBERİ FIX (Kesin Görünür)
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Filled = false
FovCircle.Transparency = 1
FovCircle.Visible = false

-- WALL CHECK
local function IsVisible(TargetPart)
    if not Settings.WallCheck then return true end
    local Character = LocalPlayer.Character
    if not Character then return false end
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {Character, TargetPart.Parent}
    local Direction = (TargetPart.Position - Camera.CFrame.Position).Unit * (TargetPart.Position - Camera.CFrame.Position).Magnitude
    local Result = workspace:Raycast(Camera.CFrame.Position, Direction, Params)
    return Result == nil
end

-- PRO ESP (BOX, TRACER, HEALTH BAR)
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    local Tracer = Drawing.new("Line")
    local InfoTag = Drawing.new("Text")
    local HealthBarOutline = Drawing.new("Square")
    local HealthBar = Drawing.new("Square")
    
    RS.RenderStepped:Connect(function()
        if Settings.EspEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local Root = Player.Character.HumanoidRootPart
            local Hum = Player.Character:FindFirstChild("Humanoid")
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            
            if OnScreen and Hum then
                local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude
                local SizeY = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 2.6, 0)).Y)
                local SizeX = SizeY * 0.6
                
                -- Box
                Box.Visible = true
                Box.Color = Settings.BoxColor
                Box.Size = Vector2.new(SizeX, SizeY)
                Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
                Box.Thickness = 1
                Box.Filled = false
                
                -- Dynamic Tracer
                if Settings.TracerEnabled then
                    local ColorFactor = math.clamp(Distance / 200, 0, 1)
                    Tracer.Visible = true
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(Pos.X, Pos.Y + (SizeY / 2))
                    Tracer.Color = Color3.fromHSV(ColorFactor * 0.33, 1, 1)
                    Tracer.Thickness = 1
                else Tracer.Visible = false end

                -- HEALTH BAR (PRO SİSTEM)
                if Settings.HealthBar then
                    local HealthPercent = Hum.Health / Hum.MaxHealth
                    local BarHeight = SizeY
                    local BarPos = Vector2.new(Pos.X - (SizeX / 2) - 6, Pos.Y - (SizeY / 2))
                    
                    HealthBarOutline.Visible = true
                    HealthBarOutline.Size = Vector2.new(3, BarHeight)
                    HealthBarOutline.Position = BarPos
                    HealthBarOutline.Color = Color3.new(0,0,0)
                    HealthBarOutline.Filled = true
                    
                    HealthBar.Visible = true
                    HealthBar.Size = Vector2.new(2, BarHeight * HealthPercent)
                    HealthBar.Position = Vector2.new(BarPos.X + 0.5, BarPos.Y + (BarHeight * (1 - HealthPercent)))
                    HealthBar.Color = Color3.fromHSV(HealthPercent * 0.33, 1, 1)
                    HealthBar.Filled = true
                else
                    HealthBar.Visible = false
                    HealthBarOutline.Visible = false
                end

                -- INFO (Name & Distance & HP Number)
                local DisplayText = ""
                if Settings.Names then DisplayText = DisplayText .. Player.Name .. "\n" end
                if Settings.Distances then DisplayText = DisplayText .. math.floor(Distance) .. "m\n" end
                if Settings.HealthBar then DisplayText = DisplayText .. "HP: " .. math.floor(Hum.Health) end
                
                if DisplayText ~= "" then
                    InfoTag.Visible = true
                    InfoTag.Text = DisplayText
                    InfoTag.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 25)
                    InfoTag.Center = true
                    InfoTag.Outline = true
                    InfoTag.Size = 13
                else InfoTag.Visible = false end
            else
                Box.Visible = false Tracer.Visible = false InfoTag.Visible = false HealthBar.Visible = false HealthBarOutline.Visible = false
            end
        else
            Box.Visible = false Tracer.Visible = false InfoTag.Visible = false HealthBar.Visible = false HealthBarOutline.Visible = false
        end
    end)
end

-- AIMBOT
local function GetClosest()
    local Target = nil
    local Dist = Settings.FovRadius
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
            local Part = v.Character[Settings.AimPart]
            local Pos, On = Camera:WorldToViewportPoint(Part.Position)
            local Mag = (Center - Vector2.new(Pos.X, Pos.Y)).Magnitude
            if Mag < Dist and On and IsVisible(Part) then
                Target = v
                Dist = Mag
            end
        end
    end
    return Target
end

-- MAIN LOOP
RS.RenderStepped:Connect(function()
    -- FOV Fix
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Radius = Settings.FovRadius
    FovCircle.Visible = Settings.ShowFov

    -- Aimbot Smooth
    if Settings.AimbotEnabled then
        local T = GetClosest()
        if T then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character[Settings.AimPart].Position), Settings.Smoothness)
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
    end
end)

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- GUI
local VisualTab = Window:CreateTab("Görsel")
local CombatTab = Window:CreateTab("Savaş")
local MiscTab = Window:CreateTab("Karakter")

VisualTab:CreateSection("ESP Ayarları")
VisualTab:CreateToggle({Name = "Box ESP", CurrentValue = false, Callback = function(v) Settings.EspEnabled = v end})
VisualTab:CreateToggle({Name = "Dinamik Tracers", CurrentValue = false, Callback = function(v) Settings.TracerEnabled = v end})
VisualTab:CreateToggle({Name = "Profesyonel Health Bar", CurrentValue = false, Callback = function(v) Settings.HealthBar = v end})
VisualTab:CreateToggle({Name = "İsimleri Göster", CurrentValue = false, Callback = function(v) Settings.Names = v end})
VisualTab:CreateToggle({Name = "Mesafeyi Göster", CurrentValue = false, Callback = function(v) Settings.Distances = v end})

CombatTab:CreateSection("Aimbot")
CombatTab:CreateToggle({Name = "Aimbot Aktif", CurrentValue = false, Callback = function(v) Settings.AimbotEnabled = v end})
CombatTab:CreateToggle({Name = "Wall Check", CurrentValue = true, Callback = function(v) Settings.WallCheck = v end})
CombatTab:CreateSlider({Name = "Yumuşaklık (Smoothness)", Range = {1, 10}, Increment = 1, CurrentValue = 2, Callback = function(v) Settings.Smoothness = v/10 end})
CombatTab:CreateToggle({Name = "FOV Çemberini Göster", CurrentValue = false, Callback = function(v) Settings.ShowFov = v end})
CombatTab:CreateSlider({Name = "FOV Çapı", Range = {50, 800}, Increment = 10, CurrentValue = 150, Callback = function(v) Settings.FovRadius = v end})

MiscTab:CreateSlider({Name = "Hız", Range = {16, 300}, Increment = 1, CurrentValue = 16, Callback = function(v) Settings.WalkSpeed = v end})

Rayfield:Notify({Title = "G&G SafeCheat GOD", Content = "V12 Aktif! FOV düzeltildi, Smoothness geri geldi ve Health Bar eklendi."})
