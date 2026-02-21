-- GOK CHEAT V5 - RAYFIELD DOĞRU LİNK İLE
-- Arsenal, Bad Business, Phantom Forces için optimize edildi

--[[
ÖNEMLİ: Bu kod, senin verdiğin şu linki kullanır:
https://raw.githubusercontent.com/jensonhirst/Rayfield/refs/heads/main/source
]]

-- Rayfield UI Library'yi senin verdiğin linkle yükle
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Rayfield/refs/heads/main/source'))()

-- Ana pencereyi oluştur
local Window = Rayfield:CreateWindow({
    Name = "GOK CHEAT V5",
    LoadingTitle = "FPS HILE YUKLENIYOR...",
    LoadingSubtitle = "by Gokalp",
    ConfigurationSaving = { 
        Enabled = true, 
        FolderName = "GOKCHEAT", 
        FileName = "FPS_Config" 
    },
    KeySystem = false
})

-- Sekmeler (Tabs)
local CombatTab = Window:CreateTab("Combat ⚔️", "rbxassetid://4483345998")
local VisualsTab = Window:CreateTab("Visuals 👁️", "rbxassetid://4483345998")
local MiscTab = Window:CreateTab("Misc ⚙️", "rbxassetid://4483362458")

-- ==================================================
-- AYARLAR (Settings)
-- ==================================================
local Settings = {
    Aimbot = false,
    AimbotFOV = 180,
    AimbotSmooth = 5,
    AimbotPart = "Head",
    TeamCheck = true,
    VisibleCheck = true,
    Hitbox = false,
    HitboxSize = 3,
    ESP = false,
    ESPBox = false,
    ESPName = false,
    ESPHealth = false,
    Walkspeed = 16,
    AntiAFK = true
}

-- ==================================================
-- COMBAT SEKMESİ (Aimbot + Hitbox)
-- ==================================================

-- Aimbot Aç/Kapa
CombatTab:CreateToggle({
    Name = "Aimbot (Hedef Kilidi)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(value)
        Settings.Aimbot = value
    end
})

-- FOV Ayarı (Hedef alma mesafesi)
CombatTab:CreateSlider({
    Name = "Aimbot FOV (Mesafe)",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 180,
    Flag = "AimbotFOV",
    Callback = function(value)
        Settings.AimbotFOV = value
    end
})

-- Smoothness Ayarı (Yumuşaklık)
CombatTab:CreateSlider({
    Name = "Smoothness (Yumuşaklık)",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 5,
    Flag = "AimbotSmooth",
    Callback = function(value)
        Settings.AimbotSmooth = value
    end
})

-- Hedeflenecek Vücut Parçası
CombatTab:CreateDropdown({
    Name = "Hedef Vücut Parçası",
    Options = {"Head", "Torso", "HumanoidRootPart"},
    CurrentOption = "Head",
    Flag = "AimbotPart",
    Callback = function(option)
        Settings.AimbotPart = option
    end
})

-- Takım Kontrolü
CombatTab:CreateToggle({
    Name = "Takım Kontrolü (Takımını Vurma)",
    CurrentValue = true,
    Flag = "TeamCheck",
    Callback = function(value)
        Settings.TeamCheck = value
    end
})

-- Görünürlük Kontrolü
CombatTab:CreateToggle({
    Name = "Görünürlük Kontrolü (Duvar Arkasını Vurma)",
    CurrentValue = true,
    Flag = "VisibleCheck",
    Callback = function(value)
        Settings.VisibleCheck = value
    end
})

-- Hitbox Büyütme
CombatTab:CreateToggle({
    Name = "Hitbox Büyütme (Kafayı Büyüt)",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(value)
        Settings.Hitbox = value
    end
})

-- Hitbox Boyutu
CombatTab:CreateSlider({
    Name = "Hitbox Boyutu",
    Range = {2, 10},
    Increment = 1,
    CurrentValue = 3,
    Flag = "HitboxSize",
    Callback = function(value)
        Settings.HitboxSize = value
    end
})

-- ==================================================
-- VISUALS SEKMESİ (ESP)
-- ==================================================

-- ESP Aç/Kapa
VisualsTab:CreateToggle({
    Name = "ESP Aç",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(value)
        Settings.ESP = value
    end
})

-- Kutu ESP
VisualsTab:CreateToggle({
    Name = "Kutu ESP (Box)",
    CurrentValue = false,
    Flag = "ESPBox",
    Callback = function(value)
        Settings.ESPBox = value
    end
})

-- İsim ESP
VisualsTab:CreateToggle({
    Name = "İsim ESP (Name)",
    CurrentValue = false,
    Flag = "ESPName",
    Callback = function(value)
        Settings.ESPName = value
    end
})

-- Sağlık ESP
VisualsTab:CreateToggle({
    Name = "Sağlık ESP (Health)",
    CurrentValue = false,
    Flag = "ESPHealth",
    Callback = function(value)
        Settings.ESPHealth = value
    end
})

-- ==================================================
-- MISC SEKMESİ
-- ==================================================

-- Walkspeed (Hız)
MiscTab:CreateSlider({
    Name = "WalkSpeed (Hız)",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 16,
    Flag = "Walkspeed",
    Callback = function(value)
        Settings.Walkspeed = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})

-- Anti-AFK
MiscTab:CreateToggle({
    Name = "Anti-AFK (Atılma Engelle)",
    CurrentValue = true,
    Flag = "AntiAFK",
    Callback = function(value)
        Settings.AntiAFK = value
    end
})

-- FPS Boost Butonu
MiscTab:CreateButton({
    Name = "FPS Boost (Efektleri Temizle)",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
                v:Destroy()
            end
        end
        Rayfield:Notify({
            Title = "FPS Boost",
            Content = "Gereksiz efektler temizlendi!",
            Duration = 3
        })
    end
})

-- GUI'yi Gizle/Göster Butonu
MiscTab:CreateButton({
    Name = "GUI'yi Gizle/Göster (Ins tuşu)",
    Callback = function()
        Rayfield:Notify({
            Title = "GUI Kontrol",
            Content = "Ins (Insert) tuşu ile gizleyip gösterebilirsin!",
            Duration = 3
        })
    end
})

-- ==================================================
-- SERVİSLER
-- ==================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ==================================================
-- YARDIMCI FONKSİYONLAR
-- ==================================================

-- Düşman mı kontrolü
local function IsEnemy(player)
    if player == LocalPlayer then return false end
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return false end
    if player.Character.Humanoid.Health <= 0 then return false end
    if Settings.TeamCheck and player.Team == LocalPlayer.Team then return false end
    return true
end

-- En yakın düşmanı bul
local function GetClosestEnemy()
    local closest = nil
    local closestDist = Settings.AimbotFOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) then
            local root = player.Character:FindFirstChild("HumanoidRootPart") or 
                         player.Character:FindFirstChild("Torso") or 
                         player.Character:FindFirstChild("UpperTorso")
            if root then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < closestDist then
                        if Settings.VisibleCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (root.Position - Camera.CFrame.Position).Unit * 1000)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                            if hit and hit:IsDescendantOf(player.Character) then
                                closest = player
                                closestDist = dist
                            end
                        else
                            closest = player
                            closestDist = dist
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- ==================================================
-- ANA DÖNGÜLER
-- ==================================================

-- Aimbot Döngüsü
RunService.RenderStepped:Connect(function()
    if Settings.Aimbot then
        local target = GetClosestEnemy()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(Settings.AimbotPart) or 
                               target.Character:FindFirstChild("Head") or 
                               target.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                if Settings.AimbotSmooth > 1 then
                    local targetCF = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / Settings.AimbotSmooth)
                else
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
                end
            end
        end
    end
end)

-- Hitbox Döngüsü
RunService.Heartbeat:Connect(function()
    if Settings.Hitbox then
        for _, player in ipairs(Players:GetPlayers()) do
            if IsEnemy(player) and player.Character and player.Character:FindFirstChild("Head") then
                player.Character.Head.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                player.Character.Head.Transparency = 0.5
                player.Character.Head.CanCollide = false
                player.Character.Head.Material = Enum.Material.Neon
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") then
                player.Character.Head.Size = Vector3.new(2, 1, 1)
                player.Character.Head.Transparency = 0
                player.Character.Head.CanCollide = true
                player.Character.Head.Material = Enum.Material.Plastic
            end
        end
    end
end)

-- ESP Döngüsü
local ESPCache = {}
RunService.Heartbeat:Connect(function()
    if Settings.ESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if IsEnemy(player) then
                local root = player.Character:FindFirstChild("HumanoidRootPart") or 
                             player.Character:FindFirstChild("Torso") or 
                             player.Character:FindFirstChild("UpperTorso")
                if root then
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        -- İsim ESP
                        if Settings.ESPName then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Adornee = root
                            billboard.Size = UDim2.new(0, 100, 0, 30)
                            billboard.StudsOffset = Vector3.new(0, 3, 0)
                            billboard.AlwaysOnTop = true
                            billboard.Parent = Rayfield
                            
                            local label = Instance.new("TextLabel")
                            label.Text = player.Name
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.new(1, 0, 0)
                            label.TextStrokeTransparency = 0
                            label.TextScaled = true
                            label.Parent = billboard
                            
                            task.delay(0.1, function()
                                if billboard then billboard:Destroy() end
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- WalkSpeed Döngüsü
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Walkspeed
    end
end)

-- Anti-AFK
if Settings.AntiAFK then
    LocalPlayer.Idled:Connect(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
end

-- Insert tuşu ile GUI gizle/göster
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        Rayfield.Enabled = not Rayfield.Enabled
    end
end)

-- ==================================================
-- BAŞLANGIÇ MESAJI
-- ==================================================
Rayfield:Notify({
    Title = "GOK CHEAT V5",
    Content = "Doğru Rayfield linki ile yüklendi! Insert tuşu ile gizle/göster.",
    Duration = 5
})

print("GOK CHEAT V5 YÜKLENDİ - Doğru Rayfield linki kullanıldı")
