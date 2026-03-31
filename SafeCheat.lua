local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G Premium V2 | Mobile Edition",
   LoadingTitle = "Gokalp Advanced ESP...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = true, FolderName = "GG_Configs", FileName = "MainConfig" }
})

-- Global Değişkenler
local Settings = {
    EspEnabled = false,
    ShowName = false,
    ShowDistance = false,
    ShowHealth = false,
    EspColor = Color3.fromRGB(255, 0, 0)
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function CreateESP(Player)
    -- Drawing Objeleri
    local Box = Drawing.new("Square")
    local NameTag = Drawing.new("Text")
    local DistanceTag = Drawing.new("Text")
    local HealthBarOutline = Drawing.new("Line")
    local HealthBar = Drawing.new("Line")

    -- Varsayılan Ayarlar
    Box.Thickness = 1
    Box.Filled = false
    NameTag.Size = 14
    NameTag.Center = true
    NameTag.Outline = true
    DistanceTag.Size = 12
    DistanceTag.Center = true
    DistanceTag.Outline = true

    local function Update()
        local Connection
        Connection = RunService.RenderStepped:Connect(function()
            if Settings.EspEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid") and Player ~= LocalPlayer then
                local RootPart = Player.Character.HumanoidRootPart
                local Humanoid = Player.Character.Humanoid
                local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)

                if OnScreen then
                    -- Boyut Hesaplama
                    local SizeY = (Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, 2.6, 0)).Y)
                    local SizeX = SizeY * 0.6
                    
                    -- Box Ayarları
                    Box.Visible = true
                    Box.Color = Settings.EspColor
                    Box.Size = Vector2.new(SizeX, SizeY)
                    Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)

                    -- İsim ESP
                    if Settings.ShowName then
                        NameTag.Visible = true
                        NameTag.Text = Player.Name
                        NameTag.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 15)
                        NameTag.Color = Color3.new(1,1,1)
                    else NameTag.Visible = false end

                    -- Mesafe ESP
                    if Settings.ShowDistance then
                        local Dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - RootPart.Position).Magnitude)
                        DistanceTag.Visible = true
                        DistanceTag.Text = "[" .. Dist .. "m]"
                        DistanceTag.Position = Vector2.new(Pos.X, Pos.Y + (SizeY / 2) + 5)
                        DistanceTag.Color = Color3.new(1,1,1)
                    else DistanceTag.Visible = false end

                    -- Can Barı (Health Bar)
                    if Settings.ShowHealth then
                        local HealthPercent = Humanoid.Health / Humanoid.MaxHealth
                        local BarPos = Pos.X - (SizeX / 2) - 5
                        
                        HealthBarOutline.Visible = true
                        HealthBarOutline.From = Vector2.new(BarPos, Pos.Y + (SizeY / 2))
                        HealthBarOutline.To = Vector2.new(BarPos, Pos.Y - (SizeY / 2))
                        HealthBarOutline.Color = Color3.new(0,0,0)
                        HealthBarOutline.Thickness = 3

                        HealthBar.Visible = true
                        HealthBar.From = Vector2.new(BarPos, Pos.Y + (SizeY / 2))
                        HealthBar.To = Vector2.new(BarPos, Pos.Y + (SizeY / 2) - (SizeY * HealthPercent))
                        HealthBar.Color = Color3.new(0, 1, 0):Lerp(Color3.new(1, 0, 0), 1 - HealthPercent)
                        HealthBar.Thickness = 1
                    else
                        HealthBar.Visible = false
                        HealthBarOutline.Visible = false
                    end
                else
                    Box.Visible = false
                    NameTag.Visible = false
                    DistanceTag.Visible = false
                    HealthBar.Visible = false
                    HealthBarOutline.Visible = false
                end
            else
                Box.Visible = false
                NameTag.Visible = false
                DistanceTag.Visible = false
                HealthBar.Visible = false
                HealthBarOutline.Visible = false
                if not Player.Parent then
                    Box:Remove(); NameTag:Remove(); DistanceTag:Remove(); HealthBar:Remove(); HealthBarOutline:Remove()
                    Connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Update)()
end

-- Başlatma
for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- GUI
local MainTab = Window:CreateTab("Görsel (ESP)", 4483362458)

MainTab:CreateSection("Ana Ayarlar")

MainTab:CreateToggle({
   Name = "Box ESP",
   CurrentValue = false,
   Callback = function(v) Settings.EspEnabled = v end,
})

MainTab:CreateColorPicker({
    Name = "ESP Rengi",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(v) Settings.EspColor = v end
})

MainTab:CreateSection("Ekstralar")

MainTab:CreateToggle({
   Name = "İsim Göster",
   CurrentValue = false,
   Callback = function(v) Settings.ShowName = v end,
})

MainTab:CreateToggle({
   Name = "Mesafe Göster",
   CurrentValue = false,
   Callback = function(v) Settings.ShowDistance = v end,
})

MainTab:CreateToggle({
   Name = "Can Barı Göster",
   CurrentValue = false,
   Callback = function(v) Settings.ShowHealth = v end,
})
