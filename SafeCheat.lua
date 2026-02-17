local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- AYARLAR
_G.SafeCheatConfig = {
    ESP = false,
    Box = false,
    Traces = false,
    RGB_Mode = false,
    Fullbright = false,
    NoRecoil = false,
    Key = "SafecheatGökalp"
}

-- [GUI ANA YAPI]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "SafeCheat_V42"

-- [SC GİZLE/GÖSTER BUTONU]
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.5, 0)
ToggleBtn.Text = "SC"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local btnStroke = Instance.new("UIStroke", ToggleBtn)
btnStroke.Color = Color3.fromRGB(0, 255, 255)

-- [ANA MENÜ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 420, 0, 300)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 255, 255)
MainStroke.Thickness = 2

-- Yan Menü (Sekmeler)
local TabSide = Instance.new("Frame", MainFrame)
TabSide.Size = UDim2.new(0, 110, 1, 0)
TabSide.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", TabSide)

local Title = Instance.new("TextLabel", TabSide)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "G&G V4.2"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

-- Bölme Konteynırları
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
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 5)
end

-- Sekme Değiştirme Fonksiyonu
local function ShowPage(pageName)
    for name, page in pairs(Pages) do
        page.Visible = (name == pageName)
    end
end

-- Sekme Butonları Oluştur
local function CreateTab(name, pos)
    local btn = Instance.new("TextButton", TabSide)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = pos
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamBold
    btn.MouseButton1Click:Connect(function() ShowPage(name) end)
end

CreateTab("Visuals", UDim2.new(0, 5, 0, 50))
CreateTab("Combat", UDim2.new(0, 5, 0, 90))
CreateTab("Player", UDim2.new(0, 5, 0, 130))

-- Özellik Butonu Oluşturucu
local function AddOption(parent, name, configName)
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

-- Seçenekleri Ekle
AddOption(Pages.Visuals, "Highlight ESP", "ESP")
AddOption(Pages.Visuals, "Box ESP (Kutu)", "Box")
AddOption(Pages.Visuals, "Distance Traces", "Traces")
AddOption(Pages.Visuals, "RGB Mode", "RGB_Mode")

AddOption(Pages.Combat, "No Recoil (Beta)", "NoRecoil")

AddOption(Pages.Player, "Fullbright", "Fullbright")

-- Menü Açma/Kapama
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- [ESP VE BOX SİSTEMİ]
local espCache = {}

local function UpdateESP()
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    if _G.SafeCheatConfig.RGB_Mode then MainStroke.Color = color end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            if not espCache[p] then
                espCache[p] = {
                    Box = Drawing.new("Square"),
                    Line = Drawing.new("Line"),
                    High = Instance.new("Highlight", game.CoreGui)
                }
            end
            
            local char = p.Character
            local obj = espCache[p]

            if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
                local root = char.HumanoidRootPart
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                local dColor = _G.SafeCheatConfig.RGB_Mode and color or (dist < 50 and Color3.new(1,0,0) or Color3.new(0,1,0))

                -- Highlight ESP
                obj.High.Enabled = _G.SafeCheatConfig.ESP
                obj.High.Adornee = char
                obj.High.FillColor = dColor

                -- BOX ESP
                if _G.SafeCheatConfig.Box and onScreen then
                    local sizeX = 2000 / pos.Z
                    local sizeY = 3000 / pos.Z
                    obj.Box.Visible = true
                    obj.Box.Size = Vector2.new(sizeX, sizeY)
                    obj.Box.Position = Vector2.new(pos.X - sizeX/2, pos.Y - sizeY/2)
                    obj.Box.Color = dColor
                    obj.Box.Thickness = 1.5
                else
                    obj.Box.Visible = false
                end

                -- TRACES
                if _G.SafeCheatConfig.Traces and onScreen then
                    obj.Line.Visible = true
                    obj.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    obj.Line.To = Vector2.new(pos.X, pos.Y)
                    obj.Line.Color = dColor
                else
                    obj.Line.Visible = false
                end
            else
                obj.High.Enabled = false
                obj.Box.Visible = false
                obj.Line.Visible = false
            end
        end
    end
end

RunService.RenderStepped:Connect(UpdateESP)

-- [KEY SİSTEMİ (V4.1'den)]
-- Not: Key sistemi kodu buraya eklenebilir veya KeyFrame direkt yaratılabilir.
-- G&G V4.2 Yüklendi!
