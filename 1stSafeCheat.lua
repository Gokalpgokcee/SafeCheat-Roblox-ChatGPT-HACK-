local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G SafeCheat | V7 PRO",
   LoadingTitle = "Gokalp Premium System",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

-- AYARLAR (Tam İstediğin Format)
local Settings = {
    EspEnabled = false,
    BoxColor = Color3.fromRGB(0, 255, 0),
    Names = false,
    AimbotEnabled = false,
    FovRadius = 100,
    ShowFov = false,
    Smoothness = 0.1, -- Kilitlenme hızı
    AimPart = "HumanoidRootPart"
}

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV ÇEMBERİ (EKRANIN TAM ORTASINA SABİT)
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Filled = false -- İÇİ BOŞ
FovCircle.Visible = false

-- İÇİ BOŞ BOX ESP
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    local NameTag = Drawing.new("Text")
    
    RS.RenderStepped:Connect(function()
        if Settings.EspEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local Root = Player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)

            if OnScreen then
                local SizeY = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 2.6, 0)).Y)
                local SizeX = SizeY * 0.6

                Box.Visible = true
                Box.Color = Settings.BoxColor
                Box.Size = Vector2.new(SizeX, SizeY)
                Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
                Box.Filled = false -- İÇİ KESİNLİKLE BOŞ
                Box.Thickness = 1

                if Settings.Names then
                    NameTag.Visible = true
                    NameTag.Text = Player.Name
                    NameTag.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 15)
                    NameTag.Center = true
                    NameTag.Outline = true
                    NameTag.Size = 14
                else NameTag.Visible = false end
            else
                Box.Visible = false
                NameTag.Visible = false
            end
        else
            Box.Visible = false
            NameTag.Visible = false
        end
    end)
end

-- AIMBOT HEDEF SEÇİCİ
local function GetClosest()
    local Target = nil
    local Dist = Settings.FovRadius
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
            local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character[Settings.AimPart].Position)
            local Mag = (Center - Vector2.new(Pos.X, Pos.Y)).Magnitude
            if Mag < Dist and OnScreen then
                Target = v
                Dist = Mag
            end
        end
    end
    return Target
end

-- ANA DÖNGÜ (KİLİTLENME VE FOV)
RS.RenderStepped:Connect(function()
    -- FOV'u ekranın matematiksel ortasına sabitle
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Position = Center
    FovCircle.Radius = Settings.FovRadius
    FovCircle.Visible = Settings.ShowFov

    -- KİLİTLENEN AIMBOT (MOUSEMOVEREL DEĞİL, DIRECT LOCK)
    if Settings.AimbotEnabled then
        local T = GetClosest()
        if T then
            local TargetPos = T.Character[Settings.AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPos), Settings.Smoothness)
        end
    end
end)

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- GUI SEKMELERİ
local VisualTab = Window:CreateTab("Görsel")
local CombatTab = Window:CreateTab("Savaş")

VisualTab:CreateToggle({Name = "İçi Boş ESP", CurrentValue = false, Callback = function(v) Settings.EspEnabled = v end})
VisualTab:CreateColorPicker({Name = "ESP Rengi", Color = Settings.BoxColor, Callback = function(v) Settings.BoxColor = v end})
VisualTab:CreateToggle({Name = "İsimleri Göster", CurrentValue = false, Callback = function(v) Settings.Names = v end})

CombatTab:CreateToggle({Name = "Aimbot (Kilitlenme)", CurrentValue = false, Callback = function(v) Settings.AimbotEnabled = v end})
CombatTab:CreateToggle({Name = "FOV Göster (Sabit)", CurrentValue = false, Callback = function(v) Settings.ShowFov = v end})
CombatTab:CreateSlider({Name = "FOV Çapı", Range = {50, 600}, Increment = 10, CurrentValue = 100, Callback = function(v) Settings.FovRadius = v end})
CombatTab:CreateSlider({Name = "Kilitlenme Hızı", Range = {1, 10}, Increment = 1, CurrentValue = 2, Callback = function(v) Settings.Smoothness = v/10 end})

Rayfield:Notify({Title = "G&G SafeCheat", Content = "V7 Yüklendi! Link Artık Çalışıyor."})
