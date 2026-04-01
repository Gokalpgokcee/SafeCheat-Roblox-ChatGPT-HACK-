local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G SafeCheat | V8 ULTIMATE",
   LoadingTitle = "Gokalp Premium Systems",
   LoadingSubtitle = "by Gemini (V8.0)",
   ConfigurationSaving = { Enabled = false }
})

-- AYARLAR
local Settings = {
    EspEnabled = false,
    BoxColor = Color3.fromRGB(0, 255, 0),
    Names = false,
    AimbotEnabled = false,
    FovRadius = 150,
    ShowFov = false,
    Smoothness = 0.1, -- 0.1 hızlı, 0.5 yavaş kilitlenir
    AimPart = "HumanoidRootPart"
}

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV ÇEMBERİ (EKRAN ORTASINA ÇAKILI)
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Filled = false
FovCircle.Visible = false

-- İÇİ BOŞ ÇERÇEVE ESP
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
                Box.Filled = false -- İÇİ BOŞ
                Box.Thickness = 1

                if Settings.Names then
                    NameTag.Visible = true
                    NameTag.Text = Player.Name
                    NameTag.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 15)
                    NameTag.Center = true
                    NameTag.Outline = true
                    NameTag.Size = 14
                    NameTag.Color = Color3.new(1,1,1)
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

-- EN YAKIN HEDEFİ BUL (EKRAN ORTASINA GÖRE)
local function GetClosestToCenter()
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

-- ANA DÖNGÜ (AIMBOT & FOV FIX)
RS.RenderStepped:Connect(function()
    -- FOV'u Her Karede Ortala
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Position = Center
    FovCircle.Radius = Settings.FovRadius
    FovCircle.Visible = Settings.ShowFov

    -- KİLİTLENEN AIMBOT
    if Settings.AimbotEnabled then
        local T = GetClosestToCenter()
        if T then
            local TPos = T.Character[Settings.AimPart].Position
            -- Kamerayı Doğrudan Hedefe Kaydır (Lock-on)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TPos), Settings.Smoothness)
        end
    end
end)

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- GUI SEKMELERİ
local VisualTab = Window:CreateTab("Görsel (ESP)")
local CombatTab = Window:CreateTab("Savaş (AIM)")

VisualTab:CreateToggle({Name = "İçi Boş Box ESP", CurrentValue = false, Callback = function(v) Settings.EspEnabled = v end})
VisualTab:CreateColorPicker({Name = "Kutu Rengi", Color = Settings.BoxColor, Callback = function(v) Settings.BoxColor = v end})
VisualTab:CreateToggle({Name = "İsim Göster", CurrentValue = false, Callback = function(v) Settings.Names = v end})

CombatTab:CreateToggle({Name = "Aimbot Kilitlenme", CurrentValue = false, Callback = function(v) Settings.AimbotEnabled = v end})
CombatTab:CreateToggle({Name = "FOV Çemberi (Sabit)", CurrentValue = false, Callback = function(v) Settings.ShowFov = v end})
CombatTab:CreateSlider({Name = "FOV Çapı", Range = {50, 800}, Increment = 10, CurrentValue = 150, Callback = function(v) Settings.FovRadius = v end})
CombatTab:CreateSlider({Name = "Kilitlenme Hızı", Range = {1, 10}, Increment = 1, CurrentValue = 2, Callback = function(v) Settings.Smoothness = v/10 end})

Rayfield:Notify({Title = "G&G SafeCheat", Content = "V8 PRO Başarıyla Hazırlandı!"})
