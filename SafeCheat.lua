-- [[ G&G V21 - THE ASCENSION ]] --
-- Final Masterpiece | Triggerbot | Aim Assist | Ultra-Smooth

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Settings = {
    SilentAim = false,
    Aimbot = false,
    AimAssist = false, -- Yeni: Hafif çekim
    Triggerbot = false, -- Yeni: Otomatik ateş
    FOV = 150,
    Smoothness = 0.25,
    HitPart = "Head",
    Hitbox = false,
    HitboxSize = 4,
    ESP = false,
    TeamCheck = true
}

local Window = Rayfield:CreateWindow({
    Name = "G&G V21 | THE ASCENSION",
    LoadingTitle = "Efsane Tamamlanıyor...",
    LoadingSubtitle = "By Gokalp - Final Edition",
})

local Combat = Window:CreateTab("Combat ⚔️")
local Visuals = Window:CreateTab("Visuals 👁️")

-- [ COMBAT SEKMESİ ]
Combat:CreateToggle({Name = "True Silent Aim", CurrentValue = false, Callback = function(v) Settings.SilentAim = v end})
Combat:CreateToggle({Name = "Aim Assist (Soft Lock)", CurrentValue = false, Callback = function(v) Settings.AimAssist = v end})
Combat:CreateToggle({Name = "Triggerbot (Auto-Fire)", CurrentValue = false, Callback = function(v) Settings.Triggerbot = v end})
Combat:CreateSlider({Name = "FOV Mesafesi", Range = {50, 500}, Increment = 5, CurrentValue = 150, Callback = function(v) Settings.FOV = v end})
Combat:CreateToggle({Name = "Hitbox Expander", CurrentValue = false, Callback = function(v) Settings.Hitbox = v end})

Visuals:CreateToggle({Name = "Master Highlight ESP", CurrentValue = false, Callback = function(v) Settings.ESP = v end})

-- [ CORE LOGIC ]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-- [ SCREEN GUI FOV ]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local FOVFrame = Instance.new("Frame", ScreenGui)
FOVFrame.BackgroundTransparency = 1
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
local UIStroke = Instance.new("UIStroke", FOVFrame); UIStroke.Color = Color3.new(1,1,1)
local UICorner = Instance.new("UICorner", FOVFrame); UICorner.CornerRadius = UDim.new(1, 0)

-- [ HEDEF SİSTEMİ ]
local Target = nil
task.spawn(function()
    while task.wait(0.1) do
        local closest, dist = nil, Settings.FOV
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        
        FOVFrame.Position = UDim2.new(0, center.X, 0, center.Y)
        FOVFrame.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
        FOVFrame.Visible = Settings.SilentAim or Settings.AimAssist

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

-- [ MASTER LOOP: AIM ASSIST, TRIGGERBOT, ESP, HITBOX ]
local ESP_Cache = {}
RunService.Heartbeat:Connect(function()
    -- 1. Aim Assist (Yumuşak Takip)
    if Settings.AimAssist and Target and Target.Character and Target.Character:FindFirstChild(Settings.HitPart) then
        local targetPos = Target.Character[Settings.HitPart].Position
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPos), Settings.Smoothness)
    end

    -- 2. Triggerbot (Ekranda düşman varken otomatik tıkla)
    if Settings.Triggerbot and Target then
        VirtualUser:Button1Down(Vector2.new(0,0))
        task.wait(0.05)
        VirtualUser:Button1Up(Vector2.new(0,0))
    end

    -- 3. ESP & Hitbox
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

        -- ESP
        if not ESP_Cache[p] then
            ESP_Cache[p] = Instance.new("Highlight", CoreGui)
        end
        local hl = ESP_Cache[p]
        if Settings.ESP and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            hl.Adornee = p.Character
            hl.Enabled = not (Settings.TeamCheck and p.Team == LocalPlayer.Team)
            hl.FillColor = (p.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Color3.new(1,0,0)
        else
            hl.Enabled = false
        end
    end
end)

-- [ SILENT AIM HOOK ]
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

Rayfield:Notify({Title = "G&G V21 FINAL", Content = "Yükseliş Tamamlandı. Keyfini çıkar Gökalp!", Duration = 5})
