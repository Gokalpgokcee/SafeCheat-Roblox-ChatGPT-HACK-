-- [[ G&G V21.1 - ENGINE FIX EDITION ]] --
-- Aimbot, Triggerbot ve ESP tamamen onarıldı!

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Settings = {
    SilentAim = false,
    Aimbot = false,
    Triggerbot = false,
    FOV = 150,
    Smoothness = 0.25,
    HitPart = "Head",
    Hitbox = false,
    HitboxSize = 4,
    ESP = false,
    TeamCheck = true
}

local Window = Rayfield:CreateWindow({
    Name = "G&G V21.1 | ENGINE FIX",
    LoadingTitle = "Hatalar Onarıldı...",
    LoadingSubtitle = "By Gokalp",
})

local Combat = Window:CreateTab("Combat ⚔️")
local Visuals = Window:CreateTab("Visuals 👁️")

-- [ ARAYÜZ ]
Combat:CreateToggle({Name = "True Silent Aim", CurrentValue = false, Callback = function(v) Settings.SilentAim = v end})
Combat:CreateToggle({Name = "Aimbot (Kamera Kilidi)", CurrentValue = false, Callback = function(v) Settings.Aimbot = v end})
Combat:CreateToggle({Name = "Triggerbot (Otomatik Ateş)", CurrentValue = false, Callback = function(v) Settings.Triggerbot = v end})
Combat:CreateSlider({Name = "FOV Mesafesi", Range = {50, 500}, Increment = 5, CurrentValue = 150, Callback = function(v) Settings.FOV = v end})
Combat:CreateToggle({Name = "Hitbox Expander", CurrentValue = false, Callback = function(v) Settings.Hitbox = v end})

Visuals:CreateToggle({Name = "Highlight ESP", CurrentValue = false, Callback = function(v) Settings.ESP = v end})

-- [ SERVİSLER ]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-- [ FOV ÇEMBERİ ]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local FOVFrame = Instance.new("Frame", ScreenGui)
FOVFrame.BackgroundTransparency = 1
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
local UIStroke = Instance.new("UIStroke", FOVFrame); UIStroke.Color = Color3.new(1,1,1); UIStroke.Thickness = 1
local UICorner = Instance.new("UICorner", FOVFrame); UICorner.CornerRadius = UDim.new(1, 0)

-- [ HEDEF SİSTEMİ ]
local Target = nil
task.spawn(function()
    while task.wait(0.1) do
        local closest, dist = nil, Settings.FOV
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        
        FOVFrame.Position = UDim2.new(0, center.X, 0, center.Y)
        FOVFrame.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
        FOVFrame.Visible = Settings.SilentAim or Settings.Aimbot

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if mag < dist then dist = mag; closest = p end
                    end
                end
            end
        end
        Target = closest
    end
end)

-- [ KAMERA (AIMBOT) & TRIGGERBOT DÖNGÜSÜ - RENDERSTEPPED ]
local LastShot = 0
RunService.RenderStepped:Connect(function()
    -- Kamera her zaman RenderStepped içinde yönlendirilmeli!
    if Settings.Aimbot and Target and Target.Character and Target.Character:FindFirstChild(Settings.HitPart) then
        local targetPos = Target.Character[Settings.HitPart].Position
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPos), Settings.Smoothness)
    end
    
    -- Triggerbot (Kasmaması için bekleme süresini 'tick()' ile çözdük)
    if Settings.Triggerbot and Target then
        if tick() - LastShot > 0.1 then -- Saniyede 10 kez tıklar (Hata vermez)
            LastShot = tick()
            VirtualUser:ClickButton1(Vector2.new(0,0))
        end
    end
end)

-- [ ESP & HITBOX DÖNGÜSÜ - HEARTBEAT ]
RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        
        -- Hitbox
        if Settings.Hitbox and p.Character:FindFirstChild("Head") then
            if p.Character.Head.Size.X ~= Settings.HitboxSize then
                p.Character.Head.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                p.Character.Head.Transparency = 0.6
                p.Character.Head.CanCollide = false
            end
        end

        -- ESP (CoreGui yerine Character içine atıldı, Delta artık görecek)
        local hl = p.Character:FindFirstChild("GG_Highlight")
        if Settings.ESP and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "GG_Highlight"
                hl.Parent = p.Character -- Delta mobilde hata vermemesi için direkt karaktere eklendi
            end
            hl.Enabled = not (Settings.TeamCheck and p.Team == LocalPlayer.Team)
            hl.FillColor = (p.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Color3.new(1,0,0)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
        else
            if hl then hl:Destroy() end
        end
    end
end)

-- [ SILENT AIM ]
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if Settings.SilentAim and Target and Target.Character and (method == "Raycast" or method == "FindPartOnRayWithIgnoreList") then
        local tPart = Target.Character:FindFirstChild(Settings.HitPart)
        if tPart then
            if method == "Raycast" then args[2] = (tPart.Position - args[1]).Unit * 1000
            else args[1] = Ray.new(Camera.CFrame.Position, (tPart.Position - Camera.CFrame.Position).Unit * 1000) end
            return OldNamecall(self, unpack(args))
        end
    end
    return OldNamecall(self, ...)
end)

Rayfield:Notify({Title = "G&G V21.1", Content = "Motor arızası giderildi. Sistem stabil.", Duration = 4})
