local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")

-- [AYARLAR]
_G.SafeCheatConfig = {
    ESP = false, Box = false, Traces = false, RGB_Mode = false,
    Aimbot = false, ShowFOV = false, AimSmoothness = 0.1, AimbotFOV = 100, TargetPart = "Head",
    Noclip = false, InfJump = false, TPTool = false, Fullbright = false,
    Key = "SafecheatGökalp"
}

-- [GUI OLUŞTURUCU - SYNAPSE STYLE]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Draggable = true
MainFrame.Active = true
Instance.new("UICorner", MainFrame)

-- Glow & Shadow
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(0, 255, 255)

-- Sol Sidebar
local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 120, 1, 0)
SideBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", SideBar)

local AppTitle = Instance.new("TextLabel", SideBar)
AppTitle.Size = UDim2.new(1, 0, 0, 50)
AppTitle.Text = "G & G Pro"
AppTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
AppTitle.Font = Enum.Font.GothamBold
AppTitle.TextSize = 18
AppTitle.BackgroundTransparency = 1

-- Sayfalar (Container)
local PageContainer = Instance.new("Frame", MainFrame)
PageContainer.Position = UDim2.new(0, 130, 0, 10)
PageContainer.Size = UDim2.new(1, -140, 1, -20)
PageContainer.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name)
    local page = Instance.new("ScrollingFrame", PageContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ScrollBarThickness = 0
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 6)
    Pages[name] = page
    return page
end

local CombatPage = CreatePage("Combat")
local VisualPage = CreatePage("Visuals")
local PlayerPage = CreatePage("Player")
CombatPage.Visible = true

-- Sekme Butonları
local function AddTab(name, pos)
    local btn = Instance.new("TextButton", SideBar)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Pages[name].Visible = true
    end)
end

AddTab("Combat", UDim2.new(0, 5, 0, 60))
AddTab("Visuals", UDim2.new(0, 5, 0, 100))
AddTab("Player", UDim2.new(0, 5, 0, 140))

-- UI Elemanları (Toggle & Slider)
local function AddToggle(parent, text, config)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(40, 40, 40)

    btn.MouseButton1Click:Connect(function()
        _G.SafeCheatConfig[config] = not _G.SafeCheatConfig[config]
        local active = _G.SafeCheatConfig[config]
        TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = active and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(150, 150, 150)}):Play()
        s.Color = active and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(40, 40, 40)
    end)
end

-- [COMBAT PAGE]
AddToggle(CombatPage, "Enable Aimbot", "Aimbot")
AddToggle(CombatPage, "Show FOV Circle", "ShowFOV")
AddToggle(CombatPage, "No Recoil", "NoRecoil")

-- [VISUAL PAGE]
AddToggle(VisualPage, "Box ESP", "Box")
AddToggle(VisualPage, "Highlight ESP", "ESP")
AddToggle(VisualPage, "Distance Traces", "Traces")
AddToggle(VisualPage, "Neon RGB Mode", "RGB_Mode")

-- [PLAYER PAGE]
AddToggle(PlayerPage, "Noclip", "Noclip")
AddToggle(PlayerPage, "Infinite Jump", "InfJump")
AddToggle(PlayerPage, "Teleport Tool", "TPTool")
AddToggle(PlayerPage, "Fullbright", "Fullbright")

-- [SC TOGGLE BTN]
local SCBtn = Instance.new("TextButton", ScreenGui)
SCBtn.Size = UDim2.new(0, 45, 0, 45)
SCBtn.Position = UDim2.new(0, 10, 0.4, 0)
SCBtn.Text = "G&G"
SCBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SCBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
Instance.new("UICorner", SCBtn).CornerRadius = UDim.new(1, 0)
SCBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- [KEY SYSTEM] - Kısaltılmış versiyon
local KeyFrame = Instance.new("Frame", ScreenGui)
KeyFrame.Size = UDim2.new(0, 300, 0, 150)
KeyFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
KeyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", KeyFrame)
local KI = Instance.new("TextBox", KeyFrame)
KI.Size = UDim2.new(0, 200, 0, 30)
KI.Position = UDim2.new(0.15, 0, 0.4, 0)
KI.Text = ""
KI.PlaceholderText = "SafecheatGökalp"
local KB = Instance.new("TextButton", KeyFrame)
KB.Size = UDim2.new(0, 100, 0, 30)
KB.Position = UDim2.new(0.35, 0, 0.7, 0)
KB.Text = "Login"
KB.MouseButton1Click:Connect(function()
    if KI.Text == _G.SafeCheatConfig.Key then KeyFrame:Destroy() MainFrame.Visible = true end
end)

-- [AIMBOT LOGIC V2]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 255)

local function GetClosestPlayer()
    local target = nil
    local dist = _G.SafeCheatConfig.AimbotFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(_G.SafeCheatConfig.TargetPart) and p.Character.Humanoid.Health > 0 then
            local pos, vis = Camera:WorldToViewportPoint(p.Character[_G.SafeCheatConfig.TargetPart].Position)
            if vis then
                local mDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mDist < dist then
                    dist = mDist
                    target = p.Character[_G.SafeCheatConfig.TargetPart]
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if _G.SafeCheatConfig.Aimbot then
        local t = GetClosestPlayer()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), _G.SafeCheatConfig.AimSmoothness)
        end
    end
    
    FOVCircle.Visible = _G.SafeCheatConfig.ShowFOV
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = _G.SafeCheatConfig.AimbotFOV
    
    -- RGB & Fullbright Logic (Buraya eklenebilir)
end)

print("Safe Cheat V5.0: Synapse Style UI & Aimbot V2 Loaded!")
