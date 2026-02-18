-- [[ G&G V16.2 - UNIVERSAL SILENT AIM FIX ]] --
-- Delta & Mobile Optimized | Metamethod + Mouse Hooking

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

_G.ExecConfig = {
    SilentAim = false,
    Aimbot = false,
    Prediction = false,
    PredValue = 0.165,
    FOV = 150,
    HitPart = "Head",
    WallCheck = true,
    TeamCheck = true,
    ESP_Boxes = false,
    Chams = false,
}

local Window = Rayfield:CreateWindow({
   Name = "G&G V16.2 | SILENT AIM FIX",
   LoadingTitle = "Silent Aim Sistemleri Onarılıyor...",
   LoadingSubtitle = "Hazırlayan: Gökalp",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local CombatTab = Window:CreateTab("OP Combat ☠️", 4483362458)
local VisualsTab = Window:CreateTab("God ESP 👁️", 4483345998)

CombatTab:CreateToggle({ Name = "🔥 OP Silent Aim", CurrentValue = false, Callback = function(Value) _G.ExecConfig.SilentAim = Value end })
CombatTab:CreateToggle({ Name = "🎯 Aimbot (Kamera)", CurrentValue = false, Callback = function(Value) _G.ExecConfig.Aimbot = Value end })
CombatTab:CreateSlider({ Name = "Görüş Alanı (FOV)", Range = {10, 800}, Increment = 10, CurrentValue = 150, Callback = function(Value) _G.ExecConfig.FOV = Value end })

VisualsTab:CreateToggle({ Name = "Box ESP", CurrentValue = false, Callback = function(Value) _G.ExecConfig.ESP_Boxes = Value end })
VisualsTab:CreateToggle({ Name = "Chams ESP", CurrentValue = false, Callback = function(Value) _G.ExecConfig.Chams = Value end })

-- [ TEMEL DEĞİŞKENLER ]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

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

local CurrentTarget = nil

-- [ ☠️ YENİ NESİL SILENT AIM SİSTEMİ ☠️ ]

-- 1. KATMAN: __index Hooking (Mouse.Hit ve Mouse.Target Manipülasyonu)
-- Birçok oyun mermiyi farenin ucuna göre atar. Fareyi değil, farenin "değerini" kandırıyoruz.
local OldIndex
OldIndex = hookmetamethod(game, "__index", function(self, index)
    if not checkcaller() and _G.ExecConfig.SilentAim and self == Mouse and (index == "Hit" or index == "Target") then
        CurrentTarget = GetTarget()
        if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild(_G.ExecConfig.HitPart) then
            local targetPart = CurrentTarget.Character[_G.ExecConfig.HitPart]
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
    return OldIndex(self, index)
end)

-- 2. KATMAN: __namecall Hooking (Raycast ve FindPartOnRay Manipülasyonu)
-- Daha profesyonel oyunlar (Arsenal vb.) Raycast kullanır.
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if not checkcaller() and _G.ExecConfig.SilentAim and (method == "Raycast" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay") then
        CurrentTarget = GetTarget()
        if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild(_G.ExecConfig.HitPart) then
            local targetPart = CurrentTarget.Character[_G.ExecConfig.HitPart]
            local aimPos = targetPart.Position

            if _G.ExecConfig.Prediction then
                aimPos = aimPos + (CurrentTarget.Character.HumanoidRootPart.Velocity * _G.ExecConfig.PredValue)
            end

            if method == "Raycast" then
                -- args[1] Origin, args[2] Direction
                args[2] = (aimPos - args[1]).Unit * 1000
                return OldNamecall(self, unpack(args))
            elseif method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
                args[1] = Ray.new(Camera.CFrame.Position, (aimPos - Camera.CFrame.Position).Unit * 1000)
                return OldNamecall(self, unpack(args))
            end
        end
    end
    return OldNamecall(self, ...)
end)

-- Ana Döngü (Aimbot & ESP Update)
RunService.RenderStepped:Connect(function()
    CurrentTarget = GetTarget()
    
    if _G.ExecConfig.Aimbot and CurrentTarget and CurrentTarget.Character then
        local targetPart = CurrentTarget.Character:FindFirstChild(_G.ExecConfig.HitPart)
        if targetPart then
            local aimPos = targetPart.Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), 0.5)
        end
    end
end)

-- ESP Kodlarını (V16.1'deki gibi) buraya ekleyebilirsin, onlar zaten CoreGui'de çalışıyor.

Rayfield:Notify({
   Title = "V16.2 SILENT AIM FIXED",
   Content = "Metamethod + Mouse Hook aktif. Şimdi vurmayı dene!",
   Duration = 5
})
