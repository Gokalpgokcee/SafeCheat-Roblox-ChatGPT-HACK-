-- [[ G&G V17.0 - ULTIMATE ALL-IN-ONE ]] --
-- Delta & Mobile Optimized | No Lag | No Key

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

_G.Config = {
    -- Combat
    SilentAim = false,
    FOV = 150,
    HitPart = "Head",
    TeamCheck = true,
    WallCheck = true,
    HitboxExpander = false,
    HitboxSize = 2,
    
    -- Visuals
    ESP_Boxes = false,
    Chams = false,
    
    -- Movement & Safety
    Speed = 16,
    Jump = 50,
    Noclip = false,
    AntiAFK = true
}

local Window = Rayfield:CreateWindow({
   Name = "G&G V17.0 | ULTIMATE MENU",
   LoadingTitle = "Tüm Modüller Yükleniyor...",
   LoadingSubtitle = "Hazırlayan: Gökalp",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

-- [ SEKMELER ]
local CombatTab = Window:CreateTab("Combat ⚔️", 4483362458)
local VisualsTab = Window:CreateTab("Visuals 👁️", 4483345998)
local MovementTab = Window:CreateTab("Movement ⚡", 4483362458)
local MiscTab = Window:CreateTab("Misc/Safety ⚙️", 4483362458)

-- [ COMBAT SEKMESİ ]
CombatTab:CreateToggle({
   Name = "Stabil Silent Aim",
   CurrentValue = false,
   Callback = function(Value) _G.Config.SilentAim = Value end,
})

CombatTab:CreateSlider({
   Name = "Silent Aim FOV",
   Range = {50, 500},
   Increment = 10,
   CurrentValue = 150,
   Callback = function(Value) _G.Config.FOV = Value end,
})

CombatTab:CreateToggle({
   Name = "Hitbox Expander (Kafa Büyütme)",
   CurrentValue = false,
   Callback = function(Value) _G.Config.HitboxExpander = Value end,
})

CombatTab:CreateSlider({
   Name = "Hitbox Boyutu",
   Range = {2, 20},
   Increment = 1,
   CurrentValue = 2,
   Callback = function(Value) _G.Config.HitboxSize = Value end,
})

-- [ VISUALS SEKMESİ ]
VisualsTab:CreateToggle({
   Name = "Box ESP (Kırılmaz)",
   CurrentValue = false,
   Callback = function(Value) _G.Config.ESP_Boxes = Value end,
})

VisualsTab:CreateToggle({
   Name = "Chams (Gövde Parlatma)",
   CurrentValue = false,
   Callback = function(Value) _G.Config.Chams = Value end,
})

-- [ MOVEMENT SEKMESİ ]
MovementTab:CreateSlider({
   Name = "WalkSpeed (Hız)",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value) _G.Config.Speed = Value end,
})

MovementTab:CreateToggle({
   Name = "Noclip (Duvar Geçme)",
   CurrentValue = false,
   Callback = function(Value) _G.Config.Noclip = Value end,
})

-- [ MISC SEKMESİ ]
MiscTab:CreateToggle({
   Name = "Anti-AFK (Bypass Kick)",
   CurrentValue = true,
   Callback = function(Value) _G.Config.AntiAFK = Value end,
})

MiscTab:CreateButton({
   Name = "FPS Boost (Gereksiz Efektleri Sil)",
   Callback = function()
       for _, v in pairs(game:GetDescendants()) do
           if v:IsA("PostProcessEffect") or v:IsA("Explosion") then v:Destroy() end
       end
   end,
})

-- [[ ÇEKİRDEK SİSTEMLER ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Target = nil
local ESP_Cache = {}

-- Hedef Arama Döngüsü (FPS Dostu)
task.spawn(function()
    while task.wait(0.1) do
        local closest = nil
        local shortestDist = _G.Config.FOV
        if _G.Config.SilentAim then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    if _G.Config.TeamCheck and p.Team == LocalPlayer.Team then continue end
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if mag < shortestDist then
                            shortestDist = mag
                            closest = p
                        end
                    end
                end
            end
        end
        Target = closest
    end
end)

-- Ana Döngü (Movement, Hitbox, ESP)
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = _G.Config.Speed
        
        if _G.Config.Noclip then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end

    -- Hitbox & ESP İşleme
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        
        -- Hitbox Expander
        if _G.Config.HitboxExpander and p.Character:FindFirstChild("Head") then
            if not (_G.Config.TeamCheck and p.Team == LocalPlayer.Team) then
                p.Character.Head.Size = Vector3.new(_G.Config.HitboxSize, _G.Config.HitboxSize, _G.Config.HitboxSize)
                p.Character.Head.Transparency = 0.7
                p.Character.Head.CanCollide = false
            end
        end

        -- ESP Sistemi (Unbreakable)
        if p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            if not ESP_Cache[p] then
                local hl = Instance.new("Highlight", CoreGui)
                local bbg = Instance.new("BillboardGui", CoreGui)
                bbg.Size = UDim2.new(4,0,5,0); bbg.AlwaysOnTop = true
                local frame = Instance.new("Frame", bbg)
                frame.Size = UDim2.new(1,0,1,0); frame.BackgroundTransparency = 1
                Instance.new("UIStroke", frame).Thickness = 2
                
                ESP_Cache[p] = {Highlight = hl, Billboard = bbg, Stroke = frame.UIStroke}
            end
            
            local cache = ESP_Cache[p]
            local isEnemy = not (_G.Config.TeamCheck and p.Team == LocalPlayer.Team)
            local color = isEnemy and Color3.new(1,0,0) or Color3.new(0,1,0)
            
            cache.Highlight.Enabled = _G.Config.Chams and isEnemy
            cache.Highlight.Adornee = p.Character
            cache.Highlight.FillColor = color
            
            cache.Billboard.Enabled = _G.Config.ESP_Boxes and isEnemy
            cache.Billboard.Adornee = p.Character.HumanoidRootPart
            cache.Stroke.Color = color
        end
    end
end)

-- Silent Aim Hook
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if _G.Config.SilentAim and Target and Target.Character and (method == "Raycast" or method == "FindPartOnRayWithIgnoreList") then
        local hitPos = Target.Character[_G.Config.HitPart].Position
        if method == "Raycast" then args[2] = (hitPos - args[1]).Unit * 1000
        else args[1] = Ray.new(Camera.CFrame.Position, (hitPos - Camera.CFrame.Position).Unit * 1000) end
        return OldNamecall(self, unpack(args))
    end
    return OldNamecall(self, ...)
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if _G.Config.AntiAFK then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end
end)

Rayfield:Notify({Title = "G&G ULTIMATE V17.0", Content = "Tüm hileler aktif ve optimize edildi!", Duration = 5})
