local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")

-- AYARLAR
_G.SafeCheatConfig = {
    ESP = false,
    Box = false,
    Traces = false,
    RGB_Mode = false,
    Fullbright = false,
    -- Aimbot Ayarları
    Aimbot = false,
    ShowFOV = false,
    AimSmoothness = 0.1,
    AimbotFOV = 100,
    Key = "SafecheatGökalp"
}

-- [GUI ANA YAPI]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 420, 0, 350)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 255, 255)
MainStroke.Thickness = 2

-- [FOVCircle]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Filled = false

-- [SC BUTONU]
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.5, 0)
ToggleBtn.Text = "SC"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- [SEKMELER]
local TabSide = Instance.new("Frame", MainFrame)
TabSide.Size = UDim2.new(0, 110, 1, 0)
TabSide.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", TabSide)

local Pages = {
    Visuals = Instance.new("ScrollingFrame", MainFrame),
    Combat = Instance.new("ScrollingFrame", MainFrame),
    Player = Instance.new("ScrollingFrame", MainFrame)
}

for name, page in pairs(Pages) do
    page.Size = UDim2.new(1, -125, 1, -20)
    page.Position = UDim2.new(0, 115, 0, 10)
    page.BackgroundTransparency = 1
    page.Visible = (name == "Visuals")
    page.ScrollBarThickness = 0
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 8)
end

local function CreateTab(name, pos)
    local btn = Instance.new("TextButton", TabSide)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = pos
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamBold
    btn.MouseButton1Click:Connect(function() 
        for n, p in pairs(Pages) do p.Visible = (n == name) end 
    end)
end

CreateTab("Visuals", UDim2.new(0, 5, 0, 50))
CreateTab("Combat", UDim2.new(0, 5, 0, 90))
CreateTab("Player", UDim2.new(0, 5, 0, 130))

-- [BİLEŞEN OLUŞTURUCULAR]
local function AddToggle(parent, name, configName)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -5, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    Instance.new("UICorner", btn)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(40, 40, 40)

    btn.MouseButton1Click:Connect(function()
        _G.SafeCheatConfig[configName] = not _G.SafeCheatConfig[configName]
        local active = _G.SafeCheatConfig[configName]
        btn.TextColor3 = active and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(150, 150, 150)
        s.Color = active and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(40, 40, 40)
    end)
end

local function AddSlider(parent, name, min, max, configName)
    local bg = Instance.new("Frame", parent)
    bg.Size = UDim2.new(1, -5, 0, 45)
    bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", bg)

    local txt = Instance.new("TextLabel", bg)
    txt.Size = UDim2.new(1, 0, 0, 20)
    txt.Text = name .. ": " .. _G.SafeCheatConfig[configName]
    txt.TextColor3 = Color3.fromRGB(200, 200, 200)
    txt.BackgroundTransparency = 1

    local slideBar = Instance.new("Frame", bg)
    slideBar.Size = UDim2.new(0.8, 0, 0, 5)
    slideBar.Position = UDim2.new(0.1, 0, 0.7, 0)
    slideBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

    local dot = Instance.new("TextButton", slideBar)
    dot.Size = UDim2.new(0, 15, 0, 15)
    dot.Position = UDim2.new(0, 0, -1, 0)
    dot.Text = ""
    dot.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    Instance.new("UICorner", dot)

    dot.MouseButton1Down:Connect(function()
        local moveConn
        moveConn = Mouse.Move:Connect(function()
            local x = math.clamp((Mouse.X - slideBar.AbsolutePosition.X) / slideBar.AbsoluteSize.X, 0, 1)
            dot.Position = UDim2.new(x, -7, -1, 0)
            local val = math.floor(min + (max - min) * x)
            if configName == "AimSmoothness" then val = x end
            _G.SafeCheatConfig[configName] = val
            txt.Text = name .. ": " .. string.format("%.2f", val)
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then moveConn:Disconnect() end
        end)
    end)
end

-- [SEÇENEKLER]
AddToggle(Pages.Visuals, "Highlight ESP", "ESP")
AddToggle(Pages.Visuals, "Box ESP", "Box")
AddToggle(Pages.Visuals, "Traces", "Traces")
AddToggle(Pages.Visuals, "RGB Mode", "RGB_Mode")

AddToggle(Pages.Combat, "Aimbot", "Aimbot")
AddToggle(Pages.Combat, "Show FOV Circle", "ShowFOV")
AddSlider(Pages.Combat, "Smoothness", 0, 1, "AimSmoothness")
AddSlider(Pages.Combat, "FOV Size", 50, 500, "AimbotFOV")

AddToggle(Pages.Player, "Fullbright", "Fullbright")

-- [ANA DÖNGÜ]
local espCache = {}

RunService.RenderStepped:Connect(function()
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    if _G.SafeCheatConfig.RGB_Mode then MainStroke.Color = color FOVCircle.Color = color end

    -- FOV GÜNCELLEME
    FOVCircle.Visible = _G.SafeCheatConfig.ShowFOV
    FOVCircle.Radius = _G.SafeCheatConfig.AimbotFOV
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)

    local target = nil
    local maxDist = _G.SafeCheatConfig.AimbotFOV

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if not espCache[p] then espCache[p] = {B = Drawing.new("Square"), L = Drawing.new("Line"), H = Instance.new("Highlight", game.CoreGui)} end
            
            local char = p.Character
            local obj = espCache[p]

            if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
                local root = char.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                local dColor = _G.SafeCheatConfig.RGB_Mode and color or (dist < 50 and Color3.new(1,0,0) or Color3.new(0,1,0))

                -- ESP SİSTEMİ
                obj.H.Enabled = _G.SafeCheatConfig.ESP
                obj.H.Adornee = char
                obj.H.FillColor = dColor

                if _G.SafeCheatConfig.Box and onScreen then
                    local size = 2500 / pos.Z
                    obj.B.Visible = true
                    obj.B.Size = Vector2.new(size, size * 1.5)
                    obj.B.Position = Vector2.new(pos.X - size/2, pos.Y - size*0.75)
                    obj.B.Color = dColor
                else obj.B.Visible = false end

                if _G.SafeCheatConfig.Traces and onScreen then
                    obj.L.Visible = true
                    obj.L.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    obj.L.To = Vector2.new(pos.X, pos.Y)
                    obj.L.Color = dColor
                else obj.L.Visible = false end

                -- AIMBOT HEDEF SEÇİMİ
                if _G.SafeCheatConfig.Aimbot and onScreen then
                    local mouseDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mouseDist < maxDist then
                        maxDist = mouseDist
                        target = root
                    end
                end
            else
                obj.H.Enabled = false obj.B.Visible = false obj.L.Visible = false
            end
        end
    end

    -- AIMBOT UYGULAMA
    if _G.SafeCheatConfig.Aimbot and target then
        local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, _G.SafeCheatConfig.AimSmoothness)
    end
end)

print("Safe Cheat V4.3: Aimbot & Slider System Loaded!")
