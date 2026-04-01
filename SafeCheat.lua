local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G Premium | Mobile Edition",
   LoadingTitle = "Gokalp SafeCheat v3.0",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

-- AYARLAR TABLOSU (Dinamik Güncelleme İçin)
local Settings = {
    EspEnabled = false,
    BoxColor = Color3.fromRGB(0, 255, 0), -- Varsayılan Yeşil
    Names = false,
    Distances = false,
    AimbotEnabled = false,
    FovRadius = 100,
    ShowFov = false,
    Sensitivity = 0.2
}

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV ÇEMBERİ (Aimbot Alanı)
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Filled = false
FovCircle.Visible = false

-- PROFESYONEL ESP FONKSİYONU
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    local NameTag = Drawing.new("Text")
    
    local Connection
    Connection = RS.RenderStepped:Connect(function()
        if Settings.EspEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local Root = Player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)

            if OnScreen then
                local SizeY = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 2.6, 0)).Y)
                local SizeX = SizeY * 0.6

                -- KUTU GÜNCELLEME (Renk burada dinamik çekilir)
                Box.Visible = true
                Box.Color = Settings.BoxColor
                Box.Size = Vector2.new(SizeX, SizeY)
                Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
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
            if not Player.Parent then
                Box:Remove(); NameTag:Remove()
                Connection:Disconnect()
            end
        end
    end)
end

-- EN YAKIN OYUNCUYU BULMA (Aimbot İçin)
local function GetClosest()
    local Target = nil
    local Dist = Settings.FovRadius
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            local Mag = (Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude
            if Mag < Dist and OnScreen then
                Target = v
                Dist = Mag
            end
        end
    end
    return Target
end

-- ANA DÖNGÜ (Aimbot & FOV)
RS.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)
    FovCircle.Radius = Settings.FovRadius
    FovCircle.Visible = Settings.ShowFov

    if Settings.AimbotEnabled then
        local T = GetClosest()
        if T then
            local TPos = Camera:WorldToViewportPoint(T.Character.HumanoidRootPart.Position)
            local MPos = UIS:GetMouseLocation()
            -- Delta/Mobile uyumlu yumuşak kilitlenme
            mousemoverel((TPos.X - MPos.X) * Settings.Sensitivity, (TPos.Y - MPos.Y) * Settings.Sensitivity)
        end
    end
end)

-- OYUNCULARI TAKİP ET
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- GUI ARAYÜZÜ (TABLAR)
local VisualTab = Window:CreateTab("Görsel (ESP)", 4483362458)
local CombatTab = Window:CreateTab("Savaş (AIM)", 4483362458)

-- ESP MENÜSÜ
VisualTab:CreateSection("ESP Ayarları")
VisualTab:CreateToggle({Name = "ESP Aktif", CurrentValue = false, Callback = function(v) Settings.EspEnabled = v end})
VisualTab:CreateColorPicker({Name = "ESP Rengi", Color = Color3.fromRGB(0, 255, 0), Callback = function(v) Settings.BoxColor = v end})
VisualTab:CreateToggle({Name = "İsimleri Göster", CurrentValue = false, Callback = function(v) Settings.Names = v end})

-- AIMBOT MENÜSÜ
CombatTab:CreateSection("Aimbot Ayarları")
CombatTab:CreateToggle({Name = "Aimbot Aktif", CurrentValue = false, Callback = function(v) Settings.AimbotEnabled = v end})
CombatTab:CreateToggle({Name = "FOV Çemberini Göster", CurrentValue = false, Callback = function(v) Settings.ShowFov = v end})
CombatTab:CreateSlider({Name = "FOV Boyutu", Range = {50, 500}, Increment = 10, CurrentValue = 100, Callback = function(v) Settings.FovRadius = v end})
CombatTab:CreateSlider({Name = "Smooth (Yumuşaklık)", Range = {1, 10}, Increment = 1, CurrentValue = 2, Callback = function(v) Settings.Sensitivity = v/10 end})

Rayfield:Notify({Title = "G&G SafeCheat", Content = "Script Başarıyla Hazırlandı!"})
