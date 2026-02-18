-- [[ G&G V16.3 - MOBILE TOUCH-FORCE EDITION ]] --
-- Delta & Mobile Optimized | Direct Touch Manipulation

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

_G.ExecConfig = {
    SilentAim = false,
    Aimbot = false,
    Prediction = false,
    PredValue = 0.165,
    FOV = 200, -- Mobilde FOV'u biraz daha geniş tutmak iyidir
    HitPart = "Head",
    WallCheck = true,
    TeamCheck = true,
    ESP_Boxes = false,
    Chams = false,
}

local Window = Rayfield:CreateWindow({
   Name = "G&G V16.3 | MOBILE TOUCH FIX",
   LoadingTitle = "Dokunmatik Sistemler Manipüle Ediliyor...",
   LoadingSubtitle = "Hazırlayan: Gökalp",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local CombatTab = Window:CreateTab("OP Combat ☠️", 4483362458)
local VisualsTab = Window:CreateTab("God ESP 👁️", 4483345998)

CombatTab:CreateToggle({ Name = "🔥 OP Silent Aim", CurrentValue = false, Callback = function(Value) _G.ExecConfig.SilentAim = Value end })
CombatTab:CreateSlider({ Name = "Görüş Alanı (FOV)", Range = {10, 800}, Increment = 10, CurrentValue = 200, Callback = function(Value) _G.ExecConfig.FOV = Value end })

VisualsTab:CreateToggle({ Name = "Box ESP", CurrentValue = false, Callback = function(Value) _G.ExecConfig.ESP_Boxes = Value end })
VisualsTab:CreateToggle({ Name = "Chams ESP", CurrentValue = false, Callback = function(Value) _G.ExecConfig.Chams = Value end })

-- [ TEMEL DEĞİŞKENLER ]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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

-- [ ☠️ MOBİL DOKUNMATİK MANİPÜLASYONU ☠️ ]

local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and _G.ExecConfig.SilentAim then
        CurrentTarget = GetTarget()
        
        if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild(_G.ExecConfig.HitPart) then
            local targetPart = CurrentTarget.Character[_G.ExecConfig.HitPart]
            local aimPos = targetPart.Position
            
            -- Mobil mermi ve dokunmatik vuruş metodlarını yakalıyoruz
            if method == "Raycast" or method == "FindPartOnRayWithIgnoreList" or method == "FireServer" then
                -- Eğer oyun bir mermi veya hasar "RemoteEvent" (FireServer) kullanıyorsa
                -- Bazı oyunlar direkt pozisyonu bu yolla gönderir.
                for i, arg in pairs(args) do
                    if typeof(arg) == "Vector3" then
                        args[i] = aimPos -- Pozisyonu kafaya çevir
                    elseif typeof(arg) == "CFrame" then
                        args[i] = CFrame.new(aimPos) -- CFrame ise kafaya çevir
                    end
                end
                
                -- Raycast için yönü düzelt
                if method == "Raycast" then
                    args[2] = (aimPos - args[1]).Unit * 1000
                end
                
                return OldNamecall(self, unpack(args))
            end
        end
    end
    return OldNamecall(self, ...)
end)

-- [ GÖRSEL FOV DAİRESİ (EKRANA DOKUNUNCA GÖRMEN İÇİN) ]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Radius = _G.ExecConfig.FOV
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Transparency = 0.5

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = _G.ExecConfig.SilentAim
    FOVCircle.Radius = _G.ExecConfig.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    CurrentTarget = GetTarget()
end)
