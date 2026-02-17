local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- AYARLAR
_G.SafeCheatConfig = {
    Enabled = true,
    ESP = false,
    Traces = false,
    TeamCheck = true,
    BoxColor = Color3.fromRGB(0, 255, 255),
    TraceColor = Color3.fromRGB(255, 255, 255)
}

-- GUI OLUŞTURMA (MODERN & DRAGGABLE)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SafeCheatV2"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- AÇMA/KAPAMA BUTONU (DELTA İÇİN)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0.5, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "SC"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

-- ANA PANEL
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true -- Delta/Mobil için önemli

local Corner = Instance.new("UICorner", MainFrame)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "SAFE CHEAT V2"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- MENÜ BUTON FONKSİYONU
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local function CreateToggle(name, pos, configName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name .. ": KAPALI"
    btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    btn.Font = Enum.Font.Gotham
    btn.Parent = MainFrame
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        _G.SafeCheatConfig[configName] = not _G.SafeCheatConfig[configName]
        btn.Text = name .. ": " .. (_G.SafeCheatConfig[configName] and "AÇIK" or "KAPALI")
        btn.TextColor3 = _G.SafeCheatConfig[configName] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
end

CreateToggle("ESP (Kutu)", UDim2.new(0.06, 0, 0.25, 0), "ESP")
CreateToggle("Traces (Çizgi)", UDim2.new(0.06, 0, 0.45, 0), "Traces")
CreateToggle("Team Check", UDim2.new(0.06, 0, 0.65, 0), "TeamCheck")

-- OPTİMİZE ESP VE TRACES SİSTEMİ
local function CreateESP(player)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Enabled = false
    highlight.Parent = game.CoreGui -- Performans için CoreGui

    local line = Drawing.new("Line") -- Traces için Drawing API (En hızlısı)
    line.Visible = false
    line.Thickness = 1
    line.Color = _G.SafeCheatConfig.TraceColor

    RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
            local root = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            -- Team Check
            local isTeammate = _G.SafeCheatConfig.TeamCheck and player.Team == LocalPlayer.Team
            
            -- ESP Güncelleme
            if _G.SafeCheatConfig.ESP and onScreen and not isTeammate then
                highlight.Adornee = player.Character
                highlight.Enabled = true
                highlight.FillColor = _G.SafeCheatConfig.BoxColor
            else
                highlight.Enabled = false
            end

            -- Traces Güncelleme
            if _G.SafeCheatConfig.Traces and onScreen and not isTeammate then
                line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Ekranın alt ortası
                line.To = Vector2.new(screenPos.X, screenPos.Y)
                line.Visible = true
            else
                line.Visible = false
            end
        else
            highlight.Enabled = false
            line.Visible = false
        end
    end)
end

-- Mevcut ve yeni oyunculara ESP ekle
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

print("Safe Cheat V2: Delta Sürümü Yüklendi!")
