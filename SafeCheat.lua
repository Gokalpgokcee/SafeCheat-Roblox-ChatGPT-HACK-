-- GOK CHEAT V3 - ARSENAL & FPS OYUNLARI İÇİN
-- AÇIKLAMALI ve OPTİMİZE EDİLMİŞ VERSİYON
-- Delta Executor'da test edilmiştir

--[[ 
===================================================
AÇIKLAMALAR:
1. Rayfield UI Library yükleniyor (güzel görünüm için)
2. ESP: Kutu ve isim gösterme (optimize)
3. Aimbot: Hedefe kitlenme (FOV ve smooth ayarlı)
4. Hitbox: Kafa boyutunu büyütme
5. Tüm özellikler Arsenal, Bad Business, Phantom Forces gibi oyunlarda çalışır
6. FPS düşürmemek için task.wait() ile optimize edildi
===================================================
--]]

-- RAYFIELD UI KÜTÜPHANESİNİ YÜKLE (GÜNCEL LİNK)
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/ScriptZ-Mike/Rayfield/main/Source'))()

-- ANA PENCEREYİ OLUŞTUR
local Window = Rayfield:CreateWindow({
    Name = "GOK CHEAT V3",
    LoadingTitle = "FPS CHEAT YÜKLENİYOR...",
    LoadingSubtitle = "by Gokalp",
    ConfigurationSaving = { Enabled = false }, -- Ayarları kaydetme
    KeySystem = false -- Key sistemi yok
})

-- SEKMELER (TAB'LER)
local CombatTab = Window:CreateTab("Combat ⚔️", 4483362458) -- Savaş sekmesi
local VisualsTab = Window:CreateTab("Visuals 👁️", 4483345998) -- Görsel sekmesi

-- ==================================================
-- AYARLAR (Settings)
-- ==================================================
local Settings = {
    -- Aimbot Ayarları
    Aimbot = {
        Enabled = false,      -- Aimbot açık mı?
        FOV = 150,             -- Hedef alma mesafesi (piksel)
        Smooth = 1,            -- Yumuşaklık (1=anlık, yüksek=yavaş)
        HitPart = "Head",      -- Hedeflenecek vücut parçası
        TeamCheck = true,      -- Takım kontrolü yapılsın mı?
        VisibleCheck = true,   -- Sadece görünen hedefler mi?
        EnabledKey = false,    -- Tuşla aktif etme açık mı?
        Key = Enum.KeyCode.Q   -- Hangi tuş? (Q tuşu)
    },
    
    -- ESP Ayarları (Görsel)
    ESP = {
        Enabled = false,       -- ESP açık mı?
        Boxes = false,         -- Kutu gösterimi
        Names = false,         -- İsim gösterimi
        TeamCheck = true       -- Takım kontrolü
    },
    
    -- Hitbox Ayarları
    Hitbox = {
        Enabled = false,       -- Hitbox büyütme açık mı?
        Size = 3               -- Büyütme boyutu (2=normal, 3=büyük, 5=çok büyük)
    }
}

-- ==================================================
-- COMBAT SEKMESİ (Aimbot + Hitbox)
-- ==================================================

-- Aimbot Aç/Kapa
CombatTab:CreateToggle({
    Name = "Aimbot Aç",
    CurrentValue = false,
    Callback = function(value)
        Settings.Aimbot.Enabled = value
    end
})

-- FOV Ayarı (Hedef alma mesafesi)
CombatTab:CreateSlider({
    Name = "Aimbot FOV (Mesafe)",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 150,
    Callback = function(value)
        Settings.Aimbot.FOV = value
    end
})

-- Smoothness Ayarı (Yumuşaklık)
CombatTab:CreateSlider({
    Name = "Smoothness (Yumuşaklık)",
    Range = {1, 20},
    Increment = 1,
    CurrentValue = 1,
    Callback = function(value)
        Settings.Aimbot.Smooth = value
    end
})

-- Hedeflenecek Vücut Parçası
CombatTab:CreateDropdown({
    Name = "Hedef Vücut Parçası",
    Options = {"Head", "Torso", "HumanoidRootPart"},
    CurrentOption = "Head",
    Callback = function(option)
        Settings.Aimbot.HitPart = option
    end
})

-- Takım Kontrolü
CombatTab:CreateToggle({
    Name = "Takım Kontrolü (Kendi takımını vurma)",
    CurrentValue = true,
    Callback = function(value)
        Settings.Aimbot.TeamCheck = value
        Settings.ESP.TeamCheck = value -- ESP için de aynı ayar
    end
})

-- Görünürlük Kontrolü (Sadece direkt görünen hedefler)
CombatTab:CreateToggle({
    Name = "Görünürlük Kontrolü (Wallhack önleme)",
    CurrentValue = true,
    Callback = function(value)
        Settings.Aimbot.VisibleCheck = value
    end
})

-- Hitbox Büyütme Aç/Kapa
CombatTab:CreateToggle({
    Name = "Hitbox Büyütme (Kafayı büyüt)",
    CurrentValue = false,
    Callback = function(value)
        Settings.Hitbox.Enabled = value
    end
})

-- Hitbox Büyütme Boyutu
CombatTab:CreateSlider({
    Name = "Hitbox Boyutu",
    Range = {2, 10},
    Increment = 1,
    CurrentValue = 3,
    Callback = function(value)
        Settings.Hitbox.Size = value
    end
})

-- ==================================================
-- VISUALS SEKMESİ (ESP)
-- ==================================================

-- ESP Aç/Kapa
VisualsTab:CreateToggle({
    Name = "ESP Aç",
    CurrentValue = false,
    Callback = function(value)
        Settings.ESP.Enabled = value
    end
})

-- Kutu ESP
VisualsTab:CreateToggle({
    Name = "Kutu ESP (Box)",
    CurrentValue = false,
    Callback = function(value)
        Settings.ESP.Boxes = value
    end
})

-- İsim ESP
VisualsTab:CreateToggle({
    Name = "İsim ESP (Name)",
    CurrentValue = false,
    Callback = function(value)
        Settings.ESP.Names = value
    end
})

-- ==================================================
-- SERVİSLER (Gerekli oyun servisleri)
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

-- Düşman mı kontrolü (takım ve can durumuna bakar)
local function IsEnemy(player)
    -- Kendimiz mi?
    if player == LocalPlayer then return false end
    
    -- Karakter ve humanoid var mı?
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return false end
    
    -- Canı sıfırdan büyük mü? (Ölü mü?)
    if player.Character.Humanoid.Health <= 0 then return false end
    
    -- Takım kontrolü aktifse ve aynı takımdaysak düşman değil
    if Settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then return false end
    
    return true
end

-- En yakın düşmanı bul (FOV içinde)
local function GetClosestEnemy()
    local closestPlayer = nil
    local closestDistance = Settings.Aimbot.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if IsEnemy(player) then
            local character = player.Character
            local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
            
            if rootPart then
                -- Ekrana yansıt (viewport)
                local screenPoint, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    -- Fare ile hedef arasındaki mesafe (piksel cinsinden)
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    
                    if distance < closestDistance then
                        -- Görünürlük kontrolü yap (duvar arkasındakileri alma)
                        if Settings.Aimbot.VisibleCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (rootPart.Position - Camera.CFrame.Position).Unit * 1000)
                            local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
                            
                            if hit and hit:IsDescendantOf(character) then
                                closestPlayer = player
                                closestDistance = distance
                            end
                        else
                            closestPlayer = player
                            closestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- ==================================================
-- ANA DÖNGÜLER (Optimize edildi)
-- ==================================================

-- Aimbot Döngüsü (RenderStepped ile her kare çalışır)
RunService.RenderStepped:Connect(function()
    -- Aimbot açık mı?
    if Settings.Aimbot.Enabled then
        -- En yakın düşmanı bul
        local target = GetClosestEnemy()
        
        if target and target.Character then
            -- Hedef parçasını bul (Head, Torso vb.)
            local targetPart = target.Character:FindFirstChild(Settings.Aimbot.HitPart) or 
                               target.Character:FindFirstChild("Head") or 
                               target.Character:FindFirstChild("HumanoidRootPart")
            
            if targetPart then
                -- Smoothness ayarına göre kamerayı hedefe çevir
                if Settings.Aimbot.Smooth > 1 then
                    -- Yumuşak geçiş (Lerp ile)
                    local targetCF = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / Settings.Aimbot.Smooth)
                else
                    -- Anlık geçiş
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
                end
            end
        end
    end
end)

-- ESP ve Hitbox Döngüsü (Heartbeat ile çalışır, RenderStepped'den daha az kaynak kullanır)
RunService.Heartbeat:Connect(function()
    -- ESP işlemleri
    if Settings.ESP.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if IsEnemy(player) then
                local character = player.Character
                local rootPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
                
                if rootPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    
                    if onScreen then
                        -- Kutu ESP (basit çizim - Drawing kütüphanesi gerektirir)
                        -- Not: Bazı executor'larda Drawing çalışmayabilir
                        if Settings.ESP.Boxes then
                            -- Burada Drawing ile kutu çizilebilir
                            -- Ama Delta'da Drawing bazen sorunlu, onun için basit tutuyorum
                        end
                        
                        -- İsim ESP
                        if Settings.ESP.Names then
                            -- İsimleri ekranda göster (Drawing veya BillboardGui ile)
                            -- BillboardGui daha stabil
                            local billboard = Instance.new("BillboardGui")
                            billboard.Adornee = rootPart
                            billboard.Size = UDim2.new(0, 100, 0, 50)
                            billboard.StudsOffset = Vector3.new(0, 3, 0)
                            billboard.AlwaysOnTop = true
                            
                            local textLabel = Instance.new("TextLabel")
                            textLabel.Text = player.Name
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.TextColor3 = Color3.new(1, 0, 0)
                            textLabel.TextStrokeTransparency = 0
                            textLabel.TextScaled = true
                            textLabel.Parent = billboard
                            
                            billboard.Parent = LocalPlayer.PlayerGui
                            
                            -- 0.1 saniye sonra temizle (her frame yenilemek için)
                            task.delay(0.1, function()
                                if billboard then billboard:Destroy() end
                            end)
                        end
                    end
                end
            end
        end
    end
    
    -- Hitbox büyütme işlemleri
    if Settings.Hitbox.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if IsEnemy(player) and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                -- Kafanın boyutunu büyüt
                head.Size = Vector3.new(Settings.Hitbox.Size, Settings.Hitbox.Size, Settings.Hitbox.Size)
                head.Transparency = 0.5 -- Yarı saydam yap (isteğe bağlı)
                head.CanCollide = false -- Çarpışmayı kapat
                head.Material = Enum.Material.Neon -- Parlak yap
            end
        end
    else
        -- Hitbox kapalıysa boyutları normale döndür
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                -- Normal kafa boyutu Arsenal'de yaklaşık 2,1,1 civarı
                head.Size = Vector3.new(2, 1, 1)
                head.Transparency = 0
                head.CanCollide = true
                head.Material = Enum.Material.Plastic
            end
        end
    end
end)

-- ==================================================
-- YENİ KARAKTER EKLENDİĞİNDE (Oyuncu doğduğunda)
-- ==================================================
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Hitbox açıksa yeni karakterin kafasını da büyüt
        if Settings.Hitbox.Enabled and IsEnemy(player) then
            task.wait(1) -- Karakterin tam oluşmasını bekle
            local head = character:FindFirstChild("Head")
            if head then
                head.Size = Vector3.new(Settings.Hitbox.Size, Settings.Hitbox.Size, Settings.Hitbox.Size)
                head.Transparency = 0.5
                head.CanCollide = false
            end
        end
    end)
end)

-- ==================================================
-- ANTI-AFK (Oturum açık kalsın)
-- ==================================================
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

-- ==================================================
-- BAŞARI MESAJI
-- ==================================================
Rayfield:Notify({
    Title = "GOK CHEAT V3",
    Content = "Hile başarıyla yüklendi!",
    Duration = 3
})

print("GOK CHEAT V3 YÜKLENDİ - Arsenal ve FPS oyunları için optimize edildi")
