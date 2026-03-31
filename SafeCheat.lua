-- Rayfield Kütüphanesi (Mobil En Stabil Sürüm)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G SafeCheat | V2.5",
   LoadingTitle = "Sistem Yükleniyor...",
   LoadingSubtitle = "Gokalp Edition",
   ConfigurationSaving = { Enabled = false }
})

-- AYARLAR TABLOSU (Dinamik Güncelleme İçin Şart)
local Config = {
    EspActive = false,
    EspColor = Color3.fromRGB(0, 255, 0), -- Varsayılan Yeşil
    ShowNames = false,
    ShowDist = false,
    ShowHealth = false
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ESP Çizim Fonksiyonu
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    local Name = Drawing.new("Text")
    local Dist = Drawing.new("Text")
    local HealthBar = Drawing.new("Line")

    -- Ayarları her karede yenileyen döngü
    local Connection
    Connection = RunService.RenderStepped:Connect(function()
        if Config.EspActive and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local Root = Player.Character.HumanoidRootPart
            local Hum = Player.Character:FindFirstChild("Humanoid")
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)

            if OnScreen then
                local SizeY = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 2.6, 0)).Y)
                local SizeX = SizeY * 0.6

                -- KUTU (Renk Fix: Config.EspColor'ı direkt buradan çeker)
                Box.Visible = true
                Box.Color = Config.EspColor
                Box.Size = Vector2.new(SizeX, SizeY)
                Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
                Box.Thickness = 1

                -- İSİM
                if Config.ShowNames then
                    Name.Visible = true
                    Name.Text = Player.Name
                    Name.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 15)
                    Name.Outline = true
                    Name.Center = true
                    Name.Size = 14
                else Name.Visible = false end

                -- MESAFE
                if Config.ShowDist then
                    local Distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude)
                    Dist.Visible = true
                    Dist.Text = Distance .. "m"
                    Dist.Position = Vector2.new(Pos.X, Pos.Y + (SizeY / 2) + 5)
                    Dist.Outline = true
                    Dist.Center = true
                    Dist.Size = 12
                else Dist.Visible = false end
            else
                Box.Visible = false
                Name.Visible = false
                Dist.Visible = false
            end
        else
            Box.Visible = false
            Name.Visible = false
            Dist.Visible = false
            if not Player.Parent then
                Box:Remove(); Name:Remove(); Dist:Remove()
                Connection:Disconnect()
            end
        end
    end)
end

-- Oyuncuları Takip Et
for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- GUI ARAYÜZÜ
local VisualTab = Window:CreateTab("Görsel (ESP)", 4483362458)

VisualTab:CreateToggle({
   Name = "ESP Aktif",
   CurrentValue = false,
   Callback = function(Value) Config.EspActive = Value end,
})

VisualTab:CreateColorPicker({
    Name = "ESP Rengi",
    Color = Color3.fromRGB(0, 255, 0),
    Callback = function(Value) 
        Config.EspColor = Value -- Renk anında güncellenir
    end
})

VisualTab:CreateSection("Ek Özellikler")

VisualTab:CreateToggle({
   Name = "İsimleri Göster",
   CurrentValue = false,
   Callback = function(v) Config.ShowNames = v end,
})

VisualTab:CreateToggle({
   Name = "Mesafe Göster",
   CurrentValue = false,
   Callback = function(v) Config.ShowDist = v end,
})

Rayfield:Notify({Title = "G&G SafeCheat", Content = "Script Başarıyla Hazırlandı!", Duration = 3})
= function(v) Settings.ShowHealth = v v end })
