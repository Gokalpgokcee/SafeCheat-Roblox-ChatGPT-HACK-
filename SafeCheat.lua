-- [[ G&G OMNI-GOD V7.0 ]]
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")

-- [GENİŞLETİLMİŞ AYARLAR]
_G.SafeCheatConfig = {
    -- Combat
    Aimbot = false, ShowFOV = false, AimSmoothness = 0.1, AimbotFOV = 150, WallCheck = true,
    HitboxExpander = false, HitboxSize = 5,
    -- Visuals
    Box = false, HealthBar = false, Traces = false, Names = false, RGB_Mode = false,
    -- Player
    Noclip = false, InfJump = false, Fly = false, Speed = 16, Jump = 50, Fullbright = false,
    Key = "SafecheatGökalp"
}

-- [GÖRSEL ÇİZİMLER (DRAWING API)]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(0, 255, 255)

local espCache = {}

-- [GUI TASARIMI]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(0, 255, 255)
Stroke.Thickness = 2

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Instance.new("UICorner", Sidebar)

local Pages = {Combat = Instance.new("ScrollingFrame", MainFrame), Visuals = Instance.new("ScrollingFrame", MainFrame), Player = Instance.new("ScrollingFrame", MainFrame)}
for n, p in pairs(Pages) do
    p.Size = UDim2.new(1, -145, 1, -20) p.Position = UDim2.new(0, 135, 0, 10)
    p.BackgroundTransparency = 1 p.Visible = false p.ScrollBarThickness = 2
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)
end
Pages.Combat.Visible = true

-- [UI BİLEŞENLERİ]
local function CreateButton(parent, text, config)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 35) b.BackgroundColor3 = Color3.fromRGB(20,20,20)
    b.Text = text b.TextColor3 = Color3.fromRGB(180,180,180) b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b)
    local s = Instance.new("UIStroke", b) s.Color = Color3.fromRGB(40,40,40)

    b.MouseButton1Click:Connect(function()
        _G.SafeCheatConfig[config] = not _G.SafeCheatConfig[config]
        local act = _G.SafeCheatConfig[config]
        b.TextColor3 = act and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(180,180,180)
        s.Color = act and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(40,40,40)
    end)
end

local function CreateSlider(parent, text, min, max, config)
    local f = Instance.new("Frame", parent) f.Size = UDim2.new(1,-10,0,50) f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f) l.Size = UDim2.new(1,0,0,20) l.Text = text .. ": " .. _G.SafeCheatConfig[config] l.TextColor3 = Color3.new(1,1,1) l.BackgroundTransparency = 1
    local b = Instance.new("Frame", f) b.Size = UDim2.new(1,0,0,6) b.Position = UDim2.new(0,0,0.6,0) b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    local d = Instance.new("TextButton", b) d.Size = UDim2.new(0,16,0,16) d.Position = UDim2.new(0,0,-0.8,0) d.Text = "" d.BackgroundColor3 = Color3.fromRGB(0,255,255) Instance.new("UICorner", d)
    
    d.MouseButton1Down:Connect(function()
        local con; con = RunService.RenderStepped:Connect(function()
            local x = math.clamp((Mouse.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
            d.Position = UDim2.new(x, -8, -0.8, 0)
            local val = math.floor(min + (max-min) * x)
            _G.SafeCheatConfig[config] = val
            l.Text = text .. ": " .. val
        end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then con:Disconnect() end end)
    end)
end

-- [İÇERİK EKLEME]
-- Combat
CreateButton(Pages.Combat, "Aimbot Master", "Aimbot")
CreateButton(Pages.Combat, "Show FOV Circle", "ShowFOV")
CreateButton(Pages.Combat, "Hitbox Expander (OP)", "HitboxExpander")
CreateSlider(Pages.Combat, "Aimbot FOV", 50, 600, "AimbotFOV")
-- Visuals
CreateButton(Pages.Visuals, "Box ESP", "Box")
CreateButton(Pages.Visuals, "Health Bar", "HealthBar")
CreateButton(Pages.Visuals, "Traces", "Traces")
CreateButton(Pages.Visuals, "RGB Mode", "RGB_Mode")
-- Player
CreateButton(Pages.Player, "Noclip", "Noclip")
CreateButton(Pages.Player, "Infinite Jump", "InfJump")
CreateButton(Pages.Player, "Fullbright", "Fullbright")
CreateSlider(Pages.Player, "WalkSpeed", 16, 250, "Speed")
CreateSlider(Pages.Player, "JumpPower", 50, 500, "Jump")

-- [CORE DÖNGÜ]
RunService.RenderStepped:Connect(function()
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    if _G.SafeCheatConfig.RGB_Mode then Stroke.Color = color FOVCircle.Color = color end

    -- FOV Update
    FOVCircle.Visible = _G.SafeCheatConfig.ShowFOV
    FOVCircle.Radius = _G.SafeCheatConfig.AimbotFOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    -- Player Speed/Jump Apply
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = _G.SafeCheatConfig.Speed
        LocalPlayer.Character.Humanoid.JumpPower = _G.SafeCheatConfig.Jump
    end

    local aimTarget = nil
    local shortestDist = _G.SafeCheatConfig.AimbotFOV

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local hum = p.Character.Humanoid
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)

            -- Hitbox Expander Logic
            if _G.SafeCheatConfig.HitboxExpander then
                p.Character.Head.Size = Vector3.new(_G.SafeCheatConfig.HitboxSize, _G.SafeCheatConfig.HitboxSize, _G.SafeCheatConfig.HitboxSize)
                p.Character.Head.Transparency = 0.5
                p.Character.Head.CanCollide = false
            else
                p.Character.Head.Size = Vector3.new(1,1,1)
                p.Character.Head.Transparency = 0
            end

            -- ESP Caching
            if not espCache[p] then espCache[p] = {B = Drawing.new("Square"), L = Drawing.new("Line"), H = Drawing.new("Square")} end
            local obj = espCache[p]

            if onScreen and hum.Health > 0 then
                local size = 2000 / pos.Z
                obj.B.Visible = _G.SafeCheatConfig.Box
                obj.B.Size = Vector2.new(size, size * 1.5)
                obj.B.Position = Vector2.new(pos.X - size/2, pos.Y - size*0.75)
                obj.B.Color = color

                obj.L.Visible = _G.SafeCheatConfig.Traces
                obj.L.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                obj.L.To = Vector2.new(pos.X, pos.Y)
                obj.L.Color = color

                -- Aimbot Target Check
                local mouseDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mouseDist < shortestDist then aimTarget = root shortestDist = mouseDist end
            else
                obj.B.Visible = false obj.L.Visible = false
            end
        end
    end

    -- Aimbot Apply
    if _G.SafeCheatConfig.Aimbot and aimTarget then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimTarget.Position), _G.SafeCheatConfig.AimSmoothness)
    end

    -- Noclip Logic
    if _G.SafeCheatConfig.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

-- SC BUTONU VE GİRİŞ (KEY SİSTEMİ)
local KeyF = Instance.new("Frame", ScreenGui)
KeyF.Size = UDim2.new(0,300,0,150) KeyF.Position = UDim2.new(0.5,-150,0.5,-75) KeyF.BackgroundColor3 = Color3.fromRGB(15,15,15)
local KI = Instance.new("TextBox", KeyF) KI.Size = UDim2.new(0,200,0,30) KI.Position = UDim2.new(0.15,0,0.4,0) KI.PlaceholderText = "Key: SafecheatGökalp"
local KB = Instance.new("TextButton", KeyF) KB.Size = UDim2.new(0,100,0,30) KB.Position = UDim2.new(0.35,0,0.7,0) KB.Text = "LOGIN"
KB.MouseButton1Click:Connect(function() if KI.Text == _G.SafeCheatConfig.Key then KeyF:Destroy() MainFrame.Visible = true end end)

local SCB = Instance.new("TextButton", ScreenGui) SCB.Size = UDim2.new(0,50,0,50) SCB.Position = UDim2.new(0,10,0.4,0) SCB.Text = "G&G"
SCB.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
Instance.new("UICorner", SCB).CornerRadius = UDim.new(1,0)

-- Sekme Değiştirici
local function Tab(n, p)
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(1,-10,0,40) b.Position = p b.Text = n b.BackgroundColor3 = Color3.fromRGB(20,20,20) b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(function() for _,pg in pairs(Pages) do pg.Visible = false end Pages[n].Visible = true end)
end
Tab("Combat", UDim2.new(0,5,0,60)) Tab("Visuals", UDim2.new(0,5,0,110)) Tab("Player", UDim2.new(0,5,0,160))
