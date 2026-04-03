-- G&G SafeCheat V17 ULTRA-COMPATIBLE
local Success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not Success or not Rayfield then
    warn("Rayfield yuklenemedi, baglantinizi kontrol edin!")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "G&G SafeCheat | V17 ULTRA",
   LoadingTitle = "Gokalp Premium Hub",
   LoadingSubtitle = "by Gemini (V17.0)",
   ConfigurationSaving = { Enabled = false }
})

-- AYARLAR
local Settings = {
    EspEnabled = false,
    TracerEnabled = false,
    Names = false,
    Distances = false,
    HealthBar = false,
    BoxColor = Color3.fromRGB(0, 255, 0),
    AimbotEnabled = false,
    WallCheck = true,
    FovRadius = 250,
    Smoothness = 0.2,
    AimPart = "HumanoidRootPart",
    WalkSpeed = 16
}

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- WALL CHECK
local function IsVisible(TargetPart)
    if not Settings.WallCheck then return true end
    local Character = LocalPlayer.Character
    if not Character then return false end
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {Character, TargetPart.Parent}
    local Direction = (TargetPart.Position - Camera.CFrame.Position).Unit * (TargetPart.Position - Camera.CFrame.Position).Magnitude
    local Result = workspace:Raycast(Camera.CFrame.Position, Direction, Params)
    return Result == nil
end

-- ESP SİSTEMİ
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    local Tracer = Drawing.new("Line")
    local InfoTag = Drawing.new("Text")
    local HealthBarOutline = Drawing.new("Square")
    local HealthBar = Drawing.new("Square")
    
    RS.RenderStepped:Connect(function()
        if Settings.EspEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local Root = Player.Character.HumanoidRootPart
            local Hum = Player.Character:FindFirstChild("Humanoid")
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            
            if OnScreen and Hum then
                local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude
                local SizeY = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 2.6, 0)).Y)
                local SizeX = SizeY * 0.6
                
                Box.Visible = true
                Box.Color = Settings.BoxColor
                Box.Size = Vector2.new(SizeX, SizeY)
                Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
                Box.Filled = false
                
                if Settings.TracerEnabled then
                    Tracer.Visible = true
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(Pos.X, Pos.Y + (SizeY / 2))
                    Tracer.Color = Color3.fromHSV(math.clamp(Distance / 200, 0, 1) * 0.33, 1, 1)
                else Tracer.Visible = false end

                if Settings.HealthBar then
                    local HP = Hum.Health / Hum.MaxHealth
                    HealthBarOutline.Visible = true
                    HealthBarOutline.Size = Vector2.new(4, SizeY)
                    HealthBarOutline.Position = Vector2.new(Pos.X - (SizeX / 2) - 8, Pos.Y - (SizeY / 2))
                    HealthBarOutline.Color = Color3.new(0,0,0)
                    HealthBarOutline.Filled = true
                    
                    HealthBar.Visible = true
                    HealthBar.Size = Vector2.new(2, SizeY * HP)
                    HealthBar.Position = Vector2.new(Pos.X - (SizeX / 2) - 7, Pos.Y - (SizeY / 2) + (SizeY * (1 - HP)))
                    HealthBar.Color = Color3.fromHSV(HP * 0.33, 1, 1)
                    HealthBar.Filled = true
                else HealthBar.Visible = false HealthBarOutline.Visible = false end

                local DisplayText = ""
                if Settings.Names then DisplayText = DisplayText .. Player.Name .. "\n" end
                if Settings.Distances then DisplayText = DisplayText .. math.floor(Distance) .. "m\n" end
                if Settings.HealthBar then DisplayText = DisplayText .. "HP: " .. math.floor(Hum.Health) end
                
                InfoTag.Visible = (DisplayText ~= "")
                InfoTag.Text = DisplayText
                InfoTag.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 25)
                InfoTag.Center = true
                InfoTag.Outline = true
                InfoTag.Size = 13
            else Box.Visible = false Tracer.Visible = false InfoTag.Visible = false HealthBar.Visible = false HealthBarOutline.Visible = false end
        else Box.Visible = false Tracer.Visible = false InfoTag.Visible = false HealthBar.Visible = false HealthBarOutline.Visible = false end
    end)
end

-- EN YAKIN HEDEF
local function GetClosest()
    local Target = nil
    local Dist = Settings.FovRadius
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
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

-- ANA DÖNGÜ
RS.Heartbeat:Connect(function()
    if Settings.AimbotEnabled then
        local T = GetClosest()
        if T then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, T.Position), Settings.Smoothness)
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
VisualTab:CreateToggle({Name = "Dinamik Tracers", CurrentValue = false, Callback = function(v) Settings.TracerEnabled = v end})
VisualTab:CreateToggle({Name = "Pro Health Bar", CurrentValue = false, Callback = function(v) Settings.HealthBar = v end})
VisualTab:CreateToggle({Name = "Mesafe Göster", CurrentValue = false, Callback = function(v) Settings.Distances = v end})

CombatTab:CreateSection("Aimbot")
CombatTab:CreateToggle({Name = "Aimbot Aktif", CurrentValue = false, Callback = function(v) Settings.AimbotEnabled = v end})
CombatTab:CreateDropdown({
   Name = "Hedef Bölgesi",
   Options = {"HumanoidRootPart", "Head", "UpperTorso", "LowerTorso"},
   CurrentOption = "HumanoidRootPart",
   Callback = function(Option) Settings.AimPart = Option end,
})
CombatTab:CreateSlider({Name = "Smoothness", Range = {1, 10}, Increment = 1, CurrentValue = 2, Callback = function(v) Settings.Smoothness = v/10 end})
CombatTab:CreateSlider({Name = "Menzil (Range)", Range = {50, 1000}, Increment = 50, CurrentValue = 250, Callback = function(v) Settings.FovRadius = v end})

MiscTab:CreateSlider({Name = "Hız", Range = {16, 300}, Increment = 1, CurrentValue = 16, Callback = function(v) Settings.WalkSpeed = v end})

Rayfield:Notify({Title = "G&G SafeCheat V17", Content = "Ultra Sürüm Yüklendi!"})
