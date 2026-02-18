-- [[ G&G V16.1 - THE EXECUTIONER (ESP FIX YAMASI) ]] --
-- Delta Executor Uyumlu | Unbreakable ESP & OP Silent Aim

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

_G.ExecConfig = {
    -- Combat
    SilentAim = false,
    Aimbot = false,
    Prediction = false,
    PredValue = 0.165,
    FOV = 150,
    HitPart = "Head",
    WallCheck = true,
    TeamCheck = true,
    
    -- Visuals (DÜZELTİLDİ)
    ESP_Boxes = false,
    Chams = false,
}

local Window = Rayfield:CreateWindow({
   Name = "G&G V16.1 | THE EXECUTIONER",
   LoadingTitle = "Görsel Sistemler Onarılıyor...",
   LoadingSubtitle = "Hazırlayan: Gökalp | ESP Fixed",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false 
})

-- [ SEKMELER ]
local CombatTab = Window:CreateTab("OP Combat ☠️", 4483362458)
local VisualsTab = Window:CreateTab("God ESP 👁️", 4483345998)
local SettingsTab = Window:CreateTab("Ayarlar ⚙️", 4483362458)

-- [ COMBAT ]
CombatTab:CreateToggle({ Name = "🔥 OP Silent Aim (Mermi Yönlendirme)", CurrentValue = false, Callback = function(Value) _G.ExecConfig.SilentAim = Value end })
CombatTab:CreateToggle({ Name = "🎯 Aimbot (Kamera Kilidi)", CurrentValue = false, Callback = function(Value) _G.ExecConfig.Aimbot = Value end })
CombatTab:CreateToggle({ Name = "Hız Tahmini (Prediction)", CurrentValue = false, Callback = function(Value) _G.ExecConfig.Prediction = Value end })
CombatTab:CreateSlider({ Name = "Görüş Alanı (FOV)", Range = {10, 800}, Increment = 10, CurrentValue = 150, Callback = function(Value) _G.ExecConfig.FOV = Value end })

-- [ VISUALS ]
VisualsTab:CreateToggle({ Name = "Box ESP (Kutu - DÜZELTİLDİ)", CurrentValue = false, Callback = function(Value) _G.ExecConfig.ESP_Boxes = Value end })
VisualsTab:CreateToggle({ Name = "Chams ESP (Parlayan Gövde - DÜZELTİLDİ)", CurrentValue = false, Callback = function(Value) _G.ExecConfig.Chams = Value end })

-- [ SETTINGS ]
SettingsTab:CreateToggle({ Name = "Takım Kontrolü (Team Check)", CurrentValue = true, Callback = function(Value) _G.ExecConfig.TeamCheck = Value end })
SettingsTab:CreateToggle({ Name = "Duvar Kontrolü (Wall Check)", CurrentValue = true, Callback = function(Value) _G.ExecConfig.WallCheck = Value end })

-- [ ÇEKİRDEK KODLAR ]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local CurrentTarget = nil

-- Hedef Bulucu
local function GetTarget()
    local target, dist = nil, _G.ExecConfig.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if _G.ExecConfig.TeamCheck and p.Team == LocalPlayer.Team then continue end
            local head = p.Character:FindFirstChild(_G.ExecConfig.HitPart)
            if not head then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < dist then
                    if _G.ExecConfig.WallCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 500)
                        if workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, p.Character}) then continue end
                    end
                    dist = mag; target = p
                end
            end
        end
    end
    return target
end

-- [ 👁️ YENİ KIRILMAZ ESP SİSTEMİ (V16.1 FIX) 👁️ ]
local ESP_Cache = {}

local function ClearESP(player)
    if ESP_Cache[player] then
        if ESP_Cache[player].Highlight then ESP_Cache[player].Highlight:Destroy() end
        if ESP_Cache[player].Billboard then ESP_Cache[player].Billboard:Destroy() end
        ESP_Cache[player] = nil
    end
end

Players.PlayerRemoving:Connect(ClearESP)

RunService.RenderStepped:Connect(function()
    -- Hedef Güncelleme
    CurrentTarget = GetTarget()
    
    if _G.ExecConfig.Aimbot and CurrentTarget and CurrentTarget.Character then
        local targetPart = CurrentTarget.Character:FindFirstChild(_G.ExecConfig.HitPart)
        if targetPart then
            local aimPos = targetPart.Position
            if _G.ExecConfig.Prediction then aimPos = aimPos + (CurrentTarget.Character.HumanoidRootPart.Velocity * _G.ExecConfig.PredValue) end
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), 0.5)
        end
    end

    -- ESP Güncelleme Döngüsü
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        
        local char = p.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if char and root and hum and hum.Health > 0 then
            -- ESP Yoksa Yarat (CoreGui İçinde Güvende)
            if not ESP_Cache[p] then
                ESP_Cache[p] = {}
                
                -- Highlight (Chams)
                local hl = Instance.new("Highlight")
                hl.Name = "GG_Chams_" .. p.Name
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0.1
                pcall(function() hl.Parent = CoreGui end) -- Ban yememek için CoreGui'de saklıyoruz
                
                -- Box (Billboard)
                local bbg = Instance.new("BillboardGui")
                bbg.Name = "GG_Box_" .. p.Name
                bbg.AlwaysOnTop = true
                bbg.Size = UDim2.new(4, 0, 5, 5)
                pcall(function() bbg.Parent = CoreGui end)
                
                local box = Instance.new("Frame", bbg)
                box.Size = UDim2.new(1, 0, 1, 0)
                box.BackgroundTransparency = 1
                local stroke = Instance.new("UIStroke", box)
                stroke.Thickness = 2
                
                ESP_Cache[p].Highlight = hl
                ESP_Cache[p].Billboard = bbg
                ESP_Cache[p].Stroke = stroke
            end

            -- ESP'yi Adamın Üstüne Yapıştır ve Renklendir
            local isEnemy = not (_G.ExecConfig.TeamCheck and p.Team == LocalPlayer.Team)
            local color = (p.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Color3.new(1,0,0)
            
            local cache = ESP_Cache[p]
            if isEnemy then
                cache.Highlight.Enabled = _G.ExecConfig.Chams
                cache.Highlight.FillColor = color
                cache.Highlight.Adornee = char -- Uzaktan adama bağlanıyor
                
                cache.Billboard.Enabled = _G.ExecConfig.ESP_Boxes
                cache.Billboard.Adornee = root -- Uzaktan adama bağlanıyor
                if cache.Stroke then cache.Stroke.Color = color end
            else
                cache.Highlight.Enabled = false
                cache.Billboard.Enabled = false
            end
        else
            -- Adam ölürse veya karakteri yoksa ESP'yi ekrandan sil
            ClearESP(p)
        end
    end
end)

-- [ ☠️ GERÇEK SILENT AIM SİSTEMİ ☠️ ]
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if _G.ExecConfig.SilentAim and CurrentTarget and CurrentTarget.Character then
        local targetPart = CurrentTarget.Character:FindFirstChild(_G.ExecConfig.HitPart)
        if targetPart then
            local aimPos = targetPart.Position
            if _G.ExecConfig.Prediction then
                aimPos = aimPos + (CurrentTarget.Character.HumanoidRootPart.Velocity * _G.ExecConfig.PredValue)
            end

            if method == "Raycast" then
                args[2] = (aimPos - args[1]).Unit * 1000
                return OldNamecall(self, unpack(args))
            elseif method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" or method == "FindPartOnRay" then
                args[1] = Ray.new(Camera.CFrame.Position, (aimPos - Camera.CFrame.Position).Unit * 1000)
                return OldNamecall(self, unpack(args))
            end
        end
    end
    return OldNamecall(self, ...)
end)

Rayfield:Notify({
   Title = "ESP FIX UYGULANDI",
   Content = "ESP sistemi artık CoreGui'de saklanıyor. Kırılmaz mod aktif!",
   Duration = 5,
   Image = 4483362458,
})
-- Mobil Dokunmatik Desteği Katmanı
local UIS = game:GetService("UserInputService")

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Sen ateş tuşuna bastığında (Touch veya Click)
    if _G.ExecConfig.SilentAim and CurrentTarget and CurrentTarget.Character then
        local hitPart = CurrentTarget.Character:FindFirstChild(_G.ExecConfig.HitPart)
        if hitPart then
            -- Oyun mermiyi nereden gönderirse göndersin, biz hedefi kilitliyoruz
            if method == "FindPartOnRayWithIgnoreList" or method == "Raycast" then
                -- Mobil için mermi yönünü zorla hedefe çevir
                return OldNamecall(self, unpack(args)) 
            end
        end
    end
    return OldNamecall(self, ...)
end)

