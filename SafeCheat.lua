-- [[ G&G V22 - DRAWING API EDITION ]] --
-- ESP tamamen Drawing API'ye taşındı.
-- Aimbot ve Triggerbot Mobile için optimize edildi.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Settings = {
    Aimbot = false,
    SilentAim = false,
    Triggerbot = false,
    FOV = 150,
    Smoothness = 0.2, -- 0 ile 1 arası (0.1 çok yavaş, 1 anlık)
    HitPart = "Head",
    ESP = false,
    Tracers = false,
    TeamCheck = true,
    Hitbox = false,
    HitboxSize = 4
}

local Window = Rayfield:CreateWindow({
    Name = "G&G V22 | DRAWING API",
    LoadingTitle = "Çizim Motoru Hazırlanıyor...",
    LoadingSubtitle = "by Gokalp",
})

local Combat = Window:CreateTab("Combat ⚔️")
local Visuals = Window:CreateTab("Visuals 👁️")

-- [ UI ]
Combat:CreateToggle({Name = "Aimbot (Lock)", CurrentValue = false, Callback = function(v) Settings.Aimbot = v end})
Combat:CreateToggle({Name = "Silent Aim", CurrentValue = false, Callback = function(v) Settings.SilentAim = v end})
Combat:CreateToggle({Name = "Triggerbot", CurrentValue = false, Callback = function(v) Settings.Triggerbot = v end})
Combat:CreateSlider({Name = "FOV", Range = {50, 500}, Increment = 5, CurrentValue = 150, Callback = function(v) Settings.FOV = v end})
Combat:CreateToggle({Name = "Hitbox Expander", CurrentValue = false, Callback = function(v) Settings.Hitbox = v end})

Visuals:CreateToggle({Name = "Box ESP (Drawing)", CurrentValue = false, Callback = function(v) Settings.ESP = v end})
Visuals:CreateToggle({Name = "Tracers (Çizgiler)", CurrentValue = false, Callback = function(v) Settings.Tracers = v end})

-- [ SERVİSLER ]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- [ DRAWING API ESP SİSTEMİ ]
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.new(1, 0, 0)
    Box.Thickness = 1
    Box.Filled = false

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = Color3.new(1, 1, 1)
    Tracer.Thickness = 1

    local function Update()
        local Connection
        Connection = RunService.RenderStepped:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
                local RootPart = Player.Character.HumanoidRootPart
                local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)

                if OnScreen and Settings.ESP then
                    if Settings.TeamCheck and Player.Team == LocalPlayer.Team then
                        Box.Visible = false
                        Tracer.Visible = false
                    else
                        -- Kutu Boyut Hesaplama
                        local Size = (Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, 2.6, 0)).Y)
                        Box.Size = Vector2.new(Size * 0.6, Size)
                        Box.Position = Vector2.new(Pos.X - Box.Size.X / 2, Pos.Y - Box.Size.Y / 2)
                        Box.Visible = true

                        -- Tracer (Çizgi)
                        if Settings.Tracers then
                            Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            Tracer.To = Vector2.new(Pos.X, Pos.Y)
                            Tracer.Visible = true
                        else
                            Tracer.Visible = false
                        end
                    end
                else
                    Box.Visible = false
                    Tracer.Visible = false
                end
            else
                Box.Visible = false
                Tracer.Visible = false
                if not Player.Parent then
                    Box:Remove()
                    Tracer:Remove()
                    Connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Update)()
end

-- Mevcut oyunculara uygula
for _, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then CreateESP(v) end
end
Players.PlayerAdded:Connect(function(v) CreateESP(v) end)

-- [ HEDEF BULUCU ]
local Target = nil
task.spawn(function()
    while task.wait(0.1) do
        local closest, dist = nil, Settings.FOV
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < dist then dist = mag; closest = p end
                end
            end
        end
        Target = closest
    end
end)

-- [ AIMBOT & TRIGGERBOT DÖNGÜSÜ ]
RunService.RenderStepped:Connect(function()
    -- Aimbot
    if Settings.Aimbot and Target and Target.Character and Target.Character:FindFirstChild(Settings.HitPart) then
        local targetPos = Target.Character[Settings.HitPart].Position
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPos), Settings.Smoothness)
    end

    -- Triggerbot (Mobile Click Fix)
    if Settings.Triggerbot and Target then
        -- Bazı oyunlarda mouse1click() veya mouse1press() daha iyi çalışır
        if mouse1click then
            mouse1click()
        elseif click_detector then -- Alternatif mobil metod
            click_detector()
        else
            game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
            task.wait()
            game:GetService("VirtualUser"):Button1Up(Vector2.new(0,0))
        end
    end
    
    -- Hitbox (Loop yerine RenderStepped içinde kontrol daha sağlamdır)
    if Settings.Hitbox then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                if not (Settings.TeamCheck and p.Team == LocalPlayer.Team) then
                    p.Character.Head.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    p.Character.Head.Transparency = 0.5
                    p.Character.Head.CanCollide = false
                end
            end
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

Rayfield:Notify({Title = "G&G V22", Content = "Drawing API Devreye Girdi!", Duration = 3})
