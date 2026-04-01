local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G SafeCheat | V10 GOLD EDITION",
   LoadingTitle = "Gokalp Premium Hub",
   LoadingSubtitle = "by Gemini (V10.0)",
   ConfigurationSaving = { Enabled = false },
   Theme = "Default" -- Buradan temayı değiştirebilirsin
})

-- AYARLAR
local Settings = {
    EspEnabled = false,
    TracerEnabled = false,
    BoxColor = Color3.fromRGB(255, 215, 0), -- Gold Rengi
    Names = false,
    AimbotEnabled = false,
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
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ESP ÇİZİM FONKSİYONU (Box + Tracer)
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    local Tracer = Drawing.new("Line")
    local NameTag = Drawing.new("Text")
    
    RS.RenderStepped:Connect(function()
        if Settings.EspEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local Root = Player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            
            if OnScreen then
                local SizeY = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 2.6, 0)).Y)
                local SizeX = SizeY * 0.6
                
                -- Box
                Box.Visible = true
                Box.Color = Settings.BoxColor
                Box.Size = Vector2.new(SizeX, SizeY)
                Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
                Box.Thickness = 1
                Box.Filled = false
                
                -- Tracer (Çizgi)
                if Settings.TracerEnabled then
                    Tracer.Visible = true
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(Pos.X, Pos.Y + (SizeY / 2))
                    Tracer.Color = Settings.BoxColor
                    Tracer.Thickness = 1
                else Tracer.Visible = false end

                -- Name
                if Settings.Names then
                    NameTag.Visible = true
                    NameTag.Text = Player.Name
                    NameTag.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 15)
                    NameTag.Center = true
                    NameTag.Outline = true
                    NameTag.Size = 14
                else NameTag.Visible = false end
            else Box.Visible = false Tracer.Visible = false NameTag.Visible = false end
        else Box.Visible = false Tracer.Visible = false NameTag.Visible = false end
    end)
end

-- FOV ÇEMBERİ
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)

-- ANA DÖNGÜ (QoL Fixes)
RS.RenderStepped:Connect(function()
    -- FOV Fix
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Radius = Settings.FovRadius
    FovCircle.Visible = Settings.ShowFov

    -- Aimbot Lock
    if Settings.AimbotEnabled then
        local Target = nil
        local Dist = Settings.FovRadius
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
                local Pos, On = Camera:WorldToViewportPoint(v.Character[Settings.AimPart].Position)
                local Mag = (Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) - Vector2.new(Pos.X, Pos.Y)).Magnitude
                if Mag < Dist and On then Target = v Dist = Mag end
            end
        end
        if Target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, Target.Character[Settings.AimPart].Position), Settings.Smoothness)
        end
    end

    -- FullBright (Gece Görüşü)
    if Settings.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end

    -- Karakter Fix (Speed & Jump)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = Settings.JumpPower
    end

    -- Noclip & Fly Logic
    if Settings.FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local BPV = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlyV") or Instance.new("BodyVelocity", LocalPlayer.Character.HumanoidRootPart)
        BPV.Name = "FlyV"
        BPV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BPV.Velocity = Camera.CFrame.LookVector * Settings.FlySpeed
    end
end)

-- BAŞLAT
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- GUI SEKMELERİ
local VisualTab = Window:CreateTab("Görsel (ESP/World)")
local CombatTab = Window:CreateTab("Savaş (Combat)")
local MiscTab = Window:CreateTab("Karakter (Movement)")

-- GÖRSEL
VisualTab:CreateSection("ESP Ayarları")
VisualTab:CreateToggle({Name = "İçi Boş Box ESP", CurrentValue = false, Callback = function(v) Settings.EspEnabled = v end})
VisualTab:CreateToggle({Name = "Tracer (Çizgiler)", CurrentValue = false, Callback = function(v) Settings.TracerEnabled = v end})
VisualTab:CreateToggle({Name = "İsimleri Göster", CurrentValue = false, Callback = function(v) Settings.Names = v end})
VisualTab:CreateColorPicker({Name = "ESP/Tema Rengi", Color = Settings.BoxColor, Callback = function(v) Settings.BoxColor = v end})

VisualTab:CreateSection("Dünya Ayarları")
VisualTab:CreateToggle({Name = "FullBright (Gece Görüşü)", CurrentValue = false, Callback = function(v) Settings.FullBright = v end})

-- SAVAŞ
CombatTab:CreateSection("Aimbot")
CombatTab:CreateToggle({Name = "Aimbot Lock", CurrentValue = false, Callback = function(v) Settings.AimbotEnabled = v end})
CombatTab:CreateToggle({Name = "FOV Göster", CurrentValue = false, Callback = function(v) Settings.ShowFov = v end})
CombatTab:CreateSlider({Name = "FOV Çapı", Range = {50, 800}, Increment = 10, CurrentValue = 150, Callback = function(v) Settings.FovRadius = v end})
CombatTab:CreateSlider({Name = "Smoothness (Yumuşaklık)", Range = {1, 10}, Increment = 1, CurrentValue = 1, Callback = function(v) Settings.Smoothness = v/10 end})

-- KARAKTER
MiscTab:CreateSection("Hareket Ayarları")
MiscTab:CreateSlider({Name = "Yürüme Hızı", Range = {16, 300}, Increment = 1, CurrentValue = 16, Callback = function(v) Settings.WalkSpeed = v end})
MiscTab:CreateSlider({Name = "Zıplama Gücü", Range = {50, 500}, Increment = 1, CurrentValue = 50, Callback = function(v) Settings.JumpPower = v end})

MiscTab:CreateSection("Özel Yetenekler")
MiscTab:CreateToggle({Name = "Uçma (Fly)", CurrentValue = false, Callback = function(v) Settings.FlyEnabled = v end})
MiscTab:CreateSlider({Name = "Uçma Hızı", Range = {10, 500}, Increment = 10, CurrentValue = 50, Callback = function(v) Settings.FlySpeed = v end})
MiscTab:CreateToggle({Name = "Noclip (Duvar Geçme)", CurrentValue = false, Callback = function(v) Settings.NoclipEnabled = v end})

Rayfield:Notify({Title = "G&G SafeCheat GOLD", Content = "V10 Gold Edition Başarıyla Yüklendi! İyi Oyunlar Gokalp."})
