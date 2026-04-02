local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G SafeCheat | V11 ELITE EDITION",
   LoadingTitle = "Gokalp Elite Hub",
   LoadingSubtitle = "by Gemini (V11.0)",
   ConfigurationSaving = { Enabled = false },
   Theme = "Default"
})

-- AYARLAR
local Settings = {
    EspEnabled = false,
    TracerEnabled = false,
    Names = false,
    Distances = false, -- Mesafe Gösterimi
    Health = false,    -- Can Gösterimi
    BoxColor = Color3.fromRGB(0, 255, 0),
    AimbotEnabled = false,
    WallCheck = true,  -- Duvar Kontrolü
    FovRadius = 150,
    ShowFov = false,
    Smoothness = 0.1,
    AimPart = "HumanoidRootPart",
    WalkSpeed = 16,
    JumpPower = 50,
    FlyEnabled = false,
    FlySpeed = 50,
    NoclipEnabled = false,
    FullBright = false
}

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV ÇEMBERİ (TAM ŞEFFAF)
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Filled = false -- İçini boşaltıyoruz
FovCircle.Transparency = 1

-- WALL CHECK FONKSİYONU
local function IsVisible(TargetPart)
    if not Settings.WallCheck then return true end
    local Character = LocalPlayer.Character
    if not Character then return false end
    
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {Character, TargetPart.Parent}
    
    local Direction = (TargetPart.Position - Camera.CFrame.Position).Unit * (TargetPart.Position - Camera.CFrame.Position).Magnitude
    local Result = workspace:Raycast(Camera.CFrame.Position, Direction, Params)
    
    return Result == nil -- Eğer arada bir engel yoksa True döner
end

-- ESP SİSTEMİ (DYNAMIC TRACERS & DISTANCE)
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    local Tracer = Drawing.new("Line")
    local InfoTag = Drawing.new("Text")
    
    RS.RenderStepped:Connect(function()
        if Settings.EspEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local Root = Player.Character.HumanoidRootPart
            local Hum = Player.Character:FindFirstChild("Humanoid")
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            
            if OnScreen then
                local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude
                local SizeY = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 2.6, 0)).Y)
                local SizeX = SizeY * 0.6
                
                -- DINAMIK RENK GEÇİŞİ (Yeşil -> Kırmızı)
                -- 0m = Kırmızı, 100m+ = Yeşil
                local ColorFactor = math.clamp(Distance / 150, 0, 1)
                local DynamicColor = Color3.fromHSV(ColorFactor * 0.33, 1, 1) -- 0.33 (Yeşil) - 0 (Kırmızı)
                
                -- Box
                Box.Visible = true
                Box.Color = Settings.BoxColor
                Box.Size = Vector2.new(SizeX, SizeY)
                Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
                Box.Filled = false
                
                -- Tracer (Dinamik Renkli)
                if Settings.TracerEnabled then
                    Tracer.Visible = true
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(Pos.X, Pos.Y + (SizeY / 2))
                    Tracer.Color = DynamicColor
                    Tracer.Thickness = 1
                else Tracer.Visible = false end

                -- Info (Name, Dist, Health)
                local DisplayText = ""
                if Settings.Names then DisplayText = DisplayText .. Player.Name .. "\n" end
                if Settings.Distances then DisplayText = DisplayText .. "[" .. math.floor(Distance) .. "m]\n" end
                if Settings.Health and Hum then DisplayText = DisplayText .. "HP: " .. math.floor(Hum.Health) end
                
                if DisplayText ~= "" then
                    InfoTag.Visible = true
                    InfoTag.Text = DisplayText
                    InfoTag.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 25)
                    InfoTag.Center = true
                    InfoTag.Outline = true
                    InfoTag.Size = 13
                else InfoTag.Visible = false end
            else Box.Visible = false Tracer.Visible = false InfoTag.Visible = false end
        else Box.Visible = false Tracer.Visible = false InfoTag.Visible = false end
    end)
end

-- AIMBOT (WALL CHECK ENTEGRELİ)
local function GetClosest()
    local Target = nil
    local Dist = Settings.FovRadius
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
            local Part = v.Character[Settings.AimPart]
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            local Mag = (Center - Vector2.new(Pos.X, Pos.Y)).Magnitude
            
            if Mag < Dist and OnScreen then
                if IsVisible(Part) then -- DUVAR KONTROLÜ BURADA
                    Target = v
                    Dist = Mag
                end
            end
        end
    end
    return Target
end

-- ANA DÖNGÜ
RS.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Radius = Settings.FovRadius
    FovCircle.Visible = Settings.ShowFov

    if Settings.AimbotEnabled then
        local T = GetClosest()
        if T then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character[Settings.AimPart].Position), Settings.Smoothness)
        end
    end

    if Settings.FullBright then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
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
VisualTab:CreateToggle({Name = "Tracer (Dinamik Renk)", CurrentValue = false, Callback = function(v) Settings.TracerEnabled = v end})
VisualTab:CreateToggle({Name = "İsimleri Göster", CurrentValue = false, Callback = function(v) Settings.Names = v end})
VisualTab:CreateToggle({Name = "Mesafe Göster", CurrentValue = false, Callback = function(v) Settings.Distances = v end})
VisualTab:CreateToggle({Name = "Can (Health) Göster", CurrentValue = false, Callback = function(v) Settings.Health = v end})

CombatTab:CreateSection("Aimbot")
CombatTab:CreateToggle({Name = "Aimbot Lock", CurrentValue = false, Callback = function(v) Settings.AimbotEnabled = v end})
CombatTab:CreateToggle({Name = "Duvar Kontrolü (WallCheck)", CurrentValue = true, Callback = function(v) Settings.WallCheck = v end})
CombatTab:CreateToggle({Name = "FOV Göster", CurrentValue = false, Callback = function(v) Settings.ShowFov = v end})
CombatTab:CreateSlider({Name = "FOV Çapı", Range = {50, 800}, Increment = 10, CurrentValue = 150, Callback = function(v) Settings.FovRadius = v end})

MiscTab:CreateSection("Hileler")
MiscTab:CreateSlider({Name = "Hız", Range = {16, 300}, Increment = 1, CurrentValue = 16, Callback = function(v) Settings.WalkSpeed = v end})
MiscTab:CreateToggle({Name = "Uçma (Fly)", CurrentValue = false, Callback = function(v) Settings.FlyEnabled = v end})
MiscTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Settings.NoclipEnabled = v end})

Rayfield:Notify({Title = "G&G SafeCheat ELITE", Content = "V11 Elite Edition Aktif! Duvar Kontrolü ve Dinamik Tracers Hazır."})
