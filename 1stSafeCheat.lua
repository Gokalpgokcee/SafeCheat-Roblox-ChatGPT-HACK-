local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G SafeCheat | V9 ULTIMATE",
   LoadingTitle = "Gokalp Advanced Systems",
   LoadingSubtitle = "by Gemini (V9.0)",
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
    Smoothness = 0.1,
    AimPart = "HumanoidRootPart",
    -- Yeni Özellikler
    WalkSpeed = 16,
    JumpPower = 50,
    FlyEnabled = false,
    FlySpeed = 50,
    NoclipEnabled = false
}

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV ÇEMBERİ (EKRAN ORTASI)
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Visible = false

-- ESP SİSTEMİ (İÇİ BOŞ)
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
                Box.Filled = false
                Box.Thickness = 1
                if Settings.Names then
                    NameTag.Visible = true
                    NameTag.Text = Player.Name
                    NameTag.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 15)
                    NameTag.Center = true
                    NameTag.Outline = true
                else NameTag.Visible = false end
            else Box.Visible = false NameTag.Visible = false end
        else Box.Visible = false NameTag.Visible = false end
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
            if Mag < Dist and OnScreen then Target = v Dist = Mag end
        end
    end
    return Target
end

-- ANA DÖNGÜ (AIMBOT, FLY, NOCLIP)
RS.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Radius = Settings.FovRadius
    FovCircle.Visible = Settings.ShowFov

    -- Aimbot Kilitlenme
    if Settings.AimbotEnabled then
        local T = GetClosest()
        if T then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Character[Settings.AimPart].Position), Settings.Smoothness)
        end
    end

    -- Noclip (Duvar Geçme)
    if Settings.NoclipEnabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    -- Fly (Uçma) Logic
    if Settings.FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local BPV = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity", LocalPlayer.Character.HumanoidRootPart)
        BPV.Name = "FlyVelocity"
        BPV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BPV.Velocity = Camera.CFrame.LookVector * Settings.FlySpeed
    elseif LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlyVelocity") then
        LocalPlayer.Character.HumanoidRootPart.FlyVelocity:Destroy()
    end
end)

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- GUI
local VisualTab = Window:CreateTab("Görsel")
local CombatTab = Window:CreateTab("Savaş")
local PlayerTab = Window:CreateTab("Karakter")

-- Görsel
VisualTab:CreateToggle({Name = "İçi Boş ESP", CurrentValue = false, Callback = function(v) Settings.EspEnabled = v end})
VisualTab:CreateColorPicker({Name = "Renk", Color = Settings.BoxColor, Callback = function(v) Settings.BoxColor = v end})

-- Savaş
CombatTab:CreateToggle({Name = "Aimbot Lock", CurrentValue = false, Callback = function(v) Settings.AimbotEnabled = v end})
CombatTab:CreateToggle({Name = "FOV Göster", CurrentValue = false, Callback = function(v) Settings.ShowFov = v end})
CombatTab:CreateSlider({Name = "FOV Çapı", Range = {50, 800}, Increment = 10, CurrentValue = 150, Callback = function(v) Settings.FovRadius = v end})

-- Karakter
PlayerTab:CreateSlider({Name = "Hız", Range = {16, 300}, Increment = 1, CurrentValue = 16, Callback = function(v) LocalPlayer.Character.Humanoid.WalkSpeed = v end})
PlayerTab:CreateToggle({Name = "Noclip (Duvar Geçme)", CurrentValue = false, Callback = function(v) Settings.NoclipEnabled = v end})
PlayerTab:CreateToggle({Name = "Fly (Uçma)", CurrentValue = false, Callback = function(v) Settings.FlyEnabled = v end})
PlayerTab:CreateSlider({Name = "Uçma Hızı", Range = {10, 500}, Increment = 10, CurrentValue = 50, Callback = function(v) Settings.FlySpeed = v end})

Rayfield:Notify({Title = "G&G SafeCheat", Content = "V9 Ultimate Aktif! İyi oyunlar."})
