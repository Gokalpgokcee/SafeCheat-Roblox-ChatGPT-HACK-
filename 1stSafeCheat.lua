local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G SafeCheat | V15 PRECISION",
   LoadingTitle = "Gokalp Engineering System",
   LoadingSubtitle = "by Gemini (V15.0)",
   ConfigurationSaving = { Enabled = false }
})

-- AYARLAR
local Settings = {
    EspEnabled = false,
    TracerEnabled = false,
    Names = false,
    HealthBar = false,
    AimbotEnabled = false,
    WallCheck = true,
    AimPart = "Head", -- Varsayılan Bölge
    FovRadius = 300,
    Smoothness = 0.15,
    WalkSpeed = 16
}

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- GÖRÜNÜRLÜK KONTROLÜ (Daha Stabil)
local function IsVisible(Part)
    if not Settings.WallCheck then return true end
    local Character = LocalPlayer.Character
    if not Character then return false end
    
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {Character, Part.Parent}
    
    local Direction = (Part.Position - Camera.CFrame.Position).Unit * (Part.Position - Camera.CFrame.Position).Magnitude
    local Result = workspace:Raycast(Camera.CFrame.Position, Direction, Params)
    
    return Result == nil
end

-- ESP SİSTEMİ
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    local Tracer = Drawing.new("Line")
    local Info = Drawing.new("Text")
    
    RS.RenderStepped:Connect(function()
        if Settings.EspEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local Root = Player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            
            if OnScreen then
                local SizeY = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 2.6, 0)).Y)
                local SizeX = SizeY * 0.6
                
                Box.Visible = true
                Box.Size = Vector2.new(SizeX, SizeY)
                Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
                Box.Color = Color3.fromRGB(0, 255, 0)
                Box.Filled = false
                
                if Settings.TracerEnabled then
                    Tracer.Visible = true
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(Pos.X, Pos.Y + (SizeY / 2))
                    Tracer.Color = Color3.fromRGB(255, 255, 255)
                else Tracer.Visible = false end

                if Settings.Names then
                    Info.Visible = true
                    Info.Text = Player.Name
                    Info.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 15)
                    Info.Center = true
                    Info.Outline = true
                else Info.Visible = false end
            else Box.Visible = false Tracer.Visible = false Info.Visible = false end
        else Box.Visible = false Tracer.Visible = false Info.Visible = false end
    end)
end

-- EN YAKIN HEDEFİ BULMA
local function GetTarget()
    local Target = nil
    local Dist = Settings.FovRadius
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            -- Seçilen bölgeyi kontrol et, yoksa RootPart'a dön
            local Part = v.Character:FindFirstChild(Settings.AimPart) or v.Character:FindFirstChild("HumanoidRootPart")
            if Part then
                local Pos, On = Camera:WorldToViewportPoint(Part.Position)
                local Mag = (Center - Vector2.new(Pos.X, Pos.Y)).Magnitude
                if Mag < Dist and On and IsVisible(Part) then
                    Target = Part
                    Dist = Mag
                end
            end
        end
    end
    return Target
end

-- AIMBOT ANA DÖNGÜ (Daha Stabil Çalışması İçin Heartbeat)
RS.Heartbeat:Connect(function()
    if Settings.AimbotEnabled then
        local TargetPart = GetTarget()
        if TargetPart then
            -- Lerp ile kilitlenme (Smoothness ayarına göre)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPart.Position), Settings.Smoothness)
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

VisualTab:CreateToggle({Name = "Box ESP", CurrentValue = false, Callback = function(v) Settings.EspEnabled = v end})
VisualTab:CreateToggle({Name = "Çizgiler", CurrentValue = false, Callback = function(v) Settings.TracerEnabled = v end})
VisualTab:CreateToggle({Name = "İsimler", CurrentValue = false, Callback = function(v) Settings.Names = v end})

CombatTab:CreateSection("Aimbot Kontrolü")
CombatTab:CreateToggle({Name = "Aimbot Aktif", CurrentValue = false, Callback = function(v) Settings.AimbotEnabled = v end})

CombatTab:CreateDropdown({
   Name = "Hedef Bölgesi",
   Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
   CurrentOption = "Head",
   Callback = function(Option)
      Settings.AimPart = Option
      Rayfield:Notify({Title = "Hedef Değişti", Content = "Yeni Hedef: " .. Option})
   end,
})

CombatTab:CreateSlider({Name = "Smoothness (Yumuşaklık)", Range = {1, 10}, Increment = 1, CurrentValue = 2, Callback = function(v) Settings.Smoothness = v/10 end})
CombatTab:CreateSlider({Name = "Mesafe (Range)", Range = {100, 1500}, Increment = 50, CurrentValue = 300, Callback = function(v) Settings.FovRadius = v end})
CombatTab:CreateToggle({Name = "Duvar Kontrolü", CurrentValue = true, Callback = function(v) Settings.WallCheck = v end})

MiscTab:CreateSlider({Name = "Hız", Range = {16, 300}, Increment = 1, CurrentValue = 16, Callback = function(v) Settings.WalkSpeed = v end})

Rayfield:Notify({Title = "G&G SafeCheat V15", Content = "Precision sürümü aktif! Hitbox seçimi sorunsuz çalışıyor."})
