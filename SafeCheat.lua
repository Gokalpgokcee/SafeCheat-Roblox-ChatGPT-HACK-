-- [[ G&G V16.0 - THE EXECUTIONER (OP SILENT AIM & PREDICTION) ]] --
-- Universal FPS Overhaul | Delta Executor Compatible

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

_G.ExecConfig = {
    -- Aimbot & Silent Aim
    SilentAim = false,
    Aimbot = false,
    Prediction = false,
    PredValue = 0.165, -- Standart ping/hız tahmini
    FOV = 150,
    HitPart = "Head",
    WallCheck = true,
    TeamCheck = true,
    
    -- Visuals
    ESP_Boxes = false,
    ESP_Names = false,
    Chams = false,
    Tracer = false
}

local Window = Rayfield:CreateWindow({
   Name = "G&G V16.0 | THE EXECUTIONER",
   LoadingTitle = "Çekirdek Sistemlere Sızılıyor...",
   LoadingSubtitle = "Hazırlayan: Gökalp | OP Sürüm",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false 
})

-- [ SEKMELER ]
local CombatTab = Window:CreateTab("OP Combat ☠️", 4483362458)
local VisualsTab = Window:CreateTab("God ESP 👁️", 4483345998)
local SettingsTab = Window:CreateTab("Hit Ayarları ⚙️", 4483362458)

-- [ COMBAT ]
CombatTab:CreateToggle({
   Name = "🔥 OP Silent Aim (Mermi Yönlendirme)",
   CurrentValue = false,
   Callback = function(Value) _G.ExecConfig.SilentAim = Value end,
})

CombatTab:CreateToggle({
   Name = "🎯 Aimbot (Kamera Kilidi)",
   CurrentValue = false,
   Callback = function(Value) _G.ExecConfig.Aimbot = Value end,
})

CombatTab:CreateToggle({
   Name = "Hız Tahmini (Prediction - Koşanları Vurma)",
   CurrentValue = false,
   Callback = function(Value) _G.ExecConfig.Prediction = Value end,
})

CombatTab:CreateSlider({
   Name = "Görüş Alanı (FOV)",
   Range = {10, 800},
   Increment = 10,
   CurrentValue = 150,
   Callback = function(Value) _G.ExecConfig.FOV = Value end,
})

-- [ VISUALS ]
VisualsTab:CreateToggle({
   Name = "Box ESP (Kutu)",
   CurrentValue = false,
   Callback = function(Value) _G.ExecConfig.ESP_Boxes = Value end,
})

VisualsTab:CreateToggle({
   Name = "Chams ESP (Parlayan Gövde)",
   CurrentValue = false,
   Callback = function(Value) _G.ExecConfig.Chams = Value end,
})

VisualsTab:CreateToggle({
   Name = "Mermi İzi (Tracer)",
   CurrentValue = false,
   Callback = function(Value) _G.ExecConfig.Tracer = Value end,
})

-- [ SETTINGS ]
SettingsTab:CreateToggle({
   Name = "Takım Kontrolü (Team Check)",
   CurrentValue = true,
   Callback = function(Value) _G.ExecConfig.TeamCheck = Value end,
})

SettingsTab:CreateToggle({
   Name = "Duvar Kontrolü (Wall Check)",
   CurrentValue = true,
   Callback = function(Value) _G.ExecConfig.WallCheck = Value end,
})

-- [ ÇEKİRDEK KODLAR & OYUN MOTORU MANİPÜLASYONU ]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- FOV Dairesi
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 90
FOVCircle.Radius = _G.ExecConfig.FOV
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 0, 50)

-- Hedef Bulucu (En yakın ve koşulları sağlayan)
local function GetTarget()
    local target = nil
    local dist = _G.ExecConfig.FOV

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health > 0 then
                if _G.ExecConfig.TeamCheck and p.Team == LocalPlayer.Team then continue end

                local head = p.Character:FindFirstChild(_G.ExecConfig.HitPart)
                if not head then continue end

                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then
                        if _G.ExecConfig.WallCheck then
                            local ray = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 500)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, p.Character})
                            if hit then continue end
                        end
                        dist = mag
                        target = p
                    end
                end
            end
        end
    end
    return target
end

local CurrentTarget = nil

-- Döngü Güncellemeleri
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = (_G.ExecConfig.Aimbot or _G.ExecConfig.SilentAim)
    FOVCircle.Radius = _G.ExecConfig.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    CurrentTarget = GetTarget()

    -- Normal Aimbot + Prediction
    if _G.ExecConfig.Aimbot and CurrentTarget and CurrentTarget.Character then
        local targetPart = CurrentTarget.Character:FindFirstChild(_G.ExecConfig.HitPart)
        if targetPart then
            local aimPos = targetPart.Position
            -- Koşan adamı vurmak için hızı hesapla
            if _G.ExecConfig.Prediction then
                local velocity = CurrentTarget.Character.HumanoidRootPart.Velocity
                aimPos = aimPos + (velocity * _G.ExecConfig.PredValue)
            end
            
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), 0.5)
        end
    end
end)

-- [ ☠️ GERÇEK SILENT AIM SİSTEMİ (HOOKING) ☠️ ]
-- Oyunun Mermi Atma (Raycast/Mouse.Hit) fonksiyonlarını ele geçiriyoruz
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if _G.ExecConfig.SilentAim and CurrentTarget and CurrentTarget.Character then
        local targetPart = CurrentTarget.Character:FindFirstChild(_G.ExecConfig.HitPart)
        
        if targetPart then
            local aimPos = targetPart.Position
            if _G.ExecConfig.Prediction then
                local vel = CurrentTarget.Character.HumanoidRootPart.Velocity
                aimPos = aimPos + (vel * _G.ExecConfig.PredValue)
            end

            -- Eğer oyun Raycast kullanıyorsa:
            if method == "Raycast" then
                args[2] = (aimPos - args[1]).Unit * 1000 -- Mermiyi kafaya yönlendir
                return OldNamecall(self, unpack(args))
            
            -- Eğer oyun FindPartOnRay kullanıyorsa:
            elseif method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" or method == "FindPartOnRay" then
                args[1] = Ray.new(Camera.CFrame.Position, (aimPos - Camera.CFrame.Position).Unit * 1000)
                return OldNamecall(self, unpack(args))
            end
        end
    end
    return OldNamecall(self, ...)
end)

-- Oyun Mouse.Hit kullanıyorsa onu da ele geçirelim
local OldIndex
OldIndex = hookmetamethod(game, "__index", function(self, index)
    if _G.ExecConfig.SilentAim and CurrentTarget and CurrentTarget.Character then
        if self == Mouse and (index == "Hit" or index == "Target") then
            local targetPart = CurrentTarget.Character:FindFirstChild(_G.ExecConfig.HitPart)
            if targetPart then
                local aimPos = targetPart.Position
                if _G.ExecConfig.Prediction then
                    aimPos = aimPos + (CurrentTarget.Character.HumanoidRootPart.Velocity * _G.ExecConfig.PredValue)
                end
                if index == "Hit" then
                    return CFrame.new(aimPos)
                elseif index == "Target" then
                    return targetPart
                end
            end
        end
    end
    return OldIndex(self, index)
end)

-- [ 👁️ OPTIMIZE ESP SİSTEMİ ]
local function ManageESP(p)
    if p == LocalPlayer then return end

    local charAddedCon
    charAddedCon = p.CharacterAdded:Connect(function(char)
        -- Chams (En güvenli performans ESP'si)
        local high = Instance.new("Highlight")
        high.Parent = char
        high.FillTransparency = 0.5
        high.OutlineTransparency = 0.1
        
        -- Box ESP (Drawing API yerine BillboardGui kullanarak ban riskini azalttık)
        local bbg = Instance.new("BillboardGui", game:GetService("CoreGui"))
        bbg.AlwaysOnTop = true
        bbg.Size = UDim2.new(4, 0, 5, 5)
        bbg.Adornee = char:WaitForChild("HumanoidRootPart", 5)
        
        local box = Instance.new("Frame", bbg)
        box.Size = UDim2.new(1, 0, 1, 0)
        box.BackgroundTransparency = 1
        local stroke = Instance.new("UIStroke", box)
        stroke.Thickness = 2
        stroke.Color = Color3.fromRGB(255, 0, 0)

        RunService.Heartbeat:Connect(function()
            if char and char:Parent() then
                local isEnemy = not (_G.ExecConfig.TeamCheck and p.Team == LocalPlayer.Team)
                
                high.Enabled = _G.ExecConfig.Chams and isEnemy
                high.FillColor = (p.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Color3.new(1,0,0)
                
                bbg.Enabled = _G.ExecConfig.ESP_Boxes and isEnemy
                stroke.Color = high.FillColor
            else
                high:Destroy() bbg:Destroy()
            end
        end)
    end)
    if p.Character then p.CharacterAdded:Fire(p.Character) end
end

for _,p in pairs(Players:GetPlayers()) do ManageESP(p) end
Players.PlayerAdded:Connect(ManageESP)

Rayfield:Notify({
   Title = "THE EXECUTIONER AKTİF",
   Content = "Silent Aim ve Prediction devrede. Metamethodlar başarıyla kancalandı.",
   Duration = 5,
   Image = 4483362458,
})
