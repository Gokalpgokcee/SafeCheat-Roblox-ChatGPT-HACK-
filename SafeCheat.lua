local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- AYARLAR
_G.SafeCheatConfig = {
    ESP = false,
    Traces = false,
    RGB_Mode = false,
    Fullbright = false,
    Key = "SafecheatGökalp"
}

-- [GUI ANA YAPI]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "SafeCheat_Collaborative"

-- [KEY SİSTEMİ PANELİ]
local KeyFrame = Instance.new("Frame", ScreenGui)
KeyFrame.Size = UDim2.new(0, 350, 0, 200)
KeyFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
KeyFrame.BorderSizePixel = 0
local KeyCorner = Instance.new("UICorner", KeyFrame)
local KeyStroke = Instance.new("UIStroke", KeyFrame)
KeyStroke.Color = Color3.fromRGB(0, 255, 255)
KeyStroke.Thickness = 2

local Credits = Instance.new("TextLabel", KeyFrame)
Credits.Size = UDim2.new(1, 0, 0, 30)
Credits.Position = UDim2.new(0, 0, 0, 10)
Credits.Text = "CREATED BY GÖKALP & GEMINI"
Credits.TextColor3 = Color3.fromRGB(0, 255, 255)
Credits.Font = Enum.Font.GothamBold
Credits.TextSize = 14
Credits.BackgroundTransparency = 1

local KeyTitle = Instance.new("TextLabel", KeyFrame)
KeyTitle.Size = UDim2.new(1, 0, 0, 40)
KeyTitle.Position = UDim2.new(0, 0, 0, 40)
KeyTitle.Text = "ACCESS PANEL"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 22
KeyTitle.BackgroundTransparency = 1

local KeyInput = Instance.new("TextBox", KeyFrame)
KeyInput.Size = UDim2.new(0, 250, 0, 40)
KeyInput.Position = UDim2.new(0.5, -125, 0.5, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
KeyInput.Text = ""
KeyInput.PlaceholderText = "Enter Security Key..."
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", KeyInput)

local KeyBtn = Instance.new("TextButton", KeyFrame)
KeyBtn.Size = UDim2.new(0, 120, 0, 35)
KeyBtn.Position = UDim2.new(0.5, -60, 0.75, 5)
KeyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
KeyBtn.Text = "AUTHENTICATE"
KeyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
KeyBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", KeyBtn)

-- [ANA MENÜ PANELİ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 1.2, 0) -- Başta ekranın altında gizli
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 255, 255)
MainStroke.Thickness = 2

-- Sol Sekme Kısmı
local TabSide = Instance.new("Frame", MainFrame)
TabSide.Size = UDim2.new(0, 110, 1, 0)
TabSide.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", TabSide)

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, -130, 1, -20)
Container.Position = UDim2.new(0, 120, 0, 10)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 8)

-- [BUTON OLUŞTURUCU]
local function AddToggle(name, configName)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, -5, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(45, 45, 45)

    btn.MouseButton1Click:Connect(function()
        _G.SafeCheatConfig[configName] = not _G.SafeCheatConfig[configName]
        local active = _G.SafeCheatConfig[configName]
        TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = active and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(150, 150, 150)}):Play()
        TweenService:Create(s, TweenInfo.new(0.3), {Color = active and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(45, 45, 45)}):Play()
    end)
end

AddToggle("Visual ESP", "ESP")
AddToggle("Distance Traces", "Traces")
AddToggle("Neon RGB Mode", "RGB_Mode")
AddToggle("Lighting: Fullbright", "Fullbright")

-- [KEY LOGIC & ANIMATIONS]
KeyBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == _G.SafeCheatConfig.Key then
        -- Key ekranını salla ve yok et
        local tweenOut = TweenService:Create(KeyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -175, -0.5, 0), BackgroundTransparency = 1})
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            KeyFrame:Destroy()
            MainFrame.Visible = true
            MainFrame:TweenPosition(UDim2.new(0.5, -200, 0.5, -150), "Out", "Quart", 0.6, true)
        end)
    else
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "ACCESS DENIED!"
        KeyStroke.Color = Color3.fromRGB(255, 0, 0)
        task.wait(1)
        KeyStroke.Color = Color3.fromRGB(0, 255, 255)
    end
end)

-- [RENDERING]
local espCache = {}
RunService.RenderStepped:Connect(function()
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    if _G.SafeCheatConfig.RGB_Mode then MainStroke.Color = color KeyStroke.Color = color end
    if _G.SafeCheatConfig.Fullbright then game:GetService("Lighting").Brightness = 2 game:GetService("Lighting").ClockTime = 14 end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if not espCache[p] then
                espCache[p] = {H = Instance.new("Highlight", game.CoreGui), L = Drawing.new("Line")}
            end
            local char = p.Character
            local root = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
            local dColor = (dist < 50 and Color3.new(1,0,0) or (dist < 150 and Color3.new(1,0.5,0) or Color3.new(0,1,0)))

            espCache[p].H.Enabled = _G.SafeCheatConfig.ESP
            espCache[p].H.Adornee = char
            espCache[p].H.FillColor = _G.SafeCheatConfig.RGB_Mode and color or dColor

            if _G.SafeCheatConfig.Traces and onScreen then
                espCache[p].L.Visible = true
                espCache[p].L.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                espCache[p].L.To = Vector2.new(pos.X, pos.Y)
                espCache[p].L.Color = espCache[p].H.FillColor
            else
                espCache[p].L.Visible = false
            end
        end
    end
end)

print("Safe Cheat V4.1: Collaborative Version by Gokalp & Gemini Loaded!")
