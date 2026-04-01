local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G SafeCheat | V4 Professional",
   LoadingTitle = "Gokalp Scripting System",
   LoadingSubtitle = "by Gemini (v4.0)",
   ConfigurationSaving = { Enabled = false }
})

-- AYARLAR TABLOSU
local Settings = {
    EspEnabled = false,
    BoxColor = Color3.fromRGB(0, 255, 0),
    Names = false,
    AimbotEnabled = false,
    FovRadius = 100,
    ShowFov = false,
    Sensitivity = 0.2,
    WalkSpeed = 16,
    JumpPower = 50
}

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV Çemberi
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Filled = false
FovCircle.Visible = false

-- ESP Fonksiyonu
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
                Box.Color = Settings.BoxColor -- Renk anında güncellenir
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

-- Aimbot Hedef Bulucu
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

-- Ana Döngü (Aimbot & Karakter)
RS.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)
    FovCircle.Radius = Settings.FovRadius
    FovCircle.Visible = Settings.ShowFov

    -- Aimbot Logic
    if Settings.AimbotEnabled then
        local T = GetClosest()
        if T then
            local TPos = Camera:WorldToViewportPoint(T.Character.HumanoidRootPart.Position)
            local MPos = UIS:GetMouseLocation()
            mousemoverel((TPos.X - MPos.X) * Settings.Sensitivity, (TPos.Y - MPos.Y) * Settings.Sensitivity)
        end
    end

    -- Hız ve Zıplama Fix (Ölünce gitmez)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = Settings.JumpPower
    end
end)

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- GUI
local VisualTab = Window:CreateTab("Görsel (ESP)")
local CombatTab = Window:CreateTab("Savaş (AIM)")
local MiscTab = Window:CreateTab("Karakter")

-- ESP Menüsü
VisualTab:CreateToggle({Name = "Box ESP", CurrentValue = false, Callback = function(v) Settings.EspEnabled = v end})
VisualTab:CreateColorPicker({Name = "ESP Rengi", Color = Settings.BoxColor, Callback = function(v) Settings.BoxColor = v end})
VisualTab:CreateToggle({Name = "İsim Göster", CurrentValue = false, Callback = function(v) Settings.Names = v end})

-- Combat Menüsü
CombatTab:CreateToggle({Name = "Aimbot", CurrentValue = false, Callback = function(v) Settings.AimbotEnabled = v end})
CombatTab:CreateToggle({Name = "FOV Göster", CurrentValue = false, Callback = function(v) Settings.ShowFov = v end})
CombatTab:CreateSlider({Name = "FOV Çapı", Range = {50, 500}, Increment = 10, CurrentValue = 100, Callback = function(v) Settings.FovRadius = v end})

-- Karakter Menüsü
MiscTab:CreateSlider({Name = "Hız (WalkSpeed)", Range = {16, 250}, Increment = 1, CurrentValue = 16, Callback = function(v) Settings.WalkSpeed = v end})
MiscTab:CreateSlider({Name = "Zıplama Gücü", Range = {50, 500}, Increment = 1, CurrentValue = 50, Callback = function(v) Settings.JumpPower = v end})

Rayfield:Notify({Title = "G&G SafeCheat", Content = "Script V4 Başarıyla Yüklendi!"})
