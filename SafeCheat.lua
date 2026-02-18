-- [[ G&G V8.1 - OP TAB FIX & POLISHED EDITION ]]
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")

-- [AYARLAR]
_G.SafeCheatConfig = {
    -- Combat (Safe)
    Aimbot = false, ShowFOV = false, AimSmoothness = 0.1, AimbotFOV = 150, WallCheck = true,
    LegitHitbox = false,
    -- Visuals
    Box = false, HealthBar = false, Traces = false, RGB_Mode = false,
    -- Player
    InfJump = false, Fullbright = false,
    -- OP (Bannable)
    RageHitbox = false, Noclip = false, SpeedOverride = false, Speed = 35, JumpOverride = false, Jump = 100,
    Key = "SafecheatGökalp"
}

-- [GÖRSEL ÇİZİMLER]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8
FOVCircle.Color = Color3.fromRGB(0, 255, 255)

local espCache = {}
local function RemoveESP(player)
    if espCache[player] then
        espCache[player].B:Remove()
        espCache[player].L:Remove()
        espCache[player].H:Remove()
        espCache[player] = nil
    end
end
Players.PlayerRemoving:Connect(RemoveESP) -- Hayalet ESP (Oyundan Çıkanlar) Fixlendi

-- [GUI TASARIMI]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
local Stroke = Instance.new("UIStroke", MainFrame) Stroke.Color = Color3.fromRGB(0, 255, 255) Stroke.Thickness = 2

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Sidebar)

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1,0,0,50) Title.Text = "G&G V8.1" Title.TextColor3 = Color3.fromRGB(0, 255, 255) Title.Font = Enum.Font.GothamBold Title.BackgroundTransparency = 1

local Pages = {
    Combat = Instance.new("ScrollingFrame", MainFrame),
    Visuals = Instance.new("ScrollingFrame", MainFrame),
    Player = Instance.new("ScrollingFrame", MainFrame),
    OP = Instance.new("ScrollingFrame", MainFrame) -- Sorunlu sekme burasıydı
}

for n, p in pairs(Pages) do
    p.Size = UDim2.new(1, -155, 1, -20) p.Position = UDim2.new(0, 145, 0, 10)
    p.BackgroundTransparency = 1 p.Visible = false p.ScrollBarThickness = 2
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)
end
Pages.Combat.Visible = true -- Varsayılan açık sekme

-- [UI BİLEŞENLERİ]
local function CreateButton(parent, text, config, isWarning)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 35) b.BackgroundColor3 = Color3.fromRGB(20,20,20)
    b.Text = "  " .. text b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextColor3 = isWarning and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(180,180,180) b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    local s = Instance.new("UIStroke", b) s.Color = Color3.fromRGB(40,40,40)

    b.MouseButton1Click:Connect(function()
        _G.SafeCheatConfig[config] = not _G.SafeCheatConfig[config]
        local act = _G.SafeCheatConfig[config]
        b.TextColor3 = act and Color3.fromRGB(0, 255, 255) or (isWarning and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(180,180,180))
        s.Color = act and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(40,40,40)
    end)
end

local function CreateSlider(parent, text, min, max, config)
    local f = Instance.new("Frame", parent) f.Size = UDim2.new(1,-10,0,45) f.BackgroundColor3 = Color3.fromRGB(20,20,20) Instance.new("UICorner", f)
    local l = Instance.new("TextLabel", f) l.Size = UDim2.new(1,0,0,20) l.Text = text .. ": " .. _G.SafeCheatConfig[config] l.TextColor3 = Color3.new(1,1,1) l.BackgroundTransparency = 1
    local b = Instance.new("Frame", f) b.Size = UDim2.new(0.9,0,0,6) b.Position = UDim2.new(0.05,0,0.6,0) b.BackgroundColor3 = Color3.fromRGB(40,40,40) Instance.new("UICorner", b)
    local d = Instance.new("TextButton", b) d.Size = UDim2.new(0,16,0,16) d.Position = UDim2.new(0,0,-0.8,0) d.Text = "" d.BackgroundColor3 = Color3.fromRGB(0,255,255) Instance.new("UICorner", d)
    
    local isDragging = false
    d.MouseButton1Down:Connect(function() isDragging = true end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isDragging = false end end)
    
    RunService.RenderStepped:Connect(function()
        if isDragging then
            local x = math.clamp((Mouse.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
            d.Position = UDim2.new(x, -8, -0.8, 0)
            local val = math.floor(min + (max-min) * x)
            _G.SafeCheatConfig[config] = val
            l.Text = text .. ": " .. val
        end
    end)
end

-- [İÇERİK EKLEME]
-- Combat (Safe)
CreateButton(Pages.Combat, "Aimbot Master", "Aimbot", false)
CreateButton(Pages.Combat, "Show FOV Circle", "ShowFOV", false)
CreateButton(Pages.Combat, "Wall Check (Legit)", "WallCheck", false)
CreateButton(Pages.Combat, "Legit Hitbox (Safe)", "LegitHitbox", false)
CreateSlider(Pages.Combat, "Aimbot FOV", 50, 600, "AimbotFOV")

-- Visuals
CreateButton(Pages.Visuals, "Box ESP (Boş Kutu)", "Box", false)
CreateButton(Pages.Visuals, "Health Bar", "HealthBar", false)
CreateButton(Pages.Visuals, "Traces", "Traces", false)
CreateButton(Pages.Visuals, "RGB UI Mode", "RGB_Mode", false)

-- Player
CreateButton(Pages.Player, "Infinite Jump (Fix)", "InfJump", false)
CreateButton(Pages.Player, "Fullbright", "Fullbright", false)

-- OP (Bannable) - DÜZELTİLEN YER
CreateButton(Pages.OP, "RAGE Hitbox (BANNABLE!)", "RageHitbox", true)
CreateButton(Pages.OP, "Noclip (Duvar Geçme)", "Noclip", true)
CreateButton(Pages.OP, "Enable Speed Hack", "SpeedOverride", true)
CreateSlider(Pages.OP, "WalkSpeed", 16, 150, "Speed")
CreateButton(Pages.OP, "Enable Super Jump", "JumpOverride", true)
CreateSlider(Pages.OP, "JumpPower", 50, 300, "Jump")

-- [CORE DÖNGÜ]
RunService.RenderStepped:Connect(function()
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    if _G.SafeCheatConfig.RGB_Mode then Stroke.Color = color FOVCircle.Color = color end

    -- FOV Update
    FOVCircle.Visible = _G.SafeCheatConfig.ShowFOV
    FOVCircle.Radius = _G.SafeCheatConfig.AimbotFOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    -- Hız ve Zıplama Mantığı (Artık kendi kendine bozulmaz)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if _G.SafeCheatConfig.SpeedOverride then hum.WalkSpeed = _G.SafeCheatConfig.Speed end
        if _G.SafeCheatConfig.JumpOverride then hum.JumpPower = _G.SafeCheatConfig.Jump end
    end

    local aimTarget = nil
    local shortestDist = _G.SafeCheatConfig.AimbotFOV

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") then
            local root = p.Character.HumanoidRootPart
            local head = p.Character.Head
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                -- HITBOX LOGIC
                if _G.SafeCheatConfig.RageHitbox then
                    head.Size = Vector3.new(10, 10, 10) head.Transparency = 0.6 head.CanCollide = false
                elseif _G.SafeCheatConfig.LegitHitbox then
                    head.Size = Vector3.new(2.5, 2.5, 2.5) head.Transparency = 0.8 head.CanCollide = false
                end

                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)

                -- ESP Caching & Update
                if not espCache[p] then espCache[p] = {B = Drawing.new("Square"), L = Drawing.new("Line"), H = Drawing.new("Square")} end
                local obj = espCache[p]

                if onScreen then
                    local size = 2500 / pos.Z
                    
                    -- Box ESP Fix (İçi boş kareler)
                    obj.B.Visible = _G.SafeCheatConfig.Box
                    obj.B.Size = Vector2.new(size, size * 1.5)
                    obj.B.Position = Vector2.new(pos.X - size/2, pos.Y - size*0.75)
                    obj.B.Color = color
                    obj.B.Thickness = 1.5
                    obj.B.Filled = false -- BÜYÜK DÜZELTME BURADA

                    -- Health Bar
                    obj.H.Visible = _G.SafeCheatConfig.HealthBar
                    obj.H.Size = Vector2.new(3, (size * 1.5) * (hum.Health/hum.MaxHealth))
                    obj.H.Position = Vector2.new(pos.X - size/2 - 6, pos.Y - size*0.75)
                    obj.H.Color = Color3.fromRGB(0, 255, 0)
                    obj.H.Filled = true

                    -- Traces
                    obj.L.Visible = _G.SafeCheatConfig.Traces
                    obj.L.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    obj.L.To = Vector2.new(pos.X, pos.Y)
                        
